# PRD — Engineering Roadmap

Phases are sequential gates; tasks within a phase parallelize (see 05-task-breakdown.md).
Effort assumes autonomous coding agents with human review, one macOS/Xcode-capable CI lane,
and at least one physical iPad for hardware validation checkpoints (marked 🔶 — these cannot
be fully automated).

## Phase 0 — Research validation (this document set) ✅→🔶

Goal: confirm the paper findings on real hardware before committing to the plan.

- 0.1 Reproduce upstream iOS builds: `cmake -DTARGET_PLATFORM=ios -G Xcode` for Julius
  (pinned SHA) and Augustus (pinned SHA); build for Simulator in CI. **Exit: both engines
  boot to the "Game Data Required" alert in the iPad Simulator.**
- 0.2 🔶 Device smoke test: sideload both onto one physical iPad with GOG data; play 15
  minutes; record: fps, touch behavior, audio, import quirks, crash on background/resume.
- 0.3 File upstream issues for anything broken found in 0.2 (establishes the
  upstream-first relationship early).
- Kill criteria: if either engine fails to run acceptably on device and the cause is
  architectural (not a fixable bug), fall back to single-engine scope (Augustus).

## Phase 1 — Successful iPad build, repeatable (CaesarPad skeleton)

Goal: this repo builds both engines for iOS from clean checkout, in CI, every commit.

- 1.1 Repo scaffolding: submodules (`engines/julius`, `engines/augustus`), `scripts/`
  (fetch-deps, apply-patches, build-ios, package-ipa), patch-queue mechanism.
- 1.2 CI `build.yml`: matrix build (2 engines × simulator/device-unsigned), artifact upload
  of unsigned IPAs (DevilutionX `Payload/` zip pattern).
- 1.3 App identity: bundle ids, icons, display names ("CaesarPad · Julius", "CaesarPad ·
  Augustus"), Info.plist additions (`UIFileSharingEnabled`,
  `LSSupportsOpeningDocumentsInPlace`, `UIRequiresFullScreen`,
  `UIApplicationSupportsIndirectInputEvents`).
- 1.4 Nightly upstream-drift workflow.
- **Exit: green CI producing two installable unsigned IPAs from a tag.**

## Phase 2 — Asset importing (CaesarPadKit/Importer)

Goal: the first-launch flow in 03-ux-requirements §2, replacing upstream's minimal picker.

- 2.1 Validation engine: required-file manifest (per language/source), case-insensitive
  scan, GOG/Steam/CD layout knowledge, free-space preflight. Pure Swift, unit-tested with
  fixture folders (synthetic files — no copyrighted content).
- 2.2 Importer UI: welcome → instructions → picker → validation report → progress copy →
  done; cancellation/resume; delete-partial-on-failure.
- 2.3 Engine handoff patch: replace `ios_show_c3_path_dialog` call path with CaesarPadKit
  flow (patch in `patches/`, PR'd upstream as an optional hook).
- 2.4 Re-import/manage-data in Settings; backup-exclusion flags on imported media.
- **Exit: fresh install → playing, using only an iPad + Files app, per walkthrough test;
  all validation unit tests green.**

## Phase 3 — Playable city (engine integration hardening)

Goal: the game is *correct* on iPad, not yet *delightful*.

- 3.1 Lifecycle: autosave on `SDL_APP_DIDENTERBACKGROUND` (event-filter patch), pause when
  inactive, resume-with-paused-overlay, no GPU work in background.
- 3.2 Audio session: category/interruption handling verified (calls, Siri, mute switch).
- 3.3 Display: per-device default display scale, safe-area inset bridge, home-indicator
  deferral, orientation support.
- 3.4 🔶 Performance pass: Instruments on oldest-supported iPad; fix anything under 30 fps;
  target 60.
- 3.5 Save round-trip verification: Julius save → desktop vanilla C3 and back; Augustus
  save → desktop Augustus and back (Files export).
- **Exit: 2-hour play session on device without crash, data loss, or audio glitch; save
  round-trips verified.**

## Phase 4 — Touch polish

Goal: the control scheme in 03-ux-requirements §3.

- 4.1 iPad touch defaults patch (direct tap-to-click on map+UI, drag-pan, long-press right-
  click with haptic, two-finger tap).
- 4.2 Pinch-zoom polish (Augustus): centroid anchoring, momentum, min/max clamps; Julius:
  pinch → display-scale stepping.
- 4.3 Native overlay toolbar (pause, speed, overlays, settings) with auto-hide + keyboard-
  attached suppression.
- 4.4 Virtual keyboard interplay (save naming) and long-press timing options.
- 4.5 🔶 Touch usability test: 5 scripted tasks (place housing block, run aqueduct, quell
  fire, use advisors, win a mission start) executed by testers on 11" and 13" hardware.
- **Exit: all 5 tasks completable with touch alone, no instruction sheet.**

## Phase 5 — Keyboard / trackpad / controller polish

- 5.1 `UIApplicationSupportsIndirectInputEvents` verification: hover, right-click, scroll,
  trackpad pinch (Augustus zoom).
- 5.2 Hotkey reference sheet (native, generated from engine hotkey config).
- 5.3 Controller mapping pass-through + menu navigation audit (P2 — may slip post-1.0).
- **Exit: Magic Keyboard user gets desktop-parity play.**

## Phase 6 — Packaging & distribution

- 6.1 `release.yml`: tag → deterministic rebuild → unsigned IPAs attached to GitHub Release
  with checksums.
- 6.2 AltStore/SideStore source JSON on GitHub Pages, auto-updated per release.
- 6.3 Install guides (per-channel, screenshots) + release-page template.
- 6.4 AGPL compliance kit: in-app license screen, corresponding-source pinning (release ==
  exact submodule SHAs + patch set), THIRD-PARTY-NOTICES.
- 6.5 (Decision gate) EU AltStore PAL / notarization lane and/or TestFlight lane — requires
  an Apple Developer account and the legal posture in 08-release-strategy §3.
- **Exit: a non-developer installs via AltStore source in < 10 min following the guide.**

## Phase 7 — Documentation & community launch

- 7.1 User docs site (GitHub Pages): install, import, controls, FAQ, troubleshooting.
- 7.2 Contributor docs: architecture, patch-queue workflow, upstream-first policy.
- 7.3 Launch posts: Julius/Augustus Discord (GamerZakh server), r/caesar3,
  r/impressionsgames, HeavenGames; coordinate with upstream maintainers first.
- 7.4 Post-launch: issue triage rotation, upstream-sync cadence (monthly submodule bump),
  crash-report intake via diagnostics export.

## Effort estimate (calendar-agnostic, agent-executed with human review)

| Phase | Size | Dominant risk |
|---|---|---|
| 0 | S (days) | Device access 🔶 |
| 1 | M (1–2 wk) | Xcode/CMake glue brittleness |
| 2 | M–L (2–3 wk) | Layout variance across GOG/Steam/CD/languages |
| 3 | M (1–2 wk) | Lifecycle/audio edge cases need hardware |
| 4 | L (2–4 wk) | UX iteration is inherently human-in-the-loop |
| 5 | S–M (1 wk) | SDL iPadOS pointer quirks |
| 6 | M (1–2 wk) | Signing/notarization decisions, not code |
| 7 | S–M (1 wk) | — |

Total: roughly **2–3 engineer-months equivalent** to a polished 1.0, dominated by phases 2
and 4. A "developer preview" (phases 0–2) is reachable in **2–3 weeks**.
