# PRD — Functional Requirements

Requirement IDs are stable; priorities: **P0** = launch blocker, **P1** = 1.0, **P2** = post-1.0.
"[exists upstream]" marks behavior already implemented in Julius/Augustus that CaesarPad
inherits and must not regress.

## FR-1 Asset importing

- **FR-1.1 (P0)** First launch with no game data must open the importer flow — a native
  explanation screen, then a folder picker (`UIDocumentPickerViewController`, `UTTypeFolder`).
  [exists upstream, minimal form]
- **FR-1.2 (P0)** Pre-copy validation: before copying, scan the picked folder
  (case-insensitively) for the engine's required files — at minimum `c3.emp`-era data:
  `C3.eng`/language equivalent, `C3_model.txt`, `.sg2`+`.555` graphics pairs — and report
  *which* files are missing with guidance per source (GOG offline installer, Steam folder,
  CD "Full installation", 1.0.1.0 patch note for Augustus).
- **FR-1.3 (P0)** Copy with progress UI (file count + bytes; music/videos can approach
  1 GB), cancellable, resumable on relaunch. Failure surfaces the OS error and returns to
  the picker (never a dead end). Replaces upstream's silent one-shot `copyItemAtPath` (which
  fails outright if a partial copy exists).
- **FR-1.4 (P1)** Optional components: user may skip videos and/or music to save space;
  importer records what was skipped and offers to add them later from Settings.
- **FR-1.5 (P1)** Re-import / replace data from Settings (e.g., switching language versions),
  preserving saves.
- **FR-1.6 (P2)** Import from a `.zip` of the game folder (common way people move GOG
  installs), extracted on-device.
- **FR-1.7 (P0)** Never bundle, download, or link to copyrighted game data. Importer copy
  explicitly states the user must own Caesar III and shows where to buy it (GOG/Steam).

## FR-2 Input

- **FR-2.1 (P0)** Touch: full game playable with touch alone. Inherit engine touch layer
  (tap = click, drag, two-finger scroll, touch modes) [exists upstream]; add iPad defaults:
  direct-touch mode with tap-to-act on UI, drag-to-pan on map, long-press for right-click
  (context/info), two-finger tap as alternate right-click.
- **FR-2.2 (P0, Augustus)** Pinch-to-zoom mapped to the engine zoom [exists upstream:
  `zoom_update_touch`]; smooth, anchored at gesture centroid.
- **FR-2.3 (P1)** Hardware keyboard: engine hotkeys work on external/Magic Keyboard
  [exists upstream via SDL]; publish a hotkey reference in-app; ⌘-based iPad conventions
  (⌘, for settings) where they don't collide with game hotkeys.
- **FR-2.4 (P1)** Trackpad/mouse: SDL pointer events give full desktop-equivalent control,
  including right-click and scroll-wheel zoom (Augustus); hover states work. Requires
  `UIApplicationSupportsIndirectInputEvents` and testing of SDL's iPadOS pointer path.
- **FR-2.5 (P2)** Game controller: navigate map + menus with MFi/DualSense/Xbox controllers
  via the engines' joystick mapping [exists upstream: joystick.c + 2026 controller
  auto-binding work in Julius].
- **FR-2.6 (P2)** Apple Pencil: treated as precise touch (tap = click); no special mode at
  launch, evaluate hover on M-series iPads later.
- **FR-2.7 (P1)** On-screen virtual keyboard summoned automatically for text fields (save
  names, city name) [exists upstream: virtual_keyboard.c]; verify iPadOS behavior and safe
  -area interplay.

## FR-3 Saves & files

- **FR-3.1 (P0)** Saves live in the app's Documents directory and the app declares
  `UIFileSharingEnabled` + `LSSupportsOpeningDocumentsInPlace` so users can browse, copy,
  and delete saves from the Files app.
- **FR-3.2 (P1)** Export/import a save via the iOS share sheet from the in-game load/save
  dialog area (native affordance around the engine UI is acceptable: a "Manage saves"
  native screen).
