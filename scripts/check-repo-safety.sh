#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/augustus"

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

git -C "$ROOT_DIR" diff --check

"$ROOT_DIR/scripts/check-sources.py"

while IFS= read -r path; do
    case "$path" in
        ref/*|build/*|ext/SDL2/*|*.ipa|*.mobileprovision|*.p12|*.p8|*.xcarchive/*|*.xcresult/*|*/c3.eng|*/c3_model.txt|*/c3.sg2|*/c3.555|*.sav|*.svx)
            fail "prohibited tracked path: $path"
            ;;
    esac
done < <(git -C "$ROOT_DIR" ls-files)

for required in \
    LICENSE \
    RIGHTS_AND_LICENSES.md \
    THIRD_PARTY_NOTICES.md \
    docs/INSTALL_IPA.md \
    docs/RELEASE_CHECKLIST.md; do
    [[ -f "$ROOT_DIR/$required" ]] || fail "missing release file: $required"
done

for script in "$ROOT_DIR"/scripts/*.sh; do
    bash -n "$script"
done

for image in \
    docs/readme/caesarpad-gameplay.jpg \
    docs/readme/caesarpad-empire-map.jpg \
    docs/readme/caesarpad-advisors.jpg \
    docs/readme/caesarpad-campaign.jpg; do
    [[ -f "$ROOT_DIR/$image" ]] || fail "missing README image: $image"
    size="$(stat -f '%z' "$ROOT_DIR/$image")"
    (( size < 5242880 )) || fail "README image exceeds 5 MiB: $image"
done

grep -q 'com.chrissotraidis.caesarpad' "$ENGINE_DIR/CMakeLists.txt" ||
    fail "patched bundle identifier is missing"
grep -q '<key>UIFileSharingEnabled</key>' "$ENGINE_DIR/res/ios/Info.plist" ||
    fail "Files sharing metadata is missing"
grep -q '<key>UIRequiresFullScreen</key>' "$ENGINE_DIR/res/ios/Info.plist" ||
    fail "landscape full-screen metadata is missing"
grep -q 'usesExistingGameData' "$ENGINE_DIR/src/platform/ios/CaesarPadGameDataPickerController.m" ||
    fail "Files-visible C3 folder handling is missing"
grep -q 'Importing Game Data' "$ENGINE_DIR/src/platform/ios/CaesarPadGameDataPickerController.m" ||
    fail "game-data import feedback is missing"
grep -q 'dispatch_get_global_queue' "$ENGINE_DIR/src/platform/ios/CaesarPadGameDataPickerController.m" ||
    fail "game-data import still blocks the UIKit thread"

echo "PASS: repository safety, scripts, assets, submodule pin, and maintained source graph"
