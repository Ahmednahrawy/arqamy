# Arqamy — Full Project Audit

| | |
|---|---|
| **Repository** | `Ahmednahrawy/arqamy` (public) |
| **Commit** | `fa56a7c` — "Add optional customerId to invoices, preserved by edit and backup" (2026-11-23) |
| **App version** | `1.0.4+22` (`pubspec.yaml`) |
| **Platforms** | Android, iOS, Web, Windows, macOS, Linux scaffolding |
| **Code size** | 67 hand-written Dart files in `lib/` (~12.0k LOC), 24 test files (~13.6k LOC), plus a generated Drift schema |
| **Method** | First-hand source review, `flutter analyze`, `flutter test`, `flutter test --coverage`, `flutter pub outdated`, git history/object inspection, Android/iOS config review |
| **Changes made** | None. This report (`docs/AUDIT.md`) is the only file added; the working tree is otherwise unchanged. |

---

## 1. Executive summary

The app is a working Arabic-first invoice/POS tool with a genuinely good foundation in places: a correct fixed-point `Money` type with half-away-from-zero rounding, a versioned and validated backup format, a mutation lock around persistence, full ARB-based localization, and 211 passing tests.

The problems are concentrated in two places: **the persistence path** and **release/security hygiene**.

1. **Critical data loss.** Invoices live only in memory until a screen loads them. `OrderScreen` is the start route, it never calls `loadInvoices()`, and `saveInvoice()` writes the whole in-memory list over storage. A user who cold-starts the app and saves an invoice **silently destroys all previously saved invoices**. Reproduced with a failing test (see §3, P0-1).
2. **Critical signing-key compromise.** The release keystore `upload-keystore.jks` and a plaintext file containing its store password were committed to a **public** GitHub repository and remain in history. I verified the keystore opens with the committed password and contains a usable `PrivateKeyEntry` (alias `upload`, valid to 2052). Anyone who clones the repo can sign an APK for `com.nahro.arqamy` that is accepted as an update.

Around those sit structural issues: a single unversioned JSON blob in `SharedPreferences` with no validation or recovery, ~4,000 LOC of Drift ledger code that production never instantiates, `customerId` that is preserved but never assigned, and a CI pipeline that only builds an unsigned iOS IPA on manual dispatch.

### Scorecard

| Area | Grade | Note |
|---|---|---|
| Data integrity | **F** | P0 overwrite bug; no transactional storage; no schema version on the main store |
| Security & privacy | **F** | Signing key + password public; unencrypted PII; `AD_ID` permission without ads |
| Architecture | **D** | Two parallel persistence designs, one of them dead; no app-level init |
| Business logic | **C-** | Money type is good; inputs and invoice numbering are not validated |
| UX / i18n | **B-** | Solid RTL and localization; several no-op settings entries; debug prints |
| Testing | **C+** | 211 green tests, 73.6% line coverage — but they miss the startup path entirely |
| Build / CI / release | **F** | No analyze/test CI, debug-signing fallback, broken iOS identity |
| Maintainability | **C** | Readable code, but duplicated constants, dead modules, stale branches |

---

## 2. What was verified

| Check | Result |
|---|---|
| `flutter analyze --no-fatal-infos` | 0 errors, 0 warnings, 7 `avoid_print` infos (all in `lib/core/tool/customer_audit.dart`) |
| `flutter test` | **211 tests, all passed** (~66 s) |
| `flutter test --coverage` | **73.6%** of hand-written `lib/` lines (4,024 / 5,471); 47.1% if generated files are included |
| `flutter pub outdated` | Direct deps current; only `cupertino_icons` has a newer major (2.0.0) |
| Git | 138 commits; `main` + 4 stale branches (`ahmednahrawy-fix-main-2`, `-history-loading`, `-performance-optimization`, `releases`); single tag `v1.0` |
| Remote | Public GitHub repo `github.com/Ahmednahrawy/arqamy` (confirmed via API) |

