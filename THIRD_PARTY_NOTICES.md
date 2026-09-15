# Third-party notices

CaesarPad builds on the following projects. This summary is not a replacement
for their complete license texts, which remain authoritative and are copied into
the public IPA under `CaesarPad.app/Legal/`.

| Component | License / notice | Source |
|---|---|---|
| Augustus and Julius-derived engine code | GNU AGPL v3.0 | Pinned under `engines/augustus`; upstream `LICENSE.txt` |
| Augustus interface assets | CC BY-SA 3.0 | `engines/augustus/res/assets/LICENSE` |
| SDL2 | zlib | Maintained SDL 2.32.10 fork; `LICENSE.txt` |
| SDL2_mixer and bundled codecs | zlib and component-specific permissive notices | Checksum-pinned source release; license files retained in source |
| dav1d (retained nested source; AV1 disabled in the shipping iOS configuration) | BSD 2-Clause and retained component notices | `engines/augustus/ext/easyav1/ext/dav1d/COPYING` |
| pl_mpeg | MIT notice in source header | `engines/augustus/ext/pl_mpeg/pl_mpeg.h` |
| easyav1 | BSD 3-Clause | `engines/augustus/ext/easyav1/LICENSE` |
| libspng | BSD 2-Clause | `engines/augustus/ext/spng/LICENSE` |
| sxml | Unlicense | `engines/augustus/ext/sxml/UNLICENSE` |
| kuba--/zip vendored by Augustus | Unlicense in the pinned Augustus tree | `engines/augustus/ext/zip/UNLICENSE` |
| miniz | permissive license | `engines/augustus/ext/miniz/LICENSE` |

Each project, contributor name, copyright, and trademark belongs to its
respective owner. Inclusion does not imply endorsement of CaesarPad.

Packaging retains component license, COPYING, COPYRIGHT, AUTHORS and NOTICE files
under `Legal/components/`. SDL_mixer uses built-in dr_flac, minimp3 and stb_vorbis
in this iOS configuration; their notices are embedded in their source headers and
are retained in complete source archives. These component terms are not replaced
by the app AGPL. No game files or signing material are part of source delivery.
