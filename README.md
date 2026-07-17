# CaesarPad

**A feasibility study and engineering PRD for bringing Caesar III to iPadOS as a polished,
native experience, built on the open-source [Julius](https://github.com/bvschaik/julius) and
[Augustus](https://github.com/Keriew/augustus) engines.**

> **Verdict: GO.** Both upstream engines already contain merged, CI-tested iOS build
> support (January 2025). What's missing is the last mile — importer UX, iPad-native
> controls, lifecycle hardening, packaging, and distribution. That last mile is this
> project. Read the [feasibility report](docs/feasibility-report.md).

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

Julius and Augustus are mature AGPL-3.0 re-implementations of Caesar III that run on eight
platforms and, since January 2025, build for iOS in upstream CI — but no installable iPad
build has ever shipped: the AGPL rules out the App Store, upstream won't distribute
unsigned IPAs, and the merged iOS support stops at "it compiles and boots." CaesarPad is a
wrapper project (pinned submodules + upstream-first patches + a native Swift UX kit) that
ships what's missing: a validating first-launch asset importer for user-owned GOG/Steam/CD
copies, Files-app-visible saves, background autosave, iPad-tuned touch controls with
pinch-zoom, and automated unsigned-IPA releases installable via AltStore/SideStore — with
an AltStore PAL lane as the stretch goal.

## Status

Phase 0 (research validation) is specified and ready to execute — see the
[roadmap](docs/prd/04-roadmap.md).

## Legal notes

- This repository contains **no Caesar III game data** and never will. Playing requires
  your own legally purchased copy ([GOG](https://www.gog.com/en/game/caesar_3),
  [Steam](https://store.steampowered.com/app/517790/Caesar_3/)).
- CaesarPad is not affiliated with or endorsed by Activision, Microsoft, or the owners of
  the Caesar trademark. "CaesarPad" is a working title used descriptively; see risk R2 in
  the [risk register](docs/prd/07-risk-register.md) regarding renaming before distribution.
- Engine code is AGPL-3.0 (Julius, Augustus); this project's code will be AGPL-3.0.
