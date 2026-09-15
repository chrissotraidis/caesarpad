#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/augustus"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build/ios}"
ICON_SOURCE="$ROOT_DIR/assets/ios/AppIcon.png"
ICON_TARGET="$ENGINE_DIR/res/ios/Assets.xcassets/AppIcon.appiconset/augustus_1024.png"

# shellcheck source=scripts/simulator.sh
source "$ROOT_DIR/scripts/simulator.sh"
caesarpad_select_simulator

"$ROOT_DIR/scripts/fetch-deps.sh"
"$ROOT_DIR/scripts/check-sources.py"

ICON_INFO="$(sips -g pixelWidth -g pixelHeight -g hasAlpha "$ICON_SOURCE")"
if ! grep -q "pixelWidth: 1024" <<<"$ICON_INFO" ||
    ! grep -q "pixelHeight: 1024" <<<"$ICON_INFO" ||
    ! grep -q "hasAlpha: no" <<<"$ICON_INFO"; then
    echo "App icon must be an opaque 1024x1024 PNG: $ICON_SOURCE" >&2
    exit 1
fi
cmp "$ICON_SOURCE" "$ICON_TARGET"

cmake \
    -S "$ENGINE_DIR" \
    -B "$BUILD_DIR" \
    -DTARGET_PLATFORM=ios \
    -G Xcode

xcodebuild \
    -project "$BUILD_DIR/augustus.xcodeproj" \
    -scheme augustus \
    -configuration Release \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    ONLY_ACTIVE_ARCH=YES \
    build

APP_PATH="$BUILD_DIR/Release-iphonesimulator/augustus.app"
if [[ ! -d "$APP_PATH" ]]; then
    echo "Expected app bundle was not produced: $APP_PATH" >&2
    exit 1
fi

"$ROOT_DIR/scripts/check-sources.py" --stamp "$APP_PATH/CaesarPad-source.json"
echo "Built $APP_PATH"
