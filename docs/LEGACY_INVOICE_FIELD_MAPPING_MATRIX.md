# Arqamy — Legacy Invoice and Product Field-Mapping Matrix

**Repository:** Ahmednahrawy/arqamy  
**Baseline:** Current main at D4 audit  
**Status:** Design/audit artifact; no mapping implementation authorized  
**Purpose:** Define exactly what the current legacy invoice model contains, what the existing Drift mapper persists, what is only retained as source evidence, and what requires a policy decision before production migration.

---

## 1. Invoice field mapping

| Legacy JSON field | Legacy model / preflight rule | Current Drift destination | Current behavior and D4 requirement |
|---|---|---|---|
| `id` | Required string by preflight; not currently checked for non-empty/trimmed value | `invoices.legacy_invoice_id`; destination `invoice_id` is newly generated | Preserve legacy ID as historical metadata. Generate a new destination ID. Never use legacy ID alone as migration identity. Blank IDs require held classification. |
| `customerName` | Required string; blank value is not currently rejected | No dedicated invoice display-name column; party identity is stored in `party_id` and `party_role`; normalized JSON may retain the original name as supporting evidence | Require an explicit effective party decision and role. The referenced party must exist and have the exact required role at import time; missing parties, missing roles, or mismatched roles keep the occurrence held. Do not create parties or assign/change roles automatically. Owner-approved: preserve the exact original display text in the immutable raw snapshot and retain it in normalized `source_json` as supporting evidence. The resolved `party_id` and `party_role` remain authoritative. Do not add a dedicated invoice column solely for this migration; reconsider only if a separate business requirement needs historical-name search or reporting. |
| `customerId` | Optional string/null by structural parser; current audit flags null as `noCustomerId` | `invoices.party_id` after approved resolution | Treat as a suggestion/reference, not proof of role. Validate party exists and has the approved role at import time. Missing party, missing required role, stale decision, or wrong role remains held for explicit human review; never create a party or assign/change its role automatically. |
| `products` | Required list; each element must be object | One or more `invoice_lines` rows | Preserve source array order as `line_index`. Every line must commit with its invoice and occurrence mapping. Empty list is held by current audit. |
| `totalCost` | Required finite number | `total_minor` plus `legacy_total_value` | Existing planner converts with `Money.fromDouble` (2 decimals, half away from zero) and preserves decimal text. Current audit flags precision beyond 2 decimals, out-of-range, negative/zero, and mismatch with rounded line totals. Production mapping must not silently round a held record. |
| `paid` | Required finite number | `legacy_paid_value` text | Preserve as historical invoice aggregate only. Never synthesize a cash event, payment, allocation, refund, or accounting posting. Current audit flags negative, overpaid, excess precision, and out-of-range values. |
| `rest` | Required finite number | `legacy_remaining_value` text | Preserve as historical invoice aggregate only. Current audit checks consistency with absolute total minus paid. Do not infer physical money movement. |
| `formattedDate` | Required string; semantic format validation is not yet implemented | No current structured mapping; `issued_at` remains unset until date/time and timezone rules are established | Owner-approved policy: preserve the exact original string and hold occurrences with invalid or unrecognized formats. Do not guess locale, date order, timezone, or convert ambiguous dates. Once supported formats and timezone semantics are explicitly established, convert the combined date/time into the existing `issued_at` field. Do not add separate structured date or time columns solely for this migration; reconsider only if a distinct business requirement needs them. |
| `formattedTime` | Required string; semantic format validation is not yet implemented | No dedicated destination field; retain the exact original string in source evidence | Owner-approved policy: preserve the exact original string and hold occurrences with invalid or unrecognized formats. Do not guess timezone or combine date and time by guesswork. Populate `issued_at` only after supported formats and timezone semantics are explicitly established. |
| `invoiceAction` | Current UI requires an action selection, but historical persisted data still requires defensive validation; structurally may be null or contain an unsupported value | `legacy_action` plus normalized `action` enum | Recognized values: purchase = شراء, sale = بيع, storage = تخزين. Owner-approved rule: null, empty, or unrecognized values are held for human review. Preserve the exact original value and emit a stable finding. Never infer an action from customer, products, or amounts, and never apply a default action. |
| `invoiceSerial` | Required string; blank value is not currently rejected | `invoices.invoice_serial` | Preserve as historical serial. Do not impose uniqueness unless separately justified; duplicate serials must not merge occurrences. |

