# Third-party licenses

DeskTabs itself is licensed under the [GNU GPL v3 or later](LICENSE) with the additional terms in [NOTICE](NOTICE) © Henning Pähtz (versions up to 1.1.8: MIT).
It builds on the following third-party components.

---

## VirtualDesktopAccessor.dll

- **Project:** [Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor)
- **License:** MIT
- **Bundled:** yes (the `.dll` ships in this repository and in the release archive)
- **Modified:** built from the upstream source at commit `7ff9ef827bab9a081421ebb204339dd96475ec1a` with one function added to `dll/src/lib.rs`: the export `MoveDesktop`, which calls the library's existing `move_desktop`. The added code is in [`vda/move_desktop.rs`](vda/move_desktop.rs), the build in [`.github/workflows/build-dll.yml`](.github/workflows/build-dll.yml). Everything else is unchanged.

```
MIT License

Copyright (c) 2015-2023 Jari Otto Oskari Pennanen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## AutoHotkey (interpreter)

- **Project:** [AutoHotkey/AutoHotkey](https://github.com/AutoHotkey/AutoHotkey)
- **License:** GNU General Public License v2.0 or (at your option) any later version (GPL-2.0-or-later, as stated in its source files), full text in [LICENSE-AutoHotkey.txt](LICENSE-AutoHotkey.txt)

**Running from source (`DeskTabs.ahk`):** AutoHotkey is not bundled. You install AutoHotkey v2 yourself and it runs the script. The script itself is under GPL v3 (see [NOTICE](NOTICE)).

**Compiled executable (`DeskTabs.exe` in the releases):** the executable is produced with Ahk2Exe and **embeds the AutoHotkey interpreter**, which is licensed under GPL-2.0 or later. The compiled `.exe` is therefore distributed as a combined work under the terms of the **GPL v3**, which the interpreter's “or later” clause allows. To comply:

- The GPL v3 text is included as `LICENSE`, the additional terms as `NOTICE`, the interpreter's GPL-2.0 text as `LICENSE-AutoHotkey.txt` (all shipped inside the release archive).
- The corresponding source is available: the DeskTabs script in this repository, and the AutoHotkey interpreter source at <https://github.com/AutoHotkey/AutoHotkey>.

The bundled MIT component (VirtualDesktopAccessor) is compatible with GPL v3; the resulting binary as a whole follows GPL v3.

---

## Segoe Fluent Icons (icon library)

- **Source:** the `Segoe Fluent Icons` font that ships with Windows 11
- **Bundled:** no. DeskTabs only *uses* the font that is already installed on the system; no font file is distributed with DeskTabs. On systems without it, DeskTabs falls back to `Segoe MDL2 Assets`.

## Icon names (`data/glyph-names.txt`)

- **Source:** [MicrosoftDocs/windows-dev-docs](https://github.com/MicrosoftDocs/windows-dev-docs), file `hub/apps/design/iconography/segoe-fluent-icons-font.md`
- **License:** [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/) © Microsoft Corporation
- **Bundled:** yes. `data/glyph-names.txt` lists the glyph codes and their official names, filtered to the glyphs present in the font, plus German search keywords added by this project. It is used only to make the icon library searchable.