- **FR-3.3 (P1)** Engine-correct compatibility messaging: Julius saves interchange with
  vanilla C3; Augustus saves are one-way (loads C3/Julius, exports only Augustus-compatible)
  — surfaced in the Manage-saves UI so users don't discover it by data loss.
- **FR-3.4 (P2)** Optional iCloud Drive container for saves (toggle in Settings; default
  off to avoid sync conflicts with a single shared `Documents`); conflict policy documented.
- **FR-3.5 (P0)** Backup hygiene: imported game data marked `isExcludedFromBackup = true`
  (re-importable, ~1 GB); saves and settings included in iCloud/iTunes backup.

## FR-4 Display

- **FR-4.1 (P0)** Fullscreen native-resolution rendering with correct HiDPI scaling on all
  current iPads (11"/13" Pro & Air, 10.9" base, 8.3" mini). Engine display-scale option
  exposed in Settings with per-device sane defaults (target: UI elements ≥ 44 pt effective).
- **FR-4.2 (P0)** Safe-area handling: game viewport respects rounded corners/home indicator;
  no interactive element under the indicator.
- **FR-4.3 (P1)** Orientation: landscape both ways; portrait allowed but not tuned.
- **FR-4.4 (P0→P2)** Multitasking: SDL on iOS is a single fullscreen window ("Full-size,
  single window applications only" — SDL README-ios), so v1.0 declares `UIRequiresFullScreen`
  and does not support Stage Manager resizing. Post-1.0: investigate resizable behavior
  (engine already handles live desktop resize, so the blocker is SDL's UIKit backend, not the
  engine).
- **FR-4.5 (P2)** External display: mirrored by default; "game on external, controls on
  iPad" is out of scope.

## FR-5 Audio

- **FR-5.1 (P0)** Music, speech, ambient effects via SDL2_mixer [exists upstream]; correct
  iOS audio-session category (ambient vs solo), respecting the mute switch/background rules.
- **FR-5.2 (P1)** Pause/duck on interruption (call, Siri, other app audio) and resume
  correctly; no audio after backgrounding.
- **FR-5.3 (P2)** High-quality MP3 soundtrack support if user imports the files
  [exists upstream].

## FR-6 Lifecycle

- **FR-6.1 (P0)** Auto-save or state-preserve on backgrounding; process kill while
  backgrounded must lose at most the last few minutes (engine has autosave; wire
  `SDL_APP_WILLENTERBACKGROUND` to force one).
- **FR-6.2 (P0)** Clean resume from background including GPU texture revalidation (Metal via
  SDL — verify no context loss artifacts).
- **FR-6.3 (P1)** Fast app switching under Stage Manager doesn't stall simulation
  incorrectly (game pauses while inactive; explicit "paused" overlay on return).

## FR-7 Settings & configuration

- **FR-7.1 (P0)** Native settings screen (reachable pre-game and via an unobtrusive in-game
  affordance) covering: touch mode, display scale, audio volumes, language/data folder,
  save management, importer re-run, licenses/credits.
- **FR-7.2 (P1)** Engine config files (`julius.cfg` / Augustus equivalents) remain the
  source of truth — the native UI reads/writes them so desktop-style config stays valid.
- **FR-7.3 (P2)** Per-engine extras: expose Augustus's own config UI as-is (it has one);
  don't duplicate it natively.

## FR-8 Mod support (Augustus flavor only)

- **FR-8.1 (P2)** Augustus custom assets pack (required for Augustus's extra buildings) is
  fetchable/importable like game data (it is freely distributed by the Augustus project);
  custom scenarios/campaigns importable via Files.
- **FR-8.2 (P2)** No mod marketplace, no in-app downloads of third-party content beyond the
  official Augustus assets.

## FR-9 Diagnostics

- **FR-9.1 (P1)** In-app log viewer / "export diagnostics" (engine log + device info) to
  make sideload-user bug reports actionable. No telemetry, no network calls (also keeps the
  AGPL network clause trivially satisfied).
