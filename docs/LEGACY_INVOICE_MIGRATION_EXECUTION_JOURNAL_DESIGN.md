# Arqamy — Legacy Invoice Migration Execution Journal and Import Contract

**Repository:** Ahmednahrawy/arqamy  
**Branch:** main  
**Design status:** Proposal for owner review  
**Implementation status:** Not authorized  
**Scope:** Durable execution, occurrence-key idempotency, retry/recovery, and import-state accounting for migration from SharedPreferences saved_invoices to Drift.

---

## 1. Purpose and boundary

The D3.2 party-review journal records human decisions about party identity. It does not record invoice import execution. D4 defines a separate execution journal so an import can be resumed, audited, reconciled, and recovered without relying on in-memory progress or legacy invoice IDs.

This proposal does not authorize schema changes, generated-code changes, importer changes, source mutation, repository cutover, or production workflow changes. Those require separate approval after this design is reviewed.

The current operational invoice source remains SharedPreferences. No import or cutover is authorized by this document.

## 2. Recommended design decisions

1. One execution run is bound to one immutable source snapshot and one immutable processing contract: snapshot SHA-256, byte length, snapshot format, migration version, occurrence-identity version, preflight version, and mapping-contract version.
2. The source occurrence is the unit of accounting and idempotency. A legacy invoice ID or serial is diagnostic/business data, never the migration identity.
3. The execution journal is separate from the party-review journal. Party decisions remain in the D3.2 tables; execution progress, attempts, quarantine, and reconciliation belong to D4.
4. One eligible occurrence imports as one atomic business unit. Invoice row, all invoice-line rows, and occurrence-to-destination mapping commit together.
5. Attempt history is append-only. Current occurrence state is a projection of durable events/attempts, not a mutable log that loses prior failures.
6. A process crash must not leave a partially imported invoice. A durable claim may expire; the business transaction either commits all import records and the imported mapping/state or commits none.
7. A retry of the same snapshot and migration contract cannot create a second invoice for the same occurrence. Conflicting pre-existing data is surfaced as a conflict, never overwritten.
8. Held, malformed, and explicitly excluded occurrences remain accounted for and traceable. Their raw evidence remains in the immutable snapshot.
9. No financial ledger history is inferred. Invoice-level paid and rest values remain historical document aggregates; they do not create cash events, payments, allocations, refunds, or accounting entries.
10. Cutover remains a separate, explicitly accepted operation.

## 3. Identity model and idempotency contract

### 3.1 Immutable run identity

A run must record at least:
- run_id: generated unique run identifier;
- snapshot_sha256 and snapshot_byte_length;
- snapshot_format_version;
- migration_version;
- occurrence_identity_version;
- preflight_version;
- mapping_contract_version;
- creation time and initiating actor;
- party-review run identifier, if the review set is associated with one;
- run status and execution, reconciliation, and acceptance timestamps.

The run is immutable with respect to its source and processing versions. A changed snapshot or changed interpretation contract is a new migration input and must not silently reuse an existing run. A retry of the same run resumes it only if all compatibility fields match.

A deliberate new attempt over the same snapshot may be represented as a new run linked to the prior run, but it must not bypass prior imported mappings or duplicate business data. The implementation proposal must choose the precise retry-lineage mechanism before schema work.

### 3.2 Source occurrence identity

Use the already implemented identity format:

v1:{snapshotSha256}:{sourceIndex}:{recordSha256}

The inputs are the immutable snapshot digest, original array index, and digest of the exact raw record fragment. Store the exact key unchanged; do not re-derive it from a decoded invoice object.

The complete idempotency scope is the tuple (migration_version, source_occurrence_key). The run also binds the mapping, preflight, and identity versions. A run cannot reuse a key under a different contract merely because the legacy invoice ID matches.

Recommended stable import idempotency key:

legacy-invoice-import:{migration_version}:{source_occurrence_key}

If the repository uses a hashed or length-limited key, hash the canonical UTF-8 representation of that full tuple and retain the original components in separate columns for audit. Do not include a retry-attempt number in the business idempotency key: retries must converge on the same destination mapping.

### 3.3 Destination mapping