## 2. Product field mapping

| Legacy product JSON field | Legacy model / preflight rule | Current Drift destination | Current behavior and D4 requirement |
|---|---|---|---|
| `name` | Required string; blank value not currently rejected | `invoice_lines.product_name` | Preserve exact source text; define whether blank names are held. |
| `weight` | Required finite number | `quantity_decimal` text | Existing mapper stores `weight.toString()`. Product net weight is `weight - packageWeight × numberPackage`. Owner-approved rule: any negative value is held for human review. Non-negative range/precision limits remain to be defined. |
| `packageWeight` | Required finite number | `package_weight_decimal` text | Existing mapper stores `packageWeight.toString()`. Owner-approved rule: any negative value is held for human review. Non-negative range/precision limits remain to be defined. |
| `numberPackage` | Required integer | `package_count` | Existing Drift column has a non-negative check, but preflight currently checks integer type only, not non-negativity. Owner-approved rule: negative values are held for human review before insert. |
| `price` | Required finite number | `unit_price_decimal` text | Existing mapper stores `price.toString()`. Owner-approved rule: any negative value is held for human review. Non-negative range/precision limits remain to be defined. |
| Computed line total | Not a stored legacy JSON field; model computes `(weight - packageWeight × numberPackage) × price` | `line_total_minor` | Existing planner uses `Money.fromDouble` with 2-decimal half-away-from-zero rounding. Audit compares sum of rounded line totals with invoice total. Any out-of-range result is held. |
| Runtime `lineTotalOverride` | Optional model-only field; not serialized by the legacy invoice JSON writer | No direct migration field | Not a source field in the persisted JSON contract. Do not infer or recreate it during migration. |

## 3. Numeric and date conversion rules currently present

### Money

The current `Money` type:
- uses 2 decimal places;
- rounds half away from zero;
- rejects non-finite values;
- rejects absolute values greater than or equal to 1,000,000,000,000;
- represents money in integer minor units.

The current audit additionally flags:
- invoice total with more than 2 decimals;
- paid with more than 2 decimals;
- rest with more than 2 decimals;
- amount out of range;
- negative paid;
- negative total;
- zero total;
- paid greater than absolute total;
- rest not equal to absolute total minus paid;
- invoice total not equal to the sum of rounded product line totals.

The production migration contract should preserve original decimal text and keep any record requiring rounding or correction held until the owner approves its treatment. The two-decimal currency setting (EGP) is already confirmed for the existing ledger import, but it does not authorize lossy conversion of records flagged by audit.

### Product measurements and prices

Preflight verifies that weight, package weight, and price are finite numeric values, and that package count is an integer. It does not currently enforce non-negative values, measurement precision, or a business-specific upper bound. Those are unresolved validation requirements; do not silently add assumptions during implementation.

### Date and time

The current legacy model stores separate formatted date and time strings. The current mapper does not populate Drift `issued_at`. Owner-approved policy: preserve exact original strings and hold occurrences with invalid or unrecognized formats. Do not guess date format, locale, date order, timezone, or convert ambiguous dates. Populate `issued_at` only after supported formats and timezone semantics are explicitly established. Tests must cover valid, invalid, and ambiguous examples; daylight-saving cases apply if the established timezone makes them relevant.

## 4. Structural validation gaps identified

The current preflight checks required field types, but these values can still pass structural parsing while being semantically suspect:
- empty or whitespace-only invoice ID;
- empty or whitespace-only invoice serial;
- empty or whitespace-only customer name;
- empty or whitespace-only product name;
- negative package count (integer type passes preflight, although Drift rejects it);
- negative weight, package weight, package count, or unit price;
- unsupported measurement precision;
- invalid date/time strings;
- invoice values whose decimal representation is not safely convertible under the approved money policy.

The current invoice audit covers several financial consistency rules, but does not cover all the above product/text/date semantics. These should become explicit stable preflight finding codes before production import. No data should be auto-corrected to bypass a finding.

## 5. Raw evidence and normalized source JSON

