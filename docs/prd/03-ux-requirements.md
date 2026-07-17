# PRD — UX Requirements

## 1. Installation flow

Sideloading is the launch channel (see Release Strategy), so installation UX is mostly
documentation UX — and documentation quality is a product feature:

- **UX-1.1** README + a `docs/install/` guide per channel (AltStore Classic, SideStore,
  Sideloadly, AltStore PAL where available, build-from-source), each with screenshots and a
  troubleshooting section (free-account 7-day resign, "Untrusted Developer" prompt,
  revocation).
- **UX-1.2** An AltStore/SideStore **source JSON** hosted from this repo (GitHub Pages) so
  users can add the source once and receive updates in-app.
- **UX-1.3** Every release page states, above the fold: what CaesarPad is, that Caesar III
  data is required and where to buy it, and which IPA (Julius vs Augustus flavor) to pick,
  with a one-table comparison.

## 2. First launch & import flow

State machine (replaces upstream's minimal alert→picker→copy):

1. **Welcome** — one screen: what this app is, "You need your own copy of Caesar III",
   buy links (GOG/Steam), and "I have my files" CTA. Native (UIKit/SwiftUI), localized.
2. **How to get files on this iPad** — collapsible per-source instructions: GOG offline
   installer (extract on Mac/PC → AirDrop or iCloud Drive the folder), Steam (copy install
   folder), CD (copy patched 1.0.1.0 install). Each ends at: "Put the folder anywhere in
   Files, then tap Import."
3. **Pick folder** — `UIDocumentPickerViewController` (`UTTypeFolder`).
4. **Validate before copy** — scan for required files (case-insensitive): language pack
   (`c3.eng`+`c3_mm.eng` or localized equivalents), `c3_model.txt`, graphics (`c3.sg2` +
   `c3.555`, `c3_north.sg2`…), audio/video optional. Outcomes:
   - ✅ all required → summary screen: what was found (base game, music ✓/✗, videos ✓/✗,
     speech ✓/✗, size estimate) → Import.
   - ⚠️ playable but incomplete → same screen with what's missing and what that means
     (e.g., "No videos: intro and victory movies will be skipped").
   - ❌ not playable → list exactly which files are missing + which source-specific step
     likely went wrong; button back to picker. Never copy anything in this state.
5. **Copy with progress** — determinate progress (bytes), cancel supported; on failure,
   delete partial copy, show the underlying error, return to picker.
6. **Done** → engine launches. (Augustus flavor: offer optional download of the freely
   licensed Augustus extra-assets pack here, since Augustus features need it.)

Re-entry: Settings → "Game data" shows current data language/version/size, with
Re-import, Add music/videos, and Delete data (with save-preserving confirmation).

## 3. Controls — iPad control scheme

Design principle: **the engine's existing input model is mouse-shaped; touch maps to it
predictably; native gestures never steal events the game needs.**

### Touch (primary)

| Action | Gesture | Mapping |
|---|---|---|
| Select / place building / press UI button | Tap | Left click at finger |
| Drag-build roads/walls/aqueducts; drag map in build mode | Touch-drag | Left-drag |
| Pan city view | One-finger drag on map (when no build tool active); two-finger drag always | Engine scroll (touch scroll path exists upstream) |
| Building info / cancel current tool | Long-press (≈350 ms, haptic tick) | Right click |
| Alternate right-click | Two-finger tap | Right click |
| Zoom (Augustus) | Pinch | Engine zoom, anchored at pinch centroid (exists upstream: `zoom_update_touch`) |
| Zoom (Julius) | Pinch | Display-scale stepping (nearest comfortable step) — Julius has no world zoom; document the difference |
| Fast map travel | Tap minimap | Existing engine behavior |
| Pause | Toolbar button (see overlay) + keyboard `P` | Engine pause |

Touch modes: keep upstream's three modes available in Settings for accessibility, but the
iPad default is the direct mapping above (upstream default "touchpad mode" is wrong for a
large direct-touch canvas).

### Native overlay (minimal, out of the engine's way)

A slim auto-hiding edge toolbar (native, respects safe areas) with: Pause, Speed −/+,
Overlays quick-cycle, Screenshot, Settings. Everything it does is also reachable in-game;
it exists because touch users lack hotkeys (upstream issue #613: no pause without keyboard;
issue #631: requests for a shortcut overlay). Hidden automatically when a hardware keyboard
is attached (setting to override).

### Keyboard (Magic Keyboard / external)

- All engine hotkeys pass through unmodified (SDL scancodes); in-app hotkey reference sheet
  (⌘/ or ?) rendered natively from the engine's hotkey config.
- Arrow keys/WASD pan (upstream behavior); Esc backs out of menus.

### Trackpad / mouse

- With `UIApplicationSupportsIndirectInputEvents`, SDL delivers real pointer events: full
  desktop parity — hover, right-click (two-finger click), scroll-to-pan, pinch-on-trackpad
  → zoom (Augustus). This is the "it's just the PC game" mode and a headline feature for
  Magic Keyboard owners.

### Game controller (P2)

- Map via engine joystick layer (Vita/Switch heritage; Julius gained controller auto-binding
  in 2026): left stick = cursor/pan, right stick = fast pan, A = click, B = right-click,
  triggers = speed, d-pad = menu navigation. Follow upstream mappings; don't invent.

### Apple Pencil

- Acts as precise touch (tap/drag identical to finger); long-press timing shortened for
  pencil. No pencil-exclusive features at 1.0.

### Explicit interaction rules

- Gestures are resolved in the engine's touch layer (patched), not by UIKit gesture
  recognizers, to avoid latency and event theft; the native toolbar is outside the SDL view.
- No rotation gesture (map rotation doesn't exist in Caesar III).
- Drag-to-place shows the engine's existing footprint preview; no extra confirm step (city
  builders die by extra taps). Undo remains the engine's own (Augustus has undo).

## 4. Menus & in-game UI

- Engine UI is kept pixel-authentic (that's the product's charm); CaesarPad adjusts **scale**,
  not layout: per-device default display scale chosen so the sidebar buttons hit ≥ 44 pt
  effective touch targets (engine display-scale option exists; upstream issue #631 confirms
  "too tiny" is the #1 mobile complaint).
- Native surfaces are only: importer, settings sheet, save manager, hotkey sheet, about/
  licenses. All support Dynamic Type where text is native.

## 5. Display

| Device | Points | Default approach |
|---|---|---|
| iPad Pro 13" / Air 13" | 1032×1376 pt class | Display scale ≈ 150% (validate) |
| iPad Pro 11" / Air 11" | 834×1194 pt class | ≈ 130–140% |
| iPad 10.9" | 820×1180 pt | ≈ 130% |
| iPad mini 8.3" | 744×1133 pt | ≈ 110–120%; verify ≥ 640×480 logical after scaling |

Values are **assumptions to validate in Phase 1 on hardware** — the requirement is the
44 pt touch-target floor and a ≥ 640×480 logical viewport (engine minimum), not the exact
percentages. Safe-area insets applied via native bridge (SDL2 lacks the API); home indicator
auto-hidden (`SDL_HINT_IOS_HIDE_HOME_INDICATOR=2` deferred mode).

## 6. Accessibility

- Respect Reduce Motion (disable native overlay animations), system text size in native
  surfaces, VoiceOver labels for every native control (engine canvas is exempt — out of
  scope), haptics toggle, all three touch modes selectable, left-handed toolbar position
  option.

## 7. Settings (native sheet)

Sections: Game data (see §2) · Controls (touch mode, long-press delay, toolbar position/
auto-hide) · Display (scale, orientation lock) · Audio (music/speech/effects volume — writes
engine config) · Saves (manager, iCloud toggle P2) · Help (hotkeys, install guide link,
diagnostics export) · About (version, engine version/SHA, AGPL license text, source link —
**the license text and corresponding-source link are a legal requirement, not garnish**).

## 8. Error handling

- Every failure state has: what happened (plain language), why (if known), one primary
  recovery action. No dead-end alerts (upstream's importer error alert loops back to the
  picker — keep that property everywhere).
- Missing-data-at-boot (user deleted data in Files): detected → importer flow, saves
  untouched.
- Out of storage during import: preflight free-space check against measured source size
  before copying.
- Corrupt save on load: engine reports; native layer offers "restore from autosave" if
  present.
