#Requires AutoHotkey v2.0
#SingleInstance Force
;@Ahk2Exe-SetMainIcon DeskTabs.ico
;@Ahk2Exe-SetName DeskTabs
;@Ahk2Exe-SetDescription DeskTabs - clickable taskbar buttons for Windows 11 virtual desktops
;@Ahk2Exe-SetCopyright Henning Pähtz (MIT License)
;@Ahk2Exe-SetVersion 1.1.0.0
; ============================================================================
;  DeskTabs  —  klickbare Buttons fuer virtuelle Desktops (Win 11)
;  Von Henning Pähtz (paehtz.de), baut auf Ciantic/VirtualDesktopAccessor.dll
;  MIT License
;  Stand: 2026-06-04
; ----------------------------------------------------------------------------
;  - Liest Desktop-Namen LIVE aus Windows (in Windows benannt, nichts doppelt)
;  - Aktiver Desktop wird hervorgehoben
;  - Linksklick auf einen Button  -> dorthin wechseln
;  - Mausrad ueber der Leiste     -> vor/zurueck blaettern
;  - Ziehen am Griff (links)      -> Leiste verschieben (Position wird gemerkt)
;  - Liegt auf allen Desktops (an alle angepinnt), immer sichtbar
; ============================================================================

; ------------------------------ Programm ------------------------------------
; Versionsnummer: bei jedem Release zusammen mit ;@Ahk2Exe-SetVersion oben anheben.
global APP_VERSION := "1.1.0"
global APP_URL      := "https://github.com/paehtz/DeskTabs"
global APP_DOCS_URL := Map("en", APP_URL "#readme", "de", APP_URL "/blob/main/README.de.md")  ; spaeter: paehtz.de/desktabs
global APP_CHANGELOG_URL := APP_URL "/releases"
global APP_AUTHOR   := "Henning Pähtz"
global APP_AUTHOR_URL := "https://www.paehtz.de"
global APP_MAIL     := "henning@paehtz.de"
global APP_API_LATEST := "https://api.github.com/repos/paehtz/DeskTabs/releases/latest"
global gUpdateTag := ""      ; neuere Version laut GitHub ("v1.2.0"), leer = keine bekannt
global gAbout := ""          ; offenes "Ueber"-Fenster (Gui) oder ""

; ---------------------------- Konfiguration ---------------------------------
global CONF := Map(
    "DllPath",        A_ScriptDir "\VirtualDesktopAccessor.dll",
    "IniPath",        A_ScriptDir "\settings.ini",
    "FontName",       "Segoe UI",
    "FontSizePt",     10,
    "PadX",           18,      ; Innenabstand links/rechts im Tab (px @100%)
    "Gap",            4,       ; Abstand zwischen den Tabs (px @100%), wie zwischen Taskleisten-Buttons
    "GripW",          16,      ; Breite des Ziehgriffs (px @100%)
    "SwitchMethod",   "dll",   ; "dll"    = Direktsprung per GoToDesktopNumber (Standard, ohne Zwischen-Desktops)
                               ; "native" = Strg+Win+Pfeil nachbilden, Desktop fuer Desktop (Fallback; Menue "Direkt springen")
    "ColDivider",     0xCFCFCF, ; Trennstrich-Farbe (sanft, Material)
    "DividerInsetY",  9,       ; vertikaler Abstand des Trennstrichs oben/unten (px @100%)
    "DockMode",       "on",    ; "on"    = auf der Taskleiste (optisch integriert, kann minimal flackern)
                               ; "above" = direkt ueber der Taskleiste (flackerfrei)
    "OffsetX",        10,      ; Abstand vom linken Bildschirmrand (px @100%)
    "SnapToTaskbar",  1,       ; 1 = beim Ziehen vertikal auf die Taskleiste einrasten (X bleibt frei)
    "SnapDistance",   40,      ; zusaetzl. Fang-Abstand (px @100%) ueber der Taskleiste; auf der Taskleiste haelt es ohnehin (Ueberlappung)
    "ThemeMode",      "auto",  ; "auto" = Windows-Theme folgen (Taskleisten-Helligkeit), "light", "dark"
    ; Farben (werden beim Start je nach Theme aus THEME_LIGHT/THEME_DARK ueberschrieben).
    ; Die Werte hier sind der HELLE Standard und dienen als Fallback.
    "ColBarBg",       0xE9E9E9, ; Leisten-Hintergrund (passt an helle Taskleiste)
    "ColInactiveBg",  0xE9E9E9, ; inaktive Buttons: blenden mit der Leiste
    "ColInactiveTx",  0x1F1F1F, ; dunkler Text
    "ColActiveBg",    0x0078D4, ; aktiver Button: Windows-Akzentfarbe
    "ColActiveTx",    0xFFFFFF, ; weisser Text auf Akzent
    "ColGripBg",      0xE9E9E9,
    "ColGripTx",      0x909090,
    "WheelSwitch",    1,       ; 1 = Mausrad blaettert Desktops, 0 = aus
    "ShowIndex",      1,       ; 1 = Nummer vor dem Namen ("3 · Acme Bakery")
    "ColorCoding",    1,       ; 1 = farbiger Akzentbalken pro Desktop unten am Button
    "AccentBarH",     3,       ; Hoehe des Farbbalkens (px @100%)
    "ActiveStyle",    "desktop", ; aktiver Tab: "desktop" = eigene Desktop-Farbe, getoent | "accent" = Windows-Akzentfarbe, getoent | "solid" = kraeftig gefuellt
    "TintL",          88,      ; Helligkeit (%) des getoenten aktiven Tabs - Farbton bleibt, nur heller (je Theme ueberschrieben)
    "TintS",          100,     ; Anteil (%) der Original-Saettigung im getoenten Tab
    "CornerRadius",   4,       ; Eckenradius der Tabs (px @100%), wie Windows-11-Taskleisten-Buttons
    "TabMargin",      4,       ; Abstand der Tabs zum oberen/unteren Rand der Leiste (px @100%)
    "ShowDividers",   0,       ; 1 = duenne Trennstriche zwischen den Tabs
    "ShowIcons",      1,       ; 1 = Symbole aus settings.ini [Icons] im Tab zeigen
    "IconSize",       18,      ; Kantenlaenge des Symbols neben dem Text (px @100%)
    "IconOnlySize",   24,      ; Kantenlaenge in der Stufe "nur Symbol" (px @100%), wie die Taskleisten-Symbole
    "IconGap",        7,       ; Abstand zwischen Symbol und Text (px @100%)
    "IconFont",       "Segoe Fluent Icons",  ; Symbolschrift von Windows 11 (Fallback: Segoe MDL2 Assets)
    "ColHoverBg",     0xFFFFFF, ; Hover-Farbe: wird mit HoverPct ueber den Leistengrund gelegt (Windows hellt auf)
    "ColHoverTx",     0x1F1F1F,
    "HoverPct",      58,      ; Deckkraft (%) der Hover-Aufhellung; je Theme ueberschrieben
    "GradientPct",   14,      ; Staerke des senkrechten Verlaufs in gefuellten Tabs (0 = flach), wie bei Fluent-Buttons
    "AutoHideFullscreen", 1,   ; 1 = Leiste ausblenden, wenn Vollbild-App im Vordergrund
    "ClickActiveTaskView", 1,  ; 1 = Klick auf aktiven Desktop oeffnet Task-Ansicht (Win+Tab)
    "Palette",        [0xE5471D, 0x2E7D32, 0x1565C0, 0x6A1B9A, 0xEF6C00, 0x00838F, 0xC2185B, 0x558B2F],
    "MaxNameLen",     22,      ; Stufe "full": Namen laenger als das werden gekuerzt
    "CompactMode",    "auto",  ; "auto" = Stufe nach Platz waehlen | "full" | "short" | "icon" (fest)
    "MaxBarWidthPct", 40,      ; auto: max. Anteil der Taskleistenbreite, bevor eine Stufe runtergeschaltet wird
    "ShortNameLen",   8,       ; Stufe "short": Namen laenger als das werden gekuerzt
    "TimeLog",        1,       ; 1 = Aufenthaltszeit pro Desktop als CSV protokollieren (desktop-log_YYYY-MM.csv)
    "TimeLogIdleMin", 5,       ; nach so vielen Minuten ohne Eingabe gilt "Pause": Segment wird geschlossen
    "Language",       "auto",  ; "auto" = Windows-Anzeigesprache | "de" | "en" | Code einer lang\xx.ini
    "UpdateCheck",    1        ; 1 = einmal taeglich bei GitHub nach einer neueren Version fragen (nur Versionsnummer, keine Daten)
)

; ---- Theme-Farbsaetze (werden je nach Windows-Theme in CONF uebernommen) ----
; Die Palette (Farbbalken pro Desktop) bleibt fuer beide Themes gleich.
global THEME_LIGHT := Map(
    "ColBarBg",      0xE9E9E9,
    "ColInactiveBg", 0xE9E9E9,
    "ColInactiveTx", 0x1F1F1F,
    "ColActiveBg",   0x0078D4,
    "ColActiveTx",   0xFFFFFF,
    "ColGripBg",     0xE9E9E9,
    "ColGripTx",     0x909090,
    "TintL",         88,        ; hell: klarer Pastellton in der Desktop-Farbe
    "TintS",         100,
    "ColHoverBg",    0xFFFFFF,   ; hell: Weiss ueber den Grund -> Tab wird heller
    "HoverPct",      58,
    "ColHoverTx",    0x1F1F1F,
    "ColDivider",    0xCFCFCF
)
global THEME_DARK := Map(
    "ColBarBg",      0x202020,   ; dunkle Win-11-Taskleiste
    "ColInactiveBg", 0x202020,
    "ColInactiveTx", 0xE6E6E6,   ; heller Text
    "ColActiveBg",   0x0078D4,   ; Akzentfarbe (liest sich auf dunkel gut)
    "ColActiveTx",   0xFFFFFF,
    "ColGripBg",     0x202020,
    "ColGripTx",     0x808080,
    "TintL",         30,        ; dunkel: ruhiger, dunkler Ton derselben Farbe
    "TintS",         70,
    "ColHoverBg",    0xFFFFFF,   ; dunkel: wenig Weiss -> Tab wird leicht heller
    "HoverPct",      12,
    "ColHoverTx",    0xFFFFFF,
    "ColDivider",    0x3F3F3F
)
global gTheme := ""             ; aktuell angewandtes Theme ("light"/"dark")
global gIniStamp := ""          ; letzte bekannte Aenderungszeit der settings.ini (Live-Reload)
global gSegStart := ""          ; Zeit-Log: Beginn des laufenden Aufenthalts (YYYYMMDDHHMMSS), "" = keins offen
global gSegDesk := -1           ; Zeit-Log: Desktop-Index des laufenden Aufenthalts
global gSegName := ""           ; Zeit-Log: Desktop-Name beim Segmentstart
global gLogPaused := false      ; Zeit-Log: Pause (Bildschirm gesperrt oder laenger inaktiv)

; ------------------------------ Zeit-Log ------------------------------------
; Schreibt pro Aufenthalt auf einem Desktop eine CSV-Zeile (Monatsdatei neben
; settings.ini): start,end,seconds,desktop_index,desktop_name. Gedacht fuer
; Nutzer ohne Time-Tracker und fuer Coding-Agenten, die daraus abrechnen.
LogFile(ts) => A_ScriptDir "\desktop-log_" SubStr(ts, 1, 4) "-" SubStr(ts, 5, 2) ".csv"
IsoTime(ts) => FormatTime(ts, "yyyy-MM-dd'T'HH:mm:ss")
CsvQuote(s) => '"' StrReplace(s, '"', '""') '"'

LogOpen(num) {
    global gSegStart, gSegDesk, gSegName
    if (!CONF["TimeLog"])
        return
    gSegStart := A_Now, gSegDesk := num, gSegName := GetDesktopNameRaw(num)
}

; Laufendes Segment abschliessen. endTime optional (z.B. Beginn einer Pause).
LogClose(endTime := "") {
    global gSegStart, gSegDesk, gSegName
    if (!CONF["TimeLog"] || gSegStart = "")
        return
    end := (endTime = "") ? A_Now : endTime
    secs := DateDiff(end, gSegStart, "Seconds")
    if (secs >= 1) {
        file := LogFile(gSegStart)
        try {
            if !FileExist(file)
                FileAppend("start,end,seconds,desktop_index,desktop_name`n", file, "UTF-8")
            FileAppend(Format("{1},{2},{3},{4},{5}`n", IsoTime(gSegStart), IsoTime(end), secs, gSegDesk + 1, CsvQuote(gSegName)), file, "UTF-8")
        }
    }
    gSegStart := ""
}

; Desktop-Wechsel ins Log uebernehmen (aus UpdateHighlight)
LogDesktop(num) {
    global gSegDesk, gLogPaused
    if (!CONF["TimeLog"] || gLogPaused || num = gSegDesk)
        return
    LogClose()
    LogOpen(num)
}

; Inaktivitaet: laeuft im Refresh-Takt. Nach TimeLogIdleMin Minuten ohne Eingabe
; wird das Segment rueckwirkend zum Beginn der Inaktivitaet geschlossen; bei
; der naechsten Eingabe beginnt ein neues.
LogIdleTick() {
    global gLogPaused
    if (!CONF["TimeLog"])
        return
    idleMs := A_TimeIdle
    thr := CONF["TimeLogIdleMin"] * 60000
    if (!gLogPaused && idleMs >= thr) {
        LogClose(DateAdd(A_Now, -Round(idleMs / 1000), "Seconds"))
        gLogPaused := true
    } else if (gLogPaused && idleMs < thr) {
        gLogPaused := false
        LogOpen(GetCurrentDesktop())
    }
}

; Bildschirm gesperrt/entsperrt (WM_WTSSESSION_CHANGE): Sperre = Pause
OnSessionChange(wParam, lParam, msg, hwnd) {
    global gLogPaused
    if (wParam = 7) {                 ; WTS_SESSION_LOCK
        LogClose()
        gLogPaused := true
    } else if (wParam = 8) {          ; WTS_SESSION_UNLOCK
        gLogPaused := false
        LogOpen(GetCurrentDesktop())
    }
}

; Hat sich settings.ini seit dem letzten Blick geaendert? Erster Aufruf merkt
; sich nur den Stand. Eigene Schreibzugriffe (IniSet) aktualisieren den Stempel
; sofort, damit sie keinen Neuaufbau ausloesen.
SettingsChanged() {
    global gIniStamp
    stamp := ""
    try stamp := FileGetTime(CONF["IniPath"], "M")
    if (gIniStamp = "") {
        gIniStamp := stamp
        return false
    }
    if (stamp = gIniStamp)
        return false
    gIniStamp := stamp
    return true
}

global SCALE := A_ScreenDPI / 96
global VDA := 0
global BTNS := []            ; Array von Maps {ctrl, num}
global gBarDC := 0           ; Speicher-DC mit dem fertig gezeichneten Leistenbild (fuer WM_PAINT)
global gBarBmp := 0          ; zugehoeriges HBITMAP
global gRenderSig := ""      ; Zustand des letzten Renderns (nur bei Aenderung neu zeichnen)
global gGripHover := false   ; Maus ueber dem Ziehgriff?
global gIconCache := Map()   ; Pfad -> geladenes GDI+-Bitmap (einmal laden, oft zeichnen)
global gIconFetch := Map()   ; URLs, die in dieser Sitzung schon geholt wurden
global gLayout := 0          ; Geometrie der aktuellen Leiste (Map)
global gGdipToken := 0
global GUIW := 0, GUIH := 0
global MyGui := 0
global MSG_VD_CHANGED := 0x1400
global gCurrent := -1        ; aktuell aktiver Desktop (fuer Hervorhebung/Hover)
global gHidden := false      ; true, wenn wegen Vollbild ausgeblendet
global gWinEventHook := 0    ; Hook auf Vordergrund-Wechsel (gegen Flackern)
global gWinEventCb := 0
global gBurst := 0           ; Restzahl schneller Re-Asserts nach Fensterwechsel
global gBuilding := false    ; Re-Entrancy-Schutz: laeuft gerade ein BuildBar?
global gSwitching := false   ; laeuft gerade ein Desktop-Wechsel? (gegen Rebuild-Race)
global gCompact := "full"    ; aktuell dargestellte Stufe: "full" | "short" | "icon"
global gTaskbarW := 0        ; Breite der Primaer-Taskleiste (fuer das Breiten-Budget im auto-Modus)

