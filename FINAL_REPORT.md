# CaesarPad Final Report

Date: 2026-07-27

## Outcome

Caesar III runs through the Augustus engine on an iPad Pro 11-inch (M4) Simulator
in landscape. A single command verifies the build, app boot, user-owned data load,
playable mission flow, touch controls, and lifecycle autosave/resume. The complete
path passed twice consecutively after a clean build and fresh submodule checkout.

Caesar III game data is not present in the repository. The local `ref/` directory
remained ignored throughout verification.

## Upstream pin and patches

Augustus is pinned as a Git submodule at
`69c69827682a11eaaa400c5a77198131249bfe2a`. CaesarPad makes no vendor copy of the
engine. Its five required changes are maintained in `patches/augustus/`:

1. `0001-ios-landscape-only.patch` — removes portrait orientations so the iPad
   game canvas always launches in landscape.
2. `0002-ios-long-press-right-click.patch` — maps a stationary long press and a
   two-finger tap to the engine's right-click path; movement cancels a pending
   long press and consumed multi-touch cannot leak a later click.
3. `0003-ios-native-pause-button.patch` — adds the one allowed native control, a
   safe-area pause/resume button, and exposes the engine canvas/control state to
   UI automation.
4. `0004-ios-lifecycle-autosave.patch` — writes the active city to
   `Documents/caesarpad-autosave.svx` when iOS backgrounds the app, resumes it
   after a cold launch, and consumes a successfully loaded recovery save.
5. `0005-ios-caesarpad-name.patch` — gives the downstream app and original icon
   one consistent installed display name.

The original opaque 1024×1024 app icon is owned downstream at
`assets/ios/AppIcon.png`, validated during every build, and copied into the generated
Augustus asset catalog without committing a binary change to the engine submodule.

SDL2 2.32.10 and SDL2_mixer 2.8.2 are checksum-pinned source downloads fetched
into `ext/SDL2/` by the build, following the Augustus iOS layout.

## Automated coverage

`scripts/test.sh` performs the complete verification:

- builds Augustus for the arm64 iPad Simulator;
- boots the selected iPad, installs the app, and injects local `ref/` game data;
- validates the long-press state machine and multi-touch consumption;
- starts a mission and verifies selection, building placement, map panning,
  speed control, and pause without a keyboard;
- verifies tap, drag, long press, pinch, two-finger tap, and the native pause
  affordance through XCUITest, including clock stability while paused;
- backgrounds the app through `simctl`, confirms the autosave file appears,
  terminates the app, and verifies cold-start resume.

Gate-specific screenshots and logs are under `artifacts/g0/` through
`artifacts/g8/`. G8 evidence is the pair `repeat-1.log` and `repeat-2.log`; both
end with the complete-suite PASS marker.

## Repeatability proof

The repository was cleaned with `git clean -fdx -e ref/`, preserving 609
user-owned files under the ignored `ref/` directory. The Augustus submodule was
deinitialized and freshly initialized at the pinned SHA. From that state,

```sh
scripts/build.sh && scripts/test.sh
scripts/build.sh && scripts/test.sh
```

passed twice consecutively.

After the public-preview and control hardening work, the finalized suite passed twice
again in succession. Those runs are recorded at
`artifacts/public-preview/full-suite-repeat.log` and
`artifacts/public-preview/full-suite-repeat-2.log`.

## Known limitations

- Automated verification targets the recorded iPad Simulator and assumes local,
  legally purchased Caesar III data is available.
- `scripts/install.sh` automatically selects an available iPad Simulator and provides
  the clean human launch path; it does not produce a physical-device build.
- The recovery save is intentionally single-slot and consumed after a successful
  resume; Caesar III's normal save UI remains available for durable saves.
- Distribution signing, App Store packaging, and a user-facing document importer
  are outside these gates.

## Physical iPad checks still required

- sustained rendering performance and thermal behavior;
- touch target comfort, gesture feel, and accidental-gesture rates;
- music and effects through real speakers, headphones, and interruption routes;
- background/foreground behavior during calls, Control Center use, locking, and
  memory pressure;
- device signing, installation, and any eventual distribution packaging.

## Simplicity audit

The final implementation contains only the Augustus submodule, five narrowly scoped
patches, one downstream icon, build/data/test scripts, the small XCUITest harness, and
evidence. No Julius flavor, mode-switching UI, native toolbar, vendored engine copy, or
extra dependency was added. A duplicate README copy of the 2 MB icon was deleted; the
README and build now share `assets/ios/AppIcon.png`. The remaining audit found no tracked
implementation that could be deleted while retaining the verified behavior; generated
build products and test result bundles remain ignored.
