# CaesarPad build state

Last updated: 2026-08-01

## Release candidate

| Item | Status | Current evidence |
|---|---|---|
| Source safety | PASS | `scripts/check-repo-safety.sh` applies all 12 patches from a clean Augustus checkout and audits tracked paths, scripts, metadata, screenshots, and the pinned submodule. |
| Simulator build | PASS | arm64 `iPhoneSimulator` Release app built with Xcode 26.6. |
| Touch engine tests | PASS | Long press, two-finger alternate click, pan-versus-pinch intent, and Pencil/finger routing all pass in `scripts/test-touch.sh`. |
| Native iPad controls | PASS | On an iPad Pro 13-inch (M5) Simulator, the top-right controls, controls guide, and persistent Pencil mode passed focused XCUITests on 2026-08-01. |
| Physical device build | PASS | Developer-signed arm64 `iPhoneOS` app, bundle ID `com.chrissotraidis.caesarpad`, version `0.1.0` (1), passed strict code-signature verification. |
| Attached iPad deployment | PASS | The signed release-identity build installed and launched on an attached iPad Pro 12.9-inch (6th generation) on 2026-08-01. Its new container was populated from a verified backup of the old bundle, game-data hashes matched, and the game resumed. This proves deployment and migration, not final hands-on acceptance. |
| Unsigned IPA | PASS | `scripts/package-ios.sh` produces and audits `CaesarPad-0.1.0-preview.1-unsigned.ipa`, its SHA-256 file, embedded notices, arm64 executable, and absence of game data, saves, signatures, or provisioning profiles. |
| Public release | PENDING | Source can be merged to `main`; a public GitHub prerelease, tag, and downloadable IPA have not yet been published. |

## Automated test note

Recorded end-to-end Simulator runs on the earlier verified iPad runtime passed mission
startup, building placement, map gestures, pause, and lifecycle recovery. On the current
iOS 26.5 Simulator, the identifier-based native UI tests still pass, but the older
pixel-coordinate mission test does not select the expected menu item after rotation. The
failure is retained as a visible test issue rather than having its assertion weakened.
Physical touch and Pencil behavior have also been exercised during supervised development;
the exact unsigned IPA still requires the acceptance pass in
[`docs/RELEASE_CHECKLIST.md`](docs/RELEASE_CHECKLIST.md).

## Pinned inputs

- Augustus: `69c69827682a11eaaa400c5a77198131249bfe2a` (`Keriew/augustus`, submodule).
- SDL2: 2.32.10, SHA-256 `5f5993c530f084535c65a6879e9b26ad441169b3e25d789d83287040a9ca5165`.
- SDL2_mixer: 2.8.2, SHA-256 `938dff531d00ace2296557a6599abe6f34599e2f34f0a4a08a397e2ccac8b8f7`.
- Minimum deployment target: iOS/iPadOS 14.0.

## Distribution boundary

- Caesar III game data is never tracked or packaged. Users provide their own legally
  purchased files.
- The public binary format is unsigned and re-signable. Maintainer certificates and
  provisioning profiles are stripped before packaging.
- `ref/`, `artifacts/current-run/`, saves, generated builds, `.ipa` files, and signing
  material remain local and ignored.
- Files access is enabled for the app's Documents directory, but a polished in-app import
  workflow is not part of this preview.

## Remaining prerelease acceptance

- Re-sign and install the exact candidate IPA rather than the directly built `.app`.
- Confirm Files visibility and copy owned Caesar III data into the installed container.
- Load the developed demo save, then validate touch, Pencil, audio, lifecycle, performance,
  and thermals on the exact packaged candidate.
- Recalibrate the pixel-coordinate gameplay XCUITests for the current iOS Simulator runtime.
