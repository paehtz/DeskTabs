# DeskTabs: Neu in dieser Version
<!-- Pro Version ein Abschnitt "## x.y.z", darunter kurze Punkte "- ...". Jeder Punkt sagt, was der Nutzer jetzt Neues tun kann oder was besser läuft, und wie er es findet; das Schlagwort am Anfang **fett**. DeskTabs zeigt die Abschnitte nach einem Update an (neueste zuerst, alle übersprungenen Versionen). -->

## 1.1.19
- **Fenster bleiben normal:** Nach einem Desktop-Wechsel konnten Fenster dauerhaft „immer im Vordergrund“ werden, sodass sich andere nicht mehr nach vorne holen ließen. Das passiert nicht mehr. Wer es erlebt hat: Ein Neustart der betroffenen Programme stellt sie wieder normal.

## 1.1.18
- **Timer statt Gespräch:** Aus „Gespräch starten“ wird **Timer starten** (Rechtsklick auf einen Tab oder Strg + Win + T). Er ist für alles, was einem Kunden gehört, Dich aber zwischen Desktops wechseln lässt: ein Telefonat, bei dem Du nebenbei woanders nachsiehst, oder Arbeit mit Werkzeugen auf mehreren Desktops. Die ganze Zeit zählt für den Desktop, für den Du ihn gestartet hast. Beim Beenden kannst Du eine **Notiz** eingeben, etwa „Telefonat mit Christian“; sie steht im Zeit-Log und in der Zeit-Auswertung. Deine letzten Notizen schlägt DeskTabs je Desktop als Bubbles vor: ein Klick übernimmt sie, ✎ benennt sie um (auf Wunsch auch in früheren Einträgen), × entfernt sie, und per Rechtsklick heftest Du feste Einträge an.
- **Schnellerer Desktop-Wechsel:** DeskTabs wartet nach einem Wechsel nicht mehr auf Windows, um Fenster und Leiste herzurichten. Außerdem springt ein Klick auf einen Tab nicht mehr zum vorherigen Desktop zurück, wenn dessen zuletzt vorderstes Fenster inzwischen auf einem anderen Desktop liegt.

## 1.1.17
- **Zeit-Auswertung:** Im Menü steht jetzt **Zeit-Auswertung…**. Sie zeigt im Browser, wie viel Zeit Du auf welchem Desktop und Unterprojekt verbracht hast. Du blätterst Tag für Tag mit den Pfeiltasten oder wählst Woche, Monat, Jahr oder einen freien Zeitraum. Jeder Tag erscheint als farbige Zeitleiste, dazu Stunden je Tag, Deine typischen Arbeitszeiten über den Tag, Wochentage, alle Gespräche und der Vergleich zur Vorwoche. Desktops lassen sich ausblenden, jede Tabelle geht als CSV direkt nach Excel, und **Drucken / PDF** macht daraus einen Stundennachweis. Alles bleibt auf Deinem Rechner.
- **Fenster mit einem Klick auf allen Desktops:** **Umschalt + Klick auf ≡** zeigt das aktive Fenster auf allen Desktops, nur dieses Fenster, nicht die ganze App. **Umschalt + Klick auf einen Tab** holt es zurück: Danach ist es nur noch auf diesem Desktop zu sehen, auch auf dem, auf dem Du gerade bist.

