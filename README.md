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

## Background

I organise my projects and my time tracking around virtual desktops: one desktop per project, with exactly the windows and the layout I need for it. Switching desktops serves two purposes at once. First, it swaps the entire working context: every window of the project is instantly there. Second, [ManicTime](https://www.manictime.com), which I use to track my working hours, records the active desktop. In the daily view I can later see precisely when and how long I worked on which project.

For this to stay clean, I need to see at any moment which desktop I am on. In the past I often ran a task on the wrong desktop by accident, which skews the later evaluation and means rework. DeskTabs solves that: a permanently visible bar shows the active desktop, and a direct click switches to it instead of cycling through the Windows shortcut. So I always land in the right context, and the time is attributed to the right project.

---

## Features

- **Live names from Windows:** the button labels come straight from the desktops you named in Windows (Task View). Nothing is maintained twice.
- **Dynamic:** add or remove a desktop in Windows → the bar adapts automatically within ~1.2 s (or via Tray → "Rebuild bar").
- **Native switching:** a click emulates `Win+Ctrl+Arrow`. Windows stay put on their desktops (unlike `GoToDesktopNumber`, which drags the focused window along on 24H2/25H2).
- **Visible on all desktops:** the window is pinned to every desktop.
- **Light/Dark automatic:** follows the Windows theme (taskbar brightness), switchable or fixed.
- **Index prefix:** "3 · ProjectName" (can be disabled).
- **Colour coding:** a thin colour bar per desktop (tab-indicator style, can be disabled, overridable per desktop).
- **Hover effect:** the button under the mouse lightens up.
- **Click on the active desktop:** opens Task View (Win+Tab).
- **Fullscreen auto-hide:** hides itself when a fullscreen app is in the foreground.
- **Mouse wheel** over the bar pages through the desktops.
- **Separators** between the buttons (subtle).
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
2. Extract it anywhere and keep `DeskTabs.exe` and `VirtualDesktopAccessor.dll` together in the same folder.
3. Double-click `DeskTabs.exe`.

Or install (and update) in one line, from PowerShell:

```powershell
irm https://raw.githubusercontent.com/paehtz/DeskTabs/main/setup.ps1 | iex
```

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

**Quit / control:** tray icon (screen symbol) → right-click:
- Rebuild bar
- Reset position
- Exit

---

## Configuration

All options live in the `CONF` block at the very top of `DeskTabs.ahk`:

| Option | Default | Meaning |
|---|---|---|
| `DockMode` | `on` | `on` = on the taskbar (visually integrated, may flicker slightly when switching windows). `above` = just above the taskbar (flicker-free, but overlaps the bottom edge of windows). |
| `ThemeMode` | `auto` | `auto` = follow the Windows theme (taskbar brightness via registry `SystemUsesLightTheme`). `light` / `dark` = fixed. A change at runtime is detected automatically (~1.2 s) and the bar is rebuilt. |
| `OffsetX` | 10 | Distance from the left screen edge (px). |
| `SwitchMethod` | `native` | `native` = emulate Win+Ctrl+Arrow (windows stay stable). `dll` = `GoToDesktopNumber` (faster, but drags windows along). |
| `ShowIndex` | 1 | Number prefix ("3 · …"). |
| `ColorCoding` | 1 | Colour bar per desktop. |
| `AccentBarH` | 3 | Height of the colour bar (px). |
| `AutoHideFullscreen` | 1 | Hide when a fullscreen app is in front. |
| `ClickActiveTaskView` | 1 | Clicking the active desktop opens Win+Tab. |
| `WheelSwitch` | 1 | Mouse wheel pages through desktops. |
| `Palette` | 8 colours | Colour palette for the colour coding (by index). |
| `FontSizePt` | 10 | Font size. |
| `MaxNameLen` | 22 | Names longer than this are truncated. |
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
```

---

## How it works (architecture)

- **Reading the desktops** via `VirtualDesktopAccessor.dll` (in-process, fast): `GetDesktopCount`, `GetCurrentDesktopNumber`, `GetDesktopName`, `PinWindow`, `RegisterPostMessageHook`.
- **Switching** via simulated keyboard shortcuts (`SwitchMethod=native`), not via the DLL, which prevents windows from being dragged along.
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
- **`GoToDesktopNumber` drags windows along:** on 24H2/25H2 the DLL internally uses `switch_desktop_and_move_foreground_view`. Hence `SwitchMethod=native` (shortcut emulation).
- **`&` in a desktop name:** AHK text controls interpret `&` as an accelerator marker. Fix: the `SS_NOPREFIX` style (`+0x80`) on the buttons, which shows `&` literally (e.g. "T&K").
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

[MIT](LICENSE) © Henning Pähtz

---

## Author

**Henning Pähtz:** media scientist (Dipl.-Medienwiss.) based in Lutherstadt Eisleben, Germany. Web design, brand strategy, AI consulting and process automation.

🌐 [paehtz.de](https://paehtz.de) · ✉️ henning@paehtz.de

---

## Credits

- [Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor): the DLL that provides access to the Windows virtual-desktop API.
- [AutoHotkey v2](https://www.autohotkey.com/)
