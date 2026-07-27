# CaesarPad Build State

Last updated: 2026-07-27

## Gates

| Gate | Status | Evidence |
|---|---|---|
| G0 — Toolchain | PASS | Xcode 26.6 (17F113); iOS 18.5 and 26.5 Simulator runtimes; booted iPad Pro 11-inch (M4), iOS 18.5, UDID `08636791-2675-4675-8335-EF72EF954DCF`; `artifacts/g0/` |
| G1 — Engine builds | PASS | `scripts/build.sh`; arm64 Simulator app; `** BUILD SUCCEEDED **`; `artifacts/g1/build.log` |
| G2 — Boots | PASS | Fresh install launched as PID 47408 and displayed the “Game Data Required” alert; `artifacts/g2/game-data-required.png`; `artifacts/g2/launch.log` |
| G3 — Data loads | PASS | 601 files injected by `scripts/inject-data.sh`; main menu reached; PID 47855 remained live; CoreAudio created and started a 2-channel 22050 Hz playback queue; `artifacts/g3/` |
| G4 — Playable | PASS | Clean XCUITest reached a landscape mission, selected housing, placed it, dismissed the build tool, panned the map, changed speed, and paused without a keyboard; 1 test, 0 failures in 93.858 s; `artifacts/g4/playable-flow-pass-2.log`; screenshots in ignored `artifacts/g4/playable-flow-pass-2.xcresult` |
| G5 — Touch controls | PASS | Strengthened Simulator UI test passed tap, two-finger right-click, visible long-press tool cancellation, drag pan, boundary-safe pinch zoom, native clock pause, and resume three consecutive times (77.737 s, 75.149 s, 76.997 s); engine test also rejects moved, delayed, single, and consumed alternate-click gestures; `artifacts/public-preview/touch-stable-{1,2,3}.log`; screenshots in ignored xcresults |
| G6 — Lifecycle safe | PASS | `simctl` backgrounding created `Documents/caesarpad-autosave.svx` (58,320 bytes); after terminate + cold launch, XCUITest observed the engine-marked resumed state and the save was consumed; `artifacts/g6/build-final.log`; `artifacts/g6/lifecycle-pass-2.log`; screenshots in ignored xcresults |
| G7 — Test suite | PASS | Two consecutive identical-checkout `scripts/test.sh` runs built the branded app, auto-selected and booted the iPad, installed/injected data, passed the engine touch test, playable UI flow, strengthened minimal-touch flow, and lifecycle cycle; both end with `PASS: CaesarPad build, boot, data, gameplay, touch, and lifecycle suite`; `artifacts/public-preview/full-suite-repeat.log`; `artifacts/public-preview/full-suite-repeat-2.log` |
| G8 — Repeatable | PASS | After `git clean -fdx -e ref/` and a fresh Augustus submodule checkout, `scripts/build.sh && scripts/test.sh` passed twice consecutively; `ref/` remained ignored with all 609 files; `artifacts/g8/repeat-1.log`; `artifacts/g8/repeat-2.log` |

## Pinned inputs

- Augustus: `69c69827682a11eaaa400c5a77198131249bfe2a` (`Keriew/augustus`, submodule).
- SDL2: 2.32.10 source release, SHA-256 `5f5993c530f084535c65a6879e9b26ad441169b3e25d789d83287040a9ca5165`.
- SDL2_mixer: 2.8.2 source release, SHA-256 `938dff531d00ace2296557a6599abe6f34599e2f34f0a4a08a397e2ccac8b8f7`.

## Decisions

- Augustus is the only engine flavor in this build loop.
- The iOS 18.5 iPad Pro 11-inch (M4) Simulator is the primary automated target.
- `ref/` is ignored and reserved for user-owned Caesar III data. Its contents must never be staged or committed.
- Engine changes, if a gate requires them, live as small patches under `patches/`; the engine remains a submodule.
- The app supports landscape left and right only; portrait orientations are removed by the smallest upstream patch.
- iOS lifecycle autosaves use Augustus's normal `.svx` format at `Documents/caesarpad-autosave.svx`; a successful cold-start resume consumes the file to avoid stale-session launches.
- The original CaesarPad icon is a single downstream-owned opaque 1024×1024 PNG; the build validates and stages it without committing a binary change inside Augustus.
- Human Simulator setup uses `scripts/install.sh`; scripts auto-select a booted iPad or the first available iPad, while `SIMULATOR_UDID` remains an explicit override.
- Public documentation describes the current output as a Simulator-only developer preview. Device signing, IPA distribution, and a production Files importer remain unshipped.

## Public-preview follow-up

- `scripts/install.sh` completed build, install, data injection, and launch from one
  command; `artifacts/public-preview/install-pass.log`.
- The compiled bundle reports `CFBundleDisplayName=CaesarPad`, contains only the two
  landscape orientations, and includes a 1024×1024 AppIcon rendition.
- The long-press replay found and fixed an in-progress construction edge case: touch
  right-click now rolls back the transient placement and clears the selected tool.
- The original app icon, root AGPL-3.0 license, public product README, expandable install
  and troubleshooting paths, and honest device-only boundary are present.

## Current blocker

None. All gates G0–G8 are complete.
