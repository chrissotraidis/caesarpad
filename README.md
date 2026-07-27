<p align="center">
  <img src="assets/ios/AppIcon.png" width="180" alt="CaesarPad app icon: a Roman arch opening onto a city">
</p>

<h1 align="center">CaesarPad</h1>

<p align="center">
  <strong>Caesar III on an iPad-shaped canvas, powered by Augustus.</strong><br>
  Developer preview · Augustus only · iPad Simulator verified
</p>

CaesarPad is a small, source-first iPadOS port layer for the open-source
[Augustus](https://github.com/Keriew/augustus) engine. It adds landscape presentation,
direct touch mappings, one native pause control, lifecycle recovery, and repeatable
Simulator automation—without distributing any Caesar III game data.

> [!IMPORTANT]
> CaesarPad is currently a **Simulator-tested developer preview**. There is no signed IPA,
> TestFlight build, App Store release, AltStore source, or production Files importer yet.
> Running on a physical iPad remains future work.

[What works](#what-works-today) · [Controls](#touch-controls) ·
[Run it](#run-in-ipad-simulator) · [How it works](#how-it-works) ·
[Project status](STATE.md)

## What works today

- Augustus builds and runs in landscape on an iPad Simulator.
- A mission can be started, panned, zoomed, paused, and played without a keyboard.
- Local, legally purchased Caesar III data can be injected into the Simulator container.
- Backgrounding creates a recovery save; a cold launch resumes and consumes it.
- One automated suite verifies build, boot, data load, gameplay, touch, and lifecycle.
- The complete clean-build path has passed twice consecutively.

Simulator automation proves event routing and visible game behavior. Touch comfort,
multitouch feel, audio routes, performance, thermals, Pencil, and trackpad behavior still
need a physical iPad.

## Touch controls

| Gesture | Action |
|---|---|
| Tap | Select, place, or press an engine UI control |
| One-finger drag | Pan the city map |
| Long press | Right-click: cancel the active tool or open information |
| Pinch | Zoom through Augustus's native touch zoom |
| Two-finger tap | Alternate right-click |
| **Pause** button | Pause or resume without a keyboard |

The defaults use direct, predictable mappings; there is no mode switch or native toolbar
to learn.

## Run in iPad Simulator

You need macOS, Xcode, and your own legally purchased Caesar III files. Then:

```sh
git clone --recurse-submodules https://github.com/chrissotraidis/caesarpad.git
cd caesarpad
C3_SOURCE_DIR="/absolute/path/to/C3" scripts/install.sh
```

`scripts/install.sh` checks the required tools and game-data markers, selects a booted
iPad Simulator (or the first available iPad), builds CaesarPad, installs it, injects the
local data, and launches the app. Set `SIMULATOR_UDID` only when you want a specific
Simulator. On the first launch, confirm Augustus's two local-directory prompts; the game
data is already available under the app's `Documents/C3`.

<details>
<summary><strong>Prerequisites and expected game-data layout</strong></summary>

<br>

- macOS with full Xcode; Xcode 26.6 is the currently verified version
- Xcode opened once, with its license accepted
- an iPad Simulator runtime installed from Xcode Settings → Components
- CMake 3.25 or newer, Git, `curl`, and network access for the first build
- a legally purchased Caesar III data directory containing at least:

```text
C3/
├── c3.eng
├── c3_model.txt
├── c3.sg2
├── c3.555
└── ...
```

The automation currently validates the English `c3.eng` layout. CaesarPad never copies
game data into Git and `ref/` is ignored by the repository.

</details>

<details>
<summary><strong>Troubleshooting a first build</strong></summary>

<br>

- **No iPad Simulator found:** install an iOS Simulator runtime in Xcode Settings →
  Components, then retry.
- **Xcode asks for setup:** launch Xcode once, accept its license, and let it install
  additional components.
- **Game data not found:** point `C3_SOURCE_DIR` at the directory that directly contains
  `c3.eng` and `c3_model.txt`.
- **SDL download fails:** check network access and retry. Downloads are version- and
  checksum-pinned; a mismatched archive is rejected.
- **Patch application fails:** restore the Augustus submodule to its pinned SHA with
  `git submodule update --init --recursive --force engines/augustus`, then rerun.
- **Choose another iPad:** run
  `SIMULATOR_UDID="<udid>" C3_SOURCE_DIR="/path/to/C3" scripts/install.sh`.

</details>

<details>
<summary><strong>I want to install CaesarPad on a physical iPad</strong></summary>

<br>

A downloadable iPad build is not available yet. Device signing, an unsigned IPA lane,
sideloading documentation, and physical-device validation must be completed before this
can be presented as a clean end-user install. The current repository produces an arm64
iPad Simulator app only.

</details>

## How it works

CaesarPad keeps Augustus as a pinned Git submodule at
`69c69827682a11eaaa400c5a77198131249bfe2a`. The engine is never vendor-copied. Five small
patches provide only the downstream behavior needed here:

1. landscape-only iOS presentation;
2. long-press and two-finger right-click mappings;
3. one native pause/resume affordance and automation state;
4. background autosave and cold-launch recovery;
5. the CaesarPad display name.

The original 1024×1024 CaesarPad icon lives downstream in `assets/ios/` and is validated
as opaque before each build. SDL2 and SDL2_mixer are downloaded from their official source
releases and verified by SHA-256.

<details>
<summary><strong>What the automated suite proves</strong></summary>

<br>

```sh
scripts/test.sh
```

The suite builds and installs the app, injects local game data, starts a mission, places a
building, pans and zooms the city, exercises every core touch mapping, verifies pause and
resume, backgrounds the app, checks the recovery save, and proves cold-start restoration.

Evidence and exact pinned inputs are recorded in [STATE.md](STATE.md). The complete
implementation and hardware-only boundary are summarized in
[FINAL_REPORT.md](FINAL_REPORT.md).

</details>

## Not shipped yet

- a validated Files-based first-run importer;
- localized game-data validation and friendly recovery UI;
- device signing, IPA packaging, and a supported sideload channel;
- physical-iPad touch, audio, lifecycle-stress, performance, and thermal sign-off;
- release automation and distribution.

These are intentionally described as future work rather than implied by the source
preview.

<details>
<summary><strong>Design, engineering, and research documents</strong></summary>

<br>

- [Feasibility report](docs/feasibility-report.md)
- [Product overview](docs/prd/00-product-overview.md)
- [Functional requirements](docs/prd/01-functional-requirements.md)
- [Technical requirements](docs/prd/02-technical-requirements.md)
- [UX requirements](docs/prd/03-ux-requirements.md)
- [Engineering roadmap](docs/prd/04-roadmap.md)
- [Autonomous task breakdown](docs/prd/05-task-breakdown.md)
- [Testing plan](docs/prd/06-testing-plan.md)
- [Risk register](docs/prd/07-risk-register.md)
- [Release strategy](docs/prd/08-release-strategy.md)
- [Augustus research annex](docs/research/annex-augustus.md)
- [SDL on iOS and port precedents](docs/research/annex-ios-sdl.md)
- [Licensing and legal research](docs/research/annex-licensing.md)

</details>

## Legal

CaesarPad contains no Caesar III game data. You must supply your own legally purchased
copy from a source such as [GOG](https://www.gog.com/en/game/caesar_3) or
[Steam](https://store.steampowered.com/app/517790/Caesar_3/).

CaesarPad is not affiliated with or endorsed by the Augustus contributors or the rights
holders of Caesar III. “CaesarPad” is a working descriptive name and must be reviewed
before distribution.

Engine and project code are available under the
[GNU Affero General Public License v3.0](LICENSE). Augustus retains its own copyright and
license notices.
