#Requires AutoHotkey v2.0
#SingleInstance Force
;@Ahk2Exe-SetMainIcon DeskTabs.ico
;@Ahk2Exe-SetName DeskTabs
;@Ahk2Exe-SetDescription DeskTabs - clickable taskbar buttons for Windows 11 virtual desktops
;@Ahk2Exe-SetCopyright Henning Pähtz (GPL-3.0-or-later)
;@Ahk2Exe-SetVersion 1.1.10.0
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
global APP_VERSION := "1.1.10"
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
    "ClickActiveTaskView", 1,  ; 1 = Klick auf aktiven Desktop oeffnet Task-Ansicht (Win+Tab)
    "Palette",        [0xE5471D, 0x2E7D32, 0x1565C0, 0x6A1B9A, 0xEF6C00, 0x00838F, 0xC2185B, 0x558B2F],
    "MaxNameLen",     22,      ; Stufe "full": Namen laenger als das werden gekuerzt
    "CompactMode",    "auto",  ; "auto" = Stufe nach Platz waehlen | "full" | "short" | "icon" (fest)
    "MaxBarWidthPct", 40,      ; auto: max. Anteil der Taskleistenbreite, bevor eine Stufe runtergeschaltet wird
    "ShortNameLen",   8,       ; Stufe "short": Namen laenger als das werden gekuerzt
    "TimeLog",        1,       ; 1 = Aufenthaltszeit pro Desktop als CSV protokollieren (timelog\desktop-log_YYYY-MM.csv)
    "TimeLogMinSec",  5,       ; kuerzere Aufenthalte (Durchfahrten) nicht eintragen, Zeit zaehlt zum Ziel-Desktop
    "TimeLogIdleMin", 5,       ; nach so vielen Minuten ohne Eingabe gilt "Pause": Segment wird geschlossen
    "Language",       "auto",  ; "auto" = Windows-Anzeigesprache | "de" | "en" | Code einer lang\xx.ini
    "UpdateCheck",    1,       ; 1 = einmal taeglich bei GitHub nach einer neueren Version fragen (nur Versionsnummer, keine Daten)
    "Hotkeys",        0,       ; 1 = Tastenkuerzel fuer den Direktsprung (Ziffernreihe UND Ziffernblock)
    "DragToTab",      1,       ; 1 = Fenster an der Titelleiste auf einen Tab ziehen schickt es auf diesen Desktop
    "AttentionDot",   1,       ; 1 = Punkt am Tab, wenn ein Programm auf einem anderen Desktop blinkt
    "SwitchAlert",    1,       ; 1 = Desktop-Wechsel durch andere Programme melden (Tab blinkt, Rahmen bleibt)
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