Each successfully imported occurrence must have exactly one durable mapping to its destination invoice. The mapping should record:
- run ID;
- migration version;
- source occurrence key;
- source snapshot digest;
- destination invoice primary key;
- import completion timestamp;
- mapping-contract version;
- destination content fingerprint or equivalent verification value.

The database must enforce uniqueness for the migration-version/source-occurrence identity and uniqueness of the destination mapping where appropriate. Check exact constraints against the current schema before implementation.

Do not add a unique constraint to the legacy invoice ID or serial merely to make migration easier. Multiple source occurrences may legitimately share either value.

## 4. Execution journal model

### 4.1 Run record

One record represents one immutable migration execution scope. It holds source and contract versions, lifecycle status, counts, actor provenance, and references to the snapshot manifest/export package and D3.2 review run.

Run-level status is derived from occurrence outcomes and reconciliation evidence. It must not become accepted merely because all eligible rows were written.

### 4.2 Occurrence record

One record exists for every source array occurrence, including malformed and duplicate-ID records. It stores:
- run ID and exact source occurrence key;
- source index and raw-record SHA-256;
- legacy invoice ID and serial as nullable diagnostic fields;
- preflight classification and versioned findings;
- party-review outcome reference/effective status;
- current execution status;
- destination invoice ID when imported;
- latest attempt number and last error classification;
- explicit hold/exclusion reason and actor when applicable;
- created/updated timestamps.

The raw record fragment remains recoverable from the immutable snapshot using the source index and occurrence identity. A quarantine view/index must make it easy to retrieve the exact original source fragment. Do not store only a parsed/re-serialized JSON object as evidence.

### 4.3 Attempt history

Each execution attempt is a separate append-only record. It should include:
- attempt ID and sequence;
- run and occurrence identity;
- idempotency key;
- start time, completion time, and worker/device identifier;
- claim/lease expiry where a claim is used;
- outcome: imported, already-imported, retryable-failure, permanent-failure, conflict, or abandoned;
- stable error code/category and diagnostic details;
- destination invoice ID and content fingerprint when successful.

Do not store secrets or unnecessary personal data in diagnostics. Error messages should be bounded and sanitized.

### 4.4 Event/audit history

Record explicit operator actions and material state changes: hold, release from hold, exclude, retry, conflict resolution, reconciliation, and acceptance/rejection. Keep actor, timestamp, reason, and relevant before/after state. Correct an earlier action with a new event; do not erase history.

The execution journal must not duplicate the full D3.2 party decision history. It should reference the effective party decision and record the party/role actually validated at import time.

## 5. Occurrence state machine

Recommended occurrence states:

| State | Meaning | Import eligibility |
|---|---|---|
| captured | Occurrence identity and raw evidence recorded | No |
| preflighted | Record-level validation completed | Depends on classification |
| ready | Valid under approved mapping contract and required party decision | Yes |
| held | Requires human review or has a blocking finding | No |
| excluded | Explicitly excluded by an authorized human decision, with reason | No |
| claimed | A worker has a time-bounded execution claim | In progress |
| imported | Invoice, lines, and mapping committed atomically | Already complete |
| retryable_failure | Attempt failed for a transient/recoverable reason | Yes, after retry policy |
| permanent_failure | Data or invariant failure requiring correction/new approved contract | No automatic retry |
| conflict | Existing destination data/mapping contradicts expected identity or content | No automatic retry |
| reconciled | Imported occurrence passed required reconciliation checks | Already complete |
| reconciliation_failed | Reconciliation found a mismatch | No cutover |

State changes must be validated against an explicit transition table:

- captured → preflighted only after snapshot integrity and preflight complete.
- preflighted → ready only when all blocking validation and party-role requirements pass.
- preflighted → held for malformed, duplicate, unresolved, unsupported, or financially inconsistent records.
- held → ready only after explicit, auditable resolution and revalidation.
- ready → claimed through an atomic claim operation.
- claimed → imported only in the same transaction that commits invoice, all lines, mapping, and successful attempt outcome.
- claimed → retryable_failure, permanent_failure, or conflict only with a durable attempt result.
- An expired claim may be reclaimed after recording the prior attempt as abandoned; it must not imply that business data was imported.
- imported → reconciled or reconciliation_failed only through a recorded reconciliation result.
- excluded requires explicit authorization and a reason; it is not a way to hide malformed or inconvenient records.
- Reopening a permanent failure or conflict requires an explicit corrective action and audit event. Do not silently reset it to ready.

