#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/augustus"
PATCHES=("$ROOT_DIR"/patches/augustus/*.patch)

# Remove known patches from newest to oldest so overlapping context remains
# recognizable, then apply the complete series in its canonical order.
for ((index=${#PATCHES[@]} - 1; index >= 0; index--)); do
    patch="${PATCHES[$index]}"
    if git -C "$ENGINE_DIR" apply --reverse --check "$patch" 2>/dev/null; then
        git -C "$ENGINE_DIR" apply --reverse "$patch"
    fi
done

for patch in "${PATCHES[@]}"; do
    git -C "$ENGINE_DIR" apply --check "$patch"
    git -C "$ENGINE_DIR" apply "$patch"
    echo "Applied: $(basename "$patch")"
done
