# Arqamy Payment Ledger

## Approved Business Decisions — Consolidated Register (1–49)

**Document purpose:** Authoritative business-requirements reference for the Arqamy Payment Ledger architecture and future implementation.

**Source status:** This document consolidates decisions approved during previous planning discussions. It preserves their approved meaning but is not a verbatim transcript of the original conversations.

**Approval status:** Decisions 1–49 have been approved. Approval of these business requirements does not authorize implementation.

---

## Part I — Ledger foundation and historical data

### Decision 1 — Ledger authority

The financial ledger is the authoritative source of financial activity.

Existing invoice fields `paid` and `rest` remain temporarily for backward compatibility but must be derived from ledger records rather than independently edited.

### Decision 2 — Historical payment dates

Migrated historical payments must have an unknown transaction date (`null`) unless a reliable historical date is available.

Display:

- Arabic: مدفوعات سابقة — التاريخ غير محدد
- English: Previous payments — Date unknown

Never infer a payment date from an invoice date or migration date.

### Decision 3 — Negative historical paid values

Legacy invoices with negative `paid` values require manual review.

- Preserve the original values.
- Exclude the records from automatic payment migration.
- Include invoice ID, serial, customer, legacy `paid`, and `rest` in the reconciliation report.

### Decision 4 — Inconsistent historical balances

If legacy `rest` differs from the expected balance calculated from the invoice total and legacy `paid`, the record requires manual review.

Preserve the original values. Do not automatically recalculate or migrate the disputed amount.

### Decision 5 — Migration exceptions

Migrate valid historical invoices and payments.

Quarantine records that fail validation. Mark affected invoices as `migration_pending_review`.

Until reconciliation, legacy `paid` and `rest` must not be treated as ledger-derived verified values.

### Decision 6 — Append-only financial transactions

Payments are immutable and append-only.

Corrections must use reversal and replacement records. A reversal:

- References the original transaction.
- Requires a reason.
- Is immutable.
- Preserves the original transaction.

Payment notes, references, and payment-method corrections must be audited.

### Decision 7 — Payment transaction fields

Payment records must support:

- Unique transaction ID.
- Invoice and customer/supplier link.
- Amount.
- Transaction date/time, nullable for historical migrated entries.
- Optional payment method.
- Reference.
- Notes.
- Transaction type.
- Related transaction ID for reversals.
- Actual record creation timestamp.

Payment methods:

- Cash (نقدي).
- Bank transfer (تحويل بنكي).
- Mobile wallet (محفظة إلكترونية).
- Other (أخرى).

### Decision 8 — No direct payment editing or deletion

Payments cannot be directly edited or deleted.

Corrections use reversal and replacement records.

Notes and references may be edited only with an audit event. Payment-method corrections must also be audited.

Reversal records are immutable.

### Decision 9 — Refunds are separate transactions

Refunds are first-class financial transactions, not payment corrections.

A refund:

- Reduces net recognized funds.
- Increases the related invoice's outstanding obligation when applicable.
- Has its own transaction history.
- Requires a reason.
- References the original payment when applicable.
- Appears separately in reports and payment history.

### Decision 10 — Refund limits

A refund cannot exceed the original payment's remaining refundable amount.

Partial refunds are allowed.

Previous refunds and payment reversals reduce the remaining refundable amount.

An unlinked refund requires a separately authorized business transaction.

### Decision 11 — Overpayments

Overpayments are allowed.

Record the full amount received or paid. Excess funds become customer credit or supplier advance, as appropriate.

Do not automatically assign excess funds to another invoice.

### Decision 12 — Multi-invoice payments

Support one parent payment transaction allocated across multiple invoices.

Each allocation must be separately recorded.

Any unallocated remainder remains customer credit or supplier advance, according to transaction direction and counterparty role.

### Decision 13 — Separate customer credit

Customer credit must be tracked separately for each customer.

It must:

- Never be automatically allocated.
- Be displayed separately from invoice balances.
- Preserve allocation history.
- Never be transferred between customers without an explicit authorized transaction.

### Decision 14 — Refunds from unallocated credit

Refunds from unallocated customer credit are allowed.

They reduce the available customer credit and must record:

- Source.
- Amount.
- Date.
- Reason.

For invoice-linked refunds, respect the original payment's refundable amount.

Allocated funds cannot also be refunded as unallocated credit. Release allocated funds through an allocation reversal first.

### Decision 15 — Allocation rules

Manual allocation is the default.

An optional oldest-invoice-first allocation method may be supported.