; ------------------------------ Sprache -------------------------------------
; Alle sichtbaren Texte laufen durch T("schluessel", args*). Deutsch und Englisch
; sind eingebaut. Eine Datei lang\<code>.ini (UTF-8, Zeilen "schluessel=Text")
; neben dem Skript ergaenzt oder ueberschreibt Texte, ohne den Code anzufassen.
global LANG_DE := Map(
    "err.dll_missing", "VirtualDesktopAccessor.dll nicht gefunden:`n{1}",
    "err.dll_load",    "Die DLL konnte nicht geladen werden.",
    "tray.rebuild",    "Leiste neu aufbauen",
    "tray.resetpos",   "Position zurücksetzen",
    "tray.exit",       "Beenden",
    "view.tip",        "Ansicht: {1}",
    "view.auto",       "automatisch ({1})",
    "level.full",      "Nummer + Name",
    "level.short",     "Nummer + Kürzel",
    "level.icon",      "nur Kürzel/Nummer",
    "menu.settings",   "Einstellungen…",
    "menu.tab.short",  "Kürzel setzen…",
    "menu.tab.color",  "Farbe",
    "menu.tab.icon",   "Symbol",
    "menu.icon.library", "Aus der Symbol-Bibliothek…",
    "iconlib.title",   "Symbol für „{1}“",
    "iconlib.hint",    "Symbol anklicken. Es erscheint in der Farbe des Desktops. Suchen geht deutsch und englisch.",
    "iconlib.search",  "Suchen, z.B. Kalender, Ordner, Zeit…",
    "iconlib.count",   "{1} Symbole",
    "iconlib.t.files", "Dateien",
    "iconlib.t.time",  "Zeit",
    "iconlib.t.people", "Personen",
    "iconlib.t.comm",  "Nachrichten",
    "iconlib.t.media", "Medien",
    "iconlib.t.data",  "Daten",
    "iconlib.t.system", "System",
    "iconlib.t.places", "Orte",
    "iconlib.none",    "Kein Symbol gefunden.",
    "menu.icon.url",   "Von einer Webseite holen…",
    "menu.icon.file",  "Eigene Bilddatei wählen…",
    "menu.icon.clear", "Symbol entfernen",
    "menu.showicons",  "Symbole anzeigen",
    "prompt.iconurl.title", "Symbol für „{1}“",
    "prompt.iconurl.text", "Adresse der Webseite (leer = Symbol entfernen):",
    "dlg.ok",          "OK",
    "dlg.cancel",      "Abbrechen",
    "prompt.iconfile.title", "Bilddatei für „{1}“ wählen",
    "icon.fetching",   "Symbol wird geholt…",
    "err.icon_fetch",  "Von dieser Adresse konnte kein Symbol geladen werden.",
    "menu.color.custom", "Eigene Farbe…",
    "menu.color.default", "Standardfarbe verwenden",
    "menu.color.fromicon", "Farbe aus dem Symbol übernehmen",
    "err.color_icon",  "Aus diesem Symbol lässt sich keine Farbe ableiten. Das geht nur bei Symbolen von einer Webseite oder aus einer Bilddatei.",
    "color.E5471D",    "Rot",
    "color.2E7D32",    "Grün",
    "color.1565C0",    "Blau",
    "color.6A1B9A",    "Violett",
    "color.EF6C00",    "Orange",
    "color.00838F",    "Petrol",
    "color.C2185B",    "Pink",
    "color.558B2F",    "Olivgrün",
    "menu.showindex",  "Nummern anzeigen",
    "menu.colorcoding", "Farbcodierung",
    "menu.active",     "Aktiver Desktop",
    "menu.active.desktop", "In seiner Desktop-Farbe (getönt)",
    "menu.active.accent", "Einheitlich in Akzentfarbe (getönt)",
    "menu.active.solid", "Einheitlich, kräftig gefüllt",
    "menu.dividers",   "Trennstriche anzeigen",
    "menu.view",       "Ansicht",
    "menu.view.auto",  "Automatisch (nach Platz)",
    "menu.theme",      "Farbschema",
    "menu.theme.auto", "Automatisch (Windows)",
    "menu.theme.light", "Hell",
    "menu.theme.dark", "Dunkel",
    "menu.dock",       "Andocken",
    "menu.dock.on",    "Auf der Taskleiste",
    "menu.dock.above", "Über der Taskleiste",
    "menu.directjump", "Direkt springen (ohne Zwischen-Desktops)",
    "menu.snap",       "An Taskleiste einrasten",
    "menu.timelog",    "Zeit-Log schreiben",
    "menu.language",   "Sprache",
    "menu.language.auto", "Automatisch (Windows)",
    "prompt.short.title", "Kürzel für „{1}“",
    "prompt.short.text", "Kurzname für die Kompakt-Ansicht (leer = keins):",
    "prompt.color.title", "Farbe für „{1}“",
    "prompt.color.text", "Hex-Farbe RRGGBB, z.B. E5471D:",
    "err.color",       "Ungültige Farbe. Bitte sechs Hex-Zeichen, z.B. E5471D.",
    "menu.help",       "Hilfe",
    "menu.help.docs",  "Anleitung und Dokumentation…",
    "menu.help.changelog", "Was ist neu (Änderungsverlauf)…",
    "menu.feedback.bug", "Fehler melden…",
    "menu.feedback.idea", "Idee oder Wunsch einreichen…",
    "menu.feedback.mail", "E-Mail an den Autor…",
    "menu.update.check", "Nach Updates suchen…",
    "menu.update.auto", "Täglich automatisch nach Updates suchen",
    "menu.update.available", "Update {1} verfügbar…",
    "menu.about",      "Über DeskTabs…",
    "about.title",     "Über DeskTabs",
    "about.tagline",   "Klickbare Taskleisten-Buttons für virtuelle Desktops",
    "about.version",   "Version {1}",
    "about.author",    "von {1}",
    "about.license",   "Lizenz: MIT (Quelltext frei verfügbar)",
    "about.components", "Enthält VirtualDesktopAccessor (MIT, Jari Pennanen){1}.`nSymbol-Bibliothek: Schrift „Segoe Fluent Icons“ von Windows; Symbolnamen aus der`nMicrosoft-Dokumentation (CC BY 4.0).",
    "about.ahk",       "und AutoHotkey v2 (GPL-2.0)",
    "about.website",   "Website",
    "about.github",    "Projekt auf GitHub",
    "about.feedback",  "Feedback geben",
    "about.check",     "Nach Updates suchen",
    "about.close",     "Schließen",
    "update.none",     "DeskTabs {1} ist aktuell.",
    "update.found",    "Version {1} ist verfügbar (installiert: {2}).`n`nDownload-Seite öffnen?",
    "update.error",    "Update-Prüfung nicht möglich (keine Verbindung zu GitHub).",
    "update.tip",      "DeskTabs {1} ist verfügbar. Rechtsklick auf die Leiste → Update…",
    "feedback.mail.subject", "DeskTabs: Feedback",
    "feedback.mail.body", "Hallo Henning,`n`n(Fehler, Idee oder Frage hier beschreiben)`n`n"
)
global LANG_EN := Map(
    "err.dll_missing", "VirtualDesktopAccessor.dll not found:`n{1}",
    "err.dll_load",    "The DLL could not be loaded.",
    "tray.rebuild",    "Rebuild bar",
    "tray.resetpos",   "Reset position",
    "tray.exit",       "Exit",
    "view.tip",        "View: {1}",
    "view.auto",       "automatic ({1})",
    "level.full",      "number + name",
    "level.short",     "number + abbreviation",
    "level.icon",      "abbreviation/number only",
    "menu.settings",   "Settings…",
    "menu.tab.short",  "Set abbreviation…",
    "menu.tab.color",  "Colour",
    "menu.tab.icon",   "Icon",
    "menu.icon.library", "From the icon library…",
    "iconlib.title",   "Icon for “{1}”",
    "iconlib.hint",    "Click an icon. It is drawn in the desktop's colour. Search works in English and German.",
    "iconlib.search",  "Search, e.g. calendar, folder, time…",
    "iconlib.count",   "{1} icons",
    "iconlib.t.files", "Files",
    "iconlib.t.time",  "Time",
    "iconlib.t.people", "People",
    "iconlib.t.comm",  "Messages",
    "iconlib.t.media", "Media",
    "iconlib.t.data",  "Data",
    "iconlib.t.system", "System",
    "iconlib.t.places", "Places",
    "iconlib.none",    "No icon found.",
    "menu.icon.url",   "Fetch from a website…",
    "menu.icon.file",  "Choose an image file…",
    "menu.icon.clear", "Remove icon",
    "menu.showicons",  "Show icons",
    "prompt.iconurl.title", "Icon for “{1}”",
    "prompt.iconurl.text", "Website address (empty = removes the icon):",
    "dlg.ok",          "OK",
    "dlg.cancel",      "Cancel",
    "prompt.iconfile.title", "Choose an image file for “{1}”",
    "icon.fetching",   "Fetching icon…",
    "err.icon_fetch",  "No icon could be loaded from that address.",
    "menu.color.custom", "Custom colour…",
    "menu.color.default", "Use default colour",
    "menu.color.fromicon", "Take the colour from the icon",
    "err.color_icon",  "No colour could be derived from this icon. That only works for icons fetched from a website or loaded from an image file.",
    "color.E5471D",    "Red",
    "color.2E7D32",    "Green",
    "color.1565C0",    "Blue",
    "color.6A1B9A",    "Purple",
    "color.EF6C00",    "Orange",
    "color.00838F",    "Teal",
    "color.C2185B",    "Pink",
    "color.558B2F",    "Olive",
    "menu.showindex",  "Show numbers",
    "menu.colorcoding", "Colour coding",
    "menu.active",     "Active desktop",
    "menu.active.desktop", "In its own desktop colour (tinted)",
    "menu.active.accent", "Uniform accent colour (tinted)",
    "menu.active.solid", "Uniform, solid fill",
    "menu.dividers",   "Show dividers",
    "menu.view",       "View",
    "menu.view.auto",  "Automatic (by available space)",
    "menu.theme",      "Theme",
    "menu.theme.auto", "Automatic (Windows)",
    "menu.theme.light", "Light",
    "menu.theme.dark", "Dark",
    "menu.dock",       "Docking",
    "menu.dock.on",    "On the taskbar",
    "menu.dock.above", "Above the taskbar",
    "menu.directjump", "Jump directly (skip desktops in between)",
    "menu.snap",       "Snap to taskbar",
    "menu.timelog",    "Write time log",
    "menu.language",   "Language",
    "menu.language.auto", "Automatic (Windows)",
    "prompt.short.title", "Abbreviation for “{1}”",
    "prompt.short.text", "Short name for the compact levels (empty = none):",
    "prompt.color.title", "Colour for “{1}”",
    "prompt.color.text", "Hex colour RRGGBB, e.g. E5471D:",
    "err.color",       "Invalid colour. Please use six hex digits, e.g. E5471D.",
    "menu.help",       "Help",
    "menu.help.docs",  "Guide and documentation…",
    "menu.help.changelog", "What's new (changelog)…",
    "menu.feedback.bug", "Report a bug…",
    "menu.feedback.idea", "Suggest an idea or feature…",
    "menu.feedback.mail", "E-mail the author…",
    "menu.update.check", "Check for updates…",
    "menu.update.auto", "Check for updates daily",
    "menu.update.available", "Update {1} available…",
    "menu.about",      "About DeskTabs…",
    "about.title",     "About DeskTabs",
    "about.tagline",   "Clickable taskbar buttons for virtual desktops",
    "about.version",   "Version {1}",
    "about.author",    "by {1}",
    "about.license",   "License: MIT (source code freely available)",
    "about.components", "Includes VirtualDesktopAccessor (MIT, Jari Pennanen){1}.`nIcon library: the Windows font “Segoe Fluent Icons”; icon names from the`nMicrosoft documentation (CC BY 4.0).",
    "about.ahk",       "and AutoHotkey v2 (GPL-2.0)",
    "about.website",   "Website",
    "about.github",    "Project on GitHub",
    "about.feedback",  "Give feedback",
    "about.check",     "Check for updates",
    "about.close",     "Close",
    "update.none",     "DeskTabs {1} is up to date.",
    "update.found",    "Version {1} is available (installed: {2}).`n`nOpen the download page?",
    "update.error",    "Could not check for updates (no connection to GitHub).",
    "update.tip",      "DeskTabs {1} is available. Right-click the bar → Update…",
    "feedback.mail.subject", "DeskTabs: feedback",
    "feedback.mail.body", "Hello Henning,`n`n(describe the bug, idea or question here)`n`n"
)
global LANG := LANG_EN          ; aktive Texte (wird in InitLanguage gesetzt)
global gLangCode := "en"

; Sprache bestimmen: CONF/settings.ini "Language", sonst Windows-Anzeigesprache.
; A_Language ist der Hex-Code der Windows-UI-Sprache (0407 = Deutsch, ...).
InitLanguage() {
    global LANG, LANG_DE, LANG_EN, gLangCode
    code := CONF["Language"]
    ov := IniRead(CONF["IniPath"], "View", "Language", "")
    if (ov != "")
        code := ov
    if (code = "auto") {
        deCodes := "0407,0807,0c07,1007,1407"           ; Deutschland, Schweiz, Oesterreich, Luxemburg, Liechtenstein
        code := InStr(deCodes, A_Language) ? "de" : "en"
    }
    gLangCode := code
    ; eingebaute Basis (unbekannte Codes starten auf Englisch), dann lang\<code>.ini drueber
    LANG := (code = "de") ? LANG_DE.Clone() : LANG_EN.Clone()
    file := A_ScriptDir "\lang\" code ".ini"
    if FileExist(file) {
        try {
            Loop Parse, FileRead(file, "UTF-8"), "`n", "`r" {
                line := Trim(A_LoopField)
                if (line = "" || SubStr(line, 1, 1) = ";" || SubStr(line, 1, 1) = "[")
                    continue
                eq := InStr(line, "=")
                if (eq > 1)
                    LANG[Trim(SubStr(line, 1, eq - 1))] := StrReplace(Trim(SubStr(line, eq + 1)), "\n", "`n")
            }
        }
    }
}

; Text holen und Platzhalter {1}, {2} ... fuellen; fehlende Schluessel fallen auf Englisch, dann auf den Schluessel zurueck
T(key, args*) {
    global LANG, LANG_EN
    s := LANG.Has(key) ? LANG[key] : (LANG_EN.Has(key) ? LANG_EN[key] : key)
    return args.Length ? Format(s, args*) : s
}

; ------------------------------- Start --------------------------------------
Main()

