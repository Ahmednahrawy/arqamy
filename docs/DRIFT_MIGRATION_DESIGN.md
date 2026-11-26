# Arqamy — Drift Adoption and Legacy Invoice Migration Design

**Repository:** `Ahmednahrawy/arqamy`  
**Branch:** `main`  
**Design status:** Approved for documentation only  
**Implementation status:** Not authorized by this document  
**Scope:** Migration from the SharedPreferences `saved_invoices` store to Drift/SQLite as the authoritative local invoice store.

---

## 1. Purpose and decision boundary

Arqamy's product direction requires Drift/SQLite to become the authoritative local persistence layer for business data. The current production invoice workflow still uses the SharedPreferences key `saved_invoices`. Existing Drift ledger and migration components are a foundation, but they do not yet replace the app-wide invoice store.

This document defines the proposed migration architecture, data-preservation rules, validation, execution, reconciliation, cutover, rollback, and acceptance criteria.

**This is a design document, not implementation authorization.** It does not authorize database schema changes, generated-code changes, migration scripts, repository rewiring, SharedPreferences deletion, or production behavior changes. Each implementation step remains separately gated by review and approval.

## 2. Current implementation verified on main

**Reviewed baseline:** `main` merge commit `271d330` (2026-11-26). The current Drift schema version is **7**.

### Implemented migration foundation

The following components now exist in the repository:

- `LegacyInvoiceSnapshotService` captures the raw `saved_invoices` preference directly, records whether the key exists, writes a content-addressed raw file and manifest, and verifies the raw file by byte length and SHA-256.
- `LegacyInvoicePreflightService` verifies the snapshot and parses the top-level JSON array record by record. It retains source index, raw record fragment, occurrence identity, malformed reasons, and audit findings. It distinguishes ready, needs-review, duplicate-identity, and malformed-record outcomes; fatal snapshot/JSON errors stop preflight.
- `LegacyInvoiceSourceOccurrenceIdentity` creates a versioned deterministic key from snapshot digest, source index, and exact record-fragment digest.
- `LegacyInvoicePartyResolutionPlanner` proposes customer/supplier identity and role per source occurrence. It does not create parties or automatically merge ambiguous names.
- `LegacyInvoicePartyResolutionReview` supports explicit review decisions against the snapshot and occurrence identity.
- `LegacyPartyReviewJournalRepository` persists migration-run metadata, frozen occurrence/review snapshots, and append-only, idempotent decisions. The D3.2 schema migration upgrades the database to version 7 and strengthens the insert-validation trigger for resolved suggestions.

### Existing import foundation — not yet migration-safe

- `LedgerImportPlanner` and `LedgerImportExecutor` exist. The executor writes within a Drift transaction and requires a backup callback.
- However, the planner's `legacyRecordKeyFor(invoice)` still returns `saved_invoices/{invoice.id}`. Duplicate IDs are held when the planner receives them together, but the key is not a unique source-occurrence identity.
- `LedgerImportService.preview` currently loads typed invoices through `InvoiceProvider`; it does not orchestrate the raw snapshot/preflight/review pipeline.
- The current backup callback uses the typed invoice backup service. That is not equivalent to a verified, independently recoverable byte-for-byte source snapshot.

### Current production boundary

The application continues to read and write operational invoices through SharedPreferences key `saved_invoices`. The new snapshot/preflight/review components are migration preparation tools; they do not switch production reads or writes to Drift.

The current snapshot service writes to app-private storage. An independently recoverable/user-exportable snapshot and verified restore workflow are still required before cutover.

### Known validation note

The latest owner-reported local validation on this baseline is `flutter analyze` clean and **362 tests passed**. The payment-ledger concurrency tests still emit Drift multiple-`AppDatabase` warnings. They did not fail the test run, but the underlying executor/handle ownership must be investigated rather than suppressing the warning.

The original typed-model concern remains relevant to ordinary app loading: `Invoice.fromJson` still performs direct casts. The migration preflight avoids relying on that all-or-nothing decode path, but it does not by itself harden the production loader.

## 3. Non-negotiable migration invariants

