# DeskTabs

[🇬🇧 English](README.md) · 🇩🇪 **Deutsch**

**Klickbare Desktop-Leiste für die virtuellen Desktops von Windows 11.** Sitzt unten links in der Taskleiste, ein Button pro virtuellem Desktop, beschriftet mit dem Windows-Namen des Desktops. Klick = dorthin wechseln, der aktive Desktop ist hervorgehoben.

Entwickelt von [Henning Pähtz](https://paehtz.de) als schlankes Werkzeug fürs Zeit-Tracking pro Projekt: ein Desktop = ein Kunde, immer einen Klick entfernt.

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![AutoHotkey v2](https://img.shields.io/badge/AutoHotkey-v2-334455.svg)
![Windows 11](https://img.shields.io/badge/Windows-11-0078D4.svg)

![DeskTabs, helles Theme](docs/screenshot-light.png)

![DeskTabs, dunkles Theme](docs/screenshot-dark.png)

---

## Hintergrund

Ich strukturiere meine Projekte und mein Zeit-Tracking über virtuelle Desktops: pro Projekt ein Desktop mit genau den Fenstern und der Oberfläche, die ich dafür brauche. Das Umschalten erfüllt dabei zwei Zwecke gleichzeitig. Erstens wechselt es den kompletten Arbeitskontext, alle Fenster des Projekts sind sofort da. Zweitens erfasst [ManicTime](https://www.manictime.com), womit ich meine Arbeitszeit tracke, den jeweils aktiven Desktop. In der Tagesansicht kann ich später präzise nachvollziehen, wann und wie lange ich an welchem Projekt gearbeitet habe.

Damit das sauber funktioniert, muss ich jederzeit sehen, auf welchem Desktop ich gerade bin. Früher ist es mir öfter passiert, dass ich eine Aufgabe versehentlich auf dem falschen Desktop erledigt habe, was die spätere Auswertung verfälscht und Nacharbeit bedeutet. DeskTabs löst das: eine dauerhaft sichtbare Leiste zeigt den aktiven Desktop, und ein direkter Klick wechselt dorthin, statt sich mit dem Windows-Shortcut durchzuschalten. So lande ich immer im richtigen Kontext, und die Zeit wird dem richtigen Projekt zugeordnet.

---

## Was es kann

- **Live-Namen aus Windows:** die Button-Beschriftung kommt direkt aus den in Windows benannten Desktops (Task-Ansicht). Nichts wird doppelt gepflegt.
- **Dynamisch:** Desktop hinzufügen/entfernen in Windows → die Leiste passt sich innerhalb ~1,2 s automatisch an (oder Tray → „Leiste neu aufbauen").
- **Direktsprung:** Ein Klick springt in einem Schritt zum Ziel-Desktop (~100 ms), ohne die Desktops dazwischen durchzuschalten. Auf 25H2 (26200) gemessen: Das fokussierte Fenster bleibt liegen; nimmt ein Build es doch mit, schiebt DeskTabs es sofort zurück. Der schrittweise Wechsel (`Win+Strg+Pfeil`) bleibt über den Menüpunkt „Direkt springen“ verfügbar.
- **Auf allen Desktops sichtbar:** das Fenster ist an alle Desktops gepinnt.
- **Hell/Dunkel automatisch:** folgt dem Windows-Theme (Taskleisten-Helligkeit), umschaltbar oder fest einstellbar.
- **Index-Präfix:** „3 · Projektname" (abschaltbar).
- **Farbcodierung:** dünner Farbbalken pro Desktop (Tab-Indikator-Stil, abschaltbar, pro Desktop überschreibbar). *Farbe aus dem Symbol übernehmen* liest die Hauptfarbe aus einem geholten Seiten-Symbol und setzt sie für diesen Desktop.
- **Symbol-Bibliothek:** eingebautes Auswahlfenster über die komplette Windows-11-Schrift `Segoe Fluent Icons` (1500+ Symbole), durchsuchbar auf Deutsch und Englisch, mit Schnellfiltern und rollbarem Raster. Bibliotheks-Symbole erscheinen in der Farbe des Desktops und stehen als `[Icons] Desktopname = glyph:E713` in der Datei.
- **Symbole pro Tab:** Symbol von einer Webseite holen (DeskTabs sucht das Seiten-Symbol in der bestmöglichen Auflösung und legt es im Zwischenspeicher ab) oder eigene Bilddatei wählen. Rechtsklick auf den Tab → *Symbol*, oder in der `settings.ini`: `[Icons] Desktopname = URL oder Pfad`. Die Domain genügt, `https://www.` ist nicht nötig.
- **Fluent-Optik:** abgerundete Tabs, aktiver Desktop getönt in seiner eigenen Farbe (Farbton bleibt, Helligkeit kommt vom Farbschema), dezente senkrechte Verläufe, Hover hellt auf wie bei den Windows-Taskleisten-Buttons. Der aktive Stil ist umschaltbar: eigene Desktop-Farbe, einheitliche Akzentfarbe oder kräftige Füllung.
- **Klick auf aktiven Desktop:** öffnet die Task-Ansicht (Win+Tab).
- **Vollbild-Auto-Hide:** blendet sich aus, solange auf dem Monitor der Leiste eine Vollbild-App ganz oben liegt (ein Vollbild-Video auf einem anderen Monitor blendet sie nicht aus; eine Vollbild-App bleibt respektiert, auch wenn der Fokus auf einen anderen Monitor wandert).
- **Kompakt-Stufen:** `full` / `short` / `icon`, automatisch nach verfügbarer Breite oder manuell per **Strg + Mausrad** über der Leiste; mit optionalen Kürzeln pro Desktop. Passt so auch auf schmale Laptop-Taskleisten.
- **Eingebautes Zeit-Log:** schreibt, wie lange Du auf welchem Desktop warst, in eine Monats-CSV (`desktop-log_YYYY-MM.csv`); pausiert bei gesperrtem Bildschirm und nach 5 Minuten ohne Eingabe. Für alle ohne Time-Tracker, und für Coding-Agenten, die daraus die Abrechnung machen. Siehe [Zeit-Log](#zeit-log).
- **Rechtsklick-Menü:** Rechtsklick auf einen Tab für Kürzel und Farbe, dazu alle App-Einstellungen (Nummern, Farbcodierung, Ansichtsstufe, Farbschema, Andocken, Einrasten, Zeit-Log, Sprache). Kein Editieren von Dateien nötig; alles landet in `settings.ini`. Das Tray-Symbol zeigt dasselbe Menü direkt.
- **Hilfe-Menü:** Dokumentation, Änderungsverlauf, Fehler melden und Wunsch einreichen (öffnet ein vorausgefülltes GitHub-Issue), E-Mail an den Autor, Update-Prüfung und *Über DeskTabs* (Version, Lizenz, Links).
- **Update-Prüfung:** einmal täglich fragt DeskTabs die GitHub-Releases-API nach der aktuellen Versionsnummer (mehr wird nicht übertragen) und zeigt bei einer neueren Version einen Tray-Hinweis. Abschaltbar im Hilfe-Menü oder per `UpdateCheck = 0`.
- **Live-Konfiguration:** Änderungen an `settings.ini` (Kürzel, Farben, Stufe) werden innerhalb von ~1,2 s übernommen, ohne Neustart. Praktisch, wenn Dein KI-Agent die Leiste für Dich einrichtet.
- **Mausrad** über der Leiste blättert durch die Desktops.
- **Trennstriche** zwischen den Tabs (standardmäßig aus, umschaltbar).
- **Verschiebbar** am Griff `≡` links; Position wird in `settings.ini` gemerkt.

---

## Voraussetzungen

- **Windows 11:** entwickelt und getestet auf **25H2 (Build 26200)**. Funktioniert ab 24H2 (26100).
- **AutoHotkey v2** (getestet mit 2.0.26), Standardpfad `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`.
- **VirtualDesktopAccessor.dll** (liegt im Repo bei), von [Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor), Release `2024-12-16-windows11`.

---

## Installation & Start

### Variante A: sofort startklar (ohne AutoHotkey)

1. Die neueste `DeskTabs-vX.Y.Z.zip` von der [Releases-Seite](https://github.com/paehtz/DeskTabs/releases/latest) herunterladen.
2. Irgendwohin entpacken und den Ordner zusammenlassen: `DeskTabs.exe`, `VirtualDesktopAccessor.dll`, `lang\` und `data\`.
3. Doppelklick auf `DeskTabs.exe`. Beim ersten Start meldet sich DeskTabs kurz und zeigt auf das Rechtsklick-Menü.

**Windows SmartScreen** meldet beim ersten Start eventuell „Der Computer wurde durch Windows geschützt“, weil die Datei nicht signiert ist (ein Zertifikat kostet jährlich Geld, das Werkzeug ist kostenlos). Auf **Weitere Informationen → Trotzdem ausführen** klicken. Wer einer unsignierten Datei nicht vertrauen möchte, nimmt Variante B mit dem Skript oder kompiliert die exe mit Ahk2Exe selbst.

Oder per Einzeiler installieren (und aktualisieren) in PowerShell:

```powershell
irm https://raw.githubusercontent.com/paehtz/DeskTabs/main/setup.ps1 | iex
```

Das installiert nach `%LOCALAPPDATA%\DeskTabs`, legt einen Autostart-Eintrag an und startet DeskTabs. Erneut ausführen aktualisiert; `settings.ini`, Symbol-Zwischenspeicher und Zeit-Logs bleiben erhalten. Schalter: `-NoAutostart`, `-NoLaunch`, `-Uninstall`.

### Deinstallieren

```powershell
.\setup.ps1 -Uninstall
```

Stoppt DeskTabs, entfernt die Autostart-Verknüpfung und den Programmordner und fragt, ob Einstellungen, Symbole und Zeit-Logs erhalten bleiben sollen (sie wandern dann in einen Ordner unter `%TEMP%`). DeskTabs schreibt nichts in die Registry und legt nichts außerhalb seines Ordners ab — bei einer Installation von Hand genügt es also, den Ordner zu löschen.

Das installiert DeskTabs nach `%LOCALAPPDATA%\DeskTabs`, legt einen Autostart-Eintrag an und startet es. Erneut ausführen aktualisiert auf die neueste Version.

> Hinweis: Eine mit AutoHotkey kompilierte `.exe` kann bei manchen Virenscannern Fehlalarme auslösen. Deshalb gibt es immer beides, die `.exe` und den vollständigen Quellcode; Du kannst stattdessen jederzeit aus dem Quellcode starten.

### Variante B: aus dem Quellcode

1. Repo klonen oder als ZIP herunterladen und in einen Ordner Deiner Wahl entpacken.
2. [AutoHotkey v2](https://www.autohotkey.com/) installieren (falls noch nicht vorhanden).
3. Doppelklick auf `DeskTabs.ahk` (öffnet mit AHK v2), oder per Kommandozeile:

```
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" "<Pfad-zum-Ordner>\DeskTabs.ahk"
```

**Autostart:** Eine Verknüpfung in den Autostart-Ordner legen
(`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\`)
→ Ziel: `AutoHotkey64.exe`, als Argument der Pfad zu `DeskTabs.ahk`.

**Beenden / Steuern:** Tray-Icon (DeskTabs-Symbol) → Rechtsklick: das komplette Einstellungsmenü, Hilfe (Doku, Feedback, Updates, Über), Leiste neu aufbauen, Position zurücksetzen, Beenden.

---

## Konfiguration

> **Du nutzt einen KI-Coding-Agenten (z.B. Claude Code)?** Forke das Repo und sieh Dir [CLAUDE.md](CLAUDE.md) an: Sie erklärt Deinem Agenten, wie er DeskTabs startet, validiert und sicher an Dein Setup anpasst.

Alle Optionen stehen im `CONF`-Block ganz oben in `DeskTabs.ahk`:

| Option | Default | Bedeutung |
|---|---|---|
| `DockMode` | `on` | `on` = auf der Taskleiste (optisch integriert, kann beim Fensterwechsel minimal flackern). `above` = knapp über der Taskleiste (flackerfrei, überlagert aber die unterste Fensterkante). |
| `ThemeMode` | `auto` | `auto` = folgt dem Windows-Theme (Taskleisten-Helligkeit via Registry `SystemUsesLightTheme`). `light` / `dark` = fest. Wechsel zur Laufzeit wird automatisch erkannt (~1,2 s) und die Leiste neu gebaut. |
| `OffsetX` | 10 | Abstand vom linken Bildschirmrand (px). |
| `ShowIndex` | 1 | Nummern-Präfix („3 · …"). |
| `ColorCoding` | 1 | Farbbalken pro Desktop. |
| `AccentBarH` | 3 | Höhe des Farbbalkens (px). |
| `AutoHideFullscreen` | 1 | Bei Vollbild-App ausblenden. |
| `ClickActiveTaskView` | 1 | Klick auf aktiven Desktop öffnet Win+Tab. |
| `WheelSwitch` | 1 | Mausrad blättert Desktops. |
| `Palette` | 8 Farben | Farbpalette für die Farbcodierung (nach Index). |
| `FontSizePt` | 10 | Schriftgröße. |
| `MaxNameLen` | 22 | Namen länger als das werden gekürzt (Stufe `full`). |
| `CompactMode` | `auto` | Label-Stufe: `full` (Nummer + Name), `short` (Nummer + Kürzel bzw. gekürzter Name), `icon` (nur Kürzel bzw. Nummer). `auto` startet bei `full` und schaltet runter, bis die Leiste in `MaxBarWidthPct` der Taskleistenbreite passt, funktioniert so auch auf schmalen Laptop-Taskleisten. **Strg + Mausrad** über der Leiste schaltet manuell durch (nach oben über `full` hinaus wieder `auto`); die Wahl wird in `settings.ini` `[View]` gemerkt. |
| `MaxBarWidthPct` | 40 | Nur `auto`: maximaler Anteil der Taskleistenbreite, bevor eine Stufe runtergeschaltet wird. |
| `ShortNameLen` | 8 | Stufe `short`: Namen länger als das werden gekürzt (wenn kein Kürzel hinterlegt ist). |
| `TimeLog` | 1 | Aufenthaltszeiten pro Desktop in `desktop-log_YYYY-MM.csv` neben dem Skript schreiben. `0` = aus. |
| `TimeLogIdleMin` | 5 | Minuten ohne Tastatur-/Mauseingabe, nach denen der laufende Aufenthalt geschlossen wird (zählt als Pause). Bildschirmsperre schließt ihn immer. |
| `UpdateCheck` | 1 | 1 = einmal täglich die GitHub-Releases-API nach einer neueren Version fragen (nur die Versionsnummer wird gelesen). Auch im Hilfe-Menü schaltbar; landet in `[View] UpdateCheck`. |
| `ActiveStyle` | `desktop` | Füllung des aktiven Tabs: `desktop` = eigene Desktop-Farbe, `accent` = einheitliche Akzentfarbe, `solid` = kräftige Füllung. |
| `TintL` / `TintS` | 88 / 100 (hell), 30 / 70 (dunkel) | Helligkeit und Sättigung (%) des getönten aktiven Tabs. Höheres `TintL` = zarter, niedrigeres = kräftiger. |
| `GradientPct` | 14 | Stärke des senkrechten Verlaufs in gefüllten Tabs, `0` = flach. |
| `HoverPct` | 58 (hell), 12 (dunkel) | Wie stark ein Tab beim Drüberfahren aufhellt. |
| `CornerRadius` | 4 | Eckenradius der Tabs (wie die Windows-11-Taskleisten-Buttons). |
| `ShowIcons` | 1 | Symbole aus `[Icons]` in den Tabs anzeigen. |
| `IconSize` / `IconGap` | 16 / 7 | Symbolgröße und Abstand zwischen Symbol und Text. |
| `ShowDividers` | 0 | Dünne Trennstriche zwischen den Tabs. |
| `SwitchMethod` | `dll` | `dll` = direkt zum Desktop springen, `native` = `Win+Strg+Pfeil` schrittweise nachbilden. |
| `Language` | `auto` | Oberflächensprache: `auto` folgt der Windows-Anzeigesprache (Deutsch → `de`, alles andere → `en`), oder `de` / `en` fest. Jeder andere Code lädt `lang\<code>.ini`. Auch in `settings.ini` `[View] Language=` setzbar. Wirkt nach Neustart. |
| Farben | auto | `ColBarBg`, `ColInactiveBg/Tx`, `ColActiveBg/Tx`, `ColHoverBg/Tx`, `ColDivider` werden beim Start aus `THEME_LIGHT` / `THEME_DARK` (je nach `ThemeMode`) in die CONF übernommen. Anpassen → die beiden `THEME_*`-Maps oben im Skript. |

### settings.ini (wird automatisch angelegt)

```ini
[Position]
X=10
Y=1392

[Colors]
; Farbcodierung pro Desktop-Name überschreiben (RRGGBB):
Design=E5471D
Buchhaltung=1565C0

[Short]
; Kürzel pro Desktop-Name für die Kompakt-Stufen
; (short: "4 · BPH", icon: "BPH" statt nur der Nummer):
Acme Bakery=ACME
Buchhaltung=BH

[View]
; Wird vom Rechtsklick-Menü (und Strg + Mausrad) geschrieben; jeder Schlüssel
; überschreibt den CONF-Standard: CompactMode, ThemeMode, DockMode, Language,
; ShowIndex, ColorCoding, SnapToTaskbar, TimeLog
CompactMode=short
ShowIndex=1
```

---

## Sprachen

DeskTabs spricht von Haus aus Deutsch und Englisch und wählt die Sprache nach Deiner Windows-Anzeigesprache. Eine weitere Sprache ergänzt Du, indem Du `lang\en.ini` nach `lang\<code>.ini` kopierst (z.B. `lang\fr.ini`), die Zeilen übersetzt (`schlüssel=Text`, Platzhalter `{1}` stehen lassen, `\n` ist ein Zeilenumbruch, Datei ist UTF-8) und in `settings.ini` unter `[View]` `Language=fr` setzt. Pull Requests mit neuen Sprachen sind willkommen.

---

## Zeit-Log

Mit `TimeLog=1` (Standard) schreibt DeskTabs pro Aufenthalt auf einem Desktop eine Zeile in `desktop-log_YYYY-MM.csv` neben dem Skript:

```csv
start,end,seconds,desktop_index,desktop_name
2026-09-22T09:02:11,2026-09-22T10:47:30,6319,4,"Acme Bakery"
2026-09-22T10:47:30,2026-09-22T11:15:02,1652,2,"Miller & Sons"
```

- Ein Aufenthalt endet beim Desktop-Wechsel, beim Sperren des Bildschirms oder nach `TimeLogIdleMin` Minuten ohne Eingabe (dann wird er rückwirkend zum Beginn der Inaktivität geschlossen, Pausen zählen also nicht mit).
- Zeiten sind lokal, ISO 8601. `desktop_index` ist 1-basiert wie die Nummern in der Leiste; `desktop_name` ist der Name beim Start des Aufenthalts.
- Die Datei ist reines UTF-8-CSV: in Excel öffnen, oder einen Coding-Agenten die Zeiten pro Kunde für die Rechnung aufsummieren lassen. Es sind persönliche Daten, die Datei ist git-ignoriert.

---

## Wie es funktioniert (Architektur)

- **Lesen der Desktops** über `VirtualDesktopAccessor.dll` (in-process, schnell): `GetDesktopCount`, `GetCurrentDesktopNumber`, `GetDesktopName`, `PinWindow`, `RegisterPostMessageHook`.
- **Wechseln** über die DLL in einem Schritt (`SwitchMethod=dll`), mit Sicherheitsnetz: Nimmt ein Windows-Build das Vordergrundfenster mit, schiebt DeskTabs es zurück; `native` bildet stattdessen die Tastenkürzel nach.
- **Live-Update der Hervorhebung** via `RegisterPostMessageHook` (Desktop-Wechsel-Benachrichtigung) + 1,2-s-Fallback-Timer (`Refresh`), der auch Desktop-Anzahl/Namen aktualisiert und die Leiste bei Bedarf neu baut.
- **Immer im Vordergrund** (`DockMode=on`): Kombination aus
  - `SetWinEventHook(EVENT_SYSTEM_FOREGROUND)` → bei jedem Fensterwechsel sofort `AssertTop()`,
  - kurzer **Burst** (10× alle 25 ms) zum Abdecken von Maximier-Animationen,
  - 250-ms-Backstop-Timer.
- **Fenster** ist `-Caption +AlwaysOnTop +ToolWindow +E0x08000000` (WS_EX_NOACTIVATE → Klicks klauen nicht den Fokus vom Arbeitsfenster) und an alle Desktops gepinnt.
- **Theme** wird über die Registry erkannt (`SystemUsesLightTheme` unter `…\Themes\Personalize`, derselbe Wert, der die Taskleisten-Helligkeit steuert). `ApplyTheme()` kopiert den passenden Satz (`THEME_LIGHT`/`THEME_DARK`) in die CONF-Farbschlüssel; der `Refresh`-Timer erkennt einen Theme-Wechsel und baut die Leiste neu.

---

## Erkenntnisse / Stolpersteine (für künftige Wartung)

- **25H2-Kompatibilität:** Die Ciantic-DLL ist mit „24H2" gelabelt, läuft aber auf 25H2 (26200) einwandfrei. Bei einem Windows-Feature-Update, das die Virtual-Desktop-COM-VTable ändert, kann die DLL brechen → dann neue Version von Ciantics Repo holen.
- **`GoToDesktopNumber` und das Vordergrundfenster:** Auf 24H2 nutzt die DLL intern `switch_desktop_and_move_foreground_view` und nahm das fokussierte Fenster mit auf den Ziel-Desktop. Auf 25H2 (26200) mit einem Vordergrundfenster aus einem fremden Prozess nachgemessen: passiert nicht mehr, deshalb ist der Direktsprung Standard. DeskTabs prüft trotzdem nach jedem Sprung und schiebt das Fenster notfalls zurück. `SwitchMethod=native` stellt den alten Tastenkürzel-Nachbau wieder her.
- **`&` im Desktop-Namen:** AHK-Text-Controls interpretieren `&` als Tastenkürzel-Markierung. Lösung: Style `SS_NOPREFIX` (`+0x80`) auf die Buttons, das zeigt `&` wörtlich (z.B. „M&S").
- **z-Order der Farbbalken/Trennstriche:** Überlappende Controls werden vom Button verdeckt. Deshalb liegen Trennstriche in den Lücken und Farbbalken **unter** dem Button (überlappungsfrei).
- **AHK-Semikolon-Falle:** Ein `;` ohne Leerzeichen davor ist KEIN Kommentar, sondern wirft „Illegal character in expression". Inline-Kommentare immer mit Leerzeichen vor `;`.
- **DockMode-Abwägung:** `on` (auf der Taskleiste) sieht integrierter aus, kämpft aber mit der Taskleiste um die z-Order (kurzes Flackern beim Fensterwechsel trotz WinEvent-Hook + Burst). `above` (knapp darüber) ist flackerfrei, überlagert aber die unterste Fensterkante.
- **Multi-Monitor:** Die Leiste sitzt immer auf der **Primär-Taskleiste** (`Shell_TrayWnd`) und folgt automatisch, wenn sich der Primärmonitor in Windows ändert. Sekundäre Taskleisten (`Shell_SecondaryTrayWnd`) werden nicht bespielt.
- **DLL-Funktionsumfang:** `VirtualDesktopAccessor.dll` bietet KEINE Funktion zum Umsortieren von Desktops (geprüfte Exports u.a. `GetDesktopCount`, `GetCurrentDesktopNumber`, `GetDesktopName`, `GoToDesktopNumber`, `MoveWindowToDesktopNumber`, `PinWindow`, `RegisterPostMessageHook`, aber kein `MoveDesktop`). Fürs Umsortieren müsste [MScholtes/VirtualDesktop](https://github.com/MScholtes/VirtualDesktop) her.

---

## Ideen für die Zukunft

- **Rest-Flackern in `DockMode=on` final lösen:** dauerhaft auf der Taskleiste ohne Zucken beim Fensterwechsel. Ansätze: zusätzliche WinEvents (`EVENT_OBJECT_REORDER`, `EVENT_SYSTEM_MINIMIZEEND`), dichterer Burst, oder die Leiste als Kind der Taskleiste (`SetParent`). Aktueller Standard-Workaround: `DockMode=above` (flackerfrei).
- **Drag-to-Reorder** der Buttons mit echter Windows-Umsortierung über [MScholtes/VirtualDesktop](https://github.com/MScholtes/VirtualDesktop).

---

## Über dieses Projekt

DeskTabs ist KI-unterstützt mit [Claude Code](https://claude.com/claude-code) entstanden. Mein Hintergrund liegt in Strategie, Design und Konzeption, nicht in klassischer Softwareentwicklung: Programmiererfahrung hatte ich vor allem aus Templatesprachen, HTML und CSS. Mit KI-gestütztem Arbeiten setze ich eigene Ideen heute direkt in funktionierende Werkzeuge um. DeskTabs ist eines davon und zugleich ein praktisches Beispiel für genau das, was ich als KI-Beratung an Unternehmen weitergebe.

## Lizenz

DeskTabs steht unter der [MIT-Lizenz](LICENSE) © Henning Pähtz.

**Haftungsausschluss:** DeskTabs wird „wie besehen" bereitgestellt, ohne jede Gewährleistung und ohne Haftung, wie in der MIT-Lizenz festgehalten. Nutzung auf eigenes Risiko.

### Drittkomponenten

- **VirtualDesktopAccessor.dll** ([Ciantic](https://github.com/Ciantic/VirtualDesktopAccessor)) ist unter der **MIT-Lizenz** beigelegt.
- Die kompilierte **`DeskTabs.exe`** (in den Releases) bettet den **AutoHotkey**-Interpreter ein, der unter **GPL-2.0** steht. Die kompilierte exe wird daher unter GPL-2.0 verteilt; der Skript-Quellcode liegt in diesem Repo, der AutoHotkey-Quellcode auf der [Projektseite](https://github.com/AutoHotkey/AutoHotkey). Beim Start aus dem Quellcode (`DeskTabs.ahk`) wird AutoHotkey nicht mitgeliefert.

Vollständige Hinweise: [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).

---

## Autor

**Henning Pähtz:** Diplom-Medienwissenschaftler aus Lutherstadt Eisleben. Webdesign, Markenstrategie, KI-Beratung und Prozessautomatisierung.

🌐 [paehtz.de](https://paehtz.de) · ✉️ henning@paehtz.de

---

## Credits

- [Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor): DLL für den Zugriff auf die Windows-Virtual-Desktop-API.
- [AutoHotkey v2](https://www.autohotkey.com/)