Main() {
    global VDA, MyGui
    OnError(LogErr)
    InitLanguage()
    if !FileExist(CONF["DllPath"]) {
        MsgBox(T("err.dll_missing", CONF["DllPath"]), "DeskTabs", 0x10)
        ExitApp
    }
    VDA := DllCall("LoadLibrary", "Str", CONF["DllPath"], "Ptr")
    if !VDA {
        MsgBox(T("err.dll_load"), "DeskTabs", 0x10)
        ExitApp
    }
    ApplyIniOverrides()                      ; gemerkte Einstellungen aus settings.ini [View]
    ApplyTheme()                             ; Farbsatz passend zum Windows-Theme
    BuildBar()
    ApplyWindowHooks()                       ; Pin auf alle Desktops + Change-Hook
    OnMessage(MSG_VD_CHANGED, OnDesktopChanged)
    if (CONF["WheelSwitch"])
        OnMessage(0x020A, OnWheel)          ; WM_MOUSEWHEEL
    OnMessage(0x0205, OnRButtonUp)          ; WM_RBUTTONUP -> Kontextmenue
    ; Fallback-Timer (falls Hook mal nichts meldet) + Namen + Desktop-Anzahl frisch halten
    SetTimer(Refresh, 1200)
    ; Backstop: im Vordergrund halten (gegen z-Order-Verdraengung)
    SetTimer(AssertTop, 250)
    ; Sofort reagieren, wenn ein Fenster nach vorne kommt -> kein Flackern
    gWinEventCb := CallbackCreate(WinEventProc)
    ; EVENT_SYSTEM_FOREGROUND (0x0003), WINEVENT_OUTOFCONTEXT (0)
    gWinEventHook := DllCall("SetWinEventHook", "UInt", 0x0003, "UInt", 0x0003
        , "Ptr", 0, "Ptr", gWinEventCb, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr")
    ; Hover-Effekt
    SetTimer(HoverTick, 60)
    ; Vollbild-Erkennung (Leiste aus-/einblenden)
    if (CONF["AutoHideFullscreen"])
        SetTimer(FullscreenTick, 500)
    UpdateHighlight()                        ; oeffnet auch das erste Zeit-Log-Segment
    ; Zeit-Log: Sperren/Entsperren des Bildschirms als Pause erkennen (immer
    ; registrieren, TimeLog kann zur Laufzeit ueber das Menue eingeschaltet werden)
    DllCall("Wtsapi32\WTSRegisterSessionNotification", "Ptr", A_ScriptHwnd, "UInt", 0)
    OnMessage(0x02B1, OnSessionChange)      ; WM_WTSSESSION_CHANGE
    BuildTray()
    SetTimer(AutoUpdateTick, -20000)         ; Update-Pruefung 20 s nach dem Start, hoechstens einmal pro Tag
}

; ------------------------ Einstellungen (settings.ini [View]) ---------------
; Alles, was das Kontextmenue umschaltet, landet in settings.ini [View] und
; ueberschreibt beim Start bzw. beim Live-Reload die CONF-Standardwerte.
ApplyIniOverrides() {
    for key, allowed in Map("CompactMode", "auto,full,short,icon", "ThemeMode", "auto,light,dark"
                          , "DockMode", "on,above", "Language", "*", "ActiveStyle", "desktop,accent,solid"
                          , "SwitchMethod", "native,dll") {
        v := IniRead(CONF["IniPath"], "View", key, "")
        if (v != "" && (allowed = "*" || InStr("," allowed ",", "," v ",")))
            CONF[key] := v
    }
    for key in ["ShowIndex", "ColorCoding", "SnapToTaskbar", "TimeLog", "UpdateCheck", "ShowDividers", "ShowIcons"] {
        v := IniRead(CONF["IniPath"], "View", key, "")
        if (v = "0" || v = "1")
            CONF[key] := Integer(v)
    }
}

; Einstellung setzen, merken, anwenden
SetView(key, val) {
    CONF[key] := val
    IniSet("View", key, val)
    if (key = "TimeLog")
        val ? LogOpen(GetCurrentDesktop()) : LogClose()
    if (key = "Language") {
        InitLanguage()
        BuildTray()
    }
    if (key = "DockMode")
        IniDel("Position", "Y")     ; Y neu aus dem Andock-Modus ableiten, X bleibt
    ApplyTheme()
    RebuildAll()
}
ToggleView(key, *) => SetView(key, CONF[key] ? 0 : 1)
SetViewStr(key, val, *) => SetView(key, val)

RebuildAll() {
    BuildBar()
    ApplyWindowHooks()
    UpdateHighlight()
}

; --------------------------- Symbol-Bibliothek ------------------------------
; Windows 11 bringt die Schrift "Segoe Fluent Icons" mit: ueber tausend saubere
; Symbole im System-Stil. Wir nutzen sie als eingebaute Bibliothek - nichts zu
; bundeln, keine Lizenzfrage, und die Symbole lassen sich einfaerben.
GlyphList() {
    static list := ParseGlyphs()
    return list
}

; Die vollstaendige Bibliothek steht in data\glyph-names.txt ("CODE|Name|Suchbegriffe").
; Fehlt die Datei (z.B. weil nur das Skript kopiert wurde), bleibt die eingebaute
; Kurzauswahl uebrig, damit die Bibliothek trotzdem nutzbar ist.
ParseGlyphs() {
    out := []
    file := A_ScriptDir "\data\glyph-names.txt"
    if FileExist(file) {
        try {
            Loop Parse, FileRead(file, "UTF-8"), "`n", "`r" {
                line := Trim(A_LoopField)
                if (line = "" || SubStr(line, 1, 1) = ";")
                    continue
                parts := StrSplit(line, "|")
                if (parts.Length >= 2)
                    out.Push(Map("code", parts[1], "name", parts[2]
                        , "kw", StrLower(parts[1] " " parts[2] " " (parts.Length > 2 ? parts[3] : ""))))
            }
        }
    }
    if (out.Length)
        return out
    for code in StrSplit("E713 E790 E91B E8AC E8EF E8FD E793 E7C4 E8B9 E706 E708 E946"
        . " E897 E72C E80F E71D E74E E8BD E81C E9D9 E734 E8A5 E90F EA80 E8C8 ECAA E71B"
        . " E8F1 E7EE E787 E823 E8EC E81E E9D2 E9F5 E7C1 E7B8 E77B E7EF E774 E896 E71E"
        . " E8FB E715 E8D7 E838 E8B7 E707 E912 E930 E945 E703 E7F4 E71C E8AE E9F9 EB44", " ")
        out.Push(Map("code", code, "name", code, "kw", StrLower(code)))
    return out
}

; Schnellfilter: Beschriftung => Suchbegriff
GlyphTopics() => Map(T("iconlib.t.files"), "ordner", T("iconlib.t.time"), "zeit"
    , T("iconlib.t.people"), "person", T("iconlib.t.comm"), "nachricht"
    , T("iconlib.t.media"), "bild", T("iconlib.t.data"), "diagramm"
    , T("iconlib.t.system"), "einstellungen", T("iconlib.t.places"), "ort")

IsGlyphSpec(s) => (SubStr(s, 1, 6) = "glyph:")
GlyphChar(spec) => Chr(Integer("0x" SubStr(spec, 7)))

; Schriftobjekt der Symbolschrift (mit Fallback auf aeltere Windows-Versionen)
MakeIconFont(sizePx) {
    fam := 0
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "Str", CONF["IconFont"], "Ptr", 0, "Ptr*", &fam)
    if (!fam)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "Str", "Segoe MDL2 Assets", "Ptr", 0, "Ptr*", &fam)
    if (!fam)
        return 0
    font := 0
    DllCall("gdiplus\GdipCreateFont", "Ptr", fam, "Float", sizePx, "Int", 0, "Int", 2, "Ptr*", &font)
    DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", fam)
    return font
}

; Symbol aus der Bibliothek direkt in eine Zeichenflaeche malen
DrawGlyph(g, spec, x, y, size, rgb) {
    font := MakeIconFont(size * 0.86)
    if (!font)
        return
    sf := MakeFormat()
    DrawText(g, font, sf, GlyphChar(spec), x, y, size, size, ARGB(rgb))
    DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
    DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf)
}

; Symbol als HBITMAP (fuer Menue-Eintraege und das Auswahlfenster)
GlyphHBitmap(spec, size, rgb, bgRgb) {
    GdipStart()
    bmp := 0, g := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", size, "Int", size, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &bmp)
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", bmp, "Ptr*", &g)
    DllCall("gdiplus\GdipGraphicsClear", "Ptr", g, "UInt", ARGB(bgRgb))
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 5)
    DrawGlyph(g, spec, 0, 0, size, rgb)
    hbm := 0
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", bmp, "Ptr*", &hbm, "UInt", ARGB(bgRgb))
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", bmp)
    return hbm
}

; Symbol vor einem Menue-Eintrag
MenuGlyph(menu, item, code) {
    hbm := GlyphHBitmap("glyph:" code, 16, 0x1F1F1F, 0xF0F0F0)
    if (hbm) {
        try menu.SetIcon(item, "HBITMAP:*" hbm, , 16)
        DllCall("DeleteObject", "Ptr", hbm)
    }
}

; Auswahlfenster: Suchfeld, Schnellfilter und ein rollbares Raster ueber die
; gesamte Bibliothek. Eine Seite ist EIN gezeichnetes Bild (wie die Leiste), nicht
; hundert Steuerelemente - sonst baut sich das Raster beim Rollen sichtbar auf.
; Fertige Seiten bleiben im Zwischenspeicher, die Nachbarseiten werden vorbereitet.
ShowIconLibrary(num, *) {
    NCOLS := 12, NROWS := 8, CELLW := 44   ; als lokale Variablen, damit die inneren Funktionen sie mitbekommen
    glyphs := GlyphList()
    raw := GetDesktopNameRaw(num)
    col := DesktopColor(num)
    gridW := NCOLS * CELLW, gridH := NROWS * CELLW
    filtered := [], offset := 0, pages := Map(), sig := "", hoverIdx := 0

    g := Gui("+AlwaysOnTop +OwnDialogs -MinimizeBox -MaximizeBox", T("iconlib.title", raw))
    g.SetFont("s10", "Segoe UI")
    g.MarginX := 14, g.MarginY := 12
    g.Add("Text", "xm ym w" (gridW + 21), T("iconlib.hint"))
    search := g.Add("Edit", "xm y+8 w" (gridW + 21) " h26")
    SendMessage(0x1501, 1, StrPtr(T("iconlib.search")), search)   ; EM_SETCUEBANNER
    g.SetFont("s9")
    firstBtn := 0
    for label, term in GlyphTopics() {
        b := g.Add("Button", (firstBtn ? "x+4 yp" : "xm y+8") " h24 w" Max(58, StrLen(label) * 8), label)
        b.OnEvent("Click", ((t, *) => (search.Value := t, ApplyFilter(t))).Bind(term))
        if (!firstBtn)
            firstBtn := b
    }
    g.SetFont("s10")
    ty := 0, th := 0
    firstBtn.GetPos(, &ty, , &th)
    gridX := 14, gridY := ty + th + 10

    sheet := g.Add("Picture", Format("x{1} y{2} w{3} h{4} +0x100", gridX, gridY, gridW, gridH))
    sb := g.Add("Custom", Format("ClassScrollBar x{1} y{2} w17 h{3} 0x1", gridX + gridW + 4, gridY, gridH))
    count := g.Add("Text", "x" gridX " y" (gridY + gridH + 14) " w260 h24 +0x200", "")
    btnCancel := g.Add("Button", "x" (gridX + gridW - 104) " y" (gridY + gridH + 12) " w120 h28", T("dlg.cancel"))
    btnCancel.OnEvent("Click", (*) => Close())

    ; --- eine Seite als Bild zeichnen (und im Zwischenspeicher behalten) ---
    PageBitmap(off, hover := 0) {
        key := sig "|" off "|" hover
        if (pages.Has(key))
            return pages[key]
        GdipStart()
        bmp := 0, gr := 0
        DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", gridW, "Int", gridH, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &bmp)
        DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", bmp, "Ptr*", &gr)
        DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", gr, "Int", 4)
        DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", gr, "Int", 5)
        DllCall("gdiplus\GdipGraphicsClear", "Ptr", gr, "UInt", ARGB(0xF6F6F6))
        font := MakeIconFont(28)
        sf := MakeFormat()
        Loop NCOLS * NROWS {
            i := A_Index
            idx := off * NCOLS + i
            if (idx > filtered.Length)
                break
            cx := Mod(i - 1, NCOLS) * CELLW, cy := ((i - 1) // NCOLS) * CELLW
            if (i = hover)
                FillRoundRect(gr, cx + 2, cy + 2, CELLW - 4, CELLW - 4, 5, ARGB(Mix(0x000000, 0xF6F6F6, 7)))
            DrawText(gr, font, sf, GlyphChar("glyph:" glyphs[filtered[idx]]["code"]), cx, cy, CELLW, CELLW, ARGB(col))
        }
        DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
        DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf)
        hbm := 0
        DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", bmp, "Ptr*", &hbm, "UInt", ARGB(0xF6F6F6))
        DllCall("gdiplus\GdipDeleteGraphics", "Ptr", gr)
        DllCall("gdiplus\GdipDisposeImage", "Ptr", bmp)
        pages[key] := hbm
        return hbm
    }
    ShowPage() {
        sheet.Value := "HBITMAP:*" PageBitmap(offset, hoverIdx)
        SetScroll(Ceil(filtered.Length / NCOLS), NROWS, offset)
        count.Text := T("iconlib.count", filtered.Length)
        SetTimer(Preload, -60)          ; Nachbarseiten im Hintergrund vorbereiten
    }
    Preload() {
        maxOff := Max(0, Ceil(filtered.Length / NCOLS) - NROWS)
        for , off in [offset + 1, offset - 1, offset + NROWS, offset - NROWS]
            if (off >= 0 && off <= maxOff)
                PageBitmap(off, 0)
    }
    SetScroll(nRows, pageSize, pos) {
        si := Buffer(28, 0)
        NumPut("UInt", 28, "UInt", 0x17, "Int", 0, "Int", Max(0, nRows - 1), "UInt", pageSize, "Int", pos, si)
        DllCall("SetScrollInfo", "Ptr", sb.Hwnd, "Int", 2, "Ptr", si, "Int", 1)
    }
    ApplyFilter(needle) {
        needle := Trim(StrLower(needle))
        filtered := []
        for i, item in glyphs
            if (needle = "" || InStr(item["kw"], needle))
                filtered.Push(i)
        sig := needle, offset := 0, hoverIdx := 0
        ShowPage()
    }
    Scroll(deltaRows) {
        maxOff := Max(0, Ceil(filtered.Length / NCOLS) - NROWS)
        newOff := Min(Max(offset + deltaRows, 0), maxOff)
        if (newOff = offset)
            return
        offset := newOff, hoverIdx := 0
        ShowPage()
    }
    ; Zelle unter der Maus (1-basiert), 0 = daneben
    CellAt(&idx) {
        CoordMode("Mouse", "Screen")
        MouseGetPos(&mx, &my)
        sx := 0, sy := 0
        ControlGetPos(&sx, &sy, , , sheet, g)
        gx := 0, gy := 0
        WinGetPos(&gx, &gy, , , g)
        lx := mx - gx - sx, ly := my - gy - sy
        if (lx < 0 || ly < 0 || lx >= gridW || ly >= gridH)
            return false
        hitCell := (ly // CELLW) * NCOLS + (lx // CELLW) + 1
        idx := offset * NCOLS + hitCell
        return (idx <= filtered.Length) ? hitCell : false
    }
    HoverTickLib() {
        if (!WinExist("ahk_id " g.Hwnd))
            return
        idx := 0
        hitCell := CellAt(&idx)
        if (hitCell != hoverIdx) {
            hoverIdx := hitCell ? hitCell : 0
            sheet.Value := "HBITMAP:*" PageBitmap(offset, hoverIdx)
            if (hitCell)
                ToolTip(glyphs[idx]["name"])
            else
                ToolTip()
        }
    }
    SheetClick(*) {
        idx := 0
        if (CellAt(&idx))
            SetGlyphIcon(num, glyphs[filtered[idx]]["code"], g, Close)
    }
    OnVScroll(wParam, lParam, msg, hwnd) {
        if (lParam != sb.Hwnd)
            return
        switch (wParam & 0xFFFF) {
            case 0: Scroll(-1)
            case 1: Scroll(1)
            case 2: Scroll(-NROWS)
            case 3: Scroll(NROWS)
            case 4, 5: Scroll(((wParam >> 16) & 0xFFFF) - offset)
            case 6: Scroll(-99999)
            case 7: Scroll(99999)
        }
        return 0
    }
    OnPickerWheel(wParam, lParam, msg, hwnd) {
        if (!WinActive("ahk_id " g.Hwnd))
            return
        d := (wParam >> 16) & 0xFFFF
        if (d > 0x7FFF)
            d -= 0x10000
        Scroll(d > 0 ? -1 : 1)
        return 0
    }
    Close() {
        SetTimer(HoverTickLib, 0)
        SetTimer(Preload, 0)
        ToolTip()
        OnMessage(0x0115, OnVScroll, 0)
        OnMessage(0x020A, OnPickerWheel, 0)
        for , h in pages
            DllCall("DeleteObject", "Ptr", h)
        g.Destroy()
    }

    sheet.OnEvent("Click", SheetClick)
    search.OnEvent("Change", (ctrl, *) => ApplyFilter(ctrl.Value))
    OnMessage(0x0115, OnVScroll)
    OnMessage(0x020A, OnPickerWheel)
    g.OnEvent("Escape", (*) => Close())
    g.OnEvent("Close", (*) => Close())
    ApplyFilter("")
    SetGuiIcon(g)
    g.Show("AutoSize Center")
    search.Focus()
    SetTimer(HoverTickLib, 70)
}

SetGlyphIcon(num, code, g, closeFn := 0, *) {
    IniSet("Icons", GetDesktopNameRaw(num), "glyph:" code)
    if (closeFn)
        closeFn()
    else
        try g.Destroy()
    RebuildAll()
}

; ------------------------------- Symbole ------------------------------------
; settings.ini [Icons] "Desktopname = Pfad ODER URL". Eine URL wird einmal geholt
; (hochaufgeloestes Seiten-Symbol) und in icons\<Desktopname>.png zwischengespeichert.
IconsDir() => A_ScriptDir "\icons"

; Dateiname aus einem Desktop-Namen (ohne verbotene Zeichen)
SafeName(s) {
    for , ch in StrSplit('<>:"/\|?*')
        s := StrReplace(s, ch, "_")
    return Trim(s)
}

IsUrl(s) => (SubStr(s, 1, 7) = "http://" || SubStr(s, 1, 8) = "https://" || RegExMatch(s, "i)^[a-z0-9\-]+(\.[a-z0-9\-]+)+(/|$)"))

; Zu zeichnende Bilddatei fuer einen Desktop ("" = keine)
IconPathFor(num) {
    raw := GetDesktopNameRaw(num)
    spec := IniRead(CONF["IniPath"], "Icons", raw, "")
    if (spec = "")
        return ""
    if (IsGlyphSpec(spec))
        return spec                      ; Bibliotheks-Symbol, wird direkt gezeichnet
    if (!IsUrl(spec)) {
        path := (InStr(spec, ":") || SubStr(spec, 1, 1) = "\") ? spec : A_ScriptDir "\" spec
        return FileExist(path) ? path : ""
    }
    cache := IconsDir() "\" SafeName(raw) ".png"
    if FileExist(cache)
        return cache
    FetchSiteIconOnce(spec, cache)
    return FileExist(cache) ? cache : ""
}

; Pro Sitzung nur einen Versuch je URL (sonst bremst ein toter Link jeden Neuaufbau)
FetchSiteIconOnce(url, dest) {
    global gIconFetch
    if (gIconFetch.Has(url))
        return
    gIconFetch[url] := true
    FetchSiteIcon(url, dest)
}

HttpGetBytes(url, timeoutMs := 6000) {
    global APP_VERSION
    try {
        req := ComObject("WinHttp.WinHttpRequest.5.1")
        req.SetTimeouts(timeoutMs, timeoutMs, timeoutMs, timeoutMs)
        req.Open("GET", url, false)
        req.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) DeskTabs/" APP_VERSION)
        req.Send()
        if (req.Status = 200)
            return req.ResponseBody
    }
    return 0
}

SaveBytes(bytes, path) {
    try {
        stream := ComObject("ADODB.Stream")
        stream.Type := 1
        stream.Open()
        stream.Write(bytes)
        stream.SaveToFile(path, 2)
        stream.Close()
        return FileExist(path) ? true : false
    }
    return false
}

; Holt das beste Symbol einer Webseite: erst apple-touch-icon / grosse <link rel=icon>
; aus dem HTML, dann /favicon.ico, zuletzt ein Favicon-Dienst. Ergebnis wird als PNG
; in der gewuenschten Groesse gespeichert.
FetchSiteIcon(url, dest) {
    if (SubStr(url, 1, 4) != "http")
        url := "https://" url
    if !RegExMatch(url, "i)^(https?://[^/]+)", &m)
        return false
    origin := m[1]
    cands := []
    html := ""
    try {
        req := ComObject("WinHttp.WinHttpRequest.5.1")
        req.SetTimeouts(6000, 6000, 6000, 6000)
        req.Open("GET", url, false)
        req.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) DeskTabs")
        req.Send()
        if (req.Status = 200)
            html := req.ResponseText
    }
    if (html != "") {
        pos := 1
        while (pos := RegExMatch(html, "is)<link\b[^>]*>", &lm, pos)) {
            tag := lm[0], pos += lm.Len
            if !RegExMatch(tag, 'is)rel\s*=\s*["\x27]?([^"\x27>]*)', &rm)
                continue
            rel := StrLower(rm[1])
            if !InStr(rel, "icon")
                continue
            if !RegExMatch(tag, 'is)href\s*=\s*["\x27]?([^"\x27> ]+)', &hm)
                continue
            href := hm[1]
            size := 0
            if RegExMatch(tag, "is)sizes\s*=\s*[\x22\x27]?(\d+)", &sm)
                size := Integer(sm[1])
            if (InStr(rel, "apple-touch"))
                size := Max(size, 180)
            cands.Push(Map("href", AbsUrl(href, origin, url), "size", size))
        }
    }
    ; grosse zuerst
    Loop cands.Length - 1 {
        i := A_Index
        Loop cands.Length - i {
            j := A_Index
            if (cands[j]["size"] < cands[j + 1]["size"]) {
                tmp := cands[j], cands[j] := cands[j + 1], cands[j + 1] := tmp
            }
        }
    }
    cands.Push(Map("href", origin "/favicon.ico", "size", 0))
    host := RegExReplace(origin, "i)^https?://")
    cands.Push(Map("href", "https://www.google.com/s2/favicons?sz=128&domain=" host, "size", 0))

    DirCreate(IconsDir())
    tmpFile := IconsDir() "\_dl.tmp"
    for cand in cands {
        bytes := HttpGetBytes(cand["href"])
        if (!bytes)
            continue
        try FileDelete(tmpFile)
        if (!SaveBytes(bytes, tmpFile))
            continue
        if (ConvertToPng(tmpFile, dest, 128)) {   ; grosszuegig zwischenspeichern, beim Zeichnen sauber verkleinert
            try FileDelete(tmpFile)
            return true
        }
    }
    try FileDelete(tmpFile)
    return false
}