1. Never mutate or delete the legacy source before migration acceptance.
2. Preserve every source occurrence, including malformed records and duplicate IDs.
3. Never use a legacy invoice ID as the sole identity of a source occurrence.
4. Never silently discard, normalize, round, or guess business data.
5. Never auto-merge ambiguous customer/supplier identities.
6. Preserve historical invoice totals, paid values, and remaining values as historical document data.
7. Never infer individual cash movements from an invoice aggregate `paid` value.
8. Do not create payment events, cash events, allocations, or accounting entries from invoice aggregates.
9. Make import retry-safe and idempotent for the same immutable source snapshot.
10. Do not switch production reads/writes until reconciliation and explicit acceptance.
11. Do not maintain uncontrolled dual-write between SharedPreferences and Drift.
12. Every failure must leave the source recoverable and the destination in a known state.

## 4. Target migration architecture

The target pipeline remains:

1. Capture an immutable raw source snapshot. **Foundation implemented; independent export/restore remains open.**
2. Perform read-only, record-level preflight. **Implemented.**
3. Assign deterministic identity to each source occurrence. **Implemented.**
4. Resolve party identity and role without guessing. **Planner and explicit review workflow implemented; persistent review journal implemented through D3.2.**
5. Build an import plan using existing ledger mapping where its contract is safe. **Existing planner is not yet occurrence-key safe.**
6. Import eligible invoices and lines transactionally into Drift. **Not yet implemented as the production migration path.**
7. Preserve held and malformed records in a durable, traceable migration store. **Review metadata is persisted; durable raw-record quarantine/import-state handling still needs design.**
8. Reconcile source and destination. **Specification exists; executable reconciliation is not complete.**
9. Obtain explicit acceptance.
10. Cut over the application repository to Drift.
11. Retain the legacy snapshot and a tested recovery path.

The existing `LedgerImportPlanner`, `LedgerImportExecutor`, party registry, occurrence identity, and review journal should be reused or extended where their current contracts fit. Do not create parallel mapping or customer-matching engines. The party-review journal is not an import-execution journal: it records review decisions, not invoice-import progress or transaction recovery state.

## 5. Stage A — immutable raw source snapshot

### 5.1 Capture

Before decoding, read the exact string stored under SharedPreferences key `saved_invoices`. Capture:

- exact raw string (including original whitespace and formatting);
- UTF-8 byte length;
- SHA-256 digest of the UTF-8 bytes;
- source key and application/database context;
- capture timestamp;
- snapshot format/version identifier.

An absent key and an empty string must be represented distinctly. The snapshot operation must not call `InvoiceProvider.loadInvoices()` as its source of truth.

### 5.2 Storage and verification

Store the raw snapshot in the app-private migration backup area and provide a user-exportable copy or another independently recoverable location before destructive cutover is considered. Verify the written copy by reading it back and recomputing its byte length and SHA-256 digest.

The existing typed `InvoiceBackup` format remains useful for ordinary backup/restore, but it is not a substitute for this raw snapshot because it serializes decoded invoice objects and cannot preserve malformed source fragments or the exact original source representation.

### 5.3 Failure behavior

If capture, write, read-back, or hash verification fails, stop. No preflight import or source mutation may proceed.

## 6. Stage B — read-only record-level preflight

A dedicated decoder should inspect the raw snapshot without changing it or relying on the current all-or-nothing `Invoice.fromJson()` path.

It should validate the top-level JSON shape and then validate each source occurrence independently. For each occurrence, retain its original array index, exact raw fragment when available, decoded representation when valid, validation findings, and classification.

Suggested classifications:

| Classification | Meaning | Import behavior |
|---|---|---|
| Ready | Structurally valid, financially valid, identity resolved | Eligible for planning |
| Needs identity | Invoice valid but party identity/role unresolved | Hold |
| Duplicate identity | Legacy ID appears more than once | Hold all colliding occurrences pending review |
| Malformed record | Record cannot be decoded or required fields have invalid types | Preserve raw occurrence; hold |
| Unknown action | Action cannot be mapped to an approved invoice type | Hold |
| Financial discrepancy | Invalid amount, unsupported precision, or inconsistent totals | Hold |
| Product/line discrepancy | Missing, malformed, or inconsistent line data | Hold |

