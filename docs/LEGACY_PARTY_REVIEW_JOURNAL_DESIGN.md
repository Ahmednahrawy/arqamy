# Arqamy — Stage D3: Persistent Party-Resolution Review Journal

**Repository:** `Ahmednahrawy/arqamy`  
**Target branch:** `main`  
**Design status:** Implemented in part; retained as the design record  
**Implementation status:** D3.1/D3.2 persistence implementation is merged into `main`; this document does not authorize further implementation  
**Current implementation baseline:** `main` merge commit `271d330`; schema version 7  
**Scope:** Persist the human review decisions produced by the occurrence-based legacy invoice party-resolution workflow.

---

## 1. Purpose and decision boundary

Stages A–C establish a verified raw snapshot, record-level preflight, and deterministic source-occurrence identities. Stage D1 plans party resolution per occurrence. Stage D2 applies explicit review decisions in memory. Stage D3's persistent party-review journal has now been implemented through D3.1/D3.2 and merged into `main`.

This document records the design and implemented behavior. The implementation is intentionally limited to migration-run metadata, frozen occurrence/review snapshots, and append-only party-review decisions. It does **not** implement UI/startup integration, party creation, role assignment, invoice linking, invoice import, or changes to SharedPreferences business data. Those activities require separate design review and approval.

## 2. Current implementation baseline

The implementation is present on `main` at merge commit `271d330`. `AppDatabase` is at schema version **7**.

- Persistent tables: `legacy_migration_runs`, `legacy_migration_occurrences`, and `legacy_party_review_decisions`.
- `LegacyPartyReviewJournalRepository` persists run metadata, frozen preflight/resolution snapshots, and append-only decision events.
- Decision writes include idempotency keys, request fingerprints, sequence/predecessor relationships, actor metadata, and atomic batch handling.
- D3.2 adds a schema-v6-to-v7 trigger migration that validates accepted suggested matches against resolved preflight statuses.
- The repository validates that every occurrence belongs to the run's snapshot and that resolved suggestions contain a complete party identity and role.

The journal does not integrate a production review UI or perform invoice-import side effects. It does not create parties, assign roles, link invoices, import invoices, or modify existing business transactions.

The owner-reported full local validation on this baseline is `flutter analyze` clean and **362 tests passed**.

## 3. Design principles

1. **Snapshot-bound:** every run and every decision belongs to one exact raw snapshot digest and migration/preflight version.
2. **Occurrence-bound:** decisions use the complete versioned source-occurrence key, never invoice ID or serial alone.
3. **Append-only history:** a later decision supersedes an earlier one; it never edits or deletes it.
4. **Explicit human intent:** no party is selected or approved by silently re-running fuzzy/name matching.
5. **Role-safe:** an approved party must already exist and hold the expected role at decision time.
6. **Idempotent writes:** retrying the same request cannot create duplicate decisions.
7. **Offline-first:** the journal is local Drift data; it does not require Firebase or network access.
8. **No business side effects:** D3 records review data only. It does not create parties, alter party roles, link invoices, create cash events, or import invoices.
9. **Recoverable:** a crash between review and confirmation must leave either the whole decision batch committed or none of it.
10. **Auditable:** reviewer identity, decision time, action, selected party snapshot, and supersession history remain inspectable.

## 4. Proposed data model

The recommendation is three tables. Names are proposed and may be adjusted to repository naming conventions during implementation.

### 4.1 `legacy_migration_runs` — immutable run identity

One row identifies one attempt to review one immutable source snapshot using a particular migration/preflight contract.

| Field | Type | Purpose |
|---|---|---|
| `run_id` | TEXT PK | Stable unique ID for this migration run |
| `snapshot_sha256` | TEXT | Exact raw snapshot digest |
| `snapshot_manifest_path` | TEXT | App-private manifest reference; never a user-supplied arbitrary path |
| `migration_version` | INTEGER | Version of the migration workflow |
| `occurrence_identity_version` | INTEGER | Version of the source-occurrence key format |
| `preflight_version` | INTEGER | Version of preflight rules used to create the review set |
| `created_at` | INTEGER | UTC epoch timestamp |
| `created_by_actor_id` | TEXT | Actor that initiated the run |

Constraints:
- SHA-256 must be exactly 64 hexadecimal characters.
- Version values must be positive.
- A run is permanently bound to one snapshot digest and one set of processing versions.
- A changed snapshot or changed preflight contract creates a new run; it must not mutate or silently reuse an old run.
- The run identity row is immutable.

A deliberate retry of the exact same snapshot may either resume the existing compatible run or create a new run with an explicit retry relationship in a later design. D3 should initially resume an existing open run only when all version and digest fields match. It must reject incompatible reuse.

### 4.2 `legacy_migration_occurrences` — frozen review input

One row stores the occurrence-level planning result used by the reviewer. This freezes what was presented for review and prevents later party-registry changes from silently rewriting the historical plan.