Never allocate more than:

- The payment's available funds.
- The invoice's remaining eligible balance.

Any remainder stays as unallocated customer credit or supplier advance.

All allocations and reallocations must preserve their history.

### Decision 16 — Allocation eligibility

Allocations must satisfy all of the following:

- Same customer or supplier account.
- Same currency.
- Eligible invoice type.
- Active invoice status.

Sales invoices are eligible for customer receipts.

Purchase invoices are eligible for supplier payments.

Storage invoices are excluded.

Fully paid invoices cannot receive additional allocations unless a previous allocation is reversed.

Cancelled or deleted invoices are ineligible.

Credit cannot transfer between different customers or suppliers.

### Decision 17 — Reducing invoice totals below allocations

If an invoice total is reduced below its existing net allocations, block the change until the excess allocation is explicitly reversed or otherwise resolved through an approved financial operation.

Never silently create a refund or modify allocations.

### Decision 18 — Increasing invoice totals

Increasing an invoice total is allowed.

Existing allocations remain unchanged. Recalculate the outstanding amount from the new invoice total and existing valid allocations.

### Decision 19 — Reducing fully paid invoice totals

Reducing a fully paid invoice total is blocked until the excess allocation is resolved.

The excess may be:

- Reversed into unallocated customer credit or supplier advance.
- Refunded if money was actually returned.

A refund must represent a real cash movement, not an accounting-only correction.

### Decision 20 — Deleting invoices with financial history

An invoice with payment allocations or financial transactions cannot be permanently deleted.

It may be cancelled or archived while preserving its financial history.

Invoices without financial history may retain deletion behavior, subject to validation.

### Decision 21 — Cancellation with allocations

When cancelling an invoice with allocations:

- Reverse all related allocations.
- Return released funds to the appropriate customer credit or supplier advance.
- Record actual returned money separately as a refund.
- Preserve all transaction and allocation records.

Cancellation completes only after the required financial effects are resolved.

### Decision 22 — Cancellation without payment history

An invoice without payment history may be cancelled.

Preserve it as a cancelled record and exclude it from active balances, outstanding balances, and normal active reports.

It remains accessible through cancelled invoice history.

### Decision 23 — Reopening cancelled invoices

A cancelled invoice may be reopened only if:

- No unresolved financial transactions remain.
- Original invoice data is valid.
- Explicit user confirmation is obtained.

Restore the invoice to active status, recalculate outstanding from its total and valid allocations, and preserve cancellation/reopening history.

### Decision 24 — Permissions

Support the following roles:

**Owner/Admin**

- Full financial permissions.

**Manager**

- May record payments and allocations.
- Refunds and reversals require Owner/Admin approval.

**Staff**

- May view permitted information.
- May record payments only when explicitly permitted.
- Cannot independently reverse, refund, or modify financial records.

The initial single-user version gives the Owner full permissions by default.

The architecture must support future role-based permissions.

### Decision 25 — Approval workflow

Manager requests for actions requiring Owner approval must include:

- Requested action.
- Amount.
- Reason.
- Related transaction or invoice.

The original financial records remain unchanged while approval is pending.

The transaction is recorded only after approval.

Record requester, approver, decision, timestamps, and reason.

### Decision 26 — Permanent audit trail

Maintain an audit trail for:

- Payments.
- Refunds.
- Reversals.
- Adjustments.
- Allocations and reallocations.
- Cancellation and reopening.
- Approval decisions.
- Changes to payment notes, references, and methods.
- Customer-credit changes.

Audit entries must record the action, affected IDs, previous and new values where applicable, actor, timestamp, and reason.

Audit history must be immutable through normal application operations.

### Decision 27 — Transaction dates and creation timestamps

New payments, refunds, reversals, and adjustments require an explicit transaction date/time.

Default to the device's current local date/time.

Authorized users may enter a past transaction date.

Store the actual record creation timestamp separately.

Never silently change transaction dates.

Migrated historical transactions with unknown dates retain `null`.

### Decision 28 — Currency handling

Every invoice and customer/supplier account has an explicit currency.

Allocations are permitted only between records using the same currency.

Customer credit and supplier advances remain separated by currency.

Never combine balances from different currencies.

Future currency conversion must be an explicit, auditable exchange transaction with a recorded rate and related amounts.

Preserve the original currency of historical invoices. Never assume a currency during migration.

### Decision 29 — Monetary precision

Use decimal-safe monetary calculations.

Store amounts using the appropriate currency minor-unit precision or another explicitly reviewed decimal representation.

