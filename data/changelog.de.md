# DeskTabs: Neu in dieser Version
<!-- Pro Version ein Abschnitt "## x.y.z", darunter kurze Punkte "- ...". Jeder Punkt sagt, was der Nutzer jetzt Neues tun kann oder was besser läuft, und wie er es findet; das Schlagwort am Anfang **fett**. DeskTabs zeigt die Abschnitte nach einem Update an (neueste zuerst, alle übersprungenen Versionen). -->

## 1.1.25
- **Fensterbereiche per Tastatur und Ziehen:** Strg + Alt + Ziffernblock legt das aktive Fenster in einen Bereich seines Bildschirms, ein zweiter Druck auf dieselbe Taste schaltet zur nächsten Breite. Ziehst Du ein Fenster mit gedrückter Strg + Alt, zeigt DeskTabs den Zielbereich und legt es dort ab. Strg + Alt + Bild↓ minimiert, Strg + Alt + Bild↑ holt zurück. Die Bereiche je Taste stellst Du unter *Weitere Einstellungen* › *Fensterbereiche* ein: Stufen anklicken und ändern, zwischen Tasten verschieben, und die passenden Werte misst das Fenster selbst, wenn Du es oder ein anderes Fenster zurechtziehst (mit Strg in ganzen Prozent).
- **Übersteht Explorer-Neustarts:** Startete der Windows-Explorer neu (Absturz, Task-Manager, manche Updates), blieb DeskTabs stehen und reagierte nicht mehr, samt Tastenkürzeln. Jetzt läuft die Leiste einfach weiter.
- **Fenster landen sauber auf ihrem Desktop:** Verteilt ein Programm beim Start seine Fenster selbst auf die Desktops (etwa Chrome beim Wiederherstellen), blieben einzelne auf dem aktuellen Desktop sichtbar. DeskTabs sortiert solche Fenster jetzt gleich richtig ein.
- **Offene Fragen in Orange:** Endet eine Claude-Antwort nur mit einer Frage, ohne Dialog zum Anklicken, zeigt der Tab einen orangen statt eines roten Punkts. Rot bleibt für echte Dialoge wie Freigaben und Auswahlfenster. Läufe geplanter Aufgaben und archivierte Chats zeigen keinen Punkt mehr.
- **Welcher Chat wartet?** Fährst Du mit der Maus über einen Tab mit Claude-Punkt, nennt die Kurzinfo die Chats, die dort auf Dich warten oder gerade laufen.
- **Claude-Status bleibt nicht mehr hängen:** Zeigte ein Tab weiter „läuft“, obwohl alle Chats dort fertig waren, korrigiert sich das jetzt spätestens nach 15 Sekunden.

## 1.1.24
- **Leiste am Start-Knopf:** Zieh die Leiste auf der Taskleiste nach rechts an das Windows-Symbol, dann rastet sie links davon ein, mit einem Trennstrich. Sie rückt mit, wenn Programme in der Taskleiste dazukommen oder gehen, und schiebt sich nie über die Symbole; wird es eng, werden die Tabs kompakter. Wegziehen löst sie wieder. Auch unter *Weitere Einstellungen* › *Links vom Start-Knopf andocken*.
- **Claude-Hauptfenster auf dem Standard-Desktop:** Beim Ordnen und Verteilen kommen dort die Hauptfenster aller Claude-Instanzen maximiert auf den Hauptbildschirm, die Chats nebeneinander auf die Bildschirme daneben. Strg + Alt + Klick auf den Griff ≡ ordnet den Standard-Desktop danach gleich so an.
- **Kein Stillstand mehr durch hängende Programme:** Reagierte ein Programm nicht mehr (zuletzt WhatsApp), konnte DeskTabs beim Desktop-Wechsel mit hängen bleiben, samt Tastenkürzeln. Hängende Fenster lässt DeskTabs jetzt aus.
- **Kein Fehlerfenster vom Status-Plugin:** Bei sehr langen Claude-Antworten zeigte das Status-Plugin für Claude Code ein Fehlerfenster. Behoben.
- **Verschobene Chats verschwinden zuverlässig:** Blieb ein Chat nach dem Verschicken auf seinen Desktop hier noch sichtbar, räumt DeskTabs ihn jetzt selbst weg.

