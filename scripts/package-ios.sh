#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/augustus"
APP_PATH="${APP_PATH:-$ROOT_DIR/build/ios/Release-iphoneos/augustus.app}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/build/release}"
VERSION="${VERSION:-0.1.0}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"
RELEASE_LABEL="${RELEASE_LABEL:-preview.1}"
BUNDLE_ID="com.chrissotraidis.caesarpad"
OUTPUT_NAME="CaesarPad-$VERSION-$RELEASE_LABEL-unsigned.ipa"
OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_NAME"
SHA_PATH="$OUTPUT_PATH.sha256"
SOURCE_REVISION="$(git -C "$ROOT_DIR" rev-parse HEAD)"
"$ROOT_DIR/scripts/check-sources.py" --verify-stamp "$APP_PATH/CaesarPad-source.json"

for tool in codesign file find plutil shasum unzip zip zipinfo; do
    if ! command -v "$tool" >/dev/null; then
        echo "Required tool is missing: $tool" >&2
        exit 1
    fi
done

if [[ ! -d "$APP_PATH" ]]; then
    echo "Device app was not found: $APP_PATH" >&2
    echo "Run scripts/build-device.sh first." >&2
    exit 1
fi

INFO_PLIST="$APP_PATH/Info.plist"
if [[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INFO_PLIST")" != "$BUNDLE_ID" ]]; then
    echo "Unexpected bundle identifier in $APP_PATH" >&2
    exit 1
