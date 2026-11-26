# Arqamy — Development Plan

**Repository:** `Ahmednahrawy/arqamy`  
**Branch:** `main`  
**Current main baseline:** `271d330` — D3.2 merge; local validation on 2026-11-26: `flutter analyze` clean and 362 tests passed.  
**Product direction:** Global, modular business management SaaS  
**Status:** Approved roadmap — implementation remains phase-gated and requires separate approval for code/schema changes

---

## 1. Product vision

Transform Arqamy from an invoice-focused Flutter application into a configurable, multi-business business-management platform for small and medium-sized businesses.

### Initial market

- Retail
- Wholesale
- Distribution
- Services

Manufacturing and other industries can be introduced through future industry-specific modules.

### First platforms

- Android
- Web

iOS, Windows, and macOS remain future platform targets.

### Core principles

1. Modular architecture with shared business services.
2. Strict tenant and business data isolation.
3. Offline-first operation and reliable synchronization.
4. Drift as the local database source of truth.
5. Lossless migration of existing customer data.
6. Financial and inventory integrity.
7. Configurable permissions and approval workflows.
8. Arabic/English localization, RTL/LTR, and global formatting.
9. Progressive activation of advanced modules.
10. Incremental implementation with automated verification.

---

## 2. Current repository baseline

**Verified baseline:** `main` at merge commit `271d330` (2026-11-26).

The repository currently contains:

- Flutter application using Provider.
- SharedPreferences key `saved_invoices` remains the operational invoice source of truth.
- Drift/SQLite database at schema version **7**.
- Financial ledger domain, repositories, and invoice import planner/executor.
- Customer/party registry and role model.
- Legacy invoice raw-snapshot, record-level preflight, deterministic source-occurrence identity, party-resolution planning, and persistent party-review journal.
- Invoice bootstrap/retry handling and regression coverage for storage-read failures.
- Fixed-point `Money` implementation.
- Arabic/English ARB localization.
- Invoice PDF generation, WhatsApp PDF sharing, and Excel export/sharing.
- Backup and restore functionality.
- GitHub Actions CI for Flutter analysis and tests.

The completed engineering work is recorded in [`finished_tasks.md`](finished_tasks.md). Do not re-add completed tasks to the active roadmap unless a later audit finds a regression.

### Current architecture boundary

The legacy invoice store is **not yet migrated**. Drift currently supports the ledger/customer foundation and migration-review journal, but ordinary invoice reads and writes still use SharedPreferences. The migration import planner/executor is not yet safe for duplicate source occurrences because its existing key is based on `saved_invoices/{invoice.id}`; it must be adapted to the immutable occurrence identity before production migration.

### Open high-priority risks

- The exposed Android upload-key incident is not closed: Google Play confirmation of the replacement upload key, replacement-key release verification, and historical Git cleanup remain pending. See [`SECURITY_REMEDIATION_STATUS.md`](SECURITY_REMEDIATION_STATUS.md).
- The current SharedPreferences invoice format remains a single serialized value and is not yet the authoritative-data migration target.
- The snapshot service currently stores a verified raw snapshot and manifest in app-private storage; an independently recoverable/user-exportable copy must be included in the approved migration runbook before cutover.
- Invoice-level historical `paid` and `rest` aggregates must not be converted into cash events or allocations without separate evidence and authorization.
- The Drift import path still needs occurrence-key idempotency, durable execution/recovery states, reconciliation, and a post-cutover rollback strategy.
- The latest local full test run passed 362 tests, but Drift emits multiple-database warnings in payment-ledger concurrency tests. These warnings remain an investigation item; they were not suppressed.

## 3. Target architecture

### 3.1 Application architecture

Use a modular monolith with clear boundaries.

Each feature should have:

- `domain/` — entities, value objects, business rules, and interfaces.
- `application/` — use cases and orchestration.
- `data/` — repositories, local persistence, remote data sources, and mapping.
- `presentation/` — screens, widgets, and state management.

Suggested structure:

