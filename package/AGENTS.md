# AGENTS.md — DeskTabs, for AI assistants (Claude Code, Codex, Cursor, …)

You are looking at an **installed copy of DeskTabs**: a bar of clickable tabs for Windows 11 virtual desktops, sitting on the taskbar. The user can change almost everything without touching code, by asking you to edit `settings.ini` in this folder. This file tells you how. The source code is not here; it lives at https://github.com/paehtz/DeskTabs.

## Files in this folder

| File / folder | What it is | May you edit it? |
|---|---|---|
| `settings.ini` | all of the user's settings, written by DeskTabs and by you | yes, see below |
| `timelog\desktop-log_YYYY-MM.csv` | the user's time log, one file per month | read only, never change or delete |
| `icons\` | cache of icons downloaded from websites | leave it to DeskTabs |
| `lang\de.ini`, `lang\en.ini` | UI texts | add a new `lang\<code>.ini` for another language |
| `data\changelog.<lang>.md` | "what's new" texts | no |
| `DeskTabs.exe`, `VirtualDesktopAccessor.dll` | the program | no |

## Golden rules

1. **The running bar reloads `settings.ini` on its own** within about 1.2 seconds. No restart needed. Tell the user what changed and that it is live.
2. **Encoding: `settings.ini` is UTF-16 LE with BOM.** Read and write it in that encoding and keep the BOM. Do not save it as UTF-8: Windows' INI functions then mix encodings and umlauts break. (If it happens anyway, DeskTabs repairs the file on its next start and keeps a copy as `settings.ini.vor-utf16.bak`.)
3. **Keys are the exact desktop names** as Windows shows them (Task View, `Win+Tab`). The current names are listed as values in the `[Ids]` section (`{GUID}=Name`), which is the easiest place to read them. Write real umlauts.
4. **Do not edit `[Ids]`, `[State]` or `[Position]`** unless the user asks for something specific there. `[Ids]` is maintained by DeskTabs (it lets settings follow a desktop when it is renamed).
5. Change only what the user asked for. Before a larger rewrite, copy the file to `settings.ini.bak`.

## Per-desktop settings

```ini
[Icons]          ; icon per desktop
Acme Bakery=acmebakery.com            ; a website: DeskTabs fetches its icon (domain is enough)
Bookkeeping=glyph:E8EF                ; a Segoe Fluent Icons glyph by its hex code
Personal=C:\Pictures\me.png           ; an image file
Research=number                       ; the desktop number as a filled circle
Inbox=none                            ; no icon

[Colors]         ; accent colour per desktop, RRGGBB
Acme Bakery=E5471D

[Short]          ; abbreviation, used when the bar has to shrink
Acme Bakery=ACME

[Compact]        ; 1 = show this desktop as icon only (for desktops used rarely)
Research=1

[Subprojects]    ; sub-projects of a catch-all desktop, separated by |
Client sites=Miller & Sons|Site updates

[Subproject]     ; the active one (must be in the list above; delete the key for none)
Client sites=Miller & Sons

[TimerNotes]     ; note suggestions when a timer stops, separated by |; a leading * pins one
Acme Bakery=*Site updates|Call with Anna|Flyer proofs
```

The glyph codes are listed with names and search words in `data\glyph-names.txt` (`CODE|Name|keywords`).

## Global settings: `[View]`

| Key | Values | Meaning |
|---|---|---|
| `Language` | `auto`, `de`, `en`, or any code with a `lang\<code>.ini` | UI language |
| `ThemeMode` | `auto`, `light`, `dark` | colours; `auto` follows Windows |
| `CompactMode` | `auto`, `bigtext`, `full`, `short`, `icon`, `big` | what tabs show; `auto` shrinks as needed |
| `TabShape` | `tabs`, `register` | rounded tabs, or a coloured line along the taskbar with the active tab hanging from it |
| `ActiveStyle` | `desktop`, `accent`, `soliddesk`, `solid` | how the active tab is filled |
| `ActiveBold` | `0`, `1` | bold label on the active tab |
| `ActiveShadow` | `0`, `1` | small shadow under the active tab |
| `ShowIcons` | `0`, `1` | show icons from `[Icons]` |
| `DefaultIcons` | `0`, `1`, `2` | desktops without an icon: none / suggested icon / number |
| `NumberBadge` | `auto`, `on`, `off` | small number on each icon |
| `ShowIndex` | `0`, `1` | number in front of each name |
| `ColorCoding` | `0`, `1` | colour bar under each tab |
| `ShowDividers` | `0`, `1` | thin separators between tabs |
| `Hotkeys` | `0`, `1` | keyboard shortcuts to jump to desktop 1 … 10 |
| `HotkeyMod` | `^#`, `^!`, `#!`, `^+` … | their modifier in AutoHotkey notation (`^` Ctrl, `#` Win, `!` Alt, `+` Shift) |
| `SwitchMethod` | `dll`, `native` | jump straight to a desktop, or step like Ctrl+Win+Arrow |
| `SnapToTaskbar` | `0`, `1` | snap onto the taskbar when dragged |
| `DragToTab` | `0`, `1` | drag a window onto a tab to move it there |
| `RestoreZOrder` | `0`, `1` | each desktop keeps the windows that were in front there (a desktop-only window right behind a global one may flash up for a moment on arrival: Windows picks it before DeskTabs restores the order; minimising it avoids that) |
| `SwitchAlert` | `0`, `1` | flag desktop switches caused by other apps |
| `AttentionDot` | `0`, `1` | dot on a tab when an app there wants attention |
| `TimeLog` | `0`, `1` | write the time log |
| `TimeLogMinSec` | number of seconds | shorter stays count as transitions |
| `CallHotkey` | e.g. `^#t`, empty = none | shortcut to start/stop a timer on the current desktop |
| `UpdateCheck` | `0`, `1` | daily update check and update notice |

