# Arqamy — Project Audit and Remediation Status

|                             |                                                                                                                                                       |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Repository**              | `Ahmednahrawy/arqamy` (public)                                                                                                                        |
| **HEAD reviewed**           | `16e049ec23f5f056740d66023d3d5f682c3d5d7c` — `feat(orderscreen): implement invoice discount functionality` (2026-11-26)                               |
| **Original audit baseline** | `fa56a7c` (2026-11-23). The full original findings text is preserved in Git history at blob `6139c60a8acdb0c8a2ff0cb2d6d80d720d25d738`.               |
| **Previous status refresh** | 2026-11-25, against `8ab55c7`                                                                                                                         |
| **App version**             | `1.0.4+22` (`pubspec.yaml`)                                                                                                                           |
| **Review type**             | Static re-audit of the code and docs on `main` through the GitHub repository. Nothing was built, run or tested for this review.                       |
| **Documentation change**    | Replaces the 2026-11-23 baseline text with a finding-by-finding status against HEAD. Original finding IDs are kept so older references still resolve. |

---

## 1. Summary

The two critical findings from the baseline are no longer open in code:

- **P0-1 (invoice history destroyed on first save after cold start)** is mitigated. Every mutation loads storage first and the app loads invoices before showing the main UI.
- **P0-2 (release-signing configuration)** is hardened in code. The **key-compromise incident itself is not closed** (see §4).

The main remaining risks are now:

1. **The production invoice store is still one unversioned JSON blob** in SharedPreferences (`saved_invoices`) with no per-record recovery. Since the cold-start fix, a single malformed record makes loading fail closed. That prevents data loss, but it also leaves the startup retry screen as the only outcome, with no way to skip or repair the bad record (P1-1, P1-2).
2. **Invoice input validation is incomplete.** Negative or oversize business values are still possible, and the `.abs()` in `calculateOutstandingBalance` is still there (P1-3).
3. **Customers are still keyed by name for normal invoice creation.** New invoices never receive a `customerId` (P1-4).
4. **Release and privacy hygiene** items remain open: `AD_ID` permission, Android auto-backup, the iOS identity, unused dependencies, Firebase initialized but unused.
5. **CI runs analyze and test only.** No format check, no Android or Web build.

The Drift ledger is no longer dead code, but it is also not the invoice store. Its migration is designed and partly implemented (see §5).

### Status counts (23 tracked findings: 2 P0, 7 P1, 14 P2)

| Status                               | IDs                                                          |
| ------------------------------------ | ------------------------------------------------------------ |
| Resolved in code (2)                 | P1-7, P2-7 (one cosmetic leftover)                           |
| Mitigated, residual work remains (4) | P0-1, P0-2 (config only; incident open), P2-3, P2-10         |
| Partially addressed (7)              | P1-3, P1-6, P2-4, P2-8, P2-9, P2-11, P2-14                   |
| Open, unchanged (10)                 | P1-1, P1-2, P1-4, P1-5, P2-1, P2-2, P2-5, P2-6, P2-12, P2-13 |

---|---|
| Resolved in code | P1-7, P2-7 (one cosmetic leftover) |
| Mitigated, residual work remains | P0-1, P0-2 (config only; incident open), P2-3, P2-10 |
| Partially addressed | P1-3, P1-6, P2-4, P2-8, P2-9, P2-11 |
| Open, unchanged | P1-1, P1-2, P1-4, P1-5, P2-1, P2-2, P2-5, P2-6, P2-12, P2-13, P2-14 |

---

## 2. Finding status against HEAD

Legend: **Resolved** = fixed as described · **Mitigated** = main risk removed, residual work noted · **Partial** = some of the fix exists · **Open** = no change found.

