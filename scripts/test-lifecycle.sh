#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_ID="${BUNDLE_ID:-com.chrissotraidis.caesarpad}"
APP_PATH="${APP_PATH:-$ROOT_DIR/build/ios/Release-iphonesimulator/augustus.app}"
ARTIFACT_DIR="$ROOT_DIR/artifacts/g6"
RUN_ID="$(date +%Y%m%d-%H%M%S)"

# shellcheck source=scripts/simulator.sh
source "$ROOT_DIR/scripts/simulator.sh"
caesarpad_select_simulator

mkdir -p "$ARTIFACT_DIR"
xcrun simctl bootstatus "$SIMULATOR_UDID" -b
xcrun simctl install "$SIMULATOR_UDID" "$APP_PATH"
"$ROOT_DIR/scripts/inject-data.sh"

DATA_CONTAINER="$(xcrun simctl get_app_container "$SIMULATOR_UDID" "$BUNDLE_ID" data)"
AUTOSAVE_PATH="$DATA_CONTAINER/Documents/caesarpad-autosave.svx"
rm -f "$AUTOSAVE_PATH"

ONLY_TESTING="CaesarPadUITests/CaesarPadUITests/testPrepareLifecycleMission" \
RESULT_BUNDLE_PATH="$ARTIFACT_DIR/lifecycle-prepare-$RUN_ID.xcresult" \
"$ROOT_DIR/scripts/test-ui.sh"

xcrun simctl launch --terminate-running-process "$SIMULATOR_UDID" com.apple.Preferences

for _ in {1..20}; do
    if [[ -s "$AUTOSAVE_PATH" ]]; then
        break
    fi
    sleep 0.25
done

if [[ ! -s "$AUTOSAVE_PATH" ]]; then
    echo "Lifecycle autosave was not created at $AUTOSAVE_PATH" >&2
    exit 1
fi

stat -f "Lifecycle autosave: %N (%z bytes)" "$AUTOSAVE_PATH"
xcrun simctl terminate "$SIMULATOR_UDID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl launch "$SIMULATOR_UDID" "$BUNDLE_ID"

ONLY_TESTING="CaesarPadUITests/CaesarPadUITests/testVerifyLifecycleResume" \
RESULT_BUNDLE_PATH="$ARTIFACT_DIR/lifecycle-resume-$RUN_ID.xcresult" \
"$ROOT_DIR/scripts/test-ui.sh"

if [[ -e "$AUTOSAVE_PATH" ]]; then
    echo "Lifecycle autosave was not consumed after resume" >&2
    exit 1
fi

echo "PASS: background autosave was created, cold-launched, resumed, and consumed"
