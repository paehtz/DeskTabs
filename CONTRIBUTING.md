# Contributing to DeskTabs

Thanks for your interest in improving DeskTabs. Feedback, bug reports and pull requests are all welcome.

## Reporting bugs and ideas

- **Bugs:** open an [issue](https://github.com/paehtz/DeskTabs/issues/new/choose) using the bug report template. Please include your Windows version, how you run DeskTabs (compiled `.exe` or `.ahk`), and a screenshot if it is a visual problem.
- **Ideas and questions:** use [Discussions](https://github.com/paehtz/DeskTabs/discussions) or the feature request template.

## Making changes

DeskTabs is a single AutoHotkey v2 script, so changes are straightforward:

1. Fork the repository and clone your fork.
2. Install [AutoHotkey v2](https://www.autohotkey.com/).
3. Edit `DeskTabs.ahk`. Keep `VirtualDesktopAccessor.dll` next to the script so it runs.
4. Test by running the script (double-click or via `AutoHotkey64.exe`). You can validate syntax with:
   ```
   "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /validate DeskTabs.ahk
   ```
5. Commit, push to your fork, and open a pull request describing what you changed and why.

## Notes for contributors

- All user-facing options live in the `CONF` block at the top of `DeskTabs.ahk`.
- Please read the "Lessons learned / pitfalls" section in the [README](README.md) first. A few non-obvious traps are documented there (the AHK semicolon trap, `SS_NOPREFIX` for `&`, the native switch method, z-order of the colour bars).
- Inline comments use a leading space before `;` on purpose (see the semicolon trap).
- Keep changes focused and the script readable; match the surrounding style.

By contributing, you agree that your contributions are licensed under the project's [MIT License](LICENSE).