```text
lib/
  app/
    bootstrap/
    routing/
    configuration/

  core/
    database/
    errors/
    security/
    synchronization/
    localization/
    networking/
    services/
    widgets/

  features/
    identity/
    organizations/
    businesses/
    branches/
    users/
    customers/
    suppliers/
    catalog/
    inventory/
    sales/
    purchasing/
    payment_ledger/
    finance/
    reporting/
    settings/
```

Do not move all existing files immediately. Introduce the structure incrementally, feature by feature.

### 3.2 State management

Keep Provider during the initial transformation.

Standardize provider responsibilities and prevent business rules from being embedded in widgets.

Do not introduce a broad state-management rewrite unless a verified technical limitation requires it.

### 3.3 Local database

Drift/SQLite becomes the authoritative local persistence layer.

Requirements:

- Repository interfaces for all business data.
- Transactional operations.
- Foreign-key integrity.
- Explicit schema versions.
- Auditable migration history.
- Idempotent data migration.
- Safe recovery and backup.
- Appropriate indexes and query performance.

Retain SharedPreferences for lightweight preferences, not business transactions.

### 3.4 Cloud architecture

Recommended direction:

- Versioned backend API.
- Relational server database, preferably PostgreSQL.
- Explicit tenant and business isolation.
- Authentication and authorization at the server.
- Central audit and approval services.
- Object storage for documents and attachments.
- Push notification service.

Evaluate Firebase Authentication, messaging, and storage as supporting services. Do not assume Firebase Core initialization provides cloud persistence or authorization.

The backend should initially be a modular monolith, not a collection of microservices.

### 3.5 Tenant and business identity

Distinguish:

- User identity.
- Organization membership.
- Business.
- Branch.
- Operational unit.
- Warehouse.

Every business transaction must carry an explicit business scope.

Enforce tenant isolation in repositories, server authorization, and database constraints where applicable. UI visibility is never sufficient security.

---

## 4. Implementation roadmap

### Phase 0 — Critical stabilization and security

**Priority: Immediate**

Tasks:

1. Fix invoice cold-start data loss.
2. Add mandatory invoice loading before any mutation.
3. Add a regression test using pre-existing saved invoice data.
4. Protect against corrupted or partially invalid invoice records.
5. Rotate the exposed Android release-signing key.
6. If applicable, coordinate the Google Play upload-key reset.
7. Remove exposed signing material and passwords from Git history across relevant refs.
8. Store signing credentials securely outside the repository.
9. Verify release builds fail when signing is not configured.
10. Verify the current HEAD with CI.

**Acceptance criteria:**

- Existing invoice history survives cold-start saves.
- Failed writes do not replace valid stored data.
- Regression tests cover the original failure.
- Signing credentials are rotated and safely stored.
- Current HEAD passes analysis and tests.

No feature expansion before the critical data-loss issue is resolved.

### Phase 1 — Application foundation and architecture

Tasks:

- Introduce an application bootstrap lifecycle.
- Establish repository and use-case boundaries.
- Define shared error handling and logging.
- Standardize ID generation and timestamps.
- Define money and decimal precision policies.
- Define document identity and numbering rules.
- Establish architecture decision records (ADRs).
- Establish automated database migration testing.

**Acceptance criteria:**

- Business initialization is centralized.
- Data access is separated from presentation.
- Existing invoice workflows continue to function.
- Architecture rules are documented and testable.

### Phase 2 — Legacy data migration and Drift adoption

Tasks:

1. Inventory all existing SharedPreferences business data.
2. Back up the original invoice store.
3. Use the legacy invoice readiness audit.
4. Detect duplicate invoice IDs and inconsistent amounts.
5. Preserve original JSON and source-record identity.
6. Resolve customer identities through the migration planner.
7. Map invoices and lines into Drift.
8. Integrate invoice lifecycle and payment ledger repositories.
9. Validate record counts, totals, relationships, and allocations.
10. Implement retry-safe migration and recovery.
11. Switch production reads and writes only after verification.

**Migration rules:**

