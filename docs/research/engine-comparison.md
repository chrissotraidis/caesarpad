# Engine Comparison: Julius vs Augustus

> **Method note.** Every claim in this document marked **[code]** was verified by direct
> inspection of shallow clones of `bvschaik/julius` and `Keriew/augustus` at their default
> branches on 2026-07-17. Claims marked **[web]** come from the web-research annexes in this
> folder. Claims marked **[assumption]** are explicitly flagged.

## 1. Summary table

| Dimension | Julius | Augustus |
|---|---|---|
| Project goal | 100% save-compatible re-implementation of Caesar 3; no gameplay changes **[code: README]** | Fork of Julius adding gameplay changes (roadblocks, global labor pool, zoom, monuments, custom campaigns) **[code: README]** |
| License | AGPL-3.0 **[code: LICENSE.txt]** | AGPL-3.0 **[code: LICENSE.txt]** |
| Language | C (C99-style), no C++ | C, with Objective-C for iOS/macOS glue |
| Version (2026-07) | 1.8.0-dev (`PROJECT_VERSION` 1.8.0, `IS_RELEASE_VERSION FALSE`) **[code: CMakeLists.txt]** | 4.0.x (`PROJECT_VERSION_MAJOR 4`, `MINOR 0`) **[code: CMakeLists.txt]** |
| SDL | SDL2 only | **SDL2 and SDL3** selectable via `-DSDL_VERSION=2|3` **[code: CMakeLists.txt:9-10, src/platform/SDL2 + src/platform/SDL3]** |
| Rendering | Software rendering into an SDL texture (`src/platform/screen.c`) **[code]** | Hardware `SDL_Renderer` (`src/platform/SDL2/renderer.c`, `SDL3/renderer.c`) → Metal on Apple platforms; enables zoom **[code]** |
| Zoom | No zoom | Pinch-zoom implemented (`src/input/zoom.c`, `zoom_update_touch()` computes zoom from two-finger distance) **[code]** |
| Touch input | `src/input/touch.c` with 3 modes: original / touchpad / direct; tap, double-tap, drag, two-finger scroll **[code: touch.h]** | Same touch core, plus pinch-zoom **[code]** |
| iOS target | **Yes** — `TARGET_PLATFORM=ios` in CMake, `src/platform/ios/{ios.m, GameDataPickerController.m}`, `res/ios/{Info.plist, Assets.xcassets}`, `doc/iOS.md` **[code]** | **Yes** — same structure, same files **[code]** |
| iOS in CI | Yes: `xcodebuild ... CODE_SIGNING_REQUIRED=NO -scheme julius` on `macos-latest` (SDL 2.32.8) **[code: .github/workflows/main.yml, .ci_scripts/run_build.sh]** | Yes: same, SDL 2.32.10 / mixer 2.8.2 **[code]** |
| iOS artifact published | **No** — `build_upload.sh` has no `ios` deploy case; iOS is compile-only **[code]** | **No** — same **[code]** |
| Android | Google Play release + gradle project in `android/` **[code + README]** | APK releases via project download site; adds `asset_handler.c`, `jni.c` for mod-asset handling **[code]** |
| Other platforms | Windows, Linux (AppImage/Flatpak), macOS (dmg), Vita, Switch, Emscripten **[code: README + CI matrix]** | Same set **[code: README + CI matrix]** |
| Video playback | Smacker (.smk) via internal decoder | Adds `pl_mpeg` (MPEG-1) and `easyav1` (AV1) for enhanced/community videos **[code: ext/]** |
| Extra deps | SDL2, SDL2_mixer, png, zlib, tinyfiledialogs, dirent **[code: ext/]** | SDL2/3, SDL2_mixer, spng, miniz, zip, sxml, tinyfiledialogs, easyav1, pl_mpeg **[code: ext/]** |
| Mod/asset extensions | None (vanilla look) | `src/assets/` + XML-defined extra assets pack (community-made graphics), zip support **[code]** |
| Save compatibility | 100% two-way with original Caesar 3 **[code: README]** | Reads C3 and Julius saves; **Augustus saves cannot be loaded by Julius/vanilla** **[code: README]** |
| Required data version | Caesar 3 (GOG/Steam/CD) | Caesar 3 patched to **1.0.1.0** **[code: README]** |
| Crash handling | — | `src/platform/crash_handler.c` **[code]** |
| Localized text | `src/translation/` (~20 languages) **[code]** | Same, superset **[code]** |

## 2. Architecture

Both engines share the same layered architecture inherited from Julius:

```
src/
  core/        — primitives: file, string, image loading, config, random, zip…
  building/ city/ empire/ figure/ figuretype/ map/ scenario/ — game simulation
  game/        — game loop, state, save I/O, tutorial, mission logic
  graphics/    — drawing primitives, fonts, video, windows (engine-side)
  input/       — mouse, keyboard, touch, joystick, hotkeys, scroll, (zoom)
  sound/       — music/speech/effects logic
  widget/ window/ — UI widgets and screens (advisors, build menus, dialogs)
  platform/    — SDL glue: main loop, screen, sound device, per-OS backends
  translation/ — language packs
```

The **only OS-facing layer is `src/platform/`** — the simulation and UI code above it is
portable C that already runs on 8+ platforms. This is the crucial architectural fact for an
iPad port: everything iPad-specific lands in `src/platform/` (+ `res/ios/`), which is exactly
where upstream already placed the existing iOS code. **[code]**

