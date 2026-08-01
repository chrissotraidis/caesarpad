# Research Annex — Licensing, Assets & Legal

*Research date: July 2026. This is research, not legal advice.*

## 1. Licenses

- **Julius: AGPL-3.0** ([LICENSE.txt](https://github.com/bvschaik/julius/blob/master/LICENSE.txt), [license API](https://api.github.com/repos/bvschaik/julius/license)). **Augustus: AGPL-3.0** (same).
- Julius `ext/`: libpng (PNG Reference Library v2), zlib 1.2.11 trimmed (zlib), tinyfiledialogs (zlib), dirent (MIT), SDL2 (zlib). MP3 decoding is delegated to SDL2_mixer (minimp3 bundled on iOS; desktop wiki mentions libmpg123/LGPL — not needed on iOS).
- Augustus `ext/`: spng (BSD-2-Clause), pl_mpeg (MIT), miniz (permissive), tinyfiledialogs (zlib), sxml (Unlicense), the pinned kuba--/zip copy (Unlicense), and easyav1 (BSD-3-Clause). The pinned tree includes `UNLICENSE` files for sxml and zip plus an explicit easyav1 license.
- All verified third-party components are permissive and AGPL-compatible. Public packages reproduce the relevant notices and complete license texts alongside the app.
- **Consequence for CaesarPad:** the whole distributed work is AGPL-3.0; CaesarPad's own code must be AGPL-3.0-compatible with full corresponding source published per release (pin exact submodule SHAs + patch set).

## 2. AGPL vs Apple distribution

- History: FSF's GNU Go enforcement (May 2010 — Apple removed the app rather than change terms: [FSF](https://www.fsf.org/news/2010-05-app-store-compliance)); VLC pulled Jan 2011 after a core developer's complaint ([FSF](https://www.fsf.org/blogs/licensing/vlc-enforcement)); VLC returned July 2013 only after relicensing (engine LGPL; iOS app MPL-2.0 + GPLv2 bi-license).
- The conflict is GPL/AGPL's "no further restrictions" vs App Store usage rules/DRM. AGPL §13 (network clause) is irrelevant for an offline game; **all GPLv3 store-incompatibility carries over**.
- **Copyright holders can waive:** Delta emulator is **AGPLv3 and on the App Store since Apr 17, 2024** because Riley Testut holds the copyright ([repo](https://github.com/rileytestut/Delta), [App Store](https://apps.apple.com/us/app/delta-game-emulator/id1048524688)). Julius/Augustus have ~50+ contributors, no CLA → App Store consent is unobtainable in practice; a single objecting contributor suffices to trigger a takedown (VLC precedent).
- Channel ranking by license risk:
  1. **Unsigned IPA on GitHub Releases + AltStore Classic/SideStore/Sideloadly** (user self-signs) — cleanest; the established GPL-iOS pattern (DevilutionX, fallout2-ce).
  2. **AltStore PAL** (EU DMA marketplace, live EU + Japan/Brazil, UK expected 2026; Apple notarization applies) — hosts AGPL Delta; practical conflict surface far smaller than the App Store.
  3. **TestFlight** — Apple terms attach (90-day builds, 10k testers); widely practiced (GPL VCMI runs a public TestFlight) but legally gray.
  4. **App Store** — not viable without unanimous holder permission.

## 3. Original game assets

- Chain of title: Impressions Games (dev) / Sierra On-Line (pub, 1998) → Vivendi → Activision Blizzard (2008) → **Microsoft** (merger effective Oct 13, 2023; [SEC S-8 POS](https://www.sec.gov/Archives/edgar/data/718877/000110465923110565/tm2328886d21_s8pos.htm)).
- **Not abandonware:** actively sold on [GOG](https://www.gog.com/en/game/caesar_3) and [Steam](https://store.steampowered.com/app/517790/Caesar_3/) at $5.99 (frequent ~35% discounts). "Abandonware" has no legal meaning.
- Bring-your-own-assets is well-precedented and, for this exact game, **endorsed by the rights-holder's own storefront**: GOG's support center article "Caesar III - an open-source implementation" instructs customers to install Julius ([support.gog.com](https://support.gog.com/hc/en-us/articles/360017642354-Caesar-III-an-open-source-implementation)). Comparable wording: Julius README ("Julius will not run without the original Caesar 3 files. You can buy a digital copy from GOG or Steam…"), DevilutionX, OpenTTD.
- **Red line — OpenSC2K (2018):** EA DMCA'd the open-source SimCity 2000 remake **because it bundled original sprites in the repo**; removal was the only acceptable remedy ([PC Gamer](https://www.pcgamer.com/ea-takes-down-open-source-simcity-2000-remake-for-using-copyrighted-assets/)). Clean-room engine + user-supplied assets was never the issue.
- Enforcement history: **no documented takedown/C&D against Julius, Augustus, or CaesarIA in ~9 years**, through HN front pages, press, console homebrew stores, and the Microsoft acquisition.

## 4. Required files (verified in engine source)

- `c3.eng` / `c3_mm.eng` (or localized `c3.rus` etc. — `src/core/lang.c`); `c3_model.txt` (`src/building/model.c`); `.sg2` index + `.555` graphics archives; `.wav` sound/speech; `smk/` Smacker videos; optional `mp3/` high-quality soundtrack (ROME1–5, Combat_Long/Short, setup — [wiki](https://github.com/bvschaik/julius/wiki/MP3-Support)).
- Version: patched **1.0.1.0** (GOG/Steam ship patched; CD needs the patch — [Julius wiki Patches](https://github.com/bvschaik/julius/wiki)).
- Mobile import precedent (Android, [doc/RUNNING.md](https://github.com/Keriew/augustus/blob/master/doc/RUNNING.md)): copy from computer or run Inno Setup Extractor on the GOG offline installer on-device. Steam has no iPad client → users copy `steamapps/common/Caesar 3` from a desktop.

## 5. Trademark & naming

- No live US registration of "Caesar III" as a video-game mark surfaced via USPTO aggregators, but **Steam sells "Caesar™ 3"** — common-law rights asserted on an actively sold product. Treat "no registration" as indicative, not conclusive.
- Peer projects avoid the mark in their names: **Julius**, **Augustus** (emperor names), CorsixTH, OpenRCT2, fheroes2, DevilutionX (+ explicit non-affiliation disclaimer).
- **"CaesarPad" embeds the mark in an app name for the same class of goods — elevated risk**, doubly so on any Apple storefront (App Review Guideline 5.2). Mitigations: (a) rename (emperor-line naming: e.g. "Tiberius", "Pertinax"), or (b) keep as working title for the repo, use it descriptively ("an iPad build of Julius/Augustus, open-source re-implementations of Caesar III"), add a DevilutionX-style disclaimer, and rename before any notarized/marketplace distribution. **Recommendation: (b) now, (a) before Phase 6.**
- Screenshots: Julius's README ships no gameplay screenshots (logo/original art only); Augustus embeds one (tolerated). CaesarPad follows the Julius pattern; screenshots live in docs/wiki if anywhere.

## 6. Augustus extra assets

- `res/assets/` licensed **CC BY-SA 3.0 Unported** ([LICENSE](https://raw.githubusercontent.com/Keriew/augustus/master/res/assets/LICENSE); changed at v3.2.0). Community-made; no per-artist credits file → attribute "the Augustus project contributors" + repo link.
- May be redistributed inside a CaesarPad IPA with attribution + share-alike. Residual (historically untested) style-derivative question exists; never pursued by the rights holder.

## 7. Bottom line

Risk level **low** provided: never bundle original assets; require user-supplied GOG/Steam/CD files with Julius-style wording; AGPL-3.0 the whole repo and publish corresponding source per release; fix third-party notice gaps in anything shipped; keep gameplay screenshots out of the README; resolve the name before marketplace distribution.