Coverage is strong in the core (provider 89.6%, product form 89.6%, order screen 77.9%) and weak exactly where configuration and persistence bugs live:

| File | Coverage |
|---|---|
| `lib/features/settingscreen/ui/pages/product_management.dart` | 0.7% |
| `lib/features/settingscreen/ui/pages/settings_screen.dart` | 0.8% |
| `lib/features/settingscreen/ui/pages/invoice_setting.dart` | 1.0% |
| `lib/features/drawer/ui/side_nav.dart` | 1.0% |
| `lib/core/database/app_database.dart` | 32.7% |

---

## 3. Findings

Severity: **P0** = data loss or security compromise, fix now · **P1** = serious correctness/release risk · **P2** = quality, UX, maintainability.

### P0-1 — Invoice history is destroyed on the first save after a cold start

**Where:** `lib/main.dart:42`, `lib/features/orderscreen/ui/pages/order_screen.dart:55-57` and `:147`, `lib/features/orderscreen/providers/invoice_provider.dart:161-175`, `:204-241`

**What happens**

`InvoiceProvider` starts with `_invoices = []`. The only production callers of `loadInvoices()` are `CustomerScreen.initState` (`customer_screen.dart:52`), the restore flow (`settings_screen.dart:43`) and `InvoiceBackupService.shareBackup` (`invoice_backup_service.dart:22`). The app's start route is `OrderScreen` (`my_app.dart:52`), whose `initState` calls only `prepareDraft()`.

`saveInvoice()` then does:

```dart
final updatedInvoices = List<Invoice>.of(_invoices); // ← empty on a cold start
...
await _saveInvoicesToStorage(updatedInvoices);       // ← overwrites the whole store
```

So: launch app → add products → Save. The new invoice is written and **every previously saved invoice is gone**. The bug only hides if the user happened to open the Customers screen first in that session.

**Evidence.** I reproduced it with a temporary test (since removed) that seeds `saved_invoices` with one invoice, constructs a fresh `InvoiceProvider` exactly as `main()` does, and saves a second invoice:

```
stored invoice ids after first save: [new]
Expected: contains all of ['old', 'new']
  Actual: ['new']
```

The existing suite does not catch this because `test/invoice_provider_test.dart` always saves from a provider that was never expected to have prior storage.

**Impact.** Total loss of customer history, balances and invoice numbering for the primary flow. This is the single most important defect in the project.

**Fix (do all three):**

1. Make loading implicit and mandatory. Add to `InvoiceProvider`:
   ```dart
   bool _loaded = false;
   Future<void> _ensureLoaded() async {
     if (_loaded) return;
     await loadInvoices();
   }
   ```
   and `await _ensureLoaded()` inside `_withInvoiceMutationLock` before every mutation (`saveInvoice`, `updateInvoice`, `deleteInvoice`, `restoreBackup`). This fixes every call site at once, including future ones.
2. Make silent overwrite impossible. In `_saveInvoicesToStorage`, if `!_loaded` throw `StateError('refusing to write before invoices are loaded')`. Fail loudly rather than lose data.
3. Add a regression test that seeds `SharedPreferences` with an existing invoice, constructs a fresh provider, saves, and asserts both IDs survive. Keep the seed/act/assert shape of the reproduction above.

Belt-and-braces: also call `loadInvoices()` during startup (see P1-7), and keep a copy of the previous blob under a `saved_invoices_backup` key before each write so a bad write is recoverable.

---

### P0-2 — Release signing key and its password are public

**Where:** git history (objects `1b4c7eb…` `upload-keystore.jks`, `a45870a…` `keytool.txt`), `android/key.properties` (on disk, gitignored), `android/app/build.gradle.kts:8-12`, `:34-54`

**What I found**

