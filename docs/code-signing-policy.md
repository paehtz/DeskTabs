# Code signing policy

This page documents who may request, review and approve a signed build of DeskTabs, as required for projects that use a certificate from the SignPath Foundation.

## Team

DeskTabs is maintained by one person, who therefore holds all three roles:

| Role | Person | GitHub |
|---|---|---|
| Author (writes the code, opens the release) | Henning Pähtz | [@paehtz](https://github.com/paehtz) |
| Reviewer (reviews what goes into a release) | Henning Pähtz | [@paehtz](https://github.com/paehtz) |
| Approver (approves a signing request) | Henning Pähtz | [@paehtz](https://github.com/paehtz) |

Two-factor authentication is enabled for the GitHub account that owns this repository and for the SignPath account.

## What gets signed

Only artifacts that come out of the automated build in this repository:

- `DeskTabs.exe` — compiled from `DeskTabs.ahk` with Ahk2Exe, using the official AutoHotkey v2 interpreter as the base
- `DeskTabs-Setup-vX.Y.Z.exe` — built from `installer/DeskTabs.iss` with Inno Setup

Both are produced by [`.github/workflows/build.yml`](../.github/workflows/build.yml) on a GitHub-hosted runner. The workflow downloads AutoHotkey and Ahk2Exe from their official release pages, checks that the version in the source matches the requested version, compiles, packages and publishes SHA-256 checksums for every artifact. Nothing is compiled on a maintainer's machine for a release.

## Release process

1. The version in `DeskTabs.ahk` (`APP_VERSION`) and in the Ahk2Exe directive is raised in a commit.
2. A tag `vX.Y.Z` is pushed, which starts the build workflow.
3. The maintainer reviews the produced artifacts and their checksums and approves the signing request.
4. The signed artifacts are attached to the GitHub release.

## Third-party components

- `VirtualDesktopAccessor.dll` — [Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor), MIT, redistributed unmodified.
- The AutoHotkey v2 interpreter is embedded in the compiled executable by Ahk2Exe, which puts the executable under GPL-2.0; the text ships with every release as `LICENSE-AutoHotkey.txt`. The DeskTabs source itself is MIT.
- `data/glyph-names.txt` — icon names from the Microsoft documentation, CC BY 4.0.

Details in [THIRD-PARTY-LICENSES.md](../THIRD-PARTY-LICENSES.md).

## Privacy and system changes

DeskTabs collects no personal data and sends nothing about its users anywhere. See [privacy.md](privacy.md) for the one network request it makes and how to switch it off, and for what the program writes to disk. Installation, autostart and uninstallation are described in the README; the installer needs no administrator rights and writes nothing outside its own folder except the uninstall entry and, if chosen, the autostart shortcut.
