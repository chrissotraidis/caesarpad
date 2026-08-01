# CaesarPad 0.1.0 preview report

Date: 2026-08-01

## Outcome

CaesarPad is prepared as a source and unsigned-IPA release candidate. Augustus builds for
both the arm64 iPad Simulator and arm64 physical devices. A locally signed build with the
release bundle identity installed and launched on the attached iPad Pro, while the packaging
lane produces a re-signable IPA without Caesar III data or maintainer signing material.

The release remains a preview. Publishing a GitHub prerelease and completing hands-on
acceptance of the exact re-signed IPA are separate gates.

## Maintained Augustus integration

Augustus remains pinned as a Git submodule at
`69c69827682a11eaaa400c5a77198131249bfe2a`. CaesarPad carries 12 reviewable patches under
`patches/augustus/`:

1. landscape-only iOS presentation;
2. stationary long-press and two-finger alternate-click mappings;
3. native iOS lifecycle and UI-automation hooks;
4. background autosave and cold-launch recovery;
5. the CaesarPad display name;
6. visible touch cursor feedback and larger iPad UI defaults;
7. intent locking between two-finger pan and pinch zoom;
8. an in-app control guide;
9. persistent Apple Pencil and traditional-touch modes;
10. removal of the duplicate native pause button and clearer Pencil state;
11. compact top-right controls and safer event-video backgrounding;
12. the release bundle identity, version metadata, full-screen landscape presentation,
   pointer events, and Files-visible Documents directory.

The downstream app icon is validated from `assets/ios/AppIcon.png`. SDL2 2.32.10 and
SDL2_mixer 2.8.2 are checksum-pinned downloads rather than committed build products.

## Release work completed

- Added public screenshots and an installation-focused README.
- Added explicit rights boundaries and third-party notices.
- Added a deterministic device-build script and unsigned-IPA packager.
- Embedded corresponding-source and license material under `CaesarPad.app/Legal/`.
- Added repository and archive audits that reject owned game data, saves, signing assets,
  and generated artifacts.
- Added GitHub Actions coverage for source safety, an unsigned device build, candidate IPA
  packaging, artifact upload, and tag-triggered prerelease creation.
- Corrected Simulator selection so a custom iPhone name containing “iPad” cannot be mistaken
  for an iPad destination.

## Verification on 2026-08-01

- All 12 patches apply cleanly to the pinned submodule.
- The touch-engine regression executable passes every long-press, multi-touch, pan/pinch,
  and Pencil-routing case.
- Focused XCUITests pass top-right control placement, help text, and Pencil-mode persistence
  on an iPad Pro 13-inch (M5) Simulator.
- The device app is an arm64 Mach-O for `iPhoneOS`, version `0.1.0` build `1`, and passes
  `codesign --verify --deep --strict`.
- The new `com.chrissotraidis.caesarpad` build installs and launches on the attached iPad Pro
  12.9-inch (6th generation) without replacing the earlier development bundle. The old
  Documents container was backed up before migration; read-back hashes for `c3.eng`,
  `c3_model.txt`, and `Citizen.sav` matched, and the new app resumed into the recovered game.
- The unsigned IPA passes ZIP integrity, metadata, architecture, legal-notice, signature,
  provisioning-profile, save-file, and Caesar III data audits.

## Known limitations

- The current iOS 26.5 Simulator rotates synthesized pixel-coordinate taps differently from
  the recorded earlier runtime. The native identifier-based UI tests pass, but the legacy
  end-to-end mission test needs coordinate recalibration and is reported as failing rather
  than relaxed.
- The exact unsigned IPA has not yet completed the physical acceptance checklist after being
  re-signed by a sideloading tool.
- Files visibility is configured and package-audited, but the polished in-app importer and
  import-progress UI are not implemented.
- Broader audio-route, interruption, sustained-performance, thermal, and device-matrix testing
  remains outstanding.
- No App Store, TestFlight, AltStore source, or public GitHub prerelease is claimed here.

## Release boundary

The repository and IPA contain no Caesar III data. Screenshots are documentation of the
running integration and do not relicense Caesar III artwork. See
[`RIGHTS_AND_LICENSES.md`](RIGHTS_AND_LICENSES.md),
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md), and
[`docs/RELEASE_CHECKLIST.md`](docs/RELEASE_CHECKLIST.md) before publishing a binary.
