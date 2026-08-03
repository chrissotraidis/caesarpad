#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/augustus"
EXPECTED_ENGINE_SHA="69c69827682a11eaaa400c5a77198131249bfe2a"

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

git -C "$ROOT_DIR" diff --check

ACTUAL_ENGINE_SHA="$(git -C "$ENGINE_DIR" rev-parse HEAD)"
[[ "$ACTUAL_ENGINE_SHA" == "$EXPECTED_ENGINE_SHA" ]] ||
    fail "Augustus is $ACTUAL_ENGINE_SHA, expected $EXPECTED_ENGINE_SHA"

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

PATCH_TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/caesarpad-patches.XXXXXX")"
trap 'rm -rf "$PATCH_TEST_DIR"' EXIT
git -C "$ENGINE_DIR" archive HEAD | tar -xf - -C "$PATCH_TEST_DIR"
SDL_UIKIT_SOURCE="$ENGINE_DIR/ext/SDL2/SDL2/src/video/uikit/SDL_uikitview.m"
[[ -f "$SDL_UIKIT_SOURCE" ]] || fail "SDL2 source is missing; run scripts/fetch-deps.sh"
mkdir -p "$PATCH_TEST_DIR/ext/SDL2/SDL2/src/video/uikit"
cp "$SDL_UIKIT_SOURCE" "$PATCH_TEST_DIR/ext/SDL2/SDL2/src/video/uikit/SDL_uikitview.m"
git -C "$PATCH_TEST_DIR" init -q
PENCIL_PATCH="$ROOT_DIR/patches/augustus/0009-ios-apple-pencil-mode.patch"
SDL_UIKIT_PATH="ext/SDL2/SDL2/src/video/uikit/SDL_uikitview.m"
if git -C "$PATCH_TEST_DIR" apply --reverse --check --include="$SDL_UIKIT_PATH" "$PENCIL_PATCH" 2>/dev/null; then
    git -C "$PATCH_TEST_DIR" apply --reverse --include="$SDL_UIKIT_PATH" "$PENCIL_PATCH"
elif ! git -C "$PATCH_TEST_DIR" apply --check --include="$SDL_UIKIT_PATH" "$PENCIL_PATCH" 2>/dev/null; then
    fail "SDL UIKit source matches neither the clean nor patched Pencil state"
fi
for patch in "$ROOT_DIR"/patches/augustus/*.patch; do
    echo "Checking patch: $(basename "$patch")"
    if ! git -C "$PATCH_TEST_DIR" apply --check "$patch"; then
        fail "patch does not apply cleanly: $(basename "$patch")"
    fi
    git -C "$PATCH_TEST_DIR" apply "$patch"
done

grep -q 'com.chrissotraidis.caesarpad' "$PATCH_TEST_DIR/CMakeLists.txt" ||
    fail "patched bundle identifier is missing"
grep -q '<key>UIFileSharingEnabled</key>' "$PATCH_TEST_DIR/res/ios/Info.plist" ||
    fail "Files sharing metadata is missing"
grep -q '<key>UIRequiresFullScreen</key>' "$PATCH_TEST_DIR/res/ios/Info.plist" ||
    fail "landscape full-screen metadata is missing"
grep -q 'usesExistingGameData' "$PATCH_TEST_DIR/src/platform/ios/CaesarPadGameDataPickerController.m" ||
    fail "Files-visible C3 folder handling is missing"
grep -q 'Importing Game Data' "$PATCH_TEST_DIR/src/platform/ios/CaesarPadGameDataPickerController.m" ||
    fail "game-data import feedback is missing"
grep -q 'dispatch_get_global_queue' "$PATCH_TEST_DIR/src/platform/ios/CaesarPadGameDataPickerController.m" ||
    fail "game-data import still blocks the UIKit thread"

echo "PASS: repository safety, scripts, assets, submodule pin, and patch series"
