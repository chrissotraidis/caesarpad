# Research Annex — SDL on iOS/iPadOS & Port Precedents

*Research date: July 2026. Primary sources: libsdl-org/SDL docs, engine repos, port repos.*

## 1. SDL2/SDL3 iOS support

- iOS is first-class in both SDL2 and SDL3 ([SDL2 README-ios](https://github.com/libsdl-org/SDL/blob/SDL2/docs/README-ios.md), [SDL3 README-ios](https://github.com/libsdl-org/SDL/blob/main/docs/README-ios.md)).
- Video: SDL2 apps default to OpenGL ES; the `SDL_Renderer` API has a Metal backend on iOS (SDL3 defaults to Metal). Julius/Augustus use `SDL_Renderer`, not raw GL, so the backend choice is SDL's.
- **"Full-size, single window applications only"** (both READMEs) — no multi-window; Stage Manager resizing is unsupported; SDL iOS apps typically declare `UIRequiresFullScreen`.
- Touch: standard `SDL_FINGERDOWN/UP/MOTION` via the UIKit backend — same events the engines already consume for Android/Vita/Switch.
- Virtual keyboard: `SDL_StartTextInput()` "enables text events and reveals the onscreen keyboard".
- Controllers: MFi via `SDL_GameController` (GCController backend, `src/joystick/iphoneos/SDL_mfijoystick.m`); rumble via Core Haptics (`CHHapticEngine`).
- Build: SDL static lib + `SDL_UIKitRunApp`/`SDL_UIKitAppDelegate`; CMake supports iOS natively (`-DCMAKE_SYSTEM_NAME=iOS`, [README-cmake](https://github.com/libsdl-org/SDL/blob/main/docs/README-cmake.md)). Julius instead generates an Xcode project from its own CMake (`-DTARGET_PLATFORM=ios -G Xcode`).

## 2. SDL2_mixer on iOS

- Formats: FLAC, MP3, Ogg, VOC, WAV; **"The default MP3 implementation uses minimp3"** (bundled, no system dependency) — [SDL_mixer README](https://github.com/libsdl-org/SDL_mixer/blob/SDL2/README.txt). Caesar III's optional MP3 soundtrack therefore plays on iOS without mpg123/LGPL concerns.
- Proven: Julius iOS CI pins SDL_mixer 2.8.1; Augustus 2.8.2.

## 3. Lifecycle constraints (SDL2 README-ios, verbatim)

- `SDL_APP_WILLENTERBACKGROUND`: "Prepare your app to go into the background. Stop loops, etc."
- `SDL_APP_DIDENTERBACKGROUND`: "you have 5 seconds to save all your state or the app will be terminated."
- Events must be handled in an event filter/callback ("the OS may not give you any processing time after the events are delivered").
- Audio: SDL's CoreAudio backend manages `AVAudioSession` (category `Playback` + `MixWithOthers`, interruption pause/restart) — tunable via `SDL_HINT_AUDIO_CATEGORY`.
- Engineering implication: hook `SDL_SetEventFilter`, autosave on DIDENTERBACKGROUND, never render while backgrounded (iOS kills apps issuing GPU commands in background).

## 4. File access

- Sandbox: read-only bundle; write to `Documents/`.
- Julius's merged approach: `UIDocumentPickerViewController` (`UTTypeFolder`) + `startAccessingSecurityScopedResource` + copy into `Documents/C3` ([GameDataPickerController.m](https://github.com/bvschaik/julius/blob/master/src/platform/ios/GameDataPickerController.m)).
- Precedents: DevilutionX — sideload, then drop MPQs via Finder/iTunes file sharing; fallout2-ce — Files/iTunes sharing, lowercase filenames warning; VCMI — imports GOG offline-installer files picked on-device. Modern combo for Files-app visibility: `UIFileSharingEnabled` + `LSSupportsOpeningDocumentsInPlace`.

## 5. Precedent matrix

| Project | iOS status | Distribution |
|---|---|---|
| **Julius** | Merged upstream (PR #743, Jan 2025); CI-built | None (build-from-source) |
| **Augustus** | Merged Jan 2025 (PRs #1161/#1162); CI enabled Feb 2026 (PR #1678) | None |
| DevilutionX (Diablo) | Official | Unsigned IPA per release; AltStore/Sideloadly ([installing.md](https://github.com/diasurgical/devilutionX/blob/master/docs/installing.md)) |
| fallout2-ce | Official | Unsigned IPA; AltStore/Sideloadly or self-sign |
| VCMI (Heroes III) | Official | **Public TestFlight** + IPA sideload ([Installation iOS](https://vcmi.eu/players/Installation_iOS/)); "on the road to publication on the AppStore" |
| fheroes2 | Build-from-source only | Own certificate |
| OpenTTD | Historic App Store port (ZodTTD) pulled over GPL conflict; 3rd-party 2021 listing unpublished 2024 | None today |
| OpenRA | No iOS port (Mono/.NET) | n/a |

No third-party Julius/Augustus iOS forks of note exist — upstream *is* the iOS effort.

## 6. GPL/AGPL vs Apple distribution (summary; details in annex-licensing.md)

- GNU Go (2010) and VLC (2011) removals; VLC returned only after relicensing (MPL-2.0/LGPL).
- FSF position: App Store usage rules/DRM impose restrictions beyond what GPL permits.
- AGPL-3.0 inherits all GPLv3 store-incompatibility (the network clause is not the issue for an offline game).
- **Delta precedent (2024): AGPLv3 app on the App Store is possible when the sole copyright holder consents.** Julius/Augustus have ~50+ contributors and no CLA → consent unobtainable in practice.
- Channels (2026): unsigned IPA + AltStore Classic/SideStore/Sideloadly (user self-signs; 7-day resign on free accounts); **AltStore PAL** (EU + Japan/Brazil; UK expected 2026) — Apple-notarized alternative marketplace already hosting AGPL Delta; on-device sideloading without a computer arrived May 2026; TestFlight — practiced but legally gray (VCMI); build-from-source.

## 7. iPad-specific notes

- HiDPI: `SDL_WINDOW_ALLOW_HIGHDPI` + `SDL_GetRendererOutputSize` (SDL2); points-vs-pixels model.
- Safe area: **SDL2 has no safe-area query** (only `SDL_HINT_IOS_HIDE_HOME_INDICATOR`); SDL3 adds `SDL_GetWindowSafeArea` (3.2.0+). iPad impact is limited (home indicator + rounded corners).
- Mouse/trackpad: "iOS now supports Bluetooth mice on iPad, but by default will provide the mouse input as touch. In order to use it as a mouse, set `UIApplicationSupportsIndirectInputEvents` to true in your Info.plist" (SDL README-ios; default true when built with iOS 17+ SDK per SDL3 README).
- Hardware keyboard: normal `SDL_KEYDOWN` scancodes.
- Apple Pencil: touch in SDL2; SDL3 3.2.0+ has an explicit pen API ([PR #11753](https://github.com/libsdl-org/SDL/pull/11753)).
- External display: mirroring only; no SDL window placement support.

## 8. CI for iOS IPAs

- Julius/Augustus already run unsigned iOS builds in Actions (`xcodebuild … CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO`).
- DevilutionX is the artifact-shipping reference: build, then `mkdir Payload; mv devilutionx.app Payload && zip -r devilutionx-iOS.ipa Payload`, attach to releases ([iOS.yml](https://github.com/diasurgical/devilutionX/blob/master/.github/workflows/iOS.yml)). Unsigned IPAs are exactly what AltStore/Sideloadly consume.
