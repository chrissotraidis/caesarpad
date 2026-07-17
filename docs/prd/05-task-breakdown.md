# PRD — Autonomous Task Breakdown

Conventions: IDs `P<phase>.<n>`. Effort: S ≤ ½ day, M ≤ 2 days, L ≤ 5 days (agent-days,
including tests). Risk: L/M/H. Tasks marked 🔶 need a human with hardware or accounts;
everything else is executable by a coding agent against CI. "Files" are indicative, not
exhaustive. Engine-source tasks always mean: create a patch in `patches/<engine>/` AND open
the matching upstream PR.

## Phase 0 — Research validation

**P0.1 — Pin and build both engines for iOS Simulator in CI**
- Objective: GitHub Actions job that checks out `engines/julius` and `engines/augustus`
  submodules at pinned SHAs, fetches SDL2/SDL2_mixer source releases into `ext/SDL2/`, runs
  `cmake -DTARGET_PLATFORM=ios -G Xcode`, builds for `iphonesimulator`.
- Dependencies: none (first task).
- Files: `.gitmodules`, `scripts/fetch-deps.sh`, `.github/workflows/build.yml`.
- Acceptance: CI green on both engines; `julius.app`/`augustus.app` simulator bundles among
  artifacts; README badge.
- Effort M · Risk M (Xcode-generator quirks) · Priority P0.

**P0.2 — Simulator boot smoke test**
- Objective: XCUITest (or `xcrun simctl` script) that installs the app in a booted iPad
  simulator and asserts the "Game Data Required" alert appears.
- Dependencies: P0.1.
- Files: `ci/smoke/`, workflow step.
- Acceptance: test passes for both engines in CI; failure screenshots uploaded.
- Effort M · Risk M · Priority P0.

**P0.3 🔶 — Device validation session**
- Objective: human sideloads both artifacts on a physical iPad with real GOG data; completes
  the Phase-0 checklist (fps, touch, audio, import, background/resume) and files findings as
  repo issues + upstream issues where engine bugs are found.
- Dependencies: P0.1.
- Acceptance: checklist doc committed to `docs/validation/phase0.md`; go/no-go note.
- Effort S (human) · Risk L · Priority P0.

## Phase 1 — Repeatable iPad build

**P1.1 — Patch-queue infrastructure**
- Objective: `patches/<engine>/*.patch` applied by `scripts/apply-patches.sh` before build;
  CI fails if a patch doesn't apply cleanly; each patch header requires an `Upstream-PR:` or
  `Upstream-status:` line, enforced by a lint script.
- Dependencies: P0.1.
- Files: `scripts/apply-patches.sh`, `scripts/lint-patches.sh`, `patches/README.md`.
- Acceptance: dummy patch applies in CI; lint rejects a header-less patch in a test.
- Effort S · Risk L · Priority P0.

**P1.2 — Unsigned device IPA packaging**
- Objective: build for `iphoneos` with `CODE_SIGNING_REQUIRED=NO`, wrap `.app` into
  `Payload/` zip → `CaesarPad-<engine>-<version>-unsigned.ipa` (DevilutionX pattern).
- Dependencies: P0.1.
- Files: `scripts/package-ipa.sh`, workflow.
- Acceptance: IPA artifacts downloadable from CI; installs via Sideloadly (verified once,
  🔶 checkpoint inside P0.3 rerun).
- Effort S · Risk L · Priority P0.

**P1.3 — App identity & Info.plist overlay**
- Objective: per-flavor bundle id/name/icons; add `UIFileSharingEnabled`,
  `LSSupportsOpeningDocumentsInPlace`, `UIRequiresFullScreen`,
  `UIApplicationSupportsIndirectInputEvents`; CaesarPad app icons (original artwork — no
  Sierra/Impressions art, see licensing).
- Dependencies: P0.1. Engine-side: plist template patch if upstream's CMake hardcodes keys.
- Files: `ios/Julius/`, `ios/Augustus/`, `patches/*/info-plist-hooks.patch`.
- Acceptance: built app shows correct name/icon; app's Documents visible in Files app on
  simulator; saves creatable there.
- Effort M · Risk L · Priority P0.

**P1.4 — Nightly upstream-drift workflow**
- Objective: nightly job building upstream `HEAD` of both engines for iOS; on failure opens/
  updates a pinned issue.
- Dependencies: P0.1.
- Files: `.github/workflows/nightly.yml`.
- Acceptance: manual dispatch demonstrates both pass and simulated-failure paths.
- Effort S · Risk L · Priority P1.

