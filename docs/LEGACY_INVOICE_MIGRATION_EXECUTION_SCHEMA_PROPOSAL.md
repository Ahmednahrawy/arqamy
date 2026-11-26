# Arqamy — D4 Execution Journal Schema Proposal

**Repository:** Ahmednahrawy/arqamy  
**Baseline:** Drift schema version 7  
**Design status:** Approved for schema v8 implementation  
**Implementation status:** Schema-only implementation authorized; importer and production migration excluded  
**Depends on:** Owner-approved D4 execution contract; repository audit; field-mapping matrix  
**Scope:** Additive Drift persistence for invoice-migration execution, attempts, operator events, and source-occurrence mappings.

---

## 1. Proposal summary

Add a distinct D4 persistence layer. Do not repurpose the D3.2 party-review tables and do not rebuild the existing invoice/line tables unless a later field-mapping decision proves a specific column is necessary.

Proposed new tables:

1. `legacy_invoice_import_runs` — immutable source/contract identity plus current run-status projection.
2. `legacy_invoice_import_occurrences` — one row per source occurrence in a run; mutable current-state/claim projection.
3. `legacy_invoice_import_attempts` — append-only completed/abandoned attempt history.
4. `legacy_invoice_import_events` — append-only operator-action and acceptance/reconciliation audit.
5. `legacy_invoice_occurrence_mappings` — globally unique mapping from one immutable source occurrence to one destination invoice.

The initial implementation target is schema version 8, additive from current version 7. No existing invoice, line, party-review, or financial-ledger table should be dropped or rebuilt for this stage.

## 2. Critical identity rule

The repository already has a nullable unique `invoices.legacy_record_key`. For D4, store the stable `source_occurrence_key` there, not `saved_invoices/{invoice.id}` and not a retry-specific key.

The source occurrence key already contains:
- identity version;
- immutable snapshot SHA-256;
- source array index;
- exact raw-record-fragment SHA-256.

Therefore `legacy_invoice_occurrence_mappings.source_occurrence_key` must be globally unique, independent of migration version and mapping-contract version. A changed contract must not allow the same source occurrence to create a second invoice. If a mapping exists under a different contract, report a conflict and require an explicit audited correction procedure.

Attempt idempotency remains scoped to the complete processing contract:
`(migration_version, mapping_contract_version, occurrence_identity_version, source_occurrence_key)`.

This separates attempt identity from the stronger global source-to-destination uniqueness guarantee.

## 3. Proposed table contracts

The following are logical contracts, not final Drift declarations. Exact SQL types, generated names, and constraints must be finalized against the current schema and reviewed before implementation.

### 3.1 `legacy_invoice_import_runs`

One row identifies an execution run over one immutable snapshot and one processing contract.

Proposed columns:
- `run_id TEXT PRIMARY KEY`;
- `parent_run_id TEXT NULL` — linked prior run after terminal abort;
- `snapshot_sha256 TEXT NOT NULL`;
- `snapshot_byte_length INTEGER NOT NULL`;
- `snapshot_source_exists INTEGER NOT NULL`;
- `snapshot_format_version INTEGER NOT NULL`;
- `migration_version INTEGER NOT NULL`;
- `occurrence_identity_version INTEGER NOT NULL`;
- `preflight_version INTEGER NOT NULL`;
- `mapping_contract_version INTEGER NOT NULL`;
- `party_review_run_id TEXT NULL` — references the D3.2 review run where applicable;
- `export_manifest_sha256 TEXT NULL` — populated only after independently verified export;
- `created_at INTEGER NOT NULL`;
- `created_by_actor_id TEXT NULL`;
- `created_by_actor_source TEXT NOT NULL` — exactly one of `authenticated`, `local_operator`, or `system`;
- `status TEXT NOT NULL` — current run-state projection;
- `updated_at INTEGER NOT NULL`.