The exact validation rules must be derived from the legacy model, product model, invoice action rules, and existing audit findings. They must not be invented during import.

If the top-level JSON is invalid and safe record boundaries cannot be established, stop the migration and preserve the entire raw snapshot. Do not attempt heuristic splitting or partial reconstruction.

Preflight must produce a deterministic report and must not write business invoices, parties, accounts, payment events, or other ledger records.

## 7. Stage C — deterministic source-occurrence identity

The source occurrence identity must be distinct from the legacy invoice ID, invoice serial, and destination Drift primary key.

Proposed identity inputs:

- immutable snapshot digest;
- original source occurrence index;
- digest of the exact raw record fragment.

Conceptual key:

`sourceOccurrenceKey = version + snapshotDigest + occurrenceIndex + recordDigest`

Implemented encoding (identity version 1): `v1:{snapshotSha256}:{sourceIndex}:{recordSha256}`. The key is generated by `LegacyInvoiceSourceOccurrenceIdentity.create`. The current implementation validates a non-negative source index and a 64-character hexadecimal snapshot digest. Any future format change must increment the identity version and must not reinterpret existing journal rows. Database uniqueness and importer use of this key remain part of the import design review.

Properties:

- Two occurrences with the same legacy ID remain distinguishable.
- Two byte-identical records at different array positions remain distinguishable.
- Re-running against the same snapshot produces the same occurrence keys.
- A changed source snapshot is a different migration input and must not silently reuse the prior run's identity.
- Reordering the source array creates a different snapshot and therefore a new migration input; the migration must not assume that index-based identity survives arbitrary source edits.

The existing `saved_invoices/{invoice.id}` key is insufficient for duplicate occurrences. It must not be reused as the sole key for the new occurrence-level migration.

For duplicate legacy IDs, preserve all occurrences in migration staging/quarantine. Do not import one arbitrarily. A human-reviewed resolution must decide whether the records are separate business documents, duplicate copies, or a conflict requiring correction. The original records remain preserved regardless of the decision.

## 8. Stage D — party identity and role resolution

Reuse the existing customer registry and linking workflow, including the customer-linking service and linker. Extend it only if supplier-role handling or occurrence-level reporting requires it.

Rules:

- Reuse an existing confirmed party ID when the mapping is unambiguous.
- Sales and storage documents resolve to the customer role.
- Purchase documents resolve to the supplier role.
- Do not infer a supplier from a customer with a similar name.
- Do not merge spelling variants or ambiguous normalized-name groups automatically.
- Do not create a party merely to make an invoice importable unless a separately approved identity-resolution workflow explicitly authorizes it.
- Keep unresolved invoices held and traceable.
- Preserve the original display name and source JSON even after a party is linked.

Identity decisions should be recorded with the source occurrence key, selected party, role, decision time, and review provenance.

## 9. Stage E — legacy-to-Drift mapping

Reuse the existing ledger invoice mapper and draft model. Confirm the exact destination columns and constraints against the current schema before implementation.

| Legacy source | Intended destination / treatment |
|---|---|
| Invoice `id` | Preserve as `legacy_invoice_id`; do not use as occurrence identity |
| Invoice serial | Preserve as legacy/human-facing serial |
| Invoice action | Map only recognized sale, purchase, and storage actions; preserve original action text |
| Customer/supplier name | Preserve original display value; link to a confirmed party and role |
| Customer ID | Use only when valid and consistent with the party registry |
| Invoice total | Preserve original value; convert to minor units only when safely validated under the approved EGP policy |
| `paid` aggregate | Preserve as historical invoice value; never generate cash events |
| `rest` aggregate | Preserve as historical remaining value |
| Product list | Map each validated line, preserving order |
| Original source occurrence | Preserve exact raw record and occurrence identity |
| Unknown/extra legacy fields | Preserve in source JSON even if no operational column exists |

The current import service uses EGP with a two-decimal scale, explicitly documented as an owner-confirmed decision. The migration must continue to use that approved configuration; it must not infer currency from device locale or display formatting.

### Financial integrity

Historical invoice aggregates and physical cash movements are separate concepts. A legacy invoice with `paid = 500` does not prove that a single 500-unit cash event occurred. It could represent multiple payments, a manually entered aggregate, or historical data without event-level evidence.

