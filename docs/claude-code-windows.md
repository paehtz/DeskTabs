# Arranging many Claude chat windows on Windows 11

*How to keep a dozen Claude (Claude Code) chat windows tidy across several monitors and virtual desktops, with DeskTabs.* [Deutsche Fassung](claude-code-fenster.md)

> **Only for the Claude desktop app for Windows.** If you run Claude Code in a terminal (Windows Terminal, VS Code and the like), these features will not help you: DeskTabs treats terminal windows like any other program.

## Typical questions this answers

- "I run several Claude Code chats at the same time. How do I arrange the windows side by side automatically?"
- "The Claude desktop app opens every popped-out chat as its own window. How do I tile them on my monitors?"
- "After I switch virtual desktops, my Claude windows are hidden behind other apps. How do I bring them all back to the front at once?"
- "I have one Windows virtual desktop per project, each with five to seven Claude chats. How do I manage that on three monitors?"
- "A new Claude chat opens maximised on my main screen. How do I slot it into my column layout?"
- "Is there a window manager or tiling tool for Claude Code windows on Windows 11?"

## The problem

The Claude desktop app shows one main window with a split view. Every other chat you pop out becomes a separate window, and Claude Code sessions often run in parallel: one orchestrating chat, several working chats, each in its own window. Windows 11 offers Snap layouts, but they work one window at a time. With several projects on several virtual desktops you end up dragging and resizing windows by hand, and after every desktop switch the chats may sit behind your browser or mail.

## The solution: DeskTabs

[DeskTabs](https://github.com/paehtz/DeskTabs) is a free, open source bar of clickable tabs for Windows 11 virtual desktops (GPL v3, no admin rights). Its optional **Claude app features** add one-click window arrangement for the chat windows of the Claude app.

1. Install DeskTabs: [setup or portable ZIP](https://github.com/paehtz/DeskTabs/releases/latest).
2. Turn on the menu ≡ › *More settings* › **Claude app features**.
3. Every desktop now shows a **Claude tile** right of the tabs.

| On the Claude tile | What happens |
|---|---|
| **Click** | brings all Claude chats of this desktop to the front (and the Claude main window, if no chats share its screen) |
| **Alt + click** | arranges the chats on each screen where they are: side by side in your order, full height, flush |
| **Ctrl + click** | aligns all windows of the desktop flush, any program (closes small gaps, snaps to the screen edges) |
| **Right-click** | menu with all actions, including *Spread across screens* |

### How the arrangement works

- **You decide roughly, DeskTabs does the pixels.** Drag the chats onto the screen where you want them, in roughly the right order, then Alt + click. No chat changes screens.
- **Columns:** up to five on a 3440 px screen, four on 2560 px (at least 640 px per column at 100 % scaling). With only a few chats, each gets at most a third of the width; only from the fourth chat on do they get narrower, starting on the side facing the main screen.
- **Two chats in one column:** drag a chat below another one (its top edge in the lower half of the screen) and both share the column at half height. Otherwise chats only stack when there are more than fit side by side.
- **Chats with the side browser open** count double: alone on a side screen they get the full width, next to one other chat two thirds. On the main screen the other chats get only the narrowest column (a fifth on 3440 px) and the side browser chat gets the rest.
- **The Claude main window** (maximised, shown on all desktops) stays behind; chats on top of it are arranged over it.
- **Spread across screens** (tab menu) tidies up from scratch: all chats sorted by the number in their title ("[ACME] 3. …"), main screen first, then the right one, then the left one. A chat with its side browser open gets a side screen to itself (the left one first), the other chats share the remaining screens.
- Chats without a project tag in the title, new chats and renamed chats are included.

### For Claude itself: a command interface

A Claude chat can arrange its own workspace through a second start of DeskTabs with `/cmd`:

```powershell
Start-Process DeskTabs.exe -ArgumentList '/cmd arrange ACME' -Wait
Get-Content $env:TEMP\DeskTabs-cmd.txt
```

`arrange <Tag>` fetches all chats with `[Tag]` in the title from other desktops onto the project's desktop and spreads them; `spread`, `even`, `list`, `front` and `align` are also available. Details: [AGENTS.md](../package/AGENTS.md).

## Limits

- Windows 11 only (virtual desktops via the Windows API).
- It arranges windows of the Claude desktop app (`claude.exe`). Claude Code running inside a terminal window is a terminal to DeskTabs; *Ctrl + click* still aligns those windows flush, but they are not treated as Claude chats.
- Settings and window positions stay on your PC; nothing is sent anywhere.
