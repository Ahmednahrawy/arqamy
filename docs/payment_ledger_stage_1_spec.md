# Payment ledger Stage 1 implementation specification

## Stable payment and cash-event identities

This Stage 1 schema does not create payment or cash-event tables. When those
tables are introduced, `payment_id` will identify the stable payment
obligation, and `cash_event_id` will identify the single physical cash event
for that obligation. The relationship is one-to-one: one payment identity has
exactly one cash event, while that event may have multiple immutable versions.

Every cash-event version must store both IDs. A payment identity must not be
reused for a genuinely new physical movement; Method B creates a new
`payment_id` and `cash_event_id`. Method A corrections retain both original
identities.

`cash_event_heads` will use `cash_event_id` as its primary key and reference a
version through a composite key containing both `cash_event_id` and
`payment_id`. This prevents a head from selecting a version belonging to a
different payment identity.

Amounts on reversal transactions are positive integer minor units and describe
the reversal operation. They are distinct from the effective recognized amount
on the resulting cash-event version. A version's effective amount must never be
derived by treating a reversal transaction amount as that version's
recognized amount.
