# Install the CaesarPad developer-preview IPA

CaesarPad's public package is an **unsigned, re-signable IPA**. It contains the
Augustus-based iPad app, not Caesar III or any Caesar III game data. It is not an
App Store or TestFlight build.

## What you need

- a supported iPad running iPadOS 14 or newer;
- a Mac or another supported sideloading setup;
- an Apple ID used by your chosen signing tool; and
- your own legally purchased Caesar III installation files.

AltStore Classic, SideStore, Sideloadly, or Xcode can re-sign an unsigned IPA.
Follow the current instructions from the tool you choose; CaesarPad does not
collect or receive your Apple credentials.

## Install

1. Download `CaesarPad-0.1.0-preview.1-unsigned.ipa` and its `.sha256` file from
   [Preview 1](https://github.com/chrissotraidis/caesarpad/releases/tag/v0.1.0-preview.1).
2. Verify the download on macOS:

   ```sh
   shasum -a 256 -c CaesarPad-0.1.0-preview.1-unsigned.ipa.sha256
   ```

3. Import the IPA into your sideloading tool and sign it with your own Apple ID.
4. Install and launch CaesarPad once so iPadOS creates its Files-visible folder.

## Add your Caesar III data

1. Put your purchased Caesar III data folder anywhere in Files. The folder name
   does not matter.
2. Confirm that the selected folder directly contains `c3.eng`, `c3_model.txt`,
   `c3.sg2`, and the rest of the game's data files.
3. In CaesarPad, acknowledge the game-data prompt, select that folder, and tap
   **Open**. CaesarPad shows an importing message while it copies the files into
   its Files-visible storage.

If you already copied the files to **Files → On My iPad → CaesarPad → C3**, select
that exact `C3` folder. CaesarPad uses it in place instead of trying to copy the
folder onto itself. You can also force-quit and reopen CaesarPad to have it detect
that folder during startup.

Do not share those files or attach them to GitHub issues.

## Updates and saves

Install updates over the existing app. Do not uninstall first: uninstalling can
remove the Files-visible Documents container and its saves. Make a backup of
the complete app Documents and settings through your device backup workflow before
changing sideloading tools. A save-only export is not a full recovery backup.

The preview uses bundle identifier `com.chrissotraidis.caesarpad`. Packages with
a different identifier are separate apps and do not share Documents data.

Preserve the same bundle ID, signing team and entitlements for in-place updates.
If signing identity is incompatible, stop and resolve it; do not uninstall to bypass it.
