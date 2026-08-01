#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/augustus"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build/ios}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$BUILD_DIR/DerivedData-device}"
APP_PATH="$BUILD_DIR/Release-iphoneos/augustus.app"
ICON_SOURCE="$ROOT_DIR/assets/ios/AppIcon.png"
ICON_TARGET="$ENGINE_DIR/res/ios/Assets.xcassets/AppIcon.appiconset/augustus_1024.png"

for tool in cmake xcodebuild sips; do
    if ! command -v "$tool" >/dev/null; then
        echo "Required tool is missing: $tool" >&2
        exit 1
    fi
done

"$ROOT_DIR/scripts/fetch-deps.sh"
"$ROOT_DIR/scripts/apply-patches.sh"

ICON_INFO="$(sips -g pixelWidth -g pixelHeight -g hasAlpha "$ICON_SOURCE")"
if ! grep -q "pixelWidth: 1024" <<<"$ICON_INFO" ||
    ! grep -q "pixelHeight: 1024" <<<"$ICON_INFO" ||
    ! grep -q "hasAlpha: no" <<<"$ICON_INFO"; then
    echo "App icon must be an opaque 1024x1024 PNG: $ICON_SOURCE" >&2
    exit 1
fi
cp "$ICON_SOURCE" "$ICON_TARGET"

cmake \
    -S "$ENGINE_DIR" \
    -B "$BUILD_DIR" \
    -DTARGET_PLATFORM=ios \
    -G Xcode

XCODE_ARGS=(
    -project "$BUILD_DIR/augustus.xcodeproj"
    -scheme augustus
    -configuration Release
    -sdk iphoneos
    -destination "generic/platform=iOS"
    -derivedDataPath "$DERIVED_DATA_PATH"
    COMPILER_INDEX_STORE_ENABLE=NO
)

if [[ -n "${DEVELOPMENT_TEAM:-}" ]]; then
    XCODE_ARGS+=(
        DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM"
        CODE_SIGN_STYLE=Automatic
    )
    echo "Building a locally signed device app for team $DEVELOPMENT_TEAM"
else
    XCODE_ARGS+=(
        CODE_SIGN_IDENTITY=""
        CODE_SIGNING_REQUIRED=NO
        CODE_SIGNING_ALLOWED=NO
    )
    echo "Building an unsigned device app"
fi

rm -rf "$APP_PATH"
xcodebuild "${XCODE_ARGS[@]}" build

if [[ ! -d "$APP_PATH" ]]; then
    echo "Expected device app bundle was not produced: $APP_PATH" >&2
    exit 1
fi

echo "Built $APP_PATH"
