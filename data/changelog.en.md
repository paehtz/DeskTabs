# DeskTabs: what's new
<!-- One section "## x.y.z" per version with short points "- ...". Each point says what users can now do or what works better, and where to find it; the key phrase at the start in **bold**. DeskTabs shows the sections after an update (newest first, all skipped versions). -->

## 1.1.19
- **Windows stay normal:** after a desktop switch, windows could end up permanently “always on top”, so others could no longer be brought to the front. This no longer happens. If it happened to you, restarting the affected programs returns them to normal.

## 1.1.18
- **Timer instead of call:** “Start a call” becomes **Start timer** (right-click a tab or Ctrl + Win + T). It is for anything that belongs to one client but makes you switch desktops: a phone call while you look something up elsewhere, or work with tools on several desktops. All that time counts for the desktop you started it for. When you stop it, you can add a **note** such as “Call with Christian”; it shows in the time log and the time report. DeskTabs suggests your recent notes per desktop as bubbles: click one to use it, ✎ renames it (in earlier entries too, if you like), × removes it, and a right-click pins regular entries.
- **Faster desktop switching:** after a switch DeskTabs no longer waits for Windows before arranging windows and the bar. A click on a tab also no longer jumps back to the previous desktop when that desktop's last front window has meanwhile moved to another desktop.

## 1.1.17
- **Time report:** the menu now has **Time report…**. It shows in your browser how much time you spent on which desktop and sub-project. Browse day by day with the arrow keys, or pick a week, month, year or any range. Each day appears as a coloured timeline, plus hours per day, your typical working hours across the day, weekdays, all calls and the comparison with last week. Hide desktops you don't need, export any table as CSV straight into Excel, and use **Print / PDF** for a timesheet. Everything stays on your computer.
- **One click shows a window on all desktops:** **Shift + click ≡** shows the active window on every desktop, just that window, not the whole app. **Shift + click a tab** brings it back: from then on it shows only on that desktop, including the one you are on.

## 1.1.16
- **Each desktop keeps its windows in front:** windows shown on all desktops no longer push themselves to the front everywhere. When you return to a desktop, the windows you last worked with there are back in front, on all monitors, and the last one used has the focus. Turn it off under **More settings**.
- **Calls with a timer:** when a client calls, right-click their tab and choose **Start a call**, or press **Ctrl + Win + T**. A timer runs above the tab, and the time log assigns the whole call to that client, even while you look things up on other desktops. Click the timer to end it.
- **A more precise time log:** breaks are now rows of their own (no input, locked, sleep, DeskTabs off), stays across midnight are split, and every row carries a stable desktop ID. For testing you can pause the log under **More settings › Time log**.
- **Customise DeskTabs with AI:** the program folder now contains a guide for AI assistants such as Claude Code or Codex. Just tell your assistant what you want, say "give the desktop Acme a green colour", and it knows where to set it. Find it under **Help › Guide for AI assistants**.
- **Umlauts stay intact:** desktop names with accents or umlauts in the settings no longer get garbled, even after another program edited the file.
- **Smoother reordering:** even the first tab you drag after a start glides calmly into place.

## 1.1.15
- **Leaves nothing behind:** after a one-click update, DeskTabs removes the downloaded setup file again, so your disk stays tidy.

## 1.1.14
- **Catch up after a break:** if you skipped a few updates, this window lists what's new in every version you missed, one below the other. If it gets taller than your screen, just scroll with the mouse wheel.

## 1.1.13
- **One-click updates:** no need to look for new versions yourself any more. When one is out, a notice appears above the taskbar on the left. One click on **Update now** is all it takes: DeskTabs downloads the new version, checks it, installs it and restarts. Your desktops, colours, icons and time logs stay as they are.
- **Always know what's new:** after every update this window shows what you can do now. Open it again any time under **Help → New in this version**.
- **Rather decide yourself?** Turn the update notice off under **More settings**.

## 1.1.12
- **Keep several projects apart on one desktop:** if you work on several small projects on one desktop, say for different clients, add **sub-projects** to it: **Alt + click** the tab. The active one shows in small type under the desktop name, and the **time log** records it in its own column, so you can see later exactly how much time went into which project.
- **Switch sub-projects quickly:** a **click on the active tab** opens a small picker right above it.
- **No more accidental Task View:** clicking the active tab no longer opens Windows Task View. If you want it back, set `ClickActiveTaskView = 1` in settings.ini.
- **Menus like Windows 11:** light, calm and with clear icons.
- **More reliable:** the bar stays visible when you open the Start menu, reordering by dragging can no longer get stuck, and switching no longer flickers.
