# Arqamy — D4 Repository Audit and Contract Alignment

**Repository:** Ahmednahrawy/arqamy  
**Audited ref:** main at the D4 documentation baseline, after owner approval of the seven D4 design decisions  
**Audit status:** Inspection only  
**Implementation status:** Not authorized  
**Scope:** Existing snapshot, preflight, occurrence identity, party-review journal, Drift invoice schema, and ledger importer foundations.

---

## 1. Executive finding

The repository already contains useful migration-preparation foundations, but it does **not** yet implement the D4 execution contract.

The most important gap is that the current ledger importer still operates on typed invoices and uses `saved_invoices/{invoice.id}` as its idempotency key. It does not consume the immutable source-occurrence identity or persist invoice-import execution progress. It also adds missing party roles during import, which must not be carried into the approved migration workflow because party/role decisions must remain explicit and auditable.

No code or schema changes were made during this audit.

## 2. Inspected components

| Component | Current responsibility | D4 assessment |
|---|---|---|
| `LegacyInvoiceSnapshotService` | Captures raw SharedPreferences value, SHA-256, byte length, and manifest | Good source snapshot foundation; export/restore not implemented |
| `LegacyInvoicePreflightService` | Verifies snapshot and classifies each JSON array occurrence | Good read-only preflight foundation; versioned durable execution state absent |
| `LegacyInvoiceSourceOccurrenceIdentity` | Creates v1 key from snapshot digest, source index, and raw fragment digest | Correct identity primitive; not yet wired into ledger import |
| `LegacyPartyReviewJournalRepository` | Persists D3.2 party review run, occurrences, and decisions | Separate party-review journal exists; must remain distinct from execution journal |
| `LedgerImportPlanner` | Plans from typed invoice models, detects duplicate IDs, creates ready/held collections | Must be adapted to source occurrences and effective review decisions |
| `LedgerImportExecutor` | Writes currency, roles, accounts, invoices, and lines inside a transaction after backup callback | Not a resumable occurrence-aware executor; no D4 execution journal |
| `LedgerImportService` | Preview loads `InvoiceProvider`; run opens Drift and calls executor | Preview is not raw-snapshot/preflight/review based |
| `LedgerFoundationRepository.saveInvoiceDraft` | Inserts invoice and lines, returning existing invoice when legacy key already exists | Existing-key path does not verify content fingerprint or line integrity |
| `AppDatabase` invoice tables | Drift invoice and line storage with legacy metadata fields | Can store current import output, but does not yet contain D4 execution/mapping tables |

## 3. Confirmed implementation facts

### 3.1 Snapshot and preflight

- Snapshot capture reads the raw `saved_invoices` SharedPreferences string directly, without serializing `InvoiceProvider` models.
- The snapshot is stored under the app's application-support directory in a content-addressed raw file, with a JSON manifest.
- The manifest records format version, source key, source-key existence, SHA-256, byte length, capture time, and raw filename.
- Capture verifies the bytes written to the local raw file.
- The current service does not export the snapshot to an independently selected destination, verify a copied export, or implement staging restore.
- Preflight verifies the raw file's byte length and SHA-256 before parsing.
- Preflight retains the original raw snapshot and exposes a per-occurrence raw JSON fragment. The fragment excludes surrounding whitespace; the complete snapshot remains the byte-for-byte source of truth.
- Preflight classifies records as ready, needs review, duplicate identity, or malformed record. Fatal source-level issues include missing source, integrity failure, invalid UTF-8, invalid JSON, and invalid top-level shape.

### 3.2 Occurrence identity

The current identity is version 1:

`v1:{snapshotSha256}:{sourceIndex}:{recordSha256}`

The record digest is computed from UTF-8 bytes of the raw JSON element fragment. The key is independent of legacy invoice ID and serial, and identical records at different source indexes remain distinct.

This identity is created during preflight but is not passed into the existing `LedgerImportPlanner` or `LedgerImportExecutor`.

### 3.3 Party-review journal boundary

The existing Drift tables are:
- `legacy_migration_runs`;
- `legacy_migration_occurrences`;
- `legacy_party_review_decisions`.

These tables represent party-resolution review, not invoice-import execution. The repository explicitly limits itself to review data and does not create parties, change roles, link invoices, or write finance data. The execution journal must therefore use distinct tables/records and reference the effective review decision rather than repurpose these tables.

### 3.4 Current importer path

