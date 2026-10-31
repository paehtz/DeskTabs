#Requires AutoHotkey v2.0
#SingleInstance Off      ; selbst geregelt: /cmd reicht Befehle weiter, sonst ersetzt ein Start die laufende Leiste
;@Ahk2Exe-SetMainIcon DeskTabs.ico
;@Ahk2Exe-SetName DeskTabs
;@Ahk2Exe-SetDescription DeskTabs - clickable taskbar buttons for Windows 11 virtual desktops
;@Ahk2Exe-SetCopyright Henning Pähtz (GPL-3.0-or-later)
;@Ahk2Exe-SetVersion 1.1.20.0
; ============================================================================
;  DeskTabs  —  klickbare Buttons fuer virtuelle Desktops (Win 11)
;  Von Henning Pähtz (paehtz.de), baut auf Ciantic/VirtualDesktopAccessor.dll
;  Lizenz: GNU GPL v3 oder spaeter, mit Zusatzbedingungen nach Abschnitt 7
;  (Namensnennung, siehe NOTICE). Bis Version 1.1.8 MIT.
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
global APP_VERSION := "1.1.20"
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
    "PadX",           18,      ; Innenabstand links/rechts im Tab (px @100%), Minimum bei wenig Platz
    "PadXMax",        24,      ; ... und so viel, solange die Leiste ins Platzbudget passt (MaxBarWidthPct)
    "Gap",            4,       ; Abstand zwischen den Tabs (px @100%), wie zwischen Taskleisten-Buttons
    "GripW",          16,      ; Breite des Ziehgriffs (px @100%)
    "SwitchMethod",   "dll",   ; "dll"    = Direktsprung per GoToDesktopNumber (Standard, ohne Zwischen-Desktops)
                               ; "native" = Strg+Win+Pfeil nachbilden, Desktop fuer Desktop (Fallback; Menue "Direkt springen")
    "ColDivider",     0xCFCFCF, ; Trennstrich-Farbe (sanft, Material)
    "DividerInsetY",  9,       ; vertikaler Abstand des Trennstrichs oben/unten (px @100%)
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
    "ShowIndex",      0,       ; 1 = Nummer vor dem Namen ("3 · Acme Bakery")
    "ColorCoding",    1,       ; 1 = farbiger Akzentbalken pro Desktop unten am Button
    "AccentBarH",     3,       ; Hoehe des Farbbalkens (px @100%)
    "TabShape",       "tabs",  ; Form: "tabs" = freistehende Tabs | "register" = aktiver Tab haengt an einer farbigen Kante ueber die ganze Taskleiste
    "ActiveStyle",    "desktop", ; aktiver Tab: "desktop" = eigene Desktop-Farbe, getoent | "accent" = Windows-Akzentfarbe, getoent | "solid" = kraeftig gefuellt
    "TintL",          86,      ; Helligkeit (%) des getoenten aktiven Tabs - Farbton bleibt, nur heller (je Theme ueberschrieben)
    "TintS",          100,     ; Anteil (%) der Original-Saettigung im getoenten Tab
    "CornerRadius",   4,       ; Eckenradius der Tabs (px @100%), wie Windows-11-Taskleisten-Buttons
    "TabMargin",      4,       ; Abstand der Tabs zum oberen/unteren Rand der Leiste (px @100%)
    "ShowDividers",   0,       ; 1 = duenne Trennstriche zwischen den Tabs
    "ShowIcons",      1,       ; 1 = Symbole aus settings.ini [Icons] im Tab zeigen
    "DefaultIcons",   1,       ; Desktops ohne eigenes Symbol: 1 = eines aus einem Vorschlagssatz, 2 = ihre Nummer, 0 = keins
                               ;     (nur Anzeige, nichts wird in die Datei geschrieben; "Symbol entfernen" hebt es auf)
    "NumberBadge",    "auto",  ; kleine Nummer oben links am Symbol: "auto" = wenn die Tastenkuerzel an sind | "on" | "off"
    "IconSize",       18,      ; Kantenlaenge des Symbols neben dem Text (px @100%)
    "IconOnlySize",   24,      ; Kantenlaenge in der Stufe "nur Symbol" (px @100%), wie die Taskleisten-Symbole
    "IconGap",        7,       ; Abstand zwischen Symbol und Text (px @100%)
    "IconFont",       "Segoe Fluent Icons",  ; Symbolschrift von Windows 11 (Fallback: Segoe MDL2 Assets)
    "ColHoverBg",     0xFFFFFF, ; Hover-Farbe: wird mit HoverPct ueber den Leistengrund gelegt (Windows hellt auf)
    "ColHoverTx",     0x1F1F1F,
    "HoverPct",      58,      ; Deckkraft (%) der Hover-Aufhellung; je Theme ueberschrieben
    "GradientPct",   14,      ; Staerke des senkrechten Verlaufs in gefuellten Tabs (0 = flach), wie bei Fluent-Buttons
    "ActiveShadow",  1,       ; 1 = harter Schatten unter dem aktiven Tab: er wirkt leicht abgehoben (Menue: Aktiver Desktop)
    "ActiveBold",    0,       ; 1 = Beschriftung des aktiven Desktops fett (im Ansicht-Menue schaltbar)
    "ActiveBarBoost", 2,      ; um so viele px waechst der Farbbalken des aktiven Desktops (px @100%)
    "AutoHideFullscreen", 1,   ; 1 = Leiste ausblenden, wenn Vollbild-App im Vordergrund
    "ClickActiveTaskView", 0,  ; 1 = Klick auf aktiven Desktop oeffnet Task-Ansicht (Win+Tab); aus: versehentliche Klicks nervten
    "Palette",        [0xE5471D, 0x2E7D32, 0x1565C0, 0x6A1B9A, 0xEF6C00, 0x00838F, 0xC2185B, 0x558B2F],
    "MaxNameLen",     22,      ; Stufe "full": Namen laenger als das werden gekuerzt
    "CompactMode",    "auto",  ; "auto" = Stufe nach Platz waehlen | "full" | "short" | "icon" (fest)
    "MaxBarWidthPct", 40,      ; auto: max. Anteil der Taskleistenbreite, bevor eine Stufe runtergeschaltet wird
    "ShortNameLen",   8,       ; Stufe "short": Namen laenger als das werden gekuerzt
    "TimeLog",        1,       ; 1 = Aufenthaltszeit pro Desktop als CSV protokollieren (timelog\desktop-log_YYYY-MM.csv)
    "TimeLogMinSec",  5,       ; kuerzere Aufenthalte (Durchfahrten) nicht eintragen, Zeit zaehlt zum Ziel-Desktop
    "TimeLogIdleMin", 5,       ; nach so vielen Minuten ohne Eingabe gilt "Pause": Segment wird geschlossen
    "CallHotkey",     "^#t",   ; Gespraech auf dem aktuellen Desktop starten/beenden ("" = kein Kuerzel)
    "Language",       "auto",  ; "auto" = Windows-Anzeigesprache | "de" | "en" | Code einer lang\xx.ini
    "UpdateCheck",    1,       ; 1 = einmal taeglich bei GitHub nach einer neueren Version fragen (nur Versionsnummer, keine Daten)
    "Hotkeys",        0,       ; 1 = Tastenkuerzel fuer den Direktsprung (Ziffernreihe UND Ziffernblock)
    "DragToTab",      1,       ; 1 = Fenster an der Titelleiste auf einen Tab ziehen schickt es auf diesen Desktop
    "RestoreZOrder",  1,       ; 1 = je Desktop merken, welche Fenster vorne lagen, und das beim Zurueckkommen wiederherstellen
    "AttentionDot",   1,       ; 1 = Punkt am Tab, wenn ein Programm auf einem anderen Desktop blinkt
    "SwitchAlert",    1,       ; 1 = Desktop-Wechsel durch andere Programme melden (Tab blinkt, Rahmen bleibt)
    "ClaudeCode",     0,       ; 1 = Claude-Code-Funktionen (Chat-Fenster am Projektkuerzel, gleich breit verteilen, /cmd)
    "HotkeyMod",      "^#"     ; Modifikator: "^#" Strg+Win | "^!" Strg+Alt | "#!" Win+Alt | "^+" Strg+Umschalt
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
    "TintL",         86,        ; hell: heller Ton in der Desktop-Farbe - der fette Text und der dicke Balken tragen das Erkennen, die Flaeche muss nur stuetzen
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
    "TintL",         32,        ; dunkel: derselbe Ton, etwas heller als die Leiste
    "TintS",         78,
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
global gSegSrc := "", gSegId := "", gSegAct := ""   ; Zeit-Log: Herkunft, Desktop-GUID, laufender Vorgang (Gespraech)
global gSwitchSrc := ""          ; Herkunft des naechsten eigenen Wechsels (click|key|wheel), fuer das Zeit-Log
global gGap := 0                 ; Zeit-Log: laufende Luecke Map(state, start, info) - idle|locked|suspended|paused
global gWasLocked := false       ; vor dem Ruhezustand gesperrt? (dann nach dem Aufwachen weiter "locked")
global gCall := 0                ; laufendes Gespraech Map(id, name, sub, start, tick), siehe StartCall
global gCallGui := 0, gCallDC := 0, gCallHbm := 0, gCallObm := 0, gCallConfirm := 0, gNoteGui := 0, gNoteHover := 0
global gNoteCtrls := Map()          ; Hwnd -> [Steuerelement, Grundfarbe, Hover-Farbe] der Bubbles
global gToast := 0, gToastDC := 0, gToastHbm := 0, gToastObm := 0, gToastXY := [0, 0, 0, 0]
global gSegSub := ""          ; Zeit-Log: Unterprojekt des laufenden Aufenthalts
global gLogCarry := "", gLogPend := 0   ; Zeit-Log-Filter: mitgenommene Uebergangszeit, wartender Eintrag

; ----------- Fenster verschieben, Aufmerksamkeit, zurueck zum letzten Desktop ----------

; Das Fenster, an dem der Nutzer gerade arbeitet (nicht die Leiste, nicht Taskleiste/Desktop)
WorkWindow() {
    global MyGui
    hwnd := DllCall("GetForegroundWindow", "Ptr")
    if (!hwnd || (MyGui && hwnd = MyGui.Hwnd))
        return 0
    cls := ""
    try cls := WinGetClass("ahk_id " hwnd)
    if (cls = "" || InStr(",Shell_TrayWnd,Shell_SecondaryTrayWnd,Progman,WorkerW,#32768,", "," cls ","))
        return 0
    return hwnd
}

; Aktives Fenster (Tastenkuerzel) bzw. ein bestimmtes Fenster (Tab-Menue) auf Desktop idx schicken.
; Man bleibt, wo man ist - das Fenster geht, nicht der Nutzer.
MoveActiveTo(idx, *) => MoveWindowTo(idx, WorkWindow())
; Fenster mitnehmen: erst verschieben (mit Bestaetigungsblinken), dann selbst dorthin
; wechseln und das Fenster wieder nach vorne holen
TakeActiveTo(idx, *) {
    hwnd := WorkWindow()
    if (hwnd)
        MoveWindowTo(idx, hwnd)
    SwitchToDesktop(idx)
    if (hwnd)
        try WinActivate("ahk_id " hwnd)
}
; Windows-Einstellung "auf allen Desktops anzeigen" wird respektiert:
;   nur dieses Fenster auf allen Desktops -> wer es gezielt verschiebt, will es dort haben:
;                                             Einstellung aufheben, verschieben, offen sagen
;   die ganze App auf allen Desktops       -> nichts anfassen (betraefe alle ihre Fenster), nur Hinweis
MoveWindowTo(idx, hwnd, *) {
    if (!hwnd || idx < 0 || idx >= GetDesktopCount() || !WinExist("ahk_id " hwnd))
        return
    pin := PinState(hwnd)
    if (pin = 2) {
        ShowBarTip(idx, T("tip.apppinned", TruncName(ProgName(hwnd), 30)), 5000)
        return
    }
    title := ""
    try title := WinGetTitle("ahk_id " hwnd)
    if (pin = 1)
        VD("UnPinWindow", "Ptr", hwnd)
    VD("MoveWindowToDesktopNumber", "Ptr", hwnd, "Int", idx)
    if (VD("GetWindowDesktopNumber", "Ptr", hwnd, "Int") = idx)
        StartConfirmBlink(idx)                 ; angekommen: Ziel-Tab blinkt zur Bestaetigung
    if (pin = 1 && idx = GetCurrentDesktop())           ; nicht verschoben, nur nicht mehr ueberall
        ShowBarTip(idx, T("tip.unpinned", TruncName(ProgName(hwnd), 30), GetDesktopNameRaw(idx)), 3500)
    else
        ShowBarTip(idx, T(pin = 1 ? "tip.movedunpinned" : "tip.moved", TruncName(title != "" ? title : "?", 40), GetDesktopNameRaw(idx)), 3500)
}

; 2 = die ganze App wird auf allen Desktops angezeigt, 1 = nur dieses Fenster, 0 = normal (ein Desktop)
PinState(hwnd) {
    if (!hwnd)
        return 0
    try if (VD("IsPinnedApp", "Ptr", hwnd, "Int") = 1)
        return 2
    try if (VD("IsPinnedWindow", "Ptr", hwnd, "Int") = 1)
        return 1
    return 0
}
; Fenster auf allen Desktops anzeigen bzw. wieder nur auf dem aktuellen (Griff-Menue, Ziehen auf den Griff)
TogglePinWindow(hwnd, *) {
    if (!hwnd || !WinExist("ahk_id " hwnd) || PinState(hwnd) = 2)
        return
    name := TruncName(ProgName(hwnd), 30)
    if (PinState(hwnd) = 1) {
        VD("UnPinWindow", "Ptr", hwnd)
        ShowBarTip(-2, T("tip.unpinned", name, GetDesktopNameRaw(GetCurrentDesktop())), 3500)
    } else {
        VD("PinWindow", "Ptr", hwnd)
        StartConfirmBlink(-2)                  ; -2 = der Griff
        ShowBarTip(-2, T("tip.pinned", name), 3500)
    }
}
; Tab-Menue: App nicht mehr auf allen Desktops, dieses Fenster landet auf Desktop idx
UnpinAppTo(idx, hwnd, *) {
    if (!hwnd || !WinExist("ahk_id " hwnd))
        return
    VD("UnPinApp", "Ptr", hwnd)
    if (idx != GetCurrentDesktop())
        VD("MoveWindowToDesktopNumber", "Ptr", hwnd, "Int", idx)
    StartConfirmBlink(idx)
    ShowBarTip(idx, T("tip.appunpinnedto", TruncName(ProgName(hwnd), 30), GetDesktopNameRaw(idx)), 3500)
}
; Alle Fenster der App auf allen Desktops (wie "Fenster dieser App auf allen Desktops anzeigen" in Windows)
TogglePinApp(hwnd, *) {
    if (!hwnd || !WinExist("ahk_id " hwnd))
        return
    name := TruncName(ProgName(hwnd), 30)
    if (PinState(hwnd) = 2) {
        VD("UnPinApp", "Ptr", hwnd)
        ShowBarTip(-2, T("tip.appunpinned", name), 3500)
    } else {
        VD("PinApp", "Ptr", hwnd)
        StartConfirmBlink(-2)
        ShowBarTip(-2, T("tip.apppinnednow", name), 3500)
    }
}

; Kurzinfo ueber einem Tab (Slot 3, verschwindet nach ms)
ShowBarTip(num, txt, ms) {
    global MyGui, BTNS, gHidden
    if (!MyGui || gHidden)
        return
    bx := 0, by := 0
    MyGui.GetPos(&bx, &by)
    ix := bx
    for item in BTNS
        if (item["num"] = num)
            ix := bx + item["x"]
    CoordMode("ToolTip", "Screen")
    static hide := () => ToolTip(, , , 3)     ; feste Referenz: neuer Aufruf verlaengert statt alter Timer kappt
    ToolTip(txt, ix, by - px(34), 3)
    SetTimer(hide, -ms)
}

; Blinkt ein Programm auf einem anderen Desktop (so ruft Windows sonst nur in der
; Taskleiste dieses Desktops um Aufmerksamkeit), bekommt dessen Tab einen Punkt.
InitAttentionWatch() {
    global gShellMsg
    gShellMsg := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
    DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)
    OnMessage(gShellMsg, OnShellHook)
}
OnShellHook(wParam, lParam, msg, hwnd) {
    global gAttention, gCurrent
    if (!CONF["AttentionDot"] || wParam != 0x8006)      ; HSHELL_FLASH
        return
    global gSelfTick
    if (A_TickCount - gSelfTick < 2000)   ; Blinken direkt nach einem eigenen Wechsel ist Windows'
        return                            ; Fokus-Gerangel (siehe FocusTopWindow), kein echter Ruf
    desk := -1
    try desk := VD("GetWindowDesktopNumber", "Ptr", lParam, "Int")
    if (desk >= 0 && desk != gCurrent && !gAttention.Has(desk)) {
        gAttention[desk] := true
        RenderBar()
    }
}

; Zurueck zum zuletzt genutzten Desktop (Tastenkuerzel oder Mittelklick auf die Leiste).
; "Genutzt" heisst: laenger als die Durchfahrt-Grenze des Zeit-Logs dort gewesen.
GoBack(*) {
    global gLastDesk
    if (gLastDesk >= 0 && gLastDesk < GetDesktopCount() && gLastDesk != GetCurrentDesktop())
        SwitchToDesktop(gLastDesk)
}
OnMButtonUp(wParam, lParam, msg, hwnd) {
    global MyGui
    if (!MyGui || (hwnd != MyGui.Hwnd && DllCall("GetParent", "Ptr", hwnd, "Ptr") != MyGui.Hwnd))
        return
    GoBack()
    return 0
}

AttentionSig() {
    global gAttention
    s := ""
    for k in gAttention
        s .= k ","
    return s
}

; ------------- Fenster per Titelleiste auf einen Tab ziehen -------------------
; Windows meldet Beginn und Ende jedes Fenster-Ziehens (EVENT_SYSTEM_MOVESIZESTART/END).
; Laesst man das Fenster ueber einem Tab los, wandert es auf diesen Desktop - an seine
; alte Stelle und in seinen alten Zustand (maximiert bleibt maximiert). Man selbst
; bleibt auf dem aktuellen Desktop.
InitDragWatch() {
    global gDragCb, gDragHook
    gDragCb := CallbackCreate(DragEventProc)
    gDragHook := DllCall("SetWinEventHook", "UInt", 0x000A, "UInt", 0x000B     ; MOVESIZESTART .. MOVESIZEEND
        , "Ptr", 0, "Ptr", gDragCb, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr")
}
DragEventProc(hHook, event, hwnd, idObject, idChild, thread, time) {
    global gDragHwnd, gDragPlace, gDragPin, MyGui
    if (idObject != 0 || !CONF["DragToTab"])
        return
    if (event = 0x000A) {
        if (MyGui && hwnd = MyGui.Hwnd)
            return
        wp := Buffer(44, 0)
        NumPut("UInt", 44, wp)
        DllCall("GetWindowPlacement", "Ptr", hwnd, "Ptr", wp)
        gDragHwnd := hwnd, gDragPlace := wp
        gDragPin := PinState(hwnd)                ; einmal zu Beginn: auf allen Desktops?
        ToolTip(, , , 4)                          ; Namens-Kurzinfo weg, beim Ziehen spricht DragTipTick
        global gHoverTipNum := -1
        SetTimer(DragTipTick, 40)
        return
    }
    ; Ende des Ziehens
    SetTimer(DragTipTick, 0)
    ToolTip(, , , 3)
    global gDragTipNum := -1
    if (hwnd != gDragHwnd || !gDragHwnd)
        return
    gDragHwnd := 0
    for it in BTNS                            ; Hover waehrend des Ziehens war geometrisch gesetzt
        it["hover"] := false
    RenderBar()
    num := DropTarget(DragBarX(), gDragPin)
    if (num = -1)
        return
    DllCall("SetWindowPlacement", "Ptr", hwnd, "Ptr", gDragPlace)   ; zurueck an den alten Platz
    if (num = -2)
        TogglePinWindow(hwnd)                 ; auf den Griff gezogen: auf allen Desktops (bzw. wieder nur hier)
    else
        MoveWindowTo(num, hwnd)
}
; X-Position des Mauszeigers in der Leiste (geometrisch, auch wenn gerade ein Fenster
; daruebergezogen wird), -1 = nicht ueber der Leiste
DragBarX() {
    global MyGui, gHidden
    if (!MyGui || gHidden)
        return -1
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    wx := 0, wy := 0, ww := 0, wh := 0
    MyGui.GetPos(&wx, &wy, &ww, &wh)
    slack := px(6)                            ; die Leiste ist flach: etwas Spielraum ober- und unterhalb
    if (mx < wx || mx >= wx + ww || my < wy - slack || my >= wy + wh + slack)
        return -1
    return mx - wx
}
; Was passiert beim Loslassen an Position lx? Desktop-Index, -2 = Griff (auf allen Desktops
; anzeigen bzw. wieder nur hier), -1 = nichts. pin = PinState des gezogenen Fensters.
DropTarget(lx, pin) {
    global gLayout
    if (lx < 0 || pin = 2)                    ; ganze App auf allen Desktops: nichts anfassen
        return -1
    if (lx < gLayout["gripW"])
        return -2
    item := ItemAtX(lx)
    if (!item)
        return -1
    ; der eigene Desktop nur, wenn das Fenster auf allen liegt: dann heisst es "nur noch hier"
    return (item["num"] != GetCurrentDesktop() || pin = 1) ? item["num"] : -1
}
; Waehrend des Ziehens: Ziel deutlich markieren und per Kurzinfo sagen, was beim Loslassen passiert.
; Der normale Hover (HoverTick) pausiert dann: er haengt am Fenster unter dem Mauszeiger
; und bliebe beim Ziehen auf dem zuletzt beruehrten Tab stehen. Hier gilt nur die Geometrie.
DragTipTick() {
    global gDragHwnd, gDragTipNum, gDragPin, BTNS
    lx := gDragHwnd ? DragBarX() : -1
    item := (lx >= 0) ? ItemAtX(lx) : 0
    changed := false
    for it in BTNS {
        h := (item && it["num"] = item["num"])
        if (h != it["hover"])
            it["hover"] := h, changed := true
    }
    num := DropTarget(lx, gDragPin)
    ; ganze App auf allen Desktops: nichts markieren, aber sagen, warum
    appTip := (gDragPin = 2 && lx >= 0) ? (item ? item["num"] : -2) : -99
    key := (appTip != -99) ? "a" appTip : num
    if (key = gDragTipNum) {
        if (changed)
            RenderBar()
        return
    }
    gDragTipNum := key
    RenderBar()                               ; Ziel deutlich markieren (siehe RenderBar)
    if (appTip != -99)
        ShowBarTip(appTip, T("tip.apppinned", TruncName(ProgName(gDragHwnd), 30)), 5000)
    else if (num = -1)
        ToolTip(, , , 3)
    else if (num = -2)
        ShowBarTip(-2, gDragPin = 1 ? T("tip.dropunpin", GetDesktopNameRaw(GetCurrentDesktop())) : T("tip.droppin"), 5000)
    else
        ShowBarTip(num, T(gDragPin = 1 ? "tip.dropmoveunpin" : "tip.dropmove", GetDesktopNameRaw(num)), 5000)
}

; Anzeigename eines Programms (Dateibeschreibung der exe, z.B. "Microsoft Word"),
; sonst der Prozessname ohne .exe
ProgName(hwnd) {
    path := "", name := ""
    try path := WinGetProcessPath("ahk_id " hwnd)
    try name := RegExReplace(WinGetProcessName("ahk_id " hwnd), "i)\.exe$")
    if (path != "") {
        size := DllCall("version\GetFileVersionInfoSizeW", "Str", path, "Ptr", 0, "UInt")
        if (size) {
            vi := Buffer(size, 0)
            if DllCall("version\GetFileVersionInfoW", "Str", path, "UInt", 0, "UInt", size, "Ptr", vi) {
                pt := 0, ln := 0
                if DllCall("version\VerQueryValueW", "Ptr", vi, "Str", "\VarFileInfo\Translation", "Ptr*", &pt, "UInt*", &ln) && ln >= 4 {
                    lang := Format("{:04X}{:04X}", NumGet(pt, 0, "UShort"), NumGet(pt, 2, "UShort"))
                    if DllCall("version\VerQueryValueW", "Ptr", vi, "Str", "\StringFileInfo\" lang "\FileDescription", "Ptr*", &pt, "UInt*", &ln) && ln > 1 {
                        d := Trim(StrGet(pt, ln, "UTF-16"))
                        if (d != "")
                            return d
                    }
                }
            }
        }
    }
    return (name != "") ? name : "?"
}

; ---------------- Fensterliste im Tab-Menue ("Fenster hierher holen") --------
; Alle normalen Fenster des aktuellen Desktops, wie sie auch Alt+Tab zeigt.
WindowsOnDesktop(desk) {
    global MyGui
    out := []
    for hwnd in WinGetList() {
        if (MyGui && hwnd = MyGui.Hwnd)
            continue
        try {
            if !(WinGetStyle("ahk_id " hwnd) & 0x10000000)                   ; WS_VISIBLE
                continue
            ex := WinGetExStyle("ahk_id " hwnd)
            if ((ex & 0x80) && !(ex & 0x40000))                                ; Werkzeugfenster ohne APPWINDOW
                continue
            if (DllCall("GetWindow", "Ptr", hwnd, "UInt", 4, "Ptr"))           ; hat Besitzer (Dialog o. ae.)
                continue
            title := WinGetTitle("ahk_id " hwnd)
            if (title = "" || InStr(",Shell_TrayWnd,Shell_SecondaryTrayWnd,Progman,WorkerW,", "," WinGetClass("ahk_id " hwnd) ","))
                continue
            if (VD("GetWindowDesktopNumber", "Ptr", hwnd, "Int") != desk)
                continue
            if (PinState(hwnd))                                                ; ohnehin auf allen Desktops
                continue
            out.Push(Map("hwnd", hwnd, "title", title, "proc", RegExReplace(WinGetProcessName("ahk_id " hwnd), "i)\.exe$")))
        }
        if (out.Length >= 25)
            break
    }
    return out
}

; ------------------------ Fremde Desktop-Wechsel ----------------------------
; Oeffnet man z.B. eine PDF und laeuft der Reader auf einem anderen Desktop, springt
; Windows still dorthin - und die Zeit landet unbemerkt beim falschen Projekt. Wechsel,
; die weder von DeskTabs noch von den Windows-Tastenkuerzeln oder der Task-Ansicht
; kommen, meldet die Leiste: der neue Tab blinkt, danach bleibt ein Rahmen, bis die
; Maus ueber ihn faehrt. Dazu eine kurze Kurzinfo, welches Programm es war.

; Windows-eigene Wechsel per Tastatur mitbekommen (~ = Taste geht normal durch)
InitSwitchWatch() {
    for , key in ["~^#Left", "~^#Right", "~^#d", "~^#F4"]
        try Hotkey(key, MarkKeySwitch)
    try Hotkey("~#Tab", MarkTaskView)
}
MarkKeySwitch(*) {
    global gKeyTick := A_TickCount
}
MarkTaskView(*) {
    global gTaskViewTick := A_TickCount
}

; Aus UpdateHighlight: war der Wechsel von from nach to "fremd"?
CheckForeignSwitch(from, to) {
    global gSelfTick, gKeyTick, gTaskViewTick, gPrevCount
    cnt := GetDesktopCount()
    countChanged := (gPrevCount && cnt != gPrevCount)   ; Desktop angelegt/entfernt: Windows wechselt selbst
    now := A_TickCount
    if (!CONF["SwitchAlert"] || countChanged
        || now - gSelfTick < 2000 || now - gKeyTick < 2000 || now - gTaskViewTick < 60000) {
        ClearSwitchAlert()                    ; gewollter Wechsel: alter Hinweis erledigt
        return
    }
    StartSwitchAlert(to)
}

StartConfirmBlink(num) {
    global gConfirmNum, gConfirmPhase
    gConfirmNum := num, gConfirmPhase := 4    ; 4 Phasen x 160 ms = zweimal aufblinken
    SetTimer(ConfirmTick, 160)
    RenderBar()
}
ConfirmTick() {
    global gConfirmNum, gConfirmPhase
    gConfirmPhase -= 1
    if (gConfirmPhase <= 0) {
        gConfirmPhase := 0, gConfirmNum := -1
        SetTimer(ConfirmTick, 0)
    }
    RenderBar()
}

StartSwitchAlert(num) {
    global gAlertNum, gAlertPhase
    gAlertNum := num, gAlertPhase := 8        ; 8 Phasen x 250 ms = viermal blinken
    SetTimer(SwitchAlertTick, 250)
    ShowSwitchTip(num)
    RenderBar()
}
SwitchAlertTick() {
    global gAlertPhase
    gAlertPhase -= 1
    if (gAlertPhase <= 0) {
        gAlertPhase := 0
        SetTimer(SwitchAlertTick, 0)
    }
    RenderBar()
}
ClearSwitchAlert() {
    global gAlertNum, gAlertPhase
    if (gAlertNum < 0)
        return
    gAlertNum := -1, gAlertPhase := 0
    SetTimer(SwitchAlertTick, 0)
    ToolTip(, , , 3)
    RenderBar()
}

; Kurzinfo ueber dem Tab: wohin gewechselt wurde und welches Programm vorne ist
ShowSwitchTip(num) {
    global MyGui, BTNS, gHidden
    if (!MyGui || gHidden)
        return
    proc := ""
    try proc := WinGetProcessName("A")
    name := GetDesktopNameRaw(num)
    txt := (proc != "" && proc != "explorer.exe") ? T("alert.switched", name, RegExReplace(proc, "i)\.exe$")) : T("alert.switched.noproc", name)
    bx := 0, by := 0
    MyGui.GetPos(&bx, &by)
    ix := bx
    for item in BTNS
        if (item["num"] = num)
            ix := bx + item["x"]
    CoordMode("ToolTip", "Screen")
    ToolTip(txt, ix, by - px(34), 3)
    SetTimer(() => ToolTip(, , , 3), -8000)
}

; Rahmen um einen Tab (fuer den Hinweis nach dem Blinken)
StrokeRoundRect(g, x, y, w, h, r, argb, lw) {
    pen := 0
    DllCall("gdiplus\GdipCreatePen1", "UInt", argb, "Float", lw, "Int", 2, "Ptr*", &pen)
    path := RoundRectPath(x + lw / 2, y + lw / 2, w - lw, h - lw, r)
    DllCall("gdiplus\GdipDrawPath", "Ptr", g, "Ptr", pen, "Ptr", path)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
}

; ------------------------------ Zeit-Log ------------------------------------
; Schreibt pro Aufenthalt auf einem Desktop eine CSV-Zeile (Monatsdatei im
; Unterordner timelog\): start,end,seconds,desktop_index,desktop_name. Gedacht fuer
; Nutzer ohne Time-Tracker und fuer Coding-Agenten, die daraus abrechnen.
LogDir() => A_ScriptDir "\timelog"
LogFile(ts) => LogDir() "\desktop-log_" SubStr(ts, 1, 4) "-" SubStr(ts, 5, 2) ".csv"

; Bis 1.1.4 lagen die Monatsdateien direkt neben dem Skript: einmalig in den
; Unterordner umziehen. Eine gleichnamige Datei dort wird nie ueberschrieben.
MigrateLogs() {
    Loop Files, A_ScriptDir "\desktop-log_*.csv" {
        try {
            DirCreate(LogDir())
            if !FileExist(LogDir() "\" A_LoopFileName)
                FileMove(A_LoopFileFullPath, LogDir() "\" A_LoopFileName)
        }
    }
}
IsoTime(ts) => FormatTime(ts, "yyyy-MM-dd'T'HH:mm:ss")
CsvQuote(s) => '"' StrReplace(s, '"', '""') '"'

LogOpen(num, src := "") {
    global gSegStart, gSegDesk, gSegName, gSegSub, gSegSrc, gSegId, gSegAct
    if (!CONF["TimeLog"])
        return
    gSegStart := A_Now, gSegDesk := num, gSegName := GetDesktopNameRaw(num), gSegSub := SubActive(num)
    gSegSrc := src, gSegId := DesktopGuid(num), gSegAct := CallLabel()
}

; Laufendes Segment abschliessen. endTime optional (z.B. Beginn einer Pause).
; hard = true (Pause, Sperre, Beenden, Log aus): alles sofort schreiben.
; hard = false (normaler Desktop-Wechsel): Durchfahrten und kurze Abstecher filtern.
;
; Filter (TimeLogMinSec): Ein Aufenthalt unter der Mindestzeit ist nur ein Uebergang.
; Er wird nicht geschrieben, seine Sekunden zaehlen zum naechsten echten Aufenthalt
; (Durchfahrt 1 -> 2 -> 3 -> 4: die Fahrzeit gehoert zu Desktop 4). Damit ein kurzer
; Abstecher A -> B -> A keinen zweiten A-Eintrag erzeugt, wartet jeder echte Eintrag
; in gLogPend, bis der naechste feststeht; setzt dieser denselben Desktop nahtlos
; fort, wird der wartende Eintrag einfach verlaengert.
LogClose(endTime := "", hard := true) {
    global gSegStart, gSegDesk, gSegName, gSegSub, gLogCarry, gLogPend, gSegSrc, gSegId, gSegAct
    if (!CONF["TimeLog"] || gSegStart = "") {
        if (hard)
            LogFlush()
        return
    }
    end := (endTime = "") ? A_Now : endTime
    start := (gLogCarry != "") ? gLogCarry : gSegStart   ; mitgenommene Uebergangszeit
    secs := DateDiff(end, gSegStart, "Seconds")
    gSegStart := ""
    if (!hard && secs < CONF["TimeLogMinSec"]) {
        if (gLogCarry = "")
            gLogCarry := start                           ; frueheste Startzeit der Durchfahrt merken
        return
    }
    gLogCarry := ""
    if (DateDiff(end, start, "Seconds") < 1) {
        if (hard)
            LogFlush()
        return
    }
    if (IsObject(gLogPend) && gLogPend["desk"] = gSegDesk && gLogPend["sub"] == gSegSub
        && gLogPend["act"] == gSegAct && gLogPend["end"] = start)
        gLogPend["end"] := end                           ; nahtlose Fortsetzung desselben Desktops (Unterprojekt, Gespraech)
    else {
        LogFlush()
        gLogPend := Map("start", start, "end", end, "desk", gSegDesk, "name", gSegName, "sub", gSegSub
            , "src", gSegSrc, "id", gSegId, "act", gSegAct)
    }
    if (hard)
        LogFlush()
}

; Wartenden Eintrag in die Monatsdatei schreiben
LogFlush() {
    global gLogPend, gLogCarry
    gLogCarry := ""
    if (!IsObject(gLogPend))
        return
    p := gLogPend, gLogPend := 0
    LogWriteRow(p["start"], p["end"], p["desk"] + 1, p["name"], p["sub"], "active", p["id"], p["src"], p["act"])
}

; Eine Zeile schreiben. Ueber Mitternacht wird geteilt: jeder Tag (und jede Monatsdatei)
; bekommt seinen eigenen Teil, der Folgeteil traegt als Herkunft "midnight".
LogWriteRow(start, end, idx, name, sub, state, id, src, act) {
    while (DateDiff(end, start, "Seconds") > 0) {
        midnight := DateAdd(SubStr(start, 1, 8), 1, "Days")
        cut := (DateDiff(end, midnight, "Seconds") > 0) ? midnight : end
        file := LogFile(start)
        try {
            DirCreate(LogDir())
            LogHeader(file)
            FileAppend(Format("{1},{2},{3},{4},{5},{6},{7},{8},{9},{10}`n", IsoTime(start), IsoTime(cut)
                , DateDiff(cut, start, "Seconds"), idx, CsvQuote(name), CsvQuote(sub), state, id, src, CsvQuote(act)), file, "UTF-8")
        }
        start := cut, src := "midnight"
    }
}

; Kopfzeile sicherstellen. Das Format waechst nur nach rechts: 1.1.12 kam "subproject" dazu,
; 1.1.16 "state", "desktop_id", "source" und "activity". Eine Monatsdatei mit aelterer
; Kopfzeile bekommt die neue (alte Zeilen bleiben, ihnen fehlen nur die neuen Spalten).
LogHeader(file) {
    static done := Map()
    if (done.Has(file))
        return
    head := "start,end,seconds,desktop_index,desktop_name,subproject,state,desktop_id,source,activity"
    if !FileExist(file)
        FileAppend(head "`n", file, "UTF-8")
    else {
        txt := FileRead(file, "UTF-8")
        p := InStr(txt, "`n")
        first := RTrim(SubStr(txt, 1, p - 1), "`r")
        if (p && first != head && SubStr(first, 1, 17) = "start,end,seconds") {
            f := FileOpen(file, "w", "UTF-8")       ; mit BOM, wie FileAppend sie anlegt
            f.Write(head "`n" SubStr(txt, p + 1)), f.Close()
        }
    }
    done[file] := true
}

; Desktop-Wechsel ins Log uebernehmen (aus UpdateHighlight)
LogDesktop(num) {
    global gSegDesk, gLogPaused
    static first := true
    if (!CONF["TimeLog"] || gLogPaused || num = gSegDesk)
        return
    LogClose("", false)
    LogOpen(num, first ? "start" : SwitchSource())
    first := false
}
; Woher kam der Wechsel? click|wheel|key (DeskTabs-Tasten oder Strg+Win+Pfeil)|taskview|other
SwitchSource() {
    global gSelfTick, gKeyTick, gTaskViewTick, gSwitchSrc
    now := A_TickCount
    if (now - gSelfTick < 2000) {
        s := (gSwitchSrc != "") ? gSwitchSrc : "click"
        gSwitchSrc := ""
        return s
    }
    if (now - gKeyTick < 2000)
        return "key"
    if (now - gTaskViewTick < 60000)
        return "taskview"
    return "other"
}

; ---- Luecken im Zeit-Log: statt still zu fehlen, steht jede Pause als eigene Zeile da ----
; state: idle (keine Eingabe), locked (Sperre), suspended (Ruhezustand), paused (vom Nutzer
; angehalten), off (DeskTabs lief nicht; beim Start nachgetragen). Desktop-Spalten leer.
GapBegin(state, ts := "", info := "") {
    global gGap, gLogPaused
    if (!CONF["TimeLog"])
        return
    ts := (ts = "") ? A_Now : ts
    if (IsObject(gGap))
        GapEnd(ts, false)
    else
        LogClose(ts)
    gGap := Map("state", state, "start", ts, "info", info)
    gLogPaused := true
}
GapEnd(ts := "", reopen := true, src := "resume") {
    global gGap, gLogPaused
    ts := (ts = "") ? A_Now : ts
    if (IsObject(gGap)) {
        g := gGap, gGap := 0
        LogFlush()
        if (DateDiff(ts, g["start"], "Seconds") >= 1)
            LogWriteRow(g["start"], ts, "", "", "", g["state"], "", g["info"], "")
    }
    gLogPaused := false
    if (reopen && CONF["TimeLog"])
        LogOpen(GetCurrentDesktop(), src)
}
GapIs(state) {
    global gGap
    return IsObject(gGap) && gGap["state"] = state
}

; Inaktivitaet: laeuft im Refresh-Takt. Nach TimeLogIdleMin Minuten ohne Eingabe beginnt
; rueckwirkend eine Luecke "idle"; mit der naechsten Eingabe endet sie. Waehrend eines
; Gespraechs zaehlt Stille am Rechner nicht als Pause.
LogIdleTick() {
    global gLogPaused, gCall
    if (!CONF["TimeLog"])
        return
    idleMs := A_TimeIdle
    thr := CONF["TimeLogIdleMin"] * 60000
    if (!gLogPaused && idleMs >= thr && !IsObject(gCall))
        GapBegin("idle", DateAdd(A_Now, -Round(idleMs / 1000), "Seconds"), "idle>" CONF["TimeLogIdleMin"] "min")
    else if (GapIs("idle") && idleMs < thr)
        GapEnd(DateAdd(A_Now, -Round(idleMs / 1000), "Seconds"))
}

; Bildschirm gesperrt/entsperrt (WM_WTSSESSION_CHANGE)
OnSessionChange(wParam, lParam, msg, hwnd) {
    if (GapIs("paused"))
        return
    if (wParam = 7)                   ; WTS_SESSION_LOCK
        GapBegin("locked")
    else if (wParam = 8 && GapIs("locked"))   ; WTS_SESSION_UNLOCK
        GapEnd()
}
; Ruhezustand (WM_POWERBROADCAST)
OnPowerBroadcast(wParam, lParam, msg, hwnd) {
    global gWasLocked
    if (!CONF["TimeLog"] || GapIs("paused"))
        return
    if (wParam = 4) {                 ; PBT_APMSUSPEND
        gWasLocked := GapIs("locked")
        GapBegin("suspended")
    } else if ((wParam = 7 || wParam = 0x12) && GapIs("suspended")) {   ; aufgewacht
        if (gWasLocked)
            GapBegin("locked")        ; weiter gesperrt bis zum Entsperren
        else
            GapEnd()
    }
}
; Beim Start: Zeit zwischen dem letzten Eintrag und jetzt als "off" nachtragen
LogOffGap() {
    if (!CONF["TimeLog"])
        return
    last := ""
    for , m in [A_Now, DateAdd(SubStr(A_Now, 1, 6) "01", -1, "Days")] {
        f := LogFile(m)
        if !FileExist(f)
            continue
        txt := ""
        try txt := FileRead(f, "UTF-8")
        lines := StrSplit(RTrim(txt, "`r`n"), "`n", "`r")
        if (lines.Length < 2)
            continue
        flds := StrSplit(lines[lines.Length], ",")
        if (flds.Length >= 2 && RegExMatch(flds[2], "^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d$"))
            last := RegExReplace(flds[2], "[-T:]")
        break
    }
    if (last != "" && DateDiff(A_Now, last, "Seconds") >= 60)
        LogWriteRow(last, A_Now, "", "", "", "off", "", "", "")
}
; Vom Nutzer angehalten (Menue Zeit-Log), z. B. beim Testen
ToggleLogPause(*) {
    if (GapIs("paused"))
        GapEnd(, true, "resume")
    else
        GapBegin("paused")
    BuildTray()
}

; ---- Timer: Pille ueber dem Tab, eigene Spalte "activity" im Zeit-Log ----
; Ein Timer fuer Desktop X (Telefonat, Arbeit ueber mehrere Desktops fuer einen Kunden)
; laeuft weiter, auch wenn man zwischendurch auf andere Desktops wechselt: jede Zeile traegt
; bis zum Beenden "timer:<Desktop>[ / <Unterprojekt>]", und Stille am Rechner gilt in der
; Zeit nicht als Pause. Beim Beenden fragt DeskTabs nach einer freiwilligen Notiz und traegt
; sie in alle Zeilen des Timers nach (" | <Notiz>"). Bis 1.1.17 hiess das "Gespraech" und
; die Zeilen "call:..." (alte Zeilen bleiben so). Start/Ende per Tab-Menue oder Tastenkuerzel
; (CallHotkey, Standard Strg+Win+T, gilt fuer den aktuellen Desktop).
CallLabel() {
    global gCall
    return IsObject(gCall) ? "timer:" gCall["name"] (gCall["sub"] != "" ? " / " gCall["sub"] : "") : ""
}
CallActiveOn(num) {
    global gCall
    return IsObject(gCall) && gCall["id"] = DesktopGuid(num)
}
CallDuration() {
    global gCall
    s := IsObject(gCall) ? DateDiff(A_Now, gCall["start"], "Seconds") : 0
    return (s >= 3600) ? Format("{}:{:02}:{:02}", s // 3600, Mod(s // 60, 60), Mod(s, 60)) : Format("{}:{:02}", s // 60, Mod(s, 60))
}
StartCall(num, *) {
    global gCall, gSegStart, gLogPaused
    if (IsObject(gCall))
        StopCall()
    if (GapIs("idle"))
        GapEnd()
    gCall := Map("id", DesktopGuid(num), "name", GetDesktopNameRaw(num), "sub", SubActive(num), "start", A_Now)
    IniSet("State", "Call", gCall["start"] "|" gCall["id"] "|" gCall["name"] "|" gCall["sub"])
    if (CONF["TimeLog"] && !gLogPaused && gSegStart != "") {   ; ab jetzt mit Gespraech
        LogClose(A_Now, true)
        LogOpen(GetCurrentDesktop(), "timer-start")
    }
    CallPillPaint()
    SetTimer(CallTick, 1000)
}
StopCall(*) {
    global gCall, gSegStart, gLogPaused
    if (!IsObject(gCall))
        return
    dur := CallDuration(), label := CallLabel(), since := gCall["start"], nm := gCall["name"]
    if (CONF["TimeLog"] && !gLogPaused && gSegStart != "")
        LogClose(A_Now, true)
    gCall := 0
    if (CONF["TimeLog"] && !gLogPaused && gSegStart = "")
        LogOpen(GetCurrentDesktop(), "timer-end")
    IniDel("State", "Call")
    SetTimer(CallTick, 0)
    CallPillHide()
    if (CONF["TimeLog"])                      ; freiwillige Notiz, leer oder Esc = keine; danach die Bestaetigungskarte
        return TimerNoteAsk(label, since, nm, dur)
    ToolTip(T("call.ended", dur), , , 3)
    SetTimer(() => ToolTip(, , , 3), -2500)
}

; ---- Notiz zum Timer: kleines Fenster mit den letzten Notizen dieses Desktops als Bubbles ----
; [TimerNotes] <Desktop>=*Angeheftet|Neueste|...  ("*" = angeheftet: bleibt vorn, faellt nie heraus;
; von den uebrigen bleiben die 6 zuletzt benutzten). Klick auf eine Bubble uebernimmt sie,
; x entfernt sie, Rechtsklick: anheften/loesen, bearbeiten, entfernen.
TimerNotes(desk) {
    out := []
    for , s in StrSplit(IniLookup("TimerNotes", desk), "|")
        if (Trim(s, " *") != "")
            out.Push(Map("text", Trim(LTrim(s, "*")), "pin", SubStr(s, 1, 1) = "*"))
    return out
}
TimerNotesSave(desk, list) {
    s := ""
    for it in list
        s .= (s = "" ? "" : "|") (it["pin"] ? "*" : "") it["text"]
    if (s = "")
        IniDelLoose("TimerNotes", desk)
    else
        IniSet("TimerNotes", desk, s)
}
; Benutzte Notiz nach vorn (angeheftete ganz vorn, sonst hinter die angehefteten)
TimerNoteUse(desk, note) {
    list := TimerNotes(desk), pin := false
    for i, it in list
        if (it["text"] = note) {
            pin := it["pin"], list.RemoveAt(i)
            break
        }
    pos := 1
    if (!pin)
        for it in list
            if (it["pin"])
                pos++
    list.InsertAt(pos, Map("text", note, "pin", pin))
    keep := [], n := 0
    for it in list
        if (it["pin"] || ++n <= 6)
            keep.Push(it)
    TimerNotesSave(desk, keep)
}
; "|" trennt die gespeicherten Notizen, Zeilenumbrueche haben im Log nichts zu suchen
CleanNote(s) => SubStr(Trim(RegExReplace(StrReplace(s, "|", "/"), "\s+", " ")), 1, 120)

TimerNoteAsk(label, since, desk, dur, text := "") {
    global gNoteGui, gNoteCtrls, gNoteHover
    static hooked := false
    try gNoteGui.Destroy()
    g := Gui("+AlwaysOnTop -MinimizeBox -MaximizeBox", T("timer.note.title"))
    gNoteGui := g, gNoteCtrls := Map(), gNoteHover := 0
    if (!hooked)
        OnMessage(0x20, NoteSetCursor), hooked := true          ; WM_SETCURSOR: Hand ueber den Bubbles
    g.SetFont("s10", "Segoe UI")
    g.MarginX := 20, g.MarginY := 16
    state := Map("done", false), names := Map()
    g.Add("Text", "xm w460", T("timer.note.text", desk, dur))
    ed := g.Add("Edit", "xm y+8 w460 r1", text)
    list := TimerNotes(desk)
    if (list.Length) {
        lb := g.Add("Text", "xm y+14 w460 cGray", T("timer.note.recent"))
        lb.GetPos(, &ly, , &lh)
        cx := 20, cy := ly + lh + 6, lim := 480, bottom := cy
        ; Eine Bubble = drei aneinanderliegende Felder mit gemeinsamem Rahmen: Notiz | ✎ | ×
        st := "h28 Border 0x200 Center BackgroundF3F3F3"
        for it in list {
            b := g.Add("Text", Format("x{} y{} {}", cx, cy, st), "   " (it["pin"] ? "📌 " : "") it["text"] "   ")
            b.GetPos(, , &bw)
            if (cx > 20 && cx + bw + 54 > lim) {             ; passt nicht mehr in die Zeile
                cx := 20, cy += 36
                b.Move(cx, cy)
            }
            e := g.Add("Text", Format("x{} y{} w28 {}", cx + bw - 1, cy, st), "✎")
            x := g.Add("Text", Format("x{} y{} w28 {}", cx + bw + 26, cy, st), "×")
            names[b.Hwnd] := it["text"]
            gNoteCtrls[b.Hwnd] := [b, "F3F3F3", "D3E3FD"], gNoteCtrls[e.Hwnd] := [e, "F3F3F3", "D3E3FD"]
            gNoteCtrls[x.Hwnd] := [x, "F3F3F3", "F9D6D5"]
            b.OnEvent("Click", Finish.Bind(it["text"]))
            e.OnEvent("Click", Rename.Bind(it["text"]))
            x.OnEvent("Click", Remove.Bind(it["text"]))
            cx += bw + 54 + 10, bottom := cy + 28
        }
        by := bottom + 18
    } else {
        hint := g.Add("Text", "xm y+10 w460 cGray", T("timer.note.hint"))
        hint.GetPos(, &hy, , &hh)
        by := hy + hh + 14
    }
    ok := g.Add("Button", Format("x20 y{} w130 Default", by), T("timer.note.save"))
    no := g.Add("Button", "x+10 yp w140", T("timer.note.skip"))
    ok.OnEvent("Click", (*) => Finish(ed.Value))
    no.OnEvent("Click", (*) => Finish(""))
    g.OnEvent("Escape", (*) => Finish(""))
    g.OnEvent("Close", (*) => Finish(""))
    g.OnEvent("ContextMenu", NoteMenu)
    SetGuiIcon(g)
    g.Show("AutoSize Center")
    ed.Focus()
    SetTimer(NoteHoverTick, 40)

    Finish(note, *) {
        if (state["done"])
            return
        state["done"] := true
        note := CleanNote(note)
        try g.Destroy()
        if (note != "") {
            LogSetNote(label, since, note)
            TimerNoteUse(desk, note)
        }
        ; sichtbare Bestaetigung am Tab des Desktops (sonst am Griff)
        num := -2
        Loop GetDesktopCount()
            if (GetDesktopNameRaw(A_Index - 1) = desk) {
                num := A_Index - 1
                break
            }
        if (note != "")
            ToastShow(num, T("timer.toast.saved", note, dur))
        else
            ToastShow(num, T("timer.toast.nonote", dur), 0xE916)
        if (note != "")
            StartConfirmBlink(num)
    }
    Reopen(newText) {
        state["done"] := true
        try g.Destroy()
        TimerNoteAsk(label, since, desk, dur, newText)
    }
    Remove(txt, *) {
        l := TimerNotes(desk)
        for i, it in l
            if (it["text"] = txt) {
                l.RemoveAt(i)
                break
            }
        TimerNotesSave(desk, l)
        Reopen(ed.Value)
    }
    Rename(txt, *) {                               ; neuer Text an derselben Stelle, angeheftet bleibt angeheftet
        g.Opt("+OwnDialogs")
        ib := InputBox(T("timer.note.renameq", txt), T("timer.note.title"), "w420 h130", txt)
        nt := CleanNote(ib.Value)
        if (ib.Result != "OK" || nt = "" || nt == txt)
            return
        l := TimerNotes(desk), out := []
        for it in l
            if (it["text"] = txt)
                it["text"] := nt, out.Push(it)
            else if (it["text"] != nt)
                out.Push(it)
        TimerNotesSave(desk, out)
        ; auch frueher eingetragene Notizen? Standard: nein (Enter aendert nichts rueckwirkend)
        n := LogRenameNote(desk, txt, nt, true)
        if (n && MsgBox(T("timer.note.retro", txt, n, desk, nt), T("timer.note.title"), "YesNo Icon? Default2") = "Yes")
            LogRenameNote(desk, txt, nt)
        Reopen(ed.Value)
    }
    TogglePin(txt, *) {
        l := TimerNotes(desk)
        for i, it in l
            if (it["text"] = txt) {
                it["pin"] := !it["pin"], l.RemoveAt(i), l.InsertAt(1, it)
                break
            }
        TimerNotesSave(desk, l)
        Reopen(ed.Value)
    }
    NoteMenu(gui, ctrl, *) {
        if (!ctrl || !names.Has(ctrl.Hwnd))
            return
        txt := names[ctrl.Hwnd], pinned := false
        for it in TimerNotes(desk)
            if (it["text"] = txt)
                pinned := it["pin"]
        m := Menu()
        m.Add(T(pinned ? "timer.note.unpin" : "timer.note.pin"), TogglePin.Bind(txt))
        m.Add(T("timer.note.edit"), Rename.Bind(txt))
        m.Add(T("timer.note.remove"), Remove.Bind(txt))
        m.Show()
    }
}
; Notiz in frueheren Timer-Zeilen eines Desktops umbenennen (alle Monatsdateien). Betroffen ist
; nur das letzte Feld, wenn es "timer:<Desktop>[ / <Unterprojekt>] | <alt>" lautet. dry = nur zaehlen.
LogRenameNote(desk, old, new, dry := false) {
    head := ',"timer:' StrReplace(desk, '"', '""'), tail := " | " StrReplace(old, '"', '""') '"'
    newTail := " | " StrReplace(new, '"', '""') '"', total := 0
    Loop Files, LogDir() "\desktop-log_*.csv" {
        file := A_LoopFileFullPath
        try {
            out := "", n := 0
            Loop Parse, FileRead(file, "UTF-8"), "`n", "`r" {
                line := A_LoopField
                p := InStr(line, ',"timer:', , -1)
                if (p && SubStr(line, -StrLen(tail)) == tail && SubStr(line, p, StrLen(head)) == head) {
                    rest := SubStr(line, p + StrLen(head), 3)
                    if (rest = " / " || rest = " | ")
                        line := SubStr(line, 1, StrLen(line) - StrLen(tail)) newTail, n++
                }
                out .= line "`n"
            }
            total += n
            if (dry || !n)
                continue
            f := FileOpen(file ".tmp", "w", "UTF-8")
            f.Write(RTrim(out, "`n") "`n"), f.Close()
            FileMove(file ".tmp", file, 1)
        }
    }
    return total
}
; Hover der Bubbles: die Bubble unter der Maus hellt sich auf (x rot), sonst Grundfarbe
NoteHoverTick() {
    global gNoteGui, gNoteCtrls, gNoteHover
    alive := false
    try alive := WinExist("ahk_id " gNoteGui.Hwnd)
    if (!alive) {
        SetTimer(NoteHoverTick, 0)
        gNoteHover := 0
        return
    }
    h := 0
    try MouseGetPos(, , , &h, 2)
    if (h = gNoteHover)
        return
    if (gNoteHover && gNoteCtrls.Has(gNoteHover))
        try NoteTint(gNoteCtrls[gNoteHover], 2)
    gNoteHover := gNoteCtrls.Has(h) ? h : 0
    if (gNoteHover)
        try NoteTint(gNoteCtrls[gNoteHover], 3)
}
NoteTint(c, which) {
    c[1].Opt("+Background" c[which])
    c[1].Redraw()
}
; ---- Bestaetigung als schmale Lasche: gleitet wie die Unterprojekt-Auswahl aus dem Tab nach
; oben, steht gut drei Sekunden und gleitet zurueck. Grau wie die Leiste, Symbol in der Desktop-Farbe.
ToastShow(num, text, glyph := 0xE73E) {
    global gToast, gToastDC, gToastHbm, gToastObm, gToastXY, MyGui, BTNS, gLayout
    if (!MyGui || !gLayout)
        return
    ToastHide()
    item := 0
    for it in BTNS
        if (it["num"] = num) {
            item := it
            break
        }
    col := (num >= 0) ? DesktopColor(num) : CONF["ColActiveBg"]
    fill := CONF["ColBarBg"], tx := CONF["ColInactiveTx"]
    GdipStart()
    font := MakeFont(), sf := MakeFormat()
    DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", sf, "Int", 0)
    mB := 0, mG := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", 1, "Int", 1, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &mB)
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", mB, "Ptr*", &mG)
    tw := Min(MeasureText(mG, font, sf, text) + px(2), px(420))
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", mG), DllCall("gdiplus\GdipDisposeImage", "Ptr", mB)
    padX := px(14), isz := px(16), gap := px(8), h := px(34)
    w := padX + isz + gap + tw + padX
    if (item)
        w := Max(w, item["w"])
    bx := 0, by := 0
    try WinGetPos(&bx, &by, , , MyGui.Hwnd)
    left := item ? bx + item["x"] : bx
    if (left + w > A_ScreenWidth)
        left := Max(0, A_ScreenWidth - w)
    bi := Buffer(40, 0)
    NumPut("UInt", 40, bi, 0), NumPut("Int", w, bi, 4), NumPut("Int", -h, bi, 8), NumPut("UShort", 1, bi, 12), NumPut("UShort", 32, bi, 14)
    gToastDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
    bits := 0
    gToastHbm := DllCall("CreateDIBSection", "Ptr", gToastDC, "Ptr", bi, "UInt", 0, "Ptr*", &bits, "Ptr", 0, "UInt", 0, "Ptr")
    gToastObm := DllCall("SelectObject", "Ptr", gToastDC, "Ptr", gToastHbm, "Ptr")
    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", gToastDC, "Ptr*", &g)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", g, "Int", 2)
    DllCall("gdiplus\GdipGraphicsClear", "Ptr", g, "UInt", 0)
    r := px(CONF["CornerRadius"]), d := r * 2                ; oben rund, unten eckig (sitzt auf der Leiste)
    path := 0
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", 0, "Float", 0, "Float", d, "Float", d, "Float", 180, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", w - d, "Float", 0, "Float", d, "Float", d, "Float", 270, "Float", 90)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", w, "Float", r, "Float", w, "Float", h)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", w, "Float", h, "Float", 0, "Float", h)
    DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
    brush := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB(fill), "Ptr*", &brush)
    DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", brush, "Ptr", path)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush), DllCall("gdiplus\GdipDeletePath", "Ptr", path)
    fam := 0, fI := 0
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "Str", CONF["IconFont"], "Ptr", 0, "Ptr*", &fam)
    if (fam)
        DllCall("gdiplus\GdipCreateFont", "Ptr", fam, "Float", isz, "Int", 0, "Int", 2, "Ptr*", &fI)
    sfC := MakeFormat()
    if (fI)
        DrawText(g, fI, sfC, Chr(glyph), padX, 0, isz, h, ARGB(col))
    DrawText(g, font, sf, text, padX + isz + gap, 0, tw, h, ARGB(tx))
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    DllCall("gdiplus\GdipDeleteFont", "Ptr", font), DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf), DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sfC)
    if (fI)
        DllCall("gdiplus\GdipDeleteFont", "Ptr", fI)
    if (fam)
        DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", fam)
    gToast := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08080000 -DPIScale")   ; NOACTIVATE | LAYERED
    gToast.Show(Format("NA x{1} y{2} w1 h1", left, by - 1))
    try DllCall("VirtualDesktopAccessor\PinWindow", "Ptr", gToast.Hwnd)
    gToastXY := [left, by, w, h]
    ToastSlide(true)
    SetTimer(ToastOut, -3200)
}
; Lasche um hh Pixel aus der Leiste geschoben zeigen (oberer Teil des Bildes zuerst)
ToastAt(hh) {
    global gToast, gToastDC, gToastXY
    if (!gToast || !gToastDC)
        return
    pt := Buffer(8, 0), sz := Buffer(8, 0), src := Buffer(8, 0)
    NumPut("Int", gToastXY[1], "Int", gToastXY[2] - hh, pt), NumPut("Int", gToastXY[3], "Int", hh, sz)
    try DllCall("UpdateLayeredWindow", "Ptr", gToast.Hwnd, "Ptr", 0, "Ptr", pt, "Ptr", sz, "Ptr", gToastDC
        , "Ptr", src, "UInt", 0, "UInt*", 0x01FF0000, "UInt", 2)
}
ToastSlide(out) {
    global gToast, gToastXY
    h := gToastXY[4]
    Loop 8 {
        if (!gToast)
            return
        f8 := A_Index / 8                            ; (nicht "t": T() ist die Uebersetzung)
        k := out ? 1 - (1 - f8) ** 3 : (1 - f8) ** 3
        ToastAt(Max(1, Round(h * k)))
        Sleep(12)
    }
}
ToastOut() {
    ToastSlide(false)
    ToastHide()
}
ToastHide(*) {
    global gToast, gToastDC, gToastHbm, gToastObm
    SetTimer(ToastOut, 0)
    old := gToast, gToast := 0
    try old.Destroy()
    if (gToastDC) {
        DllCall("SelectObject", "Ptr", gToastDC, "Ptr", gToastObm), DllCall("DeleteObject", "Ptr", gToastHbm), DllCall("DeleteDC", "Ptr", gToastDC)
        gToastDC := 0
    }
}
NoteSetCursor(wParam, lParam, msg, hwnd) {
    global gNoteCtrls
    if (!gNoteCtrls.Has(wParam))
        return
    DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32649, "Ptr"))   ; IDC_HAND
    return 1
}
; Notiz eines beendeten Timers nachtragen: jede Zeile ab seinem Start, deren activity noch
; genau "timer:<...>" ist, bekommt " | <Notiz>". Die Monatsdatei wird atomar ersetzt.
LogSetNote(label, since, note) {
    old := "," CsvQuote(label), new := "," CsvQuote(label " | " note), from := IsoTime(since)
    files := [LogFile(since)]
    if (LogFile(A_Now) != files[1])
        files.Push(LogFile(A_Now))
    for file in files {
        if !FileExist(file)
            continue
        try {
            out := "", n := 0
            Loop Parse, FileRead(file, "UTF-8"), "`n", "`r" {
                line := A_LoopField
                if (line != "" && StrCompare(SubStr(line, 1, 19), from) >= 0 && SubStr(line, -StrLen(old)) == old)
                    line := SubStr(line, 1, StrLen(line) - StrLen(old)) new, n++
                out .= line "`n"
            }
            if (!n)
                continue
            f := FileOpen(file ".tmp", "w", "UTF-8")
            f.Write(RTrim(out, "`n") "`n"), f.Close()
            FileMove(file ".tmp", file, 1)
        }
    }
}
ToggleCallHere(*) {
    global gCall
    if (IsObject(gCall))
        StopCall()
    else
        StartCall(GetCurrentDesktop())
}
; Nach einem Neustart von DeskTabs ein laufendes Gespraech fortsetzen (hoechstens 12 h alt)
RestoreCall() {
    global gCall
    v := IniRead(CONF["IniPath"], "State", "Call", "")
    p := StrSplit(v, "|")
    if (p.Length < 3 || !RegExMatch(p[1], "^\d{14}$") || DateDiff(A_Now, p[1], "Hours") >= 12) {
        if (v != "")
            IniDel("State", "Call")
        return
    }
    gCall := Map("start", p[1], "id", p[2], "name", p[3], "sub", (p.Length >= 4) ? p[4] : "")
    SetTimer(CallTick, 1000)
    SetTimer(CallPillPaint, -1500)            ; wenn die Leiste steht
}
CallTick() {
    global gCall, gCallConfirm
    if (!IsObject(gCall))
        return SetTimer(CallTick, 0)
    if (gCallConfirm && A_TickCount - gCallConfirm > 3000)
        gCallConfirm := 0
    CallPillPaint()
}
; Kleine Pille mit Hoerer und Laufzeit, mittig ueber dem Tab des Gespraechs. Klick: "Beenden?",
; zweiter Klick binnen 3 s beendet.
CallPillPaint() {
    global gCall, gCallGui, gCallDC, gCallHbm, gCallObm, gCallConfirm, MyGui, BTNS, gHidden, gLayout
    if (!IsObject(gCall) || !MyGui || !gLayout)
        return
    num := -1, item := 0
    for it in BTNS
        if (DesktopGuid(it["num"]) = gCall["id"]) {
            num := it["num"], item := it
            break
        }
    col := (num >= 0) ? DesktopColor(num) : CONF["ColActiveBg"]
    txt := gCallConfirm ? T("call.stopq") : CallDuration()
    GdipStart()
    mBmp := 0, mG := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", 1, "Int", 1, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &mBmp)
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", mBmp, "Ptr*", &mG)
    fB := MakeFont(true, CONF["FontSizePt"] - 1), sf := MakeFormat()
    fam := 0, fI := 0
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "Str", CONF["IconFont"], "Ptr", 0, "Ptr*", &fam)
    if (fam)
        DllCall("gdiplus\GdipCreateFont", "Ptr", fam, "Float", px(12), "Int", 0, "Int", 2, "Ptr*", &fI)
    tw := MeasureText(mG, fB, sf, txt)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", mG), DllCall("gdiplus\GdipDisposeImage", "Ptr", mBmp)
    w := px(10) + px(14) + px(5) + tw + px(10), h := px(22)
    bx := 0, by := 0
    try MyGui.GetPos(&bx, &by)
    cx := item ? bx + item["x"] + item["w"] // 2 : bx + gLayout["gripW"] // 2 + w // 2
    x := cx - w // 2, y := by - h + px(6)
    if (!gCallGui) {
        gCallGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08080000 -DPIScale")   ; NOACTIVATE | LAYERED
        gCallGui.Show(Format("NA x{1} y{2} w1 h1", x, y))
        try DllCall("VirtualDesktopAccessor\PinWindow", "Ptr", gCallGui.Hwnd)
    }
    if (gCallDC) {
        DllCall("SelectObject", "Ptr", gCallDC, "Ptr", gCallObm), DllCall("DeleteObject", "Ptr", gCallHbm), DllCall("DeleteDC", "Ptr", gCallDC)
    }
    bi := Buffer(40, 0)
    NumPut("UInt", 40, bi, 0), NumPut("Int", w, bi, 4), NumPut("Int", -h, bi, 8), NumPut("UShort", 1, bi, 12), NumPut("UShort", 32, bi, 14)
    gCallDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
    bits := 0
    gCallHbm := DllCall("CreateDIBSection", "Ptr", gCallDC, "Ptr", bi, "UInt", 0, "Ptr*", &bits, "Ptr", 0, "UInt", 0, "Ptr")
    gCallObm := DllCall("SelectObject", "Ptr", gCallDC, "Ptr", gCallHbm, "Ptr")
    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", gCallDC, "Ptr*", &g)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipGraphicsClear", "Ptr", g, "UInt", 0)
    fill := gCallConfirm ? Mix(0x000000, col, 25) : col
    fg := ReadableOn(fill)
    FillRoundRect(g, 0, 0, w, h, h / 2, ARGB(fill))
    if (fI)
        DrawText(g, fI, sf, Chr(0xE916), px(10), 0, px(14), h, ARGB(fg))      ; Stoppuhr
    DrawText(g, fB, sf, txt, px(10) + px(14) + px(5), 0, tw, h, ARGB(fg))
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    DllCall("gdiplus\GdipDeleteFont", "Ptr", fB), DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf)
    if (fI)
        DllCall("gdiplus\GdipDeleteFont", "Ptr", fI)
    if (fam)
        DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", fam)
    pt := Buffer(8, 0), sz := Buffer(8, 0), src := Buffer(8, 0)
    NumPut("Int", x, "Int", y, pt), NumPut("Int", w, "Int", h, sz)
    DllCall("UpdateLayeredWindow", "Ptr", gCallGui.Hwnd, "Ptr", 0, "Ptr", pt, "Ptr", sz, "Ptr", gCallDC
        , "Ptr", src, "UInt", 0, "UInt*", gHidden ? 0x01000000 : 0x01FF0000, "UInt", 2)   ; im Vollbild unsichtbar
}
CallPillHide() {
    global gCallGui, gCallDC, gCallHbm, gCallObm, gCallConfirm
    gCallConfirm := 0
    g := gCallGui, gCallGui := 0            ; erst loesen: waehrend Destroy kommen noch Nachrichten (WM_SETCURSOR)
    try g.Destroy()
    if (gCallDC) {
        DllCall("SelectObject", "Ptr", gCallDC, "Ptr", gCallObm), DllCall("DeleteObject", "Ptr", gCallHbm), DllCall("DeleteDC", "Ptr", gCallDC)
        gCallDC := 0
    }
}
CallPillUp(wParam, lParam, msg, hwnd) {
    global gCallGui, gCallConfirm
    if (!gCallGui || hwnd != CallPillHwnd())
        return
    if (gCallConfirm)
        StopCall()
    else {
        gCallConfirm := A_TickCount
        CallPillPaint()
    }
    return 0
}
; Fenster-Handle der Pille, 0 wenn sie gerade verschwindet
CallPillHwnd() {
    global gCallGui
    try return gCallGui.Hwnd
    return 0
}
CallPillCursor(wParam, lParam, msg, hwnd) {
    global gCallGui
    if (!gCallGui || hwnd != CallPillHwnd())
        return
    DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32649, "Ptr"))   ; IDC_HAND
    return 1
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
global gSetPick := 0, gSetHover := 0, gSetCount := Map(), gSetNames := Map()   ; Kacheln Fensteranordnungen: Platz unter der Maus, Zahl und Namen je Desktop
global gHotkeys := []        ; aktuell registrierte Tastenkuerzel
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
global gSelfTick := 0, gKeyTick := 0, gTaskViewTick := 0   ; letzte gewollte Wechsel (DeskTabs, Tastatur, Task-Ansicht)
global gAlertNum := -1, gAlertPhase := 0, gPrevCount := 0  ; Hinweis auf fremden Wechsel
global gAttention := Map(), gShellMsg := 0  ; Desktops mit blinkendem Programm (Punkt am Tab)
global gMenuCaption := "", gMenuAction := "", gMenuActionCol := 0
global gConfirmNum := -1, gConfirmPhase := 0   ; Bestaetigungsblinken nach dem Verschieben
global gReorderFrom := -1, gSkipUpUntil := 0   ; Desktops umsortieren; Klicks bis zu diesem Zeitpunkt gehoeren zum Ziehen
global gOd := Map(), gOdNext := 0x10000, gMenuGlyphs := Map(), gMenuSwatches := Map()   ; selbst gezeichnete Menues
global gCard := 0, gNoticeDismissed := "", gWasWelcomed := ""   ; Hinweis-Karten (Update, Neu in dieser Version)
global gZBlockUntil := 0         ; bis dahin kein Abbild (Wechsel laeuft, Wiederherstellung steht aus)
global gZSnap := Map()          ; Desktop-GUID -> Fenster in Z-Reihenfolge (oberstes zuerst), siehe ZSnapCurrent
global gSP := 0, gSPClosed := 0   ; Unterprojekt-Auswahl am aktiven Tab (SubPanelOpen)
global gBarReused := false, gBarPos := [0, 0]   ; Neuaufbau im vorhandenen Fenster (kein Aufblitzen)
global gNameCache := 0         ; Desktop-Namen, nur waehrend eines Aufbaus gemerkt
global gIniGen := 0            ; zaehlt eigene Schreibzugriffe auf settings.ini (Zwischenspeicher ungueltig)
global gFsHit := ""            ; Fenster, das zuletzt als Vollbild galt (nur fuer _debug.txt)
global gStripe := 0           ; Register-Form: Kante ueber der Taskleiste (eigenes Fenster)
global gShortcutsGui := 0     ; Fenster "Tastenkuerzel und Gesten"
global gPadX := 18          ; aktueller Innenabstand der Tabs (BuildBar passt ihn an den Platz an)
global gOrdCache := Map()    ; Desktop-Index -> feste laufende Nummer (DeskOrdinal)
global gHoverTipNum := -1    ; Tab, dessen voller Name gerade als Kurzinfo ansteht/erscheint
global gDragCb := 0, gDragHook := 0, gDragHwnd := 0, gDragPlace := 0, gDragPin := 0, gDragTipNum := -1   ; Fenster auf Tab ziehen
global gLastDesk := -1, gDeskSince := A_TickCount   ; zuletzt genutzter Desktop (fuer "zurueck")
global gCompact := "full"    ; aktuell dargestellte Stufe: "full" | "short" | "icon"
global gTaskbarW := 0        ; Breite der Primaer-Taskleiste (fuer das Breiten-Budget im auto-Modus)

; ------------------------------ Sprache -------------------------------------
; Alle sichtbaren Texte laufen durch T("schluessel", args*). Deutsch und Englisch
; sind eingebaut. Eine Datei lang\<code>.ini (UTF-8, Zeilen "schluessel=Text")
; neben dem Skript ergaenzt oder ueberschreibt Texte, ohne den Code anzufassen.
global LANG_DE := Map(
    "menu.sub", "Unterprojekt",
    "menu.call.start", "Timer starten",
    "menu.call.stop", "Timer beenden ({1})",
    "call.stopq", "Beenden?",
    "call.ended", "Timer beendet: {1}",
    "sc.d.call", "Timer für diesen Desktop starten oder beenden (die ganze Zeit zählt hierfür, auch wenn Du wechselst)",
    "timer.note.title", "DeskTabs: Notiz zum Timer",
    "timer.note.text", "Wofür lief der Timer für „{1}“ ({2})? Die Notiz ist freiwillig.",
    "timer.note.recent", "Zuletzt bei diesem Desktop · Klick übernimmt · ✎ umbenennen · × entfernen · Rechtsklick: anheften",
    "timer.note.renameq", "Neuer Text für „{1}“:",
    "timer.note.retro", "„{1}“ steht in {2} früheren Einträgen von „{3}“ im Zeit-Log.`n`nAuch dort in „{4}“ ändern?`n`nJa: überall ändern   ·   Nein: nur den Vorschlag`n`nSchon abgeschlossene Tage in anderen Programmen (etwa ManicTime) ändern sich dadurch nicht.",
    "timer.toast.saved", "Notiz „{1}“ gespeichert · {2}",
    "timer.toast.nonote", "Timer beendet · {1} · ohne Notiz",
    "timer.note.hint", "Zum Beispiel „Telefonat mit Christian“. Deine Notizen erscheinen hier beim nächsten Mal als Vorschläge.",
    "timer.note.save", "Speichern",
    "timer.note.skip", "Ohne Notiz",
    "timer.note.pin", "Anheften (bleibt immer vorn)",
    "timer.note.unpin", "Nicht mehr anheften",
    "timer.note.edit", "Umbenennen…",
    "timer.note.remove", "Entfernen",
    "menu.timelog.pause", "Zeit-Log pausieren",
    "menu.report", "Zeit-Auswertung…",
    "report.missing", "Die Vorlage data\report.html fehlt. Bitte DeskTabs neu installieren oder das Paket vollständig entpacken.",
    "report.failed", "Die Zeit-Auswertung ließ sich nicht öffnen:`n{1}",
    "menu.sub.current", "Unterprojekt: {1}",
    "menu.sub.none", "(keins)",
    "sub.panel.none", "ohne Unterprojekt",
    "menu.sub.add", "Neues Unterprojekt…",
    "menu.sub.remove", "Entfernen",
    "prompt.sub.title", "Unterprojekt für „{1}“",
    "prompt.sub.text", "Name des Unterprojekts (z. B. ein Kunde oder „Wartung“). Es wird gleich aktiv:",
    "sc.k.altclick", "{1} + Klick auf einen Tab",
    "sc.k.ctrlclick", "{1} + Klick auf einen Tab",
    "sc.d.ctrlclick", "diesen Tab kompakt (nur Symbol) bzw. wieder normal anzeigen",
    "sc.k.setclick", "Klick auf eine Anordnungs-Kachel",
    "sc.d.setclick", "ihre Fenster nach vorne holen (Rechtsklick: alle Möglichkeiten)",
    "sc.k.setshift", "{1} + Klick auf eine Kachel",
    "sc.d.setshift", "alles, was gerade sichtbar ist, als neuen Stand der Anordnung speichern",
    "sc.k.setctrl", "{1} + Klick auf eine Kachel",
    "sc.d.setctrl", "bündig ausrichten: Kanten aneinander und an den Bildschirmrand (nur kleine Korrekturen)",
    "set.tidynone", "„{1}“: nichts nachzurichten, alles liegt schon bündig",
    "sc.d.altclick", "Unterprojekte: wählen, anlegen, entfernen (stehen im Tab und im Zeit-Log)",
    "sc.k.clickactivesub", "Klick auf den aktiven Tab",
    "sc.d.clickactivesub", "Unterprojekt schnell wählen (wenn der Desktop welche hat)",
    "menu.help.shortcuts", "Tastenkürzel und Gesten…",
    "sc.title", "DeskTabs: Tastenkürzel und Gesten",
    "sc.hkoff", "Die Tastenkürzel sind gerade aus (grau). Einschalten: Rechtsklick auf die Leiste › Tastenkürzel.",
    "sc.sec.switch", "Desktop wechseln",
    "sc.sec.windows", "Fenster verschieben",
    "sc.sec.desktops", "Desktops verwalten",
    "sc.sec.bar", "Leiste",
    "sc.k.click", "Klick auf einen Tab",
    "sc.d.click", "zu diesem Desktop wechseln",
    "sc.k.clickactive", "Klick auf den aktiven Tab",
    "sc.d.clickactive", "Taskansicht öffnen (Win+Tab): alle Fenster und Desktops",
    "sc.k.wheel", "Mausrad über der Leiste",
    "sc.d.wheel", "durch die Desktops blättern",
    "sc.k.middle", "Mittelklick auf die Leiste",
    "sc.d.back", "zurück zum zuletzt genutzten Desktop",
    "sc.d.jump", "direkt zu Desktop 1 bis 10 (Ziffernreihe oder Ziffernblock)",
    "sc.k.shiftclick", "{1} + Klick auf einen Tab",
    "sc.d.send", "aktives Fenster dorthin schicken, Du bleibst, wo Du bist",
    "sc.k.ctrlshiftclick", "{1} + {2} + Klick auf einen Tab",
    "sc.d.take", "aktives Fenster mitnehmen und dorthin wechseln",
    "sc.k.dragwin", "Fenster an der Titelleiste auf einen Tab ziehen",
    "sc.d.dragwin", "Fenster auf diesen Desktop verschieben",
    "sc.k.dragwingrip", "Fenster an der Titelleiste auf ≡ ziehen",
    "sc.d.dragwingrip", "auf allen Desktops anzeigen (noch einmal: wieder nur hier)",
    "sc.k.shiftgrip", "{1} + Klick auf ≡",
    "sc.d.shiftgrip", "aktives Fenster auf allen Desktops anzeigen; {1} + Klick auf einen Tab: wieder nur dort",
    "sc.k.rtab", "Rechtsklick auf einen Tab",
    "sc.d.rtabwin", "„… hierher verschieben“ und „Fenster hierher holen ›“",
    "sc.k.dragtab", "Tab seitlich ziehen",
    "sc.d.dragtab", "Desktops umsortieren (wie Browser-Tabs)",
    "sc.k.rgrip", "Rechtsklick auf ≡",
    "sc.d.rgrip", "neuer Desktop, Fenster auf allen Desktops, alle Einstellungen",
    "sc.d.rtabdesk", "umbenennen, entfernen, Symbol, Farbe, Kürzel, kompakt",
    "sc.k.draggrip", "≡ ziehen",
    "sc.d.draggrip", "Leiste verschieben (rastet an der Taskleiste ein)",
    "sc.k.ctrlwheel", "{1} + Mausrad über der Leiste",
    "sc.d.ctrlwheel", "Ansichtsstufe wechseln (Name, Kürzel, Symbol)",
    "sc.k.hover", "Maus auf einem Tab ruhen lassen",
    "sc.d.hover", "voller Name, wenn der Tab ihn nicht ganz zeigt",
    "menu.activeshadow", "Schatten unter dem aktiven Tab",
    "menu.shape", "Form:",
    "menu.shape.tabs", "Tabs",
    "menu.shape.register", "Register (Tab hängt an der Taskleiste)",
    "menu.hotkeys.shiftdrag", "Tab seitlich ziehen: Desktops umsortieren (wie Browser-Tabs)",
    "menu.newdesk", "Neuer Desktop…",
    "menu.set.save", "Fensteranordnung speichern…",
    "menu.set.tidy", "Fenster bündig ausrichten",
    "menu.claudecode", "Claude-Code-Funktionen",
    "menu.set.even", "Gleich breit verteilen",
    "set.evened", "„{1}“ gleich breit verteilt · {2} Fenster auf {3} Bildschirm(en)",
    "menu.claude.gather", "Claude-Fenster [{1}] hierher holen",
    "menu.claude.tag", "Claude-Kürzel…",
    "claude.tagtitle", "Claude-Kürzel für „{1}“",
    "claude.tagq", "Kürzel, das die Claude-Chats dieses Desktops in eckigen Klammern im Titel tragen (ohne Klammern). Leer lassen = automatisch:",
    "claude.gathered", "{1} Claude-Fenster [{2}] verteilt · {3} von anderen Desktops geholt",
    "claude.none", "Keine Claude-Fenster mit [{1}] gefunden",
    "menu.set.overwrite", "Mit aktueller Anordnung überschreiben",
    "menu.set.rename", "Umbenennen",
    "menu.set.delete", "Löschen",
    "set.title", "DeskTabs: Fensteranordnung",
    "set.nameq", "Name für die Anordnung der {1} Fenster auf „{2}“:",
    "set.defname", "Anordnung {1}",
    "set.none", "Auf diesem Desktop ist gerade kein Fenster zu sehen, das sich merken ließe.",
    "set.saved", "Anordnung „{1}“ gespeichert · {2} Fenster",
    "set.partial", "„{1}“ · {2} von {3} Fenstern gefunden",
    "set.nonefound", "„{1}“ · keins der Fenster ist gerade offen",
    "set.renameq", "Neuer Name für „{1}“:",
    "set.deleteq", "Anordnung „{1}“ löschen?",
    "set.tidied", "„{1}“ bündig ausgerichtet · {2} Fenster auf {3} Bildschirm(en)",
    "set.updated", "„{1}“ aktualisiert · {2} Fenster",
    "set.pickname", "Name der Anordnung auf „{1}“:",
    "set.picklist", "Welche Fenster gehören dazu? (oberstes zuerst)",
    "set.col.title", "Fenster",
    "set.col.exe", "Programm",
    "set.cancel", "Abbrechen",
    "menu.set.pick", "Fenster auswählen…",
    "set.tip", "Klick: nach vorne · Umschalt + Klick: aktuellen Stand speichern · Rechtsklick: mehr",
    "menu.set.front", "„{1}“ nach vorne holen",
    "prompt.newdesk.title", "Neuer Desktop",
    "prompt.newdesk.text", "Name des neuen Desktops (leer lassen: Windows vergibt „Desktop N“):",
    "menu.tab.rename", "Umbenennen…",
    "prompt.rename.title", "„{1}“ umbenennen",
    "prompt.rename.text", "Neuer Name. Farbe, Symbol, Kürzel und Kompakt-Einstellung ziehen mit:",
    "menu.tab.remove", "Desktop entfernen…",
    "ask.remove.windows", "Desktop „{1}“ entfernen?`n`nWindows schließt dabei keine Fenster: Die {2} Fenster darauf wandern nach „{3}“.`n`nFarbe, Symbol und Kürzel bleiben gespeichert und sind wieder da, wenn Du erneut einen Desktop „{1}“ anlegst.",
    "ask.remove.empty", "Desktop „{1}“ entfernen? Es liegen keine Fenster darauf.`n`nFarbe, Symbol und Kürzel bleiben gespeichert und sind wieder da, wenn Du erneut einen Desktop „{1}“ anlegst.",
    "menu.tab.compact", "Kompakt anzeigen (nur Symbol)",
    "menu.pin.untick", "Haken entfernen: nur noch auf „{1}“ anzeigen",
    "tip.appunpinnedto", "„{1}“ nicht mehr auf allen Desktops, dieses Fenster jetzt auf „{2}“",
    "tip.apppinned", "„{1}“ wird auf allen Desktops angezeigt (Einstellung der ganzen App, ändern per Rechtsklick auf ≡)",
    "tip.movedunpinned", "„{1}“ nach „{2}“ verschoben, jetzt nur noch dort statt auf allen Desktops",
    "tip.unpinned", "„{1}“ nur noch auf „{2}“",
    "tip.pinned", "„{1}“ wird jetzt auf allen Desktops angezeigt",
    "tip.appunpinned", "Fenster von „{1}“ nicht mehr auf allen Desktops",
    "tip.apppinnednow", "Alle Fenster von „{1}“ jetzt auf allen Desktops",
    "tip.droppin", "Loslassen: Fenster auf allen Desktops anzeigen",
    "tip.dropunpin", "Loslassen: Fenster nur noch auf „{1}“ anzeigen",
    "tip.dropmoveunpin", "Loslassen: Fenster nur noch auf „{1}“ statt auf allen Desktops",
    "menu.tab.onlyhere", "„{1}“ nur auf diesem Desktop anzeigen",
    "menu.pin.window", "„{1}“ auf allen Desktops anzeigen",
    "menu.pin.app", "Alle Fenster von „{1}“ auf allen Desktops",
    "menu.hotkeys.ctrlshiftclick", "Strg + Umschalt + Klick auf einen Tab: aktives Fenster mitnehmen und dorthin wechseln",
    "menu.hotkeys.shiftclick", "Umschalt + Klick auf einen Tab: aktives Fenster dorthin schicken",
    "tip.dropmove", "Loslassen: Fenster nach „{1}“ verschieben",
    "menu.dragtotab", "Fenster an der Titelleiste auf einen Tab ziehen = dorthin verschieben",
    "menu.zorder", "Fensterreihenfolge je Desktop wiederherstellen",
    "menu.tab.fetch", "Fenster hierher holen",
    "key.backspace", "Rücktaste",
    "menu.hotkeys.back", "{1}: zurück zum letzten Desktop (auch Mittelklick auf die Leiste)",
    "menu.hotkeys.move", "{1}: aktives Fenster dorthin schicken",
    "menu.attention", "Punkt am Tab, wenn ein Programm auf einem anderen Desktop blinkt",
    "tip.moved", "„{1}“ verschoben nach „{2}“",
    "menu.tab.movehere", "„{1}“ hierher verschieben",
    "alert.switched.noproc", "Desktop gewechselt zu „{1}“, nicht von Dir",
    "alert.switched", "Desktop gewechselt zu „{1}“, im Vordergrund: {2}",
    "menu.switchalert", "Desktop-Wechsel durch andere Programme melden",
    "menu.timelog.open", "Ordner öffnen",
    "menu.timelog.on", "Aufzeichnen",
    "menu.more", "Weitere Einstellungen",
    "menu.hotkeys.mods", "Zusatztasten:",
    "menu.numbers", "Nummern",
    "menu.icons.show", "Anzeigen",
    "menu.icons", "Symbole",
    "err.dll_missing", "VirtualDesktopAccessor.dll nicht gefunden:`n{1}",
    "err.dll_load",    "Die DLL konnte nicht geladen werden.",
    "tray.rebuild",    "Leiste neu aufbauen",
    "tray.resetpos",   "Position zurücksetzen",
    "tray.exit",       "Beenden",
    "view.tip",        "Ansicht: {1}",
    "view.auto",       "automatisch ({1})",
    "level.full",      "Symbol und Name",
    "level.short",     "Symbol und Kurzname",
    "level.icon",      "Nur Symbol oder Kürzel",
    "level.big",       "Nur großes Symbol",
    "level.bigtext",   "Großes Symbol und Name",
    "menu.settings",   "Einstellungen…",
    "menu.tab.short",  "Kürzel festlegen…",
    "menu.tab.color",  "Farbe",
    "menu.tab.icon",   "Symbol",
    "menu.icon.library", "Aus der Bibliothek…",
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
    "menu.icon.url",   "Von einer Webseite…",
    "menu.icon.file",  "Aus einer Bilddatei…",
    "menu.icon.clear", "Symbol entfernen",
    "prompt.iconurl.title", "Symbol für „{1}“",
    "prompt.iconurl.text", "Adresse der Webseite (leer = Symbol entfernen):",
    "dlg.ok",          "OK",
    "dlg.cancel",      "Abbrechen",
    "prompt.iconfile.title", "Bilddatei für „{1}“ wählen",
    "icon.fetching",   "Symbol wird geholt…",
    "err.icon_fetch",  "Von dieser Adresse konnte kein Symbol geladen werden.",
    "menu.color.custom", "Eigene Farbe…",
    "menu.color.default", "Farbe zurücksetzen",
    "menu.color.fromicon", "Aus dem Symbol übernehmen",
    "err.color_icon",  "Aus diesem Symbol lässt sich keine Farbe ableiten. Das geht nur bei Symbolen von einer Webseite oder aus einer Bilddatei.",
    "color.E5471D",    "Rot",
    "color.2E7D32",    "Grün",
    "color.1565C0",    "Blau",
    "color.6A1B9A",    "Violett",
    "color.EF6C00",    "Orange",
    "color.00838F",    "Petrol",
    "color.C2185B",    "Pink",
    "color.558B2F",    "Olivgrün",
    "menu.showindex",  "Vor dem Namen",
    "menu.colorcoding", "Farbbalken unter den Tabs",
    "menu.active",     "Aktiver Desktop",
    "menu.active.desktop", "Getönt in seiner Farbe",
    "menu.active.accent", "Getönt in der Akzentfarbe",
    "menu.active.solid", "Kräftig gefüllt in der Akzentfarbe",
    "menu.active.soliddesk", "Kräftig gefüllt in seiner Farbe",
    "menu.dividers",   "Trennstriche zwischen den Tabs",
    "menu.activebold", "Fett beschriften",
    "menu.badge",      "Als Badge am Symbol",
    "menu.noicon",     "Für Desktops ohne eigenes Symbol:",
    "menu.noicon.suggest", "Vorschlagssymbol",
    "menu.noicon.number", "Nummer",
    "menu.noicon.none", "Keins",
    "menu.icon.number", "Nummer als Symbol",
    "menu.view",       "Ansicht",
    "menu.view.auto",  "Automatisch (nach Platz)",
    "menu.theme",      "Hell oder dunkel",
    "menu.theme.auto", "Wie Windows",
    "menu.theme.light", "Hell",
    "menu.theme.dark", "Dunkel",
    "menu.hotkeys",    "Tastenkürzel",
    "menu.hotkeys.on", "Einschalten",
    "menu.hotkeys.off", "aus",
    "err.hotkey_mod",  "Mindestens eine Zusatztaste muss gewählt bleiben, sonst würden die blanken Zifferntasten belegt.",
    "key.ctrl",        "Strg",
    "key.win",         "Windows",
    "key.alt",         "Alt",
    "key.shift",       "Umschalt",
    "err.hotkeys",     "Die Tastenkürzel konnten nicht registriert werden. Vermutlich belegt sie ein anderes Programm. Bitte einen anderen Modifikator wählen.",
    "menu.directjump", "Direkt springen statt durchblättern",
    "menu.snap",       "Beim Verschieben an der Taskleiste einrasten",
    "menu.timelog",    "Zeit-Log",
    "menu.language",   "Sprache",
    "menu.language.auto", "Wie Windows",
    "prompt.short.title", "Kürzel für „{1}“",
    "prompt.short.text", "Kurzname für die Kompakt-Ansicht (leer = keins):",
    "prompt.color.title", "Farbe für „{1}“",
    "prompt.color.text", "Hex-Farbe RRGGBB, z.B. E5471D:",
    "err.color",       "Ungültige Farbe. Bitte sechs Hex-Zeichen, z.B. E5471D.",
    "firstrun.title",  "DeskTabs läuft",
    "firstrun.text",   "Klick auf einen Tab wechselt den Desktop.`nRechtsklick öffnet alle Einstellungen: Symbole, Farben, Ansicht, Sprache.",
    "menu.help",       "Hilfe",
    "menu.help.docs",  "Anleitung und Dokumentation…",
    "menu.help.agents", "Anleitung für KI-Assistenten…",
    "menu.help.changelog", "Was ist neu (Änderungsverlauf)…",
    "menu.feedback.bug", "Fehler melden (GitHub)…",
    "menu.feedback.idea", "Idee einreichen (GitHub)…",
    "menu.feedback.mailbug", "Fehler per E-Mail melden…",
    "menu.feedback.mail", "Idee oder Frage per E-Mail…",
    "menu.update.check", "Nach Updates suchen…",
    "menu.update.auto", "Update-Hinweis anzeigen (täglich prüfen)",
    "menu.help.news", "Neu in dieser Version…",
    "menu.update.available", "Update {1} verfügbar…",
    "menu.about",      "Über DeskTabs…",
    "about.title",     "Über DeskTabs",
    "about.tagline",   "Klickbare Taskleisten-Buttons für virtuelle Desktops",
    "about.version",   "Version {1}",
    "about.author",    "von {1}",
    "about.license",   "Lizenz: GNU GPL v3 mit Namensnennung (siehe NOTICE). Quelltext frei verfügbar, ohne jede Gewährleistung. Weitergaben und Abwandlungen müssen „DeskTabs von Henning Pähtz“ nennen.",
    "about.components", "Enthält VirtualDesktopAccessor (MIT, Jari Pennanen){1}.`nSymbol-Bibliothek: Schrift „Segoe Fluent Icons“ von Windows; Symbolnamen aus der`nMicrosoft-Dokumentation (CC BY 4.0).",
    "about.ahk",       "und AutoHotkey v2 (GPL-2.0 oder später)",
    "about.website",   "Website",
    "about.github",    "Projekt auf GitHub",
    "about.feedback",  "Feedback geben",
    "about.check",     "Nach Updates suchen",
    "about.close",     "Schließen",
    "update.none",     "DeskTabs {1} ist aktuell.",
    "update.error",    "Update-Prüfung nicht möglich (keine Verbindung zu GitHub).",
    "upd.title",       "DeskTabs {1} ist verfügbar",
    "upd.sub",         "Mit einem Klick aktualisieren. Einstellungen und Zeit-Logs bleiben.",
    "upd.sub.page",    "Klick öffnet die Download-Seite.",
    "upd.btn",         "Jetzt aktualisieren",
    "upd.btn.page",    "Zum Download",
    "upd.loading",     "Update wird geladen…",
    "upd.loading.sub", "DeskTabs startet gleich neu.",
    "upd.failed",      "Update nicht möglich",
    "upd.failed.sub",  "Bitte von der Download-Seite installieren.",
    "news.title",      "Neu in DeskTabs {1}",
    "news.all",        "Alle Änderungen auf GitHub",
    "feedback.mail.subject.bug", "DeskTabs {1}: Fehlermeldung",
    "feedback.mail.subject.feedback", "DeskTabs {1}: Idee oder Frage",
    "feedback.mail.body.bug", "Hallo Henning,`n`nin DeskTabs ist mir das hier aufgefallen:`n`nWas passiert ist:`n`nWas ich erwartet hatte:`n`nSo lässt es sich nachstellen:`n1.`n2.`n3.`n`nViele Grüße",
    "feedback.mail.body.feedback", "Hallo Henning,`n`nzu DeskTabs habe ich folgende Idee oder Frage:`n`n`nViele Grüße"
)
global LANG_EN := Map(
    "menu.sub", "Sub-project",
    "menu.call.start", "Start timer",
    "menu.call.stop", "Stop timer ({1})",
    "call.stopq", "Stop?",
    "call.ended", "Timer stopped: {1}",
    "sc.d.call", "start or stop a timer for this desktop (all its time counts here, even when you switch)",
    "timer.note.title", "DeskTabs: timer note",
    "timer.note.text", "What was the timer for “{1}” ({2}) about? The note is optional.",
    "timer.note.recent", "Recent for this desktop · click to use · ✎ rename · × remove · right-click: pin",
    "timer.note.renameq", "New text for “{1}”:",
    "timer.note.retro", "“{1}” appears in {2} earlier entries of “{3}” in the time log.`n`nChange it to “{4}” there as well?`n`nYes: change everywhere   ·   No: only the suggestion`n`nDays already closed in other programs (such as ManicTime) do not change.",
    "timer.toast.saved", "Note “{1}” saved · {2}",
    "timer.toast.nonote", "Timer stopped · {1} · no note",
    "timer.note.hint", "For example “Call with Christian”. Your notes show up here as suggestions next time.",
    "timer.note.save", "Save",
    "timer.note.skip", "No note",
    "timer.note.pin", "Pin (always stays first)",
    "timer.note.unpin", "Unpin",
    "timer.note.edit", "Rename…",
    "timer.note.remove", "Remove",
    "menu.timelog.pause", "Pause the time log",
    "menu.report", "Time report…",
    "report.missing", "The template data\report.html is missing. Please reinstall DeskTabs or unpack the full package.",
    "report.failed", "The time report could not be opened:`n{1}",
    "menu.sub.current", "Sub-project: {1}",
    "menu.sub.none", "(none)",
    "sub.panel.none", "no sub-project",
    "menu.sub.add", "New sub-project…",
    "menu.sub.remove", "Remove",
    "prompt.sub.title", "Sub-project for “{1}”",
    "prompt.sub.text", "Name of the sub-project (a client, or “maintenance”). It becomes active right away:",
    "sc.k.altclick", "{1} + click a tab",
    "sc.k.ctrlclick", "{1} + click a tab",
    "sc.d.ctrlclick", "show this tab compact (icon only) or normal again",
    "sc.k.setclick", "Click a layout tile",
    "sc.d.setclick", "bring its windows to the front (right-click: all options)",
    "sc.k.setshift", "{1} + click a tile",
    "sc.d.setshift", "save everything visible right now as the layout's new state",
    "sc.k.setctrl", "{1} + click a tile",
    "sc.d.setctrl", "align flush: edges to each other and to the screen edge (small corrections only)",
    "set.tidynone", "“{1}”: nothing to align, everything is flush already",
    "sc.d.altclick", "sub-projects: pick, add, remove (shown in the tab and in the time log)",
    "sc.k.clickactivesub", "Click the active tab",
    "sc.d.clickactivesub", "quick sub-project pick (if the desktop has any)",
    "menu.help.shortcuts", "Keyboard shortcuts and gestures…",
    "sc.title", "DeskTabs: keyboard shortcuts and gestures",
    "sc.hkoff", "The keyboard shortcuts are off right now (grey). Turn them on: right-click the bar › Keyboard shortcuts.",
    "sc.sec.switch", "Switch desktops",
    "sc.sec.windows", "Move windows",
    "sc.sec.desktops", "Manage desktops",
    "sc.sec.bar", "Bar",
    "sc.k.click", "Click a tab",
    "sc.d.click", "switch to that desktop",
    "sc.k.clickactive", "Click the active tab",
    "sc.d.clickactive", "open Task View (Win+Tab): all windows and desktops",
    "sc.k.wheel", "Mouse wheel over the bar",
    "sc.d.wheel", "page through the desktops",
    "sc.k.middle", "Middle-click the bar",
    "sc.d.back", "back to the desktop you last worked on",
    "sc.d.jump", "straight to desktop 1 to 10 (number row or numpad)",
    "sc.k.shiftclick", "{1} + click a tab",
    "sc.d.send", "send the active window there, you stay where you are",
    "sc.k.ctrlshiftclick", "{1} + {2} + click a tab",
    "sc.d.take", "take the active window along and switch there",
    "sc.k.dragwin", "Drag a window by its title bar onto a tab",
    "sc.d.dragwin", "move the window to that desktop",
    "sc.k.dragwingrip", "Drag a window by its title bar onto ≡",
    "sc.d.dragwingrip", "show it on all desktops (again: only here)",
    "sc.k.shiftgrip", "{1} + click ≡",
    "sc.d.shiftgrip", "show the active window on all desktops; {1} + click a tab: only there again",
    "sc.k.rtab", "Right-click a tab",
    "sc.d.rtabwin", "“Move … here” and “Bring a window here ›”",
    "sc.k.dragtab", "Drag a tab sideways",
    "sc.d.dragtab", "reorder desktops (like browser tabs)",
    "sc.k.rgrip", "Right-click ≡",
    "sc.d.rgrip", "new desktop, window on all desktops, all settings",
    "sc.d.rtabdesk", "rename, remove, icon, colour, abbreviation, compact",
    "sc.k.draggrip", "Drag ≡",
    "sc.d.draggrip", "move the bar (snaps to the taskbar)",
    "sc.k.ctrlwheel", "{1} + mouse wheel over the bar",
    "sc.d.ctrlwheel", "change the view level (name, abbreviation, icon)",
    "sc.k.hover", "Rest the mouse on a tab",
    "sc.d.hover", "full name, if the tab does not show all of it",
    "menu.activeshadow", "Shadow under the active tab",
    "menu.shape", "Shape:",
    "menu.shape.tabs", "Tabs",
    "menu.shape.register", "Register (tab hangs from the taskbar)",
    "menu.hotkeys.shiftdrag", "Drag a tab sideways: reorder desktops (like browser tabs)",
    "menu.newdesk", "New desktop…",
    "menu.set.save", "Save window layout…",
    "menu.set.tidy", "Align windows flush",
    "menu.claudecode", "Claude Code features",
    "menu.set.even", "Distribute evenly",
    "set.evened", "“{1}” distributed evenly · {2} windows on {3} screen(s)",
    "menu.claude.gather", "Bring Claude windows [{1}] here",
    "menu.claude.tag", "Claude tag…",
    "claude.tagtitle", "Claude tag for “{1}”",
    "claude.tagq", "Tag that this desktop's Claude chats carry in square brackets in their title (without brackets). Leave empty = automatic:",
    "claude.gathered", "{1} Claude windows [{2}] distributed · {3} brought from other desktops",
    "claude.none", "No Claude windows with [{1}] found",
    "menu.set.overwrite", "Overwrite with current layout",
    "menu.set.rename", "Rename",
    "menu.set.delete", "Delete",
    "set.title", "DeskTabs: window layout",
    "set.nameq", "Name for the layout of the {1} windows on “{2}”:",
    "set.defname", "Layout {1}",
    "set.none", "No window on this desktop could be saved right now.",
    "set.saved", "Layout “{1}” saved · {2} windows",
    "set.partial", "“{1}” · found {2} of {3} windows",
    "set.nonefound", "“{1}” · none of its windows is open",
    "set.renameq", "New name for “{1}”:",
    "set.deleteq", "Delete layout “{1}”?",
    "set.tidied", "“{1}” aligned · {2} windows on {3} screen(s)",
    "set.updated", "“{1}” updated · {2} windows",
    "set.pickname", "Name of the layout on “{1}”:",
    "set.picklist", "Which windows belong to it? (topmost first)",
    "set.col.title", "Window",
    "set.col.exe", "Program",
    "set.cancel", "Cancel",
    "menu.set.pick", "Choose windows…",
    "set.tip", "Click: bring to front · Shift + click: save current state · Right-click: more",
    "menu.set.front", "Bring “{1}” to front",
    "prompt.newdesk.title", "New desktop",
    "prompt.newdesk.text", "Name of the new desktop (leave empty and Windows calls it “Desktop N”):",
    "menu.tab.rename", "Rename…",
    "prompt.rename.title", "Rename “{1}”",
    "prompt.rename.text", "New name. Colour, icon, abbreviation and compact setting move along:",
    "menu.tab.remove", "Remove desktop…",
    "ask.remove.windows", "Remove the desktop “{1}”?`n`nWindows closes no windows when doing so: its {2} windows move to “{3}”.`n`nColour, icon and abbreviation stay saved and come back if you create a desktop called “{1}” again.",
    "ask.remove.empty", "Remove the desktop “{1}”? There are no windows on it.`n`nColour, icon and abbreviation stay saved and come back if you create a desktop called “{1}” again.",
    "menu.tab.compact", "Compact (icon only)",
    "menu.pin.untick", "Untick to show it only on “{1}”",
    "tip.appunpinnedto", "“{1}” no longer on all desktops, this window is now on “{2}”",
    "tip.apppinned", "“{1}” is shown on all desktops (setting of the whole app, change it with a right-click on ≡)",
    "tip.movedunpinned", "Moved “{1}” to “{2}”, now only there instead of on all desktops",
    "tip.unpinned", "“{1}” now only on “{2}”",
    "tip.pinned", "“{1}” is now shown on all desktops",
    "tip.appunpinned", "Windows of “{1}” no longer on all desktops",
    "tip.apppinnednow", "All windows of “{1}” now on all desktops",
    "tip.droppin", "Release to show the window on all desktops",
    "tip.dropunpin", "Release to show the window only on “{1}”",
    "tip.dropmoveunpin", "Release to show the window only on “{1}” instead of all desktops",
    "menu.tab.onlyhere", "Show “{1}” only on this desktop",
    "menu.pin.window", "Show “{1}” on all desktops",
    "menu.pin.app", "All windows of “{1}” on all desktops",
    "menu.hotkeys.ctrlshiftclick", "Ctrl + Shift + click a tab: take the active window along and switch there",
    "menu.hotkeys.shiftclick", "Shift + click a tab: send the active window there",
    "tip.dropmove", "Release to move the window to “{1}”",
    "menu.dragtotab", "Drag a window by its title bar onto a tab to move it there",
    "menu.zorder", "Restore each desktop's window order",
    "menu.tab.fetch", "Bring a window here",
    "key.backspace", "Backspace",
    "menu.hotkeys.back", "{1}: back to the last desktop (or middle-click the bar)",
    "menu.hotkeys.move", "{1}: send the active window there",
    "menu.attention", "Dot on the tab when an app on another desktop wants attention",
    "tip.moved", "Moved “{1}” to “{2}”",
    "menu.tab.movehere", "Move “{1}” here",
    "alert.switched.noproc", "Switched to “{1}”, not by you",
    "alert.switched", "Switched to “{1}”, now in front: {2}",
    "menu.switchalert", "Flag desktop switches made by other apps",
    "menu.timelog.open", "Open folder",
    "menu.timelog.on", "Record",
    "menu.more", "More settings",
    "menu.hotkeys.mods", "Modifier keys:",
    "menu.numbers", "Numbers",
    "menu.icons.show", "Show",
    "menu.icons", "Icons",
    "err.dll_missing", "VirtualDesktopAccessor.dll not found:`n{1}",
    "err.dll_load",    "The DLL could not be loaded.",
    "tray.rebuild",    "Rebuild bar",
    "tray.resetpos",   "Reset position",
    "tray.exit",       "Exit",
    "view.tip",        "View: {1}",
    "view.auto",       "automatic ({1})",
    "level.full",      "Icon and name",
    "level.short",     "Icon and short name",
    "level.icon",      "Icon or abbreviation only",
    "level.big",       "Large icon only",
    "level.bigtext",   "Large icon and name",
    "menu.settings",   "Settings…",
    "menu.tab.short",  "Set abbreviation…",
    "menu.tab.color",  "Colour",
    "menu.tab.icon",   "Icon",
    "menu.icon.library", "From the library…",
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
    "menu.icon.url",   "From a website…",
    "menu.icon.file",  "From an image file…",
    "menu.icon.clear", "Remove icon",
    "prompt.iconurl.title", "Icon for “{1}”",
    "prompt.iconurl.text", "Website address (empty = removes the icon):",
    "dlg.ok",          "OK",
    "dlg.cancel",      "Cancel",
    "prompt.iconfile.title", "Choose an image file for “{1}”",
    "icon.fetching",   "Fetching icon…",
    "err.icon_fetch",  "No icon could be loaded from that address.",
    "menu.color.custom", "Custom colour…",
    "menu.color.default", "Reset colour",
    "menu.color.fromicon", "Take from the icon",
    "err.color_icon",  "No colour could be derived from this icon. That only works for icons fetched from a website or loaded from an image file.",
    "color.E5471D",    "Red",
    "color.2E7D32",    "Green",
    "color.1565C0",    "Blue",
    "color.6A1B9A",    "Purple",
    "color.EF6C00",    "Orange",
    "color.00838F",    "Teal",
    "color.C2185B",    "Pink",
    "color.558B2F",    "Olive",
    "menu.showindex",  "Before the name",
    "menu.colorcoding", "Colour bar under each tab",
    "menu.active",     "Active desktop",
    "menu.active.desktop", "Tinted in its own colour",
    "menu.active.accent", "Tinted in the accent colour",
    "menu.active.solid", "Solid fill in the accent colour",
    "menu.active.soliddesk", "Solid fill in its own colour",
    "menu.dividers",   "Dividers between tabs",
    "menu.activebold", "Bold label",
    "menu.badge",      "As a badge on the icon",
    "menu.noicon",     "For desktops without their own icon:",
    "menu.noicon.suggest", "Suggested icon",
    "menu.noicon.number", "Number",
    "menu.noicon.none", "None",
    "menu.icon.number", "Number as icon",
    "menu.view",       "View",
    "menu.view.auto",  "Automatic (by available space)",
    "menu.theme",      "Light or dark",
    "menu.theme.auto", "Match Windows",
    "menu.theme.light", "Light",
    "menu.theme.dark", "Dark",
    "menu.hotkeys",    "Keyboard shortcuts",
    "menu.hotkeys.on", "Turn on",
    "menu.hotkeys.off", "off",
    "err.hotkey_mod",  "At least one modifier has to stay selected, otherwise the plain number keys would be taken.",
    "key.ctrl",        "Ctrl",
    "key.win",         "Windows",
    "key.alt",         "Alt",
    "key.shift",       "Shift",
    "err.hotkeys",     "The shortcuts could not be registered. Another program probably uses them. Please pick a different modifier.",
    "menu.directjump", "Jump directly instead of stepping through",
    "menu.snap",       "Snap to the taskbar when moving",
    "menu.timelog",    "Time log",
    "menu.language",   "Language",
    "menu.language.auto", "Match Windows",
    "prompt.short.title", "Abbreviation for “{1}”",
    "prompt.short.text", "Short name for the compact levels (empty = none):",
    "prompt.color.title", "Colour for “{1}”",
    "prompt.color.text", "Hex colour RRGGBB, e.g. E5471D:",
    "err.color",       "Invalid colour. Please use six hex digits, e.g. E5471D.",
    "firstrun.title",  "DeskTabs is running",
    "firstrun.text",   "Click a tab to switch desktops.`nRight-click opens every setting: icons, colours, view, language.",
    "menu.help",       "Help",
    "menu.help.docs",  "Guide and documentation…",
    "menu.help.agents", "Guide for AI assistants…",
    "menu.help.changelog", "What's new (changelog)…",
    "menu.feedback.bug", "Report a bug (GitHub)…",
    "menu.feedback.idea", "Suggest an idea (GitHub)…",
    "menu.feedback.mailbug", "Report a bug by e-mail…",
    "menu.feedback.mail", "Send an idea or question by e-mail…",
    "menu.update.check", "Check for updates…",
    "menu.update.auto", "Show update notice (checks daily)",
    "menu.help.news", "New in this version…",
    "menu.update.available", "Update {1} available…",
    "menu.about",      "About DeskTabs…",
    "about.title",     "About DeskTabs",
    "about.tagline",   "Clickable taskbar buttons for virtual desktops",
    "about.version",   "Version {1}",
    "about.author",    "by {1}",
    "about.license",   "License: GNU GPL v3 with attribution (see NOTICE). Source code freely available, without any warranty. Copies and modified versions must credit “DeskTabs by Henning Pähtz”.",
    "about.components", "Includes VirtualDesktopAccessor (MIT, Jari Pennanen){1}.`nIcon library: the Windows font “Segoe Fluent Icons”; icon names from the`nMicrosoft documentation (CC BY 4.0).",
    "about.ahk",       "and AutoHotkey v2 (GPL-2.0 or later)",
    "about.website",   "Website",
    "about.github",    "Project on GitHub",
    "about.feedback",  "Give feedback",
    "about.check",     "Check for updates",
    "about.close",     "Close",
    "update.none",     "DeskTabs {1} is up to date.",
    "update.error",    "Could not check for updates (no connection to GitHub).",
    "upd.title",       "DeskTabs {1} is available",
    "upd.sub",         "Update with one click. Settings and time logs are kept.",
    "upd.sub.page",    "Click to open the download page.",
    "upd.btn",         "Update now",
    "upd.btn.page",    "Download",
    "upd.loading",     "Downloading the update…",
    "upd.loading.sub", "DeskTabs restarts in a moment.",
    "upd.failed",      "Update not possible",
    "upd.failed.sub",  "Please install it from the download page.",
    "news.title",      "New in DeskTabs {1}",
    "news.all",        "All changes on GitHub",
    "feedback.mail.subject.bug", "DeskTabs {1}: bug report",
    "feedback.mail.subject.feedback", "DeskTabs {1}: idea or question",
    "feedback.mail.body.bug", "Hello Henning,`n`nI ran into this in DeskTabs:`n`nWhat happened:`n`nWhat I expected:`n`nHow to reproduce it:`n1.`n2.`n3.`n`nBest regards",
    "feedback.mail.body.feedback", "Hello Henning,`n`nhere is my idea or question about DeskTabs:`n`n`nBest regards"
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
if (A_Args.Length && A_Args[1] = "/cmd")
    CmdForward()
Main()

Main() {
    global VDA, MyGui
    OnError(LogErr)
    ReplaceOtherInstance()
    OnMessage(0x4A, OnCopyData)             ; WM_COPYDATA: Befehle von DeskTabs.exe /cmd ...
    NormalizeIniEncoding()
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
    MigrateLogs()                            ; alte Zeit-Log-Dateien in den Unterordner
    SyncDesktopIds()                         ; in Windows umbenannt, waehrend DeskTabs aus war?
    ApplyTheme()                             ; Farbsatz passend zum Windows-Theme
    BuildBar()
    ApplyWindowHooks()                       ; Pin auf alle Desktops + Change-Hook
    OnMessage(MSG_VD_CHANGED, OnDesktopChanged)
    if (CONF["WheelSwitch"])
        OnMessage(0x020A, OnWheel)          ; WM_MOUSEWHEEL
    OnMessage(0x0205, OnRButtonUp)          ; WM_RBUTTONUP -> Kontextmenue
    OnMessage(0x0208, OnMButtonUp)          ; WM_MBUTTONUP -> zurueck zum letzten Desktop
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
    LogOffGap()                              ; Zeit-Log: Zeit seit dem letzten Eintrag als "off" nachtragen
    RestoreCall()                            ; laufendes Gespraech nach einem Neustart fortsetzen
    UpdateHighlight()                        ; oeffnet auch das erste Zeit-Log-Segment
    ; Zeit-Log: Sperren/Entsperren des Bildschirms als Pause erkennen (immer
    ; registrieren, TimeLog kann zur Laufzeit ueber das Menue eingeschaltet werden)
    DllCall("Wtsapi32\WTSRegisterSessionNotification", "Ptr", A_ScriptHwnd, "UInt", 0)
    OnMessage(0x0218, OnPowerBroadcast)      ; WM_POWERBROADCAST: Ruhezustand als Luecke im Zeit-Log
    OnMessage(0x0202, CallPillUp)            ; Klick auf die Gespraechs-Pille
    OnMessage(0x0020, CallPillCursor)
    OnMessage(0x02B1, OnSessionChange)      ; WM_WTSSESSION_CHANGE
    BuildTray()
    OnMessage(0x0202, CardUp)                ; Klicks in die Hinweis-Karten
    OnMessage(0x0020, CardSetCursor)
    OnMessage(0x020A, CardWheel)             ; Mausrad: lange Neuigkeiten scrollen
    global gWasWelcomed := IniRead(CONF["IniPath"], "State", "Welcomed", "")   ; vor FirstRunHint lesen
    SetTimer(NewsAfterUpdate, -4000)         ; erster Start nach einem Update: was ist neu
    SetTimer(AutoUpdateTick, -20000)         ; Update-Pruefung 20 s nach dem Start, hoechstens einmal pro Tag
    SetTimer(FirstRunHint, -1500)            ; beim allerersten Start kurz erklaeren, wo die Einstellungen sind
    ApplyHotkeys()                           ; Direktsprung-Tasten, falls eingeschaltet
    InitSwitchWatch()                        ; Windows-Tastenkuerzel fuer Wechsel mitbekommen
    InitAttentionWatch()                     ; blinkende Programme auf anderen Desktops
    InitDragWatch()                          ; Fenster per Titelleiste auf einen Tab ziehen
}

; Beim allerersten Start (noch keine settings.ini) einmalig erklaeren, wie man
; die Leiste bedient. Danach nie wieder - der Merker steht in der Datei selbst.
FirstRunHint() {
    if (IniRead(CONF["IniPath"], "State", "Welcomed", "") = "1")
        return
    IniSet("State", "Welcomed", 1)
    TrayTip(T("firstrun.text"), T("firstrun.title"), 0x1)
    SetTimer(() => TrayTip(), -12000)
}

; ------------------------ Einstellungen (settings.ini [View]) ---------------
; Alles, was das Kontextmenue umschaltet, landet in settings.ini [View] und
; ueberschreibt beim Start bzw. beim Live-Reload die CONF-Standardwerte.
ApplyIniOverrides() {
    ; Frueher gab es "ueber der Taskleiste" (DockMode=above). Die Leiste lag dann ueber
    ; der Unterkante jedes Fensters - entfernt in 1.1.5. Alte Eintraege zurueck auf die
    ; Taskleiste holen: Schalter und die dazu passende Hoehe vergessen, X bleibt.
    if (IniRead(CONF["IniPath"], "View", "DockMode", "") != "") {
        IniDel("View", "DockMode")
        IniDel("Position", "Y")
    }
    for key, allowed in Map("CompactMode", "auto,full,short,icon,big,bigtext", "ThemeMode", "auto,light,dark"
                          , "Language", "*", "ActiveStyle", "desktop,accent,soliddesk,solid", "TabShape", "tabs,register"
                          , "SwitchMethod", "native,dll", "NumberBadge", "auto,on,off") {
        v := IniRead(CONF["IniPath"], "View", key, "")
        if (v != "" && (allowed = "*" || InStr("," allowed ",", "," v ",")))
            CONF[key] := v
    }
    ; Modifikator frei, aber nur aus den vier Zeichen und nicht leer
    v := IniRead(CONF["IniPath"], "View", "HotkeyMod", "")
    if (v != "" && RegExMatch(v, "^[\^+!#]{1,4}$"))
        CONF["HotkeyMod"] := v
    for key in ["ShowIndex", "ColorCoding", "SnapToTaskbar", "TimeLog", "UpdateCheck", "ShowDividers", "ShowIcons", "Hotkeys", "ActiveBold", "ActiveShadow", "SwitchAlert", "AttentionDot", "DragToTab", "RestoreZOrder", "ClaudeCode"] {
        v := IniRead(CONF["IniPath"], "View", key, "")
        if (v = "0" || v = "1")
            CONF[key] := Integer(v)
    }
    v := IniRead(CONF["IniPath"], "View", "CallHotkey", "-")
    if (v = "" || RegExMatch(v, "^[\^+!#]{1,4}\w+$"))
        CONF["CallHotkey"] := v
    v := IniRead(CONF["IniPath"], "View", "TimeLogMinSec", "")
    if (RegExMatch(v, "^\d{1,3}$"))
        CONF["TimeLogMinSec"] := Integer(v)
    v := IniRead(CONF["IniPath"], "View", "DefaultIcons", "")
    if (v = "0" || v = "1" || v = "2")
        CONF["DefaultIcons"] := Integer(v)
}

; Einstellung setzen, merken, anwenden
SetView(key, val) {
    CONF[key] := val
    IniSet("View", key, val)
    if (key = "TimeLog")
        val ? LogOpen(GetCurrentDesktop()) : LogClose()
    if (key = "Hotkeys" || key = "HotkeyMod")
        ApplyHotkeys()
    if (key = "Language") {
        InitLanguage()
        BuildTray()
    }
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

; Schnellfilter: Beschriftung => Suchbegriffe, durch | getrennt (ODER-Suche).
; Bewusst mehrere Begriffe je Thema, sonst liefert ein Filter nur eine Handvoll
; Treffer - die Namen im Index sind englisch, die deutschen Woerter kommen nur
; bei den gemappten Begriffen dazu.
GlyphTopics() => Map(
      T("iconlib.t.files"),  "folder|file|document|page|ordner|datei|dokument|save|copy|print"
    , T("iconlib.t.time"),   "time|clock|calendar|date|history|timer|hour|zeit|kalender|termin"
    , T("iconlib.t.people"), "people|person|contact|user|account|group|team|profile|kontakt|benutzer"
    , T("iconlib.t.comm"),   "mail|message|chat|comment|send|reply|inbox|phone|call|nachricht|post"
    , T("iconlib.t.media"),  "photo|picture|image|video|camera|music|audio|play|media|bild|foto|musik"
    , T("iconlib.t.data"),   "chart|graph|analytics|data|report|table|calculator|percent|diagramm|daten"
    , T("iconlib.t.system"), "settings|system|device|network|power|security|tool|repair|einstellungen|werkzeug"
    , T("iconlib.t.places"), "map|location|place|home|globe|world|car|train|flight|ort|karte|welt")

IsGlyphSpec(s) => (SubStr(s, 1, 6) = "glyph:")
IsNumberSpec(s) => (s = "number")          ; Nummer des Desktops als Symbol (gefuellter Kreis)
IsDrawnSpec(s) => (IsGlyphSpec(s) || IsNumberSpec(s))   ; gezeichnet statt aus einer Bilddatei
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
    global gMenuGlyphs
    gMenuGlyphs[menu.Handle "|" item] := code          ; gezeichnet wird in OdDraw aus der Symbolschrift
}

; Auswahlfenster: Suchfeld, Schnellfilter und ein rollbares Raster ueber die
; gesamte Bibliothek. Eine Seite ist EIN gezeichnetes Bild (wie die Leiste), nicht
; hundert Steuerelemente - sonst baut sich das Raster beim Rollen sichtbar auf.
; Fertige Seiten bleiben im Zwischenspeicher, die Nachbarseiten werden vorbereitet.
; Bedienung: Klick markiert, OK (oder Doppelklick, oder Enter) uebernimmt.
ShowIconLibrary(num, *) {
    NCOLS := 12, NROWS := 8, CELLW := 44   ; als lokale Variablen, damit die inneren Funktionen sie mitbekommen
    glyphs := GlyphList()
    raw := GetDesktopNameRaw(num)
    col := DesktopColor(num)
    gridW := NCOLS * CELLW, gridH := NROWS * CELLW
    filtered := [], offset := 0, pages := Map(), sig := "", hoverCell := 0, lastInfo := ""
    selG := 0                                ; markiertes Symbol (Index in glyphs, 0 = keins)

    ; aktuelles Bibliotheks-Symbol des Desktops vormarkieren
    curSpec := IconPathFor(num)
    if (IsGlyphSpec(curSpec)) {
        curCode := SubStr(curSpec, 7)
        for gi, gl in glyphs
            if (gl["code"] = curCode) {
                selG := gi
                break
            }
    }

    g := Gui("+AlwaysOnTop +OwnDialogs -MinimizeBox -MaximizeBox", T("iconlib.title", raw))
    g.SetFont("s10", "Segoe UI")
    g.MarginX := 14, g.MarginY := 12
    g.Add("Text", "xm ym w" (gridW + 21), T("iconlib.hint"))
    search := g.Add("Edit", "xm y+8 w" (gridW - 13) " h26")
    SendMessage(0x1501, 1, StrPtr(T("iconlib.search")), search)   ; EM_SETCUEBANNER
    btnClear := g.Add("Button", "x+4 yp w30 h26", "✕")            ; Suche leeren
    btnClear.OnEvent("Click", (*) => (search.Value := "", ApplyFilter(""), search.Focus()))
    g.SetFont("s9")
    firstBtn := 0
    for label, topic in GlyphTopics() {
        b := g.Add("Button", (firstBtn ? "x+4 yp" : "xm y+8") " h24 w" Max(58, StrLen(label) * 8), label)
        b.OnEvent("Click", ((t, *) => (search.Value := t, ApplyFilter(t))).Bind(topic))
        if (!firstBtn)
            firstBtn := b
    }
    g.SetFont("s10")
    ty := 0, th := 0
    firstBtn.GetPos(, &ty, , &th)
    gridX := 14, gridY := ty + th + 10

    sheet := g.Add("Picture", Format("x{1} y{2} w{3} h{4} +0x100", gridX, gridY, gridW, gridH))
    sb := g.Add("Custom", Format("ClassScrollBar x{1} y{2} w17 h{3} 0x1", gridX + gridW + 4, gridY, gridH))
    info := g.Add("Text", "x" gridX " y" (gridY + gridH + 14) " w" (gridW - 250) " h24 +0x200", "")
    btnOk := g.Add("Button", "x" (gridX + gridW - 211) " y" (gridY + gridH + 12) " w110 h28 Default", T("dlg.ok"))
    btnCancel := g.Add("Button", "x+8 yp w110 h28", T("dlg.cancel"))
    btnOk.OnEvent("Click", (*) => Apply())
    btnCancel.OnEvent("Click", (*) => Close())

    ; Zeichenflaeche in echten Bildpunkten (das Fenster ist bei hoher DPI skaliert)
    rc0 := Buffer(16, 0)
    DllCall("GetClientRect", "Ptr", sheet.Hwnd, "Ptr", rc0)
    pw := NumGet(rc0, 8, "Int"), ph := NumGet(rc0, 12, "Int")
    if (pw < NCOLS || ph < NROWS)
        pw := gridW, ph := gridH
    CELLP := pw / NCOLS, CELLH := ph / NROWS
    zoom := pw / gridW

    ; --- eine Seite als Bild zeichnen (und im Zwischenspeicher behalten) ---
    PageBitmap(off) {
        key := sig "|" off "|" selG
        if (pages.Has(key))
            return pages[key]
        GdipStart()
        bmp := 0, gr := 0
        DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", pw, "Int", ph, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &bmp)
        DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", bmp, "Ptr*", &gr)
        DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", gr, "Int", 4)
        DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", gr, "Int", 5)
        DllCall("gdiplus\GdipGraphicsClear", "Ptr", gr, "UInt", ARGB(0xF6F6F6))
        font := MakeIconFont(28 * zoom)
        sf := MakeFormat()
        Loop NCOLS * NROWS {
            i := A_Index
            idx := off * NCOLS + i
            if (idx > filtered.Length)
                break
            cx := Mod(i - 1, NCOLS) * CELLP, cy := ((i - 1) // NCOLS) * CELLH
            if (filtered[idx] = selG)
                MarkCell(gr, cx, cy)
            DrawText(gr, font, sf, GlyphChar("glyph:" glyphs[filtered[idx]]["code"]), cx, cy, CELLP, CELLH, ARGB(col))
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
    ; Markierung: zart getoente Flaeche mit Rahmen in der Desktop-Farbe
    MarkCell(gr, cx, cy) {
        m := 2 * zoom, rr := 6 * zoom, lw := 2 * zoom
        FillRoundRect(gr, cx + m, cy + m, CELLP - 2 * m, CELLH - 2 * m, rr, ARGB(Mix(col, 0xF6F6F6, 16)))
        pen := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB(col), "Float", lw, "Int", 2, "Ptr*", &pen)
        path := RoundRectPath(cx + m + lw / 2, cy + m + lw / 2, CELLP - 2 * m - lw, CELLH - 2 * m - lw, rr)
        DllCall("gdiplus\GdipDrawPath", "Ptr", gr, "Ptr", pen, "Ptr", path)
        DllCall("gdiplus\GdipDeletePath", "Ptr", path)
        DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
    }
    ; Bild tauschen, ohne dass die Flaeche vorher leer aufblitzt: Neuzeichnen
    ; kurz aussetzen und danach ohne Hintergrund-Loeschen neu malen lassen.
    ShowPage() {
        SendMessage(0x000B, 0, 0, sheet)             ; WM_SETREDRAW aus
        sheet.Value := "HBITMAP:*" PageBitmap(offset)
        SendMessage(0x000B, 1, 0, sheet)             ; WM_SETREDRAW an
        DllCall("RedrawWindow", "Ptr", sheet.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0101)  ; INVALIDATE | UPDATENOW
        SetScroll(Ceil(filtered.Length / NCOLS), NROWS, offset)
        UpdateInfo()
        SetTimer(Preload, -60)          ; Nachbarseiten im Hintergrund vorbereiten
    }
    Preload() {
        maxOff := Max(0, Ceil(filtered.Length / NCOLS) - NROWS)
        for , off in [offset + 1, offset - 1, offset + NROWS, offset - NROWS]
            if (off >= 0 && off <= maxOff)
                PageBitmap(off)
    }
    ; Zeile unter dem Raster: Name unter der Maus, sonst die Auswahl, sonst die Anzahl
    UpdateInfo() {
        if (hoverCell && offset * NCOLS + hoverCell <= filtered.Length)
            txt := glyphs[filtered[offset * NCOLS + hoverCell]]["name"]
        else if (selG)
            txt := T("iconlib.selected", glyphs[selG]["name"])
        else if (filtered.Length = 0)
            txt := T("iconlib.none")
        else
            txt := T("iconlib.count", filtered.Length)
        if (txt != lastInfo) {
            lastInfo := txt
            info.Text := txt
        }
        btnOk.Enabled := (selG > 0)
    }
    SetScroll(nRows, pageSize, pos) {
        si := Buffer(28, 0)
        NumPut("UInt", 28, "UInt", 0x17, "Int", 0, "Int", Max(0, nRows - 1), "UInt", pageSize, "Int", pos, si)
        DllCall("SetScrollInfo", "Ptr", sb.Hwnd, "Int", 2, "Ptr", si, "Int", 1)
    }
    ApplyFilter(needle) {
        needle := Trim(StrLower(needle))
        terms := (needle = "") ? [] : StrSplit(needle, "|")   ; mehrere Begriffe = ODER
        filtered := []
        for i, item in glyphs {
            hitAny := (terms.Length = 0)
            for , tm in terms {
                tm := Trim(tm)
                if (tm != "" && InStr(item["kw"], tm)) {
                    hitAny := true
                    break
                }
            }
            if (hitAny)
                filtered.Push(i)
        }
        sig := needle, offset := 0, hoverCell := 0
        ShowPage()
    }
    Scroll(deltaRows) {
        maxOff := Max(0, Ceil(filtered.Length / NCOLS) - NROWS)
        newOff := Min(Max(offset + deltaRows, 0), maxOff)
        if (newOff = offset)
            return
        offset := newOff, hoverCell := 0
        ShowPage()
    }
    ; Die markierte Zeile ins Bild rollen (beim Oeffnen)
    RevealSelection() {
        for k, gi2 in filtered
            if (gi2 = selG) {
                maxOff := Max(0, Ceil(filtered.Length / NCOLS) - NROWS)
                offset := Min(Max((k - 1) // NCOLS - NROWS // 2 + 1, 0), maxOff)
                ShowPage()
                return
            }
    }
    ; Zelle unter der Maus (1-basiert, 0 = daneben); idx = Position in filtered.
    ; Gerechnet wird direkt im Koordinatensystem des Rasters - Rahmen und
    ; Titelleiste des Fensters spielen so keine Rolle (frueher um 8/31 px versetzt).
    CellAt(&idx) {
        pt := Buffer(8, 0)
        DllCall("GetCursorPos", "Ptr", pt)
        DllCall("ScreenToClient", "Ptr", sheet.Hwnd, "Ptr", pt)
        lx := NumGet(pt, 0, "Int"), ly := NumGet(pt, 4, "Int")
        if (lx < 0 || ly < 0 || lx >= pw || ly >= ph)
            return 0
        hit := Floor(ly / CELLH) * NCOLS + Floor(lx / CELLP) + 1
        idx := offset * NCOLS + hit
        return (idx <= filtered.Length) ? hit : 0
    }
    ; Beim Ueberfahren wird NICHT neu gezeichnet (sonst blitzt die Seite), nur die
    ; Namenszeile unter dem Raster aendert sich. Keine schwebende Kurzinfo mehr -
    ; die lag unter dem Mauszeiger und schluckte Klicks.
    HoverTickLib() {
        if (!WinExist("ahk_id " g.Hwnd))
            return
        idx := 0
        hit := CellAt(&idx)
        if (hit != hoverCell) {
            hoverCell := hit
            UpdateInfo()
        }
    }
    SheetClick(*) {
        idx := 0
        if (!CellAt(&idx) || filtered[idx] = selG)
            return
        selG := filtered[idx]
        ShowPage()
    }
    SheetDoubleClick(*) {
        idx := 0
        if (!CellAt(&idx))
            return
        selG := filtered[idx]
        Apply()
    }
    Apply() {
        if (selG)
            SetGlyphIcon(num, glyphs[selG]["code"], g, Close)
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
        OnMessage(0x0115, OnVScroll, 0)
        OnMessage(0x020A, OnPickerWheel, 0)
        for , h in pages
            DllCall("DeleteObject", "Ptr", h)
        g.Destroy()
    }

    sheet.OnEvent("Click", SheetClick)
    sheet.OnEvent("DoubleClick", SheetDoubleClick)
    search.OnEvent("Change", (ctrl, *) => ApplyFilter(ctrl.Value))
    OnMessage(0x0115, OnVScroll)
    OnMessage(0x020A, OnPickerWheel)
    g.OnEvent("Escape", (*) => Close())
    g.OnEvent("Close", (*) => Close())
    ApplyFilter("")
    if (selG)
        RevealSelection()
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
; Vorschlagssymbole: Desktops ohne eigenen Eintrag bekommen reihum eines davon,
; damit die Leiste vom ersten Start an nach etwas aussieht. Nur Anzeige - in der
; settings.ini steht nichts, jede eigene Zuweisung sticht das hier sofort aus.
DefaultGlyph(num) {
    static set := StrSplit("E7F4 E838 E715 E787 E9D2 E90F E8F1 E77B E912 E774 E8EF E8AE", " ")
    return "glyph:" set[Mod(DeskOrdinal(num), set.Length) + 1]
}

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
    spec := IniLookup("Icons", raw)
    if (spec = "none")                       ; ausdruecklich entfernt: auch kein Vorschlag
        return ""
    if (spec = "")
        return (CONF["DefaultIcons"] = 2) ? "number" : CONF["DefaultIcons"] ? DefaultGlyph(num) : ""
    if (IsDrawnSpec(spec))
        return spec                      ; Bibliotheks-Symbol oder Nummer, wird direkt gezeichnet
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

    ; Nur (annaehernd) quadratische Bilder taugen als Tab-Symbol. Manche Seiten tragen als
    ; apple-touch-icon einfach ihr breites Logo ein (z.B. Website-Baukaesten); das wird
    ; uebersprungen und nur genommen, wenn sich gar nichts Quadratisches findet.
    DirCreate(IconsDir())
    tmpFile := IconsDir() "\_dl.tmp", wideFile := IconsDir() "\_wide.tmp", haveWide := false
    try FileDelete(wideFile)
    for cand in cands {
        bytes := HttpGetBytes(cand["href"])
        if (!bytes)
            continue
        try FileDelete(tmpFile)
        if (!SaveBytes(bytes, tmpFile))
            continue
        if (ConvertToPng(tmpFile, dest, 128, 1.25)) {   ; grosszuegig zwischenspeichern, beim Zeichnen sauber verkleinert
            try FileDelete(tmpFile)
            try FileDelete(wideFile)
            return true
        }
        if (!haveWide && ImageSize(tmpFile)) {
            try FileCopy(tmpFile, wideFile, true)
            haveWide := FileExist(wideFile) ? true : false
        }
    }
    try FileDelete(tmpFile)
    ok := haveWide && ConvertToPng(wideFile, dest, 128)
    try FileDelete(wideFile)
    return ok
}

; Breite und Hoehe einer Bilddatei als [w, h], 0 wenn GDI+ sie nicht lesen kann
ImageSize(path) {
    GdipStart()
    img := 0
    if (DllCall("gdiplus\GdipCreateBitmapFromFile", "WStr", path, "Ptr*", &img) != 0 || !img)
        return 0
    w := 0, h := 0
    DllCall("gdiplus\GdipGetImageWidth", "Ptr", img, "UInt*", &w)
    DllCall("gdiplus\GdipGetImageHeight", "Ptr", img, "UInt*", &h)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", img)
    return (w && h) ? [w, h] : 0
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

; Bilddatei (ico/png/jpg/svg-frei) als quadratisches PNG in Zielgroesse speichern.
; maxRatio > 0: Bilder, deren Seitenverhaeltnis davon weiter abweicht, werden abgelehnt.
ConvertToPng(src, dest, size, maxRatio := 0) {
    GdipStart()
    img := 0
    if (DllCall("gdiplus\GdipCreateBitmapFromFile", "WStr", src, "Ptr*", &img) != 0 || !img)
        return false
    w := 0, h := 0
    DllCall("gdiplus\GdipGetImageWidth", "Ptr", img, "UInt*", &w)
    DllCall("gdiplus\GdipGetImageHeight", "Ptr", img, "UInt*", &h)
    if (!w || !h || (maxRatio > 0 && Max(w, h) / Min(w, h) > maxRatio)) {
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
    ; GDI+ haelt die Datei offen, solange das Bild lebt. Deshalb in eine eigene Kopie
    ; umzeichnen und das Original freigeben - sonst liesse sich ein angezeigtes Symbol
    ; weder erneuern noch loeschen (Abruf von der Webseite schlug dann immer fehl).
    if (img) {
        w := 0, h := 0, cp := 0, g := 0
        DllCall("gdiplus\GdipGetImageWidth", "Ptr", img, "UInt*", &w)
        DllCall("gdiplus\GdipGetImageHeight", "Ptr", img, "UInt*", &h)
        if (w && h && DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", w, "Int", h, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &cp) = 0 && cp) {
            DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", cp, "Ptr*", &g)
            DllCall("gdiplus\GdipDrawImageRectI", "Ptr", g, "Ptr", img, "Int", 0, "Int", 0, "Int", w, "Int", h)
            DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
            DllCall("gdiplus\GdipDisposeImage", "Ptr", img)
            img := cp
        }
    }
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
    if (spec = "" || IsDrawnSpec(spec)) {
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
    cur := IniLookup("Icons", raw)
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

SetNumberIcon(num, *) {
    raw := GetDesktopNameRaw(num)
    IniSet("Icons", raw, "number")
    try FileDelete(IconsDir() "\" SafeName(raw) ".png")
    RebuildAll()
}

ClearIcon(num, *) {
    raw := GetDesktopNameRaw(num)
    IniDelLoose("Icons", raw)
    try FileDelete(IconsDir() "\" SafeName(raw) ".png")
    if (CONF["DefaultIcons"])
        IniSet("Icons", raw, "none")         ; sonst erschiene sofort wieder das Vorschlagssymbol
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
    if (si := SetAt(BarMouseX())) {
        SetTimer(SetMenu.Bind(si), -1)
        return 0
    }
    item := ItemAtX(BarMouseX())
    ; Menue nicht hier im Handler oeffnen: m.Show() blockiert, bis das Menue zu ist. Ein
    ; Rechtsklick auf den naechsten Tab kam sonst an, solange dieser Handler noch lief, und
    ; wurde verworfen (Menue ging erst beim zweiten Klick auf). So ist der Handler sofort frei.
    SetTimer(ShowContextMenu.Bind(item ? item["num"] : -1), -1)
    return 0
}

; Kopf jedes Menues: App-Symbol, "DeskTabs" fett und die Version kleiner und grau
; dahinter. Ein normaler Menue-Eintrag kann Groesse und Farbe nicht mischen, also
; wird diese eine Zeile selbst gezeichnet (owner-draw). Klick oeffnet "Ueber DeskTabs".
AddAppHeader(m) {
    static hooked := false
    if (!hooked) {
        OnMessage(0x002C, HeadMeasure)          ; WM_MEASUREITEM
        OnMessage(0x002B, HeadDraw)             ; WM_DRAWITEM
        hooked := true
    }
    m.Add("DeskTabs", ShowAbout)
    m.Add()
    mii := Buffer(80, 0)                        ; MENUITEMINFOW (64 Bit)
    NumPut("UInt", 80, "UInt", 0x100 | 0x20, "UInt", 0x100, mii)   ; MIIM_FTYPE|MIIM_DATA, MFT_OWNERDRAW
    NumPut("UPtr", 0xDE5C, mii, 48)                                ; Kennung fuer HeadMeasure/HeadDraw
    DllCall("SetMenuItemInfoW", "Ptr", m.Handle, "UInt", 0, "Int", 1, "Ptr", mii)
}

; Schriften des Menues (Windows-Menueschrift): fett fuer den Namen, kleiner fuer die Version
HeadFonts() {
    static fonts := 0
    if (fonts)
        return fonts
    ncm := Buffer(504, 0)
    NumPut("UInt", 504, ncm)
    DllCall("SystemParametersInfoW", "UInt", 0x29, "UInt", 504, "Ptr", ncm, "UInt", 0)   ; SPI_GETNONCLIENTMETRICS
    lf := Buffer(92, 0)
    DllCall("RtlMoveMemory", "Ptr", lf, "Ptr", ncm.Ptr + 224, "UPtr", 92)                ; lfMenuFont
    h := NumGet(lf, 0, "Int")
    NumPut("Int", 700, lf, 16)
    bold := DllCall("CreateFontIndirectW", "Ptr", lf, "Ptr")
    NumPut("Int", Round(h * 0.85), lf, 0)
    NumPut("Int", 400, lf, 16)
    small := DllCall("CreateFontIndirectW", "Ptr", lf, "Ptr")
    NumPut("Int", h, lf, 0)
    normal := DllCall("CreateFontIndirectW", "Ptr", lf, "Ptr")
    fonts := [bold, small, normal]
    return fonts
}

; ---------------- Menues komplett selbst zeichnen (Windows-11-Stil) ----------------
; Sobald ein Menue einen selbst gezeichneten Eintrag hat (Kopfzeile, Aktionszeile),
; zeichnet Windows den Rest im alten Stil: blauer Balken ueber die volle Breite,
; Symbol-Bildchen wirken darin ausgestanzt. Deshalb zeichnet DeskTabs alle Eintraege
; selbst: heller, abgerundeter Hover, Symbole aus der Symbolschrift, eigener Haken und
; Untermenue-Pfeil. Zustand (Haken, grau, fett) kommt beim Zeichnen von Windows.
OD_BG() => 0xF9F9F9                    ; Menue-Grund (GDI, BGR = RGB bei Grau)
OD_HOVER() => 0xEAEAEA
OwnerDrawAll(hMenu) {
    global gOd, gOdNext, gMenuGlyphs, gMenuSwatches
    static bgBrush := 0
    if (!bgBrush)
        bgBrush := DllCall("CreateSolidBrush", "UInt", OD_BG(), "Ptr")
    mi := Buffer(A_PtrSize = 8 ? 40 : 28, 0)            ; MENUINFO: einheitlicher heller Grund
    NumPut("UInt", mi.Size, mi, 0), NumPut("UInt", 0x2, mi, 4)          ; MIM_BACKGROUND
    NumPut("Ptr", bgBrush, mi, A_PtrSize = 8 ? 16 : 16)
    DllCall("SetMenuInfo", "Ptr", hMenu, "Ptr", mi)
    Loop DllCall("GetMenuItemCount", "Ptr", hMenu, "Int") {
        pos := A_Index - 1
        mii := Buffer(80, 0)
        NumPut("UInt", 80, mii, 0), NumPut("UInt", 0x100 | 0x20 | 0x4 | 0x40, mii, 4)   ; FTYPE|DATA|SUBMENU|STRING
        DllCall("GetMenuItemInfoW", "Ptr", hMenu, "UInt", pos, "Int", 1, "Ptr", mii)
        ftype := NumGet(mii, 8, "UInt"), sub := NumGet(mii, 24, "Ptr")
        if (sub)
            OwnerDrawAll(sub)
        if (ftype & 0x100)                               ; schon selbst gezeichnet (Kopf, Aktion, frueherer Lauf)
            continue
        text := ""
        if (!(ftype & 0x800)) {
            cch := NumGet(mii, 64, "UInt")
            buf := Buffer((cch + 1) * 2, 0)
            NumPut("UInt", 0x40, mii, 4), NumPut("Ptr", buf.Ptr, mii, 56), NumPut("UInt", cch + 1, mii, 64)
            DllCall("GetMenuItemInfoW", "Ptr", hMenu, "UInt", pos, "Int", 1, "Ptr", mii)
            text := StrGet(buf, "UTF-16")
        }
        key := hMenu "|" text
        id := gOdNext++
        gOd[id] := Map("text", text, "sep", (ftype & 0x800) ? 1 : 0, "sub", sub ? 1 : 0
            , "glyph", gMenuGlyphs.Has(key) ? gMenuGlyphs[key] : "", "swatch", gMenuSwatches.Has(key) ? gMenuSwatches[key] : -1)
        set := Buffer(80, 0)
        NumPut("UInt", 80, set, 0), NumPut("UInt", 0x100 | 0x20, set, 4)     ; FTYPE|DATA
        NumPut("UInt", ftype | 0x100, set, 8)                                ; MFT_OWNERDRAW dazu
        NumPut("UPtr", id, set, 48)
        DllCall("SetMenuItemInfoW", "Ptr", hMenu, "UInt", pos, "Int", 1, "Ptr", set)
    }
}
OdIconFont(px) {
    static fonts := Map()
    if (!fonts.Has(px))
        fonts[px] := DllCall("CreateFontW", "Int", -px, "Int", 0, "Int", 0, "Int", 0, "Int", 400, "UInt", 0, "UInt", 0, "UInt", 0
            , "UInt", 1, "UInt", 0, "UInt", 0, "UInt", 5, "UInt", 0, "Str", CONF["IconFont"], "Ptr")
    return fonts[px]
}
OdMeasure(lParam, rec) {
    s := A_ScreenDPI / 96
    if (rec["sep"]) {
        NumPut("UInt", Round(20 * s), lParam, 12), NumPut("UInt", Round(9 * s), lParam, 16)
        return 1
    }
    f := HeadFonts()
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    w := HeadTextW(hdc, f[1], rec["text"])                ; fett messen: Standard-Eintraege sind fett
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    NumPut("UInt", w + Round(70 * s), lParam, 12)         ; Symbolspalte + Text + Pfeilspalte
    NumPut("UInt", Round(30 * s), lParam, 16)
    return 1
}
OdDraw(lParam, rec) {
    s := A_ScreenDPI / 96
    hdc := NumGet(lParam, 32, "Ptr"), st := NumGet(lParam, 16, "UInt")
    l := NumGet(lParam, 40, "Int"), t := NumGet(lParam, 44, "Int"), r := NumGet(lParam, 48, "Int"), b := NumGet(lParam, 52, "Int")
    sel := (st & 1) && !(st & 6), dis := (st & 6), chk := (st & 8), def := (st & 0x20)
    rc := Buffer(16, 0)
    NumPut("Int", l, "Int", t, "Int", r, "Int", b, rc)
    br := DllCall("CreateSolidBrush", "UInt", OD_BG(), "Ptr")
    DllCall("FillRect", "Ptr", hdc, "Ptr", rc, "Ptr", br)
    DllCall("DeleteObject", "Ptr", br)
    if (rec["sep"]) {
        pen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", 0xE0E0E0, "Ptr")
        op := DllCall("SelectObject", "Ptr", hdc, "Ptr", pen, "Ptr")
        my := (t + b) // 2
        DllCall("MoveToEx", "Ptr", hdc, "Int", l + Round(8 * s), "Int", my, "Ptr", 0)
        DllCall("LineTo", "Ptr", hdc, "Int", r - Round(8 * s), "Int", my)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", op), DllCall("DeleteObject", "Ptr", pen)
        return 1
    }
    if (sel) {                                           ; Hover: hell, abgerundet, eingerueckt
        br := DllCall("CreateSolidBrush", "UInt", OD_HOVER(), "Ptr")
        oB := DllCall("SelectObject", "Ptr", hdc, "Ptr", br, "Ptr")
        oP := DllCall("SelectObject", "Ptr", hdc, "Ptr", DllCall("GetStockObject", "Int", 8, "Ptr"), "Ptr")   ; NULL_PEN
        DllCall("RoundRect", "Ptr", hdc, "Int", l + Round(4 * s), "Int", t + Round(1 * s), "Int", r - Round(4 * s) + 1
            , "Int", b - Round(1 * s) + 1, "Int", Round(8 * s), "Int", Round(8 * s))
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oB), DllCall("SelectObject", "Ptr", hdc, "Ptr", oP)
        DllCall("DeleteObject", "Ptr", br)
    }
    fg := dis ? 0xA0A0A0 : 0x1A1A1A
    DllCall("SetBkMode", "Ptr", hdc, "Int", 1)
    DllCall("SetTextColor", "Ptr", hdc, "UInt", fg)
    rt := Buffer(16, 0)
    gx := l + Round(10 * s), gw := Round(22 * s)
    if (rec["swatch"] >= 0) {                            ; Farbfeld (Farbmenue)
        c := rec["swatch"], bgr := ((c & 0xFF) << 16) | (c & 0xFF00) | ((c >> 16) & 0xFF)
        br := DllCall("CreateSolidBrush", "UInt", bgr, "Ptr")
        oB := DllCall("SelectObject", "Ptr", hdc, "Ptr", br, "Ptr")
        oP := DllCall("SelectObject", "Ptr", hdc, "Ptr", DllCall("GetStockObject", "Int", 8, "Ptr"), "Ptr")
        sz := Round(14 * s), sx := gx + (gw - sz) // 2, sy := t + (b - t - sz) // 2
        DllCall("RoundRect", "Ptr", hdc, "Int", sx, "Int", sy, "Int", sx + sz + 1, "Int", sy + sz + 1, "Int", Round(4 * s), "Int", Round(4 * s))
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oB), DllCall("SelectObject", "Ptr", hdc, "Ptr", oP)
        DllCall("DeleteObject", "Ptr", br)
    } else if (!chk && SubStr(rec["glyph"], 1, 4) = "ico:" && (hi := OdExeIcon(SubStr(rec["glyph"], 5), Round(16 * s)))) {
        sz := Round(16 * s)                              ; Programm-Icon statt Symbolschrift
        DllCall("DrawIconEx", "Ptr", hdc, "Int", gx + (gw - sz) // 2, "Int", t + (b - t - sz) // 2, "Ptr", hi, "Int", sz, "Int", sz, "UInt", 0, "Ptr", 0, "UInt", 3)
    } else if (chk || (rec["glyph"] != "" && SubStr(rec["glyph"], 1, 4) != "ico:")) {
        old := DllCall("SelectObject", "Ptr", hdc, "Ptr", OdIconFont(Round(16 * s)), "Ptr")
        NumPut("Int", gx, "Int", t, "Int", gx + gw, "Int", b, rt)
        DllCall("DrawTextW", "Ptr", hdc, "Str", Chr(chk ? 0xE73E : Integer("0x" rec["glyph"])), "Int", 1, "Ptr", rt, "UInt", 0x25)   ; CENTER|VCENTER|SINGLELINE
        DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
    }
    f := HeadFonts()
    old := DllCall("SelectObject", "Ptr", hdc, "Ptr", def ? f[1] : f[3], "Ptr")
    NumPut("Int", l + Round(40 * s), "Int", t, "Int", r - Round(28 * s), "Int", b, rt)
    DllCall("DrawTextW", "Ptr", hdc, "Str", rec["text"], "Int", -1, "Ptr", rt, "UInt", 0x8024)   ; VCENTER|SINGLELINE|END_ELLIPSIS
    DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
    if (rec["sub"]) {                                    ; eigener Pfeil, den von Windows wegschneiden
        old := DllCall("SelectObject", "Ptr", hdc, "Ptr", OdIconFont(Round(10 * s)), "Ptr")
        NumPut("Int", r - Round(26 * s), "Int", t, "Int", r - Round(10 * s), "Int", b, rt)
        DllCall("DrawTextW", "Ptr", hdc, "Str", Chr(0xE76C), "Int", 1, "Ptr", rt, "UInt", 0x25)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
        DllCall("ExcludeClipRect", "Ptr", hdc, "Int", r - Round(30 * s), "Int", t, "Int", r, "Int", b)
    }
    return 1
}

HeadTextW(hdc, font, s) {
    old := DllCall("SelectObject", "Ptr", hdc, "Ptr", font, "Ptr")
    sz := Buffer(8, 0)
    DllCall("GetTextExtentPoint32W", "Ptr", hdc, "Str", s, "Int", StrLen(s), "Ptr", sz)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
    return NumGet(sz, 0, "Int")
}

HeadMeasure(wParam, lParam, msg, hwnd) {
    global gMenuCaption, gMenuAction, gOd
    kind := NumGet(lParam, 24, "UPtr")
    if (NumGet(lParam, 0, "UInt") = 1 && gOd.Has(kind))
        return OdMeasure(lParam, gOd[kind])
    if (NumGet(lParam, 0, "UInt") != 1 || (kind != 0xDE5C && kind != 0xDE5D && kind != 0xDE5E))   ; ODT_MENU + unsere Kennung
        return
    f := HeadFonts(), s := A_ScreenDPI / 96
    if (kind = 0xDE5E) {                    ; Hauptaktion "Fenster hierher": hoch und breit
        hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
        w := HeadTextW(hdc, f[1], gMenuAction)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
        NumPut("UInt", w + Round(52 * s), lParam, 12)
        NumPut("UInt", Round(38 * s), lParam, 16)
        return 1
    }
    if (kind = 0xDE5D) {                    ; Zwischenzeile mit dem Desktop-Namen
        hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
        w := HeadTextW(hdc, f[3], gMenuCaption)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
        NumPut("UInt", w + Round(48 * s), lParam, 12)
        NumPut("UInt", Round(24 * s), lParam, 16)
        return 1
    }
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    w := HeadTextW(hdc, f[1], "DeskTabs") + Round(7 * s) + HeadTextW(hdc, f[2], APP_VERSION)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    NumPut("UInt", w + Round(48 * s), lParam, 12)                  ; itemWidth (Rest macht Windows)
    NumPut("UInt", Round(30 * s), lParam, 16)                      ; itemHeight
    return 1
}

HeadDraw(wParam, lParam, msg, hwnd) {
    global gMenuCaption, gMenuAction, gMenuActionCol, gOd
    kind := NumGet(lParam, 56, "UPtr")
    if (NumGet(lParam, 0, "UInt") = 1 && gOd.Has(kind))
        return OdDraw(lParam, gOd[kind])
    if (NumGet(lParam, 0, "UInt") != 1 || (kind != 0xDE5C && kind != 0xDE5D && kind != 0xDE5E))
        return
    static icon := 0
    f := HeadFonts(), s := A_ScreenDPI / 96
    hdc := NumGet(lParam, 32, "Ptr")
    l := NumGet(lParam, 40, "Int"), t := NumGet(lParam, 44, "Int"), r := NumGet(lParam, 48, "Int"), b := NumGet(lParam, 52, "Int")
    ; Grund: die Farbe, die Windows fuer das Menue gemalt hat (rechte obere Ecke der Zeile)
    bgc := OD_BG()                                                ; derselbe Grund wie alle Eintraege (OwnerDrawAll)
    br := DllCall("CreateSolidBrush", "UInt", bgc, "Ptr")
    rc := Buffer(16, 0)
    NumPut("Int", l, "Int", t, "Int", r, "Int", b, rc)
    DllCall("FillRect", "Ptr", hdc, "Ptr", rc, "Ptr", br)
    DllCall("DeleteObject", "Ptr", br)
    if (kind = 0xDE5E) {                    ; Hauptaktion: Flaeche in der Farbe des Ziel-Desktops
        sel := NumGet(lParam, 16, "UInt") & 1           ; ODS_SELECTED = Maus darueber
        fill := sel ? Mix(0x000000, gMenuActionCol, 22) : gMenuActionCol
        fg := ReadableOn(fill)
        bgr := (v) => ((v & 0xFF) << 16) | (v & 0xFF00) | ((v >> 16) & 0xFF)   ; GDI will BGR
        br := DllCall("CreateSolidBrush", "UInt", bgr(fill), "Ptr")
        oldB := DllCall("SelectObject", "Ptr", hdc, "Ptr", br, "Ptr")
        oldP := DllCall("SelectObject", "Ptr", hdc, "Ptr", DllCall("GetStockObject", "Int", 8, "Ptr"), "Ptr")   ; NULL_PEN
        DllCall("RoundRect", "Ptr", hdc, "Int", l + Round(4 * s), "Int", t + Round(3 * s), "Int", r - Round(4 * s)
            , "Int", b - Round(3 * s), "Int", Round(8 * s), "Int", Round(8 * s))
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldB)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldP)
        DllCall("DeleteObject", "Ptr", br)
        DllCall("SetBkMode", "Ptr", hdc, "Int", 1)
        DllCall("SetTextColor", "Ptr", hdc, "UInt", bgr(fg))
        static ifont := 0
        if (!ifont)
            ifont := DllCall("CreateFontW", "Int", -Round(15 * s), "Int", 0, "Int", 0, "Int", 0, "Int", 400, "UInt", 0, "UInt", 0, "UInt", 0
                , "UInt", 1, "UInt", 0, "UInt", 0, "UInt", 5, "UInt", 0, "Str", CONF["IconFont"], "Ptr")
        old := DllCall("SelectObject", "Ptr", hdc, "Ptr", ifont, "Ptr")
        rt := Buffer(16, 0)
        NumPut("Int", l + Round(10 * s), "Int", t, "Int", l + Round(32 * s), "Int", b, rt)   ; Symbolspalte wie OdDraw
        DllCall("DrawTextW", "Ptr", hdc, "Str", Chr(0xE72A), "Int", 1, "Ptr", rt, "UInt", 0x24)   ; Pfeil
        DllCall("SelectObject", "Ptr", hdc, "Ptr", f[1])
        NumPut("Int", l + Round(40 * s), "Int", t, "Int", r - Round(8 * s), "Int", b, rt)
        DllCall("DrawTextW", "Ptr", hdc, "Str", gMenuAction, "Int", -1, "Ptr", rt, "UInt", 0x24)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
        return 1
    }
    if (kind = 0xDE5D) {                    ; Desktop-Name: gut lesbares Mittelgrau statt blassem "deaktiviert"
        DllCall("SetBkMode", "Ptr", hdc, "Int", 1)
        old := DllCall("SelectObject", "Ptr", hdc, "Ptr", f[3], "Ptr")
        DllCall("SetTextColor", "Ptr", hdc, "UInt", 0x5C5C5C)
        rt := Buffer(16, 0)
        NumPut("Int", l + Round(40 * s), "Int", t, "Int", r, "Int", b, rt)     ; Textspalte wie OdDraw
        DllCall("DrawTextW", "Ptr", hdc, "Str", gMenuCaption, "Int", -1, "Ptr", rt, "UInt", 0x24)   ; VCENTER|SINGLELINE
        DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
        return 1
    }
    ; Symbol in der Spalte, in der auch die anderen Menue-Symbole stehen
    isz := Round(16 * s)                       ; so gross wie die Symbole der anderen Eintraege (OdDraw)
    if (!icon && FileExist(AppIconPath()))
        try icon := LoadPicture(AppIconPath(), "w" isz " h" isz " Icon1", &imgType)
    x := l + Round(10 * s) + (Round(22 * s) - isz) // 2   ; mittig in der Symbolspalte von OdDraw
    if (icon)
        DllCall("DrawIconEx", "Ptr", hdc, "Int", x, "Int", t + (b - t - isz) // 2, "Ptr", icon, "Int", isz, "Int", isz, "UInt", 0, "Ptr", 0, "UInt", 3)
    ; Texte auf gemeinsamer Grundlinie: Name fett, Version kleiner und grau
    tx := l + Round(40 * s)                    ; Textspalte wie OdDraw
    DllCall("SetBkMode", "Ptr", hdc, "Int", 1)
    old := DllCall("SelectObject", "Ptr", hdc, "Ptr", f[1], "Ptr")
    tm := Buffer(60, 0)
    DllCall("GetTextMetricsW", "Ptr", hdc, "Ptr", tm)
    asc := NumGet(tm, 4, "Int"), desc := NumGet(tm, 8, "Int")
    base := t + (b - t - asc - desc) // 2 + asc
    DllCall("SetTextAlign", "Ptr", hdc, "UInt", 24)               ; TA_BASELINE
    DllCall("SetTextColor", "Ptr", hdc, "UInt", DllCall("GetSysColor", "Int", 7, "UInt"))   ; COLOR_MENUTEXT
    DllCall("TextOutW", "Ptr", hdc, "Int", tx, "Int", base, "Str", "DeskTabs", "Int", 8)
    w1 := HeadTextW(hdc, f[1], "DeskTabs")
    DllCall("SelectObject", "Ptr", hdc, "Ptr", f[2])
    DllCall("SetTextColor", "Ptr", hdc, "UInt", 0x8A8A8A)          ; grau, ruhiger als der Name
    DllCall("TextOutW", "Ptr", hdc, "Int", tx + w1 + Round(7 * s), "Int", base, "Str", APP_VERSION, "Int", StrLen(APP_VERSION))
    DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
    DllCall("SetTextAlign", "Ptr", hdc, "UInt", 0)
    return 1
}

ShowContextMenu(num, *) {
    fgw := WorkWindow()                     ; vor dem Menue merken, an welchem Fenster gearbeitet wird
    ToolTip(, , , 4)                        ; Namens-Kurzinfo nicht ueber dem Menue stehen lassen
    m := Menu()
    AddAppHeader(m)
    if (num >= 0) {
        raw := GetDesktopNameRaw(num)
        head := (num + 1) " · " raw
        m.Add(head, (*) => 0)
        m.Disable(head)
        global gMenuCaption := head             ; selbst gezeichnet, siehe HeadDraw
        mii := Buffer(80, 0)
        NumPut("UInt", 80, "UInt", 0x100 | 0x20, "UInt", 0x100, mii)
        NumPut("UPtr", 0xDE5D, mii, 48)
        DllCall("SetMenuItemInfoW", "Ptr", m.Handle, "UInt", 2, "Int", 1, "Ptr", mii)   ; Position 2: nach Kopf und Linie
        fpin := PinState(fgw)
        if (fgw && fpin >= 1) {
            ; Fenster bzw. App liegt auf allen Desktops: hier sichtbar und abwaehlbar (Haken weg =
            ; nur noch auf DIESEM Desktop). Setzen geht bewusst nur ueber den Griff.
            prog := TruncName(ProgName(fgw), 24)
            pl := T(fpin = 2 ? "menu.pin.app" : "menu.pin.window", prog)
            m.Add(pl, fpin = 2 ? UnpinAppTo.Bind(num, fgw) : MoveWindowTo.Bind(num, fgw))
            m.Check(pl)
            ph := T("menu.pin.untick", raw)
            m.Add(ph, (*) => 0)
            m.Disable(ph)
            if (num = GetCurrentDesktop())
                m.Add()
        }
        ; Hauptaktion nur fuer normale Fenster und fremde Desktops
        if (fgw && fpin = 0 && num != GetCurrentDesktop()) {
            mv := T("menu.tab.movehere", TruncName(ProgName(fgw), 24))   ; Programmname, nicht der (oft lange) Fenstertitel
            m.Add(mv, MoveWindowTo.Bind(num, fgw))
            ; Hauptaktion des Tab-Menues: selbst gezeichnet, gross und in der Desktop-Farbe
            global gMenuAction := mv, gMenuActionCol := DesktopColor(num)
            mii := Buffer(80, 0)
            NumPut("UInt", 80, "UInt", 0x100 | 0x20, "UInt", 0x100, mii)
            NumPut("UPtr", 0xDE5E, mii, 48)
            DllCall("SetMenuItemInfoW", "Ptr", m.Handle, "UInt", 3, "Int", 1, "Ptr", mii)   ; Position 3: nach Kopf, Linie, Name
        }
        if (num != GetCurrentDesktop()) {
            wl := Menu()
            seen := Map()
            for , w in WindowsOnDesktop(GetCurrentDesktop()) {
                lbl := TruncName(w["title"], 48) "  (" w["proc"] ")"
                while seen.Has(lbl)
                    lbl .= " "                      ; gleiche Titel: Menuepunkte muessen eindeutig sein
                seen[lbl] := true
                wl.Add(lbl, MoveWindowTo.Bind(num, w["hwnd"]))
            }
            if (seen.Count) {
                m.Add(T("menu.tab.fetch"), wl)
                MenuGlyph(m, T("menu.tab.fetch"), "E8A7")
            }
            m.Add()                                 ; Aktionen oben, Einstellungen des Tabs darunter
        }
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
        if (iconSpec = "" || IsDrawnSpec(iconSpec))
            cm.Disable(T("menu.color.fromicon"))
        cm.Add(T("menu.color.default"), ClearColor.Bind(num))
        im := Menu()
        im.Add(T("menu.icon.library"), ShowIconLibrary.Bind(num))
        MenuGlyph(im, T("menu.icon.library"), "ECAA")
        im.Add(T("menu.icon.url"), PromptIconUrl.Bind(num))
        MenuGlyph(im, T("menu.icon.url"), "E774")
        im.Add(T("menu.icon.file"), PromptIconFile.Bind(num))
        MenuGlyph(im, T("menu.icon.file"), "E8B9")
        im.Add(T("menu.icon.number"), SetNumberIcon.Bind(num))
        if (IsNumberSpec(IniLookup("Icons", raw)))
            im.Check(T("menu.icon.number"))
        im.Add()
        im.Add(T("menu.icon.clear"), ClearIcon.Bind(num))
        if (IniLookup("Icons", raw) = "none")
            im.Disable(T("menu.icon.clear"))
        m.Add(T("menu.tab.icon"), im)
        MenuGlyph(m, T("menu.tab.icon"), "E91B")
        m.Add(T("menu.tab.color"), cm)
        MenuGlyph(m, T("menu.tab.color"), "E790")
        m.Add(T("menu.tab.short"), PromptShort.Bind(num))
        MenuGlyph(m, T("menu.tab.short"), "E8AC")
        callLbl := CallActiveOn(num) ? T("menu.call.stop", CallDuration()) : T("menu.call.start")
        m.Add(callLbl, CallActiveOn(num) ? StopCall : StartCall.Bind(num))
        MenuGlyph(m, callLbl, "E916")
        if (CONF["ClaudeCode"]) {
            ctag := ClaudeTag(raw)
            m.Add(T("menu.claude.gather", ctag), ClaudeGather.Bind(num))
            MenuGlyph(m, T("menu.claude.gather", ctag), ClaudeGlyph())
            m.Add(T("menu.claude.tag"), ClaudeTagAsk.Bind(num))
            MenuGlyph(m, T("menu.claude.tag"), ClaudeGlyph())
        }
        subCur := SubActive(num)
        subLbl := (subCur != "") ? T("menu.sub.current", subCur) : T("menu.sub")
        m.Add(subLbl, SubMenu(num))
        MenuGlyph(m, subLbl, "E8EC")
        m.Add(T("menu.tab.compact"), ToggleCompact.Bind(num))
        if (IsCompactDesk(num))
            m.Check(T("menu.tab.compact"))
        m.Add(T("menu.tab.rename"), PromptRename.Bind(num))
        MenuGlyph(m, T("menu.tab.rename"), "E70F")
        m.Add(T("menu.tab.remove"), RemoveDesktopAsk.Bind(num))
        MenuGlyph(m, T("menu.tab.remove"), "E74D")
        if (GetDesktopCount() < 2)
            m.Disable(T("menu.tab.remove"))
        m.Add()
    }
    if (num < 0) {
        m.Add(T("menu.newdesk"), NewDesktop)
        MenuGlyph(m, T("menu.newdesk"), "E710")
        m.Add(T("menu.set.save"), SetSaveAsk)
        MenuGlyph(m, T("menu.set.save"), "E8A9")
        m.Add()
    }
    ; Griff bzw. Luecke: gehoert keinem Desktop, also der Ort fuer "auf allen Desktops"
    if (num < 0 && fgw) {
        prog := TruncName(ProgName(fgw), 24)
        fpin := PinState(fgw)
        pw := T("menu.pin.window", prog), pa := T("menu.pin.app", prog)
        m.Add(pw, TogglePinWindow.Bind(fgw))
        m.Add(pa, TogglePinApp.Bind(fgw))
        if (fpin >= 1)
            m.Check(pw)
        if (fpin = 2) {
            m.Check(pa)
            m.Disable(pw)                          ; gilt schon ueber die App
        }
        m.Add()
    }
    FillSettingsMenu(m)
    OwnerDrawAll(m.Handle)
    m.Show()
}

; Allgemeiner Teil des Einstellungsmenues; identisch im Rechtsklick auf die
; Leiste und im Tray-Menue (dort ohne Umweg ueber "Einstellungen…").
FillSettingsMenu(m) {
    ; Reihenfolgen stehen bewusst in Arrays: eine Map zaehlt ihre Schluessel
    ; alphabetisch auf, die Menues standen dadurch frueher kreuz und quer.
    ; Ansicht: erst die Stufe (was im Tab steht, von breit nach schmal),
    ; darunter Symbole, Nummern und die Schalter fuer die Optik der Leiste.
    vm := Menu()
    for , it in [["auto", T("menu.view.auto")], ["bigtext", T("level.bigtext")], ["full", T("level.full")]
               , ["short", T("level.short")], ["icon", T("level.icon")], ["big", T("level.big")]] {
        vm.Add(it[2], SetViewStr.Bind("CompactMode", it[1]))
        if (CONF["CompactMode"] = it[1])
            vm.Check(it[2])
    }
    vm.Add()
    sm := Menu()
    sm.Add(T("menu.icons.show"), ToggleView.Bind("ShowIcons"))
    if (CONF["ShowIcons"])
        sm.Check(T("menu.icons.show"))
    sm.Add()
    sm.Add(T("menu.noicon"), (*) => 0)
    sm.Disable(T("menu.noicon"))
    for , it in [[1, T("menu.noicon.suggest")], [2, T("menu.noicon.number")], [0, T("menu.noicon.none")]] {
        sm.Add(it[2], SetViewStr.Bind("DefaultIcons", it[1]))
        if (CONF["DefaultIcons"] = it[1])
            sm.Check(it[2])
    }
    vm.Add(T("menu.icons"), sm)
    MenuGlyph(vm, T("menu.icons"), "E91B")
    nm := Menu()
    nm.Add(T("menu.showindex"), ToggleView.Bind("ShowIndex"))
    if (CONF["ShowIndex"])
        nm.Check(T("menu.showindex"))
    ; Haken zeigt, ob die Badges gerade zu sehen sind; ein Klick legt es ausdruecklich fest
    nm.Add(T("menu.badge"), (*) => SetView("NumberBadge", BadgesOn() ? "off" : "on"))
    if (BadgesOn())
        nm.Check(T("menu.badge"))
    vm.Add(T("menu.numbers"), nm)
    MenuGlyph(vm, T("menu.numbers"), "E8EF")
    vm.Add(T("menu.colorcoding"), ToggleView.Bind("ColorCoding"))
    if (CONF["ColorCoding"])
        vm.Check(T("menu.colorcoding"))
    vm.Add(T("menu.dividers"), ToggleView.Bind("ShowDividers"))
    if (CONF["ShowDividers"])
        vm.Check(T("menu.dividers"))
    m.Add(T("menu.view"), vm)
    MenuGlyph(m, T("menu.view"), "E8FD")

    ; Aktiver Desktop: Hervorhebung und (dazu gehoerig) die fette Beschriftung
    am := Menu()
    for , it in [["desktop", T("menu.active.desktop")], ["accent", T("menu.active.accent")], ["soliddesk", T("menu.active.soliddesk")], ["solid", T("menu.active.solid")]] {
        am.Add(it[2], SetViewStr.Bind("ActiveStyle", it[1]))
        if (CONF["ActiveStyle"] = it[1])
            am.Check(it[2])
    }
    am.Add()
    am.Add(T("menu.shape"), (*) => 0)
    am.Disable(T("menu.shape"))
    for , it in [["tabs", T("menu.shape.tabs")], ["register", T("menu.shape.register")]] {
        am.Add(it[2], SetViewStr.Bind("TabShape", it[1]))
        if (CONF["TabShape"] = it[1])
            am.Check(it[2])
    }
    am.Add()
    am.Add(T("menu.activeshadow"), ToggleView.Bind("ActiveShadow"))
    if (CONF["ActiveShadow"])
        am.Check(T("menu.activeshadow"))
    am.Add(T("menu.activebold"), ToggleView.Bind("ActiveBold"))
    if (CONF["ActiveBold"])
        am.Check(T("menu.activebold"))
    m.Add(T("menu.active"), am)
    MenuGlyph(m, T("menu.active"), "E7C4")

    tm := Menu()
    for , it in [["auto", T("menu.theme.auto")], ["light", T("menu.theme.light")], ["dark", T("menu.theme.dark")]] {
        tm.Add(it[2], SetViewStr.Bind("ThemeMode", it[1]))
        if (CONF["ThemeMode"] = it[1])
            tm.Check(it[2])
    }
    m.Add(T("menu.theme"), tm)
    MenuGlyph(m, T("menu.theme"), "E793")

    ; Der Hauptmenue-Eintrag zeigt gleich, ob die Kuerzel an sind und welche gelten -
    ; sonst sucht man den Schalter im Untermenue und haelt die Funktion fuer kaputt.
    km := Menu()
    km.Add(T("menu.hotkeys.on"), ToggleView.Bind("Hotkeys"))
    if (CONF["Hotkeys"])
        km.Check(T("menu.hotkeys.on"))
    km.Add()
    km.Add(T("menu.hotkeys.mods"), (*) => 0)
    km.Disable(T("menu.hotkeys.mods"))
    ; Modifikatoren frei kombinieren, in der Reihenfolge der Tastatur.
    ; Ein Klick hier schaltet die Kuerzel gleich mit ein.
    for , it in [["^", T("key.ctrl")], ["+", T("key.shift")], ["!", T("key.alt")], ["#", T("key.win")]] {
        km.Add(it[2], ToggleHotkeyMod.Bind(it[1]))
        if (InStr(CONF["HotkeyMod"], it[1]))
            km.Check(it[2])
    }
    km.Add()
    modTxt := StrReplace(HotkeyLabel(CONF["HotkeyMod"]), " + 1 … 0", "")
    if (!InStr(CONF["HotkeyMod"], "+")) {
        km.Add(T("menu.hotkeys.move", HotkeyLabel(CONF["HotkeyMod"] "+")), (*) => 0)
        km.Disable(T("menu.hotkeys.move", HotkeyLabel(CONF["HotkeyMod"] "+")))
    }
    km.Add(T("menu.hotkeys.shiftclick"), (*) => 0)
    km.Disable(T("menu.hotkeys.shiftclick"))
    km.Add(T("menu.hotkeys.ctrlshiftclick"), (*) => 0)
    km.Disable(T("menu.hotkeys.ctrlshiftclick"))
    if (CanMoveDesktop()) {
        km.Add(T("menu.hotkeys.shiftdrag"), (*) => 0)
        km.Disable(T("menu.hotkeys.shiftdrag"))
    }
    km.Add(T("menu.hotkeys.back", modTxt " + " T("key.backspace")), (*) => 0)
    km.Disable(T("menu.hotkeys.back", modTxt " + " T("key.backspace")))
    km.Add()
    km.Add(T("menu.help.shortcuts"), ShowShortcuts)
    MenuGlyph(km, T("menu.help.shortcuts"), "E765")
    hkHead := T("menu.hotkeys") ": " (CONF["Hotkeys"] ? HotkeyLabel(CONF["HotkeyMod"]) : T("menu.hotkeys.off"))
    m.Add(hkHead, km)
    MenuGlyph(m, hkHead, "E961")

    lm := Menu()
    for , it in [["auto", T("menu.language.auto")], ["de", "Deutsch"], ["en", "English"]] {
        lm.Add(it[2], SetViewStr.Bind("Language", it[1]))
        if (CONF["Language"] = it[1])
            lm.Check(it[2])
    }
    m.Add(T("menu.language"), lm)
    MenuGlyph(m, T("menu.language"), "E774")

    ; Selten gebraucht: Verhalten, Zeit-Log, Reparatur
    xm := Menu()
    xm.Add(T("menu.directjump"), (*) => SetView("SwitchMethod", CONF["SwitchMethod"] = "dll" ? "native" : "dll"))
    if (CONF["SwitchMethod"] = "dll")
        xm.Check(T("menu.directjump"))
    xm.Add(T("menu.zorder"), ToggleView.Bind("RestoreZOrder"))
    if (CONF["RestoreZOrder"])
        xm.Check(T("menu.zorder"))
    xm.Add(T("menu.dragtotab"), ToggleView.Bind("DragToTab"))
    if (CONF["DragToTab"])
        xm.Check(T("menu.dragtotab"))
    xm.Add(T("menu.attention"), ToggleView.Bind("AttentionDot"))
    if (CONF["AttentionDot"])
        xm.Check(T("menu.attention"))
    xm.Add(T("menu.switchalert"), ToggleView.Bind("SwitchAlert"))
    if (CONF["SwitchAlert"])
        xm.Check(T("menu.switchalert"))
    xm.Add(T("menu.snap"), ToggleView.Bind("SnapToTaskbar"))
    if (CONF["SnapToTaskbar"])
        xm.Check(T("menu.snap"))
    xm.Add(T("menu.update.auto"), ToggleView.Bind("UpdateCheck"))
    if (CONF["UpdateCheck"])
        xm.Check(T("menu.update.auto"))
    xm.Add(T("menu.claudecode"), ToggleView.Bind("ClaudeCode"))
    if (CONF["ClaudeCode"])
        xm.Check(T("menu.claudecode"))
    lgm := Menu()
    lgm.Add(T("menu.report"), OpenTimeReport)
    MenuGlyph(lgm, T("menu.report"), "E9D2")
    lgm.Add()
    lgm.Add(T("menu.timelog.on"), ToggleView.Bind("TimeLog"))
    if (CONF["TimeLog"])
        lgm.Check(T("menu.timelog.on"))
    lgm.Add(T("menu.timelog.pause"), ToggleLogPause)
    if (GapIs("paused"))
        lgm.Check(T("menu.timelog.pause"))
    lgm.Add(T("menu.timelog.open"), OpenLogFolder)
    MenuGlyph(lgm, T("menu.timelog.open"), "E838")
    xm.Add(T("menu.timelog"), lgm)
    MenuGlyph(xm, T("menu.timelog"), "E823")
    xm.Add()
    xm.Add(T("tray.rebuild"), (*) => RebuildAll())
    MenuGlyph(xm, T("tray.rebuild"), "E72C")
    xm.Add(T("tray.resetpos"), ResetPos)
    m.Add(T("menu.more"), xm)
    MenuGlyph(m, T("menu.more"), "E713")

    m.Add()
    m.Add(T("menu.report"), OpenTimeReport)
    MenuGlyph(m, T("menu.report"), "E9D2")
    m.Add(T("menu.help"), HelpMenu())
    MenuGlyph(m, T("menu.help"), "E897")
    if (gUpdateTag != "")
        m.Add(T("menu.update.available", gUpdateTag), UpdateNotice.Bind(true))
    m.Add(T("menu.about"), ShowAbout)
    MenuGlyph(m, T("menu.about"), "E946")
    m.Add()
    m.Add(T("tray.exit"), (*) => ExitApp())
    MenuGlyph(m, T("tray.exit"), "E7E8")
}

; Ordner mit den Zeit-Log-Dateien oeffnen, die Datei des laufenden Monats markiert
OpenLogFolder(*) {
    file := LogFile(A_Now)
    try DirCreate(LogDir())
    if FileExist(file)
        Run('explorer.exe /select,"' file '"')
    else
        Run('explorer.exe "' LogDir() '"')
}

; ---- Zeit-Auswertung: data\report.html mit den Log-Zeilen fuellen und im Browser oeffnen ----
; Die Seite rechnet alles selbst (JavaScript, offline). DeskTabs liefert nur die Rohdaten:
; alle Monatsdateien unveraendert, dazu was noch nicht in der Datei steht (wartender Eintrag,
; laufender Aufenthalt, laufende Pause), die heutigen Desktops mit Farbe, Sprache und Theme.
OpenTimeReport(*) {
    global gTheme, gLangCode
    tpl := A_ScriptDir "\data\report.html"
    if !FileExist(tpl) {
        MsgBox(T("report.missing"), "DeskTabs", "Iconx")
        return
    }
    fl := ""
    Loop Files, LogDir() "\desktop-log_*.csv" {
        try fl .= (fl = "" ? "" : ",") '{"name":' JsonStr(A_LoopFileName) ',"text":' JsonStr(FileRead(A_LoopFileFullPath, "UTF-8")) '}'
    }
    dk := ""
    Loop GetDesktopCount() {
        i := A_Index - 1
        dk .= (dk = "" ? "" : ",") '{"index":' A_Index ',"id":' JsonStr(DesktopGuid(i)) ',"name":' JsonStr(GetDesktopNameRaw(i))
            . ',"color":"#' Format("{:06X}", DesktopColor(i)) '"}'
    }
    pal := ""
    for col in CONF["Palette"]
        pal .= (pal = "" ? "" : ",") '"#' Format("{:06X}", col) '"'
    lv := ""
    for r in LiveRows()
        lv .= (lv = "" ? "" : ",") r
    json := '{"lang":' JsonStr(gLangCode) ',"theme":' JsonStr(gTheme) ',"version":' JsonStr(APP_VERSION)
        . ',"generated":' JsonStr(IsoTime(A_Now)) ',"desks":[' dk '],"palette":[' pal '],"files":[' fl '],"live":[' lv ']}'
    html := StrReplace(FileRead(tpl, "UTF-8"), "/*DESKTABS_DATA*/", json, , , 1)
    dir := A_Temp "\DeskTabs-report"
    path := dir "\DeskTabs-" (gLangCode = "de" ? "Zeit-Auswertung" : "time-report") ".html"
    try {
        DirCreate(dir)
        f := FileOpen(path, "w", "UTF-8")
        f.Write(html), f.Close()
        Run('"' path '"')
    } catch as e
        MsgBox(T("report.failed", e.Message), "DeskTabs", "Iconx")
}
; Was noch nicht in der Monatsdatei steht, als Zeilen fuer die Auswertung (nicht geschrieben)
LiveRows() {
    global gSegStart, gSegDesk, gSegName, gSegSub, gSegSrc, gSegId, gSegAct, gLogCarry, gLogPend, gGap
    rows := []
    if (!CONF["TimeLog"])
        return rows
    if (IsObject(gLogPend))
        rows.Push(LiveRow(gLogPend["start"], gLogPend["end"], gLogPend["desk"] + 1, gLogPend["name"], gLogPend["sub"]
            , "active", gLogPend["id"], gLogPend["src"], gLogPend["act"]))
    if (gSegStart != "")
        rows.Push(LiveRow(gLogCarry != "" ? gLogCarry : gSegStart, A_Now, gSegDesk + 1, gSegName, gSegSub
            , "active", gSegId, gSegSrc, gSegAct))
    if (IsObject(gGap))
        rows.Push(LiveRow(gGap["start"], A_Now, "", "", "", gGap["state"], "", gGap["info"], ""))
    return rows
}
LiveRow(start, end, idx, name, sub, state, id, src, act) => '{"start":' JsonStr(IsoTime(start)) ',"end":' JsonStr(IsoTime(end))
    . ',"desktop_index":' JsonStr(String(idx)) ',"desktop_name":' JsonStr(name) ',"subproject":' JsonStr(sub)
    . ',"state":' JsonStr(state) ',"desktop_id":' JsonStr(id) ',"source":' JsonStr(src) ',"activity":' JsonStr(act) '}'
; JSON-Zeichenkette; "<" maskiert, damit Daten den <script>-Block nicht beenden koennen
JsonStr(s) {
    s := RegExReplace(String(s), "[\x00-\x08\x0B\x0C\x0E-\x1F]")     ; uebrige Steuerzeichen waeren ungueltiges JSON
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, '"', '\"')
    s := StrReplace(s, "`r", "\r")
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`t", "\t")
    s := StrReplace(s, "<", "\u003c")
    return '"' s '"'
}

; Untermenue "Hilfe": Doku, Changelog, Feedback-Wege, Update-Pruefung
HelpMenu() {
    hm := Menu()
    hm.Add(T("menu.help.shortcuts"), ShowShortcuts)
    MenuGlyph(hm, T("menu.help.shortcuts"), "E765")
    hm.Add(T("menu.help.docs"), OpenDocs)
    MenuGlyph(hm, T("menu.help.docs"), "E8F1")
    hm.Add(T("menu.help.agents"), OpenAgentsGuide)
    MenuGlyph(hm, T("menu.help.agents"), "E99A")
    hm.Add(T("menu.help.news"), (*) => ShowNews(PrevVersion(APP_VERSION)))
    MenuGlyph(hm, T("menu.help.news"), "E789")
    hm.Add(T("menu.help.changelog"), (*) => Run(APP_CHANGELOG_URL))
    hm.Add()
    hm.Add(T("menu.feedback.bug"), ReportBug)
    MenuGlyph(hm, T("menu.feedback.bug"), "E7BA")
    hm.Add(T("menu.feedback.idea"), SuggestIdea)
    MenuGlyph(hm, T("menu.feedback.idea"), "EA80")
    hm.Add(T("menu.feedback.mailbug"), MailAuthor.Bind("bug"))
    MenuGlyph(hm, T("menu.feedback.mailbug"), "E715")
    hm.Add(T("menu.feedback.mail"), MailAuthor.Bind("feedback"))
    MenuGlyph(hm, T("menu.feedback.mail"), "E715")
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
    global gMenuSwatches
    gMenuSwatches[menu.Handle "|" item] := col         ; gezeichnet wird in OdDraw
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
    IniDelLoose("Colors", GetDesktopNameRaw(num))
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
    return "ThemeMode=" CONF["ThemeMode"] ", CompactMode=" CONF["CompactMode"]
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

MailAuthor(kind := "feedback", *) {
    global APP_MAIL, APP_VERSION
    subject := T("feedback.mail.subject." kind, APP_VERSION)
    body := T("feedback.mail.body." kind) "`n`n--`nDeskTabs " APP_VERSION ", Windows " A_OSVersion "`n" EnvSummary()
    Run("mailto:" APP_MAIL "?subject=" UrlEncode(subject) "&body=" UrlEncode(body))
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
    IniSet("State", "LatestVersion", tag)          ; nach einem Neustart ohne erneute Abfrage zeigen
    if (VersionCmp(tag, APP_VERSION) > 0) {
        gUpdateTag := tag
        BuildTray()
        UpdateNotice(manual)                         ; Karte ueber der Taskleiste (nach X: heute nicht mehr)
    } else {
        gUpdateTag := ""
        if (manual)
            MsgBox(T("update.none", APP_VERSION), "DeskTabs", 0x40)
    }
}

; Beim Start (verzoegert) und dann stuendlich: bei GitHub hoechstens einmal pro Tag fragen.
; Schon heute gefragt: die gemerkte Version nehmen - so steht der Hinweis nach jedem
; Neustart wieder da, auch wenn er vorher weggeklickt wurde.
AutoUpdateTick() {
    global gUpdateTag, APP_VERSION
    SetTimer(AutoUpdateTick, 3600000)
    if (!CONF["UpdateCheck"])
        return
    if (IniRead(CONF["IniPath"], "State", "LastUpdateCheck", "") != FormatTime(, "yyyyMMdd"))
        return CheckUpdate(false)
    tag := IniRead(CONF["IniPath"], "State", "LatestVersion", "")
    if (tag != "" && VersionCmp(tag, APP_VERSION) > 0) {
        if (gUpdateTag != tag) {
            gUpdateTag := tag
            BuildTray()
        }
        UpdateNotice()
    }
}

; Anleitung fuer KI-Assistenten: im Programmordner (Installation) bzw. im Repo die Fassung
; fuer die Installation; sonst online
OpenAgentsGuide(*) {
    global APP_URL
    for , f in [A_ScriptDir "\package\AGENTS.md", A_ScriptDir "\AGENTS.md"]
        if FileExist(f) && (InStr(f, "\package\") || A_IsCompiled) {
            try Run('notepad.exe "' f '"')
            return
        }
    Run(APP_URL "/blob/main/package/AGENTS.md")
}

OpenReleasePage(*) {
    global APP_URL
    Run(APP_URL "/releases/latest")
}

; --- Uebersicht "Tastenkuerzel und Gesten" ---
; Alle Kuerzel, Klicks und Ziehgesten an einem Ort, mit den tatsaechlich eingestellten
; Zusatztasten; was gerade abgeschaltet ist, steht nicht drin (oder mit Hinweis).
ShowShortcuts(*) {
    global gShortcutsGui
    try gShortcutsGui.Destroy()
    mod := CONF["HotkeyMod"]
    modTxt := StrReplace(HotkeyLabel(mod), " + 1 … 0", "")
    S := T("key.shift"), C := T("key.ctrl")
    rows := []
    rows.Push([T("sc.sec.switch")])
    rows.Push([T("sc.k.click"), T("sc.d.click")])
    if (CONF["ClickActiveTaskView"])     ; (bei Desktops mit Unterprojekten oeffnet der Klick die Auswahl)
        rows.Push([T("sc.k.clickactive"), T("sc.d.clickactive")])
    if (CONF["WheelSwitch"])
        rows.Push([T("sc.k.wheel"), T("sc.d.wheel")])
    rows.Push([T("sc.k.middle"), T("sc.d.back")])
    rows.Push([modTxt " + 1 … 0", T("sc.d.jump"), "hk"])
    rows.Push([modTxt " + " T("key.backspace"), T("sc.d.back"), "hk"])
    rows.Push([T("sc.sec.windows")])
    rows.Push([T("sc.k.shiftclick", S), T("sc.d.send")])
    rows.Push([T("sc.k.ctrlshiftclick", C, S), T("sc.d.take")])
    if (!InStr(mod, "+"))
        rows.Push([modTxt " + " S " + 1 … 0", T("sc.d.send"), "hk"])
    if (CONF["DragToTab"]) {
        rows.Push([T("sc.k.dragwin"), T("sc.d.dragwin")])
        rows.Push([T("sc.k.dragwingrip"), T("sc.d.dragwingrip")])
    }
    rows.Push([T("sc.k.shiftgrip", S), T("sc.d.shiftgrip", S)])
    rows.Push([T("sc.k.rtab"), T("sc.d.rtabwin")])
    rows.Push([T("sc.sec.desktops")])
    if (CanMoveDesktop())
        rows.Push([T("sc.k.dragtab"), T("sc.d.dragtab")])
    rows.Push([T("sc.k.rgrip"), T("sc.d.rgrip")])
    rows.Push([T("sc.k.rtab"), T("sc.d.rtabdesk")])
    rows.Push([T("sc.k.clickactivesub"), T("sc.d.clickactivesub")])
    rows.Push([T("sc.k.altclick", T("key.alt")), T("sc.d.altclick")])
    rows.Push([T("sc.k.ctrlclick", C), T("sc.d.ctrlclick")])
    rows.Push([T("sc.k.setclick"), T("sc.d.setclick")])
    rows.Push([T("sc.k.setshift", S), T("sc.d.setshift")])
    rows.Push([T("sc.k.setctrl", C), T("sc.d.setctrl")])
    if (CONF["CallHotkey"] != "")
        rows.Push([CallHotkeyText(), T("sc.d.call")])
    rows.Push([T("sc.sec.bar")])
    rows.Push([T("sc.k.draggrip"), T("sc.d.draggrip")])
    rows.Push([T("sc.k.ctrlwheel", C), T("sc.d.ctrlwheel")])
    rows.Push([T("sc.k.hover"), T("sc.d.hover")])

    g := Gui("+AlwaysOnTop +OwnDialogs -MinimizeBox -MaximizeBox", T("sc.title"))
    g.MarginX := 22, g.MarginY := 16
    g.SetFont("s10", "Segoe UI")
    if (!CONF["Hotkeys"]) {
        g.SetFont("s9 c8A5A00")
        g.Add("Text", "x22 y+0 w640", T("sc.hkoff"))
        g.SetFont("s10 c000000")
    }
    first := true
    for row in rows {
        if (row.Length = 1) {                        ; Abschnitt
            g.SetFont("s11 bold c1F1F1F")
            g.Add("Text", "x22 " (first ? "y+4" : "y+18") " w640", row[1])
            g.SetFont("s10 norm")
            first := false
            continue
        }
        off := (row.Length = 3 && !CONF["Hotkeys"])
        g.SetFont("s10 " (off ? "c9A9A9A" : "c1F1F1F"))
        k := g.Add("Text", "x22 y+7 w320", row[1])
        g.SetFont("s10 " (off ? "c9A9A9A" : "c5C5C5C"))
        d := g.Add("Text", "x+14 yp w390", row[2])
        ; die naechste Zeile beginnt unter der hoeheren Spalte (lange Uebersetzungen brechen um)
        k.GetPos(, &ky, , &kh), d.GetPos(, &dy, , &dh)
        g.Add("Text", "x22 y" Max(ky + kh, dy + dh) " w0 h0")
    }
    g.SetFont("s10 norm c000000")
    btn := g.Add("Button", "x22 y+22 w120 Default", T("about.close"))
    btn.OnEvent("Click", (*) => g.Destroy())
    g.OnEvent("Escape", (*) => g.Destroy())
    g.OnEvent("Close", (*) => g.Destroy())
    gShortcutsGui := g
    SetGuiIcon(g)
    g.Show("AutoSize Center")
    btn.Focus()
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
    ; nur anheften, wenn noetig: erneutes Anheften liess Windows die Leiste kurz neu darstellen
    if (DllCall("VirtualDesktopAccessor\IsPinnedWindow", "Ptr", MyGui.Hwnd, "Int") != 1)
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
    global gBuilding, gNameCache
    ; Waehrend eines Aufbaus wird jeder Name rund zehnmal gebraucht; jede Abfrage geht
    ; ueber die Windows-Schnittstelle. Deshalb nur fuer die Dauer des Aufbaus merken -
    ; ausserhalb (Abgleich, Umbenennen) wird immer frisch gefragt.
    if (gBuilding && IsObject(gNameCache) && gNameCache.Has(num))
        return gNameCache[num]
    buf := Buffer(1024, 0)
    ok := VD("GetDesktopName", "Int", num, "Ptr", buf, "Int", buf.Size, "Int")
    name := (ok ? StrGet(buf, "UTF-8") : "")
    name := (name = "") ? "Desktop " (num + 1) : name
    if (gBuilding && IsObject(gNameCache))
        gNameCache[num] := name
    return name
}

; Name auf maxLen Zeichen kuerzen (mit "…")
TruncName(name, maxLen) {
    if (StrLen(name) > maxLen)
        name := SubStr(name, 1, maxLen - 1) "…"
    return name
}

; Optionales Kuerzel pro Desktop aus settings.ini [Short] (z.B.  Acme Bakery=ACME )
ShortNameFor(num) => IniLookup("Short", GetDesktopNameRaw(num))

; Anzeige-Label je nach Kompakt-Stufe (gCompact):
;   full  -> "4 · Acme Bakery"     (MaxNameLen)
;   short -> "4 · BPH"  bzw. "4 · BauPunk…"   (Kuerzel, sonst ShortNameLen)
;   icon  -> "BPH"      bzw. "4"              (Kuerzel, sonst nur die Nummer)
LabelFor(num) {
    global gCompact
    sn := ShortNameFor(num)
    if (gCompact = "big")                     ; nur Symbol; ohne Symbol bleibt das Kuerzel
        return HasTabIcon(num) ? "" : ((sn != "") ? sn : String(num + 1))
    if (gCompact = "bigtext")                 ; grosses Symbol und Name daneben
        return (CONF["ShowIndex"] ? (num + 1) " · " : "") TruncName(GetDesktopNameRaw(num), CONF["MaxNameLen"])
    if (gCompact = "icon")
        return (sn != "") ? sn : String(num + 1)
    if (gCompact = "short")
        name := (sn != "") ? sn : TruncName(GetDesktopNameRaw(num), CONF["ShortNameLen"])
    else
        name := TruncName(GetDesktopNameRaw(num), CONF["MaxNameLen"])
    return (CONF["ShowIndex"] ? (num + 1) " · " : "") name
}

; Desktop kompakt anzeigen (Tab-Menue, settings.ini [Compact] Desktopname=1): fuer
; ruhende Projekte, die offen bleiben, aber wenig Platz brauchen sollen
IsCompactDesk(num) => (IniLookup("Compact", GetDesktopNameRaw(num)) = "1")
; ------------- Desktops anlegen, umbenennen, entfernen (wie die Taskansicht) -------------
; Einstellungen haengen lesbar am Desktop-Namen. Damit sie ein Umbenennen ueberleben -
; auch eins in der Windows-Taskansicht -, merkt sich [Ids] je Desktop-GUID den zuletzt
; gesehenen Namen. Aendert sich der, ziehen Farbe, Symbol, Kuerzel und Kompakt mit um.
DesktopGuid(num) {
    g := Buffer(16, 0)
    try DllCall("VirtualDesktopAccessor\GetDesktopIdByNumber", "Ptr", g, "Int", num, "Ptr")   ; GUID per verstecktem Rueckgabezeiger
    catch
        return ""
    s := Buffer(80, 0)
    DllCall("ole32\StringFromGUID2", "Ptr", g, "Ptr", s, "Int", 40)
    id := StrGet(s, "UTF-16")
    return (id = "{00000000-0000-0000-0000-000000000000}") ? "" : id
}
; Einstellungen eines Desktops auf einen neuen Namen umziehen; was der neue Name schon hat, bleibt
MoveDesktopSettings(oldName, newName) {
    if (oldName = "" || newName = "" || NormName(oldName) = NormName(newName))
        return
    for , sec in ["Colors", "Icons", "Short", "Compact", "Subprojects", "Subproject", "TimerNotes", "WindowSets", "ClaudeTags"] {
        v := IniLookup(sec, oldName)
        if (v = "" || IniLookup(sec, newName) != "")
            continue
        IniSet(sec, newName, v)
        IniDelLoose(sec, oldName)
    }
}
; Feste laufende Nummer eines Desktops: seine Stelle in [Ids] (Reihenfolge, in der DeskTabs
; die Desktops kennengelernt hat). Palette und Vorschlags-Symbole haengen daran, damit ein
; Desktop beim Umsortieren seine Farbe behaelt. Ohne Eintrag: die Position.
DeskOrdinal(num) {
    global gOrdCache
    if (gOrdCache.Has(num))
        return gOrdCache[num]
    ord := num, id := DesktopGuid(num)
    if (id != "") {
        for i, gid in IdsInFileOrder() {
            if (gid = id) {
                ord := i - 1
                break
            }
        }
    }
    gOrdCache[num] := ord
    return ord
}
; Schluessel von [Ids] in der Reihenfolge der Datei (eine Map wuerde sie sortieren)
IdsInFileOrder() {
    out := [], inSec := false
    Loop Parse, ReadIniText(), "`n", "`r" {
        line := Trim(A_LoopField)
        if (SubStr(line, 1, 1) = "[") {
            inSec := (Trim(line, "[]") = "Ids")
            continue
        }
        if (inSec && (eq := InStr(line, "=")) > 1)
            out.Push(Trim(SubStr(line, 1, eq - 1)))
    }
    return out
}
SyncDesktopIds() {
    global gOrdCache
    gOrdCache := Map()
    ids := ReadIniSection("Ids")
    Loop GetDesktopCount() {
        num := A_Index - 1
        id := DesktopGuid(num)
        if (id = "")
            continue
        name := GetDesktopNameRaw(num)
        old := ids.Has(id) ? ids[id] : ""
        if (old == name)
            continue
        ; Windows-Ersatzname ("Desktop 3") ist kein echter Name: aendert er sich, wurde nur umsortiert
        if (old != "" && name != "Desktop " (num + 1))
            MoveDesktopSettings(old, name)
        IniSet("Ids", id, name)
    }
}
SetDesktopNameUtf8(num, name) {
    buf := Buffer(StrPut(name, "UTF-8"))
    StrPut(name, buf, "UTF-8")
    return VD("SetDesktopName", "Int", num, "Ptr", buf, "Int")
}
; Hamburger-Menue: neuen Desktop anlegen, gleich benennen und hinwechseln (wie Strg+Win+D)
NewDesktop(*) {
    ib := InputBox(T("prompt.newdesk.text"), T("prompt.newdesk.title"), "w380 h130")
    if (ib.Result != "OK")
        return
    name := Trim(ib.Value)
    idx := VD("CreateDesktop", "Int")
    if (idx < 0)
        return
    if (name != "")
        SetDesktopNameUtf8(idx, name)
    SyncDesktopIds()
    RebuildAll()
    SwitchToDesktop(idx)
}
; Tab-Menue: umbenennen, Einstellungen ziehen mit
PromptRename(num, *) {
    old := GetDesktopNameRaw(num)
    ib := InputBox(T("prompt.rename.text"), T("prompt.rename.title", old), "w380 h130", old)
    if (ib.Result != "OK")
        return
    neu := Trim(ib.Value)
    if (neu = "" || neu == old)
        return
    SetDesktopNameUtf8(num, neu)
    MoveDesktopSettings(old, neu)          ; auch wenn der alte Name nur der Ersatzname war
    SyncDesktopIds()
    RebuildAll()
}
; Tab-Menue: Desktop entfernen. Windows schliesst dabei keine Fenster, sondern schiebt sie
; auf den Nachbarn - deshalb vorher klar sagen, wie viele wohin wandern. Die Einstellungen
; bleiben in der settings.ini: ein neuer Desktop gleichen Namens bekommt sie zurueck.
RemoveDesktopAsk(num, *) {
    cnt := GetDesktopCount()
    if (cnt < 2 || num < 0 || num >= cnt)
        return
    fb := (num > 0) ? num - 1 : 1
    name := GetDesktopNameRaw(num), fbName := GetDesktopNameRaw(fb)
    wins := WindowsOnDesktop(num).Length
    txt := wins ? T("ask.remove.windows", name, wins, fbName) : T("ask.remove.empty", name)
    if (MsgBox(txt, "DeskTabs", 0x34 | 0x100 | 0x40000) != "Yes")   ; Ja/Nein, "Nein" vorgewaehlt, im Vordergrund
        return
    VD("RemoveDesktop", "Int", num, "Int", fb, "Int")
    RebuildAll()
}

; Woraus ein Tab gebaut wurde; aendert sich das, muss die Leiste neu vermessen werden
; ---------------- Unterprojekte (Sammel-Desktops) ----------------
; Ein Desktop fuer mehrere kleine Projekte ("Webprojekte") bekommt eine Liste von
; Unterprojekten; eins davon (oder keins) ist aktiv. Es steht klein unter dem Namen im
; Tab und als eigene Spalte im Zeit-Log; ein Wechsel beginnt dort eine neue Zeile.
; settings.ini: [Subprojects] Desktopname=A|B|C  und  [Subproject] Desktopname=A
SubList(num) {
    out := []
    for , s in StrSplit(IniLookup("Subprojects", GetDesktopNameRaw(num)), "|")
        if ((s := Trim(s)) != "")
            out.Push(s)
    return out
}
SubActive(num) {
    a := IniLookup("Subproject", GetDesktopNameRaw(num))
    for , s in SubList(num)
        if (s = a)
            return s
    return ""
}
SetSub(num, val, *) {
    global gCurrent, gSegDesk
    raw := GetDesktopNameRaw(num)
    if (val = "")
        IniDelLoose("Subproject", raw)
    else
        IniSet("Subproject", raw, val)
    global gLogPaused
    if (num = gCurrent && num = gSegDesk && CONF["TimeLog"] && !gLogPaused) {   ; Zeit-Log: neue Zeile ab jetzt
        LogClose("", false)
        LogOpen(num, "subproject")
    }
    RebuildAll()
}
AddSub(num, *) {
    raw := GetDesktopNameRaw(num)
    ib := InputBox(T("prompt.sub.text"), T("prompt.sub.title", raw), "w380 h130")
    if (ib.Result != "OK" || (v := Trim(StrReplace(ib.Value, "|", "/"))) = "")
        return
    list := SubList(num)
    for , s in list
        if (s = v)
            return SetSub(num, s)
    list.Push(v)
    IniSet("Subprojects", raw, JoinList(list))
    SetSub(num, v)
}
RemoveSub(num, val, *) {
    raw := GetDesktopNameRaw(num)
    list := []
    for , s in SubList(num)
        if (s != val)
            list.Push(s)
    if (list.Length)
        IniSet("Subprojects", raw, JoinList(list))
    else
        IniDelLoose("Subprojects", raw)
    if (SubActive(num) = "" || IniLookup("Subproject", raw) = val)
        SetSub(num, "")
    else
        RebuildAll()
}
JoinList(list) {
    s := ""
    for , v in list
        s .= (s = "" ? "" : "|") v
    return s
}
; Untermenue "Unterprojekt" (Tab-Menue und Alt+Klick)
; full = false: schlanke Auswahl (Klick auf den aktiven Tab) - nur keins und die Liste,
; ohne Anlegen und Entfernen
SubMenu(num, full := true) {
    sm := Menu()
    cur := SubActive(num)
    sm.Add(T("menu.sub.none"), SetSub.Bind(num, ""))
    if (cur = "")
        sm.Check(T("menu.sub.none"))
    list := SubList(num)
    if (list.Length)
        sm.Add()
    for , s in list {
        sm.Add(s, SetSub.Bind(num, s))
        if (s = cur)
            sm.Check(s)
    }
    if (!full)
        return sm
    sm.Add()
    sm.Add(T("menu.sub.add"), AddSub.Bind(num))
    MenuGlyph(sm, T("menu.sub.add"), "E710")
    if (list.Length) {
        rm := Menu()
        for , s in list
            rm.Add(s, RemoveSub.Bind(num, s))
        sm.Add(T("menu.sub.remove"), rm)
    }
    return sm
}
; Alt+Klick auf einen Tab: Unterprojekt direkt waehlen
; Das Menue erscheint sofort beim Klick. Ein Loslassen von Alt wuerde ein offenes Menue
; aber schliessen (Windows wertet Alt als "Menue verlassen"). Deshalb gilt Alt fuer das
; System schon jetzt als losgelassen, und die echte Alt-Taste wird abgefangen, bis sie
; physisch losgelassen ist - so bleibt das Menue offen, bis etwas gewaehlt ist.
ShowSubMenu(num, full := true, *) {
    ToolTip(, , , 4)
    if (GetKeyState("Alt", "P")) {
        AltSwallow(true)
        Send("{Blind}{vkE8}{LAlt up}{RAlt up}")       ; vkE8: kein Menueleisten-Effekt im Vordergrund-Programm
        SetTimer(AltReleaseWatch, 50)
    }
    sm := SubMenu(num, full)
    OwnerDrawAll(sm.Handle)
    sm.Show()
}
AltSwallow(on) {
    static noop := (*) => 0
    for , k in ["*LAlt", "*RAlt", "*LAlt Up", "*RAlt Up"]
        try Hotkey(k, noop, on ? "On" : "Off")
}
AltReleaseWatch() {
    if (GetKeyState("Alt", "P"))
        return
    SetTimer(AltReleaseWatch, 0)
    AltSwallow(false)
}

; ------------- Unterprojekt-Auswahl am aktiven Tab ---------------------------
; Klick auf den aktiven Tab eines Desktops mit Unterprojekten: Ueber dem Tab gleitet eine
; Flaeche im Grau der Leiste heraus, als wuechse die Leiste dort nach oben (in der
; Desktop-Farbe waere sie bei grellen Farben zu laut und schlecht lesbar). Die Farbe
; markiert nur das aktive Unterprojekt. Nur Auswahl, kein Anlegen/Entfernen (das bleibt
; bei Alt + Klick). Schliesst bei Auswahl, Klick daneben, Esc oder Desktop-Wechsel.
; Eigenes Schichtfenster (UpdateLayeredWindow): runde Ecken mit Kantenglaettung.
SubPanelOpen(num, *) {
    global gSP, MyGui, BTNS, gLayout
    if (gSP || !MyGui || !gLayout)
        return
    item := 0
    for it in BTNS
        if (it["num"] = num)
            item := it
    list := SubList(num)
    if (!item || !list.Length)
        return
    ToolTip(, , , 4)
    col := (CONF["ActiveStyle"] = "accent" || CONF["ActiveStyle"] = "solid") ? CONF["ColActiveBg"] : DesktopColor(num)
    fill := CONF["ColBarBg"], tx := CONF["ColInactiveTx"]
    darkFill := (ReadableOn(fill) = 0xFFFFFF)
    ; Zeilen: die Unterprojekte, darunter (am Tab) "ohne Unterprojekt"
    vals := []
    for , s in list
        vals.Push(s)
    vals.Push("")
    cur := SubActive(num)
    rowH := px(30), padY := px(6), padX := px(14), divH := px(9)
    GdipStart()
    mBmp := 0, mG := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", 1, "Int", 1, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &mBmp)
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", mBmp, "Ptr*", &mG)
    fB := MakeFont(true), sf := MakeFormat()
    tw := 0
    for , v in vals
        tw := Max(tw, MeasureText(mG, fB, sf, (v = "") ? T("sub.panel.none") : v))
    DllCall("gdiplus\GdipDeleteFont", "Ptr", fB), DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", mG), DllCall("gdiplus\GdipDisposeImage", "Ptr", mBmp)
    w := Max(item["w"], tw + 2 * padX + px(8))
    rows := [], y := padY
    for i, v in vals {
        if (v = "")
            y += divH                              ; Trennlinie vor "ohne Unterprojekt"
        rows.Push(Map("y", y, "val", v))
        y += rowH
    }
    h := y + padY
    bx := 0, by := 0
    WinGetPos(&bx, &by, , , MyGui.Hwnd)
    left := bx + item["x"]
    bottom := by                                    ; Oberkante der Leiste
    if (left + w > A_ScreenWidth)
        left := Max(0, A_ScreenWidth - w)
    pg := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08080000 -DPIScale")   ; NOACTIVATE | LAYERED
    pg.Show(Format("NA x{1} y{2} w1 h1", left, bottom - 1))
    gSP := Map("num", num, "gui", pg, "x", left, "bottom", bottom, "w", w, "h", h, "tabW", item["w"]
        , "rows", rows, "rowH", rowH, "padX", padX, "cur", cur, "fill", fill, "tx", tx, "dark", darkFill, "col", col
        , "hover", -1, "dc", 0, "hbm", 0, "obm", 0, "shown", 0)
    SubPanelPaint()
    ; herausgleiten: das Fenster waechst nach oben, der Inhalt schiebt sich aus dem Tab
    Loop 8 {
        if (!gSP)
            return
        f8 := A_Index / 8                           ; (nicht "t": AHK-Namen sind case-insensitiv, T() ist die Uebersetzung)
        SubPanelShow(Max(1, Round(h * (1 - (1 - f8) ** 3))))
        Sleep(12)
    }
    SetTimer(SubPanelTick, 30)
    try Hotkey("Esc", SubPanelClose, "On")
}

; Inhalt neu zeichnen (einmal beim Oeffnen, dann bei Hover-Wechsel)
SubPanelPaint() {
    global gSP
    sp := gSP, w := sp["w"], h := sp["h"]
    if (!sp["dc"]) {
        bi := Buffer(40, 0)
        NumPut("UInt", 40, bi, 0), NumPut("Int", w, bi, 4), NumPut("Int", -h, bi, 8)
        NumPut("UShort", 1, bi, 12), NumPut("UShort", 32, bi, 14)
        sp["dc"] := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
        bits := 0
        sp["hbm"] := DllCall("CreateDIBSection", "Ptr", sp["dc"], "Ptr", bi, "UInt", 0, "Ptr*", &bits, "Ptr", 0, "UInt", 0, "Ptr")
        sp["obm"] := DllCall("SelectObject", "Ptr", sp["dc"], "Ptr", sp["hbm"], "Ptr")
    }
    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", sp["dc"], "Ptr*", &g)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 4)   ; AntiAliasGridFit (Fenster mit Alphakanal)
    DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", g, "Int", 2)
    DllCall("gdiplus\GdipGraphicsClear", "Ptr", g, "UInt", 0)
    r := px(CONF["CornerRadius"]), d := r * 2
    ; Form: oben rund, unten eckig (sitzt auf der Leiste)
    path := 0
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", 0, "Float", 0, "Float", d, "Float", d, "Float", 180, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", w - d, "Float", 0, "Float", d, "Float", d, "Float", 270, "Float", 90)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", w, "Float", r, "Float", w, "Float", h)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", w, "Float", h, "Float", 0, "Float", h)
    DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
    brush := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB(sp["fill"]), "Ptr*", &brush)
    DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", brush, "Ptr", path)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush), DllCall("gdiplus\GdipDeletePath", "Ptr", path)
    ; Zeilen
    font := MakeFont(), fontB := MakeFont(true), sf := MakeFormat()
    DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", sf, "Int", 0)     ; linksbuendig
    hov := Mix(CONF["ColHoverBg"], sp["fill"], CONF["HoverPct"])   ; wie der Hover der Tabs
    ix := px(5), iw := w - 2 * ix, rowH := sp["rowH"]
    for i, row in sp["rows"] {
        y := row["y"], v := row["val"]
        if (v = "") {                              ; Trennlinie
            FillRoundRect(g, sp["padX"], y - px(5), w - 2 * sp["padX"], Max(1, px(1)), 0, 0x30000000 | (sp["tx"] & 0xFFFFFF))
        }
        act := (v == sp["cur"])
        if (act || i - 1 = sp["hover"])
            FillRoundRect(g, ix, y + px(1), iw, rowH - px(2), px(5), ARGB(hov))
        if (act)                                   ; Markierung in der Desktop-Farbe, wie in Windows-Listen
            FillRoundRect(g, ix + px(2), y + rowH // 2 - px(7), px(3), px(14), px(1.5), ARGB(sp["col"]))
        txt := (v = "") ? T("sub.panel.none") : v
        a := (v = "" && !act) ? 0xA0000000 : 0xFF000000
        DrawText(g, act ? fontB : font, sf, txt, sp["padX"], y, w - 2 * sp["padX"], rowH, a | (sp["tx"] & 0xFFFFFF))
    }
    DllCall("gdiplus\GdipDeleteFont", "Ptr", font), DllCall("gdiplus\GdipDeleteFont", "Ptr", fontB)
    DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    if (sp["shown"])
        SubPanelShow(sp["shown"])
}

; die oberen hh Pixel des Bildes zeigen, Unterkante an der Oberkante des Tabs
SubPanelShow(hh) {
    global gSP
    sp := gSP
    sp["shown"] := hh
    pt := Buffer(8, 0), sz := Buffer(8, 0), src := Buffer(8, 0)
    NumPut("Int", sp["x"], "Int", sp["bottom"] - hh, pt)
    NumPut("Int", sp["w"], "Int", hh, sz)
    DllCall("UpdateLayeredWindow", "Ptr", sp["gui"].Hwnd, "Ptr", 0, "Ptr", pt, "Ptr", sz, "Ptr", sp["dc"]
        , "Ptr", src, "UInt", 0, "UInt*", 0x01FF0000, "UInt", 2)   ; AC_SRC_ALPHA, ULW_ALPHA
}

SubPanelRowAt(&mx := 0, &my := 0) {
    global gSP
    sp := gSP
    pt := Buffer(8, 0)
    DllCall("GetCursorPos", "Ptr", pt)
    mx := NumGet(pt, 0, "Int"), my := NumGet(pt, 4, "Int")
    top := sp["bottom"] - sp["h"]
    if (mx < sp["x"] || mx >= sp["x"] + sp["w"] || my < top || my >= sp["bottom"])
        return -2                                   ; ausserhalb
    ly := my - top
    for i, row in sp["rows"]
        if (ly >= row["y"] && ly < row["y"] + sp["rowH"])
            return i - 1
    return -1
}

SubPanelTick() {
    global gSP, gSPClosed
    if (!gSP)
        return SetTimer(SubPanelTick, 0)
    i := SubPanelRowAt()
    if (GetCurrentDesktop() != gSP["num"])
        return SubPanelClose()
    if ((GetKeyState("LButton", "P") || GetKeyState("RButton", "P")) && i = -2)
        return SubPanelClose()                      ; Klick daneben
    hv := Max(i, -1)
    if (hv != gSP["hover"]) {
        gSP["hover"] := hv
        SubPanelPaint()
    }
}

; Klick in die Auswahl (WM_LBUTTONUP, eigene Kette neben OnLButtonUp)
SubPanelUp(wParam, lParam, msg, hwnd) {
    global gSP
    if (!gSP || hwnd != gSP["gui"].Hwnd)
        return
    i := SubPanelRowAt()
    if (i < 0)
        return 0
    num := gSP["num"], v := gSP["rows"][i + 1]["val"]
    SubPanelClose()
    if (v !== SubActive(num))
        SetSub(num, v)
    return 0
}

SubPanelClose(*) {
    global gSP, gSPClosed
    if (!gSP)
        return
    sp := gSP, gSP := 0, gSPClosed := A_TickCount
    SetTimer(SubPanelTick, 0)
    try Hotkey("Esc", "Off")
    try sp["gui"].Destroy()
    if (sp["dc"]) {
        DllCall("SelectObject", "Ptr", sp["dc"], "Ptr", sp["obm"])
        DllCall("DeleteObject", "Ptr", sp["hbm"])
        DllCall("DeleteDC", "Ptr", sp["dc"])
    }
    RenderBar(true)                                 ; Tab wieder rund
}
TabSource(num) => LabelFor(num) "|" IsCompactDesk(num) "|" SubActive(num)
ToggleCompact(num, *) {
    if (IsCompactDesk(num))
        IniDelLoose("Compact", GetDesktopNameRaw(num))
    else
        IniSet("Compact", GetDesktopNameRaw(num), 1)
    RebuildAll()
}

; Hat dieser Desktop ein Symbol (und sind Symbole eingeschaltet)?
HasTabIcon(num) => (CONF["ShowIcons"] && IconPathFor(num) != "")

; Naechstkleinere / naechstgroessere Stufe ("" = keine)
; Reihenfolge von breit nach schmal; "big"/"bigtext" sind feste Wuensche und
; werden vom Auto-Modus nicht angesteuert, im Strg+Mausrad-Durchlauf aber schon.
LevelChain() => ["bigtext", "full", "short", "icon", "big"]
SmallerLevel(lv) {
    ch := LevelChain()
    for i, v in ch
        if (v = lv)
            return (i < ch.Length) ? ch[i + 1] : ""
    return ""
}
LargerLevel(lv) {
    ch := LevelChain()
    for i, v in ch
        if (v = lv)
            return (i > 1) ? ch[i - 1] : ""
    return ""
}
; Der Auto-Modus schaltet nur zwischen den Textstufen herunter
AutoSmaller(lv) => (lv = "bigtext") ? "full" : (lv = "full") ? "short" : (lv = "short") ? "icon" : ""

; Farbe fuer den Akzentbalken eines Desktops. Palette nach Index, optional per
; settings.ini [Colors] mit Desktop-Name ueberschreibbar (z.B.  Miller & Sons=E5471D )
DesktopColor(num) {
    raw := GetDesktopNameRaw(num)
    ov := IniLookup("Colors", raw)
    if (ov != "")
        return Integer("0x" StrReplace(ov, "0x", ""))
    pal := CONF["Palette"]
    return pal[Mod(DeskOrdinal(num), pal.Length) + 1]     ; am Desktop, nicht an der Position
}

px(v) => Round(v * SCALE)     ; logische px -> physische px

; --------------------------- Leiste aufbauen --------------------------------
; Waehlt die Kompakt-Stufe und baut die Leiste. Bei CompactMode=auto wird mit
; "full" begonnen und so lange eine Stufe runtergeschaltet, bis die Leiste
; ins Breiten-Budget (MaxBarWidthPct der Taskleistenbreite) passt.
; Innenabstand der Tabs: grosszuegig (PadXMax), solange Platz ist; wird die Leiste
; zu breit, schrumpft er in Schritten bis PadX - erst danach eine Stufe kleiner.
BuildBar() {
    global gBuilding, gCompact, GUIW, gTaskbarW, gPadX
    if (gBuilding)              ; verschachtelten Neuaufbau verhindern (Geometrie-Race)
        return
    global gSP
    if (gSP)
        SubPanelClose()
    gBuilding := true
    crit := A_IsCritical            ; Aufbau nicht unterbrechen lassen (siehe RenderBar)
    Critical
    global gNameCache := Map()       ; Desktop-Namen fuer die Dauer des Aufbaus merken
    mode := CONF["CompactMode"]
    level := (mode = "auto") ? "bigtext" : mode   ; grosszuegig anfangen, dann bei Platzmangel herunter
    pads := []
    p := Max(CONF["PadXMax"], CONF["PadX"])
    while (p > CONF["PadX"])
        pads.Push(p), p -= 3
    pads.Push(CONF["PadX"])
    Loop {
        gCompact := level
        for i, pad in pads {
            gPadX := pad
            BuildBarAt()
            if (!gTaskbarW || i = pads.Length || GUIW <= gTaskbarW * CONF["MaxBarWidthPct"] / 100)
                break
        }
        if (mode != "auto" || !gTaskbarW)
            break
        budget := gTaskbarW * CONF["MaxBarWidthPct"] / 100
        next := AutoSmaller(level)
        if (GUIW <= budget || next = "")
            break
        level := next               ; zu breit -> eine Stufe kleiner, nochmal bauen
    }
    global gBarReused, gBarPos, MyGui
    if (gBarReused) {               ; vorhandenes Fenster: erst das neue Bild fertig zeichnen,
        RenderBar(2)                ; dann in einem Schritt auf die neue Groesse - sonst fuellte
        DllCall("SetWindowPos", "Ptr", MyGui.Hwnd, "Ptr", 0, "Int", gBarPos[1], "Int", gBarPos[2]   ; Windows die neue Flaeche
            , "Int", GUIW, "Int", GUIH, "UInt", 0x0114)                                            ; kurz mit dem alten (Zucken)
        BarBlit()                                                                                  ; NOZORDER|NOACTIVATE|NOCOPYBITS
    }
    gNameCache := 0
    gBuilding := false
    Critical(crit)
}

BuildBarAt() {
    global MyGui, BTNS, GUIW, GUIH, gTaskbarW, gLayout, gOrdCache
    global gBarReused, gBarPos
    gOrdCache := Map()
    ; Das vorhandene Fenster wird weiterverwendet: nur neu vermessen, verschieben und
    ; zeichnen. Frueher wurde es zerstoert und neu angelegt - die Leiste verschwand dabei
    ; jedes Mal kurz (Unterprojekt wechseln, Kompakt, Ansicht, Umbenennen).
    gBarReused := MyGui ? true : false
    if (gBarReused)
        try DllCall("VirtualDesktopAccessor\UnregisterPostMessageHook", "Ptr", MyGui.Hwnd)
    BTNS := []

    if (!gBarReused) {
        ; NOACTIVATE (0x08000000): Klicks klauen nicht den Fokus vom Arbeitsfenster
        MyGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000 -DPIScale")
        MyGui.SetFont("s" CONF["FontSizePt"] " c" Fmt(CONF["ColInactiveTx"]), CONF["FontName"])
    }
    if (!gBarReused || MyGui.BackColor != Format("{:06X}", CONF["ColBarBg"]))
        MyGui.BackColor := CONF["ColBarBg"]      ; Setzen loest ein Neuzeichnen aus: nur bei echter Aenderung

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
    global gPrevCount := cnt

    ; Layout: Breiten der Tabs per GDI+ messen (die Leiste wird komplett gezeichnet,
    ; siehe RenderBar), Positionen in BTNS merken
    GdipStart()
    mBmp := 0, mG := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", 1, "Int", 1, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &mBmp)
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", mBmp, "Ptr*", &mG)
    font := MakeFont(), sf := MakeFormat(), fontSub := MakeFont(false, CONF["FontSizePt"] - 2)
    gap := px(CONF["Gap"])
    x := px(CONF["GripW"]) + gap
    iconSize := px(CONF["IconSize"]), iconGap := px(CONF["IconGap"])
    bigSize := Min(px(CONF["IconOnlySize"]), btnH - px(8))
    Loop cnt {
        num := A_Index - 1
        label := LabelFor(num)
        icon := CONF["ShowIcons"] ? IconPathFor(num) : ""
        big := (icon != "" && (gCompact = "big" || gCompact = "bigtext"))   ; Symbol in Taskleisten-Groesse
        if (icon != "" && gCompact = "icon")
            label := ""                          ; kleinste Stufe: nur das Symbol, klein
        if (IsCompactDesk(num))                  ; ruhendes Projekt: nur Symbol, sonst Kuerzel/Nummer
            label := (icon != "") ? "" : ((ShortNameFor(num) != "") ? ShortNameFor(num) : String(num + 1))
        iw := (icon != "") ? (big ? bigSize : iconSize) : 0
        tw := (label != "") ? MeasureText(mG, font, sf, label) : 0
        sub := (label != "") ? SubActive(num) : ""              ; nur in Stufen mit Text (Symbol-Tabs: Kurzinfo)
        if (sub != "")
            tw := Max(tw, MeasureText(mG, fontSub, sf, sub))
        w := px(gPadX) * 2 + iw + tw + ((iw && tw) ? iconGap : 0)
        if (iw && label = "")
            w := Max(btnH, iw + px(12) * 2)       ; quadratische Kachel wie die Taskleisten-Buttons
        badge := BadgeText(num, icon, label)
        if (badge != "" && iw && label != "")
            w += px(5)                            ; das Abzeichen ragt links uebers Symbol: dort etwas mehr Luft
        BTNS.Push(Map("num", num, "label", label, "icon", icon, "iw", iw, "x", x, "w", w, "hover", false, "badge", badge
            , "src", TabSource(num), "sub", sub))
        x += w
        if (A_Index < cnt)
            x += gap
    }
    DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
    DllCall("gdiplus\GdipDeleteFont", "Ptr", fontSub)
    DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", mG)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", mBmp)
    global gSetCount := Map(), gSetNames := Map()
    setX := 0, setW := 0, setN := 0
    if (SetsAny()) {                           ; Fensteranordnungen: ein Symbol je Anordnung rechts neben den Tabs
        Loop cnt {
            names := []
            for s in SetsLoad(GetDesktopNameRaw(A_Index - 1))
                names.Push(s["name"])
            gSetNames[A_Index - 1] := names, gSetCount[A_Index - 1] := names.Length
            setN := Max(setN, names.Length)
        }
        setN := Max(setN, 1)
        x += gap * 2, setX := x, setW := setN * btnH, x += setW
    }
    x += gap                                   ; etwas Luft am rechten Rand

    GUIW := x
    GUIH := tbH
    gLayout := Map("margin", margin, "btnH", btnH, "gripW", px(CONF["GripW"]), "gap", gap
        , "radius", px(CONF["CornerRadius"]), "accH", px(CONF["AccentBarH"])
        , "iconSize", iconSize, "iconGap", iconGap, "setX", setX, "setW", setW, "setN", setN)

    ; Position: aus settings.ini, sonst Standard = unten links auf der Taskleiste.
    defX := tbX + px(CONF["OffsetX"])
    defY := tbY
    posX := IniGet("Position", "X", defX)
    posY := IniGet("Position", "Y", defY)
    posX := ClampX(posX), posY := ClampY(posY, GUIH)
    ; Startposition vertikal auf die Taskleiste einrasten (wie beim Ziehen)
    if (CONF["SnapToTaskbar"]) {
        snapY := tbY + (tbH - GUIH) // 2
        if (((posY < tbY + tbH) && (posY + GUIH > tbY)) || (Abs(posY - snapY) <= px(CONF["SnapDistance"])))
            posY := snapY
    }

    ; Eigenes Zeichnen: WM_PAINT blittet das Pufferbild, WM_ERASEBKGND wird
    ; unterdrueckt -> kein Flackern bei Hover/Refresh
    OnMessage(0x000F, OnPaint)        ; WM_PAINT
    OnMessage(0x0014, OnEraseBkgnd)   ; WM_ERASEBKGND
    gBarPos := [posX, posY]
    if (!gBarReused) {
        RenderBar(2)
        MyGui.Show(Format("x{1} y{2} w{3} h{4} NoActivate", posX, posY, GUIW, GUIH))
    }                                  ; sonst: BuildBar verschiebt und zeichnet einmal am Ende
    UpdateStripe()

    ; Maus: Ziehen am Griff (LBUTTONDOWN), Tab-Klick (LBUTTONUP)
    OnMessage(0x0201, OnLButtonDown)  ; WM_LBUTTONDOWN
    OnMessage(0x0202, OnLButtonUp)    ; WM_LBUTTONUP
    OnMessage(0x0202, SubPanelUp)     ; ... und in der Unterprojekt-Auswahl
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

; Kennwerte eines Bild-Symbols (einmal gemessen, dann gemerkt): mittlere Farbe der
; sichtbaren Pixel und Anteil durchsichtiger Flaeche. Dient der Entscheidung, ob das
; Symbol auf einer kraeftigen Fuellung noch zu erkennen ist.
IconStats(path) {
    static cache := Map()
    if (cache.Has(path))
        return cache[path]
    res := Map("mean", -1, "transp", 0)
    cache[path] := res
    GdipStart()
    img := 0
    if (DllCall("gdiplus\GdipCreateBitmapFromFile", "WStr", path, "Ptr*", &img) != 0 || !img)
        return res
    w := 0, h := 0
    DllCall("gdiplus\GdipGetImageWidth", "Ptr", img, "UInt*", &w)
    DllCall("gdiplus\GdipGetImageHeight", "Ptr", img, "UInt*", &h)
    rect := Buffer(16, 0)
    NumPut("Int", 0, "Int", 0, "Int", w, "Int", h, rect)
    bd := Buffer(32, 0)
    if (!w || !h || DllCall("gdiplus\GdipBitmapLockBits", "Ptr", img, "Ptr", rect, "UInt", 1, "Int", 0x26200A, "Ptr", bd) != 0) {
        DllCall("gdiplus\GdipDisposeImage", "Ptr", img)
        return res
    }
    stride := NumGet(bd, 8, "Int"), scan := NumGet(bd, 16, "Ptr")
    step := Max(1, w // 48)
    n := 0, clear := 0, sr := 0, sg := 0, sb := 0, sw := 0
    y := 0
    while (y < h) {
        x := 0
        while (x < w) {
            p := NumGet(scan + y * stride + x * 4, "UInt")
            a := (p >> 24) & 0xFF
            n += 1
            if (a < 60)
                clear += 1
            else {
                wt := a / 255
                sr += ((p >> 16) & 0xFF) * wt, sg += ((p >> 8) & 0xFF) * wt, sb += (p & 0xFF) * wt, sw += wt
            }
            x += step
        }
        y += step
    }
    DllCall("gdiplus\GdipBitmapUnlockBits", "Ptr", img, "Ptr", bd)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", img)
    if (sw > 0)
        res["mean"] := (Round(sr / sw) << 16) | (Round(sg / sw) << 8) | Round(sb / sw)
    res["transp"] := n ? clear / n : 0
    return res
}

; Kontrastverhaeltnis zweier Farben nach WCAG (1 = gleich, 21 = schwarz/weiss)
ContrastRatio(c1, c2) {
    l1 := RelLum(c1), l2 := RelLum(c2)
    return (Max(l1, l2) + 0.05) / (Min(l1, l2) + 0.05)
}
RelLum(c) {
    ch(v) {
        v := v / 255
        return (v <= 0.03928) ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4
    }
    return 0.2126 * ch(c >> 16 & 0xFF) + 0.7152 * ch(c >> 8 & 0xFF) + 0.0722 * ch(c & 0xFF)
}

; Bild als einfarbige Silhouette zeichnen: jede sichtbare Stelle in rgb, die
; Durchsichtigkeit bleibt (Farbmatrix: RGB fest, Alpha unveraendert).
; rgb = -1: stattdessen Graustufen hell/dunkel umgekehrt (dunkle Kachel wird hell).
DrawImageTinted(g, img, x, y, size, rgb) {
    ia := 0
    DllCall("gdiplus\GdipCreateImageAttributes", "Ptr*", &ia)
    m := Buffer(100, 0)                          ; 5x5 Float
    NumPut("Float", 1, m, (3 * 5 + 3) * 4)       ; Alpha behalten
    if (rgb = -1) {
        for i, wgt in [0.299, 0.587, 0.114]      ; Ausgabe = 1 - Helligkeit, in allen drei Kanaelen
            Loop 3
                NumPut("Float", -wgt, m, ((i - 1) * 5 + A_Index - 1) * 4)
        Loop 3
            NumPut("Float", 1, m, (4 * 5 + A_Index - 1) * 4)
    } else {
        NumPut("Float", (rgb >> 16 & 0xFF) / 255, m, (4 * 5 + 0) * 4)
        NumPut("Float", (rgb >> 8 & 0xFF) / 255, m, (4 * 5 + 1) * 4)
        NumPut("Float", (rgb & 0xFF) / 255, m, (4 * 5 + 2) * 4)
    }
    NumPut("Float", 1, m, (4 * 5 + 4) * 4)
    DllCall("gdiplus\GdipSetImageAttributesColorMatrix", "Ptr", ia, "Int", 0, "Int", 1, "Ptr", m, "Ptr", 0, "Int", 0)
    w := 0, h := 0
    DllCall("gdiplus\GdipGetImageWidth", "Ptr", img, "UInt*", &w)
    DllCall("gdiplus\GdipGetImageHeight", "Ptr", img, "UInt*", &h)
    DllCall("gdiplus\GdipDrawImageRectRectI", "Ptr", g, "Ptr", img, "Int", x, "Int", y, "Int", size, "Int", size
        , "Int", 0, "Int", 0, "Int", w, "Int", h, "Int", 2, "Ptr", ia, "Ptr", 0, "Ptr", 0)   ; 2 = UnitPixel
    DllCall("gdiplus\GdipDisposeImageAttributes", "Ptr", ia)
}

; Lesbare Textfarbe auf einer Fuellfarbe: weiss auf dunkel, fast schwarz auf hell
ReadableOn(col) {
    lum := 0.299 * (col >> 16 & 0xFF) + 0.587 * (col >> 8 & 0xFF) + 0.114 * (col & 0xFF)
    return (lum > 160) ? 0x1F1F1F : 0xFFFFFF
}

; Helle Variante einer Farbe (gleicher Farbton), fuer Symbole auf dunkler Toenung
LightTone(col) {
    hsl := RgbToHsl(col)
    return HslToRgb(hsl["h"], Min(1, hsl["s"]), 0.74)
}

; Fuellfarbe des aktiven Tabs: Farbton der Desktop-Farbe, Helligkeit aus dem Theme
TintFill(col) {
    hsl := RgbToHsl(col)
    return HslToRgb(hsl["h"], Min(1, hsl["s"] * CONF["TintS"] / 100), CONF["TintL"] / 100)
}

MakeFont(bold := false, sizePt := 0) {
    fam := 0, font := 0
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "Str", CONF["FontName"], "Ptr", 0, "Ptr*", &fam)
    if (!fam)
        DllCall("gdiplus\GdipGetGenericFontFamilySansSerif", "Ptr*", &fam)
    sizePx := (sizePt ? sizePt : CONF["FontSizePt"]) * SCALE * 96 / 72
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

; ------------------------------ Nummern -------------------------------------
; Sind die Nummern-Badges gerade an? "auto" folgt den Tastenkuerzeln: nur dann
; hat die Zahl am Symbol einen Zweck (sie zeigt die Taste, die man drueckt).
BadgesOn() => (CONF["NumberBadge"] = "on") || (CONF["NumberBadge"] = "auto" && CONF["Hotkeys"])

; Text des Badges fuer einen Tab ("" = keins). Nur an echten Symbolen (nicht, wenn
; die Nummer selbst das Symbol ist) und nicht, wenn die Nummer schon im Text steht.
; Mit Tastenkuerzeln zeigt es die Taste: Desktop 10 = "0", ab 11 gibt es keine.
BadgeText(num, icon, label) {
    if (!BadgesOn() || icon = "" || IsNumberSpec(icon))
        return ""
    if (CONF["ShowIndex"] && label != "")
        return ""
    if (CONF["Hotkeys"])
        return (num < 9) ? String(num + 1) : (num = 9) ? "0" : ""
    return String(num + 1)
}

; Kleiner gefuellter Kreis mit Zahl, halb ueber der oberen linken Ecke des Symbols.
; Ein schmaler Ring in der Farbe des Untergrunds stanzt ihn vom Symbol frei.
DrawBadge(g, s, ix, iy, iw, fill, fg, under) {
    d := Max(px(12), Round(iw * 0.6))
    bw := (StrLen(s) > 1) ? Round(d * 1.45) : d          ; zweistellig: Pille statt Kreis
    bx := ix - Round(d * 0.38), by := iy - Round(d * 0.38)
    ring := Max(1, px(1.5))
    FillRoundRect(g, bx - ring, by - ring, bw + 2 * ring, d + 2 * ring, (d + 2 * ring) / 2, ARGB(under))
    FillRoundRect(g, bx, by, bw, d, d / 2, ARGB(fill))
    digits := DigitPath(s, d * 0.72, bx + bw / 2, by + d / 2)
    brush := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB(fg), "Ptr*", &brush)
    DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", brush, "Ptr", digits)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
    DllCall("gdiplus\GdipDeletePath", "Ptr", digits)
}

; Nummer als Symbol: gefuellter Kreis, die Ziffern sind echte Loecher (Pfad mit
; Alternate-Fuellung), damit Toenung und Verlauf des Tabs durchscheinen.
; knockout = false: Ziffern weiss auf den Kreis (fuer dunklen Grund).
DrawNumberDisc(g, s, x, y, size, rgb, knockout := true) {
    d := size * 0.92, off := (size - d) / 2
    path := 0
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)       ; 0 = Alternate
    DllCall("gdiplus\GdipAddPathEllipse", "Ptr", path, "Float", x + off, "Float", y + off, "Float", d, "Float", d)
    digits := DigitPath(s, d * ((StrLen(s) > 1) ? 0.52 : 0.64), x + size / 2, y + size / 2)
    if (knockout)
        DllCall("gdiplus\GdipAddPathPath", "Ptr", path, "Ptr", digits, "Int", 0)   ; Ziffern im selben Pfad = Loecher
    brush := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB(rgb), "Ptr*", &brush)
    DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", brush, "Ptr", path)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
    if (!knockout) {
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB(0xFFFFFF), "Ptr*", &brush)
        DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", brush, "Ptr", digits)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
    }
    DllCall("gdiplus\GdipDeletePath", "Ptr", digits)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
}

; Ziffern als Pfad, genau auf (cx, cy) zentriert. Gemessen wird die tatsaechliche
; Form der Ziffern, nicht das Textfeld - das hat links Innenabstand und oben
; Platz fuer Akzente, die Zahl saesse sonst ein, zwei Pixel daneben.
DigitPath(s, em, cx, cy) {
    fam := 0
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "Str", CONF["FontName"], "Ptr", 0, "Ptr*", &fam)
    if (!fam)
        DllCall("gdiplus\GdipGetGenericFontFamilySansSerif", "Ptr*", &fam)
    path := 0
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
    sf := MakeFormat()
    rect := Buffer(16, 0)
    NumPut("Float", 0, "Float", 0, "Float", em * 4, "Float", em * 4, rect)
    DllCall("gdiplus\GdipAddPathString", "Ptr", path, "WStr", s, "Int", -1, "Ptr", fam, "Int", 1
        , "Float", em, "Ptr", rect, "Ptr", sf)                          ; 1 = fett
    b := Buffer(16, 0)
    DllCall("gdiplus\GdipGetPathWorldBounds", "Ptr", path, "Ptr", b, "Ptr", 0, "Ptr", 0)
    dx := cx - (NumGet(b, 0, "Float") + NumGet(b, 8, "Float") / 2)
    dy := cy - (NumGet(b, 4, "Float") + NumGet(b, 12, "Float") / 2)
    m := 0
    DllCall("gdiplus\GdipCreateMatrix2", "Float", 1, "Float", 0, "Float", 0, "Float", 1, "Float", dx, "Float", dy, "Ptr*", &m)
    DllCall("gdiplus\GdipTransformPath", "Ptr", path, "Ptr", m)
    DllCall("gdiplus\GdipDeleteMatrix", "Ptr", m)
    DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf)
    DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", fam)
    return path
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
    global gAlertNum, gAlertPhase, gAttention, gDragTipNum, gDragHwnd, gConfirmNum, gConfirmPhase
    if (!MyGui || !gLayout)
        return
    global gBuilding
    if (gBuilding && force != 2)    ; mitten im Aufbau (halbfertige Tab-Liste): nur BuildBar zeichnet, ganz am Ende
        return
    global gReorderFrom
    global gSetHover, gSetCount
    sig := gSetHover "|" (gSetCount.Has(gCurrent) ? gSetCount[gCurrent] : 0) "|" gReorderFrom "|" RegisterOn() "|" gCurrent "|" gTheme "|" CONF["ActiveStyle"] "|" CONF["ColorCoding"] "|" CONF["ShowDividers"] "|" gGripHover "|" gAlertNum "|" gAlertPhase "|" AttentionSig() "|" (gDragHwnd ? gDragTipNum : -1) "|" gConfirmNum "|" gConfirmPhase
    for item in BTNS
        sig .= (item["hover"] ? "h" : "-") item["icon"]
    if (!force && sig = gRenderSig)
        return
    gRenderSig := sig
    ; nicht unterbrechbar: ein Menue-Aufruf (Unterprojekt waehlen) baute sonst mitten in ein
    ; laufendes Zeichnen hinein die Leiste neu, und das unterbrochene Zeichnen setzte danach
    ; das alte Bild obendrauf (Name zuckte, neuer Stand erschien erst beim naechsten Hover)
    crit := A_IsCritical
    Critical
    L := gLayout
    W := GUIW, H := GUIH     ; Achtung: AHK-Namen sind case-insensitiv - die Tab-Schleife unten ueberschreibt
                             ; W/H mit w/h des jeweiligen Tabs. Nach der Schleife GUIW/GUIH nehmen!
    pBmp := 0, g := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", W, "Int", H, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &pBmp)
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", pBmp, "Ptr*", &g)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)         ; AntiAlias
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 5)     ; ClearTypeGridFit (opaker Grund)
    DllCall("gdiplus\GdipSetInterpolationMode", "Ptr", g, "Int", 7)   ; HighQualityBicubic (Symbole)
    DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", g, "Int", 2)
    bg := CONF["ColBarBg"]
    DllCall("gdiplus\GdipGraphicsClear", "Ptr", g, "UInt", ARGB(bg))
    font := MakeFont(), fontBold := MakeFont(true), sf := MakeFormat(), fontSub := MakeFont(false, CONF["FontSizePt"] - 2)
    y := L["margin"], h := L["btnH"], r := L["radius"]

    ; Griff (beim Drueberfahren leicht hervorgehoben)
    if (gGripHover)
        FillRoundRect(g, px(1), y, L["gripW"] - px(2), h, L["radius"]
            , ARGB(Mix(CONF["ColHoverBg"], bg, CONF["HoverPct"])))
    ; Fenster wird auf den Griff gezogen (= auf allen Desktops anzeigen) bzw. gerade dort angeheftet
    if ((gDragHwnd && gDragTipNum = -2) || (gConfirmNum = -2 && (gConfirmPhase & 1)))
        FillRoundRect(g, px(1), y, L["gripW"] - px(2), h, L["radius"]
            , ((gDragHwnd ? 0x90 : 0xC0) << 24) | CONF["ColActiveBg"])
    DrawText(g, font, sf, "≡", 0, y, L["gripW"], h
        , ARGB(gGripHover ? CONF["ColInactiveTx"] : CONF["ColGripTx"]))

    style := CONF["ActiveStyle"]
    grad := CONF["GradientPct"]
    reg := RegisterOn()
    for item in RenderOrder() {
        x := item["x"], w := item["w"]
        col := DesktopColor(item["num"])
        active := (item["num"] = gCurrent)
        tx := CONF["ColInactiveTx"]
        ; kraeftig gefuellt: in der Akzentfarbe ("solid") oder in der eigenen Desktop-Farbe ("soliddesk")
        solid := (style = "solid" || style = "soliddesk")
        solidBg := (style = "soliddesk") ? col : CONF["ColActiveBg"]
        if (active) {
            ; Register: der Tab reicht bis zur Oberkante (die oberen Ecken liegen ausserhalb
            ; und werden abgeschnitten) und haengt so glatt an der farbigen Kante
            ay := reg ? -r : y, ah := reg ? y + h + r : h
            ; leicht abgehoben: kleiner, harter Schatten nach unten (im dunklen Thema kraeftiger,
            ; sonst verschwindet er auf der dunklen Leiste)
            if (CONF["ActiveShadow"] && gReorderFrom < 0) {
                sd := Max(2, px(2))
                FillRoundRect(g, x + Max(1, px(1)), ay + sd, w, ah, r, (gTheme = "dark") ? 0xA0000000 : 0x4A000000)
            }
            if (solid) {
                FillRoundRectGrad(g, x, ay, w, ah, r, ARGB(solidBg), grad)
                tx := (style = "soliddesk") ? ReadableOn(col) : CONF["ColActiveTx"]
            } else {
                base := (style = "accent") ? CONF["ColActiveBg"] : col
                FillRoundRectGrad(g, x, ay, w, ah, r, ARGB(TintFill(base)), grad)
            }
        } else if (item["hover"]) {
            ; wie der Windows-Taskleisten-Hover: der Tab wird HELLER, mit leichtem Verlauf
            FillRoundRectGrad(g, x, y, w, h, r, ARGB(Mix(CONF["ColHoverBg"], bg, CONF["HoverPct"])), grad)
        }
        ; Fenster wird auf diesen Tab gezogen (Rahmen folgt weiter unten) bzw. wurde gerade
        ; hierher verschoben (kurzes Bestaetigungsblinken): Flaeche in der Desktop-Farbe
        if (gDragHwnd && item["num"] = gDragTipNum)
            FillRoundRect(g, x, y, w, h, r, 0x70000000 | col)
        if (item["num"] = gConfirmNum && (gConfirmPhase & 1))
            FillRoundRect(g, x, y, w, h, r, 0xC0000000 | col)
        ; Symbol links, Text daneben (bzw. nur eins von beidem)
        iw := item["iw"]
        tx0 := x + px(gPadX), tw := w - 2 * px(gPadX)
        if (iw && item["label"] != "" && item["badge"] != "")
            tx0 += px(5), tw -= px(5)             ; Platz fuers Abzeichen links (siehe BuildBarAt)
        if (iw && item["label"] = "")
            tx0 := x + (w - iw) // 2              ; nur Symbol: mittig in der Kachel
        if (iw) {
            iy := y + (h - iw) // 2 - px(1)
            if (IsNumberSpec(item["icon"])) {
                ; Nummer als Symbol: gefuellter Kreis, Zahl ausgestanzt (der Tab scheint durch)
                ; im dunklen Schema waeren ausgestanzte Ziffern zu dunkel: dort weisse Ziffern
                DrawNumberDisc(g, String(item["num"] + 1), tx0, iy, iw, (active && solid) ? tx : col
                    , (gTheme != "dark") || (active && solid))
            } else if (IsGlyphSpec(item["icon"])) {
                ; Bibliotheks-Symbol in der Desktop-Farbe; auf kraeftig gefuelltem
                ; Grund stattdessen in der Textfarbe, sonst verschwindet es darin
                ; im dunklen Schema ginge es auf der gleichfarbigen Toenung des aktiven Tabs
                ; unter: dort in einer hellen Variante derselben Farbe
                DrawGlyph(g, item["icon"], tx0, iy, iw, (active && solid) ? tx
                    : (active && gTheme = "dark") ? LightTone(col) : col)
            } else {
                img := LoadIconBitmap(item["icon"])
                ; auf kraeftiger Fuellung: Logo mit zu wenig Kontrast umfaerben, damit es sichtbar bleibt
                st := (img && active && solid) ? IconStats(item["icon"]) : 0
                low := (img && st && st["mean"] >= 0 && ContrastRatio(st["mean"], solidBg) < 2.0)
                if (low && st["transp"] >= 0.15)
                    DrawImageTinted(g, img, tx0, iy, iw, tx)          ; freigestelltes Logo: weisse Silhouette
                else if (low && RelLum(st["mean"]) < RelLum(solidBg))   ; nur dunkle Kachel auf hellerer Fuellung
                    DrawImageTinted(g, img, tx0, iy, iw, -1)          ; Logo mit eigener Kachel auf dunkler Fuellung: hell/dunkel umgekehrt
                else if (img)
                    DllCall("gdiplus\GdipDrawImageRectI", "Ptr", g, "Ptr", img, "Int", tx0
                        , "Int", iy, "Int", iw, "Int", iw)
                else
                    iw := 0
            }
            if (iw && item["badge"] != "") {
                ; Grund, auf dem das Badge liegt: dieselbe Farbe wie der Tab dort
                under := active ? (solid ? solidBg : TintFill((style = "accent") ? CONF["ColActiveBg"] : col)) : item["hover"] ? Mix(CONF["ColHoverBg"], bg, CONF["HoverPct"]) : bg
                if (active && solid)
                    DrawBadge(g, item["badge"], tx0, iy, iw, tx, solidBg, under)   ; umgekehrt: weiss mit farbiger Zahl
                else if (active && gTheme = "dark")
                    DrawBadge(g, item["badge"], tx0, iy, iw, LightTone(col), 0x1F1F1F, under)   ; hebt sich von der dunklen Toenung ab
                else
                    DrawBadge(g, item["badge"], tx0, iy, iw, col, 0xFFFFFF, under)
            }
            tx0 += iw ? iw + L["iconGap"] : 0
            tw -= iw ? iw + L["iconGap"] : 0
        }
        if (item["label"] != "" && item.Has("sub") && item["sub"] != "") {
            ; zwei Zeilen: Name oben, Unterprojekt klein darunter (63 % Deckkraft der Textfarbe)
            nH := Round(CONF["FontSizePt"] * SCALE * 96 / 72 * 1.25), sH := Round((CONF["FontSizePt"] - 2) * SCALE * 96 / 72 * 1.25)
            ty := y + (h - nH - sH) // 2 + px(1)
            DrawText(g, (active && CONF["ActiveBold"]) ? fontBold : font, sf, item["label"], tx0, ty, tw, nH, ARGB(tx))
            DrawText(g, fontSub, sf, item["sub"], tx0, ty + nH - px(1), tw, sH, 0xA0000000 | (tx & 0xFFFFFF))
        } else if (item["label"] != "")
            DrawText(g, (active && CONF["ActiveBold"]) ? fontBold : font, sf, item["label"], tx0, y, tw, h, ARGB(tx))
        ; Farbbalken unten im Tab (abgerundet, eingerueckt)
        if (CONF["ColorCoding"]) {
            iconOnly := (item["label"] = "" && iw)
            inset := iconOnly ? px(5) : px(10)
            ah := L["accH"] + (iconOnly ? px(1) : 0)   ; Symbol-Stufe: deutlicher Streifen als Kennung
            if (active) {
                ah += px(CONF["ActiveBarBoost"])    ; aktiver Desktop: dickerer, breiterer Streifen
                inset := Max(px(2), inset - px(4))
            }
            FillRoundRect(g, x + inset, y + h - ah - px(3), w - 2 * inset, ah, ah / 2
                , (active && style = "soliddesk") ? (0xB0000000 | tx) : ARGB(col))   ; auf eigener Farbe unsichtbar -> in Textfarbe
        }
        ; Fenster wird auf diesen Tab gezogen: kraeftig getoent mit Rahmen in der Desktop-Farbe
        if (gDragHwnd && item["num"] = gDragTipNum)
            StrokeRoundRect(g, x, y, w, h, r, ARGB(col), Max(2, px(2)))
        ; Programm auf diesem Desktop blinkt: oranger Punkt oben rechts (wie in der Taskleiste)
        if (gAttention.Has(item["num"]) && !active) {
            dr := Max(3, px(4)), dcx := x + w - px(9), dcy := y + px(9), rg := Max(1, px(1.5))
            FillRoundRect(g, dcx - dr - rg, dcy - dr - rg, 2 * (dr + rg), 2 * (dr + rg), dr + rg, ARGB(item["hover"] ? Mix(CONF["ColHoverBg"], bg, CONF["HoverPct"]) : bg))
            FillRoundRect(g, dcx - dr, dcy - dr, 2 * dr, 2 * dr, dr, ARGB(0xF7630C))
        }
        ; fremder Wechsel: Tab blinkt orange, danach bleibt ein oranger Rahmen
        if (item["num"] = gAlertNum) {
            if (gAlertPhase & 1)
                FillRoundRect(g, x, y, w, h, r, 0x99F5A524)
            StrokeRoundRect(g, x, y, w, h, r, ARGB(0xF5A524), Max(2, px(2)))
        }
        ; optionaler Trennstrich in der Luecke danach
        if (CONF["ShowDividers"] && A_Index < BTNS.Length && gReorderFrom < 0) {
            dw := Max(1, px(1)), divH := h - 2 * px(CONF["DividerInsetY"])
            if (divH < px(8))
                divH := h
            FillRoundRect(g, x + w + (L["gap"] - dw) / 2, y + (h - divH) / 2, dw, divH, 0, ARGB(CONF["ColDivider"]))
        }
        ; Umsortieren: der gegriffene Tab haengt obenauf an der Maus, mit Rahmen in der Akzentfarbe
        if (item["num"] = gReorderFrom)
            StrokeRoundRect(g, x, y, w, h, r, ARGB(CONF["ColActiveBg"]), Max(2, px(2)))
    }
    if (L["setW"]) {                               ; Fensteranordnungen: Kachel mit Kuerzel je Anordnung
        global gSetNames
        names := gSetNames.Has(gCurrent) ? gSetNames[gCurrent] : []
        sby := L["margin"], sbh := L["btnH"], kc := (gCurrent >= 0) ? DesktopColor(gCurrent) : CONF["ColActiveBg"]
        fM := MakeFont(true, CONF["FontSizePt"] - 1)
        dvw := Max(1, px(1)), dvh := sbh - 2 * px(6)
        if (names.Length)                          ; Trennstrich Tabs | Anordnungen, nur wenn hier Kacheln stehen
            FillRoundRect(g, L["setX"] - L["gap"] - dvw / 2, sby + (sbh - dvh) / 2, dvw, dvh, 0, ARGB(CONF["ColGripTx"]))
        Loop L["setN"] {
            sbx := L["setX"] + (A_Index - 1) * sbh
            if (gSetHover = A_Index)
                FillRoundRect(g, sbx + px(2), sby, sbh - px(4), sbh, L["radius"], ARGB(Mix(CONF["ColHoverBg"], bg, CONF["HoverPct"])))
            if (A_Index > names.Length)
                continue
            ks := Round(sbh * 0.56), kx := sbx + (sbh - ks) / 2, ky := sby + (sbh - ks) / 2
            FillRoundRect(g, kx, ky, ks, ks, px(5), ARGB(kc))
            DrawText(g, fM, sf, SetInitials(names[A_Index]), kx, ky, ks, ks, ARGB(ReadableOn(kc)))
            FillRoundRect(g, kx + ks * 0.25, ky + ks + px(3), ks * 0.5, Max(2, px(2)), px(1), ARGB(CONF["ColGripTx"]))   ; Strich wie unter Taskleisten-Programmen
        }
        DllCall("gdiplus\GdipDeleteFont", "Ptr", fM)
    }
    if (reg)                                       ; die Kante laeuft auch ueber die Leiste
        FillRoundRect(g, 0, 0, GUIW, StripeH(), 0, ARGB(ActiveEdgeColor()))
    hbm := 0
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", pBmp, "Ptr*", &hbm, "UInt", ARGB(bg))
    if (!gBarDC)
        gBarDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
    DllCall("SelectObject", "Ptr", gBarDC, "Ptr", hbm, "Ptr")
    if (gBarBmp)
        DllCall("DeleteObject", "Ptr", gBarBmp)
    gBarBmp := hbm
    ; Zweigleisig auf den Bildschirm: sofort direkt zeichnen (ein Neuzeichnen-Wunsch aus
    ; einem Timer ging sonst manchmal verloren, sichtbar als haengende Markierung beim
    ; Ziehen eines Fensters auf einen Tab) UND Windows neu zeichnen lassen - waehrend
    ; eines Desktop-Wechsels landet das direkte Zeichnen im Leeren, dann greift WM_PAINT.
    if (!gBuilding)                 ; im Aufbau: nur das Pufferbild, BuildBar bringt es nach dem Groessenwechsel
        BarBlit()                   ; auf den Schirm (sonst landete das neue Bild kurz im alten Fenster: Zucken)
    DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
    DllCall("gdiplus\GdipDeleteFont", "Ptr", fontBold)
    DllCall("gdiplus\GdipDeleteFont", "Ptr", fontSub)
    DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", pBmp)
    Critical(crit)
}

; ------------------ Hinweis-Karten ueber der Taskleiste ----------------------
; Kleine Flaechen im Grau der Leiste, die ganz links aus der Oberkante der Taskleiste
; herausgleiten (wie die Unterprojekt-Auswahl am Tab): der Update-Hinweis und
; "Neu in dieser Version". Sie liegen auf allen Desktops und bleiben, bis man sie
; schliesst (X) bzw. etwas anklickt. Eigenes Schichtfenster (UpdateLayeredWindow).
CardOpen(kind, data := "") {
    global gCard
    if (gCard)
        CardClose()
    c := Map("kind", kind, "data", data, "state", "", "hover", "", "dc", 0, "hbm", 0, "obm", 0, "shown", 0)
    gCard := c
    CardLayout(c)
    tb := TaskbarRect()
    c["x"] := (tb ? tb[1] : 0) + px(12)
    c["bottom"] := (tb && tb[2] > A_ScreenHeight // 2) ? tb[2] : A_ScreenHeight
    g := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08080000 -DPIScale")   ; NOACTIVATE | LAYERED
    g.Show(Format("NA x{1} y{2} w1 h1", c["x"], c["bottom"] - 1))
    c["gui"] := g
    try DllCall("VirtualDesktopAccessor\PinWindow", "Ptr", g.Hwnd)          ; auf allen Desktops
    CardPaint()
    Loop 10 {                                      ; herausgleiten
        if (gCard != c)
            return
        f10 := A_Index / 10
        CardShow(Max(1, Round(c["h"] * (1 - (1 - f10) ** 3))))
        Sleep(14)
    }
    SetTimer(CardTick, 40)
}

CardClose(*) {
    global gCard
    if (!gCard)
        return
    c := gCard, gCard := 0
    SetTimer(CardTick, 0)
    try c["gui"].Destroy()
    if (c["dc"]) {
        DllCall("SelectObject", "Ptr", c["dc"], "Ptr", c["obm"])
        DllCall("DeleteObject", "Ptr", c["hbm"])
        DllCall("DeleteDC", "Ptr", c["dc"])
    }
}

; Groesse und Klickflaechen (zones: Name -> [x, y, w, h]) berechnen
CardLayout(c) {
    GdipStart()
    mBmp := 0, mG := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", 1, "Int", 1, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &mBmp)
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", mBmp, "Ptr*", &mG)
    fB := MakeFont(true), fS := MakeFont(false, CONF["FontSizePt"] - 1), sf := MakeFormat()
    fSB := MakeFont(true, CONF["FontSizePt"] - 1)
    z := Map(), xs := px(30)
    if (c["kind"] = "update") {
        c["l1"] := (c["state"] = "load") ? T("upd.loading") : (c["state"] = "err") ? T("upd.failed") : T("upd.title", c["data"])
        if (!c.Has("setup"))
            c["setup"] := IsSetupInstall()          ; nur dann geht das Update mit einem Klick
        c["l2"] := (c["state"] = "load") ? T("upd.loading.sub") : (c["state"] = "err") ? T("upd.failed.sub")
            : c["setup"] ? T("upd.sub") : T("upd.sub.page")
        c["btn"] := (c["state"] = "load") ? "" : (c["state"] = "err" || !c["setup"]) ? T("upd.btn.page") : T("upd.btn")
        tw := Max(MeasureText(mG, fB, sf, c["l1"]), MeasureText(mG, fS, sf, c["l2"]))
        bw := (c["btn"] != "") ? MeasureText(mG, fB, sf, c["btn"]) + px(28) : 0
        h := px(60), tx := px(54)
        w := tx + tw + px(20) + bw + (bw ? px(10) : 0) + xs + px(10)
        if (bw)
            z["btn"] := [w - px(10) - xs - px(10) - bw, (h - px(32)) // 2, bw, px(32)]
        z["body"] := [0, 0, w, h]
    } else {                                       ; "news": Neu in dieser Version
        w := px(460), padX := px(18), bx := padX + px(16), bodyW := w - bx - padX
        y := px(16), rows := []
        rows.Push(["title", T("news.title", APP_VERSION), padX, y, w - 2 * padX - xs, px(24)])
        y += px(32)
        groups := c["data"]
        for gi, grp in groups {
            if (groups.Length > 1) {
                rows.Push(["ver", grp[1], padX, y, bodyW, px(18)])
                y += px(22)
            }
            for , item in grp[2] {
                rl := RichLayout(mG, fS, fSB, item, bodyW)
                rows.Push(["item", rl, bx, y, bodyW, rl["h"]])
                y += rl["h"] + px(6)
            }
            y += px(4)
        }
        y += px(2)
        rows.Push(["link", T("news.all"), padX, y, MeasureText(mG, fS, sf, T("news.all")) + px(4), px(20)])
        z["link"] := [padX, y, MeasureText(mG, fS, sf, T("news.all")) + px(4), px(20)]
        h := y + px(20) + px(14)
        c["rows"] := rows
        tb := TaskbarRect()
        avail := ((tb && tb[2] > A_ScreenHeight // 2) ? tb[2] : A_ScreenHeight) - px(24)
        c["hdr"] := px(48)                         ; Titelzeile: scrollt nicht mit
        if (h > avail) {
            c["full"] := h, h := avail
            if (!c.Has("sy"))
                c["sy"] := 0
        }
    }
    z["x"] := [w - px(8) - xs, (c["kind"] = "update") ? (h - xs) // 2 : px(10), xs, xs]
    c["w"] := w, c["h"] := h, c["zones"] := z
    DllCall("gdiplus\GdipDeleteFont", "Ptr", fB), DllCall("gdiplus\GdipDeleteFont", "Ptr", fS), DllCall("gdiplus\GdipDeleteFont", "Ptr", fSB)
    DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sf)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", mG), DllCall("gdiplus\GdipDisposeImage", "Ptr", mBmp)
}

; Text mit **fett** markierten Stellen, an Wortgrenzen auf width umbrochen.
; Ergebnis: runs = [Text, fett, x, y, Breite] je Stueck, lh = Zeilenhoehe, h = Gesamthoehe
RichLayout(g, fN, fB, s, width) {
    sf := RichFormat()
    spaceW := RichW(g, fN, " ")
    fh := 0
    DllCall("gdiplus\GdipGetFontHeight", "Ptr", fN, "Ptr", g, "Float*", &fh)
    lh := Ceil(fh * 1.12)
    runs := [], x := 0, y := 0, bold := false
    for , word in StrSplit(s, " ") {
        if (word = "")
            continue
        wr := [], ww := 0
        for i, part in StrSplit(word, "**") {
            if (i > 1)
                bold := !bold                        ; jedes ** schaltet um
            if (part = "")
                continue
            pw := RichW(g, bold ? fB : fN, part)
            wr.Push([part, bold, ww, pw]), ww += pw
        }
        if (!wr.Length)
            continue
        if (x > 0 && x + ww > width)
            x := 0, y += lh
        for , rn in wr
            runs.Push([rn[1], rn[2], x + rn[3], y, rn[4]])
        x += ww + spaceW
    }
    return Map("runs", runs, "lh", lh, "h", y + lh)
}
; Typografisches Format (ohne den Zusatzrand von GDI+), damit Stuecke nahtlos aneinanderpassen
RichFormat() {
    static sf := 0
    if (!sf) {
        tmp := 0
        DllCall("gdiplus\GdipStringFormatGetGenericTypographic", "Ptr*", &tmp)
        DllCall("gdiplus\GdipCloneStringFormat", "Ptr", tmp, "Ptr*", &sf)
        DllCall("gdiplus\GdipSetStringFormatFlags", "Ptr", sf, "Int", 0x4 | 0x800 | 0x1000 | 0x4000)   ; NoFitBlackBox | MeasureTrailingSpaces | NoWrap | NoClip
    }
    return sf
}
RichW(g, font, s) {
    layout := Buffer(16, 0), bound := Buffer(16, 0)
    NumPut("Float", 0, "Float", 0, "Float", 10000, "Float", 1000, layout)
    DllCall("gdiplus\GdipMeasureString", "Ptr", g, "Str", s, "Int", -1, "Ptr", font, "Ptr", layout, "Ptr", RichFormat(), "Ptr", bound, "Ptr", 0, "Ptr", 0)
    return NumGet(bound, 8, "Float")
}

CardPaint() {
    global gCard
    c := gCard, w := c["w"], h := c["h"]
    if (c["dc"] && (c["dcW"] != w || c["dcH"] != h)) {     ; Groesse geaendert (anderer Zustand)
        DllCall("SelectObject", "Ptr", c["dc"], "Ptr", c["obm"]), DllCall("DeleteObject", "Ptr", c["hbm"]), DllCall("DeleteDC", "Ptr", c["dc"])
        c["dc"] := 0
    }
    if (!c["dc"]) {
        bi := Buffer(40, 0)
        NumPut("UInt", 40, bi, 0), NumPut("Int", w, bi, 4), NumPut("Int", -h, bi, 8)
        NumPut("UShort", 1, bi, 12), NumPut("UShort", 32, bi, 14)
        c["dc"] := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
        bits := 0
        c["hbm"] := DllCall("CreateDIBSection", "Ptr", c["dc"], "Ptr", bi, "UInt", 0, "Ptr*", &bits, "Ptr", 0, "UInt", 0, "Ptr")
        c["obm"] := DllCall("SelectObject", "Ptr", c["dc"], "Ptr", c["hbm"], "Ptr")
        c["dcW"] := w, c["dcH"] := h
    }
    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", c["dc"], "Ptr*", &g)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", g, "Int", 2)
    DllCall("gdiplus\GdipGraphicsClear", "Ptr", g, "UInt", 0)
    bg := CONF["ColBarBg"], fg := CONF["ColInactiveTx"], r := px(8), d := r * 2
    hov := Mix(CONF["ColHoverBg"], bg, CONF["HoverPct"])
    ; Grund: oben rund, unten eckig (sitzt auf der Taskleiste); feiner Rand oben und seitlich
    path := 0
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", 0, "Float", 0, "Float", d, "Float", d, "Float", 180, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", w - d, "Float", 0, "Float", d, "Float", d, "Float", 270, "Float", 90)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", w, "Float", r, "Float", w, "Float", h)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", w, "Float", h, "Float", 0, "Float", h)
    DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
    brush := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB(bg), "Ptr*", &brush)
    DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", brush, "Ptr", path)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
    pen := 0
    DllCall("gdiplus\GdipCreatePen1", "UInt", 0x28000000 | (fg & 0xFFFFFF), "Float", 1, "Int", 2, "Ptr*", &pen)
    DllCall("gdiplus\GdipDrawPath", "Ptr", g, "Ptr", pen, "Ptr", path)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen), DllCall("gdiplus\GdipDeletePath", "Ptr", path)
    fB := MakeFont(true), fS := MakeFont(false, CONF["FontSizePt"] - 1), fT := MakeFont(true, CONF["FontSizePt"] + 1)
    fSB := MakeFont(true, CONF["FontSizePt"] - 1)
    sfL := MakeFormat()
    DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", sfL, "Int", 0)
    sfC := MakeFormat()
    z := c["zones"]
    if (c["kind"] = "update") {
        isz := px(26), iy := (h - isz) // 2
        bmp := CardAppIcon(isz)
        if (bmp)
            DllCall("gdiplus\GdipDrawImageRectI", "Ptr", g, "Ptr", bmp, "Int", px(16), "Int", iy, "Int", isz, "Int", isz)
        if (c["hover"] = "body" || c["hover"] = "btn")
            FillRoundRect(g, px(4), px(4), z["x"][1] - px(8), h - px(8), px(6), ARGB(hov))
        lh := Round(CONF["FontSizePt"] * SCALE * 96 / 72 * 1.3)
        DrawText(g, fB, sfL, c["l1"], px(54), h // 2 - lh, w, lh, ARGB(fg))
        DrawText(g, fS, sfL, c["l2"], px(54), h // 2, w, lh, 0xA0000000 | (fg & 0xFFFFFF))
        if (z.Has("btn")) {
            b := z["btn"], acc := CONF["ColActiveBg"]
            FillRoundRect(g, b[1], b[2], b[3], b[4], px(6), ARGB(c["hover"] = "btn" ? Mix(0x000000, acc, 15) : acc))
            DrawText(g, fB, sfC, c["btn"], b[1], b[2], b[3], b[4], ARGB(ReadableOn(acc)))
        }
    } else {
        clipped := false
        scr := c.Has("full"), sy := scr ? c["sy"] : 0
        for , row in c["rows"] {
            kindR := row[1], s := row[2], x := row[3], y := row[4], rw := row[5], rh := row[6]
            if (kindR != "title") {
                if (scr && y - sy + rh < c["hdr"] || y - sy > h)
                    continue                       ; ausserhalb des sichtbaren Bereichs
                if (scr && !clipped) {
                    DllCall("gdiplus\GdipSetClipRectI", "Ptr", g, "Int", 0, "Int", c["hdr"], "Int", w, "Int", h - c["hdr"] - px(4), "Int", 0)
                    clipped := true
                }
                y -= sy
            }
            if (kindR = "title")
                DrawText(g, fT, sfL, s, x, y, rw, rh, ARGB(fg))
            else if (kindR = "ver")
                DrawText(g, fS, sfL, s, x, y, rw, rh, 0x99000000 | (fg & 0xFFFFFF))
            else if (kindR = "item") {
                FillRoundRect(g, x - px(12), y + s["lh"] / 2 - px(2.5), px(5), px(5), px(2.5), ARGB(CONF["ColActiveBg"]))
                for , rn in s["runs"]
                    DrawText(g, rn[2] ? fSB : fS, RichFormat(), rn[1], x + rn[3], y + rn[4], rn[5] + px(20), s["lh"], ARGB(fg))
            } else if (kindR = "link")
                DrawText(g, fS, sfL, s, x, y, rw + px(40), rh, ARGB(c["hover"] = "link" ? fg : CONF["ColActiveBg"]))
        }
        if (clipped)
            DllCall("gdiplus\GdipResetClip", "Ptr", g)
        if (scr) {                                 ; schmaler Balken rechts, wie in Windows 11
            trackY := c["hdr"], trackH := h - c["hdr"] - px(10)
            thumbH := Max(px(24), Round(trackH * h / c["full"]))
            thumbY := trackY + Round((trackH - thumbH) * sy / (c["full"] - h))
            FillRoundRect(g, w - px(8), thumbY, px(3), thumbH, px(1.5), 0x60000000 | (fg & 0xFFFFFF))
        }
    }
    ; Schliessen (X)
    xb := z["x"]
    if (c["hover"] = "x")
        FillRoundRect(g, xb[1], xb[2], xb[3], xb[4], px(6), ARGB(hov))
    pen := 0, cx := xb[1] + xb[3] / 2, cy := xb[2] + xb[4] / 2, k := px(5)
    DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB(fg), "Float", Max(1, px(1.3)), "Int", 2, "Ptr*", &pen)
    DllCall("gdiplus\GdipDrawLine", "Ptr", g, "Ptr", pen, "Float", cx - k, "Float", cy - k, "Float", cx + k, "Float", cy + k)
    DllCall("gdiplus\GdipDrawLine", "Ptr", g, "Ptr", pen, "Float", cx - k, "Float", cy + k, "Float", cx + k, "Float", cy - k)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
    for , f in [fB, fS, fT, fSB]
        DllCall("gdiplus\GdipDeleteFont", "Ptr", f)
    DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sfL), DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", sfC)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    if (c["shown"])
        CardShow(c["h"])
}

; Programmsymbol als GDI+-Bild (einmal geladen)
CardAppIcon(size) {
    static cache := Map()
    if (cache.Has(size))
        return cache[size]
    bmp := 0
    try {
        hIco := LoadPicture(AppIconPath(), "w" size " h" size " Icon1", &imgType)
        if (hIco)
            DllCall("gdiplus\GdipCreateBitmapFromHICON", "Ptr", hIco, "Ptr*", &bmp)
    }
    cache[size] := bmp
    return bmp
}

CardShow(hh) {
    global gCard
    c := gCard
    c["shown"] := hh
    pt := Buffer(8, 0), sz := Buffer(8, 0), src := Buffer(8, 0)
    NumPut("Int", c["x"], "Int", c["bottom"] - hh, pt)
    NumPut("Int", c["w"], "Int", hh, sz)
    DllCall("UpdateLayeredWindow", "Ptr", c["gui"].Hwnd, "Ptr", 0, "Ptr", pt, "Ptr", sz, "Ptr", c["dc"]
        , "Ptr", src, "UInt", 0, "UInt*", 0x01FF0000, "UInt", 2)
}

; Klickflaeche unter der Maus ("" = keine, "out" = ausserhalb)
CardZoneAt() {
    global gCard
    c := gCard
    pt := Buffer(8, 0)
    DllCall("GetCursorPos", "Ptr", pt)
    lx := NumGet(pt, 0, "Int") - c["x"], ly := NumGet(pt, 4, "Int") - (c["bottom"] - c["h"])
    if (lx < 0 || ly < 0 || lx >= c["w"] || ly >= c["h"])
        return "out"
    for , name in ["x", "btn", "link", "body"]
        if (c["zones"].Has(name)) {
            r := c["zones"][name]
            ry := r[2]
            if (name = "link" && c.Has("full")) {
                ry -= c["sy"]
                if (ly < c["hdr"])
                    continue                       ; unter die Titelzeile gescrollt
            }
            if (lx >= r[1] && ly >= ry && lx < r[1] + r[3] && ly < ry + r[4])
                return name
        }
    return ""
}

CardTick() {
    global gCard
    if (!gCard)
        return SetTimer(CardTick, 0)
    zn := CardZoneAt()
    zn := (zn = "out") ? "" : zn
    if (zn != gCard["hover"]) {
        gCard["hover"] := zn
        CardPaint()
    }
}

CardUp(wParam, lParam, msg, hwnd) {
    global gCard, gNoticeDismissed
    if (!gCard || hwnd != gCard["gui"].Hwnd)
        return
    zn := CardZoneAt(), kind := gCard["kind"]
    if (zn = "x") {
        if (kind = "update")
            gNoticeDismissed := FormatTime(, "yyyyMMdd")   ; heute nicht mehr; nach Neustart wieder
        CardClose()
    } else if (kind = "update" && (zn = "btn" || zn = "body")) {
        if (gCard["state"] = "err") {
            CardClose(), OpenReleasePage()
        } else if (gCard["state"] = "")
            UpdateStart()
    } else if (kind = "news" && zn = "link") {
        CardClose(), Run(APP_CHANGELOG_URL)
    }
    return 0
}

CardWheel(wParam, lParam, msg, hwnd) {
    global gCard
    if (!gCard || hwnd != gCard["gui"].Hwnd || !gCard.Has("full"))
        return
    delta := (wParam >> 16) & 0xFFFF
    if (delta >= 0x8000)
        delta -= 0x10000
    gCard["sy"] := Max(0, Min(gCard["full"] - gCard["h"], gCard["sy"] - Round(delta / 120 * px(60))))
    CardPaint()
    return 0
}

CardSetCursor(wParam, lParam, msg, hwnd) {
    global gCard
    if (!gCard || hwnd != gCard["gui"].Hwnd)
        return
    zn := CardZoneAt()
    if (zn = "x" || zn = "btn" || zn = "link" || (zn = "body" && gCard["kind"] = "update" && gCard["state"] != "load")) {
        DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32649, "Ptr"))   ; IDC_HAND
        return 1
    }
}

; --------------------------- Update mit einem Klick --------------------------
; Mit dem Setup installiert (Eintrag in "Apps & Features" zeigt auf diesen Ordner):
; Setup der neuen Version laden, gegen SHA256SUMS.txt pruefen, ohne Assistent starten;
; es installiert und startet DeskTabs wieder (/restart=1, siehe installer\DeskTabs.iss).
; Sonst (ZIP, Skript) oeffnet der Hinweis die Download-Seite.
IsSetupInstall() {
    if (!A_IsCompiled)
        return false
    try loc := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\{8B5D6C21-3E4A-4F1B-9C77-1D2E3F4A5B6C}_is1", "InstallLocation")
    catch
        return false
    return (RTrim(loc, "\") = RTrim(A_ScriptDir, "\"))
}

UpdateStart() {
    global gCard
    if (!IsSetupInstall()) {
        CardClose(), OpenReleasePage()
        return
    }
    gCard["state"] := "load", gCard["hover"] := ""
    CardRelayout()
    SetTimer(UpdateRun, -60)                       ; erst den neuen Zustand zeigen, dann laden
}

CardRelayout() {
    global gCard
    CardLayout(gCard)
    CardPaint()
    CardShow(gCard["h"])
}

UpdateRun() {
    global gCard, APP_URL
    if (!gCard || gCard["kind"] != "update")
        return
    tag := gCard["data"]
    dir := A_Temp "\DeskTabs-update"
    exeName := "DeskTabs-Setup-" tag ".exe"
    ok := false
    try {
        DirCreate(dir)
        base := APP_URL "/releases/download/" tag "/"
        Download(base "SHA256SUMS.txt", dir "\SHA256SUMS.txt")
        Download(base exeName, dir "\" exeName)
        want := ""
        Loop Parse, FileRead(dir "\SHA256SUMS.txt"), "`n", "`r"
            if (RegExMatch(A_LoopField, "i)^([0-9a-f]{64})\s+\*?" StrReplace(exeName, ".", "\.") "$", &m))
                want := m[1]
        ok := (want != "" && FileSha256(dir "\" exeName) = StrLower(want))
    }
    if (!ok) {
        if (gCard) {
            gCard["state"] := "err"
            CardRelayout()
        }
        return
    }
    ; Setup starten und DeskTabs beenden, damit es seine Dateien ersetzen kann
    Run('"' dir "\" exeName '" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /restart=1')
    ExitApp()
}

FileSha256(path) {
    data := FileRead(path, "RAW")
    hAlg := 0, hash := Buffer(32, 0)
    DllCall("bcrypt\BCryptOpenAlgorithmProvider", "Ptr*", &hAlg, "Str", "SHA256", "Ptr", 0, "UInt", 0)
    DllCall("bcrypt\BCryptHash", "Ptr", hAlg, "Ptr", 0, "UInt", 0, "Ptr", data, "UInt", data.Size, "Ptr", hash, "UInt", 32)
    DllCall("bcrypt\BCryptCloseAlgorithmProvider", "Ptr", hAlg, "UInt", 0)
    hex := ""
    Loop 32
        hex .= Format("{:02x}", NumGet(hash, A_Index - 1, "UChar"))
    return hex
}

; Update-Hinweis zeigen (nicht, wenn heute schon weggeklickt - ausser auf Nachfrage)
UpdateNotice(force := false, *) {
    global gUpdateTag, gNoticeDismissed, gCard
    if (gUpdateTag = "")
        return
    if (!force && gNoticeDismissed = FormatTime(, "yyyyMMdd"))
        return
    if (gCard && gCard["kind"] = "update")
        return
    CardOpen("update", gUpdateTag)
}

; --------------------------- Neu in dieser Version ---------------------------
; data\changelog.<sprache>.md:  "## 1.1.13" und darunter "- Punkt" je Neuerung.
; Gezeigt werden alle Versionen nach der zuletzt gesehenen, neueste oben. Wird die Karte
; hoeher als der Platz ueber der Taskleiste, scrollt der Inhalt (Mausrad, Balken rechts).
NewsFor(fromVer, toVer) {
    global gLangCode
    file := A_ScriptDir "\data\changelog." gLangCode ".md"
    if !FileExist(file)
        file := A_ScriptDir "\data\changelog.en.md"
    if !FileExist(file)
        return []
    groups := [], cur := 0
    Loop Parse, FileRead(file, "UTF-8"), "`n", "`r" {
        line := Trim(A_LoopField)
        if RegExMatch(line, "^##\s*v?([\d.]+)", &m) {
            cur := (VersionCmp(m[1], toVer) <= 0 && (fromVer = "" || VersionCmp(m[1], fromVer) > 0)) ? [m[1], []] : 0
            if (cur)
                groups.Push(cur)
        } else if (cur && RegExMatch(line, "^[-*]\s+(.+)", &m))
            cur[2].Push(StrReplace(m[1], "``", ""))          ; **fett** bleibt, RichLayout setzt es um
    }
    out := []
    for , grp in groups
        if (grp[2].Length)
            out.Push(grp)
    return out
}

ShowNews(fromVer := "", *) {
    global APP_VERSION
    news := NewsFor(fromVer, APP_VERSION)
    if (!news.Length)
        news := NewsFor(PrevVersion(APP_VERSION), APP_VERSION)
    if (news.Length)
        CardOpen("news", news)
}
PrevVersion(v) {                                   ; "1.1.13" -> "1.1.12" (fuer "nur diese Version")
    p := StrSplit(v, ".")
    p[p.Length] := Max(0, Integer(p[p.Length]) - 1)
    s := ""
    for i, n in p
        s .= (i > 1 ? "." : "") n
    return s
}

; Beim Start: erstes Mal nach einem Update? Dann einmal zeigen, was neu ist.
NewsAfterUpdate() {
    global APP_VERSION, gWasWelcomed
    ; vom Ein-Klick-Update geladenes Setup wegraeumen (das Setup ist laengst beendet)
    if DirExist(A_Temp "\DeskTabs-update")
        try DirDelete(A_Temp "\DeskTabs-update", true)
    seen := IniRead(CONF["IniPath"], "State", "SeenVersion", "")
    IniSet("State", "SeenVersion", APP_VERSION)
    if (seen = "") {
        if (gWasWelcomed != "1")
            return                                  ; ganz neue Installation: nichts "Neues"
        seen := PrevVersion(APP_VERSION)            ; Update von einer Version ohne diese Funktion
    }
    if (VersionCmp(APP_VERSION, seen) > 0)
        ShowNews(seen)
}

BarBlit() {
    global MyGui, GUIW, GUIH, gBarDC
    wdc := DllCall("GetDC", "Ptr", MyGui.Hwnd, "Ptr")
    DllCall("BitBlt", "Ptr", wdc, "Int", 0, "Int", 0, "Int", GUIW, "Int", GUIH, "Ptr", gBarDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
    DllCall("ReleaseDC", "Ptr", MyGui.Hwnd, "Ptr", wdc)
    DllCall("InvalidateRect", "Ptr", MyGui.Hwnd, "Ptr", 0, "Int", 0)   ; ohne Loeschen
    DllCall("UpdateWindow", "Ptr", MyGui.Hwnd)
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
    tid := DesktopGuid(target)    ; jetzt, solange der Explorer frei ist: danach wartet jede Rueckfrage 200-400 ms
    if (CONF["RestoreZOrder"]) {
        SetTimer(ZSnapCurrent, 0)
        ZSnapCurrent()            ; Reihenfolge des Desktops festhalten, den wir verlassen
        global gZBlockUntil := A_TickCount + 5000
    }
    gSwitching := true            ; sperrt Rebuilds + Mausrad-Folgeticks waehrend des Wechsels
    global gSelfTick := A_TickCount
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
        barHwnd := MyGui ? MyGui.Hwnd : 0
        fgDesk := (fg && fg != barHwnd && PinState(fg) = 0) ? VD("GetWindowDesktopNumber", "Ptr", fg, "Int") : -1
        VD("GoToDesktopNumber", "Int", target)
        ; Mitgenommen waere es hier sichtbar; ein zurueckgelassenes ist "cloaked". Erst dann den
        ; Explorer fragen: direkt nach dem Wechsel kostet jede Rueckfrage dort 150-350 ms.
        if (fgDesk >= 0 && !ZCloaked(fg) && VD("GetWindowDesktopNumber", "Ptr", fg, "Int") != fgDesk)
            VD("MoveWindowToDesktopNumber", "Ptr", fg, "Int", fgDesk)
        ArriveDesk(tid)           ; sofort: Reihenfolge des Ziels, bevor man das Fenster sieht, das Windows gewaehlt hat
    }
    gSwitching := false
    gSelfTick := A_TickCount
    UpdateHighlight(CONF["SwitchMethod"] = "native" ? -1 : target)   ; Ziel ist bekannt: ohne Rueckfrage beim Explorer
}

; Nach einem Wechsel das oberste Fenster des Ziel-Desktops nach vorne holen. Windows laesst
; den Fokus sonst gern an einem unsichtbaren Fenster des alten Desktops haengen; Programme
; mit Fenstern auf mehreren Desktops (Firefox, Chrome) versuchen dann nach vorne zu kommen,
; werden abgewiesen und blinken - samt Taskleisten-Knopf auf fremden Desktops.
; ------------- Fensterreihenfolge je Desktop -------------------------------
; Windows fuehrt EINE Z-Reihenfolge fuer alle Desktops. Ein Fenster, das auf allen Desktops
; liegt und auf Desktop B nach vorne geholt wurde, liegt deshalb auch auf A vorn. DeskTabs
; merkt sich je Desktop, wie seine Fenster uebereinander lagen (alle Monitore, bis 24), und
; setzt das beim Zurueckkommen in EINEM Schritt (DeferWindowPos) wieder ein - nur wenn es
; nicht ohnehin schon stimmt. Positionen und Groessen aendern sich beim Wechsel nicht.
ZCandidate(hwnd) {
    global MyGui, gStripe, gCard, gSP
    if ((MyGui && hwnd = MyGui.Hwnd) || (gStripe && hwnd = gStripe.Hwnd))
        return false
    if ((gCard && hwnd = gCard["gui"].Hwnd) || (gSP && hwnd = gSP["gui"].Hwnd))
        return false
    try {
        if !(WinGetStyle("ahk_id " hwnd) & 0x10000000) || WinGetMinMax("ahk_id " hwnd) = -1
            return false
        ex := WinGetExStyle("ahk_id " hwnd)
        if ((ex & 0x80) && !(ex & 0x40000)) || (ex & 0x08000000)     ; Werkzeug-/Nicht-aktivierbare Fenster
            return false
        if (DllCall("GetWindow", "Ptr", hwnd, "UInt", 4, "Ptr"))         ; Dialog mit Besitzer
            return false
        if (WinGetTitle("ahk_id " hwnd) = "" || InStr(",Shell_TrayWnd,Shell_SecondaryTrayWnd,Progman,WorkerW,", "," WinGetClass("ahk_id " hwnd) ","))
            return false
        return true
    }
    return false
}
; Fenster des aktuellen Desktops (inkl. der auf allen Desktops) in Z-Reihenfolge, oberstes zuerst
ZOrderCurrent(limit := 24) {
    out := []
    for hwnd in WinGetList() {
        if !ZCandidate(hwnd)
            continue
        if (ZCloaked(hwnd) || ZTopmost(hwnd))   ; anderer Desktop (schnell, ohne Explorer) bzw. "immer im Vordergrund"
            continue
        out.Push(hwnd)
        if (out.Length >= limit)
            break
    }
    return out
}
ZSnapCurrent() {
    global gZSnap, gSwitching, gZBlockUntil, gCurrent
    if (gSwitching || !CONF["RestoreZOrder"])
        return
    if (A_TickCount < gZBlockUntil || GetCurrentDesktop() != gCurrent) {
        SetTimer(ZSnapCurrent, -400)          ; Wechsel noch nicht verarbeitet: spaeter nochmal
        return
    }
    id := DesktopGuid(GetCurrentDesktop())
    if (id != "")
        gZSnap[id] := ZOrderCurrent()
}
; Angekommen auf einem Desktop: gemerkte Reihenfolge wiederherstellen, dann Fokus
; Angekommen auf einem Desktop: gemerkte Reihenfolge in einem Schritt einsetzen, Fokus auf das
; oberste. Bewusst schlank (kein Abgleich, keine Fensterabfragen): Windows hat beim Wechsel
; schon ein Fenster nach vorne geholt, je schneller das korrigiert ist, desto weniger sieht man.
; Unveraenderte Reihenfolge einzusetzen aendert sichtbar nichts.
ArriveDesk(id := "") {
    global gZSnap, gZBlockUntil
    SetWinDelay(-1)                           ; ohne die Pause, die AutoHotkey sonst nach WinActivate einlegt
    t0 := A_TickCount
    try ArriveDeskRun(t0, id)
    gZBlockUntil := A_TickCount + 300         ; danach darf wieder gemerkt werden ...
    SetTimer(ZSnapCurrent, -500)              ; ... und der wiederhergestellte Stand wird das neue Abbild
}
; Sichtbares Fenster dieses Desktops (nicht verborgen, nicht minimiert, nicht "immer oben")?
ZVisibleHere(h) {
    if (!DllCall("IsWindowVisible", "Ptr", h) || DllCall("IsIconic", "Ptr", h))
        return false
    if (DllCall("GetWindowLongPtr", "Ptr", h, "Int", -20, "Ptr") & 0x8)   ; WS_EX_TOPMOST (u. a. die Leiste)
        return false
    cloaked := 0
    DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", h, "UInt", 14, "UInt*", &cloaked, "UInt", 4)   ; DWMWA_CLOAKED
    return !cloaked
}
ArriveDeskRun(t0, id := "") {
    global gZSnap
    if (!CONF["RestoreZOrder"])
        return FocusTopWindow()
    if (id = "")
        id := DesktopGuid(GetCurrentDesktop())
    if (id = "" || !gZSnap.Has(id))
        return FocusTopWindow()
    want := [], pos := Map()
    ; was es noch gibt, nicht minimiert ist und noch auf diesem Desktop liegt: ein Fenster, das
    ; inzwischen auf einen anderen Desktop gewandert ist, wuerde beim Fokussieren Windows
    ; dorthin zurueckwechseln lassen (Klick auf Standard sprang so sofort zurueck)
    ; Schnell per DWM: Fenster anderer Desktops sind "cloaked". Keine Rueckfrage beim Explorer:
    ; direkt nach einem Wechsel wartet die erste davon 250-650 ms (gemessen 27.10.2026).
    ; Fenster "immer im Vordergrund" nie einsortieren: wer hinter ein solches gelegt wird, wird
    ; laut Windows selbst "immer im Vordergrund" (so wurden am 27.10.2026 alle Fenster topmost)
    for hwnd in gZSnap[id]
        if (DllCall("IsWindow", "Ptr", hwnd) && !DllCall("IsIconic", "Ptr", hwnd) && !ZCloaked(hwnd) && !ZTopmost(hwnd))
            want.Push(hwnd), pos[hwnd] := want.Length
    if (!want.Length)
        return FocusTopWindow()
    fg0 := DllCall("GetForegroundWindow", "Ptr")
    ; Wie tief muss eingegriffen werden? Von oben durch die Z-Reihenfolge gehen: jedes gemerkte
    ; Fenster, das nicht an seiner Stelle liegt oder ueber dem ein fremdes sichtbares liegt,
    ; muss mit allem darueber neu einsortiert werden. Meist sind das zwei, drei Fenster.
    need := 0, stranger := false, found := 0
    h := DllCall("GetTopWindow", "Ptr", 0, "Ptr")
    while (h && found < want.Length) {
        if (pos.Has(h)) {
            found++                           ; das wievielte gemerkte Fenster von oben
            if (pos[h] != found || stranger)
                need := Max(need, pos[h], found)
        } else if (!stranger && ZVisibleHere(h) && ZCandidate(h))
            stranger := true                  ; ab hier liegt ein fremdes Fenster ueber gemerkten
        h := DllCall("GetWindow", "Ptr", h, "UInt", 2, "Ptr")   ; GW_HWNDNEXT
    }
    need := Min(need, 10)                     ; mehr als die obersten zehn sieht man nicht; jedes kostet ~8 ms
    if (need) {
        hdwp := DllCall("BeginDeferWindowPos", "Int", need, "Ptr")
        after := 0                            ; HWND_TOP fuer das oberste, dann jeweils darunter
        Loop need {
            h := want[A_Index]
            if (hdwp)
                hdwp := DllCall("DeferWindowPos", "Ptr", hdwp, "Ptr", h, "Ptr", after
                    , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0213, "Ptr")   ; NOSIZE|NOMOVE|NOACTIVATE|NOOWNERZORDER
            after := h
        }
        if (hdwp)
            DllCall("EndDeferWindowPos", "Ptr", hdwp)
    }
    if (DllCall("GetForegroundWindow", "Ptr") != want[1])        ; want[] ist schon auf "nicht cloaked" gefiltert
        if !DllCall("SetForegroundWindow", "Ptr", want[1])
            try WinActivate("ahk_id " want[1])
}
ZTopmost(h) => (DllCall("GetWindowLongPtr", "Ptr", h, "Int", -20, "Ptr") & 0x8) != 0   ; WS_EX_TOPMOST
ZCloaked(h) {
    cloaked := 0
    DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", h, "UInt", 14, "UInt*", &cloaked, "UInt", 4)   ; DWMWA_CLOAKED
    return cloaked != 0
}

FocusTopWindow() {
    global MyGui, gStripe
    fg := DllCall("GetForegroundWindow", "Ptr")
    if (fg && (!MyGui || fg != MyGui.Hwnd)) {
        onCur := 0
        try onCur := VD("IsWindowOnCurrentVirtualDesktop", "Ptr", fg, "Int")
        if (onCur = 1 && !VD("IsPinnedWindow", "Ptr", fg, "Int"))
            return                        ; Fokus liegt schon auf einem Fenster dieses Desktops
    }
    for hwnd in WinGetList() {            ; Z-Reihenfolge, oberstes zuerst
        if ((MyGui && hwnd = MyGui.Hwnd) || (gStripe && hwnd = gStripe.Hwnd))
            continue
        try {
            if !(WinGetStyle("ahk_id " hwnd) & 0x10000000) || WinGetMinMax("ahk_id " hwnd) = -1
                continue
            ex := WinGetExStyle("ahk_id " hwnd)
            if ((ex & 0x80) && !(ex & 0x40000)) || (ex & 0x08000000)     ; Werkzeug-/Nicht-aktivierbare Fenster
                continue
            if (DllCall("GetWindow", "Ptr", hwnd, "UInt", 4, "Ptr"))         ; Dialog mit Besitzer
                continue
            if (WinGetTitle("ahk_id " hwnd) = "" || InStr(",Shell_TrayWnd,Shell_SecondaryTrayWnd,Progman,WorkerW,", "," WinGetClass("ahk_id " hwnd) ","))
                continue
            if (VD("IsWindowOnCurrentVirtualDesktop", "Ptr", hwnd, "Int") != 1 || VD("IsPinnedWindow", "Ptr", hwnd, "Int") = 1)
                continue
            WinActivate("ahk_id " hwnd)
            return
        }
    }
}

; ---- Fensteranordnungen: benannte Schnappschuesse der Fenster eines Desktops ----
; [WindowSets] <Desktop>=<Name>{GS}<exe>{US}<Titel>{US}<hwnd>{RS}<...>{SEP}<Name>{GS}...
; (Trennzeichen U+241D/U+241C/U+241E/U+241F, die in Titeln nicht vorkommen). Der Knopf rechts
; neben den Tabs holt die Fenster einer Anordnung in der gemerkten Reihenfolge nach vorne;
; Position und Groesse bleiben, wie sie sind. "Aufraeumen" setzt sie je Bildschirm buendig
; nebeneinander, gleich breit, volle Hoehe. Fenster erkennt DeskTabs an der Kennung, sonst
; an Programm und Titel (Claude-Chatfenster tragen den Chatnamen).
SetSep(k) => Chr([0x241D, 0x241C, 0x241E, 0x241F][k])
SetClean(s) => RegExReplace(s, "[\x{241C}-\x{241F}\r\n]", " ")
SetsLoad(desk) {
    out := []
    for , s in StrSplit(IniLookup("WindowSets", desk), SetSep(1)) {
        p := InStr(s, SetSep(2))
        if (!p)
            continue
        wins := []
        for , w in StrSplit(SubStr(s, p + 1), SetSep(3)) {
            f := StrSplit(w, SetSep(4))
            if (f.Length < 2)
                continue
            h := 0
            try h := (f.Length >= 3 && f[3] != "") ? Integer("0x" f[3]) : 0
            wins.Push(Map("exe", f[1], "title", f[2], "hwnd", h))
        }
        out.Push(Map("name", SubStr(s, 1, p - 1), "wins", wins))
    }
    return out
}
SetsSave(desk, sets) {
    parts := []
    for s in sets {
        ws := ""
        for w in s["wins"]
            ws .= (ws = "" ? "" : SetSep(3)) w["exe"] SetSep(4) w["title"] SetSep(4) Format("{:X}", w["hwnd"])
        parts.Push(s["name"] SetSep(2) ws)
    }
    v := ""
    for p in parts
        v .= (v = "" ? "" : SetSep(1)) p
    if (v = "")
        IniDelLoose("WindowSets", desk)
    else
        IniSet("WindowSets", desk, v)
}
SetsAny() {
    for k, v in ReadIniSection("WindowSets")
        if (v != "")
            return true
    return false
}
; Platz (1..n) der Anordnungs-Kachel unter lx, sonst 0
SetAt(lx) {
    global gLayout
    if (!gLayout || !gLayout.Has("setW") || !gLayout["setW"] || lx < gLayout["setX"] || lx >= gLayout["setX"] + gLayout["setW"])
        return 0
    return (lx - gLayout["setX"]) // gLayout["btnH"] + 1
}
SetNameAt(i) {                                   ; aus dem Stand beim Aufbau der Leiste (ohne Rueckfrage beim Explorer)
    global gSetNames, gCurrent
    names := gSetNames.Has(gCurrent) ? gSetNames[gCurrent] : []
    return (i >= 1 && i <= names.Length) ? names[i] : ""
}
; zwei Zeichen fuer die Kachel: Anfangsbuchstaben der ersten zwei Woerter, sonst die ersten zwei
SetInitials(name) {
    w := StrSplit(Trim(RegExReplace(name, "[^\p{L}\p{N} ]", " ")), " ", " ")
    out := ""
    for x in w
        if (x != "" && StrLen(out) < 2)
            out .= SubStr(x, 1, 1)
    if (StrLen(out) < 2 && w.Length)
        out := SubStr(w[1], 1, 2)
    return StrUpper(out)
}
SetHoverTip(i) {
    ToolTip(, , , 5)
    name := i ? SetNameAt(i) : ""
    if (name != "")
        ToolTip(name "`n" T("set.tip"), , , 5), SetTimer(() => ToolTip(, , , 5), -3000)
}
; sichtbare Fenster dieses Desktops in Stapelreihenfolge, oberstes zuerst: ohne minimierte, ohne
; "immer im Vordergrund" und ohne Fenster, die kaum zu sehen sind (weniger als die Haelfte UND
; weniger als ein Fuenftel ihres Bildschirms: ein Streifen eines Mailprogramms hinter den Chats). Sichtbar = sein
; Rahmen minus die Rahmen aller hoeheren Fenster (GDI-Regionen, echte Pixel je Monitor).
SetCapture() {
    wins := []
    old := DllCall("SetThreadDpiAwarenessContext", "Ptr", -4, "Ptr")
    above := DllCall("CreateRectRgn", "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr")
    rest := DllCall("CreateRectRgn", "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr")
    for hwnd in ZOrderCurrent(24) {
        fr := SetFrame(hwnd)
        rg := DllCall("CreateRectRgn", "Int", fr[1], "Int", fr[2], "Int", fr[3], "Int", fr[4], "Ptr")
        vis := DllCall("CombineRgn", "Ptr", rest, "Ptr", rg, "Ptr", above, "Int", 4) > 1   ; RGN_DIFF: mehr als NULLREGION
        full := (fr[3] - fr[1]) * (fr[4] - fr[2])
        if (vis && full > 0) {
            seen := RgnArea(rest)
            ; mitgenommen wird, was zur Haelfte zu sehen ist ODER sichtbar ein Fuenftel seines
            ; Bildschirms fuellt (ein Vollbild-Notion hinter zwei Chats: ein Drittel zu sehen, gehoert dazu)
            if (seen * 2 < full && seen * 5 < MonArea(hwnd))
                vis := false
        }
        DllCall("CombineRgn", "Ptr", above, "Ptr", above, "Ptr", rg, "Int", 2)           ; RGN_OR
        DllCall("DeleteObject", "Ptr", rg)
        if (!vis)
            continue
        exe := "", title := ""
        try exe := WinGetProcessName("ahk_id " hwnd), title := WinGetTitle("ahk_id " hwnd)
        if (exe != "")
            wins.Push(Map("exe", exe, "title", SetClean(title), "hwnd", hwnd))
    }
    DllCall("DeleteObject", "Ptr", above), DllCall("DeleteObject", "Ptr", rest)
    DllCall("SetThreadDpiAwarenessContext", "Ptr", old, "Ptr")
    return wins
}
SetFind(w, used) {
    h := w["hwnd"]
    if (h && !used.Has(h) && DllCall("IsWindow", "Ptr", h) && !ZCloaked(h)) {
        exe := ""
        try exe := WinGetProcessName("ahk_id " h)
        if (exe = w["exe"])
            return h
    }
    try for h2 in WinGetList("ahk_exe " w["exe"]) {
        if (used.Has(h2) || ZCloaked(h2))
            continue
        t := ""
        try t := WinGetTitle("ahk_id " h2)
        if (SetClean(t) = w["title"])
            return h2
    }
    return 0
}
SetGet(name, &desk := "", &num := 0) {
    num := GetCurrentDesktop(), desk := GetDesktopNameRaw(num)
    for s in SetsLoad(desk)
        if (s["name"] = name)
            return s
    return 0
}
SetFound(set) {
    found := [], used := Map()
    for w in set["wins"]
        if (h := SetFind(w, used))
            found.Push(h), used[h] := true
    ; Claude-Code-Funktionen: dazu alle Claude-Chats dieses Desktops mit demselben Kuerzel
    ; (umbenannte und neue Chats gehoeren so automatisch zur Anordnung)
    if (CONF["ClaudeCode"]) {
        tags := Map()
        for w in set["wins"]
            if (w["exe"] = "claude.exe" && RegExMatch(w["title"], "\[([^\]]+)\]", &m))
                tags[m[1]] := true
        for tg in tags
            for h in ClaudeWins(tg)
                if (!used.Has(h) && !ZCloaked(h))
                    found.Push(h), used[h] := true
    }
    return found
}
; Klick auf eine Kachel: nach vorne holen; Umschalt + Klick: aktuellen Stand als neue Anordnung
; dieser Kachel speichern. Leerer Platz: Menue zum Speichern.
SetClick(i, shift := false, ctrl := false) {
    name := SetNameAt(i)
    if (name = "")
        return SetMenu(i)
    if (shift)
        return SetOverwrite(name)
    if (ctrl)
        return SetTidy(name)
    SetRestore(name)
}
; Rechtsklick: Menue der Kachel (bzw. nur "speichern" auf einem leeren Platz)
SetMenu(i := 0) {
    name := SetNameAt(i)
    m := Menu()
    if (name != "") {
        m.Add(T("menu.set.front", name), SetRestore.Bind(name))
        MenuGlyph(m, T("menu.set.front", name), "E8A9")
        m.Default := T("menu.set.front", name)
        m.Add(T("menu.set.overwrite"), SetOverwrite.Bind(name))
        MenuGlyph(m, T("menu.set.overwrite"), "E72C")
        m.Add(T("menu.set.pick"), SetPickDialog.Bind(name))
        MenuGlyph(m, T("menu.set.pick"), "E762")
        m.Add(T("menu.set.tidy"), SetTidy.Bind(name))
        MenuGlyph(m, T("menu.set.tidy"), "E8A1")
        if (CONF["ClaudeCode"]) {
            m.Add(T("menu.set.even"), SetEven.Bind(name))
            MenuGlyph(m, T("menu.set.even"), ClaudeGlyph())
        }
        m.Add(T("menu.set.rename"), SetRenameAsk.Bind(name))
        MenuGlyph(m, T("menu.set.rename"), "E70F")
        m.Add(T("menu.set.delete"), SetDeleteAsk.Bind(name))
        MenuGlyph(m, T("menu.set.delete"), "E74D")
        m.Add()
    }
    m.Add(T("menu.set.save"), SetSaveAsk)
    MenuGlyph(m, T("menu.set.save"), "E710")
    m.Show()
}
; Neue Anordnung: Schnappschuss aller gerade sichtbaren Fenster, nur der Name wird gefragt
; (ausschliessen laesst sich spaeter ueber "Fenster auswaehlen...")
SetSaveAsk(*) {
    num := GetCurrentDesktop(), desk := GetDesktopNameRaw(num)
    wins := SetCapture()
    if (!wins.Length)
        return MsgBox(T("set.none"), "DeskTabs", "Iconi")
    sets := SetsLoad(desk)
    ib := InputBox(T("set.nameq", wins.Length, desk), T("set.title"), "w440 h140", T("set.defname", sets.Length + 1))
    name := SetClean(Trim(ib.Value))
    if (ib.Result != "OK" || name = "")
        return
    done := false
    for i, s in sets
        if (s["name"] = name)
            sets[i] := Map("name", name, "wins", wins), done := true
    if (!done)
        sets.Push(Map("name", name, "wins", wins))
    SetsSave(desk, sets)
    RebuildAll()
    ToastShow(num, T("set.saved", name, wins.Length), 0xE8A9)
}
; Auswahl, welche sichtbaren Fenster zur Anordnung gehoeren: Name oben, darunter alle
; sichtbaren Fenster dieses Desktops zum Anhaken (oberstes zuerst). name = "" -> neue Anordnung.
SetPickDialog(name := "", *) {
    global gSetPick
    num := GetCurrentDesktop(), desk := GetDesktopNameRaw(num)
    wins := SetCapture()
    if (!wins.Length)
        return MsgBox(T("set.none"), "DeskTabs", "Iconi")
    sets := SetsLoad(desk), cur := 0
    for s in sets
        if (s["name"] = name)
            cur := s
    ; vorausgewaehlt: bei einer bestehenden Anordnung ihre Fenster, sonst die Fenster
    ; desselben Programms wie das oberste (meist genau die, die man gerade angeordnet hat)
    pre := Map()
    if (cur) {
        used := Map()
        for w in cur["wins"]
            if (h := SetFind(w, used))
                used[h] := true, pre[h] := true
    } else
        for w in wins
            if (w["exe"] = wins[1]["exe"])
                pre[w["hwnd"]] := true
    try gSetPick.Destroy()
    g := Gui("+AlwaysOnTop -MinimizeBox -MaximizeBox", T("set.title"))
    gSetPick := g
    g.SetFont("s10", "Segoe UI")
    g.MarginX := 20, g.MarginY := 16
    g.Add("Text", "xm w560", T("set.pickname", desk))
    ed := g.Add("Edit", "xm y+6 w560 r1", cur ? name : T("set.defname", sets.Length + 1))
    g.Add("Text", "xm y+14 w560", T("set.picklist"))
    lv := g.Add("ListView", "xm y+6 w560 r12 Checked -Multi NoSortHdr", [T("set.col.title"), T("set.col.exe")])
    for w in wins
        lv.Add(pre.Has(w["hwnd"]) ? "Check" : "", w["title"], RegExReplace(w["exe"], "i)\.exe$"))
    lv.ModifyCol(1, 400), lv.ModifyCol(2, 130)
    ok := g.Add("Button", "xm y+16 w130 Default", T("timer.note.save"))
    no := g.Add("Button", "x+10 yp w130", T("set.cancel"))
    ok.OnEvent("Click", Save)
    no.OnEvent("Click", (*) => g.Destroy())
    g.OnEvent("Escape", (*) => g.Destroy())
    SetGuiIcon(g)
    g.Show("AutoSize Center")
    ed.Focus()

    Save(*) {
        nn := SetClean(Trim(ed.Value))
        if (nn = "")
            return
        picked := [], row := 0
        while (row := lv.GetNext(row, "Checked"))
            picked.Push(wins[row])
        if (!picked.Length)
            return
        g.Destroy()
        out := [], placed := false
        for s in SetsLoad(desk) {
            if (s["name"] = name && name != "") {           ; bestehende Anordnung (evtl. umbenannt)
                out.Push(Map("name", nn, "wins", picked)), placed := true
            } else if (s["name"] = nn) {                     ; gleicher Name: ersetzen
                if (!placed)
                    out.Push(Map("name", nn, "wins", picked)), placed := true
            } else
                out.Push(s)
        }
        if (!placed)
            out.Push(Map("name", nn, "wins", picked))
        SetsSave(desk, out)
        RebuildAll()
        ToastShow(num, T("set.saved", nn, picked.Length), 0xE8A9)
    }
}

; Umschalt + Klick: Schnappschuss neu, alles, was jetzt sichtbar ist, in seiner Stapelreihenfolge
SetOverwrite(name, *) {
    num := GetCurrentDesktop(), desk := GetDesktopNameRaw(num)
    wins := SetCapture()
    if (!wins.Length)
        return MsgBox(T("set.none"), "DeskTabs", "Iconi")
    sets := SetsLoad(desk)
    for i, s in sets
        if (s["name"] = name)
            sets[i]["wins"] := wins
    SetsSave(desk, sets)
    ToastShow(num, T("set.updated", name, wins.Length), 0xE72C)
}
SetRenameAsk(name, *) {
    desk := GetDesktopNameRaw(GetCurrentDesktop())
    ib := InputBox(T("set.renameq", name), T("set.title"), "w420 h130", name)
    nn := SetClean(Trim(ib.Value))
    if (ib.Result != "OK" || nn = "" || nn == name)
        return
    sets := SetsLoad(desk), out := []
    for s in sets
        if (s["name"] = name)
            s["name"] := nn, out.Push(s)
        else if (s["name"] != nn)
            out.Push(s)
    SetsSave(desk, out)
    RebuildAll()
}
SetDeleteAsk(name, *) {
    desk := GetDesktopNameRaw(GetCurrentDesktop())
    if (MsgBox(T("set.deleteq", name), "DeskTabs", "YesNo Icon? Default2") != "Yes")
        return
    out := []
    for s in SetsLoad(desk)
        if (s["name"] != name)
            out.Push(s)
    SetsSave(desk, out)
    RebuildAll()
}
; Fenster der Anordnung nach vorne: von unten nach oben jeweils ganz nach oben, minimierte
; ohne Aktivieren zurueck, zuletzt das oberste in den Vordergrund. HWND_TOP macht nichts
; "immer im Vordergrund" (anders als ein Einsortieren hinter ein solches Fenster).
SetRestore(name, *) {
    set := SetGet(name, &desk, &num)
    if (!set)
        return
    found := SetFound(set)
    if (!found.Length)
        return ToastShow(num, T("set.nonefound", name), 0xE8A9)
    ; Die Leiste ist nie im Vordergrund (sie soll dem Arbeitsfenster den Fokus nicht nehmen),
    ; deshalb ignoriert Windows ein blosses Nach-oben-Schieben anderer Fenster gern. WinActivate
    ; setzt sich ueber diese Sperre hinweg: jedes Fenster von unten nach oben einmal aktivieren.
    SetWinDelay(-1)
    i := found.Length
    while (i >= 1) {
        try WinActivate("ahk_id " found[i])
        i--
    }
    if (found.Length < set["wins"].Length)
        ToastShow(num, T("set.partial", name, found.Length, set["wins"].Length), 0xE8A9)
}
; Buendig ausrichten: nur die letzten Pixel Handarbeit. Die Fenster liegen schon grob, wo sie
; hin sollen; jede Kante rueckt hoechstens um TIDY_TOL der Bildschirmbreite bzw. -hoehe:
; an den Rand des Arbeitsbereichs, wenn sie so nah dran ist, und an die gegenueberliegende
; Kante eines Nachbarfensters (Spalt oder Ueberlappung, beide treffen sich in der Mitte).
; Alles, was weiter weg ist, bleibt, wie es ist. Maximierte, minimierte und zu mehr als der
; Haelfte von anderen Fenstern der Anordnung verdeckte Fenster (etwa ein breites Fenster im
; Hintergrund) fasst es nicht an. Gerechnet wird mit dem sichtbaren Rahmen
; (DWMWA_EXTENDED_FRAME_BOUNDS), in echten Pixeln je Bildschirm.
SetTidy(name, *) {
    static TIDY_TOL := 0.05
    set := SetGet(name, &desk, &num)
    if (!set)
        return
    found := SetFound(set)
    if (!found.Length)
        return ToastShow(num, T("set.nonefound", name), 0xE8A9)
    old := DllCall("SetThreadDpiAwarenessContext", "Ptr", -4, "Ptr")   ; PER_MONITOR_AWARE_V2
    cnt := 0, mons := Map()
    try {
        items := [], above := DllCall("CreateRectRgn", "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr")
        for h in found {                                            ; found[1] liegt oben
            fr := SetFrame(h)
            rg := DllCall("CreateRectRgn", "Int", fr[1], "Int", fr[2], "Int", fr[3], "Int", fr[4], "Ptr")
            vis := DllCall("CreateRectRgn", "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr")
            DllCall("CombineRgn", "Ptr", vis, "Ptr", rg, "Ptr", above, "Int", 4)      ; RGN_DIFF
            va := RgnArea(vis), fa := (fr[3] - fr[1]) * (fr[4] - fr[2])
            DllCall("CombineRgn", "Ptr", above, "Ptr", above, "Ptr", rg, "Int", 2)    ; RGN_OR
            DllCall("DeleteObject", "Ptr", rg), DllCall("DeleteObject", "Ptr", vis)
            if (DllCall("IsZoomed", "Ptr", h) || DllCall("IsIconic", "Ptr", h) || fa <= 0 || va < fa / 2)
                continue
            mon := DllCall("MonitorFromWindow", "Ptr", h, "UInt", 2, "Ptr")
            mi := Buffer(40, 0), NumPut("UInt", 40, mi)
            DllCall("GetMonitorInfo", "Ptr", mon, "Ptr", mi)
            wl := NumGet(mi, 20, "Int"), wt := NumGet(mi, 24, "Int"), wr := NumGet(mi, 28, "Int"), wb := NumGet(mi, 32, "Int")
            items.Push({h: h, mon: mon, l: fr[1], t: fr[2], r: fr[3], b: fr[4]
                , nl: fr[1], nt: fr[2], nr: fr[3], nb: fr[4]
                , wl: wl, wt: wt, wr: wr, wb: wb, tx: (wr - wl) * TIDY_TOL, ty: (wb - wt) * TIDY_TOL})
        }
        DllCall("DeleteObject", "Ptr", above)
        for a in items {                                            ; an den Rand des Arbeitsbereichs
            if (Abs(a.l - a.wl) <= a.tx)
                a.nl := a.wl
            if (Abs(a.r - a.wr) <= a.tx)
                a.nr := a.wr
            if (Abs(a.t - a.wt) <= a.ty)
                a.nt := a.wt
            if (Abs(a.b - a.wb) <= a.ty)
                a.nb := a.wb
        }
        usedL := Map(), usedT := Map()
        for a in items {                                            ; rechte an linke, untere an obere Kante
            bx := 0, dx := a.tx + 1, by := 0, dy := a.ty + 1
            for b in items {
                if (b = a || b.mon != a.mon)
                    continue
                if (!usedL.Has(b.h) && Abs(a.r - b.l) < dx && Min(a.b, b.b) - Max(a.t, b.t) > Min(a.b - a.t, b.b - b.t) / 2)
                    bx := b, dx := Abs(a.r - b.l)
                if (!usedT.Has(b.h) && Abs(a.b - b.t) < dy && Min(a.r, b.r) - Max(a.l, b.l) > Min(a.r - a.l, b.r - b.l) / 2)
                    by := b, dy := Abs(a.b - b.t)
            }
            if (bx)
                m := Round((a.r + bx.l) / 2), a.nr := m, bx.nl := m, usedL[bx.h] := true
            if (by)
                m := Round((a.b + by.t) / 2), a.nb := m, by.nt := m, usedT[by.h] := true
        }
        for a in items {
            if (a.nl = a.l && a.nt = a.t && a.nr = a.r && a.nb = a.b)
                continue
            wrc := Buffer(16, 0)
            DllCall("GetWindowRect", "Ptr", a.h, "Ptr", wrc)
            dl := a.l - NumGet(wrc, 0, "Int"), dt := a.t - NumGet(wrc, 4, "Int")
            dr := NumGet(wrc, 8, "Int") - a.r, db := NumGet(wrc, 12, "Int") - a.b
            DllCall("SetWindowPos", "Ptr", a.h, "Ptr", 0, "Int", a.nl - dl, "Int", a.nt - dt
                , "Int", (a.nr - a.nl) + dl + dr, "Int", (a.nb - a.nt) + dt + db, "UInt", 0x0214)   ; NOZORDER|NOACTIVATE
            cnt++, mons[a.mon] := true
        }
    }
    DllCall("SetThreadDpiAwarenessContext", "Ptr", old, "Ptr")
    SetRestore(name)
    if (!cnt)
        return ToastShow(num, T("set.tidynone", name), 0xE8A1)
    ToastShow(num, T("set.tidied", name, cnt, mons.Count), 0xE8A1)
}
; Gleich breit verteilen (nur mit Claude-Code-Funktionen): die Claude-Fenster der Anordnung grob in
; die gewuenschte Reihenfolge ziehen (uebereinander = halbe Hoehe), TileEven macht den Rest.
; Andere Programme, Vollbild-Fenster (maximiert oder fast bildschirmgross) und minimierte
; bleiben, wie sie sind.
SetEven(name, *) {
    set := SetGet(name, &desk, &num)
    if (!set)
        return
    found := SetFound(set)
    if (!found.Length)
        return ToastShow(num, T("set.nonefound", name), 0xE8A9)
    cl := []                                                    ; nur die Claude-Fenster
    for h in found
        try if (WinGetProcessName("ahk_id " h) = "claude.exe")
            cl.Push(h)
    cnt := TileEven(SetNotFull(cl), false, &mc)
    SetRestore(name)
    ToastShow(num, T("set.evened", name, cnt, mc), 0xECA5)
}
; die Fenster aus der Liste, die weder minimiert noch maximiert sind und nicht mindestens
; 90 % von Breite und Hoehe des Arbeitsbereichs ihres Bildschirms bedecken
SetNotFull(list) {
    out := []
    old := DllCall("SetThreadDpiAwarenessContext", "Ptr", -4, "Ptr")
    for h in list {
        if (DllCall("IsZoomed", "Ptr", h) || DllCall("IsIconic", "Ptr", h))
            continue
        mi := Buffer(40, 0), NumPut("UInt", 40, mi)
        DllCall("GetMonitorInfo", "Ptr", DllCall("MonitorFromWindow", "Ptr", h, "UInt", 2, "Ptr"), "Ptr", mi)
        fr := SetFrame(h)
        if (fr[3] - fr[1] >= (NumGet(mi, 28, "Int") - NumGet(mi, 20, "Int")) * 0.9
            && fr[4] - fr[2] >= (NumGet(mi, 32, "Int") - NumGet(mi, 24, "Int")) * 0.9)
            continue
        out.Push(h)
    }
    DllCall("SetThreadDpiAwarenessContext", "Ptr", old, "Ptr")
    return out
}
; Gleich verteilen, je Bildschirm dort, wo die Fenster gerade liegen: Fenster, die sich
; waagerecht zur Haelfte decken, bilden eine Spalte und liegen uebereinander (gleich hoch),
; die Spalten bekommen von links nach rechts gleich viel Breite, volle Hoehe, buendig.
; Je Bildschirm passen hoechstens so viele Spalten, wie TILE_MINW (Pixel bei 100 %) breit
; sind (3440 -> 5, 2560 -> 3, 1920 -> 2); sind es mehr, werden die beiden schmalsten
; Nachbarspalten (von rechts) zusammengelegt, ihre Fenster also uebereinander gestapelt.
; force: maximierte/minimierte Fenster erst normal machen statt sie auszulassen.
; Rueckgabe: Zahl der verteilten Fenster, &mc: Zahl der Bildschirme
TileEven(list, force, &mc := 0) {
    static TILE_MINW := 660
    old := DllCall("SetThreadDpiAwarenessContext", "Ptr", -4, "Ptr")   ; PER_MONITOR_AWARE_V2
    mons := Map(), order := [], cnt := 0
    try {
        for h in list {
            if (DllCall("IsIconic", "Ptr", h) || DllCall("IsZoomed", "Ptr", h)) {
                if (!force)
                    continue
                DllCall("ShowWindow", "Ptr", h, "Int", 4)          ; SW_SHOWNOACTIVATE: erst normal
            }
            mon := DllCall("MonitorFromWindow", "Ptr", h, "UInt", 2, "Ptr")
            if (!mons.Has(mon))
                mons[mon] := [], order.Push(mon)
            fr := SetFrame(h)
            mons[mon].Push({h: h, l: fr[1], t: fr[2], r: fr[3], b: fr[4]})
        }
        for mon in order {
            items := mons[mon]
            Loop items.Length - 1 {                                 ; nach linker Kante sortieren
                j := A_Index + 1
                while (j > 1 && items[j].l < items[j - 1].l)
                    t0 := items[j], items[j] := items[j - 1], items[j - 1] := t0, j--
            }
            cols := []                                              ; Spalten: {l, r, wins}
            for it in items {
                hit := 0
                for c in cols
                    if (Min(c.r, it.r) - Max(c.l, it.l) >= Min(c.r - c.l, it.r - it.l) / 2) {
                        hit := c
                        break
                    }
                if (hit)
                    hit.wins.Push(it)
                else
                    cols.Push({l: it.l, r: it.r, wins: [it]})
            }
            for c in cols {                                         ; in der Spalte von oben nach unten
                w := c.wins
                Loop w.Length - 1 {
                    j := A_Index + 1
                    while (j > 1 && w[j].t < w[j - 1].t)
                        t0 := w[j], w[j] := w[j - 1], w[j - 1] := t0, j--
                }
            }
            mi := Buffer(40, 0), NumPut("UInt", 40, mi)
            DllCall("GetMonitorInfo", "Ptr", mon, "Ptr", mi)
            wl := NumGet(mi, 20, "Int"), wt := NumGet(mi, 24, "Int"), wr := NumGet(mi, 28, "Int"), wb := NumGet(mi, 32, "Int")
            dpi := 96, dpy := 96
            try DllCall("shcore\GetDpiForMonitor", "Ptr", mon, "Int", 0, "UInt*", &dpi, "UInt*", &dpy)
            maxc := Max(1, Floor((wr - wl) * 96 / dpi / TILE_MINW))
            while (cols.Length > maxc) {                            ; zu viele: Nachbarn stapeln
                bi := 0, bn := 0
                Loop cols.Length - 1 {
                    i := cols.Length - A_Index                      ; von rechts
                    n := cols[i].wins.Length + cols[i + 1].wins.Length
                    if (!bi || n < bn)
                        bi := i, bn := n
                }
                for it in cols[bi + 1].wins
                    cols[bi].wins.Push(it)
                cols[bi].r := cols[bi + 1].r
                cols.RemoveAt(bi + 1)
            }
            nc := cols.Length
            for ci, c in cols {
                x0 := wl + Round((wr - wl) * (ci - 1) / nc), x1 := wl + Round((wr - wl) * ci / nc)
                nr := c.wins.Length
                for ri, it in c.wins {
                    y0 := wt + Round((wb - wt) * (ri - 1) / nr), y1 := wt + Round((wb - wt) * ri / nr)
                    fr := SetFrame(it.h), wrc := Buffer(16, 0)
                    DllCall("GetWindowRect", "Ptr", it.h, "Ptr", wrc)
                    dl := fr[1] - NumGet(wrc, 0, "Int"), dt := fr[2] - NumGet(wrc, 4, "Int")
                    dr := NumGet(wrc, 8, "Int") - fr[3], db := NumGet(wrc, 12, "Int") - fr[4]
                    DllCall("SetWindowPos", "Ptr", it.h, "Ptr", 0, "Int", x0 - dl, "Int", y0 - dt
                        , "Int", (x1 - x0) + dl + dr, "Int", (y1 - y0) + dt + db, "UInt", 0x0214)   ; NOZORDER|NOACTIVATE
                    cnt++
                }
            }
        }
    }
    DllCall("SetThreadDpiAwarenessContext", "Ptr", old, "Ptr")
    mc := mons.Count
    return cnt
}

; ---------------------------- Claude-Code-Funktionen ----------------------------
; Abschaltbar (Weitere Einstellungen, Standard aus). Die Chat-Fenster der Claude-App tragen
; den Projektkuerzel in eckigen Klammern im Titel, z. B. "🧭 [ACME] 1. Website"; daran
; erkennt DeskTabs sie, auch nach dem Umbenennen und bei neuen Chats.
; Kuerzel eines Desktops: [ClaudeTags] in settings.ini, sonst das haeufigste Kuerzel der
; Claude-Fenster in seinen Anordnungen, sonst der Desktop-Name
; Menue-Symbol der Claude-Funktionen: das Icon der Claude-App (Pfad aus einem laufenden
; Claude-Fenster), sonst ein Symbol aus der Schrift
ClaudeGlyph() {
    static path := ""
    if (path = "") {
        dhw := A_DetectHiddenWindows
        DetectHiddenWindows(true)
        try for h in WinGetList("ahk_exe claude.exe")
            if (path := ProcessGetPath(WinGetPID(h)))
                break
        DetectHiddenWindows(dhw)
    }
    return path != "" ? "ico:" path : "ECA5"
}
; Icon einer Programmdatei in Groesse sz (je Pfad und Groesse einmal geladen); 0 = keins
OdExeIcon(path, sz) {
    static cache := Map()
    k := path "|" sz
    if (!cache.Has(k)) {
        hi := 0
        try hi := LoadPicture(path, "w" sz " h" sz " Icon1", &ty)
        cache[k] := hi
    }
    return cache[k]
}
ClaudeTag(desk) {
    v := IniLookup("ClaudeTags", desk)
    if (v != "")
        return v
    cnt := Map(), best := "", bn := 0
    for s in SetsLoad(desk)
        for w in s["wins"]
            if (w["exe"] = "claude.exe" && RegExMatch(w["title"], "\[([^\]]+)\]", &m))
                cnt[m[1]] := (cnt.Has(m[1]) ? cnt[m[1]] : 0) + 1
    for k, n in cnt
        if (n > bn)
            best := k, bn := n
    return best != "" ? best : desk
}
; alle Chat-Fenster der Claude-App mit [tag] im Titel, auf allen Desktops
ClaudeWins(tag) {
    out := [], dhw := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    try for h in WinGetList("ahk_exe claude.exe") {
        if (!(WinGetStyle(h) & 0x10000000) || DllCall("GetWindow", "Ptr", h, "UInt", 4, "Ptr"))
            continue                                                ; unsichtbar oder Unterfenster
        if (InStr(WinGetTitle(h), "[" tag "]"))
            out.Push(h)
    }
    DetectHiddenWindows(dhw)
    return out
}
; Desktop zu einem Kuerzel (oder Desktop-Namen); -1 = keiner
ClaudeDeskFor(tag) {
    Loop GetDesktopCount() {
        nm := GetDesktopNameRaw(A_Index - 1)
        if (nm = tag || ClaudeTag(nm) = tag)
            return A_Index - 1
    }
    return -1
}
; Alle Claude-Fenster des Projekts auf Desktop num holen, gleich breit verteilen und, wenn
; es der aktuelle Desktop ist, nach vorne holen. Rueckgabe: Bericht fuer die Schnittstelle
ClaudeGather(num, *) {
    desk := GetDesktopNameRaw(num), tag := ClaudeTag(desk)
    wins := ClaudeWins(tag)
    if (!wins.Length) {
        ToastShow(num, T("claude.none", tag), 0xE8A9)
        return "error: no Claude windows with [" tag "]"
    }
    moved := 0
    for h in wins
        if (VD("GetWindowDesktopNumber", "Ptr", h, "Int") != num)
            VD("MoveWindowToDesktopNumber", "Ptr", h, "Int", num), moved++
    TileEven(wins, true, &mc)
    if (num = GetCurrentDesktop()) {
        SetWinDelay(-1)
        for h in wins
            try WinActivate("ahk_id " h)
    }
    ToastShow(num, T("claude.gathered", wins.Length, tag, moved), 0xECA5)
    rep := "ok: " wins.Length " windows [" tag "] on desktop " (num + 1) " (" desk "), " moved " moved here`n"
    for h in wins
        rep .= WinGetTitle("ahk_id " h) "`n"
    return rep
}
ClaudeTagAsk(num, *) {
    desk := GetDesktopNameRaw(num)
    ib := InputBox(T("claude.tagq"), T("claude.tagtitle", desk), "w440 h150", IniLookup("ClaudeTags", desk))
    if (ib.Result != "OK")
        return
    v := Trim(ib.Value, " []")
    if (v = "")
        IniDelLoose("ClaudeTags", desk)
    else
        IniSet("ClaudeTags", desk, v)
}

; Schnittstelle fuer Claude-Chats (und Skripte): ein zweiter Start mit /cmd reicht den Befehl
; per WM_COPYDATA an die laufende Leiste weiter, wartet auf das Ergebnis und endet.
;   DeskTabs.exe /cmd arrange ACME        Claude-Fenster [ACME] auf ihren Desktop holen, verteilen
;   DeskTabs.exe /cmd list [Kuerzel]      Claude-Fenster mit Kuerzel und Desktop auflisten
;   DeskTabs.exe /cmd front|even|align <Anordnung>   auf dem aktuellen Desktop
; Ergebnis: %TEMP%\DeskTabs-cmd.txt, erste Zeile "ok: ..." oder "error: ...".
CmdResultPath() => A_Temp "\DeskTabs-cmd.txt"
; die laufende Leiste (ihr verstecktes Hauptfenster), nicht diese Instanz
OtherInstance() {
    dhw := A_DetectHiddenWindows, me := DllCall("GetCurrentProcessId", "UInt"), hit := 0
    DetectHiddenWindows(true)
    try for h in WinGetList("ahk_class AutoHotkey")
        if (WinGetPID(h) != me && InStr(WinGetTitle(h), A_ScriptFullPath) = 1) {
            hit := h
            break
        }
    DetectHiddenWindows(dhw)
    return hit
}
CmdForward() {
    args := ""
    for i, a in A_Args
        if (i > 1)
            args .= (args = "" ? "" : " ") a
    res := CmdResultPath()
    try FileDelete(res)
    h := OtherInstance()
    if (!h) {
        try FileAppend("error: DeskTabs is not running`n", res, "UTF-8")
        ExitApp(2)
    }
    buf := Buffer(StrPut(args, "UTF-16"), 0)
    StrPut(args, buf, "UTF-16")
    cds := Buffer(A_PtrSize * 3, 0)
    NumPut("UPtr", 0x444B4344, cds, 0)                             ; Kennung "DCKD"
    NumPut("UInt", buf.Size, cds, A_PtrSize)
    NumPut("Ptr", buf.Ptr, cds, A_PtrSize * 2)
    DetectHiddenWindows(true)
    try SendMessage(0x4A, A_ScriptHwnd, cds.Ptr, , "ahk_id " h, , , , 5000)
    t0 := A_TickCount
    while (!FileExist(res) && A_TickCount - t0 < 20000)
        Sleep(50)
    ExitApp(FileExist(res) ? 0 : 3)
}
; Beim normalen Start eine schon laufende Leiste beenden (wie #SingleInstance Force, das
; wegen /cmd nicht mehr geht)
ReplaceOtherInstance() {
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows(true)                                       ; das Hauptfenster ist versteckt
    Loop 3 {
        if (!h := OtherInstance())
            break
        pid := 0
        try pid := WinGetPID("ahk_id " h)
        try WinClose("ahk_id " h)
        if (pid && ProcessWaitClose(pid, 3))                        ; laeuft nach 3 s noch
            try ProcessClose(pid)
    }
    DetectHiddenWindows(dhw)
}
OnCopyData(wParam, lParam, msg, hwnd) {
    if (NumGet(lParam, 0, "UPtr") != 0x444B4344)
        return 0
    s := StrGet(NumGet(lParam, A_PtrSize * 2, "Ptr"), "UTF-16")
    SetTimer(CmdRun.Bind(s), -1)
    return 1
}
CmdRun(s) {
    s := Trim(s), p := InStr(s, " ")
    verb := p ? SubStr(s, 1, p - 1) : s, arg := p ? Trim(SubStr(s, p + 1), " `"") : ""
    if (!CONF["ClaudeCode"])
        return CmdResult("error: Claude Code features are off (DeskTabs menu > More settings)")
    try {
        switch verb, false {
            case "arrange":
                num := ClaudeDeskFor(arg)
                return CmdResult(num < 0 ? "error: no desktop for [" arg "]" : ClaudeGather(num))
            case "list":
                return CmdResult(ClaudeListText(arg))
            case "front", "even", "align":
                if (!SetGet(arg))
                    return CmdResult("error: no layout `"" arg "`" on the current desktop")
                (verb = "front") ? SetRestore(arg) : (verb = "even") ? SetEven(arg) : SetTidy(arg)
                return CmdResult("ok: " verb " " arg)
        }
        CmdResult("error: unknown command `"" verb "`" (arrange, list, front, even, align)")
    } catch as e
        CmdResult("error: " e.Message)
}
; alle Claude-Chat-Fenster (oder nur eines Kuerzels): Desktop-Nummer, Desktop, Titel
ClaudeListText(tag := "") {
    out := "ok`n", dhw := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    try for h in WinGetList("ahk_exe claude.exe") {
        if (!(WinGetStyle(h) & 0x10000000) || DllCall("GetWindow", "Ptr", h, "UInt", 4, "Ptr"))
            continue
        ti := WinGetTitle(h)
        if (!RegExMatch(ti, "\[[^\]]+\]") || (tag != "" && !InStr(ti, "[" tag "]")))
            continue
        d := VD("GetWindowDesktopNumber", "Ptr", h, "Int")
        out .= (d + 1) "`t" (d >= 0 ? GetDesktopNameRaw(d) : "?") "`t" ti "`n"
    }
    DetectHiddenWindows(dhw)
    return out
}
CmdResult(txt) {
    res := CmdResultPath()
    try {
        FileOpen(res ".tmp", "w", "UTF-8").Write(RTrim(txt, "`n") "`n")
        FileMove(res ".tmp", res, 1)
    }
}
; Flaeche des Arbeitsbereichs des Bildschirms, auf dem das Fenster liegt
MonArea(h) {
    mi := Buffer(40, 0), NumPut("UInt", 40, mi)
    DllCall("GetMonitorInfo", "Ptr", DllCall("MonitorFromWindow", "Ptr", h, "UInt", 2, "Ptr"), "Ptr", mi)
    return (NumGet(mi, 28, "Int") - NumGet(mi, 20, "Int")) * (NumGet(mi, 32, "Int") - NumGet(mi, 24, "Int"))
}
; Flaeche einer GDI-Region in Pixeln (Summe ihrer Rechtecke)
RgnArea(rgn) {
    n := DllCall("GetRegionData", "Ptr", rgn, "UInt", 0, "Ptr", 0, "UInt")
    if (!n)
        return 0
    buf := Buffer(n, 0)
    DllCall("GetRegionData", "Ptr", rgn, "UInt", n, "Ptr", buf, "UInt")
    cnt := NumGet(buf, 8, "UInt"), a := 0
    Loop cnt {
        o := 32 + (A_Index - 1) * 16
        a += (NumGet(buf, o + 8, "Int") - NumGet(buf, o, "Int")) * (NumGet(buf, o + 12, "Int") - NumGet(buf, o + 4, "Int"))
    }
    return a
}
; sichtbarer Rahmen eines Fensters [l, t, r, b] (ohne die unsichtbaren Raender)
SetFrame(h) {
    rc := Buffer(16, 0)
    if (DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", h, "UInt", 9, "Ptr", rc, "UInt", 16) != 0)
        DllCall("GetWindowRect", "Ptr", h, "Ptr", rc)
    return [NumGet(rc, 0, "Int"), NumGet(rc, 4, "Int"), NumGet(rc, 8, "Int"), NumGet(rc, 12, "Int")]
}

BtnClick(num, *) {
    ; Klick auf den bereits aktiven Desktop: hat er Unterprojekte, die schlanke Auswahl
    ; (Alt + Klick bleibt das volle Menue mit Anlegen/Entfernen); sonst auf Wunsch die Taskansicht
    if (num = GetCurrentDesktop()) {
        if (SubList(num).Length) {
            global gSP, gSPClosed
            if (gSP || A_TickCount - gSPClosed < 400)   ; derselbe Klick hat sie gerade geschlossen
                return
            SetTimer(SubPanelOpen.Bind(num), -1)
        }
        else if (CONF["ClickActiveTaskView"]) {
            MarkTaskView()
            Send("#{Tab}")
        }
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
    if (target != cur) {
        global gSwitchSrc := "wheel"
        SwitchToDesktop(target)
    }
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
    if (BarMouseX() >= gLayout["gripW"])     ; nur der Griff zieht die Leiste; ein Tab wird - wie
        return ReorderDrag()                 ; ein Browser-Tab - beim Ziehen umsortiert, ein Klick bleibt ein Klick
    if (GetKeyState("Shift"))                ; Umschalt+Klick auf den Griff: Fenster auf allen Desktops (beim Loslassen)
        return 0
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
            targetY := tbY + ((tbBottom - tbY) - GUIH) // 2
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
    RenderBar(true)                  ; auf die Taskleiste gezogen oder davon weg: Register an/aus
    UpdateStripe()
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
; Desktops umsortieren wie Browser-Tabs: Tab greifen und seitlich ziehen. Erst ab ein paar
; Pixeln Weg gilt es als Ziehen - ein Klick (auch Umschalt+Klick) bleibt ein Klick.
; Braucht eine DLL mit dem Export MoveDesktop (Ciantic ab Commit ceb6488, PR #119; bis zu einem
; offiziellen Release selbst gebaut per .github/workflows/build-dll.yml).
ReorderDrag() {
    global gReorderFrom
    ; Mit Alt, Strg oder Umschalt ist ein Klick immer eine Geste (Unterprojekt, Fenster
    ; schicken/mitnehmen), nie ein Ziehen - sonst sortierte ein leicht verwackelter
    ; Alt-Klick die Desktops um.
    if (GetKeyState("Alt", "P") || GetKeyState("Ctrl") || GetKeyState("Shift"))
        return
    ; Sicherheitsnetz: wie auch immer das Ziehen endet (auch mit Fehler), der Zieh-Zustand
    ; wird zurueckgesetzt. Blieb er stehen, verschluckte die Leiste danach jeden Klick.
    try
        return ReorderDragRun()
    finally
        gReorderFrom := -1
}
ReorderDragRun() {
    global BTNS, gLayout, gReorderFrom, gSkipUpUntil, MyGui
    item := ItemAtX(BarMouseX())
    if (!item || !CanMoveDesktop())
        return
    tabs := BTNS                                   ; wird die Leiste waehrend des Ziehens neu aufgebaut -> abbrechen
    CoordMode("Mouse", "Screen")
    MouseGetPos(&sx)
    wx := 0
    MyGui.GetPos(&wx)
    grab := (sx - wx) - item["x"]                  ; wo im Tab gegriffen wurde
    gap := gLayout["gap"], x0 := BTNS[1]["x"]
    last := BTNS[BTNS.Length], xEnd := last["x"] + last["w"]
    for it in BTNS
        it["x0"] := it["x"]
    dragging := false, target := item["num"]
    while GetKeyState("LButton", "P") {
        MouseGetPos(&mx)
        if (BTNS != tabs) {                          ; Neuaufbau mitten im Ziehen (z. B. aus einem Menue): sauber abbrechen
            gReorderFrom := -1
            return
        }
        if (!dragging && Abs(mx - sx) > px(10)) {
            dragging := true
            gReorderFrom := item["num"], item["hover"] := true
            ToolTip(, , , 4)
        }
        if (dragging) {
            ; Das Loslassen kommt als WM_LBUTTONUP oft an, bevor diese Schleife es merkt - und
            ; wurde dann als Klick verarbeitet (Umschalt+Klick schickte das aktive Fenster weg,
            ; ein Klick wechselte den Desktop). Deshalb ab jetzt jeden Klick verschlucken.
            gSkipUpUntil := A_TickCount + 600
            ; der gegriffene Tab haengt an der Maus, die anderen gleiten zur Seite
            item["x"] := Max(x0, Min((mx - wx) - grab, xEnd - item["w"]))
            target := ReorderSlots(item, x0, gap)
            for it in BTNS
                if (it != item)
                    it["x"] := Glide(it["x"], it["tx"])
            RenderBar(true)
        }
        Sleep(15)
    }
    if (!dragging)
        return                                       ; nur geklickt: OnLButtonUp entscheidet wie immer
    gSkipUpUntil := A_TickCount + 600                ; das WM_LBUTTONUP gehoert zum Ziehen
    if (BTNS != tabs) {
        gReorderFrom := -1
        return 0
    }
    ReorderSlots(item, x0, gap)
    Loop 10 {                                        ; beim Loslassen in die Luecke gleiten
        for it in BTNS
            it["x"] := Glide(it["x"], it["tx"])
        RenderBar(true)
        Sleep(15)
    }
    from := gReorderFrom
    gReorderFrom := -1
    if (target != from) {
        ; am Stueck, nicht unterbrechbar: Windows hat den Desktop sofort verschoben, die
        ; Nummern hier ziehen erst danach nach. Zeichnete der Hover-Timer dazwischen (beim
        ; ersten Mal dauert MoveDesktop ~50 ms), sprangen Markierung und Farben kurz zurueck.
        Critical
        global gSelfTick := A_TickCount
        moved := (VD("MoveDesktop", "Int", from, "Int", target, "Int") = 1)
        if (moved)
            RemapAfterMove(from, target)
        SyncDesktopIds()
        if (!moved || !ReorderInPlace())             ; ohne Neuaufbau: kein Aufblitzen der Leiste
            RebuildAll()                             ; kein Bestaetigungsblinken - Browser-Tabs blinken auch nicht
    } else {
        for it in BTNS
            it["x"] := it["x0"]
        RenderBar(true)
    }
    return 0
}
; Nach dem Umsortieren haben Desktops neue Positionsnummern. Alles, was sich DeskTabs per
; Nummer merkt, wird mitgezogen - sonst hielte UpdateHighlight die neue Nummer des aktiven
; Desktops fuer einen fremden Wechsel (oranges Blinken), das Zeit-Log teilte den Aufenthalt
; und "zurueck" zeigte auf den falschen Desktop.
RemapAfterMove(from, to) {
    global gCurrent, gLastDesk, gSegDesk, gLogPend, gAttention, gAlertNum
    m(i) => (i = from) ? to
        : (from < to && i > from && i <= to) ? i - 1
        : (to < from && i >= to && i < from) ? i + 1 : i
    gCurrent := (gCurrent >= 0) ? m(gCurrent) : gCurrent
    gLastDesk := (gLastDesk >= 0) ? m(gLastDesk) : gLastDesk
    gSegDesk := (gSegDesk >= 0) ? m(gSegDesk) : gSegDesk
    if (IsObject(gLogPend) && gLogPend.Has("desk") && gLogPend["desk"] >= 0)
        gLogPend["desk"] := m(gLogPend["desk"])
    if (gAlertNum >= 0)
        gAlertNum := m(gAlertNum)
    att := Map()
    for k in gAttention
        att[m(k)] := true
    gAttention := att
}
; Die Tabs stehen nach dem Gleiten schon an ihren neuen Plaetzen: nur Nummern, Beschriftungen
; und Abzeichen nachziehen und neu zeichnen, statt die Leiste neu aufzubauen (das liess sie
; kurz aufblitzen). Aendert sich dabei eine Beschriftung in der Laenge (Nummer vorangestellt,
; 9 -> 10), stimmen die Breiten nicht mehr: dann false, der Aufrufer baut neu.
ReorderInPlace() {
    global BTNS, gOrdCache
    gOrdCache := Map()                               ; Position -> Laufnummer hat sich verschoben
    order := []
    for it in BTNS
        order.Push(it)
    ; nach der Zielposition sortieren (wenige Tabs: einfaches Einfuegesortieren)
    Loop order.Length - 1 {
        i := A_Index + 1, cur := order[i], j := i - 1
        while (j >= 1 && order[j]["tx"] > cur["tx"]) {
            order[j + 1] := order[j], j -= 1
        }
        order[j + 1] := cur
    }
    for i, it in order {
        num := i - 1
        label := LabelFor(num)
        if (it["label"] != "" && StrLen(label) != StrLen(it["label"]))
            return false
        if (it["label"] != "")
            it["label"] := label
        it["num"] := num, it["x"] := it["tx"]
        it["badge"] := BadgeText(num, it["icon"], it["label"])
        it["src"] := TabSource(num)
    }
    BTNS := order
    UpdateHighlight()
    RenderBar(true)
    return true
}
; weiches Annaehern: pro Schritt gut ein Drittel des Restwegs
Glide(cur, to) => (Abs(to - cur) < 1) ? to : cur + (to - cur) * 0.35
; Zielplatz des gezogenen Tabs (0-basiert) und die Gleit-Ziele (tx) aller Tabs
ReorderSlots(drag, x0, gap) {
    global BTNS
    others := []
    for it in BTNS
        if (it != drag)
            others.Push(it)
    ; Ziel wie bei Browser-Tabs: es zaehlt die Kante in Zugrichtung. Ein Nachbar rechts weicht
    ; nach links aus, sobald die rechte Kante des gezogenen Tabs seine Mitte (an seinem
    ; Ausgangsplatz) ueberquert; ein Nachbar links entsprechend mit der linken Kante.
    ; (Vorher: Mitte gegen Mitte - bei breiten Tabs sprangen schmale Nachbarn zu frueh
    ; unter den gezogenen, bei schmalen kam das Ausweichen zu spaet.)
    L := drag["x"], R := drag["x"] + drag["w"], t := 0
    for it in others {
        c := (it.Has("x0") ? it["x0"] : it["x"]) + it["w"] / 2
        if (it["num"] < drag["num"] ? (L > c) : (R > c))
            t += 1
    }
    ; Gleit-Ziele: dicht gepackt, mit einer Luecke fuer den gezogenen an Stelle t
    x := x0
    for i, it in others {
        if (i - 1 = t)
            drag["tx"] := x, x += drag["w"] + gap
        it["tx"] := x, x += it["w"] + gap
    }
    if (t = others.Length)
        drag["tx"] := x
    return t
}
; Zeichenreihenfolge: beim Umsortieren kommt der gezogene Tab zuletzt, also obenauf
RenderOrder() {
    global BTNS, gReorderFrom
    if (gReorderFrom < 0)
        return BTNS
    out := [], top := 0
    for it in BTNS {
        if (it["num"] = gReorderFrom)
            top := it
        else
            out.Push(it)
    }
    if (top)
        out.Push(top)
    return out
}
; Kann die geladene DLL Desktops verschieben? (die offizielle exportiert MoveDesktop nicht)
CanMoveDesktop() {
    static ok := ""
    if (ok = "") {
        h := DllCall("GetModuleHandle", "Str", "VirtualDesktopAccessor", "Ptr")
        ok := (h && DllCall("GetProcAddress", "Ptr", h, "AStr", "MoveDesktop", "Ptr")) ? 1 : 0
    }
    return ok
}

OnLButtonUp(wParam, lParam, msg, hwnd) {
    global MyGui, gSkipUpUntil, gReorderFrom, gLayout
    if (!MyGui || (hwnd != MyGui.Hwnd && DllCall("GetParent", "Ptr", hwnd, "Ptr") != MyGui.Hwnd))
        return
    if (gReorderFrom >= 0 || A_TickCount < gSkipUpUntil) {   ; Ende eines Umsortier-Ziehens, kein Klick
        gSkipUpUntil := 0
        return 0
    }
    lx := BarMouseX()
    item := ItemAtX(lx)
    if (!item && (si := SetAt(lx))) {
        SetTimer(SetClick.Bind(si, GetKeyState("Shift"), GetKeyState("Ctrl")), -1)   ; nach vorne; Umschalt: neu aufnehmen; Strg: aufraeumen
        return 0
    }
    if (!item && lx >= 0 && lx < gLayout["gripW"] && GetKeyState("Shift")) {
        TogglePinWindow(WorkWindow())          ; Umschalt+Klick auf den Griff: aktives Fenster auf allen Desktops (noch einmal: nur hier)
        return 0
    }
    if (item && GetKeyState("Alt", "P")) {        ; Alt+Klick: Unterprojekt waehlen (physisch: logisch ist Alt nach dem ersten Alt-Menue schon "los")
        Send("{Blind}{vkE8}")                     ; verhindert, dass das Loslassen von Alt die Menueleiste des Vordergrund-Programms oeffnet
        SetTimer(ShowSubMenu.Bind(item["num"]), -1)
        return 0
    }
    if (item && GetKeyState("Ctrl") && !GetKeyState("Shift")) {
        ToggleCompact(item["num"])             ; Strg+Klick: dieser Tab kompakt (nur Symbol) bzw. wieder normal
        return 0
    }
    if (item && GetKeyState("Shift") && (item["num"] != GetCurrentDesktop() || PinState(WorkWindow()) = 1)) {
        if (GetKeyState("Ctrl")) {
            TakeActiveTo(item["num"])          ; Strg+Umschalt+Klick: Fenster mitnehmen und selbst mitgehen
            return 0
        }
        MoveActiveTo(item["num"])              ; Umschalt+Klick: aktives Fenster dorthin schicken, selbst bleiben
        return 0
    }
    if (item)
        BtnClick(item["num"])
    return 0
}

; known >= 0: eigener Wechsel mit bekanntem Ziel. Dann keine Rueckfragen beim Explorer (der direkt
; nach einem Wechsel 200-400 ms fuer jede braucht), ArriveDesk lief schon, das Zeit-Log folgt kurz danach.
UpdateHighlight(known := -1) {
    global BTNS, gCurrent
    prev := gCurrent
    gCurrent := (known >= 0) ? known : GetCurrentDesktop()
    if (prev >= 0 && gCurrent >= 0 && gCurrent != prev) {
        if (known >= 0)
            ClearSwitchAlert()                 ; eigener Wechsel: alter Hinweis erledigt
        else
            CheckForeignSwitch(prev, gCurrent)
        global gLastDesk, gDeskSince, gAttention
        if (A_TickCount - gDeskSince >= Max(1, CONF["TimeLogMinSec"]) * 1000)
            gLastDesk := prev                  ; nur echte Aufenthalte, keine Durchfahrten
        gDeskSince := A_TickCount
        if (gAttention.Has(gCurrent))
            gAttention.Delete(gCurrent)        ; angekommen: Punkt erledigt
        if (known < 0) {
            global gZBlockUntil := A_TickCount + 5000   ; bis ArriveDesk fertig ist (setzt es dann kurz)
            SetTimer(ArriveDesk, -1)           ; sofort: Windows hat beim Wechsel schon ein Fenster nach vorne geholt
        }
    }
    if (known >= 0)
        SetTimer(LogDesktop.Bind(gCurrent), -300)   ; Zeit-Log, wenn der Explorer wieder frei ist
    else
        LogDesktop(gCurrent)         ; Zeit-Log: Segmentwechsel bei Desktop-Wechsel
    RenderBar()
    UpdateStripe()                   ; Register-Kante in der Farbe des neuen Desktops
}

; Hover: Tab unter dem Mauszeiger leicht hervorheben
HoverTick() {
    global BTNS, gHidden, gBuilding, gGripHover, gLayout, gAlertNum, gAlertPhase, gDragHwnd
    if (gHidden || gBuilding)       ; waehrend eines Neuaufbaus existiert die GUI kurz nicht
        return
    if (gDragHwnd)                  ; beim Ziehen eines Fensters uebernimmt DragTipTick
        return
    global gReorderFrom
    if (gReorderFrom >= 0)          ; beim Umsortieren steuert ReorderDrag die Darstellung
        return
    lx := BarMouseX()
    over := ItemAtX(lx)
    grip := (lx >= 0 && lx < gLayout["gripW"])
    changed := (grip != gGripHover)
    gGripHover := grip
    global gSetHover
    sh := SetAt(lx)
    if (sh != gSetHover) {
        gSetHover := sh, changed := true
        SetHoverTip(sh)
    }
    for item in BTNS {
        h := (over && item["num"] = over["num"])
        if (h != item["hover"]) {
            item["hover"] := h
            changed := true
        }
    }
    if (gAlertNum >= 0 && gAlertPhase = 0 && over && over["num"] = gAlertNum)
        ClearSwitchAlert()
    HoverNameTip(over ? over["num"] : -1)
    if (changed)
        RenderBar()
}
; Zeigt der Tab seinen Namen nicht ganz (kompakt, nur Symbol, Kuerzel, gekuerzt), erscheint
; er nach kurzem Verweilen als Kurzinfo ueber dem Tab - wie bei den Taskleisten-Buttons
HoverNameTip(num) {
    global gHoverTipNum
    static show := ShowHoverName
    if (num = gHoverTipNum)
        return
    gHoverTipNum := num
    ToolTip(, , , 4)
    SetTimer(show, 0)
    if (num >= 0)
        SetTimer(show, -450)
}
ShowHoverName() {
    global gHoverTipNum, BTNS, MyGui, gDragHwnd, gHidden
    if (gHoverTipNum < 0 || gDragHwnd || gHidden || !MyGui)
        return
    for item in BTNS {
        if (item["num"] != gHoverTipNum)
            continue
        raw := GetDesktopNameRaw(item["num"])
        if (raw = "" || InStr(item["label"], raw))  ; Name steht schon voll im Tab
            return
        if ((sb := SubActive(item["num"])) != "")
            raw .= " · " sb
        bx := 0, by := 0
        MyGui.GetPos(&bx, &by)
        CoordMode("ToolTip", "Screen")
        ToolTip(raw, bx + item["x"], by - px(34), 4)
        return
    }
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
        UpdateStripe()
        global gFsHit
        try FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") "  ausgeblendet wegen Vollbild: " gFsHit "`n", A_ScriptDir "\_debug.txt", "UTF-8")
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
            ; Desktop/Taskleiste und die unsichtbaren, bildschirmgrossen Traegerfenster der
            ; Shell (Startmenue, Suche, Info-Center, Taskansicht) ueberspringen - sonst
            ; verschwand die Leiste mit dem Startmenue und kam erst beim naechsten Klick wieder
            static shellCls := ",WorkerW,Progman,Shell_TrayWnd,Shell_SecondaryTrayWnd,Windows.UI.Core.CoreWindow,"
                . "XamlExplorerHostIslandWindow,ForegroundStaging,MultitaskingViewFrame,Shell_InputSwitchTopLevelWindow,"
                . "TopLevelWindowForOverflowXamlIsland,Xaml_WindowedPopupClass,NotifyIconOverflowWindow,TaskListThumbnailWnd,"
                . "ApplicationManager_ImmersiveShellWindow,Windows.Internal.Shell.TabProxyWindow,"
            if (cls != "" && !InStr(shellCls, "," cls ",")) {
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
                        full := (wl <= ml + tol && wt <= mt + tol && wri >= mr - tol && wb >= mb - tol)
                        if (full) {                  ; fuer die Fehlersuche: wer hat die Leiste ausgeblendet?
                            global gFsHit
                            ttl := ""
                            try ttl := WinGetTitle("ahk_id " h)
                            gFsHit := cls " | " SubStr(ttl, 1, 60)
                        }
                        return full
                    }
                }
            }
        }
        h := hNext
    }
    return false
}

; ---------------- Register-Form: farbige Kante ueber der Taskleiste -----------------
; Die aktive Taskleiste gehoert sichtbar zum aktiven Tab: an ihrer Oberkante laeuft eine
; schmale Linie in dessen Farbe, der Tab haengt daran (RenderBar). Die Linie ist ein eigenes
; Fenster, durch das alle Klicks hindurchgehen (WS_EX_TRANSPARENT|LAYERED|NOACTIVATE).
StripeH() => Max(2, px(3))
ActiveEdgeColor() {
    global gCurrent
    s := CONF["ActiveStyle"]
    return (s = "accent" || s = "solid") ? CONF["ColActiveBg"] : DesktopColor(Max(gCurrent, 0))
}
; Taskleisten-Rechteck [x, y, w, h], 0 wenn keine da ist
TaskbarRect() {
    hTray := DllCall("FindWindow", "Str", "Shell_TrayWnd", "Ptr", 0, "Ptr")
    if (!hTray)
        return 0
    rc := Buffer(16, 0)
    DllCall("GetWindowRect", "Ptr", hTray, "Ptr", rc)
    x := NumGet(rc, 0, "Int"), y := NumGet(rc, 4, "Int")
    return [x, y, NumGet(rc, 8, "Int") - x, NumGet(rc, 12, "Int") - y]
}
; Register nur, wenn die Leiste wirklich auf der (sichtbaren) Taskleiste sitzt; frei
; verschoben oder bei ausgeblendeter Taskleiste bleibt es bei normalen Tabs
RegisterOn() {
    global MyGui
    if (CONF["TabShape"] != "register" || !MyGui)
        return false
    tb := TaskbarRect()
    if (!tb || tb[2] >= A_ScreenHeight - px(4))
        return false
    bx := 0, by := 0
    try MyGui.GetPos(&bx, &by)
    return Abs(by - tb[2]) <= px(3)
}
UpdateStripe() {
    global gStripe, gHidden
    on := !gHidden && RegisterOn()
    if (!on) {
        if (gStripe && DllCall("IsWindowVisible", "Ptr", gStripe.Hwnd))
            DllCall("ShowWindow", "Ptr", gStripe.Hwnd, "Int", 0)    ; SW_HIDE
        return
    }
    ; Bei einem Desktop-Wechsel nur die Farbe setzen und das Fenster sonst nicht anfassen:
    ; ein Show() mitten im Umschalten wertete Windows als Griff nach dem Vordergrund, das
    ; Programm auf dem Ziel-Desktop wurde abgewiesen und blinkte (Punkt am Tab, Taskleisten-
    ; Knopf auf fremden Desktops). Lage/Groesse nur per SetWindowPos ohne Aktivierung.
    static geo := "", colSet := -1
    tb := TaskbarRect(), col := ActiveEdgeColor()
    g := tb[1] "|" tb[2] "|" tb[3]
    if (!gStripe) {
        gStripe := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08080020 -DPIScale")   ; NOACTIVATE|LAYERED|TRANSPARENT
        gStripe.BackColor := Format("{:06X}", col), colSet := col
        gStripe.Show("NoActivate x" tb[1] " y" tb[2] " w" tb[3] " h" StripeH())
        WinSetTransparent(255, gStripe)
        try DllCall("VirtualDesktopAccessor\PinWindow", "Ptr", gStripe.Hwnd)
        geo := g
    }
    if (col != colSet)
        gStripe.BackColor := Format("{:06X}", col), colSet := col
    if (g != geo) {
        DllCall("SetWindowPos", "Ptr", gStripe.Hwnd, "Ptr", 0, "Int", tb[1], "Int", tb[2], "Int", tb[3], "Int", StripeH(), "UInt", 0x0014)   ; NOZORDER|NOACTIVATE
        geo := g
    }
    if (!DllCall("IsWindowVisible", "Ptr", gStripe.Hwnd))
        DllCall("ShowWindow", "Ptr", gStripe.Hwnd, "Int", 4)        ; SW_SHOWNOACTIVATE
    StripeBelowBar()
}

AssertTop() {
    global MyGui, gHidden, gBuilding, gStripe
    if (gHidden || gBuilding)       ; waehrend eines Neuaufbaus existiert die GUI kurz nicht
        return
    ; HWND_TOPMOST(-1), SWP_NOMOVE|SWP_NOSIZE|SWP_NOACTIVATE = 0x0013
    DllCall("SetWindowPos", "Ptr", MyGui.Hwnd, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0013)
    StripeBelowBar()
}
; Register-Kante direkt UNTER die Leiste einsortieren (beide bleiben ueber der Taskleiste).
; Vorher kam sie als eigenes "ganz nach oben" kurz ueber die Leiste - sichtbar als Aufblitzen.
StripeBelowBar() {
    global gStripe, MyGui
    if (gStripe && MyGui && DllCall("IsWindowVisible", "Ptr", gStripe.Hwnd))
        DllCall("SetWindowPos", "Ptr", gStripe.Hwnd, "Ptr", MyGui.Hwnd, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0013)
}

; Wird bei jedem Vordergrund-Wechsel aufgerufen -> Leiste sofort wieder nach oben
WinEventProc(hHook, event, hwnd, idObject, idChild, thread, time) {
    global gHidden
    if (CONF["RestoreZOrder"])
        SetTimer(ZSnapCurrent, -300)    ; Fensterreihenfolge dieses Desktops merken (entprellt)
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
    global BTNS, gTheme, gBuilding, gSwitching, gCurrent, gSegDesk, gSegStart, gLogPaused
    LogIdleTick()                  ; Zeit-Log: Inaktivitaet erkennen (braucht keine GUI)
    if (gBuilding || gSwitching)   ; nicht mitten in Aufbau/Wechsel neu bauen (Geometrie-Race)
        return
    ; Abgleich mit dem tatsaechlich aktiven Desktop: Eine verpasste oder zu frueh beantwortete
    ; Wechsel-Meldung (etwa direkt nach dem Aufwachen) liess Leiste und Zeit-Log sonst auf dem
    ; alten Desktop stehen, bis zum naechsten Wechsel (Fall 30.10.2026, 7 min falsch gebucht).
    cur := GetCurrentDesktop()
    if (cur >= 0 && cur != gCurrent)
        UpdateHighlight()
    else if (cur >= 0 && CONF["TimeLog"] && !gLogPaused && gSegStart != "" && cur != gSegDesk)
        LogDesktop(cur)
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
        ApplyHotkeys()
        BuildTray()
        ApplyTheme()
        BuildBar()
        ApplyWindowHooks()
        UpdateHighlight()
        return
    }
    if (GetDesktopCount() != BTNS.Length) {
        SyncDesktopIds()
        BuildBar()
        ApplyWindowHooks()
    } else {
        ; Hat sich ein Name geaendert? -> KOMPLETT neu bauen, damit die Button-BREITEN
        ; zur neuen Textlaenge passen. Reines c.Text := ... laesst die Breite stehen
        ; -> lange Namen werden abgeschnitten und die Abstaende kollabieren.
        ; Verglichen wird die Quelle (Name/Kuerzel + Kompakt-Schalter), nicht der angezeigte
        ; Text: der ist bei Symbol-Tabs absichtlich leer und loeste sonst jede 1,2 s einen
        ; Neuaufbau aus (Leiste zuckte).
        nameChanged := false
        Critical                   ; Vergleich am Stueck: sonst baute ein dazwischen gewaehltes
        for item in BTNS {         ; Unterprojekt neu und der Rest verglich die alte Liste (zweiter Neuaufbau)
            if (item["src"] != TabSource(item["num"])) {
                nameChanged := true
                break
            }
        }
        Critical "Off"
        if (nameChanged) {
            SyncDesktopIds()       ; in Windows umbenannt? Farbe, Symbol, Kuerzel ziehen mit
            BuildBar()
            ApplyWindowHooks()
        }
    }
    UpdateHighlight()
}

; ------------------------------ Tastenkuerzel -------------------------------
; Direktsprung auf Desktop 1..10 per Zifferntaste. Registriert werden immer beide
; Reihen: die Zifferntasten oben und der Ziffernblock - dort zusaetzlich die
; Zweitbelegung, damit es auch ohne eingeschaltetes NumLock funktioniert.
; Zweitbelegung des Ziffernblocks (NumLock aus)
NumpadAlias(digit) {
    alias := Map("1", "NumpadEnd", "2", "NumpadDown", "3", "NumpadPgDn", "4", "NumpadLeft", "5", "NumpadClear"
               , "6", "NumpadRight", "7", "NumpadHome", "8", "NumpadUp", "9", "NumpadPgUp", "0", "NumpadIns")
    return alias.Has(digit) ? alias[digit] : ""
}

NumpadScan(digit) {
    ; Scancodes des Ziffernblocks. Ueber den Scancode gilt eine Taste unabhaengig
    ; davon, ob NumLock an ist - mit den Namen (Numpad2 vs. NumpadDown) muesste man
    ; beide Zustaende getrennt registrieren, was nicht zuverlaessig greift.
    sc := Map("1", "sc04F", "2", "sc050", "3", "sc051", "4", "sc04B", "5", "sc04C"
            , "6", "sc04D", "7", "sc047", "8", "sc048", "9", "sc049", "0", "sc052")
    return sc.Has(digit) ? sc[digit] : ""
}

ApplyHotkeys() {
    global gHotkeys
    for , key in gHotkeys
        try Hotkey(key, "Off")
    gHotkeys := []
    if (CONF["CallHotkey"] != "") {             ; Gespraech: unabhaengig von den Ziffern-Kuerzeln
        try {
            Hotkey(CONF["CallHotkey"], ToggleCallHere, "On")
            gHotkeys.Push(CONF["CallHotkey"])
        }
    }
    if (!CONF["Hotkeys"])
        return
    mk := CONF["HotkeyMod"]                 ; nicht "mod" nennen: das ist die eingebaute Funktion Mod()
    failed := 0
    Loop 10 {
        idx := A_Index - 1                      ; Desktop 1..10 -> Index 0..9
        digit := (A_Index = 10) ? "0" : String(A_Index)
        ; Zifferreihe, Ziffernblock per Scancode (gilt unabhaengig von NumLock) und
        ; zusaetzlich beide Namensvarianten - was zuerst greift, greift.
        for , key in [mk digit, mk NumpadScan(digit), mk "Numpad" digit, mk NumpadAlias(digit)] {
            if (key = mk)
                continue
            try {
                Hotkey(key, JumpToDesktop.Bind(idx), "On")
                gHotkeys.Push(key)
            } catch {
                failed++
            }
        }
    }
    ; Umschalt dazu: aktives Fenster auf diesen Desktop schicken (nur, wenn Umschalt
    ; nicht schon Teil des Grund-Kuerzels ist). Ruecktaste: zurueck zum letzten Desktop.
    if (!InStr(mk, "+")) {
        Loop 10 {
            digit := (A_Index = 10) ? "0" : String(A_Index)
            for , key in [mk "+" digit, mk "+" NumpadScan(digit)] {
                try {
                    Hotkey(key, MoveActiveTo.Bind(A_Index - 1), "On")
                    gHotkeys.Push(key)
                }
            }
        }
    }
    try {
        Hotkey(mk "Backspace", GoBack, "On")
        gHotkeys.Push(mk "Backspace")
    }
    if (failed && gHotkeys.Length = 0) {
        MsgBox(T("err.hotkeys"), "DeskTabs", 0x30)
        CONF["Hotkeys"] := 0
        IniSet("View", "Hotkeys", 0)
    }
}

; Einen Modifikator zu- oder abschalten. Mindestens einer muss bleiben, sonst
; wuerden die blossen Zifferntasten belegt.
ToggleHotkeyMod(sign, *) {
    cur := CONF["HotkeyMod"]
    einschalten := !CONF["Hotkeys"]         ; wer hier waehlt, will die Kuerzel auch nutzen
    neu := InStr(cur, sign) ? StrReplace(cur, sign) : cur sign
    ; in eine feste Reihenfolge bringen: Strg, Umschalt, Alt, Windows
    out := ""
    for , s in ["^", "+", "!", "#"]
        if (InStr(neu, s))
            out .= s
    if (out = "") {
        MsgBox(T("err.hotkey_mod"), "DeskTabs", 0x30)
        return
    }
    SetView("HotkeyMod", out)
    if (einschalten)
        SetView("Hotkeys", 1)
}

JumpToDesktop(idx, *) {
    global gSwitchSrc
    if (idx < GetDesktopCount()) {
        gSwitchSrc := "key"
        SwitchToDesktop(idx)
    }
}

; Lesbare Beschriftung eines Modifikators, z.B. "Strg + Windows + 1 … 0"
; "^#t" -> "Strg + Win + T"
CallHotkeyText() {
    k := CONF["CallHotkey"]
    RegExMatch(k, "^([\^+!#]*)(.+)$", &m)
    return StrReplace(HotkeyLabel(m[1]), " + 1 … 0", "") " + " StrUpper(m[2])
}
HotkeyLabel(mk) {
    parts := []
    if (InStr(mk, "^"))
        parts.Push(T("key.ctrl"))
    if (InStr(mk, "#"))
        parts.Push(T("key.win"))
    if (InStr(mk, "!"))
        parts.Push(T("key.alt"))
    if (InStr(mk, "+"))
        parts.Push(T("key.shift"))
    out := ""
    for , v in parts
        out .= (out = "" ? "" : " + ") v
    return out " + 1 … 0"
}

; ------------------------------- Tray ---------------------------------------
BuildTray() {
    A_TrayMenu.Delete()
    AddAppHeader(A_TrayMenu)
    FillSettingsMenu(A_TrayMenu)
    A_TrayMenu.Default := T("menu.about")     ; Doppelklick aufs Tray-Symbol = "Ueber DeskTabs"
    OwnerDrawAll(A_TrayMenu.Handle)
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
    y := tbY
    MyGui.Move(x, y)
    IniSet("Position", "X", x)
    IniSet("Position", "Y", y)
}

; ------------------------------- Utils --------------------------------------
Fmt(color) => Format("{:06X}", color)

; ---------------------- Einstellungen je Desktop-Name -----------------------
; Farbe, Kuerzel und Symbol haengen am NAMEN des Desktops, nicht an seiner Nummer.
; Wird ein Desktop geloescht, bleibt sein Eintrag in der settings.ini stehen und
; gilt wieder, sobald ein Desktop mit diesem Namen existiert - auch wenn der Name
; spaeter etwas anders geschrieben wird: Gross-/Kleinschreibung, Leer- und
; Sonderzeichen sowie Umlaut-Schreibweisen werden beim Vergleich ignoriert.
NormName(s) {
    s := StrLower(s)
    for from, to in Map("ä", "ae", "ö", "oe", "ü", "ue", "ß", "ss", "à", "a", "á", "a", "â", "a"
                      , "è", "e", "é", "e", "ê", "e", "í", "i", "ó", "o", "ô", "o", "ú", "u", "ç", "c")
        s := StrReplace(s, from, to)
    return RegExReplace(s, "[^a-z0-9]")        ; alles ausser Buchstaben und Ziffern faellt weg
}

; Abschnitt der settings.ini als Map (normalisierter Schluessel -> Wert),
; zwischengespeichert bis die Datei sich aendert
IniSectionMap(sec) {
    global gIniGen
    static cache := Map()
    stamp := ""
    ; Zeitstempel (fuer Aenderungen von aussen) plus Zaehler der eigenen Schreibzugriffe:
    ; der Zeitstempel ist nur sekundengenau, im selben Takt Geschriebenes lieferte sonst
    ; den alten Wert (z. B. Unterprojekt "(keins)" erschien erst ~1-2 s spaeter)
    try stamp := FileGetTime(CONF["IniPath"], "M")
    stamp .= "|" gIniGen
    if (cache.Has(sec) && cache[sec]["stamp"] = stamp)
        return cache[sec]["map"]
    m := Map()
    for key, val in ReadIniSection(sec) {
        m[NormName(key)] := val
        m["=" key] := val
    }
    cache[sec] := Map("stamp", stamp, "map", m)
    return m
}

; Abschnitt selbst aus der Datei lesen. IniRead geht ueber die Windows-INI-
; Schnittstelle und versteht kein UTF-8; Namen mit Umlauten kaemen dort verstuemmelt
; an. Deshalb: erst als UTF-8 lesen, sonst in der Systemcodierung.
; settings.ini muss UTF-16 (mit BOM) sein: nur dann schreibt Windows' IniWrite Umlaute als
; Unicode. In einer UTF-8- oder ANSI-Datei (etwa von Hand oder von einem KI-Agenten angelegt)
; schreibt es ANSI dazwischen, die Datei ist dann gemischt und "Baeckerei" wird zu "BÃ¤ckerei".
; Einmalig beim Start umwandeln; jede Zeile wird einzeln als UTF-8 oder ANSI erkannt, so
; wird auch eine schon gemischte Datei sauber. Vorher eine Sicherungskopie daneben legen.
NormalizeIniEncoding() {
    path := CONF["IniPath"]
    if !FileExist(path)
        return
    try {
        raw := FileRead(path, "RAW")
        if (raw.Size >= 2 && NumGet(raw, 0, "UChar") = 0xFF && NumGet(raw, 1, "UChar") = 0xFE)
            return                                     ; schon UTF-16 LE
        start := (raw.Size >= 3 && NumGet(raw, 0, "UChar") = 0xEF && NumGet(raw, 1, "UChar") = 0xBB
            && NumGet(raw, 2, "UChar") = 0xBF) ? 3 : 0   ; UTF-8-BOM ueberspringen
        txt := "", ls := start
        Loop raw.Size - start + 1 {
            i := start + A_Index - 1
            if (i < raw.Size && NumGet(raw, i, "UChar") != 0x0A)
                continue
            len := i - ls
            if (len > 0) {
                line := StrGet(raw.Ptr + ls, len, "UTF-8")
                if InStr(line, Chr(0xFFFD))
                    line := StrGet(raw.Ptr + ls, len, "CP1252")
                txt .= RTrim(line, "`r")
            }
            if (i < raw.Size)
                txt .= "`r`n"
            ls := i + 1
        }
        FileCopy(path, path ".vor-utf16.bak", true)
        f := FileOpen(path, "w", "UTF-16")
        f.Write(txt), f.Close()
        global gIniStamp := FileGetTime(path, "M")    ; eigene Aenderung, kein Live-Reload
    }
}

ReadIniText() {
    txt := ""
    try txt := FileRead(CONF["IniPath"], "UTF-8")
    if (txt = "" || InStr(txt, Chr(0xFFFD)))
        try txt := FileRead(CONF["IniPath"])
    return txt
}

; Map "Schluessel -> Wert" eines Abschnitts, Reihenfolge der Datei
ReadIniSection(sec) {
    out := Map()
    inSec := false
    Loop Parse, ReadIniText(), "`n", "`r" {
        line := Trim(A_LoopField)
        if (line = "" || SubStr(line, 1, 1) = ";")
            continue
        if (SubStr(line, 1, 1) = "[") {
            inSec := (Trim(line, "[]") = sec)
            continue
        }
        if (!inSec)
            continue
        eq := InStr(line, "=")
        if (eq > 1)
            out[Trim(SubStr(line, 1, eq - 1))] := Trim(SubStr(line, eq + 1))
    }
    return out
}

; Wert zu einem Desktop-Namen: erst genau, dann tolerant. "" = nichts hinterlegt.
; Ohne IniRead: das liest bei jedem Aufruf die ganze Datei ueber die Windows-Schnittstelle
; (beim Aufbau der Leiste rund hundertmal, das kostete ~0,1 s). Der Zwischenspeicher in
; IniSectionMap ist nach eigenen Schreibzugriffen sofort aktuell (gIniGen).
IniLookup(sec, name) {
    m := IniSectionMap(sec)
    if (m.Has("=" name))                         ; genaue Schreibweise zuerst
        return m["=" name]
    key := NormName(name)
    return m.Has(key) ? m[key] : ""
}

IniGet(sec, key, default) {
    val := IniRead(CONF["IniPath"], sec, key, "")
    return (val = "") ? default : val + 0
}
IniSet(sec, key, val) {
    global gIniStamp, gIniGen
    IniWrite(val, CONF["IniPath"], sec, key)
    gIniGen += 1
    try gIniStamp := FileGetTime(CONF["IniPath"], "M")   ; eigener Schreibzugriff, kein Live-Reload
}
; Eintrag entfernen, auch wenn er unter einer anderen Schreibweise steht
IniDelLoose(sec, name) {
    IniDel(sec, name)
    key := NormName(name)
    for k, v in ReadIniSection(sec)
        if (NormName(k) = key)
            IniDel(sec, k)
}

IniDel(sec, key) {
    global gIniStamp, gIniGen
    try IniDelete(CONF["IniPath"], sec, key)
    gIniGen += 1
    try gIniStamp := FileGetTime(CONF["IniPath"], "M")
}

OnExitCleanup(*) {
    global VDA, gWinEventHook, gWinEventCb, gDragHook, gDragCb, gGap
    if (IsObject(gGap))
        GapEnd(, false)                         ; laufende Luecke (Sperre, Pause ...) schreiben
    else
        LogClose()                              ; Zeit-Log: letztes Segment abschliessen
    if (CONF["TimeLog"])
        try DllCall("Wtsapi32\WTSUnRegisterSessionNotification", "Ptr", A_ScriptHwnd)
    if (gWinEventHook)
        DllCall("UnhookWinEvent", "Ptr", gWinEventHook)
    if (gWinEventCb)
        CallbackFree(gWinEventCb)
    if (gDragHook)
        DllCall("UnhookWinEvent", "Ptr", gDragHook)
    if (gDragCb)
        CallbackFree(gDragCb)
    if (VDA)
        DllCall("FreeLibrary", "Ptr", VDA)
}
OnExit(OnExitCleanup)
