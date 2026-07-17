# PRD — Product Overview

## Vision

Caesar III is one of the best-regarded city builders ever made, and the iPad is the best
device ever made for playing it — a large multi-touch canvas, always-on, couch-friendly,
with pencil, trackpad and keyboard options. Two mature open-source engines (Julius and
Augustus) already compile for iOS, yet **nobody can actually play Caesar III on an iPad
today** without building an Xcode project themselves: upstream ships no IPA, no importer
polish, no touch-first UX, and no distribution channel.

**CaesarPad closes that last mile.** It is a packaging, polish and distribution project that
turns the upstream engines' latent iOS support into a product: a signed/side-loadable app
with a native first-launch asset importer, an iPad-native control scheme, Files/iCloud save
handling, and per-device display tuning — while pushing every engine-level improvement back
upstream.

## Purpose

- Give Caesar III players a legitimate, polished way to play on iPad using their own
  legally-purchased game assets (GOG / Steam / CD).
- Serve both player audiences: vanilla purists (Julius flavor — 100% save compatibility with
  the original) and enhanced-gameplay players (Augustus flavor — zoom, roadblocks, monuments).
- Strengthen, not fragment, the upstream ecosystem: CaesarPad carries no permanent fork.

## Goals

1. **G1 — Installable:** a user with an iPad and a GOG copy of Caesar III can be playing
   within 10 minutes of finding the project, without Xcode.
2. **G2 — Touch-first:** every core loop (place buildings, draw roads, manage advisors,
   fight fires/invasions) is comfortable with fingers alone; keyboard/trackpad/controller are
   enhancements, not requirements.
3. **G3 — Data-safe:** saves are never trapped — visible in the Files app, exportable,
   optionally in iCloud Drive, and compatible with desktop Julius/Augustus/vanilla per each
   engine's compatibility contract.
4. **G4 — Upstream-first:** ≥ 90% of engine-side diff lines land in upstream PRs; the patch
   queue trends toward zero.
5. **G5 — Sustainable:** release pipeline is fully automated (tag → IPAs + AltStore source),
   so maintenance is submodule bumps, not manual builds.

## Non-goals

- **No App Store listing at launch.** Upstream's maintainer has ruled the App Store out of
  bounds for AGPL Julius (issue #643); CaesarPad launches on sideloading channels and
  revisits store distribution only with explicit legal review and copyright-holder consent
  (see Release Strategy).
- **No gameplay changes.** Game logic belongs to the engines; CaesarPad contributes only
  platform/UX code.
- **No asset distribution.** CaesarPad never ships, downloads, or links to Caesar III game
  data. No "abandonware" convenience features.
- **No iPhone-first design.** iPhone may incidentally work (engines require 640×480 minimum
  logical resolution, which is hostile to phones); iPad is the design target.
- **No Android/desktop builds.** Upstream already serves those platforms well.
- **No new engine abstraction layer.** See Technical Requirements §8.

## Success metrics

| Metric | Target (12 months post-1.0) |
|---|---|
| Time from "found the project" to "playing" (median, self-reported + docs walkthrough test) | ≤ 10 min |
| GitHub release IPA downloads | ≥ 5,000 (calibration: Julius 1.8.0 shipped 1,428 Android APK / 2,409 macOS downloads in its first year; sideload iOS should land in that band or above given zero prior iPad option) |
| Import success rate (opt-in telemetry is a non-goal; measure via issue rate) | < 5% of issues are import failures |
| Upstreamed PRs merged (Julius + Augustus) | ≥ 10, patch queue ≤ 3 standing patches |
| Crash-free sessions (TestFlight metrics if that lane ships) | ≥ 99.5% |
| Community | ≥ 500 members reached via existing Julius/Augustus Discord + r/caesar3 threads; CaesarPad thread in each |

## Target audience

1. **Returning fans** (30s–50s) who played Caesar III on PC, own or will buy the GOG copy,
   and want couch/tablet play. Largest group; low tolerance for jank, moderate technical
   skill (can follow an AltStore guide with screenshots).
2. **Existing Julius/Augustus players** (the ~3.3k + ~2k GitHub-star communities and Discord)
   who already run the engines on desktop/Android and want save-portable iPad play. High
   technical skill; will sideload day one; will file good bugs.
3. **iPad strategy-gaming enthusiasts** who buy premium ports (Rome: Total War, Civ VI on
   iPad) and follow sideloading/emulation communities. Discovery channel more than core base.
