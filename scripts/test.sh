#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_ID="${BUNDLE_ID:-com.chrissotraidis.caesarpad}"
APP_PATH="$ROOT_DIR/build/ios/Release-iphonesimulator/augustus.app"
ARTIFACT_DIR="$ROOT_DIR/artifacts/g7"
RUN_ID="$(date +%Y%m%d-%H%M%S)"

# shellcheck source=scripts/simulator.sh
source "$ROOT_DIR/scripts/simulator.sh"
caesarpad_select_simulator

mkdir -p "$ARTIFACT_DIR"
"$ROOT_DIR/scripts/build.sh"

xcrun simctl boot "$SIMULATOR_UDID" 2>/dev/null || true
xcrun simctl bootstatus "$SIMULATOR_UDID" -b
xcrun simctl install "$SIMULATOR_UDID" "$APP_PATH"
"$ROOT_DIR/scripts/inject-data.sh"

DATA_CONTAINER="$(xcrun simctl get_app_container "$SIMULATOR_UDID" "$BUNDLE_ID" data)"
rm -f "$DATA_CONTAINER/Documents/caesarpad-autosave.svx"

"$ROOT_DIR/scripts/test-touch.sh"

ONLY_TESTING="CaesarPadUITests/CaesarPadUITests/testPlayableMissionFlow" \
RESULT_BUNDLE_PATH="$ARTIFACT_DIR/playable-$RUN_ID.xcresult" \
"$ROOT_DIR/scripts/test-ui.sh"

ONLY_TESTING="CaesarPadUITests/CaesarPadUITests/testMinimalTouchControls" \
RESULT_BUNDLE_PATH="$ARTIFACT_DIR/touch-$RUN_ID.xcresult" \
"$ROOT_DIR/scripts/test-ui.sh"

"$ROOT_DIR/scripts/test-lifecycle.sh"

echo "PASS: CaesarPad build, boot, data, gameplay, touch, and lifecycle suite"