- Never assume duplicate legacy IDs are unique record identities.
- Preserve every source occurrence.
- Never guess ambiguous customer mappings.
- Never silently convert unresolved amounts into a currency.
- Preserve historical financial values.
- Keep legacy data until migration acceptance.
- Make migration idempotent.

**Acceptance criteria:**

- Migration can be repeated without duplicate records.
- All source records are accounted for.
- Financial totals reconcile.
- Failed migrations can be recovered.
- No legacy records are deleted before acceptance.

### Phase 3 — Identity, organizations, and business foundations

Tasks:

- Authentication and account recovery.
- Global user identity.
- Organization membership.
- Multiple businesses per account.
- Business switching and workspace context.
- Branch and organizational hierarchy.
- Role-based authorization.
- Granular permissions.
- Approval policies.
- Audit events.
- Data lifecycle and retention policies.

**Acceptance criteria:**

- A user can belong to multiple organizations.
- Different roles work independently in different businesses.
- Cross-business access is denied by default.
- Sensitive operations enforce authorization outside the UI.
- Important changes are auditable.

### Phase 4 — Master data and commercial foundations

Implement:

- Customers and suppliers.
- Universal product/service catalog.
- Product variants.
- Units and conversions.
- Currencies and exchange rates.
- Pricing lists and customer-specific pricing.
- Tax configuration.
- Document numbering.
- Document templates.

Start with the requirements necessary for the initial industries.

**Acceptance criteria:**

- Products and services can coexist.
- Historical documents retain their original pricing and currency context.
- Customer and supplier identities are stable.
- Master data respects business boundaries.

### Phase 5 — Inventory and purchasing foundations

Implement in dependency order:

1. Inventory movement ledger.
2. Warehouses and locations.
3. Stock receipts and issues.
4. Transfers and adjustments.
5. Unit conversions.
6. Stock reservations.
7. Purchase requests.
8. Purchase orders.
9. Goods receiving.
10. Supplier returns.
11. Basic inventory valuation.
12. Reconciliation and stock reports.

Add configurable FIFO, weighted average, and other approved costing methods without rewriting historical movements.

Advanced WMS, quality management, lot genealogy, and demand forecasting follow after the core inventory engine is stable.

**Acceptance criteria:**

- Every stock change has a source and traceable movement.
- Concurrent operations cannot silently corrupt balances.
- Transfers preserve quantity and valuation consistency.
- Inventory balances can be reconciled.

### Phase 6 — Sales, POS, and financial integration

Implement:

- Quotations and sales orders.
- Invoices and partial fulfillment.
- Customer credit and payment terms.
- Returns and refunds.
- POS.
- Customer and supplier payment workflows.
- Cash and bank accounts.
- Expenses.
- Accounts receivable/payable.
- Payment allocation.
- Basic accounting integration.
- Financial reporting.

Preserve the approved Payment Ledger rules:

- Distinguish cash received from cash paid.
- Preserve correction and reversal history.
- Count corrected cash events once.
- Use suspense/reconciliation balances when recognition is reversed without cash return.
- Require authorized evidence-based suspense resolution.
- Support multiple partial refund payouts within the authorized target.

Operational document status, accounting recognition, inventory movement, and physical cash movement remain separate concepts.

**Acceptance criteria:**

- Payments cannot be allocated beyond eligible balances.
- Refunds and corrections remain auditable.
- Sales and purchase totals reconcile.
- Inventory and financial operations are transactionally consistent.

### Phase 7 — Offline/cloud synchronization and web platform

Tasks:

- Cloud API and server persistence.
- Device identity and synchronization state.
- Local outbox/inbox.
- Idempotent synchronization.
- Conflict detection and resolution.
- Versioned records.
- Approval separated from synchronization.
- Offline POS.
- Multi-device testing.
- Web-responsive business workspace.
- Role-specific dashboards.

Never silently overwrite financial or inventory records.

**Acceptance criteria:**

- Offline operations can be synchronized safely.
- Duplicate delivery does not duplicate financial events.
- Conflicts remain visible and recoverable.
- Unauthorized cross-business data access is prevented.
- Android and Web share the same business rules.

