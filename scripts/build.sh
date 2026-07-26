#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/augustus"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build/ios}"
SIMULATOR_UDID="${SIMULATOR_UDID:-08636791-2675-4675-8335-EF72EF954DCF}"

"$ROOT_DIR/scripts/fetch-deps.sh"
"$ROOT_DIR/scripts/apply-patches.sh"

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

echo "Built $APP_PATH"