Constraints:
- `snapshot_sha256` and non-null `export_manifest_sha256` must be exactly 64 hexadecimal characters;
- `snapshot_byte_length >= 0`; `snapshot_source_exists` must be exactly 0 or 1;
- format/migration/identity/preflight/mapping versions must be positive;
- `run_id` and every required text identifier must be non-empty after trimming;
- `created_by_actor_source` must be one of `authenticated`, `local_operator`, or `system`;
- allowed status values only;
- parent run must exist and cannot equal this run;
- party-review run, if present, references `legacy_migration_runs(run_id)`;
- immutable source/contract/creation/actor identity fields are protected by a database trigger; only the designated mutable run projection fields `status` and `updated_at` may change;
- status changes occur only through repository transition methods and must be accompanied by a durable event where the action is operator initiated.

Actor metadata must not claim stronger identity than the app can prove. If no authenticated identity exists, record a local-operator actor source and document its unverified nature; do not fabricate an authenticated user ID.

### 3.2 `legacy_invoice_import_occurrences`

One row per source array occurrence per execution run, including malformed, duplicate-ID, held, and excluded records.

Proposed columns:
- `run_id TEXT NOT NULL`;
- `source_occurrence_key TEXT NOT NULL`;
- `source_index INTEGER NOT NULL`;
- `record_sha256 TEXT NOT NULL`;
- `legacy_invoice_id TEXT NULL`;
- `legacy_invoice_serial TEXT NULL`;
- `preflight_classification TEXT NOT NULL`;
- `preflight_findings_json TEXT NOT NULL`;
- `party_review_run_id TEXT NULL`;
- `party_review_decision_id TEXT NULL`;
- `execution_status TEXT NOT NULL`;
- `destination_invoice_id TEXT NULL`;
- `current_attempt_number INTEGER NOT NULL DEFAULT 0`;
- `active_claim_token_hash TEXT NULL`;
- `active_claim_expires_at INTEGER NULL`;
- `active_attempt_started_at INTEGER NULL`;
- `last_error_code TEXT NULL`;
- `hold_or_exclusion_reason TEXT NULL`;
- `updated_at INTEGER NOT NULL`.

Keys and constraints:
- required identifiers, `source_occurrence_key`, and required text fields must be non-empty after trimming;
- `record_sha256` must be exactly 64 hexadecimal characters;
- non-null `active_claim_token_hash` must be non-empty after trimming;
- primary key `(run_id, source_occurrence_key)`;
- unique `(run_id, source_index)`;
- foreign key `run_id` to the D4 run;
- foreign key `(party_review_run_id, source_occurrence_key)` to the D3.2 occurrence when party review is attached;
- where a decision ID is supplied, use the D3.2 composite uniqueness key to ensure that decision belongs to the same review run and occurrence;
- valid JSON findings;
- non-negative source index and attempt number;
- valid status values;
- immutable identity/preflight columns protected from update;
- deletion prohibited; state/claim projection columns may change only through validated repository transitions.

The exact raw source fragment should remain retrievable from the verified immutable snapshot using the stored source index and occurrence key. Do not rely on `source_json` in the invoice row as raw evidence.

### 3.3 `legacy_invoice_import_attempts`

One append-only row per completed or abandoned claim attempt.

Proposed columns:
- `attempt_id TEXT PRIMARY KEY`;
- `run_id TEXT NOT NULL`;
- `source_occurrence_key TEXT NOT NULL`;
- `attempt_number INTEGER NOT NULL`;
- `attempt_idempotency_key TEXT NOT NULL`;
- `claim_token_hash TEXT NOT NULL`;
- `worker_id TEXT NOT NULL`;
- `started_at INTEGER NOT NULL`;
- `completed_at INTEGER NOT NULL`;
- `outcome TEXT NOT NULL` — imported, already_imported, retryable_failure, permanent_failure, conflict, or abandoned;
- `error_code TEXT NULL`;
- `diagnostic TEXT NULL`;
- `destination_invoice_id TEXT NULL`;
- `destination_fingerprint TEXT NULL`.