The snapshot service stores the exact raw SharedPreferences string and verifies its byte length and SHA-256. Preflight extracts an element fragment for occurrence identity; surrounding whitespace is not part of that fragment, while the whole snapshot remains authoritative.

The existing mapper serializes the decoded invoice model again with `jsonEncode(invoice.toJson())`. That normalized JSON is not byte-for-byte source evidence and may omit unknown keys or original formatting. It must not replace the immutable snapshot or be treated as the authoritative recovery artifact.

Unknown JSON keys are not represented in the current `Invoice` or `Product` model. They remain available only through the raw snapshot unless a separately approved evidence-preservation mechanism is introduced.

## 6. Required owner decisions before mapping implementation

1. Should blank invoice IDs, serials, customer names, or product names always be held? Recommended: yes.
2. What non-negative range/precision limits apply to weight, package weight, package count, and unit price? Negative values are already owner-approved as held for human review; unsupported precision and upper bounds remain open.
3. Which exact date/time formats and timezone semantics are present in representative source values? The hold/preserve/no-guess policy is approved; the formats and timezone required to populate `issued_at` remain to be established.
4. Owner-approved: a party that is missing, lacks the required role, or has a mismatched role keeps the occurrence held for human review. Do not auto-create a party or assign/change a role during migration.
5. Which fields must be represented in structured Drift columns versus retained only in source evidence? At minimum, date/time and original customer display name need an explicit decision if they must be queryable without decoding source JSON.
6. Owner-approved: null, empty, or unrecognized legacy invoice actions are held for human review; never infer or default an action. The current UI's required selection does not remove the need to validate historical persisted data.

## 7. Recommendation

Before D4 schema implementation, agree the unresolved field rules and build a field-level mapping test fixture from representative legacy records. Then bind the approved mapping contract version to the execution run and its idempotency key.

No code, schema, or data changes are authorized by this matrix.

## 8. Owner decision — blank required text fields

**Decision approved by the owner on 2026-11-26: hold for human review.**

The following values must be classified as requiring human review when empty or whitespace-only:
- legacy invoice `id`;
- legacy invoice `invoiceSerial`;
- legacy invoice `customerName`;
- legacy product `name` on any invoice line.

The importer must not invent replacement values, silently trim-and-substitute a different business value, discard the affected field, or import the occurrence as ready. Preserve the exact original value in the immutable source snapshot and emit a stable, field-specific preflight finding. A human correction, if later supported, must be explicit, authorized, attributable, and auditable; it must not mutate the original source evidence.

This decision resolves item 1 in section 6. The other field-mapping decisions remain open.


## 9. Owner decision — negative product values

**Decision approved by the owner on 2026-11-26: hold for human review.**

A source invoice occurrence must be held if any product line contains a negative value in any of these fields:
- `weight`;
- `packageWeight`;
- `numberPackage`;
- `price`.

Preflight must emit a stable, field-specific finding identifying the affected line and field. Do not clamp values to zero, take absolute values, omit the line, or otherwise auto-correct the source. Preserve the exact original values in the immutable source snapshot. A later correction, if supported, must be explicit, authorized, attributable, and auditable without mutating source evidence.

This rule applies before mapping or database constraints, including negative package counts that the current Drift schema would also reject. It does not establish upper bounds, precision rules, or other non-negative product-domain constraints; those remain open. This is a design decision only and does not authorize implementation.


## 10. Owner decision — party and role must already be valid

**Decision approved by the owner on 2026-11-26: hold for human review.**

An invoice occurrence must remain held if its referenced party:
- does not exist;
- does not have the required party role;
- has a role that does not match the invoice action or approved party-resolution decision; or
- no longer matches the effective, current party-review decision at import time.

The migration must not create a missing party, add a missing role, change an existing role, or infer a replacement party automatically. Release from hold requires an explicit, authorized, attributable, and immutable review decision, followed by revalidation immediately before import. The source snapshot remains unchanged.

This decision resolves the party/role policy question in section 6. It does not authorize changes to the existing party-review journal or importer implementation.


## 11. Owner decision — date and time validation

**Decision approved by the owner on 2026-11-26.**

Preserve the exact original `formattedDate` and `formattedTime` strings in the immutable source snapshot. Hold an invoice occurrence when either value uses an invalid or unrecognized format. Do not guess date order, locale, timezone, or automatically convert an ambiguous date/time value. Populate Drift `issued_at` only after the supported source formats and timezone semantics have been explicitly established and covered by tests.

