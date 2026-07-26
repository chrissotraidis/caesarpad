# CaesarPad

**Caesar III on iPadOS, powered by the open-source
[Augustus](https://github.com/Keriew/augustus) engine.**

CaesarPad is a focused Simulator-tested port layer: it pins Augustus, applies four small
iPad patches, and automates the complete build, data-load, gameplay, touch, and lifecycle
flow. Read the [feasibility report](docs/feasibility-report.md) for the original
investigation.

## Documents

### Deliverable 1 — Feasibility
- **[Feasibility report](docs/feasibility-report.md)** — executive summary, verdict,
  scores, risks, unknowns, and the fastest experiments to resolve them.

### Deliverable 2 — Product Requirements Document
- [00 Product overview](docs/prd/00-product-overview.md) — vision, goals, non-goals,
  success metrics, audience
- [01 Functional requirements](docs/prd/01-functional-requirements.md)
- [02 Technical requirements](docs/prd/02-technical-requirements.md) — architecture,
  repository design, build system, CI
- [03 UX requirements](docs/prd/03-ux-requirements.md) — install flow, importer, iPad
  control scheme, display, accessibility
- [04 Engineering roadmap](docs/prd/04-roadmap.md) — Phases 0–7 with exit criteria
- [05 Autonomous task breakdown](docs/prd/05-task-breakdown.md) — agent-executable tasks
  with acceptance criteria
- [06 Testing plan](docs/prd/06-testing-plan.md)
- [07 Risk register](docs/prd/07-risk-register.md)
- [08 Release strategy](docs/prd/08-release-strategy.md)

### Research evidence
- [Engine comparison: Julius vs Augustus](docs/research/engine-comparison.md) — from
  direct code inspection
- [Annex: Julius](docs/research/annex-julius.md) ·
  [Annex: Augustus](docs/research/annex-augustus.md) ·
  [Annex: SDL on iOS & port precedents](docs/research/annex-ios-sdl.md) ·
  [Annex: licensing & legal](docs/research/annex-licensing.md) ·
  [Annex: community & comparables](docs/research/annex-community.md)

## The one-paragraph version

Augustus is a mature AGPL-3.0 reimplementation of Caesar III with an upstream iOS target.
CaesarPad pins that engine, applies a small reviewed patch queue, and proves the iPad last
mile in Simulator: user-owned data import, landscape rendering, direct touch controls,
pinch zoom, one native pause button, and background autosave/resume. The repository never
contains Caesar III assets.

## Status

The Augustus Simulator build, landscape gameplay, minimal touch controls, lifecycle
autosave/resume, and automated end-to-end suite are implemented. See [STATE.md](STATE.md)
for gate evidence.

## Build and test

Prerequisites:

- macOS with Xcode 26.6, an iPad Simulator runtime, CMake 3.25+, Git, and `curl`
- the Augustus submodule initialized with `git submodule update --init --recursive`
- network access on the first build for the pinned SDL2 and SDL2_mixer source releases
- your legally purchased Caesar III data at `ref/Caesar 3/C3` (or set
  `C3_SOURCE_DIR`); `ref/` is ignored and must never be committed
- the recorded iPad Simulator is used by default; set `SIMULATOR_UDID` to another
  available iPad Simulator when needed

From the repository root, the exact commands are:

```sh
scripts/build.sh
scripts/test.sh
```

`scripts/test.sh` builds, boots the Simulator, injects local game data, and verifies
playable interactions, touch mappings, and background autosave/resume.

## Legal notes

- This repository contains **no Caesar III game data** and never will. Playing requires
  your own legally purchased copy ([GOG](https://www.gog.com/en/game/caesar_3),
  [Steam](https://store.steampowered.com/app/517790/Caesar_3/)).
- CaesarPad is not affiliated with or endorsed by Activision, Microsoft, or the owners of
  the Caesar trademark. "CaesarPad" is a working title used descriptively; see risk R2 in
  the [risk register](docs/prd/07-risk-register.md) regarding renaming before distribution.
- Engine code is AGPL-3.0 (Augustus); this project's code is AGPL-3.0.
