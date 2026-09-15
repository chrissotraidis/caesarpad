# Migration validation — 2026-09-15

The qualified local candidate was built from clean app commit
`c35a092880988b05387dd3a790e63a2c346abd64`. Subsequent validation-documentation
commits do not change that candidate's source identity. No new release, merge,
installation, or gameplay acceptance is claimed here.

## Starting point and preservation

Live `chrissotraidis/caesarpad` main and public Preview 1 both resolve to
`07a8d38a4eae77d01c6d980ecbc36de8fad97ef6`. The public IPA was downloaded
anonymously and its ZIP, identity, source link and checksum verified:
`89e9d49f168a46206f718c02bc5abc1daff2e77543d7e576cba1bc7faa36e9fc`.
Its public asset and tag were left unchanged.

The original dirty checkout, unrelated Akhenaten plan, Git history, ignored
working sources, existing packages and signing state were copied privately.
55,568 entries in the original, backup and independent restore match SHA-256,
POSIX modes and symlink targets. This is a same-physical-disk APFS copy, not
protection against disk failure. No devices were accessed and no device backup
is claimed. Recovery locations/manifests are in the private task handoff.

## Source parity and attribution

The old production preparation was reproduced from the exact base, original
SDL release archives, all 13 patches and the icon copy. The local engine differs
from that reconstruction only by an Info.plist trailing newline and generated
version outputs, with no additional private gameplay delta imported.

7,871 prepared-tree entries were compared by SHA-256, modes and symlink targets.
Only `.gitmodules` and `CMakeLists.txt` differ after migration, for the documented
SDL gitlink, generated-file paths and stable provenance suffix. Engine code,
SDL UIKit code, icon and remaining resources match exactly. The three generated
outputs (`version.c`, `version.rc`, `version.txt`) match after replacing only
`.1433-69c698276-dirty` with `.1433-caesarpad`.

Selected pins:

- Augustus: `5b18072da2a43bd6b3e9df240553d8c9d9a72bf6`, GitHub parent Keriew/augustus.
- SDL: `49cc7a303e4a7011d76b692b469b6f5f69269fd3`, GitHub parent libsdl-org/SDL.
- easyav1: `8233d82f7334222289f95e1f42713a87f5e0e4c7` (unchanged).
- dav1d: `46e901735541716e18d90d361e311b58ee95a281` (unchanged; AV1 disabled).
- SDL_mixer: 2.8.2 archive and file manifest in `sources.lock.json` (unchanged).

Existing upstream licenses and author history are retained. The package audit
verified 56 legal files, including copied embedded MPEG/dr_flac/stb_vorbis license
headers and nested component notices. This is a source/notices audit, not a new
license grant or blanket legal clearance. Original game material remains excluded.

## Validation performed

- Repository safety, shell syntax, pin/gitlink/URL checks and all 10 existing
  touch tests passed.
- Deliberate changes to Augustus, nested SDL and downloaded SDL_mixer were
  rejected without reset; files were restored after each disposable test.
- A missing SDL_mixer directory was downloaded, checksum-verified, normalized
  to the original extraction modes, and fully verified. Existing modified
  directories are rejected rather than replaced.
- Unsigned arm64 iPhoneOS and arm64 iPad Simulator builds succeeded with
  Xcode 26.6 (17F113), AppleClang 21, CMake 4.4.2 and Python 3.11.2.
- An exported source archive at app commit `99a2379` was restored without `.git`
  and built successfully with HTTP/HTTPS proxies pointed at an unavailable
  local endpoint. No dependency download or private checkout was needed.
- The final delivered candidate archive was independently extracted and passed
  manifest validation. Its entire engine/dependency contents match the successful
  restored-source build. Deliberate archived-source corruption was rejected.
- Two source exports from the same clean commit were byte-identical, including
  gzip metadata. Both candidate checksum files passed from their output directory.
- Disposable rollback to `07a8d38` initialized the original recursive graph,
  fetched original SDL releases, replayed all 13 patches, and passed the original
  repository safety and all 10 touch tests. Main and the original checkout were
  not reset or modified.

## Candidate package identity

Local review candidate, not a published release:

| Artifact | SHA-256 |
|---|---|
| `CaesarPad-0.1.0-source-review-unsigned.ipa` | `cb6a6af6e450345327badb990a6d3542feebeb2fdb8522d3dab5d22eeb03f228` |
| `CaesarPad-0.1.0-source-review-source.tar.gz` | `2ce0db8e64c762df4a4fa6a9950ef5a14d49cdf68809cc458a908c3308ed8c0d` |

ZIP integrity passed. Bundle ID remains `com.chrissotraidis.caesarpad`, version
0.1.0, build 1, minimum iPadOS 14.0. Landscape/full-screen and Files/Documents
settings match Preview 1. Device-family metadata remains `[1,2]`; this does not
constitute new iPhone UI acceptance. All 4,190 bundled engine asset files match
the public IPA byte-for-byte. No signatures, profiles, game data, saves or keys
were found in the candidate. Provenance identifies the exact app/dependency
commits and the pre-packaging executable/Info.plist hashes.

The original public IPA used an earlier toolchain, so whole-executable or signed
IPA byte equality is not asserted. Actual touch feel, audio, lifecycle stress,
Pencil hardware and gameplay have not been newly tested. A future binary release
requires its own authorization and acceptance scope.
