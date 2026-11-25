# Arqamy — Signing-Key Remediation Status

**Repository:** `Ahmednahrawy/arqamy`  
**Default branch:** `main`  
**Last reviewed:** 2026-11-25  
**Purpose:** Track the exposed Android signing-key incident and the safe sequence for completing remediation.

This document records repository state and remediation progress. It does not replace Google Play's confirmation that a replacement upload key is active.

## 1. Incident summary

The repository is public. The previous security audit found Android signing material and plaintext password material committed in Git history, including:

- `upload-keystore.jks`
- `upload-keystore.p12`
- `keytool.txt`

Treat the exposed upload key and associated credentials as compromised. Removing files from the current working tree or adding ignore rules does not remove historical Git objects and does not make the exposed key safe again.

Google Play App Signing was enabled in the user's Play Console. The affected credential is being handled as the **upload key**; do not confuse an upload-key reset with replacing the Play app-signing key.

## 2. Remediation completed in the repository

### Android release-signing validation

PR #5, **Harden Android release signing validation**, was merged into `main`.

The current `android/app/build.gradle.kts`:

- Requires `storeFile`, `storePassword`, `keyAlias`, and `keyPassword`.
- Checks that the configured keystore file exists.
- Supports a keystore path outside the repository.
- Does not fall back to debug signing for release artifacts.
- Fails release artifact tasks when signing is not configured correctly.

A credential-free template is provided at `android/key.properties.example`.

**Not yet verified:** a release build signed with the replacement upload key. That must wait until Google confirms the reset is effective and the replacement key is configured locally or in the release environment.

### Ignore rule

PR #6, **Ignore keytool files in all directories**, was merged into `main`.

The root `.gitignore` contains the repository-wide rule:

```gitignore
**/keytool.txt
```

This prevents future accidental tracking of files with that name. It does not purge existing history.

## 3. Current status

| Item | Status |
|---|---|
| Exposed old key treated as compromised | Complete |
| Replacement upload key generated and reset request submitted | Reported by repository owner; awaiting Google confirmation |
| Android release-signing validation hardened | Merged |
| Global `keytool.txt` ignore rule | Merged |
| Replacement key accepted by Google Play | Pending confirmation |
| Release build verified with replacement key | Pending |
| Historical signing-file purge | Pending |
| GitHub cached/internal reference cleanup | Pending |
| Final secret/history verification | Pending |

Do not upload a release signed with the replacement key until Google confirms that it is the active upload key.

## 4. Repository references that must be reviewed before history cleanup

The live repository currently exposes these nine ordinary branches:

- `main`
- `ahmednahrawy-fix-main-2`
- `ahmednahrawy-history-loading`
- `ahmednahrawy-performance-optimization`
- `fix/invoice-cold-start-data-loss`
- `releases`
- `security/ignore-keytool-files`
- `security/validate-android-release-signing`
- `test/fix-invoice-storage-fixtures`

The repository also has the `v1.0` tag, which was identified in the earlier history inventory. Refresh branches and tags immediately before any rewrite; this list is a dated inventory, not a guarantee that refs have not changed.

PR #2 remains open and unmerged. Its branch must not be discarded or overwritten as part of cleanup. Closed or merged PR branches should also be preserved unless the repository owner separately authorizes a change.

GitHub-managed pull-request refs and cached objects may not be directly writable through ordinary branch/tag pushes. A successful rewrite of normal branches and tags does not, by itself, prove that every GitHub-side copy has been purged.

## 5. Required sequence after Google confirms the reset

1. Confirm in Play Console that the replacement upload certificate is accepted and active. Record the confirmation date; do not store private credentials in this repository.
2. Configure the replacement keystore and passwords outside the repository or in an approved secret store.
3. Build and verify the Android release artifact with the replacement key. Confirm its signing certificate matches the accepted upload certificate before publishing.
4. Refresh the full branch, tag, and open-PR inventory from GitHub.
5. Create and verify a complete backup of all refs and repository objects before rewriting anything.
6. Identify and preserve unique commits on every branch. Resolve any open PR implications before proceeding.
7. Prepare a reviewed history-rewrite map that removes all exposed signing files and plaintext credentials from every relevant branch and tag.
8. Obtain explicit repository-owner approval before any force-push, tag rewrite/deletion, branch deletion, or other destructive ref operation.
9. Coordinate GitHub-side cleanup for pull-request refs, cached views, and other retained objects where necessary.
10. Verify the cleaned refs and reachable history no longer contain the exposed files or credentials. Document any GitHub-side limitations that cannot be independently verified.
11. Ask collaborators to replace old clones rather than merging old histories back into the cleaned repository.

## 6. Safety rules

- Never commit a keystore, private key, `key.properties`, or password file.
- Keep the replacement keystore and passwords private and outside the repository.
- Do not use the exposed old upload key for new releases.
- Do not rewrite history while the upload-key reset is pending.
- Do not force-push, delete branches, or rewrite tags without explicit approval.
- Preserve unique branch work and open-PR context.
- Treat history cleanup as exposure reduction, not as a substitute for key rotation.
