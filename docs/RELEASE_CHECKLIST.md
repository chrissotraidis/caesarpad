# CaesarPad release checklist

Use this checklist for every public source or IPA release.

## Source and rights

- [ ] Release commit is on `main`, tagged, and matches `origin/main`.
- [ ] Augustus submodule is exactly `69c69827682a11eaaa400c5a77198131249bfe2a`.
- [ ] Every maintained patch applies cleanly in numeric order.
- [ ] `scripts/check-repo-safety.sh` passes.
- [ ] No `ref/`, Caesar III data, saves, signing material, or generated build
      products are tracked.
- [ ] `LICENSE`, `RIGHTS_AND_LICENSES.md`, and `THIRD_PARTY_NOTICES.md` match the
      published artifact and source tag.

## Build and package

```sh
scripts/build-device.sh
SOURCE_REVISION="$(git rev-parse HEAD)" scripts/package-ios.sh
```

- [ ] The device build reports `iPhoneOS`, arm64, bundle identifier
      `com.chrissotraidis.caesarpad`, version `0.1.0`, and build `1`.
- [ ] The package is named `CaesarPad-0.1.0-preview.1-unsigned.ipa`.
- [ ] `unzip -t` passes and the checksum file matches.
- [ ] The IPA contains `Payload/CaesarPad.app/Legal/`.
- [ ] The IPA contains no `_CodeSignature`, `embedded.mobileprovision`, Caesar III
      data, or save files.

## Physical iPad acceptance

- [ ] Re-sign and install the exact candidate IPA on a supported iPad.
- [ ] Confirm **Files → On My iPad → CaesarPad** is visible.
- [ ] Import a locally owned Caesar III data folder and reach the main menu.
- [ ] Load the developed demo save and play for at least 15 minutes.
- [ ] Exercise touch, Apple Pencil, pan, pinch, long press, and pause/resume.
- [ ] Save, relaunch, and confirm the save survives an in-place app update.
- [ ] Background and foreground during city play and event video playback.
- [ ] Confirm speaker audio; record headphones, Bluetooth, interruptions,
      performance, and thermals as tested or still outstanding.

## GitHub release

- [ ] Release is marked as a prerelease until the physical acceptance list passes.
- [ ] Attach the unsigned IPA and `.sha256` file.
- [ ] Release notes state the CaesarPad version, Augustus SHA, supported iPadOS
      floor, known limitations, and bring-your-own-game-data requirement.
- [ ] Link the exact source tag and IPA installation guide.
- [ ] Download the published assets again and verify their size and SHA-256.
