# dsa5-latex

Eine LaTeX-Dokumentklasse, die Abenteuer im Layout von **Das Schwarze Auge 5** setzt — nach den
Maßen des offiziellen *Scriptorium Aventuris – Layout Baukastens* von Ulisses Spiele.

Zweispaltiger Satz auf A4 mit Grundlinienraster, Pergament- und Wertekästen in ihren
Produktionsgrößen, Kapitelbanner, Meistermasken, Seitenhintergründe und die Werkzeuge für
freigestellte Grafiken mit Textumfluss.

**Der Code steht unter Apache 2.0. Die Grafiken und Schriften sind nicht Teil dieses Projekts** und
müssen selbst besorgt werden — siehe Abschnitt „Grafiken und Schriften besorgen". Ohne sie
kompiliert nichts.

---

## Warum keine Grafiken im Projekt

Alles Bildmaterial und beide Schriften gehören Ulisses Spiele beziehungsweise deren Urhebern und
stehen unter der *Vereinbarung über Gemeinschaftsinhalte für SCRIPTORIUM AVENTURIS*. Diese
Vereinbarung ist mit Apache 2.0 nicht vereinbar: Apache erlaubt Weitergabe und Veränderung ohne
Rückfrage, die Scriptorium-Vereinbarung nicht.

Deshalb enthält dieses Repository **ausschließlich eigenen Code**: die Klasse, die Werkzeuge, die
Dokumentation der Maße. Die Ordner `grafiken/` und `schriften/` sind leer und in `.gitignore`
eingetragen. Wer die Klasse benutzt, lädt das offizielle Paket selbst herunter — was ohnehin
Voraussetzung dafür ist, im Scriptorium zu veröffentlichen.

Die **Maße** in diesem Projekt sind kein Bildmaterial, sondern Messergebnisse. Sie stehen in
`doku/MASSE.md` mit ihrer Herleitung.

---

## Grafiken und Schriften besorgen

### Schritt 1 — den Baukasten herunterladen

**<https://www.ulisses-ebooks.de/de/product/197880/scriptorium-aventuris-layout-baukasten>**

Der *Scriptorium Aventuris – Layout Baukasten* von Ulisses Spiele, kostenlos. Herunterladen und
entpacken. Der Ordner heißt bei der hier verwendeten Fassung `Scriptorium Aventuris v4` und
enthält unter anderem:

```
Scriptorium Aventuris v4/
├── Document fonts/     die beiden Schriften
├── Links/              die Quelldateien, PSD und JPG
├── PNG innen/          die Layoutelemente als PNG
└── PNG aussen/         Umschlag vorne und hinten
```

### Schritt 1b — das Rückseiten-Karten-Paket

**<https://www.ulisses-ebooks.de/product/240903/Ruckseiten-Karten-Paket>**

Das *Rückseiten Karten Paket* von Ulisses Spiele, ein eigenes Produkt (nicht kostenlos, rund
einen Euro). Es liefert die letzte Seite eines Hefts: eine fertige Rückseite mit Zierrahmen,
Banner und kleiner Aventurienkarte, dazu 28 **Masken**, die je eine Region hervorheben.

```
Rückseiten_Karten_Paket/
├── ScriptoriumAventuris-hinten.png   die Rückseite mit heller Karte
├── Aventurien_Mittelreich.png        28 Masken, je eine Region
├── Aventurien_Thorwal.png            …
├── KarteVerdunkelt.png               die Karte, ganz verdunkelt
├── Grenzen.png                       das Netz der Regionsgrenzen
└── Karte_mit_Grenzen_Paket.pdn       beide Ebenen als Arbeitsdatei
```

**Eine Maske ist keine fertige Seite.** Sie ist die verdunkelte Karte mit einem Loch an der Stelle
der Region — bei `Aventurien_Mittelreich.png` sind das 2,3 Prozent der Fläche, mitten in der Karte.
Erst über die neutrale Rückseite gelegt entsteht das gewünschte Bild: die Region bleibt hell, der
Rest tritt zurück. `aufbereiten.py --rueckseiten` setzt beides zusammen und legt alle 29 Fassungen
als `ruecken-neutral`, `ruecken-mittelreich`, `ruecken-thorwal` und so weiter ab.

Für eine eigene Aufteilung gibt es `werkzeuge/regionsmaske.py`: es flutet von einem Saatpunkt aus
innerhalb der Grenzlinien und schneidet die gefundene Fläche aus der Verdunkelung. Das Grenznetz
kennt allerdings nur die großen Regionen — eine Saat im Kosch flutet das ganze Mittelreich.

