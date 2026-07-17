# CaesarPad — Technical Feasibility Report

**Date:** 2026-07-17 · **Status:** Final · **Method:** direct code inspection of both engine
repositories plus five parallel primary-source research tracks (engines, SDL/iOS, licensing,
community, comparables). Evidence annexes: `docs/research/`. Companion deliverable: the full
PRD in `docs/prd/`.

---

## Executive summary

CaesarPad — a polished, native-feeling Caesar III experience for iPadOS built on the
open-source Julius and Augustus engines — is **technically feasible with high confidence**,
because the hardest work already exists upstream and is merged, CI-tested, and maintained:

- **Both engines already build for iOS.** Julius merged iOS support in January 2025
  (PR #743, contributor axmo); Augustus merged the same work days later (PRs #1161/#1162)
  and has run an iOS CI job since February 2026. Both trees contain
  `TARGET_PLATFORM=ios` CMake targets, an `src/platform/ios/` backend with a
  UIDocumentPicker-based data importer, iOS resource bundles, and documented build steps
  (`doc/iOS.md`). [facts — verified in code and upstream PRs]
- **The engines' architecture is port-friendly:** portable C99 simulation code above a
  single platform seam (`src/platform/`) that already serves Windows, macOS, Linux,
  Android, Switch, Vita, and the browser; a mature touch layer (tap/double-tap/drag/
  two-finger scroll, three modes) built for the Vita/Switch/Android ports; and, in
  Augustus, GPU rendering with pinch-zoom — the key tablet interaction. [facts]
- **What's missing is the last mile, not the port:** no IPA is published anywhere, the
  importer is a bare-bones single-shot folder copy, saves are invisible to the Files app,
  there's no safe-area/lifecycle/audio-session hardening, no iPad-tuned control defaults,
  and no distribution channel. This is precisely scoped, well-understood product work.
  [facts]
- **Demand is proven but niche.** The Caesar III community is small yet remarkably alive
  (~137 Steam CCU for a 1998 game; Augustus committed-to today; 42k downloads of its last
  stable). Upstream's own data shows distribution is the bottleneck: Julius's Play Store
  listing reached ~39k installs versus ~1.4k direct APK downloads per release. A
  well-distributed iPad build should reach low-thousands of users sideloaded, more if an
  AltStore PAL lane ships. [facts + estimate]
- **Legal posture is manageable.** Both engines are AGPL-3.0: App Store is out
  (upstream's maintainer says so herself; ~50+ copyright holders make consent
  unobtainable), but unsigned-IPA sideloading is license-clean and AltStore PAL already
  hosts AGPL software (Delta). The bring-your-own-assets model is endorsed for this exact
  game by GOG's own support pages. One real flag: the name "CaesarPad" embeds a mark that
  is actively asserted ("Caesar™ 3" on Steam) — keep as working title, rename before
  marketplace distribution. [facts + recommendation]

## Technical verdict: **GO**

(Conditional only on Phase-0 hardware validation — a days-long, cheap-to-fail gate — and on
accepting sideloading as the launch channel.)

| Dimension | Score | Basis |
|---|---|---|
| Technical feasibility | **9/10** | Port exists upstream; remaining work is UX/packaging; no unknowns of architectural size |
| Engineering effort | **~2–3 engineer-months** to polished 1.0; developer preview in 2–3 weeks | Roadmap §04, dominated by importer + touch polish |
| Community demand | **Moderate (niche, durable, underserved)** | Annex-community: multipliers observed when distribution friction drops |
| Legal risk | **Low** (with red lines held) | 9 years non-enforcement; GOG endorsement; OpenSC2K defines the only red line (never bundle assets); naming flag R2 |
| Platform risk | **Medium** | Sideloading policy churn (mitigated by multi-channel); SDL2 single-window/safe-area gaps (bridgeable) |
| Maintenance risk | **Medium → Low** | Near-daily Augustus churn vs. submodule pinning + nightly drift CI + upstream-first patches |

## Recommended foundation

**Augustus as the primary engine; Julius kept as a low-cost secondary flavor; no fork —
wrapper repo + pinned submodules + upstream-first patch queue.**

- Augustus has the iPad-critical features (GPU renderer, pinch-zoom, active maintainers,
  active player community) and the same iOS platform code as Julius.
- Julius earns its keep as the "purist" flavor (two-way vanilla save compatibility) and
  because the iOS surface of both trees is nearly identical — same files, same CMake
  switch — so one pipeline builds both.
- A shared *code* platform layer across both engines is **not** realistic (the trees have
  diverged by thousands of files); sharing happens at the pipeline/packaging/UX-kit level.
  Dual-engine support is therefore realistic and cheap — but Augustus is the one that must
  never break; Julius drops to best-effort if the patch sets diverge (risk R12).

**Alternative foundation** (if Phase 0 falsifies the primary): Augustus-only. There is no
credible third option — no independent iOS fork of either engine exists, and a from-scratch
engine is out of the question against a working upstream port.

## Answers to the primary questions

1. **Feasible?** Yes — see verdict. The port substantially exists; CaesarPad is
   productization.
2. **Which engine?** Augustus primary, Julius secondary flavor (above).
3. **Both engines realistically supportable?** Yes, at the packaging level (two IPAs, one
   pipeline, one native UX kit); no, at the shared-code level. Contract: Augustus is
   load-bearing, Julius is best-effort.
4. **Is there already an iPad port?** Yes and no — **iOS build support is merged upstream
   in both engines** (Jan 2025) and CI-tested, but no installable artifact, importer UX,
   iPad tuning, or distribution channel exists. Nobody ships a playable iPad build today.
5. **Why not?** (a) AGPL-3.0 blocks the App Store and upstream won't ship unsigned IPAs
   (bvschaik: "Providing a downloadable ipa won't work since that's not signed"); (b) the
   iOS contributor delivered build support, not product polish; (c) upstream maintainer
   bandwidth is focused on the game, not Apple distribution mechanics. All three are
   exactly the gap a dedicated packaging project fills.
6. **What engineering work remains?** Importer with validation/progress/re-import; Files
   app exposure + save management; lifecycle autosave; audio-session correctness;
   safe-area/display-scale tuning; iPad touch defaults + pinch polish + overlay toolbar;
   pointer/keyboard verification; IPA packaging + AltStore source + CI; docs. Fully
   enumerated with acceptance criteria in `docs/prd/05-task-breakdown.md`.
7. **Largest technical risks?** Touch UX quality bar (R4), lifecycle data loss (R5),
   upstream drift (R3), performance floor on older iPads (R9). None architectural; all
   have named mitigations and detection.
8. **Licensing restrictions?** AGPL-3.0 everything; publish corresponding source per
   release; no App Store; attribution for Augustus's CC BY-SA 3.0 assets; fix vendored
   notice gaps (sxml/zip) in shipped bundles. Full analysis in annex-licensing.
9. **Can users legally provide their own assets?** Yes — the engines are designed around
   it, the wording to copy is Julius's own README, GOG (the rights-holder's storefront)
   officially recommends Julius to Caesar III buyers, and the only enforcement precedent
   (OpenSC2K) punished bundling assets, not requiring them. Never bundle or link to game
   data.