## Phase 2 — Asset importer

**P2.1 — Data-set manifest & validation library**
- Objective: Swift package `CaesarPadKit/Validation`: knows required/optional Caesar III
  files (base graphics `c3.sg2/.555`, `c3_north`, language pack `c3.eng`/`c3_mm.eng` +
  localized variants, `c3_model.txt`, speech/music/video sets), detects source layout
  (GOG/Steam/CD), case-insensitive, reports `.playable/.degraded/.unplayable` with
  per-file reasons; free-space preflight.
- Dependencies: none (pure Swift).
- Files: `ios/CaesarPadKit/Sources/Validation/`, fixtures in `Tests/` (synthetic files).
- Acceptance: unit tests cover GOG, Steam, CD, missing-graphics, wrong-folder,
  music-only-missing, mixed-case; 100% of verdict logic tested.
- Effort L · Risk M (layout variance — mitigate by asking community for folder listings in
  a pinned issue) · Priority P0.

**P2.2 — Importer UI flow**
- Objective: SwiftUI flow per 03-ux §2 (welcome → instructions → picker → validation report
  → progress copy → done), cancellable copy with progress, partial-copy cleanup, relaunch
  resume.
- Dependencies: P2.1.
- Files: `ios/CaesarPadKit/Sources/Importer/`.
- Acceptance: XCUITests for happy path + unplayable path + cancel path against fixture
  folders in simulator.
- Effort L · Risk M · Priority P0.