This decision defines the safe handling policy; it does not yet establish the actual source formats or timezone, and it does not authorize implementation.

## 12. Owner decision — invoice action validation

**Decision approved by the owner on 2026-11-26: hold invalid or unrecognized historical values for human review.**

The recognized legacy action values are `شراء` (purchase), `بيع` (sale), and `تخزين` (storage). If `invoiceAction` is null, empty, or contains an unrecognized value, hold the entire invoice occurrence and emit a stable validation finding. Preserve the exact original value in the immutable source snapshot. Do not infer an action from the customer, products, or amounts, and do not assign a default action.

The current application UI requires the user to select an action when creating an invoice. This rule is a defensive check for historical persisted data and alternate, older, malformed, or corrupted records; it does not imply that the current UI permits actionless invoice creation. This is a design decision only and does not authorize implementation.

## 13. Owner decision — original customer display name

**Decision approved by the owner on 2026-11-26.**

Keep `party_id` and `party_role` as the authoritative invoice-party relationship. Preserve the exact original legacy `customerName` in the immutable source snapshot and retain it in normalized `source_json` as supporting evidence. Do not add a dedicated invoice column solely to store this value for the migration. Reconsider a structured column only if a separate business requirement establishes a need for historical-name search or reporting.

This decision does not change party resolution or role validation requirements and does not authorize implementation.

## 14. Owner decision — date/time destination storage

**Decision approved by the owner on 2026-11-26.**

Preserve the exact original `formattedDate` and `formattedTime` strings in the immutable source snapshot. After the supported formats and timezone semantics have been explicitly established and tested, convert the combined value into the existing `issued_at` field. Do not add separate structured date or time columns solely for this migration. Reconsider separate columns only if a distinct business requirement requires them.

This decision does not relax the approved hold policy for invalid or unrecognized formats and does not authorize implementation.

## 15. Owner decision — invoice total must match product line totals

**Decision approved by the owner on 2026-11-26: hold the entire occurrence for human review when the invoice total does not match the sum of its calculated product line totals.**

Preserve the original `totalCost` and every original product-line value exactly in the immutable source snapshot. Do not recalculate or overwrite the invoice total, change line values, omit lines, or silently adjust rounding to force agreement. Emit a stable finding that identifies the invoice-total/line-total mismatch and includes the compared values in the audit report where safely representable. Any later correction, if supported, must be explicit, authorized, attributable, and auditable without mutating the original source evidence.

This policy applies to the migration validation boundary; it does not authorize implementation. The mapping contract must still define the exact comparison arithmetic and precision before implementation, so the same source values produce deterministic findings.

## 16. Owner decision — historical paid and remaining amounts

**Decision approved by the owner on 2026-11-26: hold the entire occurrence for human review when historical payment aggregates fail validation.**

Hold an invoice occurrence if `paid` is negative, `paid` exceeds the absolute invoice total, or `rest` does not equal the absolute invoice total minus `paid`. Preserve the original `totalCost`, `paid`, and `rest` values exactly in the immutable source snapshot and retain their original values as historical aggregates. Do not clamp, cap, recalculate, overwrite, or otherwise silently correct any of them. Emit stable, field-specific or relationship-specific findings identifying the failed condition. Any later correction, if supported, must be explicit, authorized, attributable, and auditable without mutating original source evidence.

These values remain historical invoice aggregates only. They do not establish physical cash movement and must not generate cash events, payments, allocations, refunds, reversals, suspense entries, or accounting postings. This is a policy decision only; it does not authorize implementation.


## 17. Owner decision — zero-value invoice totals

**Decision approved by the owner on 2026-11-26: hold the entire invoice occurrence for human review when `totalCost` is zero.**

Do not assume that a zero-total invoice represents a valid free transaction, and do not replace the value, infer a non-zero amount, or otherwise auto-correct it. Preserve the exact original total and all product-line values in the immutable source snapshot. Emit a stable validation finding identifying the zero total. Any later disposition must be explicit, authorized, attributable, and auditable without mutating original source evidence.

This is a defensive migration validation policy; it does not assert that the current UI permits zero-value invoices. It is design-only and does not authorize implementation.