- `upload-keystore.jks` is not tracked today, but it is in history (`git rev-list --all --objects` finds it, and the blob is byte-identical to the file still sitting in the repo root).
- `keytool.txt`, also in history, contains the store password in plain text (it is the app name, lowercase).
- `android/key.properties` on disk stores `storePassword`, `keyPassword` and `keyAlias=upload` in plain text.
- I verified the key is usable: `keytool -list -v -keystore upload-keystore.jks -storepass <committed password>` returns `Alias name: upload`, `Entry type: PrivateKeyEntry`, `CN=ahmad alnahrawy, O=arqamy`, valid until **2052**.
- The repository is **public**.

**Impact.** Anyone can extract the private key and produce an APK signed with the app's release identity for `com.nahro.arqamy`. If this key was ever used for a Play release (or a direct-distribution release), an attacker can ship an update that existing users will install and that Android will treat as legitimate. Even without distribution, the key must be treated as burned.

**Fix (in this order):**

1. **Rotate.** Generate a new keystore with a strong password, store it outside the repo, and — if the app is on Play — request a **Play App Signing key reset** for the upload key and ship a new version signed with the new key. Deleting history does not un-leak the key; rotation is the only real fix.
2. **Purge history** with `git filter-repo` (or BFG) across *all* branches, then force-push. Assume the repo has already been cloned; treat this as hygiene, not remediation.
3. Remove `keytool.txt` and `upload-keystore.p12` from history as well (the `.p12` blob is also present).
4. Move signing material to CI secrets / a local path outside the repo. Keep `android/key.properties` gitignored (it already is, via `android/.gitignore:12`).
5. Replace the absolute `storeFile` path (`D:/flutter_Projects/arqamy/upload-keystore.jks`) with a repo-relative or environment-provided path, so a release build does not silently break on any other machine.
6. Remove the debug-signing fallback in `build.gradle.kts:49-53`. A release build with no key should **fail**, not ship debug-signed bits.

---

### P1-1 — Persistence is one unversioned JSON blob with no validation or recovery

**Where:** `invoice_provider.dart:204-241` (`saved_invoices` key), `lib/features/orderscreen/data/models/invoice.dart:36-66`

Every save serializes the *entire* invoice list and rewrites one `SharedPreferences` string. There is no schema version, no per-record validation, no atomic swap, and no copy of the previous value.

Consequences:

- **A single bad record bricks the whole history.** `loadInvoices()` decodes the list and maps every entry; one `Invoice.fromJson` failure throws, the whole load fails, and the screen shows "could not load". The user then saves a new invoice and the provider's empty list overwrites the (partially recoverable) blob. The corrupt-data path and the P0-1 path compound each other.
- **Growth is O(n) per save.** Every save re-serializes all invoices, including full product lists.
- **No migration story.** Changing any field shape breaks every stored invoice at once.

The backup format is the model to copy: `InvoiceBackup` (`lib/core/helpers/invoice_backup.dart`) has `format`, `version`, `invoiceCount`, per-field validation, and refuses partial restores. The live store has none of that.

**Fix:** put a versioned envelope around `saved_invoices` (`{version: 2, invoices: [...]}`) with a migration function; decode per record inside a `try/catch` so one bad invoice is skipped and reported instead of killing the list; write the new blob to `saved_invoices_next`, then swap keys, keeping the previous blob as `saved_invoices_previous`. Longer term, see P1-6.

---

### P1-2 — `Invoice.fromJson` trusts input and uses implicit dynamic casts

**Where:** `invoice.dart:52-66`, `:78-86`

```dart
id: json['id'],                    // dynamic → String
products: (json['products'] as List).map(...),
totalCost: json['totalCost'],      // dynamic → double
```

Any of these can throw a `TypeError` at runtime: a missing key (`null`), an integer where a `double` is expected (`"totalCost": 10` from a hand-edited or third-party backup), a null product field, or `products` being absent. There are no defaults and no error messages identifying which invoice failed. `InvoiceBackup.decode` does validate around this, but the primary store does not.

**Fix:** parse defensively with explicit `as num`/`toDouble()`, `Map<String, dynamic>` checks, and per-invoice error reporting (invoice index + field). This is a prerequisite for P1-1's "skip one bad record" behaviour.

---

### P1-3 — Invoice amounts and quantities accept invalid business values

