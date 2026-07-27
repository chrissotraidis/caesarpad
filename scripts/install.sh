#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_ID="${BUNDLE_ID:-com.github.keriew.augustus}"
APP_PATH="$ROOT_DIR/build/ios/Release-iphonesimulator/augustus.app"
SOURCE_DIR="${C3_SOURCE_DIR:-$ROOT_DIR/ref/Caesar 3/C3}"

for tool in xcodebuild xcrun cmake git curl; do
    if ! command -v "$tool" >/dev/null; then
        echo "Required tool is missing: $tool" >&2
        exit 1
    fi
done

if [[ ! -f "$SOURCE_DIR/c3.eng" ]] || [[ ! -f "$SOURCE_DIR/c3_model.txt" ]]; then
    echo "Caesar III data was not found at: $SOURCE_DIR" >&2
    echo "Set C3_SOURCE_DIR to the folder containing c3.eng and c3_model.txt." >&2
    exit 1
fi

git -C "$ROOT_DIR" submodule update --init --recursive

# shellcheck source=scripts/simulator.sh
source "$ROOT_DIR/scripts/simulator.sh"
caesarpad_select_simulator

"$ROOT_DIR/scripts/build.sh"
xcrun simctl boot "$SIMULATOR_UDID" 2>/dev/null || true
xcrun simctl bootstatus "$SIMULATOR_UDID" -b
xcrun simctl install "$SIMULATOR_UDID" "$APP_PATH"
"$ROOT_DIR/scripts/inject-data.sh"
xcrun simctl launch --terminate-running-process "$SIMULATOR_UDID" "$BUNDLE_ID"

open -a Simulator >/dev/null 2>&1 || true
echo "CaesarPad is installed and running in iPad Simulator $SIMULATOR_UDID"