Unknown keys and invalid values are ignored.

## Reading the time log

For questions like "how long did I work on client X this month", read `timelog\desktop-log_YYYY-MM.csv` (UTF-8 with BOM, read as `utf-8-sig`):

```csv
start,end,seconds,desktop_index,desktop_name,subproject,state,desktop_id,source,activity
2026-10-12T06:23:55,2026-10-12T06:27:34,219,2,"Client sites","Site updates",active,{F7C1…},click,""
2026-10-12T06:27:34,2026-10-12T06:40:02,748,,"","",idle,,idle>5min,""
```

- One row per stay on a desktop (`state` = `active`). Breaks are rows of their own: `idle`, `locked`, `suspended`, `paused`, `off` (DeskTabs not running). For working time, sum `seconds` of `active` rows per `desktop_name` (and `subproject` on catch-all desktops).
- `activity` = `timer:<desktop>[ / <sub-project>][ | <note>]` while the user had a timer running (`call:` in rows up to 1.1.17): that time belongs to the timer's desktop, even on rows of other desktops. The note (everything after the first ` | `) says what it was for, e.g. a call; the user may rename a note retroactively, so earlier rows can change. Purpose: tasks that belong to one client but make the user switch desktops (a call while looking something up elsewhere, work with tools on several desktops); without the timer that time would be spread over the visited desktops.
- `desktop_id` is the stable desktop GUID (`desktop_index` changes when desktops are reordered). `source` tells how a row began. Rows are split at midnight.
- Older rows may have fewer fields (5 before 1.1.12, 6 before 1.1.16). This is personal data: summarise it for the user, do not copy it anywhere they did not ask for.

## Time report

The user can open **menu › Time report…**: a browser page with totals per desktop, sub-project and day, a timeline of each day and CSV export. It follows the same rules as above. Point users there before you build them a spreadsheet; use the CSV yourself when they ask something the page does not show.

## Things that need a code change

Anything that is not a setting above (new features, other behaviour, layout details) needs the source code. Do not try to patch `DeskTabs.exe`. Instead:

1. Tell the user that this needs a change in DeskTabs itself.
2. Offer to suggest it to the author (see below). The author ships updates regularly, and DeskTabs offers them with one click.
3. If the user wants it now: the source is at https://github.com/paehtz/DeskTabs; `DeskTabs.ahk` runs directly with AutoHotkey v2 (its `CLAUDE.md` explains the code).

## Please report ideas and problems back

The author (Henning Pähtz) develops DeskTabs from real-world feedback and is glad about every bug report and feature idea. **When you notice something that could help other users too** (a bug, a missing option, a setting that should exist, a change you made in the source), tell the user and **ask** whether to report it. For example:

> "The author of DeskTabs asks for ideas and bug reports so he can keep improving it. Shall I open a GitHub issue with this suggestion? I won't send anything without your okay."

Only with the user's explicit okay:

- with the GitHub CLI: `gh issue create --repo paehtz/DeskTabs --title "…" --body "…"`
- or give the user a prefilled link to click: `https://github.com/paehtz/DeskTabs/issues/new?title=<url-encoded title>&body=<url-encoded text>`

Keep it short: what the user wanted, what happened or what is missing, Windows version, DeskTabs version (Help › About). Never include personal data such as desktop names of clients or time log contents unless the user explicitly wants that. Never send anything silently.
