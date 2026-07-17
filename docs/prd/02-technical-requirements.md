# PRD — Technical Requirements

Status: Draft grounded in code inspection of `bvschaik/julius` and `Keriew/augustus`
(2026-07-17). See `docs/research/` for evidence.

## 1. Architecture principles

1. **Upstream-first, fork-never.** Both engines already contain a working iOS target
   (`TARGET_PLATFORM=ios`), an iOS platform backend (`src/platform/ios/`) and CI coverage.
   CaesarPad's engine-side changes must be written as upstreamable patches against those
   trees; CaesarPad itself is a *packaging, polish and distribution* layer, not an engine fork.
2. **Engines as submodules, never vendored copies.** Divergence between Julius and Augustus is
   too large to unify code; the realistic dual-engine strategy is one build pipeline producing
   two app targets from two pinned submodules.
3. **Everything iPad-specific stays in the platform seam.** Upstream's own layering puts all
   OS code in `src/platform/` + `res/ios/`; CaesarPad additions (importer UX, safe areas,
   settings, iCloud) must respect that seam so patches remain small and reviewable.
4. **Native where Apple is opinionated, SDL where the game is opinionated.** File import,
   alerts, share sheets, iCloud, haptics → UIKit/native. Rendering, game UI, audio mixing,
   in-game input routing → SDL/engine (unchanged).

## 2. Repository structure (target)

```
caesarpad/
├── README.md
├── LICENSE                       # AGPL-3.0 (required: derivative of AGPL engines)
├── docs/                         # this PRD, research, build & user guides
├── engines/
│   ├── julius/                   # git submodule → bvschaik/julius (pinned SHA)
│   └── augustus/                 # git submodule → Keriew/augustus (pinned SHA)
├── patches/                      # quilt-style patch queues, one dir per engine.
│   ├── julius/                   #   Applied at build time until upstreamed; each patch
│   └── augustus/                 #   carries a header linking its upstream PR.
├── ios/
│   ├── CaesarPadKit/             # shared Obj-C/Swift: importer UI, validation,
│   │                             #   settings host, iCloud/backup, haptics, review nags
│   ├── Julius/                   # thin app-target glue (bundle id, icons, plist)
│   └── Augustus/
├── scripts/
│   ├── fetch-deps.sh             # SDL2/SDL2_mixer source releases → engines/*/ext/SDL2/
│   ├── apply-patches.sh
│   ├── build-ios.sh              # cmake -DTARGET_PLATFORM=ios -G Xcode + xcodebuild archive
│   └── package-ipa.sh            # unsigned .ipa for sideloading; signed for TestFlight
├── ci/                           # shared GitHub Actions logic (composite actions)
└── .github/workflows/
    ├── build.yml                 # PR: build both engines for iOS Simulator + device (unsigned)
    ├── release.yml               # tag: unsigned IPAs + AltStore source JSON update
    └── nightly.yml               # track upstream default branches; open issue on breakage
```

Rules:

- Submodule bumps are PRs with changelogs; nightly CI builds upstream `HEAD` to detect
  breakage early but releases pin SHAs.
- A patch may live in `patches/` only with a link to its upstream PR (or a written reason
  upstream rejected it). Standing unreviewed patches are a bug.
- `CaesarPadKit` is engine-agnostic: it talks to the engines only through the small C surface
  upstream already defines (`ios_show_c3_path_dialog`, `ios_get_base_path`,
  `c3_path_chosen`) plus any new functions added via patches.

## 3. Modules

| Module | Language | Responsibility |
|---|---|---|
| engine (per submodule) | C | Unmodified game simulation, rendering, audio, input |
| platform patches | C/Obj-C | Safe-area insets, high-DPI sizing, lifecycle (background/foreground, audio session), pointer/pencil handling, iPad settings hooks |
| CaesarPadKit/Importer | Swift/Obj-C | First-launch flow: document picker, pre-copy validation, progress UI, re-import, error recovery |
| CaesarPadKit/Files | Swift | `UIFileSharingEnabled` + `LSSupportsOpeningDocumentsInPlace` exposure, save export/import, iCloud Drive option, backup exclusion flags for re-importable media |
| CaesarPadKit/Settings | Swift | Native settings sheet (touch mode, zoom behavior, audio, display) writing the engine's existing config file format |
| Packaging | scripts/CI | IPA generation, AltStore/SideStore source manifest, TestFlight lane (if pursued) |