| Field | Type | Purpose |
|---|---|---|
| `run_id` | TEXT | Parent migration run |
| `source_occurrence_key` | TEXT | Full versioned occurrence identity |
| `source_index` | INTEGER | Original array position |
| `record_sha256` | TEXT | Digest of exact raw record fragment |
| `legacy_invoice_id` | TEXT nullable | Display/diagnostic value only; not identity |
| `preflight_classification` | TEXT | Preflight outcome at run creation |
| `resolution_status` | TEXT | Planner status at run creation |
| `expected_role` | TEXT nullable | Required role, if action is recognized |
| `suggested_party_id` | TEXT nullable | Suggested existing party, if resolved |
| `suggested_party_name` | TEXT nullable | Display-name snapshot at planning time |
| `candidate_party_ids_json` | TEXT | Candidate IDs shown for ambiguous review |
| `findings_json` | TEXT | Stable, versioned review findings/details |

Primary key: `(run_id, source_occurrence_key)`.

Constraints and validation:
- Source index must be non-negative.
- Record digest and occurrence key must agree with the immutable source snapshot when the run is created.
- Candidate IDs and findings must be valid JSON with a documented format version.
- Role values are restricted to the existing supported party roles.
- Rows are immutable after the run is opened for review.
- The raw record itself remains in the verified snapshot file; this table stores its digest and location identity, not a second mutable copy of the invoice.

The planner output is frozen for audit. If the party registry changes and the suggested match is no longer valid, the write-time validator rejects the stale decision. The operator must refresh/rebuild the review plan under an explicitly versioned run rather than silently changing the frozen input.

### 4.3 `legacy_party_review_decisions` — append-only decision history

Each row records one reviewer decision for one occurrence. A later review creates a new row linked to the prior decision.

| Field | Type | Purpose |
|---|---|---|
| `decision_id` | TEXT PK | Unique decision ID |
| `run_id` | TEXT | Migration run |
| `source_occurrence_key` | TEXT | Exact occurrence being reviewed |
| `sequence` | INTEGER | 1-based decision sequence for this run/occurrence |
| `previous_decision_id` | TEXT nullable | Prior decision being superseded |
| `action` | TEXT | `acceptSuggestedMatch`, `selectParty`, or `keepHeld` |
| `expected_role` | TEXT nullable | Required role copied from the frozen occurrence |
| `resolved_party_id` | TEXT nullable | Party approved by this decision; null when held |
| `resolved_party_name` | TEXT nullable | Display-name snapshot at decision time |
| `resolved_party_role` | TEXT nullable | Role snapshot at decision time |
| `reviewer_id` | TEXT | Reviewer/actor identity |
| `decided_at` | INTEGER | UTC decision timestamp |
| `review_note` | TEXT nullable | Optional human explanation |
| `idempotency_key` | TEXT | Unique request key for safe retries |
| `request_fingerprint` | TEXT | Hash of the canonical decision request |

Constraints:
- Unique `(run_id, source_occurrence_key, sequence)`.
- Unique `idempotency_key`.
- `sequence` must be at least 1.
- Sequence 1 has no previous decision. Sequence N must reference sequence N-1 for the same run and occurrence.
- `keepHeld` requires all resolved-party fields to be null.
- `acceptSuggestedMatch` requires the resolved party to equal the frozen suggested party.
- `selectParty` requires a non-null resolved party.
- Approved decisions require a non-null expected role and resolved-party role equal to that expected role.
- Reviewer ID and idempotency key must be non-empty.
- Decision time is stored as UTC epoch time.
- Update and delete triggers reject changes. Corrections are new decisions, not edits.

The selected party ID should be checked against the current `parties` and `party_roles` tables inside the same database transaction that inserts the decision. The decision also stores the party name and role observed at decision time so that later renaming or role changes do not rewrite the historical audit record. The decision row should not rely solely on a live join to reconstruct what the reviewer approved.

## 5. Decision and supersession semantics

The latest decision sequence for an occurrence is its effective review outcome.

Examples:

| Sequence | Action | Effective result |
|---:|---|---|
| 1 | `keepHeld` | Held |
| 2 | `selectParty` | Approved for the selected existing party |
| 3 | `keepHeld` | Held again; sequence 2 remains in history |

Rules:
- The first decision has sequence 1 and no predecessor.
- Every subsequent decision increments the sequence by exactly one and references the immediately preceding decision.
- A new decision never deletes or modifies the earlier decision.
- Re-reviewing an occurrence is allowed only through a new explicit user action.
- The current review report is a projection of the latest decision per occurrence, not a replacement of the historical rows.
- An occurrence with no decision remains held/unreviewed.
- A decision for a different snapshot, run, or unknown occurrence is rejected.
- Duplicate decisions in one submitted batch are rejected before any write.

## 6. Idempotency and transaction behavior

A decision submission must carry an idempotency key generated once by the caller and reused on retry.