Run states should be derived or guarded by occurrence totals, reconciliation, and acceptance evidence. Suggested run states: prepared, executing, execution_blocked, execution_complete, reconciling, reconciliation_failed, reconciled, accepted, aborted. A run can be accepted only after the acceptance gate in section 10.

## 6. Import transaction and concurrency contract

### 6.1 Claim phase

Claiming an occurrence is a short database transaction:

1. Verify the run is compatible and not accepted/aborted.
2. Verify the occurrence is ready or eligible for retry.
3. Verify the current effective party decision and required party role.
4. Check for an existing occurrence mapping.
5. If a valid mapping already exists and destination content matches, return already-imported; do not insert another invoice.
6. If the mapping exists but the invoice is missing, or the invoice exists with a contradictory mapping/content, set or report conflict; do not repair by guessing.
7. Acquire a claim using a lease/claim token and monotonically increasing attempt number. Concurrent claim attempts must allow only one winner.

The claim transaction commits before the invoice transaction so a crashed worker can be detected. A lease is a recovery aid, not proof that an import committed.

### 6.2 Business import phase

The importer then opens one Drift transaction and revalidates the claim token, run compatibility, source identity, effective party decision, party role, and idempotency mapping.

Within that single transaction:
1. Insert the destination invoice using the approved mapper and generated destination identity.
2. Insert every validated invoice line in original source order.
3. Insert the unique occurrence-to-destination mapping.
4. Record the successful attempt outcome and update the occurrence to imported.
5. Commit.

If any insert, constraint, validation, or state update fails, the entire transaction rolls back. No invoice without all its lines, no lines without their invoice, and no imported mapping without the corresponding invoice may remain.

Do not call external services, perform file I/O, or invoke non-transactional side effects from inside this transaction. Snapshot and export verification happen before import. Any database-generated IDs needed for the mapping must be created/obtained within the transaction.

### 6.3 Crash and retry behavior

- Crash before claim commit: no claim exists; another worker may claim.
- Crash after claim commit but before business transaction: lease eventually expires; attempt is marked abandoned and occurrence can be reclaimed.
- Crash during business transaction: SQLite rolls back the transaction; no invoice/lines/mapping/imported state should be visible.
- Crash after business transaction commit but before caller receives success: retry checks the unique mapping and returns already-imported after verifying destination integrity.
- Retry with same key and same source/contract: idempotent; no duplicate business rows.
- Same key with different source digest, occurrence index, record digest, or contract: reject as an identity/contract conflict.
- Existing invoice with no migration mapping is not automatically adopted, overwritten, or deleted. It requires an explicit conflict-resolution procedure.

### 6.4 Concurrency and locking

The initial migration should run as a single controlled local worker unless a demonstrated requirement justifies parallelism. Even then, the database must enforce uniqueness and serialize conflicting claims.

If multiple workers are later allowed:
- claims must be atomic and lease-based;
- a worker must verify its claim token inside the import transaction;
- stale workers must be unable to commit after a newer claim supersedes them;
- unique constraints remain the final protection against duplicate mappings;
- SQLite busy/locked errors are retryable only under a bounded policy with backoff;
- a retry must re-read mapping and destination state before attempting inserts.

No UI-level lock is sufficient.

## 7. Duplicate IDs, malformed records, and quarantine

### Duplicate legacy IDs

All occurrences sharing a legacy invoice ID remain separate source occurrences. The importer must not choose one, overwrite one, or deduplicate them automatically. They remain held until review determines whether they are separate documents, duplicate copies, or a conflict. Any approved treatment must retain every original occurrence and record the human decision.

### Malformed and unsupported records

Malformed JSON fragments, unknown invoice actions, unsupported numeric precision, invalid totals, inconsistent line data, missing party identity, and unresolved roles remain held with stable finding codes. Do not attempt a lossy conversion to make them importable.

### Quarantine requirements

Quarantine is an index/status over immutable source evidence, not a destructive move. It must provide:
- source snapshot digest and export-package reference;
- source index and exact occurrence key;
- exact raw fragment retrieval or whole-snapshot retrieval;
- preflight findings and human resolution history;
- current hold reason and status;
- any later corrective decision.

