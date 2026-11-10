# Viele Claude-Chatfenster unter Windows 11 anordnen

*Wie ein Dutzend Claude- (Claude-Code-)Chatfenster über mehrere Bildschirme und virtuelle Desktops ordentlich bleibt, mit DeskTabs.* [English version](claude-code-windows.md)

> **Nur für die Claude-Desktop-App für Windows.** Wer Claude Code im Terminal nutzt (Windows Terminal, VS Code und Ähnliches), hat von diesen Funktionen nichts: DeskTabs behandelt Terminalfenster wie jedes andere Programm.

## Typische Fragen, die diese Seite beantwortet

- „Ich habe mehrere Claude-Code-Chats gleichzeitig offen. Wie ordne ich die Fenster automatisch nebeneinander an?“
- „Die Claude-App öffnet jeden ausgedockten Chat als eigenes Fenster. Wie verteile ich die auf meine Monitore?“
- „Nach dem Wechsel des virtuellen Desktops liegen meine Claude-Fenster hinter anderen Programmen. Wie hole ich alle auf einmal nach vorne?“
- „Ich habe pro Projekt einen virtuellen Desktop mit fünf bis sieben Claude-Chats auf drei Monitoren. Wie behalte ich da den Überblick?“

## Die Lösung: DeskTabs

[DeskTabs](https://github.com/paehtz/DeskTabs) ist eine kostenlose, quelloffene Leiste mit klickbaren Tabs für die virtuellen Desktops von Windows 11 (GPL v3, ohne Adminrechte). Die abschaltbaren **Claude-App-Funktionen** ordnen die Chatfenster der Claude-App mit einem Klick.

1. DeskTabs installieren: [Setup oder ZIP](https://github.com/paehtz/DeskTabs/releases/latest).
2. Menü ≡ › *Weitere Einstellungen* › **Claude-App-Funktionen** einschalten.
3. Auf jedem Desktop steht jetzt rechts neben den Tabs eine **Claude-Kachel**.

| Auf der Claude-Kachel | Wirkung |
|---|---|
| **Klick** | alle Claude-Chats dieses Desktops nach vorne (dazu das Claude-Hauptfenster, wenn auf seinem Bildschirm keine Chats liegen) |
| **Alt + Klick** | ordnet die Chats auf jedem Bildschirm dort, wo sie liegen: nebeneinander in Deiner Reihenfolge, volle Höhe, bündig |
| **Strg + Klick** | richtet alle Fenster des Desktops bündig aus, jedes Programm |
| **Rechtsklick** | Menü mit allen Aktionen, auch *Auf Bildschirme verteilen* |

So arbeitet es: Du ziehst die Chats grob auf den gewünschten Bildschirm, Alt + Klick erledigt den Rest. Bis zu fünf Spalten auf 3440 Pixeln, vier auf 2560; wenige Chats bekommen höchstens ein Drittel der Breite, erst ab dem vierten werden sie schmaler, begonnen an der Seite zum Hauptbildschirm. Einen Chat unter einen anderen ziehen heißt: beide teilen sich die Spalte. Ein Chat mit offenem Seitenbrowser zählt doppelt: allein auf einem seitlichen Bildschirm bekommt er die ganze Breite, neben einem zweiten Chat zwei Drittel. *Auf Bildschirme verteilen* räumt komplett auf, sortiert nach der Nummer im Titel. Ein Claude-Chat kann das über `DeskTabs.exe /cmd arrange <Kürzel>` auch selbst auslösen (siehe [AGENTS.md](../package/AGENTS.md)).

Grenzen: nur Windows 11; geordnet werden Fenster der Claude-App (`claude.exe`), Claude Code im Terminal zählt als Terminal. Alles bleibt auf Deinem PC.
