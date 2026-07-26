#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/augustus"

for patch in "$ROOT_DIR"/patches/augustus/*.patch; do
    if git -C "$ENGINE_DIR" apply --reverse --check "$patch" 2>/dev/null; then
        echo "Already applied: $(basename "$patch")"
        continue
    fi

    git -C "$ENGINE_DIR" apply --check "$patch"
    git -C "$ENGINE_DIR" apply "$patch"
    echo "Applied: $(basename "$patch")"
done
