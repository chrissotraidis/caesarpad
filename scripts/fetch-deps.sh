#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/augustus"
SDL_ROOT="$ENGINE_DIR/ext/SDL2"

if [[ ! -f "$ENGINE_DIR/CMakeLists.txt" ]]; then
    echo "Augustus submodule is missing. Run: git submodule update --init --recursive" >&2
    exit 1
fi

fetch_release() {
    local name="$1"
    local version="$2"
    local url="$3"
    local expected_sha="$4"
    local target="$5"
    local marker="$target/.caesarpad-source"

    if [[ -f "$marker" ]] && [[ "$(cat "$marker")" == "$name-$version" ]]; then
        echo "Using $name $version"
        return
    fi

    local temp_dir
    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/caesarpad-${name}.XXXXXX")"

    local archive="$temp_dir/$name-$version.tar.gz"
    echo "Downloading $name $version"
    curl -fL "$url" -o "$archive"

    local actual_sha
    actual_sha="$(shasum -a 256 "$archive" | awk '{print $1}')"
    if [[ "$actual_sha" != "$expected_sha" ]]; then
        echo "$name checksum mismatch: expected $expected_sha, got $actual_sha" >&2
        exit 1
    fi

    rm -rf "$target"
    mkdir -p "$target"
    tar -xzf "$archive" -C "$target" --strip-components=1
    printf '%s\n' "$name-$version" > "$marker"
    rm -rf "$temp_dir"
}

mkdir -p "$SDL_ROOT"

fetch_release \
    "SDL2" \
    "2.32.10" \
    "https://www.libsdl.org/release/SDL2-2.32.10.tar.gz" \
    "5f5993c530f084535c65a6879e9b26ad441169b3e25d789d83287040a9ca5165" \
    "$SDL_ROOT/SDL2"

fetch_release \
    "SDL2_mixer" \
    "2.8.2" \
    "https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.8.2.tar.gz" \
    "938dff531d00ace2296557a6599abe6f34599e2f34f0a4a08a397e2ccac8b8f7" \
    "$SDL_ROOT/SDL2_mixer"
