# Desktop Switcher

Eine schlanke, klickbare Button-Leiste für die **virtuellen Desktops von Windows 11**, die unten links an der Taskleiste sitzt. Eigenbau für Henning Pähtz (AutoHotkey v2).

Jeder virtuelle Desktop bekommt einen Button mit seinem Windows-Namen. Klick = dorthin wechseln, der aktive Desktop ist hervorgehoben. Gedacht für Zeit-Tracking pro Kundenprojekt (ein Desktop = ein Kunde).

---

## Was es kann

- **Live-Namen aus Windows** — die Button-Beschriftung kommt direkt aus den in Windows benannten Desktops (Task-Ansicht). Nichts wird doppelt gepflegt.
- **Dynamisch** — Desktop hinzufügen/entfernen in Windows → die Leiste passt sich innerhalb ~1,2 s automatisch an (oder Tray → „Leiste neu aufbauen").
- **Nativer Wechsel** — Klick bildet `Win+Strg+Pfeil` nach. Fenster bleiben stabil auf ihren Desktops (anders als `GoToDesktopNumber`, das auf 24H2/25H2 das Fokusfenster mitnimmt).
- **Auf allen Desktops sichtbar** — das Fenster ist an alle Desktops gepinnt.
- **Index-Präfix** — „3 · Wolf Automobile" (abschaltbar).
- **Farbcodierung** — dünner Farbbalken pro Desktop (Tab-Indikator-Stil, abschaltbar, pro Desktop überschreibbar).
- **Hover-Effekt** — Button unter der Maus hellt auf.
- **Klick auf aktiven Desktop** — öffnet die Task-Ansicht (Win+Tab).
- **Vollbild-Auto-Hide** — blendet sich aus, wenn eine Vollbild-App im Vordergrund ist.
- **Mausrad** über der Leiste blättert durch die Desktops.
- **Trennstriche** zwischen den Buttons (Material, dezent).
- **Verschiebbar** am Griff `≡` links; Position wird in `settings.ini` gemerkt.

---

## Voraussetzungen

- **Windows 11** — entwickelt/getestet auf **25H2 (Build 26200.8457)**. Funktioniert ab 24H2 (26100.2605).
- **AutoHotkey v2** (getestet mit 2.0.26) — `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`
- **VirtualDesktopAccessor.dll** (liegt im Repo) — von [Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor), Release `2024-12-16-windows11`.

---

## Starten

Doppelklick auf `DesktopSwitcher.ahk` (öffnet mit AHK v2), oder:

```
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" "C:\Programmgelege\DesktopSwitcher\DesktopSwitcher.ahk"
```

**Autostart:** Verknüpfung im Startup-Ordner
`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\DesktopSwitcher.lnk`
→ Ziel: `AutoHotkey64.exe` mit dem Skriptpfad als Argument.

**Beenden / Steuern:** Tray-Icon (Bildschirm-Symbol) → Rechtsklick:
- Leiste neu aufbauen
- Position zurücksetzen
- Beenden

---

## Konfiguration

Alle Optionen stehen im `CONF`-Block ganz oben in `DesktopSwitcher.ahk`:

| Option | Default | Bedeutung |
|---|---|---|
| `DockMode` | `on` | `on` = auf der Taskleiste (gewünschter Standard, optisch integriert, kann beim Fensterwechsel minimal flackern). `above` = knapp über der Taskleiste (flackerfrei, überlagert aber die unterste Fensterkante). |
| `OffsetX` | 10 | Abstand vom linken Bildschirmrand (px). |
| `SwitchMethod` | `native` | `native` = Win+Strg+Pfeil nachbilden (Fenster bleiben stabil). `dll` = `GoToDesktopNumber` (schneller, nimmt aber Fenster mit). |
| `ShowIndex` | 1 | Nummern-Präfix („3 · …"). |
| `ColorCoding` | 1 | Farbbalken pro Desktop. |
| `AccentBarH` | 3 | Höhe des Farbbalkens (px). |
| `AutoHideFullscreen` | 1 | Bei Vollbild-App ausblenden. |
| `ClickActiveTaskView` | 1 | Klick auf aktiven Desktop öffnet Win+Tab. |
| `WheelSwitch` | 1 | Mausrad blättert Desktops. |
| `Palette` | 8 Farben | Farbpalette für die Farbcodierung (nach Index). |
| `FontSizePt` | 10 | Schriftgröße. |
| `MaxNameLen` | 22 | Namen länger als das werden gekürzt. |
| Farben | hell | `ColBarBg`, `ColInactiveBg/Tx`, `ColActiveBg/Tx`, `ColHoverBg/Tx`, `ColDivider` — auf helles Theme (graue Taskleiste) abgestimmt. Bei Dark-Theme anpassen. |

### settings.ini (wird automatisch angelegt)

```ini
[Position]
X=10
Y=1344

[Colors]
; Farbcodierung pro Desktop-Name überschreiben (RRGGBB):
T&K Eisleben=E5471D
Wolf Automobile=1565C0
```

---

## Wie es funktioniert (Architektur)

- **Lesen/Schreiben der Desktops** über `VirtualDesktopAccessor.dll` (in-process, schnell): `GetDesktopCount`, `GetCurrentDesktopNumber`, `GetDesktopName`, `PinWindow`, `RegisterPostMessageHook`.
- **Wechseln** über simulierte Tastenkürzel (`SwitchMethod=native`), nicht über die DLL — verhindert das Mitwandern von Fenstern.
- **Live-Update der Hervorhebung** via `RegisterPostMessageHook` (Desktop-Wechsel-Benachrichtigung) + 1,2-s-Fallback-Timer (`Refresh`), der auch Desktop-Anzahl/Namen aktualisiert und die Leiste bei Bedarf neu baut.
- **Immer im Vordergrund** (`DockMode=on`): Kombination aus
  - `SetWinEventHook(EVENT_SYSTEM_FOREGROUND)` → bei jedem Fensterwechsel sofort `AssertTop()`,
  - kurzer **Burst** (10× alle 25 ms) zum Abdecken von Maximier-Animationen,
  - 250-ms-Backstop-Timer.
- **Fenster** ist `-Caption +AlwaysOnTop +ToolWindow +E0x08000000` (WS_EX_NOACTIVATE → Klicks klauen nicht den Fokus vom Arbeitsfenster) und an alle Desktops gepinnt.

---

## Erkenntnisse / Stolpersteine (für künftige Wartung)

- **25H2-Kompatibilität:** Die Ciantic-DLL ist mit „24H2" gelabelt, läuft aber auf 25H2 (26200) einwandfrei. Bei einem Windows-Feature-Update, das die Virtual-Desktop-COM-VTable ändert, kann die DLL brechen → dann neue Version von Ciantics Repo holen.
- **`GoToDesktopNumber` nimmt Fenster mit:** Auf 24H2/25H2 nutzt die DLL intern `switch_desktop_and_move_foreground_view`. Deshalb `SwitchMethod=native` (Tastenkürzel-Nachbau).
- **`&` im Desktop-Namen:** AHK-Text-Controls interpretieren `&` als Tastenkürzel-Markierung. Lösung: Style `SS_NOPREFIX` (`+0x80`) auf die Buttons — zeigt `&` wörtlich (z.B. „T&K Eisleben").
- **z-Order der Farbbalken/Trennstriche:** Overlappende Controls werden vom Button verdeckt. Deshalb liegen Trennstriche in den Lücken und Farbbalken **unter** dem Button (überlappungsfrei).
- **AHK-Semikolon-Falle:** Ein `;` ohne Leerzeichen davor ist KEIN Kommentar, sondern wirft „Illegal character in expression". Inline-Kommentare immer mit Leerzeichen vor `;`.
- **DockMode-Abwägung:** `on` (auf der Taskleiste) sieht integrierter aus, kämpft aber mit der Taskleiste um die z-Order (kurzes Flackern beim Fensterwechsel trotz WinEvent-Hook + Burst). `above` (knapp darüber) ist flackerfrei, überlagert aber die unterste Fensterkante.

---

## Offene Punkte / Ideen

- **Rest-Flackern in `DockMode=on` final lösen.** Henning bevorzugt klar die Buttons AUF der Taskleiste (Standard = `on`) und akzeptiert das minimale Zucken beim Fensterwechsel vorerst. Ziel: dauerhaft sichtbar OHNE Zucken. Nächste Ansätze: zusätzliche WinEvents (`EVENT_OBJECT_REORDER` 0x8004, `EVENT_SYSTEM_MINIMIZEEND` 0x0017), längerer/dichterer Burst, oder ein anderer Mechanismus, um über der Taskleiste zu bleiben.
- Optional: Drag-to-Reorder der Buttons mit echter Windows-Umsortierung über [MScholtes/VirtualDesktop](https://github.com/MScholtes/VirtualDesktop) (`/MoveDesktop`). Aktuell nicht nötig (Task-Ansicht reicht).
- Optional: Dark-Theme-Farbsatz + automatische Theme-Erkennung.
- Optional: Push zu GitHub.

---

## Credits

- [Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor) — DLL für den Zugriff auf die Windows-Virtual-Desktop-API.
- AutoHotkey v2 — https://www.autohotkey.com/

_Stand: 2026-06-04_
