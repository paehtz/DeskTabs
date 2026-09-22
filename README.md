# DeskTabs

🇬🇧 **English** · [🇩🇪 Deutsch](README.de.md)

**A clickable desktop bar for the virtual desktops of Windows 11.** It sits in the lower left of the taskbar, one button per virtual desktop, labelled with the desktop's Windows name. Click to switch there; the active desktop is highlighted.

Built by [Henning Pähtz](https://paehtz.de) as a lean tool for per-project time tracking: one desktop = one client, always a single click away.

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![AutoHotkey v2](https://img.shields.io/badge/AutoHotkey-v2-334455.svg)
![Windows 11](https://img.shields.io/badge/Windows-11-0078D4.svg)

![DeskTabs, light theme](docs/screenshot-light.png)

![DeskTabs, dark theme](docs/screenshot-dark.png)

---

## ⬇ Download

**[DeskTabs for Windows 11 (ZIP, 0.9 MB)](https://github.com/paehtz/DeskTabs/releases/latest/download/DeskTabs-latest.zip)** — unpack it anywhere and run `DeskTabs.exe`. No installer, no admin rights, nothing written to the registry.

Prefer one line in PowerShell? This downloads the latest version, puts it in `%LOCALAPPDATA%\DeskTabs`, starts it and sets up autostart:

```powershell
irm https://raw.githubusercontent.com/paehtz/DeskTabs/main/setup.ps1 | iex
```

All versions and their release notes are on the [Releases page](https://github.com/paehtz/DeskTabs/releases). Windows SmartScreen may warn on first start because the file is not signed: **More info → Run anyway**.

---

## Background

I organise my projects and my time tracking around virtual desktops: one desktop per project, with exactly the windows and the layout I need for it. Switching desktops serves two purposes at once. First, it swaps the entire working context: every window of the project is instantly there. Second, [ManicTime](https://www.manictime.com), which I use to track my working hours, records the active desktop. In the daily view I can later see precisely when and how long I worked on which project.

For this to stay clean, I need to see at any moment which desktop I am on. In the past I often ran a task on the wrong desktop by accident, which skews the later evaluation and means rework. DeskTabs solves that: a permanently visible bar shows the active desktop, and a direct click switches to it instead of cycling through the Windows shortcut. So I always land in the right context, and the time is attributed to the right project.

---

## Features

- **Live names from Windows:** the button labels come straight from the desktops you named in Windows (Task View). Nothing is maintained twice.
- **Dynamic:** add or remove a desktop in Windows → the bar adapts automatically within ~1.2 s (or via Tray → "Rebuild bar").
- **Direct jump:** a click jumps straight to the target desktop in one step (~100 ms), no stepping through the desktops in between. Measured on 25H2 (26200) the focused window stays where it is; if a build does drag it along, DeskTabs moves it right back. Step-by-step switching (`Win+Ctrl+Arrow` emulation) is still available via the menu entry “Jump directly”.
- **Visible on all desktops:** the window is pinned to every desktop.
- **Light/Dark automatic:** follows the Windows theme (taskbar brightness), switchable or fixed.
- **Index prefix:** "3 · ProjectName" (can be disabled).
- **Colour coding:** a thin colour bar per desktop (tab-indicator style, can be disabled, overridable per desktop). *Take the colour from the icon* reads the dominant colour out of a fetched site icon and uses it for that desktop.
- **Icon library:** a built-in picker over the whole `Segoe Fluent Icons` font that Windows 11 ships with (1500+ icons), searchable in English and German, with quick filters and a scrollable grid. Library icons are drawn in the desktop's own colour and stored as `[Icons] Desktop = glyph:E713`.
- **Tab icons:** give a desktop an icon from a website (DeskTabs fetches the site icon in the best resolution it can find and caches it) or from your own image file. Right-click a tab → *Icon*, or set `[Icons] Desktop name = URL or path` in `settings.ini`. The bare domain is enough, no `https://www.` needed.
- **Fluent look:** rounded tabs, the active desktop tinted in its own colour (hue kept, lightness from the theme), subtle vertical gradients, hover lightens the tab like the Windows taskbar buttons. The active style is switchable: own desktop colour, uniform accent colour, or a solid fill.
- **Click on the active desktop:** opens Task View (Win+Tab).
- **Fullscreen auto-hide:** hides itself while a fullscreen app is on top on the bar's monitor (a fullscreen video on another monitor does not hide it; a fullscreen app stays respected even when you focus another monitor).
- **Compact levels:** `full` / `short` / `icon`, automatic by available width or manual via **Ctrl + mouse wheel** over the bar. Fits narrow laptop taskbars.
- **Built-in time log:** writes how long you stayed on which desktop to a monthly CSV (`desktop-log_YYYY-MM.csv`), pauses on lock screen and after 5 min without input. For anyone without a time tracker, and for coding agents that do your billing. See [Time log](#time-log).
- **Right-click menu:** right-click a tab for its abbreviation and colour, plus all app settings (numbers, colour coding, view level, theme, docking, snapping, time log, language). No file editing needed; everything is saved to `settings.ini`. The tray icon offers the same menu directly.
- **Help menu:** documentation, changelog, bug report and feature request (opens a pre-filled GitHub issue), e-mail to the author, update check and *About DeskTabs* (version, licence, links).
- **Update check:** once a day DeskTabs asks the GitHub releases API for the latest version number (nothing else is sent) and shows a tray notification if a newer release exists. Disable via the Help menu or `UpdateCheck = 0`.
- **Live config:** edits to `settings.ini` (abbreviations, colours, level) are picked up within ~1.2 s, no restart. Handy when your AI agent configures the bar for you.
- **Keyboard shortcuts (off by default):** jump straight to desktop 1 to 10 with a number key, from the number row or the numpad (the numpad works with NumLock on or off). Pick the modifier in the menu: Ctrl+Win, Ctrl+Alt, Win+Alt or Ctrl+Shift.
- **Mouse wheel** over the bar pages through the desktops.
- **Separators** between the tabs (off by default, switchable).
- **Movable** by the handle `≡` on the left; the position is remembered in `settings.ini`.

---

## Requirements

- **Windows 11:** developed and tested on **25H2 (build 26200)**. Works from 24H2 (26100).
- **AutoHotkey v2** (tested with 2.0.26), default path `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`.
- **VirtualDesktopAccessor.dll** (bundled in this repo), from [Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor), release `2024-12-16-windows11`.

---

## Installation & start

### Option A: ready to run (no AutoHotkey needed)

1. Download the latest `DeskTabs-vX.Y.Z.zip` from the [Releases page](https://github.com/paehtz/DeskTabs/releases/latest).
2. Extract it anywhere and keep the folder together: `DeskTabs.exe`, `VirtualDesktopAccessor.dll`, `lang\` and `data\`.
3. Double-click `DeskTabs.exe`. On the first start DeskTabs says hello and points at the right-click menu.

**Windows SmartScreen** may show "Windows protected your PC" because the executable is not code-signed (a certificate costs money per year; this is a free tool). Click **More info → Run anyway**. If you prefer not to trust an unsigned binary, run the script instead (Option B) or build the executable yourself with Ahk2Exe.

Or install (and update) in one line, from PowerShell:

```powershell
irm https://raw.githubusercontent.com/paehtz/DeskTabs/main/setup.ps1 | iex
```

That installs to `%LOCALAPPDATA%\DeskTabs`, adds an autostart entry and starts DeskTabs. Run it again any time to update: your `settings.ini`, the icon cache and the time logs are kept. Options: `-NoAutostart`, `-NoLaunch`, `-Uninstall`.

### Uninstall

```powershell
.\setup.ps1 -Uninstall
```

It stops DeskTabs, removes the autostart shortcut and the program folder, and asks whether to keep your settings, icons and time logs (they are moved to a folder in `%TEMP%` if you say yes). DeskTabs writes nothing to the registry and installs nothing outside its own folder, so removing that folder is enough if you installed manually.

This installs DeskTabs to `%LOCALAPPDATA%\DeskTabs`, adds an autostart entry and launches it. Run it again any time to update.

> Note: an AutoHotkey-compiled `.exe` can trigger false positives in some antivirus scanners. That is why both the `.exe` and the full source are provided; you can always run from source instead.

### Option B: from source

1. Clone the repo or download it as a ZIP and extract it to a folder of your choice.
2. Install [AutoHotkey v2](https://www.autohotkey.com/) (if not already present).
3. Double-click `DeskTabs.ahk` (opens with AHK v2), or run it from the command line:

```
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" "<path-to-folder>\DeskTabs.ahk"
```

**Autostart:** place a shortcut in the startup folder
(`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\`)
→ target: `AutoHotkey64.exe`, with the path to `DeskTabs.ahk` as the argument.

**Quit / control:** tray icon (DeskTabs symbol) → right-click: the full settings menu, Help (docs, feedback, updates, About), Rebuild bar, Reset position, Exit.

---

## Configuration

> **Using an AI coding agent (e.g. Claude Code)?** Fork the repo and see [CLAUDE.md](CLAUDE.md): it tells your agent how to run, validate and safely customize DeskTabs for your own setup.

All options live in the `CONF` block at the very top of `DeskTabs.ahk`:

| Option | Default | Meaning |
|---|---|---|
| `DockMode` | `on` | `on` = on the taskbar (visually integrated, may flicker slightly when switching windows). `above` = just above the taskbar (flicker-free, but overlaps the bottom edge of windows). |
| `ThemeMode` | `auto` | `auto` = follow the Windows theme (taskbar brightness via registry `SystemUsesLightTheme`). `light` / `dark` = fixed. A change at runtime is detected automatically (~1.2 s) and the bar is rebuilt. |
| `OffsetX` | 10 | Distance from the left screen edge (px). |
| `ShowIndex` | 1 | Number prefix ("3 · …"). |
| `ColorCoding` | 1 | Colour bar per desktop. |
| `AccentBarH` | 3 | Height of the colour bar (px). |
| `AutoHideFullscreen` | 1 | Hide when a fullscreen app is in front. |
| `ClickActiveTaskView` | 1 | Clicking the active desktop opens Win+Tab. |
| `WheelSwitch` | 1 | Mouse wheel pages through desktops. |
| `Palette` | 8 colours | Colour palette for the colour coding (by index). |
| `FontSizePt` | 10 | Font size. |
| `MaxNameLen` | 22 | Names longer than this are truncated (level `full`). |
| `CompactMode` | `auto` | Label level: `full` (number + name), `short` (number + shortened name), `icon` (number only). `auto` starts at `full` and steps down until the bar fits into `MaxBarWidthPct` of the taskbar width, so it also works on narrow laptop taskbars. **Ctrl + mouse wheel** over the bar switches levels manually (wheel up past `full` returns to `auto`); the choice is remembered in `settings.ini` `[View]`. |
| `MaxBarWidthPct` | 40 | `auto` only: maximum share of the taskbar width before the bar steps down one level. |
| `ShortNameLen` | 8 | Level `short`: names longer than this are truncated. |
| `TimeLog` | 1 | Write per-desktop stay times to `desktop-log_YYYY-MM.csv` next to the script. `0` = off. |
| `TimeLogIdleMin` | 5 | Minutes without keyboard/mouse input after which the current stay is closed (counted as a break). Lock screen always closes it. |
| `UpdateCheck` | 1 | 1 = check the GitHub releases API once a day for a newer version (only the version number is read). Also switchable in the Help menu; stored in `[View] UpdateCheck`. |
| `ActiveStyle` | `desktop` | How the active tab is filled: `desktop` = its own desktop colour, `accent` = the uniform accent colour, `solid` = a strong fill. |
| `TintL` / `TintS` | 88 / 100 (light), 30 / 70 (dark) | Lightness and saturation (%) of the tinted active tab. Higher `TintL` = more delicate, lower = stronger. |
| `GradientPct` | 14 | Strength of the vertical gradient inside filled tabs, `0` = flat. |
| `HoverPct` | 58 (light), 12 (dark) | How far a hovered tab is lightened. |
| `CornerRadius` | 4 | Corner radius of the tabs (like Windows 11 taskbar buttons). |
| `ShowIcons` | 1 | Show the icons from `[Icons]` in the tabs. |
| `IconSize` / `IconGap` | 16 / 7 | Icon size and the gap between icon and text. |
| `ShowDividers` | 0 | Thin separators between the tabs. |
| `Hotkeys` | 0 | 1 = register the number-key shortcuts for jumping to a desktop. |
| `HotkeyMod` | `^#` | Modifier for those shortcuts, in AutoHotkey notation: `^#` Ctrl+Win, `^!` Ctrl+Alt, `#!` Win+Alt, `^+` Ctrl+Shift. |
| `SwitchMethod` | `dll` | `dll` = jump straight to the desktop, `native` = emulate `Win+Ctrl+Arrow` step by step. |
| `Language` | `auto` | UI language: `auto` follows the Windows display language (German → `de`, everything else → `en`), or `de` / `en` fixed. Any other code loads `lang\<code>.ini`. Can also be set in `settings.ini` `[View] Language=`. Takes effect on restart. |
| Colours | auto | `ColBarBg`, `ColInactiveBg/Tx`, `ColActiveBg/Tx`, `ColHoverBg/Tx`, `ColDivider` are copied at startup from `THEME_LIGHT` / `THEME_DARK` (depending on `ThemeMode`) into `CONF`. To customise, edit the two `THEME_*` maps near the top of the script. |

### settings.ini (created automatically)

```ini
[Position]
X=10
Y=1392

[Colors]
; Override the colour coding per desktop name (RRGGBB):
Design=E5471D
Buchhaltung=1565C0

[Short]
; Abbreviation per desktop name, used by the compact levels
; (short: "4 · BPH", icon: "BPH" instead of just the number):
Acme Bakery=ACME
Buchhaltung=BH

[View]
; Written by the right-click menu (and Ctrl + mouse wheel); each key
; overrides the CONF default: CompactMode, ThemeMode, DockMode, Language,
; ShowIndex, ColorCoding, SnapToTaskbar, TimeLog
CompactMode=short
ShowIndex=1
```

---

## Languages

DeskTabs speaks German and English out of the box and picks the language from your Windows display language. To add a language, copy `lang\en.ini` to `lang\<code>.ini` (e.g. `lang\fr.ini`), translate the lines (`key=Text`, keep the `{1}` placeholders, `\n` is a line break, file is UTF-8) and set `Language=fr` in `settings.ini` under `[View]`. Pull requests with new languages are welcome.

---

## Time log

With `TimeLog=1` (default) DeskTabs writes one line per stay on a desktop into `desktop-log_YYYY-MM.csv` next to the script:

```csv
start,end,seconds,desktop_index,desktop_name
2026-09-22T09:02:11,2026-09-22T10:47:30,6319,4,"Acme Bakery"
2026-09-22T10:47:30,2026-09-22T11:15:02,1652,2,"Miller & Sons"
```

- A stay ends when you switch desktops, lock the screen, or stop giving input for `TimeLogIdleMin` minutes (the stay is then closed at the moment the inactivity began, so breaks are not counted).
- Times are local, ISO 8601. `desktop_index` is 1-based like the bar's numbers; `desktop_name` is the name at the start of the stay.
- The file is plain UTF-8 CSV: open it in Excel, or let a coding agent sum it up per client for your invoice. It is personal data and git-ignored.

---

## How it works (architecture)

- **Reading the desktops** via `VirtualDesktopAccessor.dll` (in-process, fast): `GetDesktopCount`, `GetCurrentDesktopNumber`, `GetDesktopName`, `PinWindow`, `RegisterPostMessageHook`.
- **Switching** via the DLL in one step (`SwitchMethod=dll`), with a safety net that moves the foreground window back if a Windows build drags it along; `native` emulates the keyboard shortcuts instead.
- **Live highlight update** through `RegisterPostMessageHook` (desktop-change notification) plus a 1.2 s fallback timer (`Refresh`), which also refreshes the desktop count and names and rebuilds the bar when needed.
- **Always on top** (`DockMode=on`): a combination of
  - `SetWinEventHook(EVENT_SYSTEM_FOREGROUND)` → an immediate `AssertTop()` on every window switch,
  - a short **burst** (10× every 25 ms) to cover maximise animations,
  - a 250 ms backstop timer.
- **The window** is `-Caption +AlwaysOnTop +ToolWindow +E0x08000000` (WS_EX_NOACTIVATE → clicks do not steal focus from the working window) and pinned to all desktops.
- **Theme** is detected via the registry (`SystemUsesLightTheme` under `…\Themes\Personalize`, the same value that controls taskbar brightness). `ApplyTheme()` copies the matching set (`THEME_LIGHT`/`THEME_DARK`) into the `CONF` colour keys; the `Refresh` timer detects a theme change and rebuilds the bar.

---

## Lessons learned / pitfalls (for future maintenance)

- **25H2 compatibility:** the Ciantic DLL is labelled "24H2" but runs fine on 25H2 (26200). A Windows feature update that changes the virtual-desktop COM vtable could break the DLL → then grab a fresh build from Ciantic's repo.
- **`GoToDesktopNumber` and the foreground window:** on 24H2 the DLL internally uses `switch_desktop_and_move_foreground_view`, which used to drag the focused window to the target desktop. Measured again on 25H2 (26200) with a foreground window from another process, it no longer does, so the direct jump is the default; DeskTabs still checks after every jump and moves the window back if needed. `SwitchMethod=native` restores the old shortcut emulation.
- **`&` in a desktop name:** AHK text controls interpret `&` as an accelerator marker. Fix: the `SS_NOPREFIX` style (`+0x80`) on the buttons, which shows `&` literally (e.g. "M&S").
- **z-order of colour bars / separators:** overlapping controls get hidden by the button. So separators sit in the gaps and colour bars sit **below** the button (no overlap).
- **AHK semicolon trap:** a `;` without a preceding space is NOT a comment but throws "Illegal character in expression". Always put a space before inline `;`.
- **DockMode trade-off:** `on` (on the taskbar) looks more integrated but fights the taskbar over z-order (a brief flicker on window switch despite the WinEvent hook + burst). `above` (just above it) is flicker-free but overlaps the bottom edge of windows.
- **Multi-monitor:** the bar always sits on the **primary taskbar** (`Shell_TrayWnd`) and follows automatically when the primary monitor changes in Windows. Secondary taskbars (`Shell_SecondaryTrayWnd`) are not served.
- **DLL feature scope:** `VirtualDesktopAccessor.dll` offers NO function to reorder desktops (exports checked, incl. `GetDesktopCount`, `GetCurrentDesktopNumber`, `GetDesktopName`, `GoToDesktopNumber`, `MoveWindowToDesktopNumber`, `PinWindow`, `RegisterPostMessageHook`, but no `MoveDesktop`). Reordering would require [MScholtes/VirtualDesktop](https://github.com/MScholtes/VirtualDesktop).

---

## Ideas for the future

- **Finally solve the residual flicker in `DockMode=on`:** stay permanently on the taskbar without the twitch on window switch. Approaches: additional WinEvents (`EVENT_OBJECT_REORDER`, `EVENT_SYSTEM_MINIMIZEEND`), a denser burst, or making the bar a child of the taskbar (`SetParent`). Current default workaround: `DockMode=above` (flicker-free).
- **Drag-to-reorder** the buttons with real Windows reordering via [MScholtes/VirtualDesktop](https://github.com/MScholtes/VirtualDesktop).

---

## About this project

DeskTabs was built AI-assisted with [Claude Code](https://claude.com/claude-code). My background is in strategy, design and concept work, not classic software development: my programming experience came mainly from template languages, HTML and CSS. With AI-assisted work I now turn my own ideas directly into working tools. DeskTabs is one of them, and at the same time a hands-on example of exactly what I pass on to companies as AI consulting.

## License

DeskTabs is licensed under the [MIT License](LICENSE) © Henning Pähtz.

**Disclaimer:** DeskTabs is provided "as is", without warranty of any kind and without any liability, as stated in the MIT License. Use at your own risk.

### Third-party components

- **VirtualDesktopAccessor.dll** ([Ciantic](https://github.com/Ciantic/VirtualDesktopAccessor)) is bundled under the **MIT License**.
- The compiled **`DeskTabs.exe`** (in the releases) embeds the **AutoHotkey** interpreter, which is licensed under **GPL-2.0**. The compiled executable is therefore distributed under GPL-2.0; the script source is in this repository and AutoHotkey's source is at its [project page](https://github.com/AutoHotkey/AutoHotkey). Running from source (`DeskTabs.ahk`) does not bundle AutoHotkey.

Full notices: [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).

---

## Author

**Henning Pähtz:** media scientist (Dipl.-Medienwiss.) based in Lutherstadt Eisleben, Germany. Web design, brand strategy, AI consulting and process automation.

🌐 [paehtz.de](https://paehtz.de) · ✉️ henning@paehtz.de

---

## Credits

- [Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor): the DLL that provides access to the Windows virtual-desktop API.
- [AutoHotkey v2](https://www.autohotkey.com/)
