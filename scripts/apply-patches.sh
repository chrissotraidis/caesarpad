#!/usr/bin/env bash
# Compatibility entry point: patches are historical; never mutate maintained source.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$ROOT_DIR/scripts/check-sources.py"