; Relative Adresse auf eine vollstaendige URL bringen
AbsUrl(href, origin, pageUrl) {
    if (SubStr(href, 1, 4) = "http")
        return href
    if (SubStr(href, 1, 2) = "//")
        return "https:" href
    if (SubStr(href, 1, 1) = "/")
        return origin href
    base := RegExReplace(pageUrl, "/[^/]*$", "/")
    return base href
}

; Bilddatei (ico/png/jpg/svg-frei) als quadratisches PNG in Zielgroesse speichern
ConvertToPng(src, dest, size) {
    GdipStart()
    img := 0
    if (DllCall("gdiplus\GdipCreateBitmapFromFile", "WStr", src, "Ptr*", &img) != 0 || !img)
        return false
    w := 0, h := 0
    DllCall("gdiplus\GdipGetImageWidth", "Ptr", img, "UInt*", &w)
    DllCall("gdiplus\GdipGetImageHeight", "Ptr", img, "UInt*", &h)
    if (!w || !h) {
        DllCall("gdiplus\GdipDisposeImage", "Ptr", img)
        return false
    }
    out := 0, g := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", size, "Int", size, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &out)
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", out, "Ptr*", &g)
    DllCall("gdiplus\GdipSetInterpolationMode", "Ptr", g, "Int", 7)   ; HighQualityBicubic
    DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", g, "Int", 2)
    ; proportional einpassen
    scale := Min(size / w, size / h)
    dw := Round(w * scale), dh := Round(h * scale)
    DllCall("gdiplus\GdipDrawImageRectI", "Ptr", g, "Ptr", img, "Int", (size - dw) // 2, "Int", (size - dh) // 2, "Int", dw, "Int", dh)
    ok := SavePng(out, dest)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", out)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", img)
    return ok
}

SavePng(pBitmap, path) {
    ; CLSID des PNG-Encoders
    clsid := Buffer(16, 0)
    if (DllCall("ole32\CLSIDFromString", "WStr", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "Ptr", clsid) != 0)
        return false
    return DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "WStr", path, "Ptr", clsid, "Ptr", 0) = 0
}

; Bild einmal laden und im Cache halten
LoadIconBitmap(path) {
    global gIconCache
    key := path "|" (FileExist(path) ? FileGetTime(path, "M") : "")
    if (gIconCache.Has(key))
        return gIconCache[key]
    GdipStart()
    img := 0
    DllCall("gdiplus\GdipCreateBitmapFromFile", "WStr", path, "Ptr*", &img)
    gIconCache[key] := img
    return img
}