Therefore migration must preserve `paid` and `rest` as historical values and must not synthesize:

- cash events;
- payment records;
- payment allocations;
- refunds;
- reversals;
- bank/cash account movements.

Any later opening-balance or historical-payment reconstruction requires a separate evidence-backed business process and explicit approval.

## 10. Stage F — migration journal and transactional import

A persistent **party-review journal** is implemented in schema version 7. It records a run bound to a snapshot digest and processing versions, frozen occurrence/preflight/resolution data, and append-only decisions with idempotency and supersession history.

This journal is deliberately limited to review. It does not record invoice import attempts, per-invoice transactional progress, reconciliation results, or cutover state. A separate **migration execution journal** is still required and must not be conflated with the party-review journal.

The proposed execution journal should record the snapshot identity, migration version, timestamps, source counts, classification counts, and final state. Each source occurrence should have a durable import status and traceable findings. Suggested states:

- captured;
- preflighted;
- ready;
- held;
- importing;
- imported;
- failed;
- reconciled;
- accepted.

The final state model and schema are subject to a separate schema proposal and approval.

### Transaction boundary

An invoice and all of its lines, plus the occurrence-to-destination mapping, must commit atomically. If any part fails, the transaction must roll back so that no partially imported invoice remains.

Party/account prerequisites must be validated before writes. The executor must distinguish:
- newly imported;
- already imported for this exact occurrence and snapshot;
- held;
- failed;
- skipped because a required party is missing.

An existing destination row must never be overwritten merely because a legacy ID or serial matches. Idempotency must be based on the immutable source occurrence identity and migration version.

The current executor already uses a transaction and performs a backup callback before execution. Those are useful foundations, but its current invoice key is based on `saved_invoices/{invoice.id}`; it must be adapted to the immutable source-occurrence key and migration version before it can safely support duplicate source IDs or distinct occurrences with identical invoice IDs. The executor must also persist import progress/recovery state without allowing a partial invoice/line/mapping commit.

## 11. Stage G — reconciliation

A successful database write is not sufficient evidence of a successful migration.

Generate a reconciliation report with at least:

| Check | Acceptance condition |
|---|---|
| Raw snapshot | Original source digest and byte length unchanged |
| Occurrence accounting | Every source occurrence has exactly one terminal classification |
| Import count | Imported occurrences equal the approved ready set |
| Held records | Every held occurrence retains its raw source and reason |
| Duplicate IDs | No collision or silent overwrite |
| Invoice identity | Every destination invoice maps to one source occurrence |
| Invoice lines | Counts, order, and validated values match |
| Invoice totals | Source and destination values reconcile under explicit precision rules |
| Paid/remaining | Historical aggregates preserved exactly or represented losslessly |
| Party links | Every imported invoice has a valid party and role |
| Payment ledger | No cash events or allocations were synthesized from aggregates |
| Foreign keys | No violations |
| SQLite integrity | `PRAGMA integrity_check` returns `ok` |
| Reopen test | Database closes and reopens with the same results |
| Idempotency | Repeating the same migration creates no additional business records |
| Failure recovery | Injected failures leave a resumable, internally consistent state |

Any mismatch must be reported, not silently repaired. Financial discrepancies, unresolved duplicates, or missing source occurrences block acceptance.

## 12. Stage H — cutover

Cutover is a separate, explicitly approved operation.

Proposed sequence:

1. Confirm a verified raw source snapshot exists outside the active database.
2. Complete preflight and resolve all records required for the initial operational scope.
3. Import eligible records and preserve held records in the migration review store.
4. Run all reconciliation checks and obtain a reviewed report.
5. Obtain explicit owner acceptance.
6. Switch invoice reads and writes to a Drift-backed repository behind the existing application-facing interface.
7. Ensure all invoice lifecycle operations use the same authoritative repository.
8. Keep the legacy SharedPreferences value and raw snapshot retained and read-only for the agreed recovery period.
9. Verify cold start, create, edit, delete, restore, and failure behavior against Drift.

The application must not write independently to both SharedPreferences and Drift as two competing authorities. If a temporary compatibility adapter is required during rollout, its exact ownership and failure semantics must be designed and approved before implementation.

