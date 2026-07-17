# Research Annex — Augustus (Keriew/augustus)

*Research date: July 17, 2026. Compiled from primary sources; cross-verified against direct
code inspection (see `engine-comparison.md`).*

## 1. Relationship to Julius

- "A fork of the Julius project that intends to incorporate gameplay changes… enhanced, customizable gameplay to Caesar 3 using project Julius UI enhancements" ([README](https://github.com/Keriew/augustus)). Earliest tags 1.4.x, June 2020.
- Save compatibility is one-way: "Augustus is able to load Caesar 3 and Julius saves, however saves made with Augustus **will not work** outside Augustus" (README).
- Headline additions: roadblocks, market special orders, global labour pool, partial warehouse storage, increased game limits, zoom controls; plus (release history) monuments/grand temples, building rotation (2.0.0), Tavern/Arena/sentiment system (3.0.x), hippodrome betting (3.1.0), **hardware GPU rendering + unlimited zoom** (3.2.0, Sep 2022), Highways, Custom Empires, new resources, City Mint, scenario events (4.0.0).

## 2. Architecture & divergence

- GitHub's compare view julius↔augustus fails to render ("might be too big"; ~4,077 commits, 5,000+ files changed) — massive divergence; Augustus no longer tracks Julius.
- Rendering in `src/platform/SDL2/renderer.c` with a parallel `src/platform/SDL3/` tree; zoom input in `src/input/zoom.c` (includes two-finger pinch: `zoom_update_touch`).
- Mod/asset system: `res/assets/` (Cursors, Graphics — 11 XML sprite/animation definition files, Sounds, i18n) + `src/assets/`. `ext/` adds spng, miniz, pl_mpeg (MPEG-1 video), easyav1 (AV1), sxml, zip.

## 3. Build system & targets

- CMake project version 4.0.x; `TARGET_PLATFORM` = `vita|switch|android|ios|emscripten`; **`SDL_VERSION` = 2 or 3**.
- CI builds: Flatpak, AppImage, Linux x64 (+old-SDL, +SDL3, +arm64), macOS, **iOS** (macos-latest, SDL 2.32.10/mixer 2.8.2), Switch, Vita, Android (+SDL3), Emscripten, Windows MinGW x86/x64 (+SDL3), MSVC x64, MSVC ARM64.
- Downloads via https://augustus.josecadete.net/download/ (stable + development), browser build at /play/. Android as signed APK (not on Google Play).

## 4. macOS

- dmg per release (`augustus-4.0.0-mac.dmg`); built on macos-latest; MacPorts (`augustus-caesar-3`) and Mac Source Ports ("for Apple Silicon and Intel Macs") also distribute it.
- Not notarized ([issue #960](https://github.com/Keriew/augustus/issues/960)).

## 5. Touch input

- Same touch core as Julius (`src/input/touch.c`, three modes documented in [doc/RUNNING.md](https://github.com/Keriew/augustus/blob/master/doc/RUNNING.md)) plus pinch-zoom. Android first-launch folder picker; active Android touch-UI iteration (issue filed July 17, 2026).

## 6. Maintenance & activity

- Latest stable **4.0.0, Dec 28, 2023**; continuous development builds since; wiki draft "Map Editor Update 2025 – 4.5 Release Prep" indicates 4.5 in preparation.
- Very active: master commit dated July 17, 2026; near-daily commits; owner Keriew; lead engine developer **crudelios** (José Cadete — also runs the download/browser-build server and authored the hardware renderer and easyav1).
- 2,035 stars, 165 forks, 76 open issues, 20 open PRs (July 2026).

## 7. Licenses

- Engine: **AGPL-3.0**. Extra assets (`res/assets/LICENSE`): **CC BY-SA 3.0 Unported** ("All the assets are licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported license"); license changed to CC BY-SA at 3.2.0; bundled with every build except Windows (separate download).
- Vendored `ext/` licenses verified: spng BSD-2-Clause, pl_mpeg MIT, miniz public-domain/Unlicense, tinyfiledialogs zlib. ⚠ `sxml.h` and `zip.h` vendored copies lack license headers (upstreams are permissive; housekeeping item). easyav1 license to verify (author is crudelios).

## 8. iOS history

- PR [#1161](https://github.com/Keriew/augustus/pull/1161) "iOS support" and [#1162](https://github.com/Keriew/augustus/pull/1162) "augustus-specific ios build changes" (axmo, merged Jan 12, 2025); [#1168](https://github.com/Keriew/augustus/pull/1168) icon cleanup.
- [Issue #1174 "Build iOS automatically"](https://github.com/Keriew/augustus/issues/1174) closed *not planned* (Jan 2025) — "no builds are being produced and nothing is mentioned about it in the README".
- [Issue #1458 "iOS failing to build"](https://github.com/Keriew/augustus/issues/1458) fixed Feb 10, 2026; PR [#1678 "Enable ios build temporarily"](https://github.com/Keriew/augustus/pull/1678) merged Feb 8, 2026 — iOS CI job active since.
- **No IPA in any release; iOS absent from README.** iPad demand signal: [issue #1036](https://github.com/Keriew/augustus/issues/1036) — iPad user asking for folder-picker support in the browser build.

## 9. Popularity

- v4.0.0: **42,295 downloads** (Windows 12,249, Linux 3,593, Android 1,208, macOS 1,058); v3.2.0 7,915; v3.1.0 6,298. Dev/nightly builds widely used per issue reports.
- Community: GamerZakh Discord (Augustus channel, custom-map sharing), HeavenGames scenario ecosystem, Steam Community guides, YouTube install guides.
