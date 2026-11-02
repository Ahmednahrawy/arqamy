# Payment ledger Stage 3 implementation contracts

Stage 3 adds append-only payment and cash-event history to the local Drift
database. It does not connect the ledger to invoices or change the existing
SharedPreferences invoice workflows.

## Schema and identity

Schema version 3 adds:

- `payment_identities`: stable payment obligation, including its
  currency-specific account, party, role, financial direction, creator, and
  creation time.
- `cash_events`: the physical-event identity and creator metadata. A unique
  `payment_id` ensures each payment identity has exactly one cash event.
- `financial_transactions`: positive minor-unit payment, payment-reversal, or
  replacement records, with explicit direction, amount, related transaction,
  actor, reason, time, and idempotency key.
- `cash_event_versions`: append-only snapshots containing both identities,
  sequence, operation, physical occurrence and amount, effective recognized
  amount, linked transaction, prior version, idempotency payload, and audit
  metadata.
- `cash_event_heads`: mutable current projection keyed by `cash_event_id`.
  Composite foreign keys require its payment and version to belong to that
  same event and payment identity.
- `reconciliation_cases`: canonical suspense case identity linked to the
  payment, event, account, party, role, and currency.
- `suspense_entries` and `suspense_resolutions`: append-only movements and
  authorized resolution history.

Composite foreign keys enforce account/party/role/currency consistency and
preserve payment/event/version/transaction relationships. Checks enforce
positive or nonnegative minor-unit values, allowed directions and operation
states, and zero physical amount when occurrence is `no`. Supporting indexes
cover transaction event/account timelines, event version sequences, and
suspense case/account queries. Update/delete triggers protect history tables;
only `cash_event_heads` is mutable.

## Operation contracts

Repository mutations run in SQLite transactions. A per-repository queue
serializes operations in-process, while head updates compare the expected
version and revision before advancing; a stale update fails rather than
forking history. Request keys are unique and payload-checked: exact retries
return the recorded result, while reuse with a different payload raises
`IdempotencyConflict`.

- **Original payment:** creates one payment identity, one cash event, the
  initial financial transaction, version 1, and its head atomically.
- **Method A correction:** retains both identities, appends a reversal
  transaction and replacement transaction, appends one correction version,
  and advances the same head. The reversal transaction amount is distinct from
  the new version's effective recognized amount.
- **Method B:** reverses recognition of the old identity and creates a new
  payment identity/event for the new physical movement in one transaction. If
  either operation fails, both roll back.
- **Never occurred:** appends a reversal and zero replacement, then records a
  `no`/zero-physical `void` version. Earlier history is retained.
- **Unknown occurrence:** excluded from confirmed cash totals and reported as
  pending. Resolution to `yes` or `no` appends a version; it does not rewrite
  the original event.
- **Suspense:** balance is derived from immutable creation/increase entries
  less decrease/resolution entries. Decrease and resolution amounts cannot
  exceed the current derived balance. Resolutions retain actor, approver,
  authorization reference, reason, and timestamp.
- **Correction leaving cash with zero recognition:** records the remaining
  physical amount in the event's suspense case rather than losing the
  unexplained cash.

Physical cash and effective recognition reports read only the version selected
by each current head. Historical correction versions therefore are not summed
as separate physical movements. Unknown events have separate pending totals.

## Migration and boundaries

The version 2 to 3 migration creates the eight Stage 3 tables, indexes, and
immutability triggers without rewriting Stage 1/2 records. Fresh databases
create the complete schema directly. Existing invoice tables, models,
SharedPreferences data, and invoice behavior are unchanged.

Stage 3 does not implement invoice allocation/reconciliation, refunds,
customer-credit workflows, legacy invoice migration, UI, or Firebase sync.