10. **Worth building?** Yes, with honest expectations: a durable niche product
    (low-thousands to tens-of-thousands of players), high gratitude-per-user, near-zero
    competition, a clean upstream-contribution story, and an unusually low-risk build
    because the engine work is done. It is not a viral hit; it is the definitive way to
    play a beloved game on the device best suited to it.

## Unknowns → fastest experiments

| # | Unknown | Fastest experiment | Cost |
|---|---|---|---|
| U1 | Real-device fps/feel (esp. Julius software blit at Retina; Augustus zoomed-out on 13") | Phase 0.2: sideload both CI artifacts on one iPad, 15-min protocol | Hours (needs 1 device + Apple ID) |
| U2 | SDL iPadOS pointer behavior (hover, right-click, trackpad pinch) with `UIApplicationSupportsIndirectInputEvents` | Plist-flag build variant + Magic Keyboard session | Hours |
| U3 | GOG/Steam/CD/localized folder-layout variance for the validator | Pinned community issue asking for `find . -type f` listings; collect ≥10 samples | Days, parallel |
| U4 | Audio-session edge cases (mute switch, interruptions) under SDL2_mixer | Scripted interruption pass in U1's session | Included in U1 |
| U5 | Whether upstream will accept the patch set (hooks, lifecycle, touch defaults) | Open the first two PRs (lifecycle autosave, importer hook) early in Phase 2–3 and read the weather | Days of elapsed time, near-zero effort beyond work already planned |
| U6 | AltStore PAL acceptance for an AGPL city-builder + notarization friction | Dry-run submission of a renamed test build at Phase-6 gate | Days + $99 account (gated, not blocking) |
| U7 | Actual sideload conversion (install-guide drop-off) | Developer Preview with 10–30 Discord volunteers | Built into release stages |

## Go decision

**GO.** Proceed to Phase 0 (research validation on hardware) and Phase 1 (repeatable
builds) immediately; both are cheap, reversible, and generate the evidence for every gate
after them. The PRD in `docs/prd/` is written to be executable by autonomous agents from
this point.
