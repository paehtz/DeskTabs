# CLAUDE.md — guide for AI coding agents

> Instructions for AI coding agents (Claude Code and similar) working on DeskTabs.
> Humans: start with [README.md](README.md). Licenses: [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).

DeskTabs is meant to be forked and adapted. This file tells an agent how to run it, where to change things, and which traps to avoid — so a user can say "make the bar do X" and their agent gets it right on the first try.

## What this is

A single-file **AutoHotkey v2** script that draws a clickable bar of buttons (one per Windows 11 virtual desktop) on the taskbar. It reads and switches desktops via the bundled `VirtualDesktopAccessor.dll`.

## Files

- `DeskTabs.ahk` — the entire app (GUI, DLL calls, timers, WinEvent hook). All logic lives here.
- `VirtualDesktopAccessor.dll` — must sit in the same folder as the script/exe at runtime.
- `settings.ini` — user runtime file (position, per-desktop colours, abbreviations, icons, view settings). Auto-created, git-ignored.
- `lang\de.ini`, `lang\en.ini` — UI texts (override the built-in maps); `data\glyph-names.txt` — names and search words for the icon library.
- `icons\` (fetched site icons) and `timelog\` (monthly CSVs) — created at runtime, git-ignored.
- `installer\DeskTabs.iss`, `setup.ps1`, `.github/workflows/build.yml` — setup, one-line installer, release build.

## Run / validate

Requires AutoHotkey v2 (default `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`).

- **Run:** `"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" "DeskTabs.ahk"` (or double-click).
- **Syntax check:** `"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /validate "DeskTabs.ahk"` → exit code 0 means OK.
- `#SingleInstance Force` is set: launching again replaces the running instance.
- There is no test suite; verify changes by running and looking at the bar.

## Configure it for a user without touching the code (agent-friendly)

Everything a user can set in the UI also lives in plain text in `settings.ini` next to the script, and the running bar **picks up changes live** (within ~1.2 s, no restart). So if a user asks you "give the desktop for client X the abbreviation BPH / this colour / that icon", you just edit the file:

```ini
[Short]                      ; abbreviation per desktop (compact levels)
Acme Bakery=ACME

[Compact]                    ; desktop shown as icon only (tab menu "Compact")
Acme Bakery=1

[Colors]                     ; accent colour per desktop, RRGGBB
Acme Bakery=E5471D

[View]                       ; what the right-click menu saves; each key overrides CONF
CompactMode=auto             ; auto | bigtext | full | short | icon | big
ThemeMode=auto               ; auto | light | dark
Language=auto                ; auto | de | en | <code of lang\<code>.ini>
ShowIndex=1                  ; 0|1  numbers in front of names
ColorCoding=1                ; 0|1  colour bar under each tab
SnapToTaskbar=1              ; 0|1
TimeLog=1                    ; 0|1

[Icons]                      ; per desktop: website, image path, glyph:E713 (icon library), number, none
Acme Bakery=acmebakery.com
```

