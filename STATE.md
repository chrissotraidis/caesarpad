# CaesarPad Build State

Last updated: 2026-07-26

## Gates

| Gate | Status | Evidence |
|---|---|---|
| G0 — Toolchain | PASS | Xcode 26.6 (17F113); iOS 18.5 and 26.5 Simulator runtimes; booted iPad Pro 11-inch (M4), iOS 18.5, UDID `08636791-2675-4675-8335-EF72EF954DCF`; `artifacts/g0/` |
| G1 — Engine builds | CURRENT | Not yet run |
| G2 — Boots | PENDING | — |
| G3 — Data loads | PENDING | — |
| G4 — Playable | PENDING | — |
| G5 — Touch controls | PENDING | — |
| G6 — Lifecycle safe | PENDING | — |
| G7 — Test suite | PENDING | — |
| G8 — Repeatable | PENDING | — |

## Pinned inputs

- Augustus: pending G1 checkout and SHA pin.
- SDL2: pending G1 fetch.
- SDL2_mixer: pending G1 fetch.

## Decisions

- Augustus is the only engine flavor in this build loop.
- The iOS 18.5 iPad Pro 11-inch (M4) Simulator is the primary automated target.
- `ref/` is ignored and reserved for user-owned Caesar III data. Its contents must never be staged or committed.
- Engine changes, if a gate requires them, live as small patches under `patches/`; the engine remains a submodule.

## Current blocker

None. Current work is G1: pin Augustus, fetch the exact SDL releases used by upstream iOS documentation, generate the Xcode project, and make the Simulator build reproducible through `scripts/build.sh`.