### Phase 8 — Advanced platform modules

Deliver incrementally:

- Advanced WMS.
- Procurement and sourcing.
- Quality management.
- Replenishment and demand planning.
- Advanced accounting and treasury.
- HCM and payroll.
- CRM and customer service.
- Project and task management.
- Marketing automation.
- E-commerce and omnichannel commerce.
- BI and advanced analytics.
- Workflow automation.
- AI agents and intelligence.
- Public APIs, SDKs, and integrations.
- Subscription and entitlement management.
- Industry-specific solution packs.

Each module must have explicit dependencies, activation rules, permissions, and acceptance criteria.

---

## 5. Security and governance

Security is foundational.

Requirements:

- Strict tenant isolation.
- Server-enforced authorization.
- Least privilege.
- MFA and secure account recovery.
- Encryption in transit and at rest.
- Secure secret and signing-key management.
- Audit trails.
- Device/session management.
- Privacy and consent management.
- Backup and recovery.
- Incident response.
- Retention and deletion policies.

AI agents must operate under the same business and user permissions as normal users.

No AI agent may bypass approval policies or perform irreversible financial or inventory operations without explicit authorization.

Compliance certifications must not be claimed until independently verified.

---

## 6. Testing and quality strategy

Every phase must include tests.

### Unit tests

- Money and rounding.
- Business rules.
- Pricing and tax calculations.
- Inventory costing.
- Permissions.
- Approval rules.
- Synchronization conflict logic.

### Integration tests

- Drift repositories.
- Database migrations.
- Invoice persistence.
- Ledger operations.
- Payment allocation.
- Backup and restore.
- Legacy migration.
- Offline synchronization.

### Widget tests

- Invoice creation and editing.
- Customer and supplier workflows.
- POS.
- Inventory operations.
- Approval interfaces.
- Arabic/English and RTL/LTR.

### End-to-end tests

- Business setup.
- Multi-business switching.
- Sales and purchasing.
- Stock movements.
- Payments and refunds.
- Offline operation.
- Data export and recovery.

### CI requirements

For every pull request:

- Formatting verification.
- Flutter analysis.
- Unit and widget tests.
- Database migration tests.
- Relevant integration tests.

Build Android and Web in their appropriate release-validation stages.

---

## 7. Delivery and change-management rules

- One feature or tightly related change at a time.
- Inspect current repository state before implementation.
- Explain the proposed change before editing.
- Obtain approval before schema or architecture changes.
- Define migration and rollback before data changes.
- Preserve existing behavior unless explicitly changed.
- Run tests and builds after each implementation step.
- Review the final diff.
- Report changed files, test results, and known limitations.
- Stop and request approval before beginning the next feature.

Do not create speculative infrastructure for future modules before a concrete dependency requires it.

---

## 8. Immediate next implementation sequence

After approval of this plan:

1. Resolve release-signing-key exposure and rotation.
2. Fix invoice cold-start data loss.
3. Add startup/bootstrap and persistence regression tests.
4. Re-run the current CI pipeline.
5. Review and update `docs/AUDIT.md`.
6. Produce the detailed Drift adoption and legacy migration design.
7. Implement the migration only after its design and rollback plan are approved.

**First implementation milestone:** A stable application that cannot silently lose invoice history, has safe release signing, and has a verified data foundation for the SaaS transformation.

---

## 9. Definition of success

Arqamy is ready for its first major SaaS release when:

- Multiple independent businesses can operate under one account.
- Business data is isolated and access-controlled.
- Customers, suppliers, products, and services share consistent identities.
- Sales, purchasing, inventory, and payments operate on reliable repositories.
- The Payment Ledger preserves financial integrity.
- Android and Web support the agreed core workflows.
- Offline changes synchronize safely.
- Arabic/English and RTL/LTR work throughout the application.
- Backups, migration, and recovery are tested.
- CI validates every change.
- Advanced modules can be enabled progressively without destabilizing the core platform.
