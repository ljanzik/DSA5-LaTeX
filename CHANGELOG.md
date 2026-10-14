# Änderungen

Eine Versionsnummer für das ganze Projekt. Sie steht gleichlautend in `\ProvidesClass` und
`\ProvidesPackage` jeder Datei und im Git-Tag. Neues kommt oben dazu, unter der Version, die es
ausliefern wird.

## 1.3.0 — unveröffentlicht

* Einleger für den Spielleiterschirm (`dsa5einleger.cls`): DIN A4 quer, vier freie Spalten ohne
  Grundlinienraster, Tabellen mit Quellenmarke und Verlaufskopf, Stimmungsbildseite.
  `werkzeuge/einleger.py` legt die Querformat-Hintergründe an. Die Klasse trägt bis zur nächsten
  Versionshebung die laufende Projektversion 1.2.0.
* Die CI baut `einleger.tex` im Ersatzmodus mit.
* Ausfüllbarer Heldenbogen (`bogen/`): überlagert das offizielle DSA5-Heldendokument mit
  Formularfeldern, leer oder mit den Werten eines Helden vorbefüllt, gebaut mit `pdflatex`.
  Dazu die Charaktermappe als Umschlag (`dsa5mappe.cls`), die bis zur nächsten Versionshebung
  ebenfalls die laufende Projektversion 1.2.0 trägt.
* `werkzeuge/einrichten.py` richtet alles aus dem Baukasten mit einem Aufruf ein,
  `werkzeuge/pergament.py` legt das Pergament der Mappe an.
* Der Pflichttext der Vereinbarung über Gemeinschaftsinhalte steht nur noch in `pflichttext.tex`
  und wird von Impressum und Mappe gemeinsam benutzt.
* Die Heldendokumente liegen in `bogen/quellen/` (von git ignoriert), `bogen/konfig.tex` nennt sie
  relativ. `einrichten.py --heldendokumente <ordner>` kopiert sie dorthin. Vorher stand dort ein
  absoluter Windows-Pfad mit Benutzername.

## 1.2.0 — unveröffentlicht

* Spielkarten im Format 63 × 88 mm (`dsa5spielkarten.cls`): elf Kartentypen, als Einzelkarten
  für die Druckerei oder als A4-Druckbogen mit duplexdeckender Rückseite, Randfarbe einstellbar.
* Farbige Seitenränder: `\dsaSeitenfarbe` färbt das Schuppenband der Seitenhintergründe in
  denselben Farben wie die Spielkarten, `werkzeuge/seitenfarbe.py` legt die Fassungen an.
* `\dsaAutor` setzt den Autor in den PDF-Metadaten. `\dsaAbenteuertitel` setzt den Dokumenttitel
  dort mit, und als Erzeuger steht `dsa5latex` mit Versionsnummer im PDF.
* Eine Versionsnummer für alle Dateien. Bis hierhin trug die Klasse `v2.0`, der Aufsteller `v1.0`
  und der Git-Tag `v1.1.0`.
* `latexmk` baut die Beispiele in `beispiel/` ohne `TEXINPUTS` und ohne drei Läufe von Hand.
* Klassenoption `ersatz`: freie Ersatzschrift aus TeX Live, wenn `schriften/` fehlt.
  `werkzeuge/platzhalter.py` legt Platzhaltergrafiken in den Sollmaßen an. Beides zusammen lässt
  die Beispiele ohne Baukastenmaterial bauen, so läuft die CI.
* GitHub Action baut alle Beispiele im Ersatzmodus und prüft das Log.
* Behoben: eine Rautenskala im Fließtext schob alles darunter um 1,61 bp vom Raster (#9).

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