; Hauptfarbe einer Bilddatei: Pixel nach Farbton gebuendelt, der kraeftigste
; Bereich gewinnt (Weiss, Schwarz und blasse Pixel zaehlen nicht mit). Fuer
; einfarbige Logos wird ersatzweise der dunkle Mittelwert genommen. -1 = nichts gefunden.
DominantColor(path) {
    GdipStart()
    img := 0
    if (DllCall("gdiplus\GdipCreateBitmapFromFile", "WStr", path, "Ptr*", &img) != 0 || !img)
        return -1
    w := 0, h := 0
    DllCall("gdiplus\GdipGetImageWidth", "Ptr", img, "UInt*", &w)
    DllCall("gdiplus\GdipGetImageHeight", "Ptr", img, "UInt*", &h)
    if (!w || !h) {
        DllCall("gdiplus\GdipDisposeImage", "Ptr", img)
        return -1
    }
    rect := Buffer(16, 0)
    NumPut("Int", 0, "Int", 0, "Int", w, "Int", h, rect)
    bd := Buffer(32, 0)
    if (DllCall("gdiplus\GdipBitmapLockBits", "Ptr", img, "Ptr", rect, "UInt", 1, "Int", 0x26200A, "Ptr", bd) != 0) {
        DllCall("gdiplus\GdipDisposeImage", "Ptr", img)
        return -1
    }
    stride := NumGet(bd, 8, "Int"), scan := NumGet(bd, 16, "Ptr")
    step := Max(1, w // 64)                       ; grosse Bilder ausduennen
    buckets := Map(), darkW := 0, darkR := 0, darkG := 0, darkB := 0
    y := 0
    while (y < h) {
        x := 0
        while (x < w) {
            px := NumGet(scan + y * stride + x * 4, "UInt")
            a := (px >> 24) & 0xFF
            if (a >= 100) {
                r := (px >> 16) & 0xFF, gg := (px >> 8) & 0xFF, b := px & 0xFF
                hsl := RgbToHsl((r << 16) | (gg << 8) | b)
                if (hsl["l"] < 0.55) {
                    darkW += 1, darkR += r, darkG += gg, darkB += b
                }
                if (hsl["s"] >= 0.18 && hsl["l"] > 0.12 && hsl["l"] < 0.93) {
                    key := Floor(hsl["h"] * 24)
                    wgt := hsl["s"]
                    if (!buckets.Has(key))
                        buckets[key] := Map("w", 0, "r", 0, "g", 0, "b", 0)
                    bk := buckets[key]
                    bk["w"] += wgt, bk["r"] += r * wgt, bk["g"] += gg * wgt, bk["b"] += b * wgt
                }
            }
            x += step
        }
        y += step
    }
    DllCall("gdiplus\GdipBitmapUnlockBits", "Ptr", img, "Ptr", bd)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", img)

    best := 0, bestW := 0
    for , bk in buckets {
        if (bk["w"] > bestW)
            bestW := bk["w"], best := bk
    }
    if (best && bestW > 0) {
        r := Round(best["r"] / bestW), gg := Round(best["g"] / bestW), b := Round(best["b"] / bestW)
    } else if (darkW > 0) {                       ; einfarbiges Logo
        r := Round(darkR / darkW), gg := Round(darkG / darkW), b := Round(darkB / darkW)
    } else {
        return -1
    }
    ; fuer den Farbbalken auf eine gut sichtbare Helligkeit bringen
    hsl := RgbToHsl((r << 16) | (gg << 8) | b)
    l := Min(0.58, Max(0.30, hsl["l"]))
    return HslToRgb(hsl["h"], hsl["s"], l)
}

; Farbe des Desktops aus seinem Symbol uebernehmen
ColorFromIcon(num, *) {
    spec := IconPathFor(num)
    if (spec = "" || IsGlyphSpec(spec)) {
        MsgBox(T("err.color_icon"), "DeskTabs", 0x30)
        return
    }
    col := DominantColor(spec)
    if (col < 0) {
        MsgBox(T("err.color_icon"), "DeskTabs", 0x30)
        return
    }
    IniSet("Colors", GetDesktopNameRaw(num), Format("{:06X}", col))
    RebuildAll()
}

; --- Menuebefehle ---
; Eingabefeld mit festem, grauem "https://" davor - so ist sichtbar, dass die
; blosse Domain genuegt. Rueckgabe: Map("ok", true/false, "value", Text ohne Schema).
PromptUrlBox(title, prompt, default) {
    res := Map("ok", false, "value", "")
    g := Gui("+AlwaysOnTop +OwnDialogs -MinimizeBox -MaximizeBox", title)
    g.SetFont("s10", "Segoe UI")
    g.MarginX := 16, g.MarginY := 14
    g.Add("Text", "xm ym w420", prompt)
    pre := g.Add("Text", "xm y+14 h26 +0x200 c808080", "https://")
    pw := 0
    pre.GetPos(, , &pw)
    ed := g.Add("Edit", "x+4 yp w" (420 - pw - 4) " h26", default)
    btnOk := g.Add("Button", "xm+196 y+16 w110 Default", T("dlg.ok"))
    btnCancel := g.Add("Button", "x+8 w110", T("dlg.cancel"))
    btnOk.OnEvent("Click", (*) => (res["ok"] := true, res["value"] := Trim(ed.Value), g.Destroy()))
    btnCancel.OnEvent("Click", (*) => g.Destroy())
    g.OnEvent("Escape", (*) => g.Destroy())
    g.OnEvent("Close", (*) => g.Destroy())
    g.Show("AutoSize Center")
    ed.Focus()
    WinWaitClose("ahk_id " g.Hwnd)
    return res
}

PromptIconUrl(num, *) {
    raw := GetDesktopNameRaw(num)
    cur := IniRead(CONF["IniPath"], "Icons", raw, "")
    start := IsUrl(cur) ? RegExReplace(cur, "i)^https?://") : ""
    res := PromptUrlBox(T("prompt.iconurl.title", raw), T("prompt.iconurl.text"), start)
    if (!res["ok"])
        return
    url := RegExReplace(Trim(res["value"]), "i)^https?://")   ; falls jemand das Schema doch mittippt
    if (url = "") {
        ClearIcon(num)
        return
    }
    cache := IconsDir() "\" SafeName(raw) ".png"
    try FileDelete(cache)
    ToolTip(T("icon.fetching"))
    ok := FetchSiteIcon(url, cache)
    ToolTip()
    if (!ok) {
        MsgBox(T("err.icon_fetch"), "DeskTabs", 0x30)
        return
    }
    IniSet("Icons", raw, url)
    RebuildAll()
}

PromptIconFile(num, *) {
    raw := GetDesktopNameRaw(num)
    file := FileSelect(3, , T("prompt.iconfile.title", raw), "Bilder (*.ico; *.png; *.jpg; *.jpeg; *.bmp; *.gif)")
    if (file = "")
        return
    IniSet("Icons", raw, file)
    RebuildAll()
}

ClearIcon(num, *) {
    raw := GetDesktopNameRaw(num)
    IniDel("Icons", raw)
    try FileDelete(IconsDir() "\" SafeName(raw) ".png")
    RebuildAll()
}

; ----------------------------- Kontextmenue --------------------------------
; Rechtsklick auf einen Tab: Tab-Bereich (Kuerzel, Farbe) + allgemeine
; Einstellungen. Rechtsklick auf Griff/Luecke oder Tray "Einstellungen…":
; nur die allgemeinen Einstellungen.
OnRButtonUp(wParam, lParam, msg, hwnd) {
    global MyGui, BTNS
    if (!MyGui)
        return
    if (hwnd != MyGui.Hwnd && DllCall("GetParent", "Ptr", hwnd, "Ptr") != MyGui.Hwnd)
        return
    item := ItemAtX(BarMouseX())
    ShowContextMenu(item ? item["num"] : -1)
    return 0
}

ShowContextMenu(num, *) {
    m := Menu()
    if (num >= 0) {
        raw := GetDesktopNameRaw(num)
        head := (num + 1) " · " raw
        m.Add(head, (*) => 0)
        m.Disable(head)
        m.Add(T("menu.tab.short"), PromptShort.Bind(num))
        MenuGlyph(m, T("menu.tab.short"), "E8AC")
        cm := Menu()
        cur := DesktopColor(num)
        hit := false
        for col in CONF["Palette"] {
            label := ColorName(col)
            cm.Add(label, SetColor.Bind(num, col))
            MenuSwatch(cm, label, col)
            if (col = cur && !hit) {
                cm.Default := label        ; aktuelle Farbe fett (ein Haken wuerde das Farbfeld verdecken)
                hit := true
            }
        }
        cm.Add()
        cm.Add(T("menu.color.custom"), PromptColor.Bind(num))
        if (!hit) {
            cm.Default := T("menu.color.custom")
            MenuSwatch(cm, T("menu.color.custom"), cur)
        }
        iconSpec := IconPathFor(num)
        cm.Add(T("menu.color.fromicon"), ColorFromIcon.Bind(num))
        MenuGlyph(cm, T("menu.color.fromicon"), "EF3B")
        if (iconSpec = "" || IsGlyphSpec(iconSpec))
            cm.Disable(T("menu.color.fromicon"))
        cm.Add(T("menu.color.default"), ClearColor.Bind(num))
        m.Add(T("menu.tab.color"), cm)
        MenuGlyph(m, T("menu.tab.color"), "E790")
        im := Menu()
        im.Add(T("menu.icon.library"), ShowIconLibrary.Bind(num))
        MenuGlyph(im, T("menu.icon.library"), "ECAA")
        im.Add(T("menu.icon.url"), PromptIconUrl.Bind(num))
        MenuGlyph(im, T("menu.icon.url"), "E774")
        im.Add(T("menu.icon.file"), PromptIconFile.Bind(num))
        MenuGlyph(im, T("menu.icon.file"), "E8B9")
        im.Add()
        im.Add(T("menu.icon.clear"), ClearIcon.Bind(num))
        if (IniRead(CONF["IniPath"], "Icons", raw, "") = "")
            im.Disable(T("menu.icon.clear"))
        m.Add(T("menu.tab.icon"), im)
        MenuGlyph(m, T("menu.tab.icon"), "E91B")
        m.Add()
    }
    FillSettingsMenu(m)
    m.Show()
}

; Allgemeiner Teil des Einstellungsmenues; identisch im Rechtsklick auf die
; Leiste und im Tray-Menue (dort ohne Umweg ueber "Einstellungen…").
FillSettingsMenu(m) {
    m.Add(T("menu.showindex"), ToggleView.Bind("ShowIndex"))
    if (CONF["ShowIndex"])
        m.Check(T("menu.showindex"))
    m.Add(T("menu.colorcoding"), ToggleView.Bind("ColorCoding"))
    if (CONF["ColorCoding"])
        m.Check(T("menu.colorcoding"))
    am := Menu()
    for val, label in Map("desktop", T("menu.active.desktop"), "accent", T("menu.active.accent"), "solid", T("menu.active.solid")) {
        am.Add(label, SetViewStr.Bind("ActiveStyle", val))
        if (CONF["ActiveStyle"] = val)
            am.Check(label)
    }
    m.Add(T("menu.active"), am)
    MenuGlyph(m, T("menu.active"), "E7C4")
    m.Add(T("menu.dividers"), ToggleView.Bind("ShowDividers"))
    if (CONF["ShowDividers"])
        m.Check(T("menu.dividers"))
    m.Add(T("menu.showicons"), ToggleView.Bind("ShowIcons"))
    if (CONF["ShowIcons"])
        m.Check(T("menu.showicons"))
    vm := Menu()
    for val, label in Map("auto", T("menu.view.auto"), "full", T("level.full"), "short", T("level.short"), "icon", T("level.icon")) {
        vm.Add(label, SetViewStr.Bind("CompactMode", val))
        if (CONF["CompactMode"] = val)
            vm.Check(label)
    }
    m.Add(T("menu.view"), vm)
    MenuGlyph(m, T("menu.view"), "E8FD")
    tm := Menu()
    for val, label in Map("auto", T("menu.theme.auto"), "light", T("menu.theme.light"), "dark", T("menu.theme.dark")) {
        tm.Add(label, SetViewStr.Bind("ThemeMode", val))
        if (CONF["ThemeMode"] = val)
            tm.Check(label)
    }
    m.Add(T("menu.theme"), tm)
    MenuGlyph(m, T("menu.theme"), "E793")
    dm := Menu()
    for val, label in Map("on", T("menu.dock.on"), "above", T("menu.dock.above")) {
        dm.Add(label, SetViewStr.Bind("DockMode", val))
        if (CONF["DockMode"] = val)
            dm.Check(label)
    }
    m.Add(T("menu.dock"), dm)
    MenuGlyph(m, T("menu.dock"), "ECAA")
    m.Add(T("menu.directjump"), (*) => SetView("SwitchMethod", CONF["SwitchMethod"] = "dll" ? "native" : "dll"))
    if (CONF["SwitchMethod"] = "dll")
        m.Check(T("menu.directjump"))
    m.Add(T("menu.snap"), ToggleView.Bind("SnapToTaskbar"))
    if (CONF["SnapToTaskbar"])
        m.Check(T("menu.snap"))
    m.Add(T("menu.timelog"), ToggleView.Bind("TimeLog"))
    if (CONF["TimeLog"])
        m.Check(T("menu.timelog"))
    lm := Menu()
    for val, label in Map("auto", T("menu.language.auto"), "de", "Deutsch", "en", "English") {
        lm.Add(label, SetViewStr.Bind("Language", val))
        if (CONF["Language"] = val)
            lm.Check(label)
    }
    m.Add(T("menu.language"), lm)
    MenuGlyph(m, T("menu.language"), "E774")
    m.Add()
    m.Add(T("menu.help"), HelpMenu())
    MenuGlyph(m, T("menu.help"), "E897")
    if (gUpdateTag != "")
        m.Add(T("menu.update.available", gUpdateTag), OpenReleasePage)
    m.Add(T("menu.about"), ShowAbout)
    MenuGlyph(m, T("menu.about"), "E946")
    m.Add()
    m.Add(T("tray.rebuild"), (*) => RebuildAll())
    MenuGlyph(m, T("tray.rebuild"), "E72C")
    m.Add(T("tray.resetpos"), ResetPos)
    m.Add()
    m.Add(T("tray.exit"), (*) => ExitApp())
    MenuGlyph(m, T("tray.exit"), "E7E8")
}

; Untermenue "Hilfe": Doku, Changelog, Feedback-Wege, Update-Pruefung
HelpMenu() {
    hm := Menu()
    hm.Add(T("menu.help.docs"), OpenDocs)
    MenuGlyph(hm, T("menu.help.docs"), "E8F1")
    hm.Add(T("menu.help.changelog"), (*) => Run(APP_CHANGELOG_URL))
    hm.Add()
    hm.Add(T("menu.feedback.bug"), ReportBug)
    hm.Add(T("menu.feedback.idea"), SuggestIdea)
    hm.Add(T("menu.feedback.mail"), MailAuthor)
    hm.Add()
    hm.Add(T("menu.update.check"), (*) => CheckUpdate(true))
    MenuGlyph(hm, T("menu.update.check"), "E896")
    hm.Add(T("menu.update.auto"), ToggleView.Bind("UpdateCheck"))
    if (CONF["UpdateCheck"])
        hm.Check(T("menu.update.auto"))
    return hm
}

PromptShort(num, *) {
    raw := GetDesktopNameRaw(num)
    ib := InputBox(T("prompt.short.text"), T("prompt.short.title", raw), "w380 h130", ShortNameFor(num))
    if (ib.Result != "OK")
        return
    v := Trim(ib.Value)
    v = "" ? IniDel("Short", raw) : IniSet("Short", raw, v)
    RebuildAll()
}

; Lesbarer Name einer Palettenfarbe (Sprachschluessel "color.RRGGBB"), sonst "#RRGGBB".
ColorName(col) {
    global LANG, LANG_EN
    hex := Format("{:06X}", col)
    key := "color." hex
    return (LANG.Has(key) || LANG_EN.Has(key)) ? T(key) : "#" hex
}

; Farbfeld als Menue-Icon: 16x16-Bitmap in der Farbe mit 1 px dunklerem Rand.
; "HBITMAP:*" laesst AHK eine Kopie anlegen, das Original wird sofort freigegeben.
MenuSwatch(menu, item, col) {
    size := 16
    r := (col >> 16) & 0xFF, g := (col >> 8) & 0xFF, b := col & 0xFF
    fill := 0xFF000000 | (r << 16) | (g << 8) | b
    edge := 0xFF000000 | ((r * 2 // 3) << 16) | ((g * 2 // 3) << 8) | (b * 2 // 3)
    px := Buffer(size * size * 4)
    Loop size {
        y := A_Index - 1
        Loop size {
            x := A_Index - 1
            onEdge := (x = 0 || y = 0 || x = size - 1 || y = size - 1)
            NumPut("UInt", onEdge ? edge : fill, px, (y * size + x) * 4)
        }
    }
    hbm := DllCall("CreateBitmap", "Int", size, "Int", size, "UInt", 1, "UInt", 32, "Ptr", px, "Ptr")
    if (hbm) {
        try menu.SetIcon(item, "HBITMAP:*" hbm, , size)
        DllCall("DeleteObject", "Ptr", hbm)
    }
}

PromptColor(num, *) {
    raw := GetDesktopNameRaw(num)
    ib := InputBox(T("prompt.color.text"), T("prompt.color.title", raw), "w380 h130", Format("{:06X}", DesktopColor(num)))
    if (ib.Result != "OK")
        return
    v := StrReplace(Trim(ib.Value), "#", "")
    if !RegExMatch(v, "^[0-9A-Fa-f]{6}$") {
        MsgBox(T("err.color"), "DeskTabs", 0x30)
        return
    }
    IniSet("Colors", raw, StrUpper(v))
    RebuildAll()
}

SetColor(num, col, *) {
    IniSet("Colors", GetDesktopNameRaw(num), Format("{:06X}", col))
    RebuildAll()
}

ClearColor(num, *) {
    IniDel("Colors", GetDesktopNameRaw(num))
    RebuildAll()
}

; ------------------------ Hilfe, Feedback, Update, Über ---------------------
; Alle Links zeigen auf das GitHub-Projekt (APP_*-Konstanten oben); eine spaetere
; Doku-Seite auf paehtz.de braucht nur die URLs dort.
AppIconPath() => A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\DeskTabs.ico"

OpenDocs(*) {
    global APP_DOCS_URL, gLangCode
    Run(APP_DOCS_URL.Has(gLangCode) ? APP_DOCS_URL[gLangCode] : APP_DOCS_URL["en"])
}

UrlEncode(s) {
    out := ""
    buf := Buffer(StrPut(s, "UTF-8") - 1)
    StrPut(s, buf, "UTF-8")
    Loop buf.Size {
        c := NumGet(buf, A_Index - 1, "UChar")
        out .= (c >= 0x30 && c <= 0x39 || c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A || Chr(c) ~= "[\-_.~]")
            ? Chr(c) : Format("%{:02X}", c)
    }
    return out
}

; Umgebungsangaben, die im Fehlerbericht vorausgefuellt werden
EnvSummary() {
    return "DockMode=" CONF["DockMode"] ", ThemeMode=" CONF["ThemeMode"] ", CompactMode=" CONF["CompactMode"]
        . ", Desktops=" GetDesktopCount() ", Screen=" A_ScreenWidth "x" A_ScreenHeight ", DPI=" A_ScreenDPI
}

ReportBug(*) {
    global APP_URL, APP_VERSION
    Run(APP_URL "/issues/new?template=bug_report.yml"
        . "&version=" UrlEncode(APP_VERSION)
        . "&windows=" UrlEncode("Windows " A_OSVersion)
        . "&run-mode=" UrlEncode(A_IsCompiled ? "Compiled DeskTabs.exe (from a release)" : "DeskTabs.ahk with AutoHotkey v2")
        . "&config=" UrlEncode(EnvSummary()))
}

SuggestIdea(*) {
    global APP_URL
    Run(APP_URL "/issues/new?template=feature_request.yml")
}

MailAuthor(*) {
    global APP_MAIL, APP_VERSION
    Run("mailto:" APP_MAIL "?subject=" UrlEncode(T("feedback.mail.subject") " (v" APP_VERSION ")")
        . "&body=" UrlEncode(T("feedback.mail.body") "--`nDeskTabs " APP_VERSION ", Windows " A_OSVersion "`n" EnvSummary()))
}

; --- Update-Pruefung: GitHub-Releases-API, nur die Versionsnummer wird gelesen ---
HttpGetText(url, timeoutMs := 4000) {
    global APP_VERSION
    try {
        req := ComObject("WinHttp.WinHttpRequest.5.1")
        req.SetTimeouts(timeoutMs, timeoutMs, timeoutMs, timeoutMs)
        req.Open("GET", url, false)
        req.SetRequestHeader("User-Agent", "DeskTabs/" APP_VERSION)
        req.SetRequestHeader("Accept", "application/vnd.github+json")
        req.Send()
        if (req.Status = 200)
            return req.ResponseText
    }
    return ""
}

FetchLatestTag() {
    global APP_API_LATEST
    body := HttpGetText(APP_API_LATEST)
    return RegExMatch(body, '"tag_name"\s*:\s*"([^"]+)"', &m) ? m[1] : ""
}

; Vergleich zweier Versionsangaben ("v1.2.0", "1.10.1-dev"): 1 wenn a > b, -1 wenn a < b, 0 gleich
VersionCmp(a, b) {
    pa := StrSplit(RegExReplace(a, "^[vV]|-.*$"), "."), pb := StrSplit(RegExReplace(b, "^[vV]|-.*$"), ".")
    Loop Max(pa.Length, pb.Length) {
        x := (A_Index <= pa.Length) ? Integer(pa[A_Index]) : 0
        y := (A_Index <= pb.Length) ? Integer(pb[A_Index]) : 0
        if (x != y)
            return (x > y) ? 1 : -1
    }
    return 0
}

; manual=true: Ergebnis immer melden; sonst leise, Hinweis nur bei neuer Version
CheckUpdate(manual := false, *) {
    global APP_VERSION, APP_URL, gUpdateTag
    tag := FetchLatestTag()
    IniSet("State", "LastUpdateCheck", FormatTime(, "yyyyMMdd"))
    if (tag = "") {
        if (manual)
            MsgBox(T("update.error"), "DeskTabs", 0x30)
        return
    }
    if (VersionCmp(tag, APP_VERSION) > 0) {
        gUpdateTag := tag
        BuildTray()
        if (manual) {
            if (MsgBox(T("update.found", tag, APP_VERSION), "DeskTabs", 0x24) = "Yes")
                Run(APP_URL "/releases/latest")
        } else {
            TrayTip(T("update.tip", tag), "DeskTabs", 0x1)
        }
    } else {
        gUpdateTag := ""
        if (manual)
            MsgBox(T("update.none", APP_VERSION), "DeskTabs", 0x40)
    }
}

; Beim Start (verzoegert): hoechstens einmal pro Tag, nur wenn eingeschaltet
AutoUpdateTick() {
    if (!CONF["UpdateCheck"])
        return
    if (IniRead(CONF["IniPath"], "State", "LastUpdateCheck", "") = FormatTime(, "yyyyMMdd"))
        return
    CheckUpdate(false)
}

OpenReleasePage(*) {
    global APP_URL
    Run(APP_URL "/releases/latest")
}

; --- "Ueber"-Dialog ---
ShowAbout(*) {
    global APP_VERSION, APP_AUTHOR, APP_AUTHOR_URL, APP_URL, gAbout
    try gAbout.Destroy()
    g := Gui("+AlwaysOnTop +OwnDialogs -MinimizeBox -MaximizeBox", T("about.title"))
    g.SetFont("s10", "Segoe UI")
    g.MarginX := 20, g.MarginY := 16
    ico := AppIconPath()
    if FileExist(ico)
        g.Add("Picture", "x20 y18 w48 h48 Icon1", ico)
    g.SetFont("s14 bold")
    g.Add("Text", "x84 y16", "DeskTabs")
    g.SetFont("s10 norm")
    g.Add("Text", "x84 y+2", T("about.tagline"))
    g.Add("Text", "x84 y+4", T("about.version", APP_VERSION) "  ·  " T("about.author", APP_AUTHOR))
    g.Add("Text", "x20 y+18 w420", T("about.license"))
    g.Add("Text", "x20 y+2 w440", T("about.components", A_IsCompiled ? " " T("about.ahk") : ""))
    g.Add("Link", "x20 y+14", '<a href="' APP_AUTHOR_URL '">' T("about.website") '</a>    ·    '
        . '<a href="' APP_URL '">' T("about.github") '</a>    ·    '
        . '<a href="' APP_URL '/issues">' T("about.feedback") '</a>')
    btnCheck := g.Add("Button", "x20 y+18 w170", T("about.check"))
    btnCheck.OnEvent("Click", (*) => CheckUpdate(true))
    btnClose := g.Add("Button", "x+10 w120 Default", T("about.close"))
    btnClose.OnEvent("Click", (*) => g.Destroy())
    g.OnEvent("Escape", (*) => g.Destroy())
    g.OnEvent("Close", (*) => g.Destroy())
    gAbout := g
    SetGuiIcon(g)
    g.Show("AutoSize Center")
    btnClose.Focus()
}

; Fenstersymbol (Titelleiste) auf das DeskTabs-Icon setzen
SetGuiIcon(g) {
    ico := AppIconPath()
    if (A_IsCompiled || !FileExist(ico))   ; kompiliert: Fenster nutzen automatisch das exe-Icon
        return
    ; LoadImage(IMAGE_ICON=1, LR_LOADFROMFILE=0x10), WM_SETICON=0x80 (ICON_SMALL=0, ICON_BIG=1)
    for size, which in Map(16, 0, 32, 1) {
        h := DllCall("LoadImage", "Ptr", 0, "Str", ico, "UInt", 1, "Int", size, "Int", size, "UInt", 0x10, "Ptr")
        if (h)
            SendMessage(0x80, which, h, g.Hwnd)
    }
}

LogErr(err, mode) {
    try FileAppend(Format("[{1}] {2} | What={3} Line={4} Extra={5}`n"
        , A_Now, err.Message, (err.HasProp("What") ? err.What : ""), err.Line, (err.HasProp("Extra") ? err.Extra : "")), A_ScriptDir "\_error.log")
    return 1  ; Dialog unterdruecken, Thread beenden
}

VD(fn, args*) {
    return DllCall("VirtualDesktopAccessor\" fn, args*)
}

; Fenster auf alle Desktops pinnen und den Change-Hook auf die AKTUELLE Hwnd setzen.
; Muss nach jedem (Neu-)Aufbau der Leiste aufgerufen werden, da sich die Hwnd aendert.
ApplyWindowHooks() {
    global MyGui, MSG_VD_CHANGED
    DllCall("VirtualDesktopAccessor\PinWindow", "Ptr", MyGui.Hwnd)
    DllCall("VirtualDesktopAccessor\RegisterPostMessageHook", "Ptr", MyGui.Hwnd, "Int", MSG_VD_CHANGED)
}

; --------------------------- Theme-Erkennung --------------------------------
; Liest aus der Registry, ob die Taskleiste dunkel ist.
; SystemUsesLightTheme = 1 -> helle Taskleiste, 0 -> dunkel. Fehlt der Wert -> hell.
SystemIsDark() {
    try {
        v := RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "SystemUsesLightTheme")
        return (v = 0)
    }
    return false
}

; Ermittelt das anzuwendende Theme aus ThemeMode (auto/light/dark).
ResolveTheme() {
    mode := CONF["ThemeMode"]
    if (mode = "light")
        return "light"
    if (mode = "dark")
        return "dark"
    return SystemIsDark() ? "dark" : "light"   ; auto
}

; Uebernimmt den passenden Farbsatz in die aktiven CONF-Schluessel.
ApplyTheme() {
    global gTheme, THEME_LIGHT, THEME_DARK
    t := ResolveTheme()
    set := (t = "dark") ? THEME_DARK : THEME_LIGHT
    for k, val in set
        CONF[k] := val
    gTheme := t
}

GetDesktopCount() => VD("GetDesktopCount", "Int")
GetCurrentDesktop() => VD("GetCurrentDesktopNumber", "Int")

GetDesktopNameRaw(num) {
    buf := Buffer(1024, 0)
    ok := VD("GetDesktopName", "Int", num, "Ptr", buf, "Int", buf.Size, "Int")
    name := (ok ? StrGet(buf, "UTF-8") : "")
    return (name = "") ? "Desktop " (num + 1) : name
}

; Name auf maxLen Zeichen kuerzen (mit "…")
TruncName(name, maxLen) {
    if (StrLen(name) > maxLen)
        name := SubStr(name, 1, maxLen - 1) "…"
    return name
}

; Optionales Kuerzel pro Desktop aus settings.ini [Short] (z.B.  Acme Bakery=ACME )
ShortNameFor(num) => IniRead(CONF["IniPath"], "Short", GetDesktopNameRaw(num), "")

; Anzeige-Label je nach Kompakt-Stufe (gCompact):
;   full  -> "4 · Acme Bakery"     (MaxNameLen)
;   short -> "4 · BPH"  bzw. "4 · BauPunk…"   (Kuerzel, sonst ShortNameLen)
;   icon  -> "BPH"      bzw. "4"              (Kuerzel, sonst nur die Nummer)
LabelFor(num) {
    global gCompact
    sn := ShortNameFor(num)
    if (gCompact = "icon")
        return (sn != "") ? sn : String(num + 1)
    if (gCompact = "short")
        name := (sn != "") ? sn : TruncName(GetDesktopNameRaw(num), CONF["ShortNameLen"])
    else
        name := TruncName(GetDesktopNameRaw(num), CONF["MaxNameLen"])
    return (CONF["ShowIndex"] ? (num + 1) " · " : "") name
}

; Naechstkleinere / naechstgroessere Stufe ("" = keine)
SmallerLevel(lv) => (lv = "full") ? "short" : (lv = "short") ? "icon" : ""
LargerLevel(lv)  => (lv = "icon") ? "short" : (lv = "short") ? "full" : ""

; Farbe fuer den Akzentbalken eines Desktops. Palette nach Index, optional per
; settings.ini [Colors] mit Desktop-Name ueberschreibbar (z.B.  Miller & Sons=E5471D )
DesktopColor(num) {
    raw := GetDesktopNameRaw(num)
    ov := IniRead(CONF["IniPath"], "Colors", raw, "")
    if (ov != "")
        return Integer("0x" StrReplace(ov, "0x", ""))
    pal := CONF["Palette"]
    return pal[Mod(num, pal.Length) + 1]
}

px(v) => Round(v * SCALE)     ; logische px -> physische px

; --------------------------- Leiste aufbauen --------------------------------
; Waehlt die Kompakt-Stufe und baut die Leiste. Bei CompactMode=auto wird mit
; "full" begonnen und so lange eine Stufe runtergeschaltet, bis die Leiste
; ins Breiten-Budget (MaxBarWidthPct der Taskleistenbreite) passt.
BuildBar() {
    global gBuilding, gCompact, GUIW, gTaskbarW
    if (gBuilding)              ; verschachtelten Neuaufbau verhindern (Geometrie-Race)
        return
    gBuilding := true
    mode := CONF["CompactMode"]
    level := (mode = "auto") ? "full" : mode
    Loop {
        gCompact := level
        BuildBarAt()
        if (mode != "auto" || !gTaskbarW)
            break
        budget := gTaskbarW * CONF["MaxBarWidthPct"] / 100
        next := SmallerLevel(level)
        if (GUIW <= budget || next = "")
            break
        level := next               ; zu breit -> eine Stufe kleiner, nochmal bauen
    }
    gBuilding := false
}

BuildBarAt() {
    global MyGui, BTNS, GUIW, GUIH, gTaskbarW, gLayout
    if (MyGui) {
        try DllCall("VirtualDesktopAccessor\UnregisterPostMessageHook", "Ptr", MyGui.Hwnd)
        try MyGui.Destroy()
    }
    BTNS := []

    ; NOACTIVATE (0x08000000): Klicks klauen nicht den Fokus vom Arbeitsfenster
    MyGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000 -DPIScale")
    MyGui.BackColor := CONF["ColBarBg"]
    MyGui.SetFont("s" CONF["FontSizePt"] " c" Fmt(CONF["ColInactiveTx"]), CONF["FontName"])

    ; Taskleisten-Geometrie holen (Hoehe + untere Kante als Standard-Y)
    hTray := DllCall("FindWindow", "Str", "Shell_TrayWnd", "Ptr", 0, "Ptr")
    tbX := 0, tbY := 0, tbW := 0, tbH := 0
    if (hTray) {
        rc := Buffer(16, 0)
        DllCall("GetWindowRect", "Ptr", hTray, "Ptr", rc)
        tbX := NumGet(rc, 0, "Int"), tbY := NumGet(rc, 4, "Int")
        tbW := NumGet(rc, 8, "Int") - tbX, tbH := NumGet(rc, 12, "Int") - tbY
    } else {
        tbH := px(48), tbY := A_ScreenHeight - tbH
    }
    gTaskbarW := tbW

    margin := px(CONF["TabMargin"])
    btnH := tbH - 2 * margin
    if (btnH < px(20))
        btnH := px(20)

    cnt := GetDesktopCount()
    if (cnt < 1)
        cnt := 1

    ; Layout: Breiten der Tabs per GDI+ messen (die Leiste wird komplett gezeichnet,
    ; siehe RenderBar), Positionen in BTNS merken
    GdipStart()
    mBmp := 0, mG := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", 1, "Int", 1, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &mBmp)
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", mBmp, "Ptr*", &mG)
    font := MakeFont(), sf := MakeFormat()
    gap := px(CONF["Gap"])
    x := px(CONF["GripW"]) + gap
    iconSize := px(CONF["IconSize"]), iconGap := px(CONF["IconGap"])
    bigSize := Min(px(CONF["IconOnlySize"]), btnH - px(8))
    Loop cnt {
        num := A_Index - 1
        label := LabelFor(num)
        icon := CONF["ShowIcons"] ? IconPathFor(num) : ""
        big := (icon != "" && gCompact = "icon")  ; kleinste Stufe mit Symbol: gross und ohne Text
        if (big)
            label := ""
        iw := (icon != "") ? (big ? bigSize : iconSize) : 0
        tw := (label != "") ? MeasureText(mG, font, sf, label) : 0
        w := px(CONF["PadX"]) * 2 + iw + tw + ((iw && tw) ? iconGap : 0)
        if (big)
            w := Max(btnH, iw + px(12) * 2)       ; quadratische Kachel wie die Taskleisten-Buttons
        BTNS.Push(Map("num", num, "label", label, "icon", icon, "iw", iw, "x", x, "w", w, "hover", false))
        x += w
        if (A_Index < cnt)
            x += gap
    }
    DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
    DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", mG)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", mBmp)
    x += gap                                   ; etwas Luft am rechten Rand

    GUIW := x
    GUIH := tbH
    gLayout := Map("margin", margin, "btnH", btnH, "gripW", px(CONF["GripW"]), "gap", gap
        , "radius", px(CONF["CornerRadius"]), "accH", px(CONF["AccentBarH"])
        , "iconSize", iconSize, "iconGap", iconGap)

    ; Position: aus settings.ini, sonst Standard = unten links.
    ; "above" => direkt ueber der Taskleiste (sicher sichtbar)
    ; "on"    => auf der Taskleiste
    defX := tbX + px(CONF["OffsetX"])
    defY := (CONF["DockMode"] = "above") ? (tbY - GUIH) : tbY
    posX := IniGet("Position", "X", defX)
    posY := IniGet("Position", "Y", defY)
    posX := ClampX(posX), posY := ClampY(posY, GUIH)
    ; Startposition vertikal auf die Taskleiste einrasten (wie beim Ziehen)
    if (CONF["SnapToTaskbar"]) {
        snapY := (CONF["DockMode"] = "above") ? (tbY - GUIH) : (tbY + (tbH - GUIH) // 2)
        if (((posY < tbY + tbH) && (posY + GUIH > tbY)) || (Abs(posY - snapY) <= px(CONF["SnapDistance"])))
            posY := snapY
    }

    ; Eigenes Zeichnen: WM_PAINT blittet das Pufferbild, WM_ERASEBKGND wird
    ; unterdrueckt -> kein Flackern bei Hover/Refresh
    OnMessage(0x000F, OnPaint)        ; WM_PAINT
    OnMessage(0x0014, OnEraseBkgnd)   ; WM_ERASEBKGND
    RenderBar(true)
    MyGui.Show(Format("x{1} y{2} w{3} h{4} NoActivate", posX, posY, GUIW, GUIH))

    ; Maus: Ziehen am Griff (LBUTTONDOWN), Tab-Klick (LBUTTONUP)
    OnMessage(0x0201, OnLButtonDown)  ; WM_LBUTTONDOWN
    OnMessage(0x0202, OnLButtonUp)    ; WM_LBUTTONUP
    OnMessage(0x0020, OnSetCursor)    ; WM_SETCURSOR -> Verschiebe-Zeiger ueber dem Griff
}

; --------------------------- Zeichnen (GDI+) --------------------------------
; Die Leiste ist ein einziges Bild: Griff, abgerundete Tabs, Text, Farbbalken.
; Zustaende (aktiv/hover) aendern nur das Bild, keine Controls.
GdipStart() {
    global gGdipToken
    if (gGdipToken)
        return
    DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")
    si := Buffer(24, 0), NumPut("UInt", 1, si)
    tok := 0
    DllCall("gdiplus\GdiplusStartup", "Ptr*", &tok, "Ptr", si, "Ptr", 0)
    gGdipToken := tok
}

ARGB(rgb, a := 255) => (a << 24) | (rgb & 0xFFFFFF)

; fg mit pct % Deckkraft ueber bg mischen (Toenung auf opakem Grund)
Mix(fg, bg, pct) {
    r := ((fg >> 16 & 0xFF) * pct + (bg >> 16 & 0xFF) * (100 - pct)) // 100
    g := ((fg >> 8 & 0xFF) * pct + (bg >> 8 & 0xFF) * (100 - pct)) // 100
    b := ((fg & 0xFF) * pct + (bg & 0xFF) * (100 - pct)) // 100
    return (r << 16) | (g << 8) | b
}

; --- Farbton-Rechnung: dieselbe Farbe, andere Helligkeit (statt Mischen mit Grau,
; das bunte Toene schmutzig macht) ---
RgbToHsl(rgb) {
    r := (rgb >> 16 & 0xFF) / 255, g := (rgb >> 8 & 0xFF) / 255, b := (rgb & 0xFF) / 255
    mx := Max(r, g, b), mn := Min(r, g, b), l := (mx + mn) / 2
    if (mx = mn)
        return Map("h", 0, "s", 0, "l", l)
    d := mx - mn
    s := (l > 0.5) ? d / (2 - mx - mn) : d / (mx + mn)
    if (mx = r)
        h := (g - b) / d + (g < b ? 6 : 0)
    else if (mx = g)
        h := (b - r) / d + 2
    else
        h := (r - g) / d + 4
    return Map("h", h / 6, "s", s, "l", l)
}

Hue2Rgb(p, q, t) {
    if (t < 0)
        t += 1
    if (t > 1)
        t -= 1
    if (t < 1/6)
        return p + (q - p) * 6 * t
    if (t < 1/2)
        return q
    if (t < 2/3)
        return p + (q - p) * (2/3 - t) * 6
    return p
}

HslToRgb(h, s, l) {
    if (s = 0) {
        v := Round(l * 255)
        return (v << 16) | (v << 8) | v
    }
    q := (l < 0.5) ? l * (1 + s) : l + s - l * s
    p := 2 * l - q
    r := Round(Hue2Rgb(p, q, h + 1/3) * 255)
    g := Round(Hue2Rgb(p, q, h) * 255)
    b := Round(Hue2Rgb(p, q, h - 1/3) * 255)
    return (r << 16) | (g << 8) | b
}

; Fuellfarbe des aktiven Tabs: Farbton der Desktop-Farbe, Helligkeit aus dem Theme
TintFill(col) {
    hsl := RgbToHsl(col)
    return HslToRgb(hsl["h"], Min(1, hsl["s"] * CONF["TintS"] / 100), CONF["TintL"] / 100)
}

MakeFont(bold := false) {
    fam := 0, font := 0
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "Str", CONF["FontName"], "Ptr", 0, "Ptr*", &fam)
    if (!fam)
        DllCall("gdiplus\GdipGetGenericFontFamilySansSerif", "Ptr*", &fam)
    sizePx := CONF["FontSizePt"] * SCALE * 96 / 72
    DllCall("gdiplus\GdipCreateFont", "Ptr", fam, "Float", sizePx, "Int", bold ? 1 : 0, "Int", 2, "Ptr*", &font)  ; Unit 2 = Pixel
    DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", fam)
    return font
}

MakeFormat() {
    sf := 0
    DllCall("gdiplus\GdipCreateStringFormat", "Int", 0x1000 | 0x4000, "Int", 0, "Ptr*", &sf)  ; NoWrap | NoClip
    DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", sf, "Int", 1)       ; horizontal zentriert
    DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", sf, "Int", 1)   ; vertikal zentriert
    DllCall("gdiplus\GdipSetStringFormatTrimming", "Ptr", sf, "Int", 0)
    return sf
}

MeasureText(g, font, sf, s) {
    layout := Buffer(16, 0), bound := Buffer(16, 0)
    NumPut("Float", 0, "Float", 0, "Float", 10000, "Float", 1000, layout)
    DllCall("gdiplus\GdipMeasureString", "Ptr", g, "Str", s, "Int", -1, "Ptr", font, "Ptr", layout, "Ptr", sf, "Ptr", bound, "Ptr", 0, "Ptr", 0)
    return Ceil(NumGet(bound, 8, "Float"))
}

DrawText(g, font, sf, s, x, y, w, h, argb) {
    brush := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &brush)
    rect := Buffer(16, 0)
    NumPut("Float", x, "Float", y, "Float", w, "Float", h, rect)
    DllCall("gdiplus\GdipDrawString", "Ptr", g, "Str", s, "Int", -1, "Ptr", font, "Ptr", rect, "Ptr", sf, "Ptr", brush)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
}

RoundRectPath(x, y, w, h, r) {
    path := 0
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
    d := Min(r * 2, w, h)
    if (d <= 0) {
        DllCall("gdiplus\GdipAddPathRectangle", "Ptr", path, "Float", x, "Float", y, "Float", w, "Float", h)
        return path
    }
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x, "Float", y, "Float", d, "Float", d, "Float", 180, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + w - d, "Float", y, "Float", d, "Float", d, "Float", 270, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + w - d, "Float", y + h - d, "Float", d, "Float", d, "Float", 0, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x, "Float", y + h - d, "Float", d, "Float", d, "Float", 90, "Float", 90)
    DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
    return path
}

; Gefuellter Tab mit senkrechtem Verlauf: oben heller, unten dunkler (Fluent-Optik).
; pct = Gesamtspreizung in Prozent; 0 faellt auf eine flache Fuellung zurueck.
FillRoundRectGrad(g, x, y, w, h, r, fill, pct) {
    if (pct <= 0) {
        FillRoundRect(g, x, y, w, h, r, fill)
        return
    }
    rgb := fill & 0xFFFFFF
    top := ARGB(Mix(0xFFFFFF, rgb, pct))          ; oben etwas heller
    bot := ARGB(Mix(0x000000, rgb, Round(pct * 0.6)))  ; unten etwas dunkler
    rect := Buffer(16, 0)
    NumPut("Int", x, "Int", y - 1, "Int", w, "Int", h + 2, rect)   ; 1 px Luft gegen Kantenartefakte
    brush := 0
    DllCall("gdiplus\GdipCreateLineBrushFromRectI", "Ptr", rect, "UInt", top, "UInt", bot
        , "Int", 1, "Int", 0, "Ptr*", &brush)      ; 1 = LinearGradientModeVertical
    if (!brush) {
        FillRoundRect(g, x, y, w, h, r, fill)
        return
    }
    path := RoundRectPath(x, y, w, h, r)
    DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", brush, "Ptr", path)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
}

FillRoundRect(g, x, y, w, h, r, argb) {
    brush := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &brush)
    path := RoundRectPath(x, y, w, h, r)
    DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", brush, "Ptr", path)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
}

