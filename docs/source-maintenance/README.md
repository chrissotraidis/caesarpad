# Source maintenance and reproducibility

CaesarPad remains the same app repository. This change converts the effective
Preview 1 source at `07a8d38a4eae77d01c6d980ecbc36de8fad97ef6` into ordinary
upstream-connected dependency commits. No upstream upgrade or gameplay change
is intended. No new binary release or device installation is part of this PR.

## Components and implementation plan

| Component | Unchanged upstream base | Maintained location / role |
|---|---|---|
| Augustus | `69c69827682a11eaaa400c5a77198131249bfe2a` | [Augustus fork](https://github.com/chrissotraidis/augustus/tree/caesarpad/maintained), AGPL engine and iOS integration |
| SDL | `5d249570393f7a37e037abf22cd6012a4cc56a71` (`release-2.32.10`) | [SDL fork](https://github.com/chrissotraidis/SDL/tree/caesarpad/maintained), zlib input/platform layer |
| SDL_mixer | 2.8.2 release, SHA-256 in lock | Unmodified download, built-in permissive codec paths |
| easyav1 / dav1d | Exact original recursive gitlinks in lock | Retained upstream; AV1 is OFF in the shipped iOS build |

The [lock](../../sources.lock.json) is the immutable selection. GitHub fork parent
metadata was verified as Keriew/augustus and libsdl-org/SDL. Branch names are for
contributions, never floating build inputs. Original author history and license
files remain intact; fork metadata grants no additional redistribution rights.

The project-specific plan was: preserve and restore the full workspace; reproduce
the 13 patches plus icon in isolation; import identical engine/SDL changes; replace
build-time mutations with pin checks; provide complete source and notices; build,
audit and rehearse rollback before opening the app PR.

## Old-to-new mapping and permitted differences

[patch-map.json](patch-map.json) maps all 13 historical patches to engine commits.
Patch 0009's SDL portion is separately committed as
`49cc7a303e4a7011d76b692b469b6f5f69269fd3`. The preceding SDL commit
`e63261276` preserves the exact 2.32.10 release distribution (release metadata
added; upstream CI/gitignore omitted by that tarball), without changing runtime
source. The app icon copy became engine commit `c13715fc1`.

After the behavior commits, the engine adds an SDL gitlink and moves generated
version files from the source tree into the build directory. Its deterministic
iOS version suffix is `.1433-caesarpad`, replacing Git/dirty-check-dependent
`.1433-69c698276-dirty`. This provenance string and generated paths are explicit
exceptions to byte parity; the game implementation, assets and build options
remain unchanged. See [validation evidence](VALIDATION.md).

`patches/augustus/` is historical evidence for Preview 1, owned by CaesarPad
maintainers. It is not production input. `apply-patches.sh` remains only as a
read-only compatibility entry point. There are no remaining production patches.

## Build and source delivery

```sh
git clone --recurse-submodules https://github.com/chrissotraidis/caesarpad.git
cd caesarpad
scripts/fetch-deps.sh
scripts/check-repo-safety.sh
scripts/test-touch.sh
scripts/build-device.sh
scripts/package-ios.sh
```

Until this PR merges, check out `codex/source-maintenance` and update submodules
in that fresh clone. Run `scripts/build.sh` for the iPad Simulator. These are the
supported iOS device and Simulator paths; upstream desktop/Android configurations
are not CaesarPad shipping platforms. No device access is required for an unsigned
build. Xcode and CMake are external toolchain prerequisites, recorded in provenance.

Normal builds validate clean dependency commits, every SDL_mixer file and mode,
and the tracked icon. A dirty/mismatched dependency fails without resetting it.
Only a missing SDL_mixer directory is fetched; an existing changed tree is never
replaced automatically. Commit app edits before stamping or packaging a candidate.
The package rejects stale build provenance and collects per-component notices.

Packaging creates an IPA and a complete `*-source.tar.gz`, each with a checksum.
The source archive contains the app, Augustus, SDL, easyav1, dav1d, SDL_mixer's
release contents, licenses, build scripts, lock and `SOURCE_MANIFEST.json`.
It excludes Git databases, private checkouts, game data, builds and signing state.
An automatic GitHub source ZIP is insufficient because it omits submodule contents.

```sh
tar -xzf CaesarPad-0.1.0-preview.1-source.tar.gz
cd CaesarPad-source
scripts/check-sources.py
scripts/build-device.sh
```

This source restoration/build needs no network or Git history after obtaining the
archive; Xcode and CMake must already be installed. This means source-complete,
not a promise of byte-identical signed binaries across Xcode/SDK versions.
Preview 1's existing public IPA remains the original `07a8d38` binary and its
original source link/patch workflow remains available. The new candidate/source
archive is for review; no historical release assets were changed.

## Making fixes and comparing upstream

Create a topic branch in the relevant fork based on the selected lock commit.
Commit fixes as normal source; compare with `git diff <upstream-base>..<selected-pin>`
and review individual commits with `git log <upstream-base>..<selected-pin>`.
For SDL, distinguish the release-distribution commit from the UIKit change.
Keep app-specific branches separate. Do not advance other apps or a shared default
branch. An upstream version upgrade needs its own behavior qualification.

After dependency review, select the new gitlink, update `sources.lock.json`, test
and commit the app change. SDL_mixer updates require a separately reviewed release
hash and file manifest. Report uncertain platform bugs to CaesarPad first with
version/pins and useful logs, never game files or private device identifiers.
No upstream issue or PR is created by this maintenance task.

## Rollback

The original checkout, local changes, nested sources, Git history and known-good
packages were backed up privately and restored to a separate location. That copy
is on the same physical disk, not disaster recovery. Private recovery paths and
full manifests are recorded in the task handoff, not committed to GitHub.

For source rollback, use a disposable clone; do not reset a user's dirty checkout:

```sh
git clone --recurse-submodules https://github.com/chrissotraidis/caesarpad.git CaesarPad-rollback
cd CaesarPad-rollback
git checkout 07a8d38a4eae77d01c6d980ecbc36de8fad97ef6
git submodule update --init --recursive
scripts/fetch-deps.sh
scripts/apply-patches.sh
scripts/check-repo-safety.sh
scripts/test-touch.sh
```

Keep an installed app and its data intact. Re-sign a preserved unsigned package
with the same established identity and install in place only when authorized.
Back up the whole relevant container/settings before device work. Bundle/signing
mismatch means stop; uninstalling is not a rollback procedure. No new hardware or
gameplay acceptance is claimed by this source migration.