Apply consistent rounding rules.

Preserve historical monetary values. Precision discrepancies must be flagged for manual review rather than silently rounded.

### Decision 30 — Financial reports

Provide reports covering:

1. Invoice financial position: total, allocated payments, refunds, reversals, and outstanding amount.
2. Customer statement: payments, allocations, unallocated credit, refunds, and running balance.
3. Cash movement: actual receipts and refunds by date, method, and currency.

Allocation records are not cash receipts.

Allocation reversals are not cash refunds.

Only actual receipts and refunds affect physical cash movement.

Support date and currency filters. Preserve access to cancelled and historical financial records.

---

## Part II — Adjustments, migration, backup, and synchronization

### Decision 31 — Financial adjustments

Adjustments are allowed only for documented purposes such as:

- Accounting corrections.
- Opening balances.
- Verified historical discrepancies.

Each adjustment must include:

- Amount.
- Currency.
- Date.
- Reason.
- Affected customer, supplier, or invoice.

Only Owner/Admin may authorize adjustments.

Adjustments must not bypass normal payment, refund, reversal, or allocation workflows.

Record the previous and new financial position in the audit trail.

Adjustment records are immutable.

### Decision 32 — Opening customer and supplier balances

Migrate verifiable historical invoices and payments through the normal migration process.

Verified remaining historical balances may be represented as separate opening-balance adjustments.

Requirements:

- Owner/Admin confirmation.
- Recorded reason.
- Separate identification from normal payments.
- No effect on actual cash movement.
- Preserve original legacy data.

Unverifiable balances remain pending reconciliation.

### Decision 33 — Reconciliation screen

Provide a reconciliation screen for unresolved historical records.

Each case must show:

- Invoice ID.
- Invoice serial.
- Customer/supplier.
- Legacy `paid`.
- Legacy `rest`.
- Reason for review.

Owner/Admin may:

- Confirm and migrate a verified amount.
- Record an opening-balance adjustment.
- Correct through an authorized reversal/adjustment process.
- Leave the record pending.

All decisions must be audited. Preserve original legacy values.

### Decision 34 — Backup and restore

Provide:

- Automatic backup before migration.
- Automatic backup before major financial schema changes.
- Manual Owner/Admin backup and restore.

Backups must include all financial data and audit history.

Validate integrity before restoration and require confirmation before overwriting existing data.

Test the restore process before release.

Migration backups must be retained separately.

### Decision 35 — Offline-first architecture

The ledger must operate fully offline.

Use local-first persistence with future Firebase synchronization when online.

Requirements:

- Globally unique IDs.
- No silent financial conflict overwrites.
- Preserve transaction history across devices.
- Explicit resolution of financial conflicts.
- Treat records as synchronized only after server confirmation.

### Decision 36 — Synchronization conflicts

Independent transactions must merge by unique IDs.

Never discard a valid payment merely because another device synchronized first.

Recalculate financial balances from the combined valid ledger.

Detect conflicting edits.

Owner/Admin must review conflicts. Preserve both versions and record the resolution.

### Decision 37 — Overpayment representation

When a customer pays more than a sales invoice's outstanding amount:

- Allocate only up to the invoice's eligible total.
- Keep excess as separate unallocated customer credit.
- The invoice outstanding becomes zero.
- Do not display a negative invoice balance.
- Do not double-count the excess as both invoice settlement and customer credit.

Apply the equivalent principle to supplier advances.

### Decision 38 — Historical currency confirmation

Require manual currency confirmation for each legacy invoice before migration.

Never assume EGP or another currency.

Unconfirmed invoices remain pending reconciliation and are excluded from verified financial calculations.

### Decision 39 — Stable customer identity

Use stable, unique customer IDs.

All invoices and financial transactions must reference those IDs rather than relying on customer names.

Customer renaming must not break financial history.

Ambiguous historical customer mappings require manual confirmation.

### Decision 40 — Unresolved legacy balances

Keep unresolved historical balances in a separate **Pending Reconciliation** section.

They must:

- Be excluded from verified customer/supplier balances.
- Be excluded from authoritative financial reports.
- Preserve original legacy values.
- Remain accessible for review.

### Decision 41 — Payment reversal

Support both partial and full payment reversals.

Each reversal must:

- Reference the original transaction.
- Include a reason.
- Be immutable.
- Preserve transaction history.

A replacement payment is a separate transaction.

### Decision 42 — Customer balance presentation

Display Customer Debt and Customer Credit separately.