**Where:** `lib/features/orderscreen/ui/widgets/product_input_form.dart:99-101`, `:313-323`, `:339-405`; `order_screen.dart:79-82`, `:583-596`; `invoice_provider.dart:69-73`; `product_model.dart:15-20`

- Validators only check `double.tryParse(value) != null` — **negative weight, negative price and negative paid amounts are accepted**. Nothing checks `netWeight > 0`, `price >= 0`, or `paid >= 0`.
- `Product.netWeight` is `weight - packageWeight * numberPackage`, so a package count larger than the weight produces a negative net weight and therefore a negative line total.
- `paid` is not compared against the total: overpayment is silently accepted, and the negative case produces a "remaining" larger than the invoice.
- `calculateOutstandingBalance` calls `Money.fromDouble(totalCost).abs()` (`invoice_provider.dart:71`). This converts a negative invoice total into a positive one, so a nonsensical invoice (negative price or negative net weight) displays a plausible-looking positive balance instead of surfacing the error.

**Fix:** validate at the form boundary (`weight > 0`, `packageWeight >= 0`, `numberPackage >= 0`, `price >= 0`, `paid >= 0`, `paid <= total` or an explicit overpayment confirmation), and remove the `.abs()` so negative totals are visible and blocked. The ledger module already encodes these rules — reuse them (P1-6).

---

### P1-4 — Customer identity is never assigned, so history splits on rename

**Where:** `invoice.dart:20-22`, `order_screen.dart:119-130`, `edit_invoice_dialog.dart:174`, `invoice_backup.dart:106-128`

`Invoice.customerId` was added ("Decision 39") and is preserved by edit and backup — but **nothing in `lib/` ever sets it to a non-null value**. `OrderScreen._buildInvoice` does not pass it. Grouping, totals and customer history are therefore keyed on the customer *name*, so renaming a customer (or fixing a spelling) splits their balance and history into two entities.