## 1.1.23
- **Claude-Status im Tab:** Ein runder Punkt oben rechts im Tab zeigt, ob eine Claude-Sitzung auf Deine Entscheidung wartet (rot, dazu ein roter Rahmen), fertig ist (gelb, bis Du den Desktop besuchst) oder gerade läuft (grau, pulsierend). Sitzungen ohne eigenes Fenster zählen zum Standard-Desktop; nur mit eingeschalteten Claude-App-Funktionen.
- **Status-Plugin für Claude Code:** Rechtsklick auf die Claude-Kachel › *Status-Plugin für Claude Code einrichten*. Mit dem Plugin melden die Claude-Sitzungen ihren Stand sofort selbst; endet eine Antwort mit einer Frage, wird der Tab rot.
- **Standard-Desktop beim Verteilen:** Der Hauptbildschirm bleibt frei für das Claude-Hauptfenster, die Chats kommen auf die Nebenbildschirme.
- **Taskleisten-Hinweis jetzt blau:** Blinkt ein Programm auf einem anderen Desktop, zeigt dessen Tab einen blauen Punkt statt eines orangen, damit es sich klar von den Claude-Signalen abhebt.
- **Standard-Desktop:** Tab-Menü › *Als Standard-Desktop festlegen* (ohne Festlegung gilt ein Desktop namens „Standard“). Entfernst Du einen Desktop, wandern seine Fenster dorthin statt auf den Nachbarn, und beim Verteilen der Claude-Chats landen Chats ohne passenden Desktop dort.
- **Geschlossene Desktops wieder öffnen:** Entfernst Du einen Desktop über sein Tab-Menü, merkt sich DeskTabs ihn. Unter ≡ › *Neuer Desktop* kannst Du ihn später per Knopf wieder öffnen, mit Name, Farbe, Symbol, Kürzel und Anordnungen, und er erscheint an seiner alten Stelle.
- **Ruhiger Desktop-Wechsel:** Wen beim Wechsel mit Strg+Win+Pfeil das Schieben der Bildschirme stört, schaltet unter *Weitere Einstellungen* „Strg+Win+Pfeil ohne Animation wechseln“ ein. Dann springt DeskTabs direkt zum Nachbar-Desktop, die übrigen Windows-Animationen bleiben an.
- **Mehr Platz für Claude-Chats auf dem Hauptbildschirm:** Beim Ordnen (Alt + Klick auf die Claude-Kachel) bekommt ein Chat auch auf dem Hauptbildschirm ein Drittel der Breite statt eines Viertels. Drei Chats füllen den Bildschirm, erst ab vier werden sie schmaler. Ein Chat mit Seitenbrowser zählt wie zwei: neben einem zweiten Chat bekommt er zwei Drittel.
- **Seitenbrowser auf dem Hauptbildschirm:** Liegt dort ein Claude-Chat mit offenem Seitenbrowser, bekommen die anderen Chats beim Ordnen nur die schmalste Spalte (ein Fünftel bei 3440 Pixeln), der Seitenbrowser den ganzen Rest.
- **Chats hierher holen:** Strg + Alt + Klick auf den Tab des aktuellen Desktops holt alle Chats mit dem Projektkürzel des Desktops von anderen Desktops hierher. Strg + Alt + Klick auf einen anderen Tab schickt die passenden Chats des aktuellen Desktops dorthin, Strg + Alt + Klick auf den Griff ≡ schickt alle Chats des aktuellen Desktops auf den Desktop ihres Kürzels. Ideal nach dem Start der Claude-App, die alle Chats auf einem Desktop öffnet. Von selbst wandert kein Fenster.
- **Mehrere Projektkürzel je Desktop:** Rechtsklick auf die Claude-Kachel › *Projektkürzel dieses Desktops*. Mehrere Kürzel durch Komma trennen, etwa für einen Desktop mit mehreren privaten Projekten.
- **Alle Chatfenster schließen:** Rechtsklick auf die Claude-Kachel › *Alle Chatfenster schließen*. Schließt die ausgedockten Fenster aller Claude-Instanzen auf allen Desktops, nur die Hauptfenster bleiben. So startet die Claude-App danach nicht mit einem Schwall alter Fenster.
- **Verteilen per Klick:** Strg + Umschalt + Klick auf die Claude-Kachel verteilt alle Chats des Desktops auf die Bildschirme, wie *Auf Bildschirme verteilen* im Menü.
- **Ausgedockte Bereiche bleiben im Hintergrund:** Ein ausgedockter Browser oder Dateibereich der Claude-App wird beim Ordnen und Verteilen nicht mehr als Chat in die Spalten gesetzt, sondern maximiert hinter die anderen Fenster gelegt. Beim Verteilen bekommt er, wenn die übrigen Bildschirme für die Chats reichen, einen seitlichen Bildschirm für sich, bevorzugt den rechten.
- **Verteilen mit Seitenbrowser:** *Auf Bildschirme verteilen* gibt einem Claude-Chat mit offenem Seitenbrowser einen seitlichen Bildschirm für sich allein, bevorzugt den linken. Die übrigen Chats teilen sich die anderen Bildschirme.
- **Klarerer Name:** Die Claude-Code-Funktionen heißen jetzt *Claude-App-Funktionen*, denn sie ordnen die Fenster der Claude-Desktop-App für Windows, nicht Claude Code im Terminal. Deine Einstellung bleibt erhalten.

