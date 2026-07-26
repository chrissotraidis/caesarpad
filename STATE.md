# CaesarPad Build State

Last updated: 2026-07-26

## Gates

| Gate | Status | Evidence |
|---|---|---|
| G0 — Toolchain | PASS | Xcode 26.6 (17F113); iOS 18.5 and 26.5 Simulator runtimes; booted iPad Pro 11-inch (M4), iOS 18.5, UDID `08636791-2675-4675-8335-EF72EF954DCF`; `artifacts/g0/` |
| G1 — Engine builds | PASS | `scripts/build.sh`; arm64 Simulator app; `** BUILD SUCCEEDED **`; `artifacts/g1/build.log` |
| G2 — Boots | PASS | Fresh install launched as PID 47408 and displayed the “Game Data Required” alert; `artifacts/g2/game-data-required.png`; `artifacts/g2/launch.log` |
| G3 — Data loads | PASS | 601 files injected by `scripts/inject-data.sh`; main menu reached; PID 47855 remained live; CoreAudio created and started a 2-channel 22050 Hz playback queue; `artifacts/g3/` |
| G4 — Playable | PASS | Clean XCUITest reached a landscape mission, selected housing, placed it, dismissed the build tool, panned the map, changed speed, and paused without a keyboard; 1 test, 0 failures in 93.858 s; `artifacts/g4/playable-flow-pass-2.log`; screenshots in ignored `artifacts/g4/playable-flow-pass-2.xcresult` |
| G5 — Touch controls | PASS | Focused Simulator UI test passed tap, two-finger right-click, drag pan, pinch zoom, and native `Running` → `Paused` control state in 75.813 s; engine interaction test passed 350 ms long-press timing, movement rejection, release timing, and two-finger consumption; `artifacts/g5/touch-controls-pass-8.log`; `artifacts/g5/long-press-engine-test-final.log`; screenshots in ignored xcresult |
| G6 — Lifecycle safe | PASS | `simctl` backgrounding created `Documents/caesarpad-autosave.svx` (58,320 bytes); after terminate + cold launch, XCUITest observed the engine-marked resumed state and the save was consumed; `artifacts/g6/build-final.log`; `artifacts/g6/lifecycle-pass-2.log`; screenshots in ignored xcresults |
| G7 — Test suite | PASS | One `scripts/test.sh` run built the app, booted/installed/injected data, passed the engine touch test, playable UI flow, minimal-touch UI flow, and lifecycle cycle; final line `PASS: CaesarPad build, boot, data, gameplay, touch, and lifecycle suite`; `artifacts/g7/full-suite.log` |
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

## Current blocker

None. All gates G0–G8 are complete.