## 1.1.16
- **Jeder Desktop behält seine Fenster vorne:** Fenster, die auf allen Desktops liegen, drängen sich nicht mehr überall nach vorne. Kommst Du auf einen Desktop zurück, liegen dort wieder die Fenster vorne, mit denen Du dort zuletzt gearbeitet hast, auf allen Monitoren, und das zuletzt benutzte hat den Fokus. Abschaltbar unter **Weitere Einstellungen**.
- **Gespräche mit Timer:** Ruft ein Kunde an, startest Du per Rechtsklick auf seinen Tab **Gespräch starten** oder mit **Strg + Win + T**. Über dem Tab läuft ein Timer, und das Zeit-Log ordnet die ganze Gesprächszeit diesem Kunden zu, auch wenn Du zwischendurch auf anderen Desktops nachschaust. Ein Klick auf den Timer beendet es.
- **Genaueres Zeit-Log:** Pausen stehen jetzt als eigene Zeilen im Log (keine Eingabe, gesperrt, Ruhezustand, DeskTabs aus), Aufenthalte über Mitternacht werden geteilt, und jede Zeile trägt eine feste Desktop-Kennung. Zum Testen lässt sich das Log unter **Weitere Einstellungen › Zeit-Log** pausieren.
- **DeskTabs mit KI anpassen:** Im Programmordner liegt jetzt eine Anleitung für KI-Assistenten wie Claude Code oder Codex. Sag Deinem Assistenten einfach, was Du willst, etwa „gib dem Desktop Acme eine grüne Farbe“, und er weiß, wo er es einstellt. Zu finden unter **Hilfe › Anleitung für KI-Assistenten**.
- **Umlaute bleiben heil:** Desktop-Namen mit Umlauten in den Einstellungen werden nicht mehr verstümmelt, auch wenn ein Programm die Datei bearbeitet hat.
- **Umsortieren ohne Ruckeln:** Auch beim ersten Verschieben eines Tabs nach dem Start gleitet er ruhig an seinen Platz.

## 1.1.15
- **Hinterlässt keinen Ballast:** Nach einem Update mit einem Klick räumt DeskTabs die heruntergeladene Setup-Datei wieder weg. Deine Festplatte bleibt sauber.

## 1.1.14
- **Nichts verpassen nach längerer Pause:** Hast Du mehrere Updates ausgelassen, zeigt Dir dieses Fenster die Neuerungen aller verpassten Versionen untereinander. Wird es länger als der Bildschirm, scrollst Du einfach mit dem Mausrad.

## 1.1.13
- **Updates mit einem Klick:** Du musst nicht mehr selbst nach neuen Versionen suchen. Gibt es eine, erscheint links über der Taskleiste ein Hinweis. Ein Klick auf **Jetzt aktualisieren** genügt: DeskTabs lädt die neue Version, prüft sie, installiert sie und startet neu. Deine Desktops, Farben, Symbole und Zeit-Logs bleiben, wie sie sind.
- **Immer wissen, was neu ist:** Nach jedem Update zeigt Dir dieses Fenster, was Du jetzt Neues machen kannst. Du findest es jederzeit wieder unter **Hilfe → Neu in dieser Version**.
- **Lieber selbst entscheiden?** Unter **Weitere Einstellungen** schaltest Du den Update-Hinweis ab.

## 1.1.12
- **Mehrere Projekte auf einem Desktop sauber trennen:** Arbeitest Du auf einem Desktop an mehreren kleinen Projekten, etwa für verschiedene Kunden, legst Du dafür **Unterprojekte** an: **Alt + Klick** auf den Tab. Das aktive Unterprojekt steht klein unter dem Desktop-Namen, und das **Zeit-Log** führt es in einer eigenen Spalte. So siehst Du später genau, wie viel Zeit in welches Projekt geflossen ist.
- **Unterprojekt schnell wechseln:** Ein **Klick auf den aktiven Tab** öffnet eine kleine Auswahl direkt darüber.
- **Keine versehentliche Taskansicht mehr:** Ein Klick auf den aktiven Tab öffnet nicht mehr die Windows-Taskansicht. Wer sie zurückhaben möchte, setzt `ClickActiveTaskView = 1` in der settings.ini.
- **Menüs wie in Windows 11:** hell, ruhig und mit klaren Symbolen.
- **Zuverlässiger:** Die Leiste bleibt sichtbar, wenn Du das Startmenü öffnest. Das Umsortieren per Ziehen kann nicht mehr hängen bleiben, und beim Umschalten flackert nichts mehr.
