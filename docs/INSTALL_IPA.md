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
   the matching GitHub Release when it is published.
2. Verify the download on macOS:

   ```sh
   shasum -a 256 -c CaesarPad-0.1.0-preview.1-unsigned.ipa.sha256
   ```

3. Import the IPA into your sideloading tool and sign it with your own Apple ID.
4. Install and launch CaesarPad once so iPadOS creates its Files-visible folder.

## Add your Caesar III data

1. Open **Files → On My iPad → CaesarPad**.
2. Create a folder named `C3` if one is not already present.
3. Copy the contents of your purchased Caesar III data directory into `C3`.
4. Confirm that `C3` directly contains `c3.eng`, `c3_model.txt`, `c3.sg2`, and
   the rest of the game's data files.
5. Return to CaesarPad. When Augustus asks for the game-data location, select or
   confirm the `C3` folder.

Do not share those files or attach them to GitHub issues.

## Updates and saves

Install updates over the existing app. Do not uninstall first: uninstalling can
remove the Files-visible Documents container and its saves. Make a backup of
important `.sav` and `.svx` files through Files before changing sideloading tools
or bundle identifiers.

The preview uses bundle identifier `com.chrissotraidis.caesarpad`. Packages with
a different identifier are separate apps and do not share Documents data.
