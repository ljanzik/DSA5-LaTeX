# Änderungen

Eine Versionsnummer für das ganze Projekt. Sie steht gleichlautend in `\ProvidesClass` und
`\ProvidesPackage` jeder Datei und im Git-Tag. Neues kommt oben dazu, unter der Version, die es
ausliefern wird.

## 1.2.0 — unveröffentlicht

* `\dsaAutor` setzt den Autor in den PDF-Metadaten. `\dsaAbenteuertitel` setzt den Dokumenttitel
  dort mit, und als Erzeuger steht `dsa5latex` mit Versionsnummer im PDF.
* Eine Versionsnummer für alle Dateien. Bis hierhin trug die Klasse `v2.0`, der Aufsteller `v1.0`
  und der Git-Tag `v1.1.0`.
* `latexmk` baut die Beispiele in `beispiel/` ohne `TEXINPUTS` und ohne drei Läufe von Hand.
* Klassenoption `ersatz`: freie Ersatzschrift aus TeX Live, wenn `schriften/` fehlt.
  `werkzeuge/platzhalter.py` legt Platzhaltergrafiken in den Sollmaßen an. Beides zusammen lässt
  die Beispiele ohne Baukastenmaterial bauen, so läuft die CI.
* GitHub Action baut alle Beispiele im Ersatzmodus und prüft das Log.

## 1.1.0 — 2026-09-20

* Aufsteller zum Ausschneiden in vier Größen, mit passender Rückseite für den Duplexdruck
  (`dsa5aufsteller.sty`).
* Battlemap mit Zollraster als eigenes Dokument, A4 bis A1, hoch oder quer
  (`beispiel/battlemap.tex`).

## 1.0.1 — 2026-09-16

* Covertitel am Verlag nachgemessen: schmalere Fläche, flacherer und weicherer Schriftschatten,
  Lagenfolge mehrzeiliger Titel in vier Stufen. Farben und Schattenmaße sind einstellbar.

## 1.0 — 2026-09-11

* `dsa5latex.cls`, die Kernklasse für Abenteuer im Layout des *Scriptorium Aventuris*.