Divergence: Augustus restructured the platform layer into `src/platform/SDL2/` and
`src/platform/SDL3/` backends and replaced Julius's software blitter with an
`SDL_Renderer`-based hardware renderer to support zoom and larger maps. Outside `platform/`,
the fork has drifted heavily: a directory-level diff shows a large majority of files in
`core/`, `game/`, `city/`, `building/`, `figure/`, `map/` differ between the two projects
(e.g. 88 differing entries in `building/`, 53 in `city/`, 51 in `core/`). **[code: diff -rq]**

**Implication:** the two codebases cannot share a literal common platform layer today; they
are parallel implementations of the same layering. Supporting both engines means building
*per-engine* from near-identical recipes, not linking one platform library into both.

## 3. iOS support as it exists upstream today

Verified facts **[code]**:

- `cmake .. -DTARGET_PLATFORM=ios -G Xcode` generates a working Xcode project on both engines
  (documented in each repo's `doc/iOS.md`; exercised in each repo's GitHub Actions matrix on
  `macos-latest`).
- The CMake target sets `CMAKE_SYSTEM_NAME=iOS`, `SDKROOT=iphoneos`, and
  `TARGETED_DEVICE_FAMILY` iPhone+iPad ("Support iPhone (1) and iPad (2) Destinations" comment).
- First-launch import: `GameDataPickerController` presents a `UIAlertController` explaining
  that game data is required, then a `UIDocumentPickerViewController` (`UTTypeFolder`) for the
  user to pick their C3 folder; the folder is **copied** (via security-scoped resource access)
  into `Documents/C3` and the engine is pointed there.
- `Info.plist` declares all four orientations, a launch screen, and `LSRequiresIPhoneOS`; it
  does **not** declare `UIFileSharingEnabled`, `LSSupportsOpeningDocumentsInPlace`, document
  types, or any iPad-multitasking/Stage Manager keys.
- Julius's iOS platform code was contributed by an external contributor in Dec 2024–Jan 2025
  (commits by Alex Montgomery: importer error alerts, instructions dialog, cleanups). **[web:
  GitHub commits API for `src/platform/ios`]**
- CI builds the iOS scheme unsigned (`CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO`) but the
  upload script has no iOS case, so **no .ipa or .app artifact is ever published**.

Known upstream gaps (each is a CaesarPad work item, see PRD):

1. No packaged, signed or sideloadable IPA; no distribution channel at all.
2. Importer is minimal: single folder copy, no validation of required files before copy, no
   re-import/replace flow (`copyItemAtPath` fails if `Documents/C3` already exists), no
   progress UI for the ~600 MB videos/music copy, 300-byte fixed path buffers.
3. No `UIFileSharingEnabled`/`LSSupportsOpeningDocumentsInPlace` → saves are trapped in the
   sandbox, invisible to the Files app.
4. No safe-area handling, no per-device display tuning, no external display or Stage Manager
   consideration.
5. Touch UX is the generic Julius touch layer (built for Vita/Switch/Android); no
   iPad-specific gestures beyond what SDL forwards; Julius lacks pinch-zoom entirely
   (no zoom feature).
6. No iOS-side settings surface (touch mode is cycled via hotkey/config file, not exposed in
   a touch-friendly way at first run).
7. No audio-session/background-lifecycle hardening beyond SDL defaults.

## 4. Portability & build system

- Both: single top-level `CMakeLists.txt` with `TARGET_PLATFORM` switch
  (`vita|switch|android|ios|emscripten|default`), vendored fallback deps under `ext/`,
  GitHub Actions matrix covering ~9 targets. **[code]**
- SDL2/SDL2_mixer are fetched as source releases and compiled into the iOS target via the
  generated Xcode project (`install_sdl_ios` in `.ci_scripts/install_dependencies.sh`). **[code]**
- Augustus's SDL3 backend (SDL3 has first-class iOS/Metal support) is a forward-compatibility
  asset, but its CI iOS job still pins SDL2. **[code]**

## 5. Maintenance & community (see community annex for details)

- Julius: feature-frozen by design (goal met at v1.7); development activity is low; the
  README itself points players wanting new features to Augustus. **[code: README; web]**
- Augustus: actively developed (4.x releases, active Discord, scenario-sharing ecosystem,
  in-README download portal with dev builds). **[code: README; web]**

## 6. Recommendation

**Foundation: Augustus, with Julius kept buildable as a secondary flavor.**

Rationale:

1. **iPad-fit features live in Augustus.** Pinch-zoom (`input/zoom.c` + hardware renderer) is
   the single most important interaction primitive for a touch city-builder; Julius has no
   zoom at all and its software blitter makes adding it costly.
2. **Augustus is where the maintainers and players are** (active releases, Discord, scenario
   community); upstreaming iPad polish there benefits from review and survives engine churn.
3. **Julius support stays cheap** because the platform/iOS surface of both projects is
   nearly identical (same files, same CMake switch, same importer); a thin per-engine overlay
   lets CaesarPad produce a "Julius flavor" build for purists who need two-way vanilla save
   compatibility.
4. **Both-engine support is realistic only at the packaging level** (two IPAs from two
   submodules built by one pipeline), not at the code-sharing level (the trees have diverged
   too far to share a compiled platform layer).

Strategy: **wrapper repo + submodules + upstream-first patches** — do not hard-fork. See PRD
§Technical Requirements for the concrete repository design.