**Fix:** introduce a real customer record (id, display name, aliases) and assign `customerId` at invoice creation; migrate existing invoices by normalized-name grouping (the existing `customer_audit.dart` normalization is a good starting point, but it must be a human-confirmed mapping, as that tool's own comment says). Group history by `customerId ?? fallbackNameKey` during the transition.

---

### P1-5 — The iOS target cannot ship as-is

**Where:** `ios/Runner/Info.plist:7-8`, `ios/Runner.xcodeproj/project.pbxproj:349,371`, `lib/features/settingscreen/ui/pages/invoice_setting.dart` (logo picking via `image_picker`)

- `CFBundleDisplayName` is **"My Hand"** and `CFBundleName` is **"my_hand"** — stale branding from before the rename.
- Bundle identifier is `com.example.myHand` (template default) and cannot be registered on the App Store.
- Deployment target is `IPHONEOS_DEPLOYMENT_TARGET = 12.0`, below what current Flutter requires.
- `image_picker` is used to pick the company logo, but there is **no `NSPhotoLibraryUsageDescription`** in `Info.plist`. Picking a logo from the gallery will terminate the app on iOS.
- No `PrivacyInfo.xcprivacy` privacy manifest, which App Store submission now expects for apps using covered APIs.
- `main.dart` locks orientation to portrait, while `Info.plist` allows landscape — inconsistent behaviour between platforms.

**Fix:** set `CFBundleDisplayName` to Arqamy, change the bundle id to a real reverse-DNS identifier, raise the deployment target, add `NSPhotoLibraryUsageDescription` (and `NSPhotoLibraryAddUsageDescription` if saving), add a privacy manifest, and align supported orientations.

---

### P1-6 — ~4,000 LOC of ledger/database code is dead in production

**Where:** `lib/core/database/app_database.dart` (~1,300 lines, schema v5, triggers, append-only tables), `lib/features/payment_ledger/data/*` (`cash_event_repository.dart`, `allocation_repository.dart`, `ledger_foundation_repository.dart`, domain models)

No production file constructs `AppDatabase`, `CashEventRepository`, `AllocationRepository` or `LedgerFoundationRepository` — only tests do. I grepped all of `lib/`; the only matches are the class declarations themselves. Yet:

- `drift`, `drift_dev` and `build_runner` are direct dependencies, and the generated file is enormous.
- 4,014 lines of hand-written code (one third of `lib/`) plus a large portion of the 13.6k test lines exist to validate a system the app never runs.
- The tests emit Drift's "created the database class multiple times… race conditions… might corrupt the database" warning during concurrent-handle tests.

**Impact.** Two competing sources of truth. A future developer will reasonably assume the ledger is live, wire a screen to it, and find that production data was never migrated. Meanwhile the real store (P1-1) stays unhardened, and the team pays the build/maintenance cost of Drift for nothing.

**Fix:** make an explicit decision and write it down:
- **Adopt it:** move invoices/payments into `AppDatabase` behind a repository interface, add a one-time migration from `saved_invoices`, and delete the SharedPreferences path.
- **Or remove it:** delete `lib/core/database` and `lib/features/payment_ledger` (plus their tests and the Drift deps) and keep the simpler store — but then harden it per P1-1.

Keeping both is the one option that is definitely wrong. Given the ledger already encodes the money and allocation rules the app lacks (P1-3), adopting it is the higher-value path — but only with a migration plan.

---

### P1-7 — No application-level initialization phase

**Where:** `lib/main.dart:13-49`, `order_screen.dart:54-71`, `customer_screen.dart:47-52`

Startup does theme and Firebase setup, then builds providers. Every feature loads its own data in `initState`. That is the root cause of P0-1, and it will keep producing variants of it (e.g. any new screen that mutates invoices before the customer screen has been opened).

**Fix:** give the provider an explicit lifecycle — `InvoiceProvider.bootstrap()` that loads invoices (and master products) once — and `await` it before `runApp`, or expose a `FutureBuilder`/`AppBootstrap` widget at the root. Then remove the per-screen `loadInvoices()` calls or make them no-ops.

---

### P2-1 — Invoice serials can collide

**Where:** `order_screen.dart:96-100`

```dart
"${now.year}${month}${day}${hour}${minute}${second}"
```

Second precision, local time, no uniqueness check. Two invoices saved within the same second (or after a clock change / manual clock adjustment) get the same human-facing invoice number. The PDF filename uses the UUID, so files do not overwrite each other — but the number printed on the invoice does.

**Fix:** derive the serial from a persisted monotonic counter (`last_serial + 1`) with a per-year prefix, or append a short random suffix, and validate uniqueness against loaded invoices.

---

### P2-2 — Invoice date cannot be set at creation

**Where:** `order_screen.dart:41`, `:73-77`, `:114-131`

`selectedDate` is `final DateTime selectedDate = DateTime.now()` at widget construction, and `_selectDate` only formats it — there is no date picker. So every new invoice is dated "now" and can only be corrected afterwards through `EditInvoiceDialog`.

**Fix:** add a date picker next to the invoice date and store an ISO `createdAt` on the invoice instead of pre-formatted `formattedDate`/`formattedTime` strings (format at render time, so changing the app locale doesn't leave old invoices in the old format).

---

### P2-3 — Debug output and a listener leak in a production widget

**Where:** `lib/features/orderscreen/ui/widgets/customer_name.dart:28,65,84,98,155`, `:139`

Five unconditional `print()` calls run on every keystroke/save path and pollute logs (they also appear throughout the test output). At `:139` a `focusNode.addListener(...)` is registered inside `build`, so a new listener is added on every rebuild and never removed.

**Fix:** delete the prints (or gate them behind `kDebugMode`), and move the listener registration into `initState` with a matching `removeListener` in `dispose`.

---

### P2-4 — Settings exposes five non-functional entries

**Where:** `lib/features/settingscreen/ui/pages/settings_screen.dart:109-115` (profile), `:161-166` (notifications), `:167-173` (privacy), `:174-180` (help), `:244-248` (logout)

All have empty `onTap` bodies (`onTap: () {}` or a comment). To a user they look like working features. "Logout" in particular implies accounts that do not exist.

**Fix:** remove them until implemented, or mark them "coming soon" and disable them.

---

### P2-5 — `AD_ID` permission declared without any ads or analytics

**Where:** `android/app/src/main/AndroidManifest.xml:3`

`com.google.android.gms.permission.AD_ID` is declared, but the app has no ads SDK and no `firebase_analytics`. The permission is a Play data-safety declaration trigger and a privacy-flag for users.

**Fix:** remove it. If an ads/analytics dependency is added later, let its manifest merge bring the permission.

---

### P2-6 — Customer PII is stored and exported unencrypted, and auto-backed up

**Where:** `invoice_provider.dart` (plain `SharedPreferences`), `invoice_backup_service.dart` (plaintext JSON via share sheet), Android manifest (no `android:allowBackup="false"`)

Invoice data contains customer names, phone numbers and transaction amounts. It sits in plaintext `SharedPreferences` (included in Android's default cloud backup), and backups are plaintext JSON files handed to any app the user shares to.

**Fix:** at minimum set `android:allowBackup="false"` (or use a scoped backup rule excluding invoice data), and warn users that backups contain personal data. If stronger protection is required, encrypt the store with a key from the Keystore/Keychain.

---

### P2-7 — Release build configuration is fragile

**Where:** `android/app/build.gradle.kts:8-12`, `:25`, `:45-55`

- Falls back to **debug signing** when `key.properties` is missing (`:49-53`), so a release build can silently produce an unshippable, non-updatable artifact.
- `storeFile` is an absolute developer path (`D:/flutter_Projects/arqamy/upload-keystore.jks`), so the build fails on any other machine.
- The template `TODO: Specify your own unique Application ID` comment is still there (`:25`).

**Fix:** fail the build when the keystore is absent in release; use a relative or environment-provided path; delete the TODO.

---

### P2-8 — CI does not test or build the app

**Where:** `.github/workflows/dart.yml`

The only workflow is named `iOS-ipa-build`, runs **only on `workflow_dispatch`**, uses `actions/checkout@v3`, and does `pod repo update` → `flutter build ios --release --no-codesign` → zip → upload to tag `v1.0` (overwriting it). There is:

- no `flutter analyze`, no `flutter test` on push/PR,
- no Android build,
- no dependency/security scanning,
- no branch protection signal.

**Fix:** add a PR workflow running `dart format --output=none --set-exit-if-changed .`, `flutter analyze --fatal-infos`, and `flutter test --coverage`; add an Android `assembleRelease` (unsigned or CI-signed) job; update actions; stop overwriting a fixed tag.

---

### P2-9 — Tests systematically miss the startup path

**Where:** `test/invoice_provider_test.dart`, `test/widget_test.dart`

211 passing tests and 73.6% line coverage, which is genuinely good — but the suite injects a storage writer and starts every provider empty, so it never exercises "app starts with existing storage, then writes". That is exactly P0-1. Settings screens are at ~1% coverage, which is why P2-4/P2-7 went unnoticed.

**Fix:** add the P0-1 regression test; add a widget test that boots the app with seeded `SharedPreferences` and saves; raise settings coverage with a few smoke tests (open screen, tap tiles, assert no crash). Also silence the debug prints so test output is readable.

---

### P2-10 — Duplicated canonical values and formatting helpers

- The persisted invoice actions exist in three places: `InvoiceAction` (`lib/core/helpers/invoice_action.dart:7-9`), `InvoiceActionL10n` (`lib/core/helpers/invoice_action_l10n.dart:10-12`), and `PdfLabels`/ARB. `invoice_action.dart`'s own doc comment says the strings "must never change", yet a second copy of them exists. Changing one copy silently orphans stored invoices.
- PDF labels are hand-mirrored from the ARB files (`pdf_labels.dart` header comment admits it) with no test asserting they match.
- `Utils.formatPrice`/`formatDate` (`lib/core/helpers/helper_date_price.dart`) duplicate `lib/core/helpers/formatters.dart`; `formatPrice` hardcodes a **`$`** prefix in an EGP app.

**Fix:** make `InvoiceAction` the single source of truth (have `InvoiceActionL10n` delegate to it), add a test that `PdfLabels` matches the ARB values, and delete `helper_date_price.dart` (it is unused).

---

### P2-11 — WhatsApp sharing only supports one package

**Where:** `android/app/src/main/kotlin/com/nahro/arqamy/MainActivity.kt` (`setPackage("com.whatsapp")`), `lib/core/services/invoice_service.dart:14`

- Users with only **WhatsApp Business** (`com.whatsapp.w4b`) get "WhatsApp is not installed".
- On Android 11+, package visibility can make the explicit-package `ACTION_SEND` fail on some OEM builds; the manifest `<queries>` block only declares `PROCESS_TEXT`.
- The channel name `com.nahro.arqamy/whatsapp` is hardcoded in Kotlin and Dart, with no shared constant.

**Fix:** try `com.whatsapp`, then `com.whatsapp.w4b`, then fall back to the generic share sheet; add the WhatsApp packages to `<queries>`; test on an Android 11+ device.

---

### P2-12 — Dependency set is nonstandard and partly unused

| Dependency | Status |
|---|---|
| `http`, `permission_handler`, `google_fonts`, `cupertino_icons` | **unused** (0 imports) |
| `font_awesome_flutter`, `url_launcher`, `in_app_update`, `dropdown_search` | 1 import each — confirm they are worth the weight |
| `shared_preferences_android` | redundant explicit pin (transitive of `shared_preferences`) |
| `drift`, `drift_dev`, `build_runner` | only used by dead code (P1-6) |
| `cupertino_ui: any` | **unpinned** dependency; `material_ui` is also used instead of `flutter/material` |
| `flutter_native_splash` | dev-time CLI tool (fine, but unused config) |

`material_ui` / `cupertino_ui` replacing Flutter's own `material`/`cupertino` libraries is unusual and a supply-chain and upgrade risk; `any` means a future publish can change behaviour without a version change.

**Fix:** remove unused deps, pin `cupertino_ui`, and document (or reverse) the `material_ui` choice. `pubspec.yaml` also still says `description: "A new Flutter project."`.

---

### P2-13 — Firebase is initialized but unused

**Where:** `lib/main.dart:23-29`, `lib/firebase_options.dart` (tracked)

Firebase is initialized on every launch inside a `try/catch` that swallows failures, but no Firebase service (auth, Firestore, messaging, analytics) is used. It adds startup cost and ships project config for `my-hand-7dde2` in a public repo.

**Fix:** remove Firebase entirely until a feature needs it, or add the feature. If kept, restrict the API key in Google Cloud console and stop swallowing initialization errors silently.

---

### P2-14 — Repository and documentation hygiene

- `README.md` is the default Flutter template; `docs/` was empty until this report.
- `pubspec.yaml` version is `1.0.4+22`, but the only tag is `v1.0` and CI overwrites it. No `CHANGELOG.md`, no `LICENSE` despite being a public repo.
- Four stale branches diverge from `main` by 100+ commits and have not been touched since October; `main...branch` counts are 132/1, 23/0, 134/1, 106/0.
- History is noisy: many `Agent host session … - baseline checkpoint` commits, which makes `git log` and `git blame` much less useful.
- Android launcher icon key is misspelled `laucher_icon` (works, but propagates the typo into `AndroidManifest.xml:7`).

**Fix:** write a real README (what the app is, how to run, how to build, how to back up), add a CHANGELOG and license, delete merged/stale branches, and squash checkpoint commits going forward.

---

## 4. Strengths worth keeping

These are not filler — they are the parts a rewrite would most likely lose:

- **`Money`** (`lib/core/helpers/money.dart`) is a correct fixed-point type: minor units, explicit half-away-from-zero rounding, binary-noise absorption, range checks, and a test suite that pins the tricky cases (`1.005 → 101`, `2.675 → 268`). Totals are summed as `Money`, not doubles.
- **`InvoiceBackup`** is a genuinely good format: explicit `format`, `version`, `invoiceCount` integrity check, per-field validation, whole-file rejection, and an explicit refusal to read a newer version.
- **`_withInvoiceMutationLock`** serializes mutations correctly within a provider instance — the right instinct, just applied to the wrong starting state.
- **Localization** is real: ARB sources for `ar`/`en`, a custom generator (`tool/generate_l10n.dart`) that fails on missing translations, a proper `Directionality` override, and locale-aware dates.
- **`AppSemanticColors`** as a `ThemeExtension` with light/dark variants is better theming than most Flutter apps of this size.
- **The test suite** is fast, broad, and green — 211 tests in ~66 s.

---

## 5. Remediation roadmap

### Phase 0 — this week (stop the bleeding)

| # | Action | Effort |
|---|---|---|
| 1 | P0-1: `_ensureLoaded()` before mutations + guard against writing when unloaded + regression test | 2–3 h |
| 2 | P0-2: rotate the signing key, purge the keystore/password from history, remove debug-signing fallback | 2–4 h + Play console time |
| 3 | P2-3: remove the `print`s and the per-build focus listener | 30 min |
| 4 | P2-5 / P2-6: drop `AD_ID`, set `allowBackup="false"` | 30 min |

### Phase 1 — next 1–2 weeks (make the data layer trustworthy)

| # | Action | Effort |
|---|---|---|
| 5 | P1-7: app-level bootstrap that loads invoices before the first frame | 3 h |
| 6 | P1-2 + P1-1: defensive `Invoice.fromJson`, versioned envelope, per-record skip, previous-blob copy | 1–2 d |
| 7 | P1-3: validate weights, prices, paid amounts; remove the `.abs()` | 1 d |
| 8 | P2-1 / P2-2: monotonic serial, real `createdAt`, date picker | 1 d |
| 9 | P2-9: tests for startup-with-data, settings smoke tests | 1 d |
| 10 | P2-8: PR CI (`analyze` + `test` + Android build) | half a day |

### Phase 2 — this month (decide the architecture)

| # | Action | Effort |
|---|---|---|
| 11 | P1-6: decide adopt-vs-delete the Drift ledger; write an ADR in `docs/` | 1 d decision |
| 12 | If adopt: repository interface + one-time migration from `saved_invoices`; if delete: remove 4k LOC and Drift deps | 3–5 d |
| 13 | P1-4: real customer records; assign and backfill `customerId` | 2–3 d |
| 14 | P1-5: iOS identity, photo permission, privacy manifest, deployment target | 1 d |
| 15 | P2-4 / P2-10 / P2-11 / P2-12: remove no-op settings, de-duplicate constants, fix WhatsApp sharing, prune deps | 2 d |

### Phase 3 — ongoing

- P2-14: README, CHANGELOG, license, branch cleanup.
- Add integration tests for the full save → history → edit → backup → restore cycle.
- Consider a crash/error reporter before shipping to real users (right now a failed write is only a snackbar).

---

## 6. Appendix — commands used

```powershell
flutter analyze --no-fatal-infos
flutter test
flutter test --coverage
flutter pub outdated

git rev-list --all --objects | Select-String 'upload-keystore|keytool|key.properties'
git cat-file -s 1b4c7eb741dfd674c3eb8ea09b82fca33cbea997   # keystore blob
git show 1bdc5fb:keytool.txt                               # committed password
keytool -list -v -keystore upload-keystore.jks -storepass <committed password>
git for-each-ref --sort=-committerdate refs/heads
```

Data-loss reproduction (temporary test, removed after running): seed `SharedPreferences` with one invoice, build a fresh `InvoiceProvider`, `saveInvoice` a second one, assert both IDs survive — the assertion failed with `Actual: ['new']`.

No source files were modified for this audit.