Never combine them into one signed balance or automatically offset one against the other.

### Decision 43 — Offline multi-device allocations

Allow provisional offline allocations.

Validate them when synchronization occurs.

If conflicts occur:

- Preserve both versions.
- Refer the conflict to Owner/Admin.
- Record the resolution.
- Never silently overwrite or discard a financial record.

### Decision 44 — Future role payment permissions

Owner/Admin, Manager, and Staff may record payments and allocations if explicitly permitted by their role permissions.

Staff cannot independently reverse, refund, or modify financial records.

The initial release remains Owner-only with full permissions by default.

### Decision 45 — Offline payment recording

Allow payments to be recorded fully offline.

Save locally using globally unique IDs and mark them **Pending Synchronization**.

Synchronize when online.

Preserve transactions if synchronization fails.

Clearly distinguish locally saved transactions from server-confirmed transactions.

---

## Part III — Transaction direction and cash-event corrections

### Decision 46 — Support both financial transaction directions

The ledger must support both directions:

**Customer receipts against sales invoices**

- Money received from customers.
- Cash inflow.
- Settles customer receivables.

**Supplier payments against purchase invoices**

- Money paid to suppliers.
- Cash outflow.
- Settles supplier payables.

Customer refunds are cash outflows.

Supplier refunds are cash inflows.

The system must explicitly model:

- Financial obligation.
- Invoice allocation/settlement.
- Actual cash movement.

Storage invoices remain excluded from payment allocation eligibility.

### Decision 47 — Two methods for correcting payment amounts

Support both correction methods.

**Method A — Correct an existing physical cash event**

When correcting an incorrectly recorded amount for an existing physical cash event:

- Preserve the original transaction.
- Append an immutable reversal/correction record with a reason.
- Append a replacement transaction linked to the same physical cash-event identity.
- Make the replacement the effective recognized version.
- Do not count the replacement as a second physical cash movement.
- Report the corrected event once at its effective amount.

**Method B — Reverse and record a genuinely new physical event**

Use this method only when new physical money actually moves:

- Preserve and reverse the original transaction.
- Create a new independent cash-event identity.
- Record the new physical movement under that new identity.
- Count the new event separately.

If original money physically moved and was subsequently returned, record an actual refund. Do not represent the return as a non-cash reversal.

Apply both methods to customer receipts and supplier payments, with the appropriate cash direction.

The architecture must distinguish:

1. Immutable transaction history.
2. Effective recognized value of a physical cash event.
3. Actual physical cash movement.

Never blindly sum every historical transaction version.

Preserve audit history, correction reasons, links, idempotency, and protection against duplicate cash movements.

### Decision 48 — Upward and downward Method A corrections

Method A must support corrections in either direction.

**Downward correction example**

- Original recorded receipt: 1,000.
- Actual physical receipt: 800.
- Preserve the original 1,000 transaction.
- Append an auditable correction record for the difference.
- Append a replacement transaction of 800 under the same `cash_event_id`.
- Set 800 as the sole effective event amount.
- Report one cash inflow of 800.

**Upward correction example**

- Original recorded receipt: 800.
- Actual physical receipt: 1,000.
- Preserve the original 800 transaction.
- Append an auditable correction record for the difference.
- Append a replacement transaction of 1,000 under the same `cash_event_id`.
- Set 1,000 as the sole effective event amount.
- Report one cash inflow of 1,000.

Apply the same logic to supplier payments, with cash outflow direction.

The correction changes the recognized value of the same physical event. It does not invent another physical cash movement.

### Decision 49 — Zero-value replacement when the original event never occurred

If investigation confirms that the original physical cash event never occurred:

- Preserve the original transaction.
- Append an immutable correction record with the reason.
- Append a zero-value replacement under the same `cash_event_id`.
- Mark the cash event as **Voided**.
- Set its effective amount to zero.
- Report zero cash movement for that event.

Do not create a refund.

Do not create a new physical cash event.

Do not treat the voiding operation as a physical cash movement.

Preserve the entire correction and audit history.

---

## Governance and implementation status

This register is the consolidated reference for the Arqamy Payment Ledger's approved business requirements.

Future architecture specifications, database schemas, migration plans, business rules, test matrices, and implementation phases must be checked against all 49 decisions.

If a technical design cannot satisfy a decision, report the conflict and request clarification rather than silently changing the requirement.

**Approval of this register does not authorize coding, database migration, package changes, or modification of existing application data. Implementation requires a separate explicit approval after architecture review.**