## 1.1.22
- **Claude-Chats mit Seitenbrowser:** Hat ein Claude-Chat den Seitenbrowser offen, bekommt er beim Ordnen (Alt + Klick auf die Claude-Kachel) doppelt so viel Breite; allein auf einem seitlichen Bildschirm die ganze Breite, neben einem zweiten Chat zwei Drittel.
- **Kontextmenüs bleiben oben:** Der farbige Strich über der Taskleiste und die Leiste legten sich über offene Kontextmenüs, etwa aus dem Infobereich. Jetzt bleiben Menüs aller Programme darüber.

## 1.1.21
- **Claude-Code-Funktionen (abschaltbar):** Wer viele Chats der Claude-App nutzt, schaltet sie unter *Weitere Einstellungen* ein. Eine Claude-Kachel auf jedem Desktop holt mit einem Klick alle Claude-Chats nach vorne. Alt + Klick auf sie ordnet die Chats jedes Bildschirms sauber nebeneinander, in Deiner Reihenfolge; ein unter einen anderen gezogener Chat teilt sich mit ihm die Spalte. Rechtsklick auf einen Tab › *Auf Bildschirme verteilen* verteilt alle Chats nach ihrer Nummer über alle Bildschirme. Ein Claude-Chat kann das über `DeskTabs.exe /cmd` selbst auslösen.
- **Zeit-Log bleibt beim richtigen Desktop:** Meldete Windows einen Desktop-Wechsel verspätet oder falsch, etwa direkt nach dem Aufwachen, buchte das Zeit-Log bis zum nächsten Wechsel auf den alten Desktop. DeskTabs gleicht das jetzt jede Sekunde ab.
- **Kürzel im Menü:** Die Menüs zeigen blass am Rand, welcher Klick dasselbe kann (etwa Strg + Klick, Alt + Klick). Strg + Klick auf eine Anordnungs-Kachel richtet jetzt alle Fenster des Desktops bündig aus, auch auf einem leeren Platz. Strg + Klick auf einen Tab schaltet jetzt zwischen nur Symbol, Kürzel und Name um, im Tab-Menü gebündelt unter *Darstellung*.
- **Kein Sprung durch fremdes Blinken:** Will ein Programm auf einem anderen Desktop Aufmerksamkeit, zeigte Windows seine Schaltfläche blinkend in der Taskleiste jedes Desktops, und ein Klick darauf wechselte den Desktop. DeskTabs beendet dieses Blinken jetzt; der Ruf bleibt als Punkt am Tab (abschaltbar unter *Weitere Einstellungen*).
- **Kacheln nach dem Umsortieren:** Nach dem Verschieben eines Desktops zeigte seine Kachel die Anordnung eines anderen Desktops, und ihr Menü tat nichts. Behoben; das Kachel-Menü zeigt jetzt auch seine Symbole.

## 1.1.20
- **Fensteranordnungen:** Fenster, die zusammengehören, merkt sich DeskTabs je Desktop als Anordnung mit Namen (Menü ≡ › *Fensteranordnung speichern…*). Eine Kachel rechts neben den Tabs holt sie mit einem Klick wieder nach vorne, Umschalt + Klick speichert den aktuellen Stand neu, Strg + Klick richtet grob nebeneinander gezogene Fenster auf den Pixel bündig aus.
- **Tab mit einem Klick kompakt:** **Strg + Klick** auf einen Tab zeigt ihn nur noch als Symbol, noch einmal zeigt ihn wieder mit Namen. Praktisch für Projekte, die gerade ruhen.

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
