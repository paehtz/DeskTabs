# CLAUDE.md — guide for AI coding agents

> Instructions for AI coding agents (Claude Code and similar) working on DeskTabs.
> Humans: start with [README.md](README.md). Licenses: [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).

DeskTabs is meant to be forked and adapted. This file tells an agent how to run it, where to change things, and which traps to avoid — so a user can say "make the bar do X" and their agent gets it right on the first try.

## What this is

A single-file **AutoHotkey v2** script that draws a clickable bar of buttons (one per Windows 11 virtual desktop) on the taskbar. It reads and switches desktops via the bundled `VirtualDesktopAccessor.dll`.

## Files

- `DeskTabs.ahk` — the entire app (GUI, DLL calls, timers, WinEvent hook). All logic lives here.
- `VirtualDesktopAccessor.dll` — must sit in the same folder as the script/exe at runtime.
- `settings.ini` — user runtime file (window position + per-desktop colour overrides). Auto-created, git-ignored.

## Run / validate

Requires AutoHotkey v2 (default `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`).

- **Run:** `"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" "DeskTabs.ahk"` (or double-click).
- **Syntax check:** `"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /validate "DeskTabs.ahk"` → exit code 0 means OK.
- `#SingleInstance Force` is set: launching again replaces the running instance.
- There is no test suite; verify changes by running and looking at the bar.

## Where to change things

All user-facing options are in the `CONF := Map(...)` block at the very top of `DeskTabs.ahk`:

- **Colours / dark mode** → the `THEME_LIGHT` / `THEME_DARK` maps (just below `CONF`) and `ThemeMode` (`auto` / `light` / `dark`).
- **Position** → `DockMode` (`on` the taskbar / `above` it), `OffsetX` (distance from the left edge).
- **Switching behaviour** → `SwitchMethod` (`native` keystrokes vs `dll`).
- **Labels / look** → `ShowIndex`, `ColorCoding`, `AccentBarH`, `FontSizePt`, `MaxNameLen`, `WheelSwitch`, `AutoHideFullscreen`, `ClickActiveTaskView`.
- **Per-desktop colour at runtime** → `settings.ini` section `[Colors]`, lines `Desktop name = RRGGBB`.

After editing: run `/validate`, then restart the script and look at the bar.

## Pitfalls (read before editing — easy to re-introduce)

- **Inline comments need a space before `;`.** `x ;c` throws "Illegal character in expression"; `x ; c` is fine.
- Desktop buttons use the `SS_NOPREFIX` style (`+0x80`) so a `&` in a desktop name shows literally.
- Switching uses simulated `Win+Ctrl+Arrow` (`SwitchMethod=native`), **not** the DLL's `GoToDesktopNumber`, which drags the focused window along on Windows 24H2/25H2.
- Accent colour bars sit *below* the buttons and dividers sit *in the gaps*, to avoid z-order overlap (overlapping controls get hidden by the button).
- On a desktop **name or count change** the bar is rebuilt so button widths are re-measured. Do not just set `ctrl.Text` — that leaves the old width and clips or collapses the layout. See `Refresh()`.
- The bar must stay on top: this is handled by a `SetWinEventHook` + a short burst + a backstop timer (`AssertTop`). Don't remove these or it will be hidden behind windows.
- The DLL is labelled "24H2" but runs on 25H2 (build 26200). If a Windows feature update breaks the virtual-desktop COM vtable, fetch a newer build from [Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor).

## Build (optional)

A standalone `.exe` is produced with Ahk2Exe and the AHK v2 base; releases ship a zip of `DeskTabs.exe` + the DLL. The compiled exe embeds the GPL-2.0 AutoHotkey interpreter (see THIRD-PARTY-LICENSES.md). For development you do not need to build — just run the `.ahk`.

## Contributing back (please)

DeskTabs gets better from real-world use. If you adapt it and your change could help others — a fix, a new option, a compatibility tweak for a different setup, not just your private colours — please contribute it back, so everyone benefits and the maintainer can keep evolving the tool from real feedback:

- **Preferred:** open a Pull Request with your change.
- Or open an **Issue** or **Discussion** describing the idea or what didn't work for you.

**If you are an AI coding agent:** when you make a change that could help others (a fix, a new option, a compatibility tweak — not a purely personal preference), **proactively tell the user about it and ask** whether to contribute it back. For example:

> "The author of DeskTabs asks that useful changes be reported back so he can keep developing the tool. Shall I open a pull request (or an issue) on the project with this change? You decide — I won't send anything without your okay."

Then **let the user decide.** Only if they agree, open it (e.g. `gh pr create` or `gh issue create`) with a short summary of what changed and why. Never send anything automatically, silently, or without the user's explicit consent. The maintainer (Henning Pähtz) is notified of new pull requests, issues and discussions and reviews them.