; Leiste komplett neu in den Puffer zeichnen und das Fenster neu blitten lassen.
; Ohne force nur, wenn sich der sichtbare Zustand geaendert hat.
RenderBar(force := false) {
    global BTNS, GUIW, GUIH, MyGui, gCurrent, gTheme, gLayout, gBarDC, gBarBmp, gRenderSig, gGripHover
    if (!MyGui || !gLayout)
        return
    sig := gCurrent "|" gTheme "|" CONF["ActiveStyle"] "|" CONF["ColorCoding"] "|" CONF["ShowDividers"] "|" gGripHover
    for item in BTNS
        sig .= (item["hover"] ? "h" : "-") item["icon"]
    if (!force && sig = gRenderSig)
        return
    gRenderSig := sig
    L := gLayout
    W := GUIW, H := GUIH
    pBmp := 0, g := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", W, "Int", H, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &pBmp)
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", pBmp, "Ptr*", &g)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)         ; AntiAlias
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 5)     ; ClearTypeGridFit (opaker Grund)
    DllCall("gdiplus\GdipSetInterpolationMode", "Ptr", g, "Int", 7)   ; HighQualityBicubic (Symbole)
    DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", g, "Int", 2)
    bg := CONF["ColBarBg"]
    DllCall("gdiplus\GdipGraphicsClear", "Ptr", g, "UInt", ARGB(bg))
    font := MakeFont(), sf := MakeFormat()
    y := L["margin"], h := L["btnH"], r := L["radius"]

    ; Griff (beim Drueberfahren leicht hervorgehoben)
    if (gGripHover)
        FillRoundRect(g, px(1), y, L["gripW"] - px(2), h, L["radius"]
            , ARGB(Mix(CONF["ColHoverBg"], bg, CONF["HoverPct"])))
    DrawText(g, font, sf, "≡", 0, y, L["gripW"], h
        , ARGB(gGripHover ? CONF["ColInactiveTx"] : CONF["ColGripTx"]))

    style := CONF["ActiveStyle"]
    grad := CONF["GradientPct"]
    for item in BTNS {
        x := item["x"], w := item["w"]
        col := DesktopColor(item["num"])
        active := (item["num"] = gCurrent)
        tx := CONF["ColInactiveTx"]
        if (active) {
            if (style = "solid") {
                FillRoundRectGrad(g, x, y, w, h, r, ARGB(CONF["ColActiveBg"]), grad)
                tx := CONF["ColActiveTx"]
            } else {
                base := (style = "accent") ? CONF["ColActiveBg"] : col
                FillRoundRectGrad(g, x, y, w, h, r, ARGB(TintFill(base)), grad)
            }
        } else if (item["hover"]) {
            ; wie der Windows-Taskleisten-Hover: der Tab wird HELLER, mit leichtem Verlauf
            FillRoundRectGrad(g, x, y, w, h, r, ARGB(Mix(CONF["ColHoverBg"], bg, CONF["HoverPct"])), grad)
        }
        ; Symbol links, Text daneben (bzw. nur eins von beidem)
        iw := item["iw"]
        tx0 := x + px(CONF["PadX"]), tw := w - 2 * px(CONF["PadX"])
        if (iw && item["label"] = "")
            tx0 := x + (w - iw) // 2              ; nur Symbol: mittig in der Kachel
        if (iw) {
            iy := y + (h - iw) // 2 - px(1)
            if (IsGlyphSpec(item["icon"])) {
                DrawGlyph(g, item["icon"], tx0, iy, iw, col)
            } else {
                img := LoadIconBitmap(item["icon"])
                if (img)
                    DllCall("gdiplus\GdipDrawImageRectI", "Ptr", g, "Ptr", img, "Int", tx0
                        , "Int", iy, "Int", iw, "Int", iw)
                else
                    iw := 0
            }
            tx0 += iw ? iw + L["iconGap"] : 0
            tw -= iw ? iw + L["iconGap"] : 0
        }
        if (item["label"] != "")
            DrawText(g, font, sf, item["label"], tx0, y, tw, h, ARGB(tx))
        ; Farbbalken unten im Tab (abgerundet, eingerueckt)
        if (CONF["ColorCoding"]) {
            iconOnly := (item["label"] = "" && iw)
            inset := iconOnly ? px(5) : px(10)
            ah := L["accH"] + (iconOnly ? px(1) : 0)   ; Symbol-Stufe: deutlicher Streifen als Kennung
            FillRoundRect(g, x + inset, y + h - ah - px(3), w - 2 * inset, ah, ah / 2, ARGB(col))
        }
        ; optionaler Trennstrich in der Luecke danach
        if (CONF["ShowDividers"] && A_Index < BTNS.Length) {
            dw := Max(1, px(1)), divH := h - 2 * px(CONF["DividerInsetY"])
            if (divH < px(8))
                divH := h
            FillRoundRect(g, x + w + (L["gap"] - dw) / 2, y + (h - divH) / 2, dw, divH, 0, ARGB(CONF["ColDivider"]))
        }
    }
    hbm := 0
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", pBmp, "Ptr*", &hbm, "UInt", ARGB(bg))
    if (!gBarDC)
        gBarDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
    DllCall("SelectObject", "Ptr", gBarDC, "Ptr", hbm, "Ptr")
    if (gBarBmp)
        DllCall("DeleteObject", "Ptr", gBarBmp)
    gBarBmp := hbm
    DllCall("InvalidateRect", "Ptr", MyGui.Hwnd, "Ptr", 0, "Int", 0)   ; ohne Loeschen
    DllCall("UpdateWindow", "Ptr", MyGui.Hwnd)
    DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
    DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", pBmp)
}

