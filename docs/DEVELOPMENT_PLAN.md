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

**Priority: Security remediation remains open**

The invoice cold-start overwrite mitigation and startup bootstrap are complete; see [`finished_tasks.md`](finished_tasks.md).

Remaining tasks:

1. Complete the Android upload-key reset with Google Play confirmation.
2. Verify a release artifact using the replacement upload key after confirmation.
3. Complete a reviewed Git-history cleanup plan and execute it only after explicit approval, preserving unique branch and open-PR work.
4. Verify all relevant refs and reachable history after cleanup.

**Acceptance criteria:**

- Google Play confirms the replacement upload certificate is active.
- A release artifact is signed with the accepted replacement upload key and its certificate is verified.
- Exposed signing material is removed from reachable history to the extent supported by GitHub, with limitations documented.
- No old compromised key is used for new releases.

### Phase 1 — Application foundation and architecture

**Status: Foundation partially implemented.**

Completed bootstrap and regression work is tracked in [`finished_tasks.md`](finished_tasks.md).

Remaining tasks:

- Establish and enforce repository and use-case boundaries for the operational invoice workflow.
- Define shared error handling and structured logging.
- Standardize ID generation and timestamps across business records.
- Define and test database migration conventions, including upgrade, rollback/recovery, and migration-fixture coverage.
- Add formatting enforcement and relevant Android/Web build validation to CI.
- Re-audit the current code and update `docs/AUDIT.md` against the current `main` baseline.

**Acceptance criteria:**

- Business initialization is centralized.
- New business data access is separated from presentation.
- Existing invoice workflows continue to function.
- Architecture rules are documented and testable.
- CI validates formatting, analysis, tests, and the agreed build targets.

### Phase 2 — Legacy data migration and Drift adoption

**Status: Design and review foundation implemented; production import and cutover remain incomplete.**

Completed foundations are tracked in [`finished_tasks.md`](finished_tasks.md):

- Verified raw snapshot capture and manifest.
- Record-level legacy invoice preflight.
- Deterministic source-occurrence identities.
- Party-resolution planning and human review.
- Persistent party-review journal (D3.2).

Remaining tasks, in dependency order:

1. Review and approve the updated [`DRIFT_MIGRATION_DESIGN.md`](DRIFT_MIGRATION_DESIGN.md) as the current design baseline.
2. Add an independently recoverable/exportable snapshot path and a tested restore procedure.
3. Design the **migration execution journal** separately from the already implemented party-review decision journal.
4. Adapt invoice mapping and import idempotency to the complete source-occurrence key and immutable snapshot/migration version. Retire `saved_invoices/{invoice.id}` as the sole migration identity.
5. Define handling for duplicate legacy IDs, malformed records, unknown actions, unsupported numeric precision, invalid totals, and unresolved party roles. Held records must remain traceable and recoverable.
6. Implement invoice-plus-lines-plus-occurrence-mapping as one atomic transaction, with retry-safe execution and failure-injection tests.
7. Reconcile every source occurrence, invoice, line, historical amount, party link, and database integrity result.
8. Define and test post-cutover rollback/recovery for writes created after cutover.
9. Implement a Drift-backed invoice repository behind an application-facing interface.
10. Integrate all invoice lifecycle operations with one authoritative repository.
11. Obtain explicit owner acceptance of reconciliation before a separately approved cutover.
12. Retain the raw source snapshot and migration evidence for the agreed recovery period.

**Migration rules:**

- Never assume duplicate legacy IDs are unique source identities.
- Preserve every source occurrence, including malformed records.
- Never guess ambiguous customer/supplier mappings.
- Never silently convert unresolved amounts into a currency.
- Preserve historical financial values.
- Never synthesize cash events, payment allocations, refunds, or accounting entries from invoice-level `paid`/`rest` aggregates.
- Make import idempotent against the immutable occurrence identity and migration version.
- Keep legacy data unchanged until acceptance and cutover approval.
- Do not introduce uncontrolled dual-write between SharedPreferences and Drift.

**Acceptance criteria:**

- A byte-for-byte recoverable source snapshot is independently verified.
- Every source occurrence has exactly one accounted-for status.
- Every imported invoice maps to exactly one source occurrence.
- Duplicate and malformed records are preserved and explicitly held.
- Financial totals and line values reconcile under an approved precision policy.
- No unsupported cash history is synthesized.
- Repeating the same migration creates no additional business records.
- Failed migrations can be resumed or safely recovered.
- Cutover occurs only after reconciliation and explicit owner approval.

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

## 8. Immediate next sequence

The D4 execution-journal/import design has been approved by the owner. The repository audit is documented in [LEGACY_INVOICE_MIGRATION_EXECUTION_AUDIT.md](LEGACY_INVOICE_MIGRATION_EXECUTION_AUDIT.md). The next work is to complete mapping/schema design; implementation remains separately gated.

1. Review the [legacy invoice/product field-mapping matrix](LEGACY_INVOICE_FIELD_MAPPING_MATRIX.md) and resolve its open business rules (date/time semantics, measurement sign/precision/range, blank text, and party-role behavior).
2. Prepare a separate D4 schema proposal for run, occurrence, attempt, operator-event, and occurrence-mapping persistence, based on the current schema-v7 database.
3. Specify the schema upgrade, indexes, uniqueness constraints, foreign keys, append-only triggers, transaction boundaries, claim-token rules, and rollback plan.
4. Review the independent snapshot export/restore design and the post-cutover forward-recovery/replay design.
5. Submit the schema proposal for explicit approval before changing `app_database.dart`, generated Drift files, or importer code.
6. After schema approval, implement one small foundation step at a time on a feature branch, with tests and separate approval for importer and cutover behavior.

Security-key remediation remains a parallel open risk and must not be represented as complete.

**First migration milestone:** An owner-approved, fully specified, testable, recoverable import process that accounts for every legacy invoice occurrence without altering the source. D4 design direction is approved; schema and implementation changes remain separately gated.

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
