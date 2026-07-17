# PRD — Testing Plan

## 1. Test layers

| Layer | Runs | Owner |
|---|---|---|
| Kit unit tests (validation, settings IO, save manager) | Every PR, simulator-less (SPM) | CI |
| XCUITest UI flows (importer, settings, toolbar) | Every PR, iPad simulator, synthetic fixtures | CI |
| Boot smoke (both engines reach first-run alert) | Every PR | CI |
| Save round-trip (iOS-built save loads in Linux build of same engine) | Every PR | CI |
| Patch-apply + upstream-drift | Every PR / nightly | CI |
| Performance (Instruments traces) | Per release + on renderer-touching changes | Human 🔶 |
| Device matrix session (checklist below) | Per release candidate | Human 🔶 |

**Fixture policy:** all automated tests use synthetic data — generated files matching the
engines' presence/size checks (names/headers only, no copyrighted content). Real-asset tests
are manual-only, on testers' own purchased copies.

## 2. Device matrix

| Device | Class | Why |
|---|---|---|
| iPad Pro 13" (M4) | Largest, 120 Hz, Pencil Pro | Flagship experience |
| iPad Air 11" | Mainstream mid | Default tuning target |
| iPad (10th gen, A14) | Slowest common | Performance floor |
| iPad mini (8.3", A17 Pro) | Smallest screen | Touch-target floor; 640×480 logical minimum check |
| Oldest OS-supported device available (A12) | Floor of deployment target | Boot + perf sanity |

Per-device release checklist: import (GOG + Steam layouts) · 30-min play · background/resume
×5 · audio interruption (timer/call) · rotation · screenshot of scale defaults · Files-app
save visibility.

## 3. Input matrix

| Input | Cases |
|---|---|
| Touch | 5 scripted tasks (housing block, aqueduct run, fire response, advisors, mission start); all three touch modes; long-press timing; two-finger scroll/tap; pinch zoom (Augustus) |
| Hardware keyboard | Hotkey sample (pause, speed, overlays, save/load), text entry, Esc navigation |
| Trackpad/mouse | Hover cursor, left/right click, wheel/pinch zoom, edge scroll |
| Controller | Pair MFi + Xbox + DualSense; cursor, click, menu nav |
| Pencil | Tap precision, drag-build, long-press |
| Virtual keyboard | Save naming: appears, doesn't obscure field, dismisses |

## 4. Regression testing

- CI re-runs the full automated suite on every submodule bump; the nightly drift job catches
  upstream breakage between bumps.
- Golden-screenshot tests for importer and settings screens (per device size class).
- Each fixed bug that had a deterministic repro gets a regression test in the same PR.

## 5. Performance testing

- Targets: 60 fps median / ≥30 fps p5 on A14 in a 10k-pop city (Augustus at 100% zoom;
  Julius at default scale); < 3 s cold boot to menu (post-import); import throughput
  ≥ 30 MB/s on-device copy; memory < 1 GB (Augustus zoomed out on 13").
- Method: Instruments (Time Profiler, Metal System Trace) on 🔶 sessions; results recorded
  in `docs/validation/perf.md` per release; regressions >10% block release.

## 6. Save testing

- Round-trip per engine (automated, per PR — see §1).
- Manual per release: Julius iOS ↔ desktop vanilla C3 (GOG under Wine/CrossOver or real PC);
  Augustus iOS ↔ desktop Augustus same version; Augustus loads a vanilla `.sav`.
- Autosave-on-background creates a loadable save (automated via `simctl` backgrounding).
- Corrupt-save handling: truncated file fixture → engine error surfaced, no crash-loop.

## 7. Lifecycle testing

- Background/foreground ×20 loop (automated `simctl`) — no leaks (memgraph), no audio after
  background, paused overlay on return.
- Kill-while-backgrounded → relaunch resumes from autosave.
- Interruption matrix: alarm, incoming FaceTime (device 🔶), Siri, control-center audio
  steal, mute-switch behavior.
- Low-storage import attempt (simulated small volume) → preflight refusal, no partial state.
- OS restart with data present → straight to menu.

## 8. Touch testing (usability gate)

- Phase-4 exit: ≥3 testers × 2 device sizes complete the 5 scripted tasks unaided; task
  time and error notes filed as issues. Repeat before 1.0 with ≥5 external beta testers
  recruited from the Augustus Discord.