LogOpen(num) {
    global gSegStart, gSegDesk, gSegName
    if (!CONF["TimeLog"])
        return
    gSegStart := A_Now, gSegDesk := num, gSegName := GetDesktopNameRaw(num)
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
    global gSegStart, gSegDesk, gSegName, gLogCarry, gLogPend
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
    if (IsObject(gLogPend) && gLogPend["desk"] = gSegDesk && gLogPend["end"] = start)
        gLogPend["end"] := end                           ; nahtlose Fortsetzung desselben Desktops
    else {
        LogFlush()
        gLogPend := Map("start", start, "end", end, "desk", gSegDesk, "name", gSegName)
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
    file := LogFile(p["start"])
    try {
        DirCreate(LogDir())
        if !FileExist(file)
            FileAppend("start,end,seconds,desktop_index,desktop_name`n", file, "UTF-8")
        FileAppend(Format("{1},{2},{3},{4},{5}`n", IsoTime(p["start"]), IsoTime(p["end"])
            , DateDiff(p["end"], p["start"], "Seconds"), p["desk"] + 1, CsvQuote(p["name"])), file, "UTF-8")
    }
}

; Desktop-Wechsel ins Log uebernehmen (aus UpdateHighlight)
LogDesktop(num) {
    global gSegDesk, gLogPaused
    if (!CONF["TimeLog"] || gLogPaused || num = gSegDesk)
        return
    LogClose("", false)
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
global gStripe := 0           ; Register-Form: Kante ueber der Taskleiste (eigenes Fenster)
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
    "menu.activeshadow", "Schatten unter dem aktiven Tab",
    "menu.shape", "Form:",
    "menu.shape.tabs", "Tabs",
    "menu.shape.register", "Register (Tab hängt an der Taskleiste)",
    "menu.hotkeys.shiftdrag", "Tab seitlich ziehen: Desktops umsortieren (wie Browser-Tabs)",
    "menu.newdesk", "Neuer Desktop…",
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
    "menu.help.changelog", "Was ist neu (Änderungsverlauf)…",
    "menu.feedback.bug", "Fehler melden (GitHub)…",
    "menu.feedback.idea", "Idee einreichen (GitHub)…",
    "menu.feedback.mailbug", "Fehler per E-Mail melden…",
    "menu.feedback.mail", "Idee oder Frage per E-Mail…",
    "menu.update.check", "Nach Updates suchen…",
    "menu.update.auto", "Täglich automatisch nach Updates suchen",
    "menu.update.available", "Update {1} verfügbar…",
    "menu.about",      "Über DeskTabs…",
    "about.title",     "Über DeskTabs",
    "about.tagline",   "Klickbare Taskleisten-Buttons für virtuelle Desktops",
    "about.version",   "Version {1}",
    "about.author",    "von {1}",
    "about.license",   "Lizenz: GNU GPL v3 mit Namensnennung (siehe NOTICE). Quelltext frei verfügbar,`nohne jede Gewährleistung. Weitergaben und Abwandlungen müssen „DeskTabs von Henning Pähtz“ nennen.",
    "about.components", "Enthält VirtualDesktopAccessor (MIT, Jari Pennanen){1}.`nSymbol-Bibliothek: Schrift „Segoe Fluent Icons“ von Windows; Symbolnamen aus der`nMicrosoft-Dokumentation (CC BY 4.0).",
    "about.ahk",       "und AutoHotkey v2 (GPL-2.0 oder später)",
    "about.website",   "Website",
    "about.github",    "Projekt auf GitHub",
    "about.feedback",  "Feedback geben",
    "about.check",     "Nach Updates suchen",
    "about.close",     "Schließen",
    "update.none",     "DeskTabs {1} ist aktuell.",
    "update.found",    "Version {1} ist verfügbar (installiert: {2}).`n`nDownload-Seite öffnen?",
    "update.error",    "Update-Prüfung nicht möglich (keine Verbindung zu GitHub).",
    "update.tip",      "DeskTabs {1} ist verfügbar. Rechtsklick auf die Leiste → Update…",
    "feedback.mail.subject.bug", "DeskTabs {1}: Fehlermeldung",
    "feedback.mail.subject.feedback", "DeskTabs {1}: Idee oder Frage",
    "feedback.mail.body.bug", "Hallo Henning,`n`nin DeskTabs ist mir das hier aufgefallen:`n`nWas passiert ist:`n`nWas ich erwartet hatte:`n`nSo lässt es sich nachstellen:`n1.`n2.`n3.`n`nViele Grüße",
    "feedback.mail.body.feedback", "Hallo Henning,`n`nzu DeskTabs habe ich folgende Idee oder Frage:`n`n`nViele Grüße"
)
global LANG_EN := Map(
    "menu.activeshadow", "Shadow under the active tab",
    "menu.shape", "Shape:",
    "menu.shape.tabs", "Tabs",
    "menu.shape.register", "Register (tab hangs from the taskbar)",
    "menu.hotkeys.shiftdrag", "Drag a tab sideways: reorder desktops (like browser tabs)",
    "menu.newdesk", "New desktop…",
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
    "menu.help.changelog", "What's new (changelog)…",
    "menu.feedback.bug", "Report a bug (GitHub)…",
    "menu.feedback.idea", "Suggest an idea (GitHub)…",
    "menu.feedback.mailbug", "Report a bug by e-mail…",
    "menu.feedback.mail", "Send an idea or question by e-mail…",
    "menu.update.check", "Check for updates…",
    "menu.update.auto", "Check for updates daily",
    "menu.update.available", "Update {1} available…",
    "menu.about",      "About DeskTabs…",
    "about.title",     "About DeskTabs",
    "about.tagline",   "Clickable taskbar buttons for virtual desktops",
    "about.version",   "Version {1}",
    "about.author",    "by {1}",
    "about.license",   "License: GNU GPL v3 with attribution (see NOTICE). Source code freely available,`nwithout any warranty. Copies and modified versions must credit “DeskTabs by Henning Pähtz”.",
    "about.components", "Includes VirtualDesktopAccessor (MIT, Jari Pennanen){1}.`nIcon library: the Windows font “Segoe Fluent Icons”; icon names from the`nMicrosoft documentation (CC BY 4.0).",
    "about.ahk",       "and AutoHotkey v2 (GPL-2.0 or later)",
    "about.website",   "Website",
    "about.github",    "Project on GitHub",
    "about.feedback",  "Give feedback",
    "about.check",     "Check for updates",
    "about.close",     "Close",
    "update.none",     "DeskTabs {1} is up to date.",
    "update.found",    "Version {1} is available (installed: {2}).`n`nOpen the download page?",
    "update.error",    "Could not check for updates (no connection to GitHub).",
    "update.tip",      "DeskTabs {1} is available. Right-click the bar → Update…",
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
    UpdateHighlight()                        ; oeffnet auch das erste Zeit-Log-Segment
    ; Zeit-Log: Sperren/Entsperren des Bildschirms als Pause erkennen (immer
    ; registrieren, TimeLog kann zur Laufzeit ueber das Menue eingeschaltet werden)
    DllCall("Wtsapi32\WTSRegisterSessionNotification", "Ptr", A_ScriptHwnd, "UInt", 0)
    OnMessage(0x02B1, OnSessionChange)      ; WM_WTSSESSION_CHANGE
    BuildTray()
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
    for key in ["ShowIndex", "ColorCoding", "SnapToTaskbar", "TimeLog", "UpdateCheck", "ShowDividers", "ShowIcons", "Hotkeys", "ActiveBold", "ActiveShadow", "SwitchAlert", "AttentionDot", "DragToTab"] {
        v := IniRead(CONF["IniPath"], "View", key, "")
        if (v = "0" || v = "1")
            CONF[key] := Integer(v)
    }
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

HeadTextW(hdc, font, s) {
    old := DllCall("SelectObject", "Ptr", hdc, "Ptr", font, "Ptr")
    sz := Buffer(8, 0)
    DllCall("GetTextExtentPoint32W", "Ptr", hdc, "Str", s, "Int", StrLen(s), "Ptr", sz)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
    return NumGet(sz, 0, "Int")
}

HeadMeasure(wParam, lParam, msg, hwnd) {
    global gMenuCaption, gMenuAction
    kind := NumGet(lParam, 24, "UPtr")
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
        NumPut("UInt", w + Round(16 * s), lParam, 12)
        NumPut("UInt", Round(24 * s), lParam, 16)
        return 1
    }
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    w := HeadTextW(hdc, f[1], "DeskTabs") + Round(7 * s) + HeadTextW(hdc, f[2], APP_VERSION)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    NumPut("UInt", w + Round(16 * s), lParam, 12)                  ; itemWidth (Rest macht Windows)
    NumPut("UInt", Round(30 * s), lParam, 16)                      ; itemHeight
    return 1
}

HeadDraw(wParam, lParam, msg, hwnd) {
    global gMenuCaption, gMenuAction, gMenuActionCol
    kind := NumGet(lParam, 56, "UPtr")
    if (NumGet(lParam, 0, "UInt") != 1 || (kind != 0xDE5C && kind != 0xDE5D && kind != 0xDE5E))
        return
    static icon := 0
    f := HeadFonts(), s := A_ScreenDPI / 96
    hdc := NumGet(lParam, 32, "Ptr")
    l := NumGet(lParam, 40, "Int"), t := NumGet(lParam, 44, "Int"), r := NumGet(lParam, 48, "Int"), b := NumGet(lParam, 52, "Int")
    ; Grund: die Farbe, die Windows fuer das Menue gemalt hat (rechte obere Ecke der Zeile)
    bgc := DllCall("GetPixel", "Ptr", hdc, "Int", r - 1, "Int", t, "UInt")
    if (bgc = 0xFFFFFFFF)
        bgc := DllCall("GetSysColor", "Int", 4, "UInt")            ; COLOR_MENU
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
        NumPut("Int", l + Round(14 * s), "Int", t, "Int", l + Round(34 * s), "Int", b, rt)
        DllCall("DrawTextW", "Ptr", hdc, "Str", Chr(0xE72A), "Int", 1, "Ptr", rt, "UInt", 0x24)   ; Pfeil
        DllCall("SelectObject", "Ptr", hdc, "Ptr", f[1])
        NumPut("Int", l + Round(38 * s), "Int", t, "Int", r - Round(8 * s), "Int", b, rt)
        DllCall("DrawTextW", "Ptr", hdc, "Str", gMenuAction, "Int", -1, "Ptr", rt, "UInt", 0x24)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
        return 1
    }
    if (kind = 0xDE5D) {                    ; Desktop-Name: gut lesbares Mittelgrau statt blassem "deaktiviert"
        DllCall("SetBkMode", "Ptr", hdc, "Int", 1)
        old := DllCall("SelectObject", "Ptr", hdc, "Ptr", f[3], "Ptr")
        DllCall("SetTextColor", "Ptr", hdc, "UInt", 0x5C5C5C)
        rt := Buffer(16, 0)
        NumPut("Int", l + Round(20 * s), "Int", t, "Int", r, "Int", b, rt)
        DllCall("DrawTextW", "Ptr", hdc, "Str", gMenuCaption, "Int", -1, "Ptr", rt, "UInt", 0x24)   ; VCENTER|SINGLELINE
        DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
        return 1
    }
    ; Symbol in der Spalte, in der auch die anderen Menue-Symbole stehen
    isz := Round(14 * s)                       ; so gross wie die Symbole der anderen Eintraege
    if (!icon && FileExist(AppIconPath()))
        try icon := LoadPicture(AppIconPath(), "w" isz " h" isz " Icon1", &imgType)
    x := l + Round(3 * s)
    if (icon)
        DllCall("DrawIconEx", "Ptr", hdc, "Int", x, "Int", t + (b - t - isz) // 2, "Ptr", icon, "Int", isz, "Int", isz, "UInt", 0, "Ptr", 0, "UInt", 3)
    ; Texte auf gemeinsamer Grundlinie: Name fett, Version kleiner und grau
    tx := l + Round(20 * s)
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
    lgm := Menu()
    lgm.Add(T("menu.timelog.on"), ToggleView.Bind("TimeLog"))
    if (CONF["TimeLog"])
        lgm.Check(T("menu.timelog.on"))
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
    m.Add(T("menu.help"), HelpMenu())
    MenuGlyph(m, T("menu.help"), "E897")
    if (gUpdateTag != "")
        m.Add(T("menu.update.available", gUpdateTag), OpenReleasePage)
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

; Untermenue "Hilfe": Doku, Changelog, Feedback-Wege, Update-Pruefung
HelpMenu() {
    hm := Menu()
    hm.Add(T("menu.help.docs"), OpenDocs)
    MenuGlyph(hm, T("menu.help.docs"), "E8F1")
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
; ------------- Desktops anlegen, umbenennen, entfernen (wie die Aufgabenansicht) -------------
; Einstellungen haengen lesbar am Desktop-Namen. Damit sie ein Umbenennen ueberleben -
; auch eins in der Windows-Aufgabenansicht -, merkt sich [Ids] je Desktop-GUID den zuletzt
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
    for , sec in ["Colors", "Icons", "Short", "Compact"] {
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
TabSource(num) => LabelFor(num) "|" IsCompactDesk(num)
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
    gBuilding := true
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
    gBuilding := false
}

BuildBarAt() {
    global MyGui, BTNS, GUIW, GUIH, gTaskbarW, gLayout, gOrdCache
    gOrdCache := Map()
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
    global gPrevCount := cnt

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
        big := (icon != "" && (gCompact = "big" || gCompact = "bigtext"))   ; Symbol in Taskleisten-Groesse
        if (icon != "" && gCompact = "icon")
            label := ""                          ; kleinste Stufe: nur das Symbol, klein
        if (IsCompactDesk(num))                  ; ruhendes Projekt: nur Symbol, sonst Kuerzel/Nummer
            label := (icon != "") ? "" : ((ShortNameFor(num) != "") ? ShortNameFor(num) : String(num + 1))
        iw := (icon != "") ? (big ? bigSize : iconSize) : 0
        tw := (label != "") ? MeasureText(mG, font, sf, label) : 0
        w := px(gPadX) * 2 + iw + tw + ((iw && tw) ? iconGap : 0)
        if (iw && label = "")
            w := Max(btnH, iw + px(12) * 2)       ; quadratische Kachel wie die Taskleisten-Buttons
        badge := BadgeText(num, icon, label)
        if (badge != "" && iw && label != "")
            w += px(5)                            ; das Abzeichen ragt links uebers Symbol: dort etwas mehr Luft
        BTNS.Push(Map("num", num, "label", label, "icon", icon, "iw", iw, "x", x, "w", w, "hover", false, "badge", badge
            , "src", TabSource(num)))
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
    RenderBar(true)
    MyGui.Show(Format("x{1} y{2} w{3} h{4} NoActivate", posX, posY, GUIW, GUIH))
    UpdateStripe()

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
    global gReorderFrom
    sig := gReorderFrom "|" RegisterOn() "|" gCurrent "|" gTheme "|" CONF["ActiveStyle"] "|" CONF["ColorCoding"] "|" CONF["ShowDividers"] "|" gGripHover "|" gAlertNum "|" gAlertPhase "|" AttentionSig() "|" (gDragHwnd ? gDragTipNum : -1) "|" gConfirmNum "|" gConfirmPhase
    for item in BTNS
        sig .= (item["hover"] ? "h" : "-") item["icon"]
    if (!force && sig = gRenderSig)
        return
    gRenderSig := sig
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
    font := MakeFont(), fontBold := MakeFont(true), sf := MakeFormat()
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
        if (item["label"] != "")
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
    wdc := DllCall("GetDC", "Ptr", MyGui.Hwnd, "Ptr")
    DllCall("BitBlt", "Ptr", wdc, "Int", 0, "Int", 0, "Int", GUIW, "Int", GUIH, "Ptr", gBarDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
    DllCall("ReleaseDC", "Ptr", MyGui.Hwnd, "Ptr", wdc)
    DllCall("InvalidateRect", "Ptr", MyGui.Hwnd, "Ptr", 0, "Int", 0)   ; ohne Loeschen
    DllCall("UpdateWindow", "Ptr", MyGui.Hwnd)
    DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
    DllCall("gdiplus\GdipDeleteFont", "Ptr", fontBold)
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
        fgDesk := (fg && fg != barHwnd) ? VD("GetWindowDesktopNumber", "Ptr", fg, "Int") : -1
        VD("GoToDesktopNumber", "Int", target)
        if (fgDesk >= 0 && VD("GetWindowDesktopNumber", "Ptr", fg, "Int") != fgDesk)
            VD("MoveWindowToDesktopNumber", "Ptr", fg, "Int", fgDesk)
    }
    gSwitching := false
    gSelfTick := A_TickCount
    UpdateHighlight()
    SetTimer(FocusTopWindow, -80)     ; kurz warten, bis Windows den Wechsel abgeschlossen hat
}

; Nach einem Wechsel das oberste Fenster des Ziel-Desktops nach vorne holen. Windows laesst
; den Fokus sonst gern an einem unsichtbaren Fenster des alten Desktops haengen; Programme
; mit Fenstern auf mehreren Desktops (Firefox, Chrome) versuchen dann nach vorne zu kommen,
; werden abgewiesen und blinken - samt Taskleisten-Knopf auf fremden Desktops.
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

BtnClick(num, *) {
    ; Klick auf den bereits aktiven Desktop -> Task-Ansicht oeffnen
    if (num = GetCurrentDesktop()) {
        if (CONF["ClickActiveTaskView"]) {
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
    if (BarMouseX() >= gLayout["gripW"])     ; nur der Griff zieht die Leiste; ein Tab wird - wie
        return ReorderDrag()                 ; ein Browser-Tab - beim Ziehen umsortiert, ein Klick bleibt ein Klick
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
; Braucht die selbst gebaute DLL mit dem Export MoveDesktop (siehe vda\move_desktop.rs).
ReorderDrag() {
    global BTNS, gLayout, gReorderFrom, gSkipUpUntil, MyGui
    item := ItemAtX(BarMouseX())
    if (!item || !CanMoveDesktop())
        return
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
        if (!dragging && Abs(mx - sx) > px(6)) {
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
        c := it["x0"] + it["w"] / 2
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
    global MyGui, gSkipUpUntil, gReorderFrom
    if (!MyGui || (hwnd != MyGui.Hwnd && DllCall("GetParent", "Ptr", hwnd, "Ptr") != MyGui.Hwnd))
        return
    if (gReorderFrom >= 0 || A_TickCount < gSkipUpUntil) {   ; Ende eines Umsortier-Ziehens, kein Klick
        gSkipUpUntil := 0
        return 0
    }
    item := ItemAtX(BarMouseX())
    if (item && GetKeyState("Shift") && item["num"] != GetCurrentDesktop()) {
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

UpdateHighlight() {
    global BTNS, gCurrent
    prev := gCurrent
    gCurrent := GetCurrentDesktop()
    if (prev >= 0 && gCurrent >= 0 && gCurrent != prev) {
        CheckForeignSwitch(prev, gCurrent)
        global gLastDesk, gDeskSince, gAttention
        if (A_TickCount - gDeskSince >= Max(1, CONF["TimeLogMinSec"]) * 1000)
            gLastDesk := prev                  ; nur echte Aufenthalte, keine Durchfahrten
        gDeskSince := A_TickCount
        if (gAttention.Has(gCurrent))
            gAttention.Delete(gCurrent)        ; angekommen: Punkt erledigt
    }
    LogDesktop(gCurrent)             ; Zeit-Log: Segmentwechsel bei Desktop-Wechsel
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
        for item in BTNS {
            if (item["src"] != TabSource(item["num"])) {
                nameChanged := true
                break
            }
        }
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
    if (idx < GetDesktopCount())
        SwitchToDesktop(idx)
}

; Lesbare Beschriftung eines Modifikators, z.B. "Strg + Windows + 1 … 0"
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
    static cache := Map()
    stamp := ""
    try stamp := FileGetTime(CONF["IniPath"], "M")
    if (cache.Has(sec) && cache[sec]["stamp"] = stamp)
        return cache[sec]["map"]
    m := Map()
    for key, val in ReadIniSection(sec)
        m[NormName(key)] := val
    cache[sec] := Map("stamp", stamp, "map", m)
    return m
}

; Abschnitt selbst aus der Datei lesen. IniRead geht ueber die Windows-INI-
; Schnittstelle und versteht kein UTF-8; Namen mit Umlauten kaemen dort verstuemmelt
; an. Deshalb: erst als UTF-8 lesen, sonst in der Systemcodierung.
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
IniLookup(sec, name) {
    v := IniRead(CONF["IniPath"], sec, name, "")
    if (v != "")
        return v
    m := IniSectionMap(sec)
    key := NormName(name)
    return m.Has(key) ? m[key] : ""
}

IniGet(sec, key, default) {
    val := IniRead(CONF["IniPath"], sec, key, "")
    return (val = "") ? default : val + 0
}
IniSet(sec, key, val) {
    global gIniStamp
    IniWrite(val, CONF["IniPath"], sec, key)
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
    global gIniStamp
    try IniDelete(CONF["IniPath"], sec, key)
    try gIniStamp := FileGetTime(CONF["IniPath"], "M")
}

OnExitCleanup(*) {
    global VDA, gWinEventHook, gWinEventCb, gDragHook, gDragCb
    LogClose()                                  ; Zeit-Log: letztes Segment abschliessen
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
