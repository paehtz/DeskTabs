# Privacy

DeskTabs collects no personal data, shows no advertising, contains no analytics or telemetry, and has no account or login. Nothing about how you use it leaves your computer.

## The one request to the internet

Once a day, at most, DeskTabs asks the GitHub releases API for the version number of the latest release:

```
GET https://api.github.com/repos/paehtz/DeskTabs/releases/latest
```

The request sends nothing but the usual HTTP headers, including a user agent of the form `DeskTabs/1.1.2`. GitHub sees the request the way it sees any visitor, including the IP address; DeskTabs sends no identifier of its own. Only the version number is read from the answer, to tell you that a newer release exists.

**How to switch it off:** right-click the bar → *Help* → uncheck *Check for updates daily*, or set `UpdateCheck = 0` in `settings.ini`. With it off, DeskTabs makes no network requests at all.

## When you ask for an icon from a website

If you give a desktop an icon by typing a website address, DeskTabs fetches that page and its icon at that moment, and only then. The icon is stored in `icons\` next to the program. This happens only on your explicit request, never in the background.

## What is written to disk

Everything stays in the program's own folder:

| File | What it holds |
|---|---|
| `settings.ini` | Your settings: position, colours, abbreviations, icons, view |
| `icons\` | Icons that were fetched from websites |
| `timelog\desktop-log_YYYY-MM.csv` | If the time log is on: which desktop was active when, and for how long |
| `_error.log` | Only if something went wrong: time, message, line number |

The time log is a local file for your own time tracking. It is never uploaded anywhere. Switch it off in the right-click menu or with `TimeLog = 0`.

## Uninstalling

The setup wizard removes the program and asks whether to keep your settings, icons and time logs. The portable version needs no uninstaller: delete the folder. DeskTabs writes nothing to the registry apart from the entry the installer creates for *Apps & features*.

## Contact

Questions about this: henning@paehtz.de
