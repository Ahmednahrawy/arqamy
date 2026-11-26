# Arqamy — Finished Tasks

**Repository:** `Ahmednahrawy/arqamy`  
**Branch:** `main`  
**Last updated:** 2026-11-26  
**Current baseline:** `271d330` — merge of `stage-d3-2-persistent-party-review-repository`

This file records completed engineering work removed from the active roadmap. Completion means the stated scope is implemented and merged; it does not imply that adjacent roadmap work or broader production rollout is complete.

---

## 1. Application data-loss mitigation and startup

- [x] Added mandatory invoice loading inside the serialized invoice mutation path before save, update, delete, restore, and customer-ID assignment.
- [x] Added application bootstrap behavior that loads saved invoices before exposing the main application.
- [x] Added loading and retry behavior when startup invoice storage cannot be read.
- [x] Added regression tests for startup loading, retry after read failure, and provider mutation behavior when storage reads fail.

**Boundary:** SharedPreferences remains the operational invoice store. These changes mitigate the cold-start overwrite defect; they do not complete the Drift migration.

## 2. Legacy invoice migration preparation — Stages A–C

- [x] Added raw snapshot capture that reads the exact `saved_invoices` SharedPreferences value directly.
- [x] Added a content-addressed raw snapshot file, SHA-256 and byte-length verification, and a manifest distinguishing a missing key from an existing empty value.
- [x] Added read-only record-level preflight with snapshot integrity verification, top-level JSON validation, per-occurrence parsing, malformed-record findings, duplicate-ID classification, and audit issue reporting.
- [x] Added deterministic, versioned source-occurrence identity using snapshot digest, original source index, and exact raw-record digest.
- [x] Added party-resolution planning per source occurrence, with expected customer/supplier role, candidate identities, and explicit handling for missing, ambiguous, and role-mismatched parties.
- [x] Added explicit in-memory party-review decisions. The workflow does not automatically merge similar names or create parties.

**Boundary:** Snapshot storage is currently app-private. An independently recoverable/exportable copy and restore workflow remain open. These stages do not import invoices into Drift.

## 3. Persistent party-review journal — Stages D3.1/D3.2

- [x] Added persistent migration-run metadata bound to the snapshot digest and processing versions.
- [x] Added frozen occurrence and party-resolution review snapshots.
- [x] Added append-only decision history with sequence and supersession relationships.
- [x] Added idempotency keys and request-fingerprint conflict detection.
- [x] Added atomic decision-batch persistence and rollback behavior for invalid/conflicting batches.
- [x] Added read operations for migration runs, decision history, and latest effective review decisions.
- [x] Added review summaries for approved, held, unreviewed, and stale decisions.
- [x] Added schema-v6-to-v7 migration to strengthen the decision insert-validation trigger.
- [x] Added validation for complete resolved party identity and role before a review run can be persisted.
- [x] Added repository and database migration regression tests.

**Boundary:** The journal records review decisions only. It does not create parties, assign roles, link invoices, import invoices, record import execution progress, or alter financial/ledger records.

## 4. Main-branch integration and verification

- [x] Merged D3.2 into `main` (merge commit `271d330`).
- [x] Confirmed local `main` is synchronized with `origin/main` and the working tree is clean.
- [x] Confirmed `flutter analyze` reports no issues.
- [x] Confirmed full `flutter test` run: **362 passed, 0 failed**.
- [x] Confirmed `git diff --check` is clean.
- [x] Owner reports GitHub CI is green for the merge.

**Known follow-up:** Payment-ledger concurrency tests emit Drift warnings about multiple `AppDatabase` instances sharing a `QueryExecutor`. The warnings did not fail the suite and must be investigated rather than globally suppressed.

## 5. Other merged application updates

- [x] Added Android WhatsApp PDF and Excel sharing support in the main-branch update preceding D3.2 integration.
- [x] Updated Arabic and English localization resources in the main-branch update preceding D3.2 integration.

---

## Explicitly not completed

The following remain active roadmap items and must not be treated as finished:

- Google Play confirmation that the replacement Android upload key is active.
- Release verification using the replacement upload key.
- Historical Git cleanup for exposed signing material.
- Independently recoverable/exportable raw migration snapshot and restore.
- Migration execution journal (separate from the party-review journal).
- Occurrence-key-based import planner/executor and durable held-record quarantine.
- Transactional, resumable invoice/line import into Drift.
- Executable source-to-destination reconciliation and formal acceptance.
- Drift-backed operational invoice repository and production cutover.
- Post-cutover rollback/recovery for new writes.
- Full current-HEAD re-audit of `docs/AUDIT.md`.
- Investigation of Drift multiple-database warnings in concurrency tests.