OnPaint(wParam, lParam, msg, hwnd) {
    global MyGui, GUIW, GUIH, gBarDC
    if (!MyGui || hwnd != MyGui.Hwnd || !gBarDC)
        return
    ps := Buffer(72, 0)
    hdc := DllCall("BeginPaint", "Ptr", hwnd, "Ptr", ps, "Ptr")
    DllCall("BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", GUIW, "Int", GUIH, "Ptr", gBarDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)  ; SRCCOPY
    DllCall("EndPaint", "Ptr", hwnd, "Ptr", ps)
    return 0
}

OnEraseBkgnd(wParam, lParam, msg, hwnd) {
    global MyGui
    if (MyGui && hwnd = MyGui.Hwnd)
        return 1                        ; Hintergrund nicht loeschen (WM_PAINT deckt alles)
}

; Ueber dem Griff zeigt Windows den Verschiebe-Zeiger (Vierfachpfeil), damit
; sichtbar ist, dass man die Leiste dort anfassen kann.
OnSetCursor(wParam, lParam, msg, hwnd) {
    global MyGui, gLayout
    if (!MyGui || !gLayout || hwnd != MyGui.Hwnd)
        return
    lx := BarMouseX()
    if (lx < 0 || lx >= gLayout["gripW"])
        return
    DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32646, "Ptr"))   ; IDC_SIZEALL
    return 1
}

; Tab an einer X-Position (Fensterkoordinaten), sonst 0
ItemAtX(lx) {
    global BTNS
    for item in BTNS
        if (lx >= item["x"] && lx < item["x"] + item["w"])
            return item
    return 0
}

; Mausposition relativ zur Leiste (-1 = nicht ueber der Leiste)
BarMouseX() {
    global MyGui
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my, &winId)
    if (!MyGui || winId != MyGui.Hwnd)
        return -1
    wx := 0, wy := 0
    MyGui.GetPos(&wx, &wy)
    return mx - wx
}

ClampX(x) {
    global GUIW
    if (x < 0)
        x := 0
    if (x + GUIW > A_ScreenWidth)
        x := A_ScreenWidth - GUIW
    return x
}
ClampY(y, h) {
    if (y < 0)
        y := 0
    if (y + h > A_ScreenHeight)
        y := A_ScreenHeight - h
    return y
}

; ------------------------------ Aktionen ------------------------------------
; Wechselt zu einem Desktop. "native" bildet Strg+Win+Pfeil nach -> Fenster
; bleiben stabil auf ihren Desktops (kein Mitwandern wie bei GoToDesktopNumber).
SwitchToDesktop(target) {
    global gSwitching, MyGui
    cur := GetCurrentDesktop()
    cnt := GetDesktopCount()
    if (target < 0 || target >= cnt || target = cur)
        return
    gSwitching := true            ; sperrt Rebuilds + Mausrad-Folgeticks waehrend des Wechsels
    if (CONF["SwitchMethod"] = "native") {
        steps := Abs(target - cur)
        key := (target > cur) ? "{Right}" : "{Left}"
        Loop steps {
            Send("#^" key)            ; Win+Strg+Pfeil
            if (A_Index < steps)      ; nur ZWISCHEN Schritten warten, nicht nach dem letzten -> snappy
                Sleep(80)
        }
    } else {
        ; Direktsprung in einem Schritt (~100 ms, keine Zwischen-Desktops).
        ; Sicherheitsnetz: Auf manchen Builds landet GoToDesktopNumber intern bei
        ; switch_desktop_and_move_foreground_view und nimmt das Vordergrundfenster
        ; mit. Gemessen auf 25H2/26200 passiert das nicht; falls doch, schieben wir
        ; das Fenster sofort auf seinen Desktop zurueck.
        fg := DllCall("GetForegroundWindow", "Ptr")
        fgDesk := (fg && fg != MyGui.Hwnd) ? VD("GetWindowDesktopNumber", "Ptr", fg, "Int") : -1
        VD("GoToDesktopNumber", "Int", target)
        if (fgDesk >= 0 && VD("GetWindowDesktopNumber", "Ptr", fg, "Int") != fgDesk)
            VD("MoveWindowToDesktopNumber", "Ptr", fg, "Int", fgDesk)
    }
    gSwitching := false
    UpdateHighlight()
}

BtnClick(num, *) {
    ; Klick auf den bereits aktiven Desktop -> Task-Ansicht oeffnen
    if (num = GetCurrentDesktop()) {
        if (CONF["ClickActiveTaskView"])
            Send("#{Tab}")
        return
    }
    SwitchToDesktop(num)
}

OnDesktopChanged(wParam, lParam, msg, hwnd) {
    UpdateHighlight()
}