- `LedgerImportService.preview(InvoiceProvider)` calls `provider.loadInvoices()` and plans from `provider.invoices`.
- `LedgerImportPlanner.legacyRecordKeyFor(invoice)` returns `saved_invoices/{invoice.id}`.
- The planner counts typed invoice IDs and holds every invoice with a duplicated ID. It has no source index, raw-record digest, or source-occurrence key.
- The planner maps from the decoded invoice model. The mapper documents that its `sourceJson` is produced by `jsonEncode(invoice.toJson())`, not the original raw source JSON.
- `LedgerImportExecutor.execute` calls a backup callback and then wraps the import plan in one database transaction.
- The executor ensures currency, party roles, and financial accounts exist before writing invoices.
- If a party role is missing, the executor adds that role automatically. D4 must not use this behavior for migration party resolution; the effective approved party decision and required role must already be valid at import time.
- If the party does not exist, the executor increments `skippedMissingParty` and continues. This is not a durable occurrence outcome and cannot satisfy D4 occurrence accounting.
- The executor checks whether a legacy record key already exists, then calls `saveInvoiceDraft`. The repository returns the existing invoice ID when that key is present, without comparing the stored invoice/lines to the expected source fingerprint.
- The existing importer transaction is plan-wide, rather than a separately journaled occurrence claim followed by an occurrence-level atomic invoice/lines/mapping/state commit.
- There is no durable attempt sequence, lease/claim token, execution status transition history, or operator-action event stream.

### 3.5 Existing invoice and line storage

The Drift `invoices` table has a nullable unique `legacy_record_key`, legacy invoice ID, source JSON, party/role/account/currency fields, action, totals, legacy paid/rest text values, and issued timestamp.

The `invoice_lines` table references the invoice, stores line order, product/quantity/package/price/total/currency/source JSON, and enforces unique invoice/line-index pairs.

`LedgerFoundationRepository.saveInvoiceDraft` inserts the invoice and all its lines inside a transaction. This is a useful atomic insertion primitive. However, D4 still needs the occurrence mapping and successful journal state to commit in the same transaction. The repository's current existing-key return path needs integrity/fingerprint verification rather than blind acceptance.

## 4. D4 gaps and required treatment

| Priority | Gap | Required treatment before production import |
|---|---|---|
| Blocker | Planner/executor use legacy invoice ID key, not occurrence identity | Replace with versioned source-occurrence idempotency contract |
| Blocker | Preview starts from typed `InvoiceProvider` models | Build the approved flow from verified snapshot → preflight → party-review decision → occurrence planner |
| Blocker | Missing party roles are added automatically | Require valid existing party and role matching the effective approved decision; otherwise hold |
| Blocker | Missing parties are skipped only in an in-memory count | Persist an explicit held/failure/excluded occurrence outcome and reason |
| Blocker | Existing idempotency hit is accepted without comparing content | Verify destination mapping and destination fingerprint; mismatches become conflicts |
| Blocker | No execution journal or occurrence mapping | Add separate run, occurrence, attempt, operator-event, and occurrence-mapping persistence after schema approval |
| Blocker | No independent snapshot export/restore | Implement verified export and staging restore before production import |
| High | Current transaction covers the whole plan, not one claimed occurrence | Design occurrence-level atomic invoice + lines + mapping + success-state transaction |
| High | Current typed backup is not raw snapshot export | Use the independently verifiable raw snapshot package as the pre-import recovery artifact |
| High | No durable reconciliation/acceptance report | Reconcile all occurrences and gate acceptance on complete evidence |
| High | No post-cutover write replay strategy | Design/test forward recovery before cutover |
| High | Source JSON in mapper is re-serialized | Preserve exact source evidence through the immutable snapshot; destination source_json may remain a normalized convenience copy only |

## 5. Existing schema reuse and likely D4 persistence boundary

The current schema already has party-review tables and invoice/line tables. D4 should not add duplicate party-review storage or create a second invoice/line model.

The schema proposal should evaluate distinct execution structures for:
- execution run identity and immutable version binding;
- execution occurrence state and source evidence references;
- append-only execution attempts;
- append-only operator-action events;
- unique source-occurrence-to-destination-invoice mapping.

The final table names, columns, foreign keys, indexes, triggers, and schema migration must be proposed against the complete current schema and then approved separately. This audit does not authorize any schema modification.

## 6. Field-mapping matrix

The initial field-level inspection is recorded in [LEGACY_INVOICE_FIELD_MAPPING_MATRIX.md](LEGACY_INVOICE_FIELD_MAPPING_MATRIX.md). It identifies structured mappings, source-evidence-only fields, current numeric behavior, and validation gaps. Owner decisions remain open for product measurement rules, date/time parsing, blank text values, and structured query requirements.

## 7. Field-mapping audit still required

This inspection confirms the current mapper covers core invoice and product fields, but it is not yet a complete source-to-destination mapping specification. Before schema implementation or importer changes, produce a field-by-field matrix covering:

- every key accepted by the legacy invoice parser/preflight;
- every legacy product field;
- nullable, missing, unknown, and malformed values;
- recognized and unrecognized invoice actions;
- exact numeric precision and rounding/conversion policy;
- timestamps/date parsing and timezone assumptions;
- party identity and role validation;
- destination invoice and line columns;
- values retained only in the immutable raw snapshot;
- fields intentionally not migrated and the reason/approval required.

No financial ledger event, payment, allocation, refund, reversal, suspense entry, or accounting posting may be synthesized from invoice paid/rest aggregates.

## 8. Approved D4 decisions applied to the audit

The owner approved:
1. Single-worker initial execution.
2. New linked run after terminal abort.
3. Authenticated actor identity where available, with local trust limitations documented.
4. Independently exported and verified snapshot retained through the recovery period.
5. Explicit authorized exclusions with reason and audit event.
6. Forward-recovery/replay designed and tested before cutover.
7. Separate append-only attempt history and operator-action events.

