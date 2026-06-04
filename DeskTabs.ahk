#Requires AutoHotkey v2.0
#SingleInstance Force
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

; ---------------------------- Konfiguration ---------------------------------
global CONF := Map(
    "DllPath",        A_ScriptDir "\VirtualDesktopAccessor.dll",
    "IniPath",        A_ScriptDir "\settings.ini",
    "FontName",       "Segoe UI",
    "FontSizePt",     10,
    "PadX",           14,      ; Innenabstand links/rechts im Button (px @100%)
    "Gap",            9,       ; Abstand zwischen Buttons (px @100%) - Platz fuer Trennstrich
    "GripW",          16,      ; Breite des Ziehgriffs (px @100%)
    "SwitchMethod",   "native", ; "native" = Strg+Win+Pfeil nachbilden (Fenster bleiben stabil)
                               ; "dll" = GoToDesktopNumber (schneller, nimmt aber Fenster mit)
    "ColDivider",     0xCFCFCF, ; Trennstrich-Farbe (sanft, Material)
    "DividerInsetY",  9,       ; vertikaler Abstand des Trennstrichs oben/unten (px @100%)
    "DockMode",       "on",    ; "on"    = auf der Taskleiste (optisch integriert, kann minimal flackern)
                               ; "above" = direkt ueber der Taskleiste (flackerfrei)
    "OffsetX",        10,      ; Abstand vom linken Bildschirmrand (px @100%)
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
    "ShowIndex",      1,       ; 1 = Nummer vor dem Namen ("3 · Wolf Automobile")
    "ColorCoding",    1,       ; 1 = farbiger Akzentbalken pro Desktop unten am Button
    "AccentBarH",     3,       ; Hoehe des Farbbalkens (px @100%)
    "ColHoverBg",     0xDCDCDC, ; Button-Hintergrund beim Drueberfahren (Hover)
    "ColHoverTx",     0x1F1F1F,
    "AutoHideFullscreen", 1,   ; 1 = Leiste ausblenden, wenn Vollbild-App im Vordergrund
    "ClickActiveTaskView", 1,  ; 1 = Klick auf aktiven Desktop oeffnet Task-Ansicht (Win+Tab)
    "Palette",        [0xE5471D, 0x2E7D32, 0x1565C0, 0x6A1B9A, 0xEF6C00, 0x00838F, 0xC2185B, 0x558B2F],
    "MaxNameLen",     22       ; Namen laenger als das werden gekuerzt
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
    "ColHoverBg",    0xDCDCDC,
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
    "ColHoverBg",    0x3A3A3A,   ; etwas heller als die Leiste
    "ColHoverTx",    0xFFFFFF,
    "ColDivider",    0x3F3F3F
)
global gTheme := ""             ; aktuell angewandtes Theme ("light"/"dark")

global SCALE := A_ScreenDPI / 96
global VDA := 0
global BTNS := []            ; Array von Maps {ctrl, num}
global GRIP := 0
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

; ------------------------------- Start --------------------------------------
Main()