A held occurrence remains counted in run totals. A malformed record must never disappear because it cannot be decoded into an invoice model.

## 8. Mapping and business-data preservation

The importer must use the approved legacy-to-Drift mapper and a versioned mapping contract. Before implementation, compare every source field with the current Drift invoice and line schema.

Preserve, where present and valid:
- legacy invoice ID and serial as historical identifiers;
- original action text and recognized document type;
- customer/supplier display name and approved party link/role;
- original invoice date and relevant timestamps;
- totals, discounts, taxes, and line-level values under the approved precision policy;
- product/line order and original descriptive values;
- invoice-level paid and rest as historical aggregates;
- unknown legacy fields through retained raw source evidence.

Do not invent defaults for missing financial values. Any unavoidable mapping loss must be classified and approved before import; otherwise hold the occurrence.

Financial boundary: invoice-level paid and rest aggregates do not prove physical cash movement. This migration must not synthesize cash events, payment records, allocations, refunds, reversals, suspense entries, or accounting postings.

## 9. Snapshot export, restore, and execution recovery

The current snapshot is app-private. Before a production migration run, create an independently recoverable export package containing at minimum:
- exact raw snapshot bytes/string;
- manifest with snapshot format, key-existence flag, byte length, SHA-256, capture time, and app/version context;
- preflight report and its version;
- occurrence identity index;
- party-review run reference and exported decision evidence;
- execution journal export/checkpoint;
- package format version and integrity metadata.

Export verification must read the exported package back from its destination and independently recompute the raw snapshot digest and byte length. A successful copy operation alone is not sufficient.

Restore procedure must:
1. validate package structure and supported versions;
2. verify all file lengths and digests;
3. verify snapshot digest against the run;
4. verify occurrence keys can be regenerated and match the journal;
5. verify journal relationships and decision chains;
6. restore to a staging location/database, never overwrite the only source copy;
7. run SQLite foreign-key and integrity checks where a database is restored;
8. produce a restore report and require explicit operator confirmation before resuming.

A missing or corrupt snapshot/export package blocks further import. Do not reconstruct source data from typed invoices, journal columns, or a partial export.

## 10. Reconciliation and acceptance gate

Reconciliation is occurrence-based, not merely a comparison of total invoice counts.

The report must account for every source occurrence exactly once as one of:
- imported and reconciled;
- held;
- explicitly excluded;
- failed/conflicted and unresolved.

For imported occurrences, verify:
- exactly one occurrence mapping;
- exactly one destination invoice;
- expected invoice-line count and order;
- all mapped values against the approved mapping contract;
- valid party ID and role;
- preserved historical aggregate fields;
- destination fingerprint matches the recorded import fingerprint;
- no orphan lines or mappings;
- foreign-key check and SQLite integrity check pass;
- database closes and reopens with consistent results.

For held/excluded occurrences, verify:
- original raw fragment remains recoverable;
- stable findings and decision provenance remain available;
- exclusion is explicit and authorized.

Also verify:
- source snapshot digest/byte length unchanged;
- total occurrence accounting equals preflight occurrence count;
- no duplicate destination mapping;
- retrying the same run produces no new invoice or line;
- no cash/ledger artifacts were synthesized.

A run is not accepted while any occurrence is unaccounted for, unresolved conflict exists, reconciliation has failed, the independent snapshot cannot be restored, or required evidence is missing. The owner must review the report and explicitly accept the result. Acceptance should record actor, timestamp, report digest, and accepted run/snapshot/contract identifiers.

## 11. Cutover and rollback boundary

Import completion and cutover are separate operations. Before cutover:
- SharedPreferences remains authoritative;
- imported Drift rows are migration output only;
- no application reads or writes are redirected;
- no source data is deleted.

Cutover requires a separately approved implementation and release plan, a reconciled/accepted run, verified export/restore, tested Drift repository coverage for every invoice lifecycle operation, and a defined maintenance/write-freeze strategy.

Rollback before cutover is straightforward: stop migration and leave the legacy source untouched. Imported staging data may be retained for diagnosis; it must not be blindly deleted if references or later work depend on it.