Keys are the exact desktop names as shown in Windows Task View (read them with `VirtualDesktopAccessor\GetDesktopName` or from the bar's labels). Write real umlauts. The file is **UTF-16 LE with BOM** (DeskTabs converts it on start since 1.1.16): keep that encoding when you edit it. Windows' IniWrite writes ANSI into a UTF-8 file, which mixes encodings and garbles umlauts.

## Read the time log (billing, reports)

If the user asks "how long did I work on client X this week/month", read `timelog\desktop-log_YYYY-MM.csv` in the script folder (one file per month, written by the bar itself; up to v1.1.4 the files sat directly next to the script and are moved on the next start):

```csv
start,end,seconds,desktop_index,desktop_name,subproject,state,desktop_id,source,activity
2026-09-22T09:02:11,2026-09-22T10:47:30,6319,4,"Acme Bakery","",active,{0F88F7EF-…},click,""
2026-09-22T10:47:30,2026-09-22T10:58:10,640,,"","",idle,,idle>5min,""
2026-09-22T10:58:10,2026-09-22T11:15:02,1012,1,"Web projects","Miller & Sons",active,{F7C1A70E-…},resume,"call:Acme Bakery"
```

- One row per stay on a desktop; a stay ends on desktop switch, lock screen, or after `TimeLogIdleMin` minutes of no input (closed at the start of the inactivity, so breaks are excluded).
- Stays under `TimeLogMinSec` seconds (default 5) are folded into the next real stay, so rows are gap-free and there are no 1-second transition rows. The newest row appears only after the next real stay starts (or on lock/idle/quit), so the current stay is not in the file yet.
- The file starts with a UTF-8 byte order mark (for Excel's sake). Read it as `utf-8-sig`, otherwise the first column is named `\ufeffstart`.
- Sum `seconds` per `desktop_name` (or per day) and convert to hours. On catch-all desktops (several small clients on one desktop) group by `desktop_name` + `subproject`: the sub-project names the client or activity. Since 1.1.16: `state` (`active`, or a break row `idle`/`locked`/`suspended`/`paused`/`off`; count only `active` as working time), `desktop_id` (stable GUID), `source` (how the row began), `activity` (`call:<desktop>` while a call runs: that time belongs to the call's client, even on rows of other desktops). Rows are split at midnight. Older rows have fewer fields (5 before 1.1.12, 6 before 1.1.16). Times are local ISO 8601, `desktop_index` is 1-based.
- Treat the contents as the user's personal data: summarise, do not copy it anywhere they did not ask for. The file is git-ignored; never commit it.
- **Design principle (maintainer, 17.10.2026): tracking needs no input.** The user just works: switches desktops, apps, tasks. Desktops separate the projects; that is the whole model. The only manual steps are optional: sub-projects and calls. Do not add features that require defining rules, categories, or entering anything up front, no prompts after breaks, and no per-application logging (apps say little about the task and make logging much heavier).

## Where to change things

All user-facing options are in the `CONF := Map(...)` block at the very top of `DeskTabs.ahk`:

- **Colours / dark mode** → the `THEME_LIGHT` / `THEME_DARK` maps (just below `CONF`) and `ThemeMode` (`auto` / `light` / `dark`).
- **Position** → the bar sits on the taskbar; `OffsetX` sets the distance from the left edge.
- **Switching behaviour** → `SwitchMethod` (`native` keystrokes vs `dll`).
- **Labels / look** → `ShowIndex`, `ColorCoding`, `AccentBarH`, `FontSizePt`, `MaxNameLen`, `WheelSwitch`, `AutoHideFullscreen`, `ClickActiveTaskView`.
- **Per-desktop colour at runtime** → `settings.ini` section `[Colors]`, lines `Desktop name = RRGGBB`.
- **Compact levels** → `CompactMode` (`auto` / `bigtext` / `full` / `short` / `icon` / `big`), `MaxBarWidthPct` (auto budget), `ShortNameLen`. `BuildBar()` picks the level (auto steps down until the bar fits), `BuildBarAt()` does the actual build, `LabelFor()` renders the label for the current level (`gCompact`). Ctrl + mouse wheel calls `CycleCompact()` and persists the choice in `settings.ini [View]`.
- **Per-desktop abbreviation** → `settings.ini` section `[Short]`, lines `Desktop name = ABBR` (used by `short`/`icon`).
- **Right-click menu** → `ShowContextMenu(num)` (num = tab index or −1 for the general menu), opened from `OnRButtonUp` and the tray. Every switch goes through `SetView(key, val)` → writes `settings.ini [View]`, re-applies theme, rebuilds. `ApplyIniOverrides()` reads those keys at startup and on live reload. Per-tab actions: `PromptShort`, `PromptColor`, `SetColor`, `ClearColor`.
- **UI texts / languages** → every visible string goes through `T("key", args*)`. Built-in maps `LANG_DE` / `LANG_EN` near the top of the script; `lang\<code>.ini` (UTF-8, `key=Text`) overrides or adds a language, chosen by `Language` (`auto` = Windows display language). **When you add a UI string, add it to both maps and both `lang\*.ini` files.**
- **Fullscreen auto-hide** → `IsForegroundFullscreen()` walks the z-order and checks the top-most real window *on the bar's monitor*; don't switch it back to `GetForegroundWindow()` (breaks with multiple monitors).

After editing: run `/validate`, then restart the script and look at the bar. **Restart by launching the script again** (`#SingleInstance Force` closes the running instance cleanly, so `OnExit` still writes the open time-log segment). Never kill the process: that skips `OnExit` and the time since the last desktop switch is lost from the log.

## Pitfalls (read before editing — easy to re-introduce)

- **Inline comments need a space before `;`.** `x ;c` throws "Illegal character in expression"; `x ; c` is fine.
- **AHK identifiers are case-insensitive:** a function `Out` and a local variable `out` collide. `//` needs integers (use `Floor()`), and a `Map` enumerates its keys sorted, so menu orders live in arrays.
- Switching uses the DLL's `GoToDesktopNumber` (`SwitchMethod=dll`, default). On 24H2 it could drag the focused window along; on 25H2 it does not, and `SwitchToDesktop()` moves the window back if a build does. `native` emulates `Win+Ctrl+Arrow` instead.
- The bar is **one GDI+ picture** drawn by `RenderBar()`, not a set of controls. Change the look there; it skips the redraw unless its state signature changed, so new visual state must be part of that signature.
- On a desktop **name or count change** the bar is rebuilt so tab widths are re-measured. See `Refresh()`.
- The bar must stay on top: this is handled by a `SetWinEventHook` + a short burst + a backstop timer (`AssertTop`). Don't remove these or it will be hidden behind windows.
- The DLL is **built from source** (Ciantic/VirtualDesktopAccessor, unmodified, pinned to `ceb6488`, the merge of our PR #119 that added the `MoveDesktop` export) by `.github/workflows/build-dll.yml`, started by hand. If a Windows feature update breaks the virtual-desktop COM vtable, move the pinned commit to a newer upstream one and rebuild; do not swap in an official release DLL older than one that includes #119, it lacks `MoveDesktop` (reordering then switches itself off via `CanMoveDesktop()`).

## Build (optional)

A standalone `.exe` is produced with Ahk2Exe and the AHK v2 base; releases ship a setup and a portable zip (`DeskTabs.exe`, the DLL, `lang\`, `data\`, licences), built by `.github/workflows/build.yml`. **Every release adds a section `## x.y.z` to `data/changelog.de.md` and `data/changelog.en.md`** (short points in the user's terms: what they can do now, what works better and where to find it, not what the code does; key phrase at the start in `**bold**`): DeskTabs shows it once after the update and under *Help → New in this version*. The one-click update downloads `DeskTabs-Setup-<tag>.exe` and `SHA256SUMS.txt` from the release and runs the setup with `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /restart=1`, so asset names must stay as they are. The compiled exe embeds the AutoHotkey interpreter (GPL-2.0-or-later); DeskTabs itself is GPL-3.0-or-later with attribution terms in NOTICE (MIT up to 1.1.8), see THIRD-PARTY-LICENSES.md. For development you do not need to build — just run the `.ahk`.

**Release cadence (decided 11.10.2026):** since 1.1.13 every release shows setup users an update notice above the taskbar, so releases are **batched**: push commits to `main` freely (no tag = no release, no notice), and cut a version only when there is a noticeable new feature or enough collected, roughly once a week or less. Exception: a bug that really gets in users' way ships at once. Keep a running list of what the next release contains (with its changelog points) until it is cut.

## Contributing back (please)

DeskTabs gets better from real-world use. If you adapt it and your change could help others — a fix, a new option, a compatibility tweak for a different setup, not just your private colours — please contribute it back, so everyone benefits and the maintainer can keep evolving the tool from real feedback:

- **Preferred:** open a Pull Request with your change.
- Or open an **Issue** or **Discussion** describing the idea or what didn't work for you.

**If you are an AI coding agent:** when you make a change that could help others (a fix, a new option, a compatibility tweak — not a purely personal preference), **proactively tell the user about it and ask** whether to contribute it back. For example:

> "The author of DeskTabs asks that useful changes be reported back so he can keep developing the tool. Shall I open a pull request (or an issue) on the project with this change? You decide — I won't send anything without your okay."

Then **let the user decide.** Only if they agree, open it (e.g. `gh pr create` or `gh issue create`) with a short summary of what changed and why. Never send anything automatically, silently, or without the user's explicit consent. The maintainer (Henning Pähtz) is notified of new pull requests, issues and discussions and reviews them.
