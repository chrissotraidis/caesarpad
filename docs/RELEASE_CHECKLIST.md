# CaesarPad release checklist

Use this checklist for every public source or IPA release.

## Source and rights

- [ ] Release commit is on `main`, tagged, and matches `origin/main`.
- [ ] Recursive gitlinks match `sources.lock.json`; dependencies are clean.
- [ ] No normal build path replays historical patches.
- [ ] `scripts/check-repo-safety.sh` passes.
- [ ] No `ref/`, Caesar III data, saves, signing material, or generated build
      products are tracked.
- [ ] `LICENSE`, `RIGHTS_AND_LICENSES.md`, and `THIRD_PARTY_NOTICES.md` match the
      published artifact and source tag.

## Build and package

```sh
scripts/build-device.sh
scripts/package-ios.sh
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
- [ ] Attach the unsigned IPA, complete source archive, and both `.sha256` files.
- [ ] Restore the source archive without Git/private inputs; validate and build it.
- [ ] App `Legal/PROVENANCE.json` agrees with the source archive and release commit.
- [ ] Release notes state the CaesarPad version, Augustus SHA, supported iPadOS
      floor, known limitations, and bring-your-own-game-data requirement.
- [ ] Link the exact source tag and IPA installation guide.
- [ ] Download the published assets again and verify their size and SHA-256.

Source-only pull requests do not authorize publication or imply new hardware acceptance.
Keep historical release assets intact. Choose a new version/label for any future release;
do not overwrite Preview 1 with a migration candidate.