Constraints:
- `attempt_id`, `run_id`, `source_occurrence_key`, `attempt_idempotency_key`, `claim_token_hash`, and `worker_id` must be non-empty after trimming;
- `claim_token_hash` must be non-null;
- `completed_at >= started_at`;
- unique `(run_id, source_occurrence_key, attempt_number)`;
- unique `attempt_idempotency_key`;
- foreign key to the matching occurrence;
- foreign key to destination invoice when populated;
- valid outcome and positive attempt number;
- append-only update/delete triggers.

Claim lifecycle: the occurrence row holds the active claim token hash, lease expiry, and start time. On success/failure, the importer inserts the immutable attempt result and updates the occurrence projection in the same transaction as the business outcome. If a worker crashes, lease recovery inserts an `abandoned` attempt from the persisted claim metadata before allowing a new claim. This avoids updating an append-only attempt row.

### 3.4 `legacy_invoice_import_events`

One append-only row per operator action or explicit run-level decision.

Proposed columns:
- `event_id TEXT PRIMARY KEY`;
- `run_id TEXT NOT NULL`;
- `source_occurrence_key TEXT NULL` — null for run-wide actions;
- `event_type TEXT NOT NULL` — hold, release_hold, exclude, retry_requested, conflict_resolution, reconciliation_started, reconciliation_passed, reconciliation_failed, accepted, rejected, aborted;
- `actor_id TEXT NULL`;
- `actor_source TEXT NOT NULL`;
- `occurred_at INTEGER NOT NULL`;
- `reason TEXT NULL`;
- `details_json TEXT NOT NULL`;
- `request_idempotency_key TEXT NULL`.

Constraints:
- required identifiers and `actor_source` must be non-empty after trimming; `actor_source` is constrained to `authenticated`, `local_operator`, or `system`;
- foreign key to run;
- occurrence foreign key when the key is present;
- valid JSON details;
- append-only update/delete triggers;
- request idempotency key unique when non-null.

Automated attempt outcomes belong in the attempts table. This event table is for explicit operator actions, decisions, reconciliation outcomes, and acceptance evidence; it must not duplicate the D3.2 party-decision chain.

### 3.5 `legacy_invoice_occurrence_mappings`

One durable mapping globally for one source occurrence.

Proposed columns:
- `source_occurrence_key TEXT PRIMARY KEY`;
- `source_snapshot_sha256 TEXT NOT NULL`;
- `occurrence_identity_version INTEGER NOT NULL`;
- `source_index INTEGER NOT NULL`;
- `record_sha256 TEXT NOT NULL`;
- `migration_version INTEGER NOT NULL`;
- `mapping_contract_version INTEGER NOT NULL`;
- `import_run_id TEXT NOT NULL`;
- `destination_invoice_id TEXT NOT NULL UNIQUE`;
- `destination_fingerprint TEXT NOT NULL`;
- `imported_at INTEGER NOT NULL`.

Constraints:
- global uniqueness of source occurrence key;
- unique destination invoice ID;
- foreign key to the successful import run and its occurrence;
- foreign key to `invoices(invoice_id)`;
- valid digest/version/index checks and non-empty required identifiers;
- an insert-validation trigger must verify that the referenced occurrence exists in the same `import_run_id` and that its source key, snapshot digest, identity version, source index, record digest, migration version, and mapping-contract version exactly match the mapping row;
- the trigger must verify that the occurrence is in `imported` state, that a successful `imported` attempt exists for the same run/source occurrence/destination invoice, and that the destination invoice's `legacy_record_key` exactly equals the mapping's `source_occurrence_key`;
- append-only update/delete triggers.

The source occurrence key is the global duplicate-prevention boundary. A later run may discover the existing mapping and record an `already_imported` attempt only after verifying the destination invoice and lines against the mapping fingerprint. It must not create a second invoice.

## 4. Existing schema integration

### Reuse

- `invoices` and `invoice_lines` remain the business destination tables.
- `invoices.legacy_record_key` stores the stable source occurrence key for D4 imports.
- `invoices.legacy_invoice_id`, `legacy_action`, `source_json`, and legacy amount text columns remain useful historical metadata.
- `legacy_migration_runs`, `legacy_migration_occurrences`, and `legacy_party_review_decisions` remain exclusively the D3.2 party-review journal.

