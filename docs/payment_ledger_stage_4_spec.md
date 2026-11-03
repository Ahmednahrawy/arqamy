# Payment ledger Stage 4A schema contract

Stage 4A advances the local Drift database from schema version 3 to version 4.
It adds persistence structures for future allocation and refund repositories;
it does not implement those repositories or connect them to the existing
SharedPreferences invoice workflow.

## Allocation history

`invoice_allocations` stores immutable positive integer minor-unit allocations
with globally unique allocation IDs, payment and invoice IDs, each side's
financial account ID, party/role/currency, idempotency key and request
fingerprint, optional actor/reason, origin device, optional conflict group, and
creation time. Composite foreign keys independently bind the payment account
to its payment identity and the invoice account to its invoice. Account IDs are
not required to match one another.

The shared party, role, and currency columns must match both identities.
An insert trigger permits only customer/incoming-payment/sale and
supplier/outgoing-payment/purchase combinations and requires the invoice's
latest lifecycle state to be active. Storage and unknown actions are rejected.
`invoices_identity_for_allocations` supplies the invoice composite unique key
for this relationship, including on databases upgraded from v3.

`allocation_reversals` records immutable positive partial or full reversal
amounts linked to an allocation. `allocation_status_history` stores append-only
status versions with per-allocation sequence, prior-version link, idempotency
key, request fingerprint, actor/reason, and timestamp. Only these statuses are
allowed: `provisional`, `server_confirmed`, `rejected`, and `conflict_pending`.

The schema preserves each allocation's origin device and optional conflict
group, so competing offline records can coexist. It does not declare a
provisional or conflict-pending record globally confirmed. Future repositories
derive local-effective and globally-confirmed totals separately:

| Status | Local-effective | Globally confirmed |
|---|---:|---:|
| `provisional` | Yes | No |
| `server_confirmed` | Yes | Yes |
| `rejected` | No | No |
| `conflict_pending` | Yes | No |

Allocation reversals must be applied to both views. The schema stores history;
it does not calculate balances or enforce cumulative allocation/reversal caps.
Those checks, invoice-total reduction guards, and reconciliation of offline
conflicts must be performed transactionally by the future repository.

## Refund identity and outcomes

`payment_refunds` is the immutable refund commitment and source relationship.
It links the original payment and cash event to a distinct refund payment and
cash event, records the positive amount and currency, both payment account IDs,
an optional invoice and invoice account, idempotency and request fingerprint,
actor/reason, and creation time. Composite foreign keys enforce matching party,
role, and currency independently on the original payment, refund payment, and
optional invoice. Different financial account IDs are allowed. A trigger
requires opposite financial directions and invoice/action compatibility.

Invoice-linked refunds additionally use
`refund_allocation_reversals` to retain links to the allocation reversals for
that invoice and original payment. The future repository must atomically
require those reversals to total the refund amount. Reversals reduce invoice
net paid and increase outstanding; refund records must not reduce invoice net
paid a second time. Unallocated-credit or supplier-advance refunds have no
invoice and do not alter allocation history.

Physical refund outcome is not duplicated in a second status table. It is
derived from the refund's existing Stage 3 cash-event head and its selected
version. Unknown/pending outcomes retain the refund commitment and reserve its
amount; confirmed no-occurrence releases the reservation and has zero physical
movement; confirmed physical refund remains counted against the original
payment's refundable limit. A refund recognition reversal without cash return
does not restore ordinary credit, advance, or refundable availability; the
existing Stage 3 suspense mechanism represents the unresolved physical
position.

The v4 `financial_transactions` definition admits the `refund` type.
Refund creation, refundable limits, pending-commitment reservations,
allocation reversal coordination, and the effects of recognized reversals
remain transaction-level responsibilities for future repositories.

## Invoice lifecycle

`invoice_lifecycle_events` is append-only and stores invoice ID, sequence,
state (`active`, `cancelled`, or `deleted`), prior event, idempotency key,
request fingerprint, actor/reason, and timestamp. Sequence triggers require
contiguous predecessor links. Ledger invoices are not physically deleted to
remove financial history. The allocation insert trigger checks the latest
lifecycle state; lifecycle transitions and their interaction with existing
allocations must be validated by future repository operations.

## Migration contract

The v3-to-v4 migration is transactional. SQLite foreign-key enforcement is
disabled before the transaction and restored afterward. Because
`financial_transactions` is referenced by both its own related-transaction
foreign key and `cash_event_versions`, the migration snapshots and rebuilds
`cash_event_heads`, `cash_event_versions`, and `financial_transactions` in
dependency order. It restores every row, then creates the v4 tables, indexes,
and triggers and checks `PRAGMA foreign_key_check` before commit. A failure
rolls back the rebuild and schema additions; schema version advances only after
the migration succeeds. Append-only triggers on rebuilt v3 tables are recreated.

The migration does not read or modify `saved_invoices`, infer legacy identity,
or assign missing party, currency, dates, or minor-unit values. Existing
invoice, customer, and supplier workflows remain unchanged.

## Explicitly deferred

Stage 4A does not implement allocation/reversal/refund repositories, balance
projections, cross-device synchronization, UI, app startup wiring, or legacy
invoice migration. Atomic available-funds, outstanding-amount, cumulative
reversal, refund-commitment, and concurrent-write guards must be implemented
and tested with those future transactional operations.