## 13. Rollback and recovery

Before cutover, rollback is straightforward: the application continues using the untouched SharedPreferences source, and the incomplete Drift migration can be discarded or resumed without changing the source.

After cutover, simply switching back to the original SharedPreferences snapshot could lose invoices created or modified after cutover. Therefore post-cutover rollback requires a reverse-recovery plan that accounts for all post-cutover Drift changes.

Required safeguards:

- retain the immutable original snapshot;
- retain migration journal and reconciliation report;
- retain Drift database backup at the cutover boundary;
- document how post-cutover writes are exported/replayed or otherwise preserved;
- never restore an old snapshot over newer business data without explicit reconciliation;
- stop writes or enter a controlled recovery mode if database integrity is uncertain.

The exact post-cutover rollback mechanism must be finalized before cutover implementation is approved.

## 14. Application behavior on migration failure

- Snapshot failure: stop before parsing/import; leave the app on the legacy store.
- Preflight failure: preserve the raw snapshot and report the failure; no business records are written.
- Identity ambiguity: hold affected occurrences; do not guess.
- Import transaction failure: roll back the affected transaction; record a recoverable failure state.
- Reconciliation failure: block acceptance and cutover.
- Database integrity failure: do not continue normal writes; preserve files and enter a controlled recovery path.
- App restart during migration: resume only from the journal after verifying the source snapshot digest and migration version.

User-facing error and recovery screens must be localized in Arabic and English before the migration workflow is exposed.

## 15. Implementation sequence (each step separately gated)

The following foundations are complete and recorded in `docs/finished_tasks.md`:

- Raw SharedPreferences snapshot capture, content-addressed storage, manifest, and raw-file verification.
- Read-only record-level preflight and malformed/fatal classification.
- Deterministic source-occurrence identity version 1.
- Party-resolution planning and explicit review decisions.
- Persistent party-review journal, including append-only/idempotent decisions and the D3.2 schema-v7 trigger migration.

Remaining sequence:

1. Design and implement an independently recoverable/exportable raw snapshot plus verified restore procedure.
2. Finalize the migration execution journal schema and lifecycle separately from the party-review journal.
3. Adapt planner, mapper, and executor to use source-occurrence identity plus migration version; stop using invoice ID as the sole import key.
4. Define durable quarantine/held-record storage for malformed and unresolved occurrences, retaining exact raw fragments.
5. Implement transactional, resumable import of invoice, lines, and occurrence mapping, with injected-failure tests.
6. Implement executable reconciliation and a signed/reviewable acceptance report.
7. Implement a Drift-backed invoice repository behind the current application-facing contract.
8. Integrate create, read, update, delete, restore, and customer-history workflows with one authoritative repository.
9. Finalize and test post-cutover rollback/recovery, including data created after cutover.
10. Request explicit approval for cutover; do not switch automatically.

No remaining step authorizes the next step. Review and approval are required before each material schema, architecture, or production behavior change.

## 16. Definition of migration acceptance

Migration is accepted only when all of the following are true:

- A byte-for-byte recoverable source snapshot has been verified.
- Every source occurrence is accounted for.
- Every imported invoice maps to exactly one source occurrence.
- Duplicate and malformed records are preserved and explicitly classified.
- All required party relationships are valid and unambiguous.
- Invoice and line data reconcile.
- Historical total, paid, and remaining values are preserved without inventing cash movements.
- No payment events or allocations were inferred from invoice aggregates.
- The import is repeatable and idempotent.
- Database and foreign-key integrity checks pass.
- Restart and failure-recovery tests pass.
- The owner has reviewed and accepted the reconciliation report.
- A post-cutover recovery plan is approved before production cutover.

---

## 17. Explicitly out of scope

This design does not authorize or implement:

- any Drift schema or generated-code change;
- any migration or production Dart code;
- any SharedPreferences deletion or source rewrite;
- any payment-event reconstruction;
- any automatic duplicate merging;
- any automatic party merging;
- Firebase or cloud synchronization;
- tenant/business architecture;
- UI changes beyond future localized migration/recovery surfaces;
- production cutover.

These remain separate, reviewable tasks.