### Do not reuse or change in this schema stage

- Do not repurpose D3.2 tables for import attempts or statuses.
- Do not change the meaning of legacy invoice ID or serial.
- Do not add automatic party creation or party-role assignment.
- Do not create payment/cash/financial transaction rows from paid/rest values.
- Do not redirect application invoice reads/writes to Drift.
- Do not delete or rewrite SharedPreferences source data.

### Existing legacy importer collision handling

The current importer may already have created invoice rows with `legacy_record_key = saved_invoices/{legacyId}`. Those rows have no D4 occurrence mapping. Before inserting a D4 occurrence, query for pre-existing destination rows with the same `legacy_invoice_id` (and inspect any existing legacy key). If a candidate exists without a D4 mapping, classify it as a conflict. Do not silently adopt, overwrite, duplicate, or delete it. A separately approved reconciliation procedure must decide its treatment.

## 5. Indexes and operational queries

Proposed indexes:
- occurrences by `(run_id, execution_status, source_index)`;
- occurrences by `(execution_status, active_claim_expires_at)` for lease recovery;
- attempts by `(run_id, source_occurrence_key, attempt_number)`;
- events by `(run_id, occurred_at)`;
- mappings by `(import_run_id)`;
- mapping destination invoice unique index (or unique constraint).

Avoid indexes on diagnostic free-text fields. Keep lookup keys deterministic and bounded.

## 6. Transaction boundaries

### Run preparation transaction

Insert the immutable run header and all occurrence rows in one transaction after snapshot integrity, preflight, and required party-review data are validated. If insertion fails, no partial run/occurrence set remains.

### Claim transaction

Atomically set occurrence status to claimed, generate a claim token, set lease expiry, and increment attempt number only if the row is eligible and has no active claim. A single-worker policy is the initial operational constraint, but the database claim still protects against accidental concurrent invocation.

### Import transaction

One Drift transaction must:
1. Revalidate run/occurrence identity, processing versions, claim token, and effective party decision/role.
2. Check for an existing global source-occurrence mapping.
3. Check for pre-existing unmapped invoice collisions by legacy invoice ID.
4. Insert invoice and all lines using the source occurrence key as `legacy_record_key`.
5. Insert the successful `imported` attempt record.
6. Update the occurrence projection to `imported` and clear active claim fields.
7. Insert the global occurrence mapping and destination fingerprint. Its insert trigger verifies the completed attempt, imported occurrence projection, exact occurrence metadata, and destination `legacy_record_key`.

Any failure rolls back invoice, lines, mapping, attempt result, and imported state together. The prior durable claim remains available for lease recovery/retry.

### Reconciliation transaction

Persist the deterministic reconciliation report reference/digest and outcome event. Reconciliation must not mutate invoice business data to make mismatches disappear.

## 7. Schema migration plan

Target schema version: **8**, additive from version 7.

Proposed migration:
1. Ensure the five D4 tables and all their indexes/triggers exist for every supported upgrade path from every schema version below 8. A direct `from == 7` branch alone is insufficient.
2. For legacy upgrade branches that call `createAll()`, account for the D4 tables being included in fresh-schema creation so they are not created a second time later in the same migration callback. Use one idempotent migration strategy with explicit version-path coverage; do not silently skip D4 creation for older installed databases.
3. Create the required unique constraints, foreign keys, indexes, run-identity immutability trigger, mapping insert-validation trigger, and append-only triggers exactly once.
3. Verify existing v7 rows remain unchanged in:
   - invoices and invoice_lines;
   - currencies, parties, party_roles, financial_accounts;
   - all payment-ledger tables;
   - D3.2 party-review tables.
4. Run `PRAGMA foreign_key_check`.
5. Run `PRAGMA integrity_check`.
6. Verify table/index/trigger definitions and schema version.
7. Commit schema version 8 only if all migration steps succeed.

Do not rebuild the existing D3.2 tables or recreate their triggers in this migration unless a demonstrated SQLite constraint requires it. The migration must be wrapped so failure leaves the v7 database intact.