OnWheel(wParam, lParam, msg, hwnd) {
    global MyGui, gSwitching
    ; Nur reagieren, wenn der Mauszeiger ueber unserer Leiste ist
    MouseGetPos(&mx, &my, &winHwnd)
    if (winHwnd != MyGui.Hwnd) {
        ; Pruefen ob ueber einem unserer Controls
        if !IsOverBar(mx, my)
            return
    }
    delta := (wParam >> 16) & 0xFFFF
    if (delta > 0x7FFF)
        delta -= 0x10000
    ; Strg + Mausrad ueber der Leiste: Kompakt-Stufe durchschalten statt Desktop wechseln
    if (GetKeyState("Ctrl", "P")) {
        CycleCompact(delta > 0 ? "up" : "down")
        return 0
    }
    ; Folgeticks ignorieren, solange ein Wechsel laeuft -> kein Stau, knackiger
    if (gSwitching)
        return 0
    cur := GetCurrentDesktop()
    cnt := GetDesktopCount()
    if (delta > 0)
        target := (cur - 1 < 0) ? 0 : cur - 1
    else
        target := (cur + 1 >= cnt) ? cnt - 1 : cur + 1
    if (target != cur)
        SwitchToDesktop(target)
    return 0
}

; Kompakt-Stufe manuell wechseln (Strg+Mausrad). "down" = kleiner, "up" = groesser;
; ueber "full" hinaus nach oben -> zurueck auf "auto". Die Wahl wird in
; settings.ini [View] gemerkt und beim Start wieder angewendet.
CycleCompact(dir) {
    global gCompact
    mode := CONF["CompactMode"]
    if (dir = "down") {
        new := SmallerLevel(gCompact)
    } else {
        new := (mode != "auto" && gCompact = "full") ? "auto" : LargerLevel(gCompact)
    }
    if (new = "" || new = mode)
        return
    CONF["CompactMode"] := new
    IniSet("View", "CompactMode", new)
    BuildBar()
    ApplyWindowHooks()
    UpdateHighlight()
    ; kurze Rueckmeldung, welche Stufe jetzt gilt
    txt := (new = "auto") ? T("view.tip", T("view.auto", T("level." gCompact))) : T("view.tip", T("level." new))
    ToolTip(txt)
    SetTimer(() => ToolTip(), -900)
}

IsOverBar(mx, my) {
    global MyGui, GUIW, GUIH
    x := 0, y := 0, w := 0, h := 0
    MyGui.GetPos(&x, &y, &w, &h)
    return (mx >= x && mx <= x + w && my >= y && my <= y + h)
}

; Eigene Drag-Routine: X folgt der Maus (frei), Y rastet auf die Taskleisten-Mitte
; ein, solange die Leiste die Taskleiste ueberlappt (oder nah dran ist). Ganz
; weggezogen wird Y frei. Deterministisch statt natives Drag + WM_MOVING.
OnLButtonDown(wParam, lParam, msg, hwnd) {
    global MyGui, GUIW, GUIH, gLayout
    if (!MyGui || (hwnd != MyGui.Hwnd && DllCall("GetParent", "Ptr", hwnd, "Ptr") != MyGui.Hwnd))
        return
    if (BarMouseX() >= gLayout["gripW"])   ; nur der Griff zieht
        return
    CoordMode("Mouse", "Screen")
    MouseGetPos(&sx, &sy)
    wx := 0, wy := 0, ww := 0, wh := 0
    MyGui.GetPos(&wx, &wy, &ww, &wh)
    offX := sx - wx, offY := sy - wy
    while GetKeyState("LButton", "P") {
        MouseGetPos(&mx, &my)
        nx := mx - offX, ny := my - offY
        hTray := DllCall("FindWindow", "Str", "Shell_TrayWnd", "Ptr", 0, "Ptr")
        if (hTray && CONF["SnapToTaskbar"]) {
            rc := Buffer(16, 0)
            DllCall("GetWindowRect", "Ptr", hTray, "Ptr", rc)
            tbY := NumGet(rc, 4, "Int"), tbBottom := NumGet(rc, 12, "Int")
            targetY := (CONF["DockMode"] = "above") ? (tbY - GUIH) : (tbY + ((tbBottom - tbY) - GUIH) // 2)
            overlaps := (ny < tbBottom) && (ny + GUIH > tbY)
            near := Abs(ny - targetY) <= px(CONF["SnapDistance"])
            if (overlaps || near)
                ny := targetY
        }
        if (nx < 0)
            nx := 0
        if (nx + GUIW > A_ScreenWidth)
            nx := A_ScreenWidth - GUIW
        MyGui.Move(nx, ny)
        Sleep(10)
    }
    SavePosDeferred()
    return 0
}

SavePosDeferred() {
    global MyGui
    x := 0, y := 0, w := 0, h := 0
    MyGui.GetPos(&x, &y, &w, &h)
    IniSet("Position", "X", x)
    IniSet("Position", "Y", y)
}

; ---------------------------- Hervorhebung ----------------------------------
; Tab-Klick (beim Loslassen, wie ein Button)
OnLButtonUp(wParam, lParam, msg, hwnd) {
    global MyGui
    if (!MyGui || (hwnd != MyGui.Hwnd && DllCall("GetParent", "Ptr", hwnd, "Ptr") != MyGui.Hwnd))
        return
    item := ItemAtX(BarMouseX())
    if (item)
        BtnClick(item["num"])
    return 0
}

UpdateHighlight() {
    global BTNS, gCurrent
    gCurrent := GetCurrentDesktop()
    LogDesktop(gCurrent)             ; Zeit-Log: Segmentwechsel bei Desktop-Wechsel
    RenderBar()
}

; Hover: Tab unter dem Mauszeiger leicht hervorheben
HoverTick() {
    global BTNS, gHidden, gBuilding, gGripHover, gLayout
    if (gHidden || gBuilding)       ; waehrend eines Neuaufbaus existiert die GUI kurz nicht
        return
    lx := BarMouseX()
    over := ItemAtX(lx)
    grip := (lx >= 0 && lx < gLayout["gripW"])
    changed := (grip != gGripHover)
    gGripHover := grip
    for item in BTNS {
        h := (over && item["num"] = over["num"])
        if (h != item["hover"]) {
            item["hover"] := h
            changed := true
        }
    }
    if (changed)
        RenderBar()
}
; Vollbild-App im Vordergrund -> Leiste ausblenden, sonst wieder zeigen
FullscreenTick() {
    global MyGui, gHidden, gBuilding
    if (gBuilding)                  ; waehrend eines Neuaufbaus existiert die GUI kurz nicht
        return
    fs := IsForegroundFullscreen()
    if (fs && !gHidden) {
        gHidden := true
        MyGui.Hide()
    } else if (!fs && gHidden) {
        gHidden := false
        MyGui.Show("NoActivate")
        ApplyWindowHooks()
        UpdateHighlight()
    }
}

; Liegt auf dem Monitor der Leiste ein Vollbildfenster ganz oben?
; Bewusst NICHT nur das Vordergrundfenster: Ist Lightroom auf dem Hauptmonitor
; im Vollbild und der Fokus wandert auf einen Nebenmonitor, bleibt Lightroom
; dort trotzdem das oberste Fenster -> die Leiste muss verborgen bleiben.
; Vorgehen: z-Reihenfolge von oben durchgehen, das erste "echte" sichtbare
; Fenster auf dem Leisten-Monitor nehmen und pruefen, ob es den Monitor fuellt.
IsForegroundFullscreen() {
    global MyGui
    hMonBar := DllCall("MonitorFromWindow", "Ptr", MyGui.Hwnd, "UInt", 2, "Ptr")   ; DEFAULTTONEAREST
    mi := Buffer(40, 0)
    NumPut("UInt", 40, mi, 0)
    DllCall("GetMonitorInfo", "Ptr", hMonBar, "Ptr", mi)
    ml := NumGet(mi, 4, "Int"), mt := NumGet(mi, 8, "Int")
    mr := NumGet(mi, 12, "Int"), mb := NumGet(mi, 16, "Int")
    monArea := (mr - ml) * (mb - mt)
    h := DllCall("GetTopWindow", "Ptr", 0, "Ptr")
    while (h) {
        hNext := DllCall("GetWindow", "Ptr", h, "UInt", 2, "Ptr")   ; GW_HWNDNEXT
        if (h != MyGui.Hwnd && DllCall("IsWindowVisible", "Ptr", h)) {
            cls := ""
            try cls := WinGetClass("ahk_id " h)
            ; Desktop/Taskleiste ueberspringen: die fuellen den Monitor immer
            if (cls != "" && cls != "WorkerW" && cls != "Progman" && cls != "Shell_TrayWnd" && cls != "Shell_SecondaryTrayWnd") {
                ex := DllCall("GetWindowLongPtr", "Ptr", h, "Int", -20, "Ptr")   ; GWL_EXSTYLE
                cloaked := 0
                DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", h, "UInt", 14, "UInt*", &cloaked, "UInt", 4)  ; DWMWA_CLOAKED
                ; Tool-Windows (Overlays, Tooltips) und gecloakte Fenster (andere
                ; virtuelle Desktops, UWP-Hintergrund) zaehlen nicht
                if (!(ex & 0x80) && !cloaked) {
                    wr := Buffer(16, 0)
                    DllCall("GetWindowRect", "Ptr", h, "Ptr", wr)
                    wl := NumGet(wr, 0, "Int"), wt := NumGet(wr, 4, "Int")
                    wri := NumGet(wr, 8, "Int"), wb := NumGet(wr, 12, "Int")
                    hMon := DllCall("MonitorFromWindow", "Ptr", h, "UInt", 2, "Ptr")
                    ; Erst ein Fenster mit >= 50 % der Monitorflaeche entscheidet. Alles
                    ; Kleinere sind Toolbars/Overlays/Helfer und werden uebersprungen,
                    ; sonst verdecken sie das darunterliegende Vollbildfenster (Lightroom
                    ; legt im Vollbild sein "BezelWindow", ~11 %, ueber den AgWinMainFrame).
                    if (hMon = hMonBar && (wri - wl) * (wb - wt) >= monArea * 0.50) {
                        ; "Umschliesst den ganzen Monitor" statt exakter Gleichheit:
                        ; rahmenlose Vollbildfenster (Lightroom Umschalt+F) ragen mit
                        ; unsichtbaren Raendern ueber den Monitorrand hinaus. Ein
                        ; maximiertes Normalfenster endet an der Arbeitsflaeche ueber
                        ; der Taskleiste (wb << mb) und zaehlt nicht als Vollbild.
                        tol := 8
                        return (wl <= ml + tol && wt <= mt + tol && wri >= mr - tol && wb >= mb - tol)
                    }
                }
            }
        }
        h := hNext
    }
    return false
}

AssertTop() {
    global MyGui, gHidden, gBuilding
    if (gHidden || gBuilding)       ; waehrend eines Neuaufbaus existiert die GUI kurz nicht
        return
    ; HWND_TOPMOST(-1), SWP_NOMOVE|SWP_NOSIZE|SWP_NOACTIVATE = 0x0013
    DllCall("SetWindowPos", "Ptr", MyGui.Hwnd, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0013)
}

; Wird bei jedem Vordergrund-Wechsel aufgerufen -> Leiste sofort wieder nach oben
WinEventProc(hHook, event, hwnd, idObject, idChild, thread, time) {
    global gHidden
    FullscreenTick()            ; ggf. aus-/einblenden bei Vollbild
    if (!gHidden) {
        AssertTop()             ; sofort ueber das neue Fenster / die Taskleiste
        StartBurst()            ; + kurzer Burst, um die Maximier-Animation abzudecken
    }
}

; Holt die Leiste fuer ~250 ms im 25-ms-Takt wiederholt nach oben (Animationsphase).
StartBurst() {
    global gBurst
    gBurst := 10
    SetTimer(BurstTick, 25)
}
BurstTick() {
    global gBurst, gHidden
    if (!gHidden)
        AssertTop()
    gBurst--
    if (gBurst <= 0)
        SetTimer(BurstTick, 0)   ; Burst beenden
}

Refresh() {
    ; Desktop-Anzahl oder Namen koennten sich geaendert haben -> ggf. neu bauen
    global BTNS, gTheme, gBuilding, gSwitching
    LogIdleTick()                  ; Zeit-Log: Inaktivitaet erkennen (braucht keine GUI)
    if (gBuilding || gSwitching)   ; nicht mitten in Aufbau/Wechsel neu bauen (Geometrie-Race)
        return
    ; Windows-Theme gewechselt? -> Farbsatz neu anwenden und Leiste neu bauen
    if (ResolveTheme() != gTheme) {
        ApplyTheme()
        BuildBar()
        ApplyWindowHooks()
        UpdateHighlight()
        return
    }
    ; settings.ini von aussen geaendert (z.B. von einem KI-Agenten: Kuerzel,
    ; Farben, Ansicht)? -> live uebernehmen, kein Neustart noetig
    if (SettingsChanged()) {
        ApplyIniOverrides()
        InitLanguage()
        BuildTray()
        ApplyTheme()
        BuildBar()
        ApplyWindowHooks()
        UpdateHighlight()
        return
    }
    if (GetDesktopCount() != BTNS.Length) {
        BuildBar()
        ApplyWindowHooks()
    } else {
        ; Hat sich ein Name geaendert? -> KOMPLETT neu bauen, damit die Button-BREITEN
        ; zur neuen Textlaenge passen. Reines c.Text := ... laesst die Breite stehen
        ; -> lange Namen werden abgeschnitten und die Abstaende kollabieren.
        nameChanged := false
        for item in BTNS {
            if (item["label"] != LabelFor(item["num"])) {
                nameChanged := true
                break
            }
        }
        if (nameChanged) {
            BuildBar()
            ApplyWindowHooks()
        }
    }
    UpdateHighlight()
}

; ------------------------------- Tray ---------------------------------------
BuildTray() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("DeskTabs", (*) => 0)
    A_TrayMenu.Disable("DeskTabs")
    A_TrayMenu.Add()
    FillSettingsMenu(A_TrayMenu)
    A_TrayMenu.Default := T("menu.about")
    ; kompiliert: die exe traegt das Icon bereits (Ahk2Exe-SetMainIcon)
    if (!A_IsCompiled && FileExist(AppIconPath()))
        TraySetIcon(AppIconPath(), 1)
    A_IconTip := "DeskTabs " APP_VERSION
}

ResetPos(*) {
    global MyGui, GUIW, GUIH
    hTray := DllCall("FindWindow", "Str", "Shell_TrayWnd", "Ptr", 0, "Ptr")
    tbX := 0, tbY := A_ScreenHeight - GUIH
    if (hTray) {
        rc := Buffer(16, 0)
        DllCall("GetWindowRect", "Ptr", hTray, "Ptr", rc)
        tbX := NumGet(rc, 0, "Int"), tbY := NumGet(rc, 4, "Int")
    }
    x := tbX + px(CONF["OffsetX"])
    y := (CONF["DockMode"] = "above") ? (tbY - GUIH) : tbY
    MyGui.Move(x, y)
    IniSet("Position", "X", x)
    IniSet("Position", "Y", y)
}

; ------------------------------- Utils --------------------------------------
Fmt(color) => Format("{:06X}", color)

IniGet(sec, key, default) {
    val := IniRead(CONF["IniPath"], sec, key, "")
    return (val = "") ? default : val + 0
}
IniSet(sec, key, val) {
    global gIniStamp
    IniWrite(val, CONF["IniPath"], sec, key)
    try gIniStamp := FileGetTime(CONF["IniPath"], "M")   ; eigener Schreibzugriff, kein Live-Reload
}
IniDel(sec, key) {
    global gIniStamp
    try IniDelete(CONF["IniPath"], sec, key)
    try gIniStamp := FileGetTime(CONF["IniPath"], "M")
}

OnExitCleanup(*) {
    global VDA, gWinEventHook, gWinEventCb
    LogClose()                                  ; Zeit-Log: letztes Segment abschliessen
    if (CONF["TimeLog"])
        try DllCall("Wtsapi32\WTSUnRegisterSessionNotification", "Ptr", A_ScriptHwnd)
    if (gWinEventHook)
        DllCall("UnhookWinEvent", "Ptr", gWinEventHook)
    if (gWinEventCb)
        CallbackFree(gWinEventCb)
    if (VDA)
        DllCall("FreeLibrary", "Ptr", VDA)
}
OnExit(OnExitCleanup)