Within one transaction:
1. Validate the run exists and is compatible with the supplied snapshot digest and workflow versions.
2. Load the frozen occurrence row and validate its key/index/hash.
3. Check whether the idempotency key already exists.
4. If it exists with the same request fingerprint, return the original decision as a successful retry.
5. If it exists with a different fingerprint, reject the request as an idempotency conflict.
6. Validate the expected role and selected party against current party/role rows.
7. Validate the next sequence and predecessor link.
8. Insert the immutable decision row.
9. Commit the complete batch atomically.

If any decision in a submitted batch fails validation, the whole batch rolls back. This prevents a partially persisted review submission.

No database write may be performed before all pure input validation has completed. Database-dependent checks must still occur inside the transaction to avoid a time-of-check/time-of-use gap.

## 7. Read model and review report

The repository should expose:
- run metadata and compatibility;
- frozen occurrence rows for the selected run;
- full decision history for an occurrence;
- the latest effective decision for each occurrence;
- counts for total, approved, held, and not-yet-reviewed occurrences;
- stale/invalid decision diagnostics where current party-role state no longer matches the stored decision.

The existing in-memory `LegacyInvoicePartyResolutionReview` remains the domain validation reference. Persistence should adapt validated domain decisions to journal records; it should not duplicate or fork the review rules.

A report must distinguish:
- **Approved:** latest decision is `acceptSuggestedMatch` or `selectParty` and passes current integrity checks.
- **Held:** latest decision is `keepHeld`, or the frozen plan cannot be approved.
- **Unreviewed:** no decision exists.
- **Stale:** the latest approval no longer passes current party/role integrity checks. Stale is a diagnostic state; it does not rewrite the original decision.

## 8. Security and actor provenance

The journal records the reviewer ID supplied by the application. A non-empty string alone is not proof of authentication.

Before production use, the application must define where actor IDs come from and how the current user is authorized to review. D3 must not invent a user or claim that local journal rows provide tamper-proof non-repudiation. A local database can be modified by someone with device/filesystem access; this journal provides application-level audit history, not cryptographic proof against a hostile device owner.

Do not store passwords, access tokens, or other credentials in the journal.

## 9. Failure, recovery, and integrity

- A failed transaction leaves no partial decision batch.
- A retry with the same idempotency key and same fingerprint returns the existing decision.
- A retry with the same key and a different fingerprint is rejected.
- A broken predecessor chain, duplicate sequence, missing run, missing occurrence, or digest mismatch blocks further writes for the affected run until diagnosed.
- The immutable raw snapshot and manifest remain the source evidence. The journal must never modify or delete them.
- Database backup/restore must include run, occurrence, and decision tables consistently.
- On restore, verify foreign keys, journal sequence chains, unique constraints, and SQLite integrity before resuming review.
- A missing snapshot file does not authorize reconstructing the source from journal fields. Mark the run unavailable for further review and preserve its audit rows.
- Do not silently migrate journal rows between runs or snapshots.

## 10. Drift schema and migration strategy

The current schema version observed on `main` is 5. If this proposal is approved for implementation, the expected next schema version is 6.

Implementation should:
1. Add the three proposed table definitions to the Drift database source.
2. Add explicit v5-to-v6 migration logic that creates the new tables and constraints without rewriting existing business rows.
3. Add append-only update/delete triggers for decision history and immutable run/occurrence records.
4. Regenerate Drift-generated code using the repository's pinned toolchain.
5. Add schema migration tests from an actual v5 database fixture and fresh-database tests.
6. Add constraint/trigger tests for sequence chains, role validation, idempotency, immutability, and transaction rollback.
7. Verify `PRAGMA foreign_key_check` and `PRAGMA integrity_check` after migration.
8. Confirm the migration preserves all existing rows and does not alter invoices, parties, payments, cash events, allocations, refunds, or suspense data.

No schema migration is part of this design-only stage.

## 11. Explicit non-goals

D3 does not:
- create missing customers or suppliers;
- assign new roles to existing parties;
- merge duplicate parties or names;
- link legacy invoices to parties in the production invoice table;
- create financial accounts;
- create payments, cash events, allocations, refunds, reversals, or ledger entries;
- import invoices or lines;
- change invoice reads/writes or cut over from SharedPreferences;
- synchronize the journal to Firebase;
- provide multi-device concurrent review or conflict resolution.

In particular, invoice aggregate `paid` and `rest` values remain historical invoice data. No journal decision can authorize synthesizing cash events or payment allocations from those aggregates.

## 12. Acceptance criteria for the design

The proposal is ready for implementation only when the owner confirms:

- the three-table separation (run, frozen occurrence, append-only decision);
- whether a compatible run is resumed or a new retry run is created;
- the supersession rule (latest sequence is effective; prior decisions remain immutable);
- idempotency-key and request-fingerprint behavior;
- storing party name/role snapshots in decision rows;
- the actor identity source and its trust limitations;
- the initial scope remains local-only and has no invoice/party/ledger side effects.

After design approval, implementation should still be split into separately reviewable steps: schema + migration tests first, then repository/domain persistence, then integration tests. UI and workflow integration remain separate approvals.

---

**End of proposal — no implementation authorized.**