**P2.3 — Engine handoff patch**
- Objective: patch both engines so the iOS boot path calls into CaesarPadKit's importer
  (weak hook: keep upstream's picker as fallback when Kit absent) and reads the resulting
  data path; upstream PR proposes the hook.
- Dependencies: P2.2.
- Files: `patches/julius/importer-hook.patch`, `patches/augustus/importer-hook.patch`
  (touches `src/platform/ios/ios.m`, `src/platform/<sdl>/platform.c` boot path).
- Acceptance: fresh simulator install runs Kit importer; deleting data and relaunching
  re-triggers it; upstream PRs opened.
- Effort M · Risk M · Priority P0.

**P2.4 — Data management in Settings + backup flags**
- Objective: Settings→Game data (current language/size/components), re-import, add
  music/videos later, delete data (saves preserved); set `isExcludedFromBackup` on imported
  media, not on saves.
- Dependencies: P2.2.
- Acceptance: unit + UI tests; backup flag asserted via `URLResourceValues` in test.
- Effort M · Risk L · Priority P1.

**P2.5 — Zip import (P2)**
- Objective: accept a `.zip` of the game folder in the picker; extract with progress.
- Dependencies: P2.2. Effort M · Risk L · Priority P2.

## Phase 3 — Playable city

**P3.1 — Background autosave & pause patch**
- Objective: engine event-filter for `SDL_APP_WILLENTERBACKGROUND`/`DIDENTERBACKGROUND`:
  force autosave, stop render loop, pause simulation; foreground: resume paused with
  overlay. Upstream PR (benefits Android too).
- Files: `patches/*/lifecycle.patch` (touches `src/platform/<...>/platform.c` main loop).
- Acceptance: simulator lifecycle test (backgrounding via `simctl`) shows autosave file
  written and no post-background frame; manual 🔶 device check in Phase-3 validation.
- Effort M · Risk M · Priority P0.

**P3.2 — Audio session correctness**
- Objective: set `SDL_HINT_AUDIO_CATEGORY` appropriately (playback vs ambient — decide:
  ambient, respect mute switch), verify interruption resume via SDL's CoreAudio backend;
  document behavior.
- Files: `patches/*/audio-session.patch` (hint set at init).
- Acceptance: interruption simulated (audio route change) without hang; music resumes.
- Effort S · Risk M (hardware-dependent edge cases) · Priority P0.

**P3.3 — Display defaults & safe areas**
- Objective: native bridge exporting safe-area insets + screen scale to the engine; engine
  patch consumes insets for viewport and applies per-device default display-scale on first
  run (table in 03-ux §5); home-indicator deferred mode.
- Files: `ios/CaesarPadKit/Sources/Display/`, `patches/*/safe-area.patch`
  (`src/platform/screen.c` / `SDL2/screen.c`).
- Acceptance: simulator screenshots on mini/11"/13" show no UI under indicator; logical
  viewport ≥ 640×480 on all devices; scale persisted in engine config.
- Effort M · Risk M · Priority P0.

**P3.4 🔶 — Performance validation & fixes**
- Objective: Instruments run on oldest-supported device; if < 30 fps sustained, profile and
  fix (likely candidates: texture streaming size in Julius software path; Augustus render
  batching). Findings upstreamed.
- Acceptance: 60 fps median / >30 fps p5 on a large city on A12-class hardware, recorded in
  `docs/validation/perf.md`.
- Effort M–L (unknown until measured) · Risk M · Priority P0.

**P3.5 — Save round-trip harness**
- Objective: scripted check: engine-created save files from iOS build load in desktop build
  of the same engine (run desktop engine headless-ish in CI Linux job loading the save) —
  guards serialization drift; document Julius↔vanilla and Augustus one-way contracts in
  user docs.
- Files: `ci/save-roundtrip/`, uses each engine's own build for Linux in CI.
- Acceptance: CI job loads an iOS-produced fixture save on Linux build of same engine
  without error for both engines.
- Effort M · Risk M · Priority P1.

## Phase 4 — Touch polish

**P4.1 — iPad touch-default patch** (direct tap-to-act, drag-pan, long-press right-click
  with haptic callback into Kit, two-finger tap) — touches `src/input/touch.c`,
  `src/game/system` config defaults; upstream PR flagged `#ifdef __IPHONEOS__` defaults.
  Acceptance: unit-style input-injection tests (SDL event synthesis) + 🔶 usability run.
  Effort L · Risk M · Priority P0.

**P4.2 — Pinch-zoom polish (Augustus) / display-scale pinch (Julius)** — centroid anchor,
  clamps, momentum; Julius: 3-step scale cycle on pinch threshold. Effort M · Risk M · P1.

**P4.3 — Native overlay toolbar** — pause/speed/overlay-cycle/settings buttons over the SDL
  view (UIKit, safe-area aware, auto-hide, hidden when hardware keyboard present); talks to
  engine via existing hotkey injection (synthesize SDL key events — no engine patch needed).
  Acceptance: XCUITest taps toolbar → game state changes (pause indicator visible in
  screenshot diff). Effort L · Risk M · Priority P1.

**P4.4 — Virtual keyboard & text input audit** — save-name dialog summons keyboard, layout
  not obscured (SDL `SDL_StartTextInput` path). Effort S · Risk L · P1.

**P4.5 🔶 — Scripted usability test** — 5 tasks, 2 device sizes, ≥3 testers; results filed
  as issues. Effort S (human) · Priority P0 gate for 1.0.

## Phase 5 — Pointer/keyboard/controller

**P5.1 — Indirect-pointer verification & fixes** (hover cursor, right-click, wheel-zoom
  Augustus, trackpad pinch) — likely zero engine work, tests + fixes only. Effort M ·
  Risk M · P1.
**P5.2 — Hotkey reference sheet** (native sheet reading engine hotkey config file).
  Effort S · Risk L · P1.
**P5.3 — Controller audit** (menu nav, cursor speed curves). Effort M · Risk L · P2.

## Phase 6 — Packaging & release

**P6.1 — `release.yml`** (tag → rebuild → checksummed unsigned IPAs → GitHub Release with
  templated notes incl. exact submodule SHAs + patch list for AGPL corresponding-source).
  Effort M · Risk L · P0.
**P6.2 — AltStore/SideStore source JSON on Pages, auto-updated**. Effort S · Risk L · P0.
**P6.3 — Install guides with screenshots** (AltStore, SideStore, Sideloadly, PAL,
  build-from-source). Effort M · Risk L · P0.
**P6.4 — In-app licenses/about screen** (AGPL full text, third-party notices, source link,
  engine SHA). Effort S · Risk L · P0.
**P6.5 🔶 — (Gate) Apple Developer account lanes**: notarized AltStore PAL distribution
  (EU/JP/BR) and/or TestFlight — human decision + account; automation only after the gate.
  Effort M · Risk H (policy) · P2.

## Phase 7 — Docs & launch

**P7.1 — User docs site** (Pages: install/import/controls/FAQ/troubleshooting). M · P0.
**P7.2 — Contributor docs** (architecture, patch policy, submodule bump runbook). S · P1.
**P7.3 🔶 — Coordinated launch** (maintainer heads-up, Discord/Reddit/HeavenGames posts,
  release). S · P0.
**P7.4 — Sustaining automation** (monthly submodule-bump PR bot reusing nightly results).
  M · P1.