| ID        | Original finding                                                    | Status                                 | Evidence at HEAD                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| --------- | ------------------------------------------------------------------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **P0-1**  | Invoice history destroyed on first save after cold start            | **Mitigated**                          | `InvoiceProvider` calls `_ensureInvoicesLoaded()` inside `_withInvoiceMutationLock` before `saveInvoice`, `updateInvoice`, `deleteInvoice`, `restoreBackup` and `assignCustomerIds`. `AppBootstrap` loads invoices before `MyApp` is shown (`lib/main.dart`). **Residual:** `_saveInvoicesToStorage` itself has no `_invoicesLoaded` guard (safety depends on every caller going through `_ensureInvoicesLoaded`), and there is no previous-blob copy before each write. |
| **P0-2**  | Release signing key and password public                             | **Mitigated (code) / Open (incident)** | `android/app/build.gradle.kts` no longer falls back to debug signing; it requires `storeFile`, `storePassword`, `keyAlias`, `keyPassword`, an existing keystore, and fails `assembleRelease` and `bundleRelease` otherwise. `storeFile` may be relative or absolute. Key rotation confirmation and history purge remain pending; see `docs/SECURITY_REMEDIATION_STATUS.md`.                                                                                              |
| **P1-1**  | Persistence is one unversioned JSON blob, no validation or recovery | **Open**                               | Storage is still a single `saved_invoices` string. `_loadInvoicesFromStorage` maps every entry with `Invoice.fromJson`; one failure throws and fails the whole load. No version envelope, no per-record skip, no previous-blob copy. **Changed risk:** the load failure now blocks startup behind a retry screen instead of silently overwriting data.                                                                                                                   |
| **P1-2**  | `Invoice.fromJson` trusts input                                     | **Open**                               | `lib/features/orderscreen/data/models/invoice.dart`: `id`, `customerName`, `totalCost`, `paid`, `rest`, dates, serial, product fields are still assigned straight from dynamic JSON. Only the newer optional fields (`subtotalCost`, `discount`) are parsed defensively.                                                                                                                                                                                                 |
| **P1-3**  | Invalid amounts and quantities accepted                             | **Partial**                            | `product_input_form.dart` now rejects a line whose `netWeight * price` cannot be represented as `Money`, and `Money` rejects NaN and huge values. Still open: validators only check that the text parses, so negative weight, price and package values are not rejected; `calculateOutstandingBalance` still applies `.abs()` to the total; paid is not compared with the total. Discount input has its own validation (percent range, cannot exceed subtotal).          |
| **P1-4**  | Customer identity never assigned                                    | **Open for normal use**                | `Orderscreen._buildInvoice` still does not set `customerId`. The model, `withCustomerId`, `assignCustomerIds`, the Drift customer registry and the Settings "Link customers" workflow exist, but new invoices are still created unlinked.                                                                                                                                                                                                                                |
| **P1-5**  | iOS target cannot ship                                              | **Open**                               | `ios/Runner/Info.plist` still has `CFBundleDisplayName` "My Hand", `CFBundleName` "my_hand", landscape orientations, and no `NSPhotoLibraryUsageDescription`. (Bundle ID, deployment target and privacy manifest were not re-checked.)                                                                                                                                                                                                                                   |
| **P1-6**  | ~4,000 LOC of ledger code dead in production                        | **Partial / changed**                  | The ledger is used by `CustomerLinkingService` and `LedgerImportService`, reached from Settings; the ledger import and customer-link tiles are shown with debug options (`showDebugOptions: kDebugMode`). It is still not the invoice store, and the invoice provider still reads and writes SharedPreferences. The decision to adopt Drift is made and documented (`docs/DEVELOPMENT_PLAN.md`, `docs/DRIFT_MIGRATION_DESIGN.md`); the migration is not complete (§5).   |
| **P1-7**  | No app-level initialization phase                                   | **Resolved**                           | `AppBootstrap` wraps `MyApp`, loads invoices first, and shows a loading state and retry screen.                                                                                                                                                                                                                                                                                                                                                                          |
| **P2-1**  | Invoice serials can collide                                         | **Open**                               | `_generateInvoiceSerial()` in `order_screen.dart` is still second-precision local time with no uniqueness check.                                                                                                                                                                                                                                                                                                                                                         |
| **P2-2**  | Invoice date cannot be set at creation                              | **Open**                               | `selectedDate` is still `DateTime.now()` at widget construction; there is no date picker. Dates are still stored as formatted strings (`formattedDate`, `formattedTime`).                                                                                                                                                                                                                                                                                                |
| **P2-3**  | Debug prints and listener leak                                      | **Mitigated**                          | Remaining `print(...)` calls found in `lib/` are guarded by `kDebugMode`. A `debugPrint('Selected Product…')` debug line remains in `product_input_form.dart`. **Not re-verified:** the focus listener registered inside `build` in `customer_name.dart`.                                                                                                                                                                                                                |
| **P2-4**  | Non-functional settings entries                                     | **Partial**                            | Privacy and Help now open screens. Profile, Notifications and Logout still have empty `onTap` handlers (`settings_screen.dart`).                                                                                                                                                                                                                                                                                                                                         |
| **P2-5**  | `AD_ID` permission without ads                                      | **Open**                               | `com.google.android.gms.permission.AD_ID` is still in `AndroidManifest.xml`.                                                                                                                                                                                                                                                                                                                                                                                             |
| **P2-6**  | PII unencrypted and auto-backed up                                  | **Open**                               | No `android:allowBackup` setting in the manifest; invoice data remains plaintext in SharedPreferences; backups are plaintext JSON.                                                                                                                                                                                                                                                                                                                                       |
| **P2-7**  | Fragile release build configuration                                 | **Resolved** (cosmetic leftover)       | Debug-signing fallback removed; keystore path no longer hardcoded in Gradle. The template `TODO: Specify your own unique Application ID` comment is still in `build.gradle.kts`.                                                                                                                                                                                                                                                                                         |
| **P2-8**  | CI does not test or build                                           | **Partial**                            | `.github/workflows/ci.yml` now runs on pushes to `main` and on pull requests with `flutter analyze` and `flutter test` (Flutter 3.50.1, concurrency group, read-only permissions). Still missing: format check, Android build, Web build. `dart.yml` (manual iOS build) is unchanged, uses `actions/checkout@v3`, and still overwrites release tag `v1.0`.                                                                                                               |
| **P2-9**  | Tests miss the startup path                                         | **Partial**                            | Startup and retry tests exist (`test/app_bootstrap_test.dart`) and provider tests were updated. Current test count was 362 at the D3.2 baseline per `docs/finished_tasks.md`; coverage was **not** recomputed.                                                                                                                                                                                                                                                           |
| **P2-10** | Duplicated canonical values and helpers                             | **Mitigated**                          | `InvoiceActionL10n` still carries a second copy of the stored strings, but `test/invoice_action_test.dart` now asserts the constants and list match `InvoiceAction`. **Correction to the baseline:** `lib/core/helpers/helper_date_price.dart` is not unused; `order_screen.dart` imports it (`Utils.formatDate`). The `$` prefix finding was not re-checked.                                                                                                            |
| **P2-11** | WhatsApp sharing supports one package                               | **Partial**                            | `MainActivity.kt` now tries `com.whatsapp`, then `com.whatsapp.w4b`; the manifest `<queries>` lists both. Still open: no generic share-sheet fallback; the channel name is still hardcoded in Kotlin and Dart.                                                                                                                                                                                                                                                           |
| **P2-12** | Dependency set nonstandard and partly unused                        | **Open**                               | `http`, `permission_handler`, `google_fonts` and `cupertino_icons` have no imports in `lib/`. `cupertino_ui: any` is still unpinned. `description` is still "A new Flutter project." `file_picker` is now used (`backup_file_picker.dart`) and is a caret range (`^13.4.1`), not the exact pin recorded in the handoff. Others (`url_launcher`, `in_app_update`, `dropdown_search`, `flutter_screenutil`, `shared_preferences_android`) were not re-counted.             |
| **P2-13** | Firebase initialized but unused                                     | **Open**                               | `Firebase.initializeApp` still runs at startup in `lib/main.dart`, errors are only `debugPrint`ed, and `lib/firebase_options.dart` is tracked in a public repository.                                                                                                                                                                                                                                                                                                    |
| **P2-14** | Repository and documentation hygiene                                | **Partial**                            | `docs/` now holds real design and status documents. Still open: `README.md` is the default Flutter template (title `my_hand`); no `LICENSE` or `CHANGELOG.md` in the repository root; stale branches (nine ordinary branches listed in `docs/SECURITY_REMEDIATION_STATUS.md`; PRs #1 and #2 are open); the `v1.0` tag is overwritten by `dart.yml`.                                                                                                                      |

---

## 3. New findings since the baseline

### N-1 — Planning documents lag `main`

`docs/DEVELOPMENT_PLAN.md` and `docs/finished_tasks.md` state baseline `271d330`. `main` has since gained: atomic and validated migrations with probe tests, the unified `BackupFilePicker`, the approved D4 schema v8 vocabularies, three approved migration policies, and invoice discounts. None of these is reflected in the "finished" list or the current-architecture section. The plan also names the Drift schema as version 7. The code has moved on: the D4 execution-journal schema v8 was added on 2026-11-26 (`e7db948`, then `e801c85` gating its creation on the v8 target), with a v7-to-v8 migration test (`test/core/database/app_database_d4_v7_v8_migration_test.dart`). An earlier draft of this audit wrongly said v8 was not in the code, because a code-search index was out of date.

### N-2 — Android backup picker copies customer data into the cache directory

`MainActivity.kt` (`copyPickedFileToCache`) writes the chosen backup to `cacheDir/picked-<name>`. No cleanup was found in `MainActivity.kt`. **Not verified:** whether `BackupFilePicker` or the backup services delete the file after restore. Backups contain customer names and amounts, so a leftover copy is a privacy concern. Verify and delete after use.

### N-3 — Discounts add persisted fields that other documents may not cover

The discount feature adds optional `subtotalCost` and `discount` fields to the invoice JSON (`Invoice.toJson`), written only when a discount exists. `totalCost` is the payable total. **Not verified:** whether `docs/LEGACY_INVOICE_FIELD_MAPPING_MATRIX.md` and the D4 mapping contract account for these fields. They should be confirmed before the importer mapping is finalized.

### N-4 — Ledger concurrency tests emit Drift "multiple databases" warnings

Already tracked in `docs/finished_tasks.md` ("Known follow-up"). Not reproduced here. They must be investigated, not suppressed.

---

## 4. Security status

The signing-key incident remains **open**. Code-side hardening is merged (PR #5, PR #6). Still pending, in order:

1. Google Play confirmation that the replacement upload key is active.
2. A release build verified against the replacement key.
3. A reviewed history-cleanup plan, executed only with explicit approval, preserving open-PR work.

Do not rewrite history while the reset is pending. Full sequence and safety rules: `docs/SECURITY_REMEDIATION_STATUS.md` (last reviewed 2026-11-25).

---

## 5. Data-store and migration status

- **Operational invoice store:** SharedPreferences key `saved_invoices` (single JSON array).
- **Drift:** schema version 8 in code (the D4 execution-journal tables were added on 2026-11-26); holds the payment ledger, the party/customer registry, the party-review journal and the D4 journal. It is not the operational invoice store.
- **Next steps after the v8 schema:** per `docs/DEVELOPMENT_PLAN.md`, the independently exportable snapshot and restore procedure, the occurrence-key importer, reconciliation, the Drift-backed invoice repository and the cutover. Importer, export/restore, production migration and cutover are explicitly **not** authorized yet.
- Migration rules that constrain related work (from `docs/DEVELOPMENT_PLAN.md`): never treat duplicate legacy IDs as unique; never synthesize cash events or allocations from invoice-level `paid`/`rest`; no uncontrolled dual-write between SharedPreferences and Drift.

---

## 6. Not re-verified in this review

These were not recomputed and should not be quoted as current:

- Line coverage (73.6% at `fa56a7c`) and per-file coverage.
- Test count at HEAD (362 at `271d330`) and the `flutter analyze` result at HEAD.
- The GitHub Actions result for `16e049e`.
- `pubspec` dependency freshness (`flutter pub outdated`).
- Behaviour on devices (WhatsApp sharing on Android 11+, file picker on different Android versions).
- `docs/DRIFT_MIGRATION_DESIGN.md`, the field-mapping matrix, and the two journal design documents (not read for this review).
- The startup error and retry screen's localization (previously hardcoded English).

---

## 7. Suggested order of work

This list only orders the open findings above. It authorizes nothing; schema, migration and data changes still need separate approval per `docs/DEVELOPMENT_PLAN.md`.

1. **Close the signing incident** (§4), as Google's confirmation arrives.
2. **Make the invoice store recoverable:** defensive `Invoice.fromJson` and per-record handling (P1-2, P1-1). This reduces the new startup-blocking risk. Coordinate with the D4 work, which also reads this store.
3. **Validate amounts at the form** and remove the `.abs()` (P1-3).
4. **Assign `customerId` at invoice creation** (P1-4), after the customer-identity policy is final.
5. **Privacy and release hygiene:** `AD_ID`, `allowBackup`, backup cache cleanup (N-2), iOS identity, Firebase decision (P2-5, P2-6, P1-5, P2-13).
6. **CI:** add format check and Android build (P2-8).
7. **Housekeeping:** README, LICENSE, CHANGELOG, unused dependencies, stale branches, plan and finished-task docs (N-1, P2-12, P2-14).

---

## 8. Method

Reviewed by reading `main` at `16e049e` through the GitHub repository connector: `android/app/build.gradle.kts`, `AndroidManifest.xml`, `MainActivity.kt`, `ios/Runner/Info.plist`, `pubspec.yaml`, `.github/workflows/*`, `lib/main.dart`, `invoice_provider.dart`, `invoice.dart`, `order_screen.dart`, `product_input_form.dart`, `settings_screen.dart`, `README.md`, the listed `docs/` files, the latest 30 commits, and open pull requests; plus targeted code searches for imports, `print(` and `InvoiceActionL10n`. No source files were modified.
