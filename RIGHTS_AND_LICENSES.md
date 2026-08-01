# Rights and licensing boundary

CaesarPad is an unofficial, community-maintained iPadOS integration for the
[Augustus](https://github.com/Keriew/augustus) source port. It is not affiliated
with or endorsed by the Augustus contributors, Impressions Games, Sierra,
Activision, Microsoft, Apple, GOG, or Valve.

## CaesarPad source

CaesarPad's integration source, build scripts, maintained patches, and project
documentation are distributed under the GNU Affero General Public License v3.0,
as provided in [LICENSE](LICENSE). Augustus remains under its upstream copyright
and AGPL-3.0 terms. Each release identifies the exact Augustus submodule revision
and includes the CaesarPad patch series needed to reproduce the iOS build.

Third-party components and engine assets retain their own licenses. See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and the license files in the
pinned upstream source.

## Caesar III game data

CaesarPad does not contain, download, license, or grant rights to Caesar III.
Users must provide files from their own legally purchased copy. Game data,
saves, generated build products, signing material, and local reference files
are excluded from Git and rejected by the IPA packaging audit.

## Screenshots and trademarks

Repository screenshots contain Caesar III game imagery and are included only to
document CaesarPad's current behavior. That imagery, the Caesar III name, and
related marks remain the property of their respective rights holders and are not
relicensed by CaesarPad's AGPL license. The CaesarPad app icon is downstream
project artwork; Augustus's bundled interface assets retain their upstream
Creative Commons Attribution-ShareAlike terms.

## Binary distribution

The supported public-binary format is an unsigned, re-signable IPA. Public
packages contain no maintainer certificate or provisioning profile and include
license notices plus a link to the exact corresponding source revision. Users
must re-sign the IPA with their own Apple credentials before installing it.

No App Store or TestFlight release is announced. Those channels have separate
signing, policy, and license-compliance requirements and are outside the current
developer preview.