## 4. Dependencies

Verified from `ext/` and CI **[code]**:

- SDL2 (CI-pinned: Julius 2.32.8, Augustus 2.32.10) and SDL2_mixer (2.8.1 / 2.8.2), built
  from source into the Xcode project by upstream's `install_sdl_ios` recipe. Augustus can
  alternatively target SDL3 (`-DSDL_VERSION=3`) — adopt only when upstream's iOS CI does.
- Vendored in-tree (no action needed): Julius — png, zlib, tinyfiledialogs, dirent;
  Augustus — spng, miniz, zip, sxml, pl_mpeg, easyav1, tinyfiledialogs, dirent.
- CaesarPad adds **no** third-party iOS dependencies (no SPM/CocoaPods packages) — Apple
  frameworks only. This keeps the AGPL license audit trivial.

## 5. Build system

- Engine builds: upstream's own `cmake .. -DTARGET_PLATFORM=ios -G Xcode` per engine —
  identical to `doc/iOS.md` in both repos so CaesarPad never owns a divergent build graph.
- App targets: an `xcworkspace` referencing the two generated engine projects plus
  `CaesarPadKit`; app targets set bundle ids (`app.caesarpad.julius`, `app.caesarpad.augustus`),
  icons, entitlements, and Info.plist additions (file sharing, document types,
  `UIRequiresFullScreen` (SDL iOS is single-window fullscreen),
  `UIApplicationSupportsIndirectInputEvents` (real pointer events for trackpad/mouse),
  controller support). Safe-area note: SDL2 exposes no safe-area query (only
  `SDL_HINT_IOS_HIDE_HOME_INDICATOR`); safe-area insets must be bridged natively via a patch,
  or via SDL3's `SDL_GetWindowSafeArea` on the Augustus SDL3 path.
- Simulator + device (arm64) both build in CI. Device builds are unsigned
  (`CODE_SIGNING_REQUIRED=NO`, as upstream CI already does) and packaged into `.ipa` by
  zipping the `.app` into `Payload/` — the standard sideload format.
- Minimum deployment target: iOS/iPadOS 15 (UniformTypeIdentifiers already required by
  upstream importer code implies ≥14; 15 gives async/await in Kit code). **[recommendation]**

## 6. CI (GitHub Actions)

- `build.yml` (PR/push): matrix {julius, augustus} × {simulator, device-unsigned}; runs on
  `macos-latest` mirroring upstream's proven iOS jobs; uploads `.app`/`.ipa` artifacts;
  10-minute smoke test on simulator: boot to the "Game Data Required" alert via XCUITest.
- `release.yml` (tag): rebuild deterministically, attach unsigned IPAs to the GitHub
  Release, regenerate the AltStore/SideStore source JSON.
- `nightly.yml`: bump submodules to upstream HEAD in a throwaway branch, build, file an
  issue on failure ("upstream drift detector").
- CodeQL: inherit upstream's `codeql.yml` pattern for the Kit code.

## 7. Testing

- **Unit (Kit):** importer validation logic (required-file manifest, case-insensitivity,
  GOG vs Steam vs CD layouts) with fixture folders; no engine needed.
- **UI (XCUITest):** first-launch alert → picker → error paths, settings sheet, files
  visibility. Runs on simulator in CI with a synthetic (non-copyrighted) fixture data set
  that satisfies the engine's file-presence checks. (Building such a fixture set is a
  Phase-2 task; the engines validate presence/size of `.sg2/.555/.eng` files, not artwork.)
- **Engine regression:** none owned by CaesarPad — upstream owns simulation correctness;
  CaesarPad pins releases. Save-compat spot checks are manual (device matrix, see Testing Plan).
- **Performance:** Instruments captures on A12 (oldest supported) and M-series iPads:
  60 fps target at 100% zoom in a 10k-population city; import throughput.

## 8. Platform abstraction verdict

Do **not** build a new abstraction layer. Upstream already has one (`src/platform/`), the
iOS backend already exists in both trees, and history shows the two projects copy platform
improvements from each other (identical `ios/` file sets). CaesarPad's leverage is in the
30% that upstream skipped — packaging, importer UX, iPad HIG polish — not in re-plumbing.