Rollback after cutover is not a database-file swap unless all post-cutover writes are accounted for. The plan must define:
- how writes made in Drift after cutover are exported/replayed or otherwise preserved;
- how a write freeze is enforced during recovery;
- how IDs and references remain stable;
- how conflicts between post-cutover writes and legacy state are resolved;
- how the app is returned to the previous repository without losing new invoices, edits, deletes, or payment relationships.

Do not implement uncontrolled dual-write as a rollback shortcut. Prefer a tested forward-recovery/replay strategy or an explicitly designed, bounded rollback window with a durable change log. The exact strategy must be designed and approved before cutover code.

## 12. Failure classification and operator actions

Use stable machine-readable categories, at minimum:
- source-integrity failure;
- unsupported snapshot/preflight version;
- malformed occurrence;
- duplicate legacy identity;
- unresolved/role-invalid party;
- mapping validation failure;
- transient database busy/locked;
- constraint/integrity failure;
- existing destination conflict;
- snapshot/export unavailable;
- reconciliation mismatch;
- actor/authorization failure.

Each category must define whether it is retryable, requires human correction, blocks the run, or requires a new migration contract. Never infer retryability from an exception message string alone.

Operator actions must be explicit and audited: retry, keep held, release after correction, exclude with reason, resolve conflict under an approved rule, reconcile, accept, or abort. The UI may not offer a generic skip-errors-and-continue action that loses occurrence accounting.

## 13. Test and verification requirements

Before production use, tests must cover:
- fresh database and schema upgrade fixtures;
- run/version/snapshot compatibility rejection;
- uniqueness of occurrence mapping;
- same-occurrence retry after success;
- same idempotency key with conflicting fingerprint;
- duplicate legacy IDs and byte-identical records at different indexes;
- malformed raw records retained in quarantine;
- party decision missing, stale, wrong-role, or superseded;
- invoice insert failure, line insert failure, mapping insert failure, and journal update failure, each proving full rollback;
- crash/expired-lease recovery;
- concurrent claim attempts and stale claim-token rejection;
- pre-existing destination invoice/mapping conflict;
- export copy corruption and restore verification failure;
- reconciliation mismatch and acceptance rejection;
- no synthesized cash events or allocations;
- repeat migration with zero additional business rows.

Run formatting, analysis, full tests, relevant integration tests, and database integrity checks. The test suite must prove transaction atomicity rather than only test happy-path repository methods.

## 14. Implementation sequence after design approval

Implementation should remain separately gated and be split into reviewable steps:

1. Repository audit and contract alignment: inspect current Drift invoice/line schema, importer, executor, snapshot service, party journal, and test fixtures; produce a field-by-field mapping matrix and confirm no existing equivalent execution tables.
2. Schema proposal: finalize execution-run, occurrence, attempt, event, and occurrence-mapping persistence with indexes, foreign keys, uniqueness, and immutable-history rules. Submit exact migration plan and rollback before approval.
3. Schema and migration tests: add the schema in a feature branch, preserve all existing rows, test upgrade from actual schema-v7 fixtures and fresh DB.
4. Journal repository: implement run/occurrence/attempt/event persistence and transition validation without importing business invoices.
5. Occurrence-key planner: adapt the planner to immutable source occurrences and versioned mapping contracts; preserve held records.
6. Atomic importer: implement claim, transactional invoice/lines/mapping/state commit, failure injection, and idempotent retry.
7. Export/restore: implement independently verifiable snapshot package and staging restore.
8. Reconciliation: produce deterministic reports and acceptance evidence.
9. Operational workflow and cutover: separate approval, repository integration, and release steps.

Do not combine schema, importer, app cutover, and legacy deletion in one change.

## 15. Open decisions for owner review

The following require explicit confirmation before implementation:
1. Whether the first production execution is strictly single-worker (recommended) or needs parallel workers.
2. Whether a retry after a terminally aborted run resumes the same run or creates a linked new run.
3. Which actor identity is authoritative for local migration review and acceptance, and how its trust limitations are communicated.
4. The retention period and user-selected destination for the independent export package.
5. Whether explicit exclusion is allowed for any occurrence class, and which roles may authorize it.
6. The precise post-cutover recovery approach and acceptable rollback window.
7. Whether an execution-event table is separate from attempt history or implemented as a unified append-only audit stream.

No decision here authorizes code or schema changes.

---

**End of D4 proposal — implementation not authorized.**