Main() {
    global VDA, MyGui
    OnError(LogErr)
    if !FileExist(CONF["DllPath"]) {
        MsgBox("VirtualDesktopAccessor.dll nicht gefunden:`n" CONF["DllPath"], "DeskTabs", 0x10)
        ExitApp
    }
    VDA := DllCall("LoadLibrary", "Str", CONF["DllPath"], "Ptr")
    if !VDA {
        MsgBox("DLL konnte nicht geladen werden.", "DeskTabs", 0x10)
        ExitApp
    }
    ApplyTheme()                             ; Farbsatz passend zum Windows-Theme
    BuildBar()
    ApplyWindowHooks()                       ; Pin auf alle Desktops + Change-Hook
    OnMessage(MSG_VD_CHANGED, OnDesktopChanged)
    if (CONF["WheelSwitch"])
        OnMessage(0x020A, OnWheel)          ; WM_MOUSEWHEEL
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
    UpdateHighlight()
    BuildTray()
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

GetDesktopName(num) {
    name := GetDesktopNameRaw(num)
    if (StrLen(name) > CONF["MaxNameLen"])
        name := SubStr(name, 1, CONF["MaxNameLen"] - 1) "…"
    return name
}

; Anzeige-Label inkl. optionalem Nummern-Praefix ("3 · Wolf Automobile")
LabelFor(num) {
    return (CONF["ShowIndex"] ? (num + 1) " · " : "") GetDesktopName(num)
}

; Farbe fuer den Akzentbalken eines Desktops. Palette nach Index, optional per
; settings.ini [Colors] mit Desktop-Name ueberschreibbar (z.B.  T&K Eisleben=E5471D )
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
BuildBar() {
    global MyGui, BTNS, GRIP, GUIW, GUIH, gBuilding
    if (gBuilding)              ; verschachtelten Neuaufbau verhindern (Geometrie-Race)
        return
    gBuilding := true
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

    margin := px(3)
    accH := px(CONF["AccentBarH"])
    reserve := CONF["ColorCoding"] ? (accH + px(2)) : 0   ; Platz unter dem Button fuer den Farbbalken
    btnH := tbH - 2 * margin - reserve
    if (btnH < px(20))
        btnH := px(20)

    cnt := GetDesktopCount()
    if (cnt < 1)
        cnt := 1

    ; Griff (zum Verschieben)
    GRIP := MyGui.Add("Text", Format("x0 y0 w{1} h{2} +Center +0x200 Background{3} c{4}"
        , px(CONF["GripW"]), btnH, Fmt(CONF["ColGripBg"]), Fmt(CONF["ColGripTx"])), "≡")

    dw := Max(1, px(1))                       ; Trennstrich-Breite
    divH := btnH - 2 * px(CONF["DividerInsetY"])
    if (divH < px(8))
        divH := btnH
    divY := margin + (btnH - divH) // 2

    x := px(CONF["GripW"]) + px(CONF["Gap"])
    Loop cnt {
        num := A_Index - 1
        name := LabelFor(num)
        ; Erst auto-breit anlegen, um Textbreite zu messen
        ; +0x200 = SS_CENTERIMAGE (vertikal zentriert), +0x80 = SS_NOPREFIX (& woertlich zeigen)
        c := MyGui.Add("Text", Format("x{1} y{2} +Center +0x200 +0x80 Background{3} c{4}"
            , x, margin, Fmt(CONF["ColInactiveBg"]), Fmt(CONF["ColInactiveTx"])), name)
        cw := 0, ch := 0
        c.GetPos(, , &cw, &ch)
        w := cw + px(CONF["PadX"]) * 2
        c.Move(x, margin, w, btnH)
        c.OnEvent("Click", BtnClick.Bind(num))
        BTNS.Push(Map("ctrl", c, "num", num, "hover", false))
        ; Farb-Akzentbalken UNTER dem Button (ueberlappungsfrei, Tab-Indikator-Stil)
        if (CONF["ColorCoding"]) {
            ac := MyGui.Add("Text", Format("x{1} y{2} w{3} h{4} Background{5}"
                , x, margin + btnH + px(1), w, accH, Fmt(DesktopColor(num))))
            ac.OnEvent("Click", BtnClick.Bind(num))
        }
        x += w
        ; Trennstrich zwischen den Buttons (nicht nach dem letzten)
        if (A_Index < cnt) {
            gap := px(CONF["Gap"])
            divX := x + (gap - dw) // 2
            MyGui.Add("Text", Format("x{1} y{2} w{3} h{4} Background{5}"
                , divX, divY, dw, divH, Fmt(CONF["ColDivider"])))
            x += gap
        }
    }
    x += px(CONF["Gap"])                       ; etwas Luft am rechten Rand

    GUIW := x
    GUIH := tbH

    ; Position: aus settings.ini, sonst Standard = unten links.
    ; "above" => direkt ueber der Taskleiste (sicher sichtbar)
    ; "on"    => auf der Taskleiste
    defX := tbX + px(CONF["OffsetX"])
    defY := (CONF["DockMode"] = "above") ? (tbY - GUIH) : tbY
    posX := IniGet("Position", "X", defX)
    posY := IniGet("Position", "Y", defY)
    posX := ClampX(posX), posY := ClampY(posY, GUIH)

    GRIP.OnEvent("Click", (*) => 0)   ; Klick auf Griff: nichts (Ziehen via LBUTTONDOWN)
    MyGui.Show(Format("x{1} y{2} w{3} h{4} NoActivate", posX, posY, GUIW, GUIH))

    ; Ziehen am Griff
    OnMessage(0x0201, OnLButtonDown)  ; WM_LBUTTONDOWN
    gBuilding := false
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
    global gSwitching
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
        VD("GoToDesktopNumber", "Int", target)
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
    ; Folgeticks ignorieren, solange ein Wechsel laeuft -> kein Stau, knackiger
    if (gSwitching)
        return 0
    delta := (wParam >> 16) & 0xFFFF
    if (delta > 0x7FFF)
        delta -= 0x10000
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

IsOverBar(mx, my) {
    global MyGui, GUIW, GUIH
    x := 0, y := 0, w := 0, h := 0
    MyGui.GetPos(&x, &y, &w, &h)
    return (mx >= x && mx <= x + w && my >= y && my <= y + h)
}

OnLButtonDown(wParam, lParam, msg, hwnd) {
    global GRIP, MyGui
    if (hwnd != GRIP.Hwnd)
        return
    ; Natives Fenster-Ziehen anstossen
    PostMessage(0x00A1, 2, 0, , "ahk_id " MyGui.Hwnd)   ; WM_NCLBUTTONDOWN, HTCAPTION
    SetTimer(SavePosDeferred, -400)
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
; Faerbt einen Button nach Zustand: aktiv > hover > inaktiv
PaintButton(item) {
    global gCurrent
    if (item["num"] = gCurrent) {
        bg := CONF["ColActiveBg"]
        tx := CONF["ColActiveTx"]
    } else if (item["hover"]) {
        bg := CONF["ColHoverBg"]
        tx := CONF["ColHoverTx"]
    } else {
        bg := CONF["ColInactiveBg"]
        tx := CONF["ColInactiveTx"]
    }
    c := item["ctrl"]
    c.Opt("+Background" Fmt(bg) " c" Fmt(tx))
    DllCall("InvalidateRect", "Ptr", c.Hwnd, "Ptr", 0, "Int", 1)
}

UpdateHighlight() {
    global BTNS, gCurrent
    gCurrent := GetCurrentDesktop()
    for item in BTNS
        PaintButton(item)
}

; Hover: Button unter dem Mauszeiger leicht aufhellen
HoverTick() {
    global MyGui, BTNS, gHidden
    if (gHidden)
        return
    MouseGetPos(, , &winId, &ctrlHwnd, 2)
    overOur := (winId = MyGui.Hwnd)
    for item in BTNS {
        h := (overOur && ctrlHwnd = item["ctrl"].Hwnd)
        if (h != item["hover"]) {
            item["hover"] := h
            PaintButton(item)
        }
    }
}

; Vollbild-App im Vordergrund -> Leiste ausblenden, sonst wieder zeigen
FullscreenTick() {
    global MyGui, gHidden
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

IsForegroundFullscreen() {
    fg := DllCall("GetForegroundWindow", "Ptr")
    if (!fg)
        return false
    cls := ""
    try cls := WinGetClass("ahk_id " fg)
    if (cls = "WorkerW" || cls = "Progman" || cls = "Shell_TrayWnd" || cls = "")
        return false
    wr := Buffer(16, 0)
    DllCall("GetWindowRect", "Ptr", fg, "Ptr", wr)
    wl := NumGet(wr, 0, "Int"), wt := NumGet(wr, 4, "Int")
    wri := NumGet(wr, 8, "Int"), wb := NumGet(wr, 12, "Int")
    hMon := DllCall("MonitorFromWindow", "Ptr", fg, "UInt", 2, "Ptr")  ; DEFAULTTONEAREST
    mi := Buffer(40, 0)
    NumPut("UInt", 40, mi, 0)
    DllCall("GetMonitorInfo", "Ptr", hMon, "Ptr", mi)
    ml := NumGet(mi, 4, "Int"), mt := NumGet(mi, 8, "Int")
    mr := NumGet(mi, 12, "Int"), mb := NumGet(mi, 16, "Int")
    tol := 2
    return (Abs(wl - ml) <= tol && Abs(wt - mt) <= tol && Abs(wri - mr) <= tol && Abs(wb - mb) <= tol)
}

AssertTop() {
    global MyGui, gHidden
    if (gHidden)
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
    if (GetDesktopCount() != BTNS.Length) {
        BuildBar()
        ApplyWindowHooks()
    } else {
        ; Hat sich ein Name geaendert? -> KOMPLETT neu bauen, damit die Button-BREITEN
        ; zur neuen Textlaenge passen. Reines c.Text := ... laesst die Breite stehen
        ; -> lange Namen werden abgeschnitten und die Abstaende kollabieren.
        nameChanged := false
        for item in BTNS {
            if (item["ctrl"].Text != LabelFor(item["num"])) {
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
    A_TrayMenu.Add("Leiste neu aufbauen", (*) => Refresh())
    A_TrayMenu.Add("Position zuruecksetzen", ResetPos)
    A_TrayMenu.Add()
    A_TrayMenu.Add("Beenden", (*) => ExitApp())
    TraySetIcon("shell32.dll", 27)
    A_IconTip := "DeskTabs"
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
    IniWrite(val, CONF["IniPath"], sec, key)
}

OnExitCleanup(*) {
    global VDA, gWinEventHook, gWinEventCb
    if (gWinEventHook)
        DllCall("UnhookWinEvent", "Ptr", gWinEventHook)
    if (gWinEventCb)
        CallbackFree(gWinEventCb)
    if (VDA)
        DllCall("FreeLibrary", "Ptr", VDA)
}
OnExit(OnExitCleanup)
