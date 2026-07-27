#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_ID="${BUNDLE_ID:-com.github.keriew.augustus}"
SOURCE_DIR="${C3_SOURCE_DIR:-$ROOT_DIR/ref/Caesar 3/C3}"

# shellcheck source=scripts/simulator.sh
source "$ROOT_DIR/scripts/simulator.sh"
caesarpad_select_simulator

if [[ ! -f "$SOURCE_DIR/c3.eng" ]] || [[ ! -f "$SOURCE_DIR/c3_model.txt" ]]; then
    echo "Caesar III data was not found at: $SOURCE_DIR" >&2
    exit 1
fi

DATA_CONTAINER="$(xcrun simctl get_app_container "$SIMULATOR_UDID" "$BUNDLE_ID" data)"
TARGET_DIR="$DATA_CONTAINER/Documents/C3"

mkdir -p "$TARGET_DIR"
ditto "$SOURCE_DIR" "$TARGET_DIR"

echo "Injected $(find "$TARGET_DIR" -type f | wc -l | tr -d ' ') files into $TARGET_DIR"