**Mehr braucht es nicht.** Der Zierrahmen des Kapitelanfangs und die drei Rautenkacheln kamen
früher aus einer dritten, fremden Sammlung; beide stecken im Baukasten selbst und werden daraus
erzeugt — der Rahmen aus der Pergamentebene von `DSA5-Kapitelstart-Beispielgrafik.psd`, die
Rauten aus `AufzaehlerDSA5_Rueckseite_rot/blau/schwarz.psd`. Die Option `--zusatz` gibt es nicht
mehr.

### Schritt 2 — aufbereiten

Der bequeme Weg. Das Werkzeug legt alles an, was die Klasse braucht, und benennt es passend:

```sh
python3 werkzeuge/aufbereiten.py "/pfad/zu/Scriptorium Aventuris v4"
```

Für die Rückseite gibt es ein zweites Paket, das **Rückseiten-Karten-Paket**. Es bringt eine
fertige Rückseite mit Zierrahmen und 28 Masken, die je eine Region Aventuriens hervorheben:

```sh
python3 werkzeuge/aufbereiten.py "/pfad/zu/Scriptorium Aventuris v4" \
    --rueckseiten "/pfad/zum/Rueckseiten_Karten_Paket"
```

Es braucht `Pillow` und `psd-tools`:

```sh
python3 -m pip install Pillow psd-tools
```

Was es tut:

- kopiert die benötigten PNG aus `PNG innen/` und `PNG aussen/` nach `grafiken/` und benennt sie
  auf Namen ohne Leerzeichen und Umlaute um
- **schneidet** die vier Doppelseiten aus `Links/` in je eine linke und eine rechte Einzelseite
  (`seite-links-0` bis `-3`, `seite-rechts-0` bis `-3`) — die Klasse rotiert über die ersten drei
- **extrahiert** aus `Links/DSA5-Kapitelstart-Beispielgrafik.psd` die Pergamentfläche und das
  Drachenornament für den Kapitelanfang
- kopiert die fünf Schriftdateien nach `schriften/`
- schreibt am Ende eine Liste dessen, was fehlt

### Schritt 3 — prüfen

```sh
python3 werkzeuge/pruefen.py
```

Vergleicht jede Datei in `grafiken/` gegen die erwarteten Pixelmaße aus `doku/MASSE.md`. Weicht
eine ab, ist entweder eine andere Fassung des Baukastens im Umlauf oder beim Kopieren etwas
schiefgegangen — beides würde sonst erst im gesetzten PDF auffallen.

### Der Weg von Hand

Wer nicht skripten will: `werkzeuge/aufbereiten.py --liste` gibt die Zuordnung aus, Quelldatei nach
Zieldatei. Die Umbenennung ist nötig, weil der Baukasten Leerzeichen und Umlaute in Dateinamen
verwendet und LaTeX damit schlecht umgeht.

Die Seitenhintergründe und die beiden Kapitelanfang-Teile lassen sich von Hand nicht sinnvoll
herstellen — dafür braucht es das Werkzeug oder ein Bildbearbeitungsprogramm.

---

## Bauen

**XeLaTeX ist Pflicht.** Die Klasse lädt `fontspec` und `polyglossia`.

```sh
cd beispiel
TEXINPUTS="..;" xelatex beispiel.tex     # dreimal, wegen Inhalt und Marken
```

`TEXINPUTS` ist nötig, weil `dsa5latex.cls` eine Ebene höher liegt. Wer die Datei nach
`TEXMFHOME/tex/latex/dsa5latex/` legt, kann es weglassen. Unter Windows in der PowerShell:
`$env:TEXINPUTS = "..;"`.

Fünf Beispieldokumente liegen in `beispiel/`: `beispiel.tex` zeigt jedes Element genau einmal
(22 Seiten), `raster.tex` nur Text und Raster und baut in Sekunden, `kaesten.tex` alle fünfzehn
Kästen, `rest.tex` die Seitentypen.

Gebraucht werden aus TeX Live oder MiKTeX: `geometry graphicx xcolor fontspec polyglossia tikz
tcolorbox eso-pic fancyhdr enumitem wrapfig contour changepage intcalc array colortbl textcomp
microtype hyperref tabularx environ`.

### Klassenoptionen

