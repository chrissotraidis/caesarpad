# Research Annex — Community Demand & Comparable Projects

*Research date: July 17, 2026.*

## 1. Community health

| Metric (2026-07-17) | Julius | Augustus |
|---|---|---|
| Stars / forks / watchers | 3,320 / 424 / 83 | 2,035 / 165 / 56 |
| Open issues | 10 | 96 (76 issues + 20 PRs) |
| Last push | 2026-06-23 | **2026-07-17 (same day)** |

- Downloads: Julius v1.8.0 (Jul 2025): 24,841 in <1 yr; lifetime GitHub ≈ 98k. Augustus v4.0.0 (Dec 2023): **42,295** (Windows 12,249, Linux 3,593, Android 1,208, macOS 1,058); dev builds widely used besides.
- Steam: Caesar 3 still has ~137 concurrent players (peak 245, Dec 2024), "Very Positive" (2,139 reviews) — [Steambase](https://steambase.io/games/caesar-3/steam-charts). GOG still sells it and officially recommends Julius.
- Forums: HeavenGames Caesar III alive (fresh scenario uploads referenced from a July 2026 Augustus issue); GamerZakh Discord hosts the Julius/Augustus community; r/caesar3 and r/impressionsgames exist (sizes unverified — Reddit blocked in research environment).

## 2. Mobile/iPad demand evidence

- Julius [issue #643](https://github.com/bvschaik/julius/issues/643) (2022–2025, 24 comments): sustained iOS requests; resolved by the merged port, blocked on distribution.
- Augustus [issue #1036](https://github.com/Keriew/augustus/issues/1036): iPad user attempting to play the Emscripten build in Safari ("Ios browser disallows selecting folder in web version of augustus").
- Android as proxy: Julius Play Store ≈ **39,000 installs** ([AppBrain](https://www.appbrain.com/app/julius/com.github.bvschaik.julius)) vs ~1.4k direct APK downloads per release → **store-style distribution multiplies reach ~10–25×; distribution, not demand, is the bottleneck.**
- DevilutionX Android: **500K+ Play installs, 4.1★** vs ~10k direct APK — same pattern at larger scale.

## 3. Player requests & frustrations (issue trackers)

- Touch gesture map was co-designed in [Julius #269](https://github.com/bvschaik/julius/issues/269) (25 comments) — works but dated.
- **#1 mobile complaint: UI too small.** [Julius #631](https://github.com/bvschaik/julius/issues/631): "everything is still too tiny for my big fingers… I just want things to be bigger"; also requests a ScummVM-style shortcut overlay. Related: [Augustus #1226](https://github.com/Keriew/augustus/issues/1226) (display-scale/cursor mismatch, +6 reactions).
- No pause without keyboard on tablets: [Julius #613](https://github.com/bvschaik/julius/issues/613).
- Controller support on Android handhelds: [Julius #787](https://github.com/bvschaik/julius/issues/787), [Augustus #1754](https://github.com/Keriew/augustus/issues/1754) (implemented May 2026).
- Android platform fragility as cautionary tale: [Augustus #1016](https://github.com/Keriew/augustus/issues/1016) (startup crash, 20 comments, wontfix).

## 4. Comparable projects

| Project | iOS/iPad | Distribution | Signal |
|---|---|---|---|
| Fallout 2 CE | Yes (PR #167, Oct 2022) | Sideload IPA only | 2,365 stars; model works |
| DevilutionX | Yes, official IPA per release | AltStore/Sideloadly | 9,612 stars; Android 500K+ installs — ceiling proof |
| VCMI (Heroes III) | Yes — best-in-class | **Public TestFlight** + sideload; "road to App Store" | 5,739 stars; in-app GOG-installer import is the pattern to study |
| OpenRA / Red Alert | No iOS port (Mono) | — | Unserved audience; not a precedent |
| HoMM3 HD (official Ubisoft) | Was on App Store (2015) | Delisted ~2018 | Commercial iPad demand existed; abandonment created VCMI's space |
| OpenTTD | Not currently | Historic ports died (GPL conflict 2010; 3rd-party listing unpublished 2024) | Unmaintained store ports die |
| Pharaoh: A New Era (2023 remaster) | PC only | Steam/GOG, ~$3.6M est. gross | Impressions-style city builders still sell |

## 5. Sideloading accessibility (2026)

- AltStore >1.5M downloads by 2022; AltStore PAL live in EU (2024) and Japan (Dec 2025), Brazil; **on-device sideloading without a computer since May 2026** ([AlternativeTo](https://alternativeto.net/news/2026/5/altstore-launches-on-device-app-sideloading-without-a-computer-or-altserver/)).

## 6. Traction estimate

- **For:** proven store-multiplier effect (Julius Play, DevilutionX), current & documented iPad demand, upstream engineering ~done, sideloading friction at an all-time low, zero competing iPad option.
- **Against:** niche ceiling (tens of thousands, not millions); sideload-only channels historically deliver low-thousands per release; app-store-class channels are license-constrained.
- **Estimate:** low-thousands of users on sideload channels in year one; 5–10× that if an AltStore PAL / notarized channel ships. Consistent with the 5,000-download 12-month success metric in the PRD.

*Unverified items:* r/caesar3 subscriber count, GOG review counts, per-asset DevilutionX iOS IPA download counts (source access blocked or rate-limited during research).