These decisions approve the design direction only. They do not authorize schema or implementation changes.

## 9. Recommended next step

Complete the field-by-field legacy invoice/product mapping matrix and inspect the exact current schema migration/trigger behavior for the proposed execution constraints. Then prepare a separate D4 schema proposal containing:
- exact table and column definitions;
- uniqueness/idempotency constraints;
- foreign-key and append-only trigger strategy;
- transaction and claim-token mechanics;
- migration from current schema version without losing existing rows;
- rollback plan for the schema change;
- focused migration and failure-injection test plan.

Submit that schema proposal for explicit approval before changing `app_database.dart` or generated Drift files.

---

**Audit complete — no code or schema changes authorized.**

## 10. Owner decision — blank required text fields

On 2026-11-26, the owner approved holding any occurrence for human review when its legacy invoice ID, invoice serial, customer name, or any product name is empty or whitespace-only.

The preflight/import contract must emit stable field-specific findings and preserve the exact source value in the immutable snapshot. It must not invent replacements, silently normalize a substitute value, discard the field, or import the occurrence as ready. Any later correction must be explicit, authorized, attributable, and auditable, while retaining the original source evidence.

This resolves the blank-text policy question identified in the field-mapping audit. It does not authorize code or schema changes.


## 17. Owner-approved field validation rule — negative product values

On 2026-11-26, the owner approved holding an entire invoice occurrence for human review if any product line has a negative `weight`, `packageWeight`, `numberPackage`, or `price`.

Preflight must produce a stable, field-specific finding that identifies the product line and offending field. The importer must not clamp to zero, take an absolute value, omit a line, or otherwise auto-correct the value. The exact original value remains available in the immutable source snapshot. Any later correction must be explicit, authorized, attributable, and auditable without modifying source evidence.

The rule applies even where the current Drift schema already rejects the value (notably negative package count); validation must classify the occurrence as held before attempting insertion. Non-negative upper bounds and precision rules remain unresolved. This is a design decision only; no implementation is authorized.


## 18. Owner-approved field validation rule — party existence and role

On 2026-11-26, the owner approved holding an invoice occurrence for human review whenever the referenced party is missing, lacks the required role, has a role inconsistent with the invoice action/effective review decision, or no longer matches the current effective party-review decision at import time.

The migration must not create parties, add missing roles, change roles, or infer replacement parties. A held occurrence may be released only through an explicit, authorized, attributable, immutable review decision, followed by revalidation immediately before import. The exact source snapshot remains unchanged.

This rule also means the current import behavior that automatically adds party roles is prohibited for the D4 migration path. This is a design decision only; no party, schema, or importer implementation is authorized.


## 19. Owner-approved field validation rule — date and time

On 2026-11-26, the owner approved the following D4 policy for legacy `formattedDate` and `formattedTime` values:

- Preserve the exact original strings in the immutable source snapshot.
- Hold an invoice occurrence if either value has an invalid or unrecognized format.
- Do not guess date order, locale, timezone, or automatically convert ambiguous date/time values.
- Populate Drift `issued_at` only after the supported source formats and timezone semantics have been explicitly established and covered by tests.

The actual source formats and timezone semantics remain to be established from representative source values. This policy is a design decision only; it does not authorize implementation.

## 20. Owner-approved field validation rule — invoice action

On 2026-11-26, the owner approved this D4 policy for historical `invoiceAction` values. The recognized values are `شراء` (purchase), `بيع` (sale), and `تخزين` (storage). A null, empty, or unrecognized value must hold the entire invoice occurrence for human review and produce a stable validation finding. Preserve the exact original value in the immutable source snapshot. Never infer an action from the customer, products, or amounts, and never assign a default action.

The current application UI requires an action selection for new invoices. This defensive migration validation protects against older persisted records, alternate write paths, malformed data, and corruption; it does not imply that the current UI permits actionless invoice creation. This is policy documentation only and does not authorize implementation.

## 21. Owner-approved field mapping decision — original customer display name

On 2026-11-26, the owner approved the following handling for legacy `customerName`:

- `party_id` and `party_role` remain the authoritative invoice-party relationship.
- Preserve the exact original customer display name in the immutable source snapshot.
- Retain the original name in normalized `source_json` as supporting evidence.
- Do not add a dedicated invoice column solely for this migration. Reconsider only if a separate business requirement establishes a need for historical-name search or reporting.

This is a mapping policy only. It does not authorize schema or importer implementation.

## 22. Owner-approved date/time destination mapping decision

On 2026-11-26, the owner approved the following destination strategy: retain the exact original `formattedDate` and `formattedTime` strings in the immutable source snapshot; after source formats and timezone semantics are established and tested, map the combined value to the existing `issued_at` field. Do not add separate structured date or time columns solely for this migration; reconsider them only for a distinct business requirement.

Invalid or unrecognized values remain held under the previously approved policy. This is a mapping decision only and does not authorize implementation.