```latex
\documentclass[raster]{dsa5latex}              % Grundlinienraster ein, Standard
\documentclass[ohneraster]{dsa5latex}          % Raster aus
\documentclass[raster,rasterzeigen]{dsa5latex} % Grundlinien mitdrucken
\documentclass[raster,entwurf]{dsa5latex}      % Bilder als Rahmen, schnelles Bauen
```

Die Elementreferenz steht in `doku/ELEMENTE.md`. Wer mit
**Claude Code** an den Klassen arbeitet,
findet die Hausregeln des Projekts in `CLAUDE.md` — Quellen der Maße, Rasterregel, Bauweg,
Prüfweg, Schreibweise.

---

## Stand

**Die Klasse läuft.** Alle vier Beispieldokumente bauen mit XeLaTeX aus TeX Live 2026
fehlerfrei durch — `beispiel.tex` mit 22 Seiten, ohne eine einzige LaTeX-Warnung. Sechs
`Overfull \hbox` sind der gewollte Überhang der Kästen, fünf `Underfull \hbox` sind lockere
Umbrüche im 80,5-mm-Satz.

**Geprüft ist damit noch nicht alles.** Gebaut heißt nicht nachgemessen: fünfzehn Stellen
tragen im Quelltext weiter `% PRUEFEN:`, weil ihr Ergebnis noch niemand am PDF nachgemessen
hat. Die Liste steht in `doku/ELEMENTE.md` unter „Was noch nicht nachgemessen ist", der
Stand jeder Messung in `doku/PRUEFPLAN.md`.

---

## Woher die Maße kommen

Nicht geschätzt, sondern gemessen — auf drei voneinander unabhängigen Wegen, die sich gegenseitig
bestätigen:

1. **Der Klartext des Verlags.** Seite 2 des Baukasten-PDF nennt Satzspiegel, Grafikbereich, Raster
   und Anschnitt in Worten. `Scriptorium Aventuris Lies mich zuerst v1.4.pdf` nennt die
   Schriftenhierarchie.
2. **Die Pixelmaße der Vorlagengrafiken.** Alle sind mit 300 ppi angelegt; Pixel geteilt durch 300,
   mal 25,4 ergibt das Produktionsmaß.
3. **Die Rahmenmaße im InDesign-Dokument.** `Scriptorium Aventuris v4.idml` ist ein ZIP; darin
   stehen zu jedem platzierten Bild der Rahmen und, entscheidend, `ActualPpi` und `EffectivePpi`.
   Sind beide gleich, liegt das Bild auf 100 % und der Rahmen ist das Produktionsmaß. Von 46
   platzierten Bildern erfüllen 27 das.

Alles einzeln in `doku/MASSE.md`.

---

## Was diese Klasse nicht ist

Sie ist **keine** Fortsetzung von **DSaTeX** von Lukas Ester, der ersten LaTeX-Vorlage für DSA5 im
Scriptorium. Diese Klasse teilt mit ihr keine Zeile Code. Sie ist aber durch sie angeregt, und der
Vergleich mit ihr hat die meisten Maße überhaupt erst hervorgebracht — 24 Abweichungen zwischen
DSaTeX und dem offiziellen Baukasten sind in `doku/MASSE.md` festgehalten, weil sie erklären, warum
hier manches anders gelöst ist.

Wer DSaTeX benutzt und sie behalten will, findet dort die Liste der Punkte, die sich lohnen zu
korrigieren. Insbesondere: DSaTeX lädt keine Sprachunterstützung, trennt deutschen Text also nach
englischen Mustern.

---

## Rechtliches

Der Code dieses Projekts steht unter **Apache License 2.0**, siehe `LICENSE` und `NOTICE`.

Das gilt **nicht** für das Material, das in `grafiken/` und `schriften/` landet — weder für das aus
dem Baukasten noch für die Karten des Rückseiten-Pakets oder die einzelnen Grafikdateien. Dafür
gilt die *Vereinbarung über Gemeinschaftsinhalte für SCRIPTORIUM AVENTURIS*. Der Baukasten schreibt einen
Wortlaut vor, der in jedem damit gesetzten Werk stehen muss; die Klasse stellt ihn als
`\dsaRechtstext{…}` bereit.

> Das Schwarze Auge und sein Logo sowie Aventuria, Dere, Myranor, Riesland, Tharun, Uthuria, The
> Dark Eye und ihre Logos sind eingetragene Marken von Ulisses Medien und Spiele Distribution GmbH.

Dieses Projekt steht in keiner Verbindung zu Ulisses Spiele und ist nicht von dort autorisiert.
