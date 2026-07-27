#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${UI_TEST_BUILD_DIR:-$ROOT_DIR/build/ui-tests}"
PROJECT_PATH="$BUILD_DIR/CaesarPadUITestHarness.xcodeproj"
SCHEME_PATH="$PROJECT_PATH/xcshareddata/xcschemes/CaesarPadUITests.xcscheme"
RESULT_BUNDLE_PATH="${RESULT_BUNDLE_PATH:-$ROOT_DIR/artifacts/g4/ui-tests-$(date +%Y%m%d-%H%M%S).xcresult}"
TEST_SELECTOR_ARGS=()
if [[ -n "${ONLY_TESTING:-}" ]]; then
    TEST_SELECTOR_ARGS+=("-only-testing:$ONLY_TESTING")
fi

# shellcheck source=scripts/simulator.sh
source "$ROOT_DIR/scripts/simulator.sh"
caesarpad_select_simulator

cmake \
    -S "$ROOT_DIR/tests/ui" \
    -B "$BUILD_DIR" \
    -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT=iphonesimulator

sed "s|@PROJECT_PATH@|$PROJECT_PATH|g" \
    "$ROOT_DIR/tests/ui/CaesarPadUITests.xcscheme.in" > "$SCHEME_PATH"

mkdir -p "$(dirname "$RESULT_BUNDLE_PATH")"

xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme CaesarPadUITests \
    -configuration Debug \
    -sdk iphonesimulator \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    clean

xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme CaesarPadUITests \
    -configuration Debug \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -resultBundlePath "$RESULT_BUNDLE_PATH" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    "${TEST_SELECTOR_ARGS[@]}" \
    test

echo "Saved UI-test results to $RESULT_BUNDLE_PATH"