Fresh-database creation must create all current v7 and proposed v8 tables/triggers in the correct dependency order.

## 8. Rollback plan

Before shipping schema v8:
- retain a verified copy of the database used for migration tests;
- test v7-to-v8 upgrade from a real v7 fixture with representative party-review history and invoice/ledger rows;
- test injected failure after each table/trigger creation step;
- verify failed migration leaves the v7 schema and all row contents intact.

After schema v8 is shipped, do not downgrade by dropping D4 tables if they contain run history. The safe operational rollback is to stop using D4 execution while preserving its audit records. If a binary downgrade is required, it needs a separately tested compatibility plan; never drop migration evidence automatically.

## 9. Required tests before implementation can be considered complete

- fresh schema creates all five tables and expected indexes/triggers;
- every supported pre-v8 upgrade path, including legacy paths that invoke `createAll()`, finishes with all five D4 tables and triggers exactly once;
- schema v7 → v8 and representative older-version → v8 upgrades preserve all pre-existing rows;
- schema v7 → v8 preserves all existing tables and rows;
- migration failure rolls back atomically;
- immutable run identity fields cannot be changed, while only `status` and `updated_at` remain mutable;
- run snapshot existence, byte-length, digest, optional export-manifest digest, actor-source, and required-identifier checks reject invalid values;
- occurrence identity fields cannot be changed or deleted; non-null claim-token hashes and required identifiers reject blank values;
- attempts reject blank required identifiers/token hashes and completion timestamps earlier than start;
- operator events reject blank required identifiers and unsupported actor-source values;
- attempts, operator events, and mappings reject update/delete;
- same source occurrence cannot map twice across different runs or mapping-contract versions;
- mapping insertion rejects mismatched occurrence snapshot/identity/index/record/version metadata;
- mapping insertion rejects a non-imported occurrence, missing matching successful attempt, mismatched destination invoice, or destination `legacy_record_key` different from the source occurrence key;
- two source occurrences with the same legacy invoice ID remain distinct keys (subject to review/hold rules);
- attempt idempotency uniqueness and retry semantics;
- valid D3.2 decision reference belongs to the same source occurrence;
- wrong-role/stale/missing party decision rejected;
- foreign-key and integrity checks pass after migration and after representative journal writes.

## 10. Approved status vocabularies

The owner approved and froze the following database-enforced values for schema v8:

- Run `status`: `prepared, executing, execution_blocked, execution_complete, reconciling, reconciliation_failed, reconciled, accepted, aborted`.
- Occurrence `execution_status`: `preflighted, ready, held, excluded, claimed, imported, retryable_failure, permanent_failure, conflict, reconciled, reconciliation_failed`.
- Attempt `outcome`: `imported, already_imported, retryable_failure, permanent_failure, conflict, abandoned`.

These are value constraints only. Repository-level transition validation is a separate implementation layer and must not be inferred from the allowed-value lists. No run, occurrence, or attempt may use an unlisted value.

## 11. Remaining operational dependencies (outside schema v8 scope)

The following remain necessary before a production import can be designed or executed, but they do not block the approved schema-only implementation:
1. Resolve the field-mapping matrix's remaining business rules, especially date/time semantics and product measurement sign/precision/range.
2. Map authenticated/local actor metadata to actual app capabilities.
3. Specify the export package manifest and restore location contract.
4. Define the current old-importer collision inventory and resolution process.
5. Define repository-level state-transition validation independently of database allowed-value checks.

## 12. Approval boundary

The owner has approved the corrected schema v8 contract and authorized implementation of the five additive D4 tables, migration coverage from every supported pre-v8 schema version, required constraints/triggers/indexes, generated Drift files, and schema-focused tests only.

This does **not** authorize an invoice importer, export/restore implementation, production data migration, source mutation, UI integration, financial-ledger operations, or cutover. Those remain separate approval gates.

---

**End of D4 schema proposal — corrected schema v8 contract approved; schema-only implementation authorized. Importer, export/restore, production migration, and cutover remain out of scope.**
