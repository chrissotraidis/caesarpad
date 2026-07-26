#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${TOUCH_TEST_BUILD_DIR:-$ROOT_DIR/build/touch-tests}"

mkdir -p "$OUTPUT_DIR"

clang \
    -std=c11 \
    -Wall \
    -Wextra \
    -Werror \
    -Wno-unused-parameter \
    -I"$ROOT_DIR/engines/augustus/src" \
    "$ROOT_DIR/tests/touch/long_press_test.c" \
    "$ROOT_DIR/engines/augustus/src/input/touch.c" \
    -o "$OUTPUT_DIR/long-press-test"

"$OUTPUT_DIR/long-press-test"
