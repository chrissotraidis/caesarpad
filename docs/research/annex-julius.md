# Research Annex — Julius (bvschaik/julius)

*Research date: July 17, 2026. Compiled from primary sources (GitHub repo, API, issues, PRs,
wiki); each claim cited. Cross-verified against direct code inspection (see
`engine-comparison.md`).*

## 1. Project goals and scope

- Julius is "a fully working open-source version of Caesar 3, with the same logic as the original, but with some UI enhancements, that can be played on multiple platforms." — [README](https://github.com/bvschaik/julius)
- Strict fidelity policy: "The goal of the project is to have exactly the same game logic as Caesar 3, with the same look and feel. This means that the saved games are 100% compatible with Caesar 3, and any gameplay bugs present in the original Caesar 3 game will also be present in Julius." (README)
- UI enhancements only (widescreen, windowed mode, QoL, high-quality MP3 support); gameplay changes are out of scope: "a fork of Julius named Augustus is implementing many long-wanted gameplay changes, such as roadblocks." (README)

## 2. Architecture

- **Language:** C99 (`set(CMAKE_C_STANDARD 99)` in [CMakeLists.txt](https://github.com/bvschaik/julius/blob/master/CMakeLists.txt)); GitHub reports 97.9% C.
- **Layout:** `src/{building, city, core, editor, empire, figure, figuretype, game, graphics, input, map, platform, scenario, sound, translation, widget, window}`.
- **Platform abstraction:** all OS/SDL-facing code in [`src/platform/`](https://github.com/bvschaik/julius/tree/master/src/platform) — `julius.c` (entry), `screen.c`, `sound_device.c`, `cursor.c`, `file_manager.c`, `prefs.c`, `virtual_keyboard.c`, plus per-target dirs `android/`, `emscripten/`, `ios/`, `switch/`, `vita/`.
- **SDL2 usage:** SDL2 + SDL2_mixer required. Game controllers: commit 2026-04-28 by crudelios — "Add support for game controllers with auto key binding and enable controller support for android".
- **Rendering:** software renderer — game draws into its own framebuffer, streamed per frame into an `SDL_PIXELFORMAT_ARGB8888` / `SDL_TEXTUREACCESS_STREAMING` texture, presented via `SDL_CreateRenderer(SDL.window, -1, SDL_RENDERER_PRESENTVSYNC)`. Upscaling via display-scale percentage + `SDL_RenderSetLogicalSize()`; nearest-neighbor at integer multiples (except Apple/Android), otherwise linear. HiDPI via `SDL_WINDOW_ALLOW_HIGHDPI`. ([src/platform/screen.c](https://github.com/bvschaik/julius/blob/master/src/platform/screen.c))

## 3. Build system and CI

- CMake ≥ 3.10; cross-compile via `TARGET_PLATFORM` = `vita|switch|android|ios|emscripten|default`.
- iOS: `CMAKE_SYSTEM_NAME=iOS`, `SDKROOT=iphoneos`, SDL2/SDL2_mixer compiled from source as static libs. macOS: bundle `com.github.bvschaik.julius`, deployment target 10.10, ad-hoc signing.
- CI ([main.yml](https://github.com/bvschaik/julius/blob/master/.github/workflows/main.yml)): matrix over ubuntu-24.04 (Linux x64/AppImage/Flatpak/Android/Emscripten/Switch/Vita), macos-latest (macOS + **iOS**, SDL 2.32.8, mixer 2.8.1), windows-latest (MinGW + MSVC). Android APKs CI-signed. **No macOS notarization. No iOS deploy case in `build_upload.sh` — iOS is compile-only.**
- Android: Gradle wraps the same CMake tree (`-DTARGET_PLATFORM=android`), AGP 8.11.1, Play-publisher plugin, minSdk 21, 4 ABIs; published on [Google Play](https://play.google.com/store/apps/details?id=com.github.bvschaik.julius).

## 4. macOS support

- `julius-1.8.0-mac.dmg` (2,409 downloads). Universal binary: CI sets `CMAKE_OSX_ARCHITECTURES="x86_64;arm64"` → native Apple Silicon.
- Not notarized/Developer-ID signed; wiki documents the Gatekeeper `xattr` workaround ([Running Julius on macOS](https://github.com/bvschaik/julius/wiki/Running-Julius-on-macOS)).

## 5. Touch support

- Cross-platform touch layer [`src/input/touch.c`](https://github.com/bvschaik/julius/blob/master/src/input/touch.c): multi-touch tracking, tap/double-tap (`CLICK_TIME 300` ms, `NOT_MOVING_RANGE 5` px), two-finger scroll (`SCROLL_FINGER_RADIUS 25` px), touch-to-mouse conversion, three switchable modes (original / touchpad / direct).
- Originated with the Vita/Switch ports (rsn8887 is the #4 all-time contributor); consumed by Android and the iOS port.

## 6. Maintenance status

- Latest release **v1.8.0, July 31, 2025** (first since v1.7.0, Oct 14, 2021).
- Last commit 2026-06-23 ("Bump actions versions in pipeline", bvschaik); steady low-volume activity (crash fix 2026-06-22, controllers 2026-04-28).
- 3,320 stars, 424 forks, 10 open issues, 50 contributors (bvschaik 2,316 commits, crudelios 279).
- Effectively a stable/maintenance project; features flow to Augustus.

## 7. License

- **AGPL-3.0** ([license API](https://api.github.com/repos/bvschaik/julius/license)). bvschaik cited GPL-family incompatibility with App Store terms as the reason store distribution is "out of bounds" ([issue #643](https://github.com/bvschaik/julius/issues/643)).
- `ext/`: SDL2 (zlib), dirent (MIT), png (PNG Reference Library v2), tinyfiledialogs (zlib), zlib (zlib).

## 8. Save/asset compatibility

- Requires original Caesar 3 assets (CD "Full installation", GOG, or Steam), patched to **1.0.1.0**; localized versions supported (v1.8.0 added Czech, Greek, Japanese).
- Saves are fully two-way compatible with original Caesar 3 (README).
- Optional Sierra high-quality MP3 soundtrack ([wiki: MP3 Support](https://github.com/bvschaik/julius/wiki/MP3-Support)).

## 9. iOS history — the decisive finding

- [Issue #643 "iOS Support planned?"](https://github.com/bvschaik/julius/issues/643) (Feb 2022 – Jan 2025, 24 comments): initially declined (640×480 minimum vs iPhone screens, iOS file-storage constraints, GPL-vs-App-Store). Nov 2024, bvschaik: *"I don't mind having Julius build for iOS, just the App Store is out of bounds."* Jan 2025: *"It builds and works, BUT: it requires the user to compile and install it on their iPhone/iPad themselves… Providing a downloadable ipa won't work since that's not signed."* Distribution discussion covered AltStore/Sideloadly and AltStore PAL.
- [PR #743 "Add iOS build support"](https://github.com/bvschaik/julius/pull/743) by **axmo**, opened Dec 27, 2024, **merged Jan 9, 2025**: `TARGET_PLATFORM=ios`, static SDL2/SDL2_mixer, `src/platform/ios/` (ios.m, GameDataPickerController.m — UIDocumentPicker import flow).
- CI builds iOS on every push; **no .ipa in any release**. No notable independent iOS fork exists — the iOS effort was upstreamed.

## 10. Popularity

- v1.8.0 downloads (first year): windows.zip 14,401; mac.dmg 2,409; AppImage 2,327; android.apk 1,428; switch 596; vita 528. v1.7.0 lifetime: windows.zip 40,897. Lifetime GitHub downloads ≈ 98k across v1.4–1.8.
- Google Play: ~39,000 installs per AppBrain (≈ 10–25× the per-release direct APK downloads — store distribution multiplies reach).
