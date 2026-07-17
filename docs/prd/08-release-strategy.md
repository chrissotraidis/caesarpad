# PRD — Release Strategy

## 1. Channels (decided by the licensing research — see `docs/research/annex-licensing.md`)

| Channel | Status | Rationale |
|---|---|---|
| Unsigned IPA on GitHub Releases (+ checksums) | **Primary, day one** | License-clean (user self-signs via AltStore Classic/SideStore/Sideloadly); the DevilutionX/fallout2-ce pattern |
| AltStore/SideStore source JSON (GitHub Pages) | **Primary, day one** | In-app updates; one-time setup for users |
| Build-from-source (Xcode) | Supported, documented | Upstream's current path; free, 7-day-free-account caveat documented |
| AltStore PAL (EU/JP/BR; UK when live) | **Phase-6 gate** | Requires Apple Developer account + notarization; AGPL Delta precedent makes it viable; **rename gate (R2) must clear first** |
| TestFlight | Explicitly deferred | Legally gray for AGPL (VCMI practices it; VLC history warns); revisit only with upstream maintainers' blessing |
| App Store | **Out of scope** | Unobtainable copyright-holder consent (~50+ contributors, no CLA); upstream maintainer has ruled it out |

## 2. Release stages

### Developer Preview (after Phase 2)
- Audience: Julius/Augustus contributors + Discord volunteers (~10–30 people).
- Content: Augustus flavor only; importer works; known-rough touch UX.
- Channel: CI artifacts + manual sideload; feedback via GitHub issues with diagnostics export.
- Exit: 10 successful independent installs; import success on GOG+Steam layouts confirmed.

### Alpha (after Phase 4)
- Audience: ~100 sideload-comfortable players recruited from Discord/r/caesar3.
- Content: both flavors; full touch scheme; save round-trip verified.
- Channel: GitHub pre-releases + AltStore source (beta channel).
- Exit: Phase-4 usability gate passed; no data-loss bugs open; crash reports < 1/10 sessions.

### Beta (after Phase 5–6)
- Audience: open beta, announced in community channels.
- Content: feature-complete 1.0 scope; install guides final.
- Exit: 2 weeks without regression-class bugs; device-matrix checklist green; docs complete.

### Public 1.0
- Coordinated launch (Phase 7.3): upstream maintainers pre-briefed (they get credit and the
  upstreamed patches); posts in GamerZakh Discord, r/caesar3, r/impressionsgames,
  HeavenGames; GOG forum thread (GOG already endorses Julius — a natural fit).
- Release artifact set: 2 IPAs + checksums + source archive with pinned submodules
  (AGPL corresponding source), THIRD-PARTY-NOTICES, changelog.

## 3. Versioning & cadence

- CaesarPad version `MAJOR.MINOR.PATCH` independent of engine versions; release notes state
  embedded engine versions/SHAs.
- Monthly maintenance release (submodule bumps + fixes); out-of-band for data-loss/crash
  fixes.
- Each release ships from a tag through `release.yml` only — no hand-built binaries ever.

## 4. Future roadmap (post-1.0 candidates, unordered)

- AltStore PAL lane (post-rename) and UK availability when the DMA-equivalent lands.
- iCloud Drive saves (FR-3.4) and cross-device save hand-off.
- SDL3 migration alongside Augustus upstream (safe-area API, pen API, Metal-first).
- Stage Manager / resizable-window investigation (blocked on SDL iOS single-window model).
- Julius-flavor iPhone experiment (640×480 floor permitting) — explicitly not before.
- Augustus scenario/campaign browser (HeavenGames ecosystem integration) — engine-side,
  upstream-first.
- Controller-first couch mode (iPad → external display mirroring + controller).
