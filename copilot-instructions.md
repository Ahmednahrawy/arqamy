# Arqamy — Copilot Development Instructions

## Project vision

Evolve Arqamy from its existing Flutter invoice-generation app into a general-purpose, multi-tenant business SaaS platform supporting:

- Invoices, customers, payment tracking, customer balances, and returns.
- Products, configurable units, purchases, sales, inventory movements, and low-stock alerts.
- Financial reports, dashboards, revenue, expenses, profit, debts, and KPIs.
- Business owners, employees, role-based permissions, subscription plans, billing, and usage limits.

Target architecture: offline-first SQLite with Firebase cloud synchronization. Firebase is already integrated; audit the current implementation before proposing changes.

## Mandatory approval-first workflow

1. Inspect the relevant code and existing project conventions.
2. Explain the problem or feature, proposed solution, affected files, trade-offs, and risks concisely.
3. For database changes, include schema changes, migration steps, rollback strategy, and data-preservation measures.
4. Wait for my explicit approval before editing files.
5. Implement only the approved, smallest useful change.
6. Run relevant tests, analysis, and builds where feasible.
7. Summarize changed files, explain the important code decisions, report actual verification results, and identify remaining risks.
8. Wait for my approval before starting the next feature.

Never interpret silence or a request for explanation as permission to modify files.

## Initial audit — no edits

Before implementation:

- Inventory existing features and document their current behavior.
- Inspect project structure, dependencies, Flutter/Dart versions, Android configuration, Firebase integration, localization, state management, and persistence.
- Identify compatibility issues, security concerns, technical debt, and release-specific failures.
- Run available baseline checks and builds where feasible.
- Record existing failures separately from newly introduced failures.
- Propose a phased architecture and implementation plan.
- Do not modify files until I approve the audit and plan.

## Preserve existing functionality

Treat current behavior as the compatibility baseline. In particular, inspect and preserve:

- Invoice calculations and current purchase/sale/storage behavior.
- PDF generation, file naming, and WhatsApp sharing.
- Existing product and invoice models.
- Arabic/English localization and current theme behavior.
- Existing navigation, state management, and working integrations.

Do not remove or replace working features without explaining why and receiving approval.

## Architecture and implementation

- Follow the project's existing conventions unless an approved architectural change is necessary.
- Prefer clear separation of presentation, business logic, and data access.
- Use maintainable, testable components and explicit domain models.
- Avoid unnecessary abstractions, dependencies, rewrites, and premature optimization.
- Support configurable product types, units, and workflows without hardcoding the current business model into the entire application.
- Define clear ownership of calculations and business rules so reports and dashboards use consistent data.
- Keep UI, persistence, synchronization, and business logic appropriately separated.

## SQLite and Firebase

- Design for offline-first operation and eventual synchronization.
- Define record identifiers, tenant ownership, synchronization status, timestamps, conflict handling, retries, and deletion semantics where appropriate.
- Treat local data and cloud data as potentially inconsistent until synchronization is confirmed.
- Never assume that a successful local write means cloud synchronization succeeded.
- Design tenant isolation and authorization into the foundation.
- Enforce access control through trusted backend rules and server-side validation where required; client-side checks alone are insufficient.
- Never embed privileged credentials or secrets in the app.
- Explain schema changes and obtain approval before implementation.
- Never delete, reset, or overwrite real user data as a migration shortcut.

## Security and SaaS

- Isolate every business's records and enforce ownership on reads and writes.
- Define roles and permissions explicitly.
- Treat subscription status and usage limits as server-authoritative entitlements.
- Never trust client-provided tenant IDs, prices, roles, or subscription status without authorization and validation.
- Do not implement payment processing or paid subscription activation without an approved provider, flow, and security design.

## Testing and quality gates

- Add appropriate unit, widget, integration, migration, and synchronization tests as relevant.
- Test invoice calculations, inventory consistency, permissions, tenant isolation, offline behavior, and error recovery.
- Run formatting, static analysis, relevant tests, and builds where feasible.
- Compare failures with the documented baseline.
- Never claim a command passed unless it actually ran and succeeded.
- Do not conceal failures or bypass tests to make a build appear successful.

## Learning and communication

- I am learning Flutter and want to understand and maintain the code myself.
- Use concise, practical explanations, not long tutorials.
- Explain important Dart, Flutter, state-management, database, and architectural decisions when they arise.
- Explain why a solution is appropriate and mention significant alternatives only when useful.
- Ask one focused question at a time when essential information is missing.

## Completion rule

A feature is complete only when its approved scope is implemented, relevant verification is reported, changed files are summarized, important code is explained concisely, and known limitations are disclosed.

After each feature, stop and ask for my approval before proceeding.