fi
if [[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleSupportedPlatforms:0' "$INFO_PLIST")" != "iPhoneOS" ]]; then
    echo "Refusing to package a non-device app: $APP_PATH" >&2
    exit 1
fi

EXECUTABLE="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$INFO_PLIST")"
if ! file "$APP_PATH/$EXECUTABLE" | grep -q "Mach-O 64-bit executable arm64"; then
    echo "Refusing to package an app without an arm64 iOS executable" >&2
    exit 1
fi

STAGING_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/caesarpad-ipa.XXXXXX")"
trap 'rm -rf "$STAGING_ROOT"' EXIT
mkdir -p "$STAGING_ROOT/Payload"
ditto "$APP_PATH" "$STAGING_ROOT/Payload/CaesarPad.app"
STAGED_APP="$STAGING_ROOT/Payload/CaesarPad.app"

codesign --remove-signature "$STAGED_APP" 2>/dev/null || true
rm -rf "$STAGED_APP/_CodeSignature"
rm -f "$STAGED_APP/embedded.mobileprovision"
xattr -cr "$STAGED_APP"

plutil -replace CFBundleShortVersionString -string "$VERSION" "$STAGED_APP/Info.plist"
plutil -replace CFBundleVersion -string "$BUILD_NUMBER" "$STAGED_APP/Info.plist"

LEGAL_DIR="$STAGED_APP/Legal"
mkdir -p "$LEGAL_DIR"
cp "$ROOT_DIR/LICENSE" "$LEGAL_DIR/CaesarPad-AGPL-3.0.txt"
cp "$ROOT_DIR/RIGHTS_AND_LICENSES.md" "$LEGAL_DIR/RIGHTS_AND_LICENSES.md"
cp "$ROOT_DIR/THIRD_PARTY_NOTICES.md" "$LEGAL_DIR/THIRD_PARTY_NOTICES.md"
cp "$ENGINE_DIR/LICENSE.txt" "$LEGAL_DIR/Augustus-AGPL-3.0.txt"
cp "$ENGINE_DIR/res/assets/LICENSE" "$LEGAL_DIR/Augustus-assets-CC-BY-SA-3.0.txt"
cp "$ENGINE_DIR/ext/easyav1/LICENSE" "$LEGAL_DIR/easyav1-BSD-3-Clause.txt"
cp "$ENGINE_DIR/ext/spng/LICENSE" "$LEGAL_DIR/spng-BSD-2-Clause.txt"
cp "$ENGINE_DIR/ext/sxml/UNLICENSE" "$LEGAL_DIR/sxml-Unlicense.txt"
cp "$ENGINE_DIR/ext/zip/UNLICENSE" "$LEGAL_DIR/zip-Unlicense.txt"
cp "$ENGINE_DIR/ext/miniz/LICENSE" "$LEGAL_DIR/miniz-License.txt"
cp "$ENGINE_DIR/ext/SDL2/SDL2/LICENSE.txt" "$LEGAL_DIR/SDL2-zlib.txt"
cp "$ENGINE_DIR/ext/SDL2/SDL2_mixer/LICENSE.txt" "$LEGAL_DIR/SDL2_mixer-zlib.txt"

cp "$APP_PATH/CaesarPad-source.json" "$LEGAL_DIR/PROVENANCE.json"
python3 - "$ENGINE_DIR" "$LEGAL_DIR" <<'PYNOTICES'
import os, pathlib, shutil, sys
root, out = map(pathlib.Path, sys.argv[1:])
for folder, dirs, files in os.walk(root):
    dirs[:] = [d for d in dirs if d not in ('.git', 'build')]
    for name in files:
        if name.upper().startswith(('LICENSE', 'COPYING', 'COPYRIGHT', 'NOTICE', 'UNLICENSE', 'AUTHORS')) or name in ('pl_mpeg.h', 'dr_flac.h', 'stb_vorbis.h'):
            p = pathlib.Path(folder) / name
            if not p.is_symlink():
                dest = out / 'components' / p.relative_to(root)
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(p, dest)
PYNOTICES
printf '%s\n' \
    "CaesarPad corresponding source for this build:" \
    "https://github.com/chrissotraidis/caesarpad/tree/$SOURCE_REVISION" \
    "Exact recursive pins: Legal/PROVENANCE.json and sources.lock.json." \
    "Obtain the matching complete source.tar.gz beside the IPA; automatic GitHub ZIPs omit submodules." \
    "Build and source update instructions: docs/source-maintenance/README.md." \
    > "$LEGAL_DIR/SOURCE_OFFER.txt"
"$ROOT_DIR/scripts/check-sources.py" --archive "$OUTPUT_DIR/CaesarPad-$VERSION-$RELEASE_LABEL-source.tar.gz"

PROHIBITED_FILES="$(find "$STAGED_APP" -type f \( \
    -iname 'c3.eng' -o \
    -iname 'c3_model.txt' -o \
    -iname 'c3.sg2' -o \
    -iname 'c3.555' -o \
    -iname '*.sav' -o \
    -iname '*.svx' \
\) -print)"
if [[ -n "$PROHIBITED_FILES" ]]; then
    echo "Refusing to package Caesar III data or saves:" >&2
    printf '%s\n' "$PROHIBITED_FILES" >&2
    exit 1
fi
if [[ -e "$STAGED_APP/embedded.mobileprovision" ]] || [[ -d "$STAGED_APP/_CodeSignature" ]]; then
    echo "Signing material remains in the staged app" >&2
    exit 1
fi
if codesign --verify "$STAGED_APP" >/dev/null 2>&1; then
    echo "The public package must be unsigned" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_PATH" "$SHA_PATH"
(
    cd "$STAGING_ROOT"
    COPYFILE_DISABLE=1 zip -qry "$OUTPUT_PATH" Payload
)

unzip -tq "$OUTPUT_PATH"
if zipinfo -1 "$OUTPUT_PATH" | grep -Eq '(^|/)(_CodeSignature/|embedded\.mobileprovision$|c3\.(eng|sg2|555)$|c3_model\.txt$|[^/]+\.(sav|svx)$)'; then
    echo "Package audit found signing material, game data, or a save" >&2
    exit 1
fi

(cd "$OUTPUT_DIR" && shasum -a 256 "$OUTPUT_NAME") > "$SHA_PATH"
echo "Created $OUTPUT_PATH"
cat "$SHA_PATH"
