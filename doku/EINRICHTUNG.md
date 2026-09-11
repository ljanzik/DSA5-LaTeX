# Einrichten und Bauen

*Das Allgemeine, das für das ganze Toolset gilt — unabhängig davon, welches Feature man setzt.
Was eine einzelne Klasse zusätzlich braucht (eigene Beispieldokumente, eigene Klassenoptionen),
steht in ihrer eigenen Doku-Datei, siehe die Feature-Liste in [README.md](../README.md).*

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
Banner und kleiner Aventurienkarte, dazu 28 Masken, die je eine Region hervorheben.

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
der Region; bei `Aventurien_Mittelreich.png` sind das 2,3 Prozent der Fläche, mitten in der Karte.
Sie sagt also nur, *wo* die Region liegt.

**Gesetzt wird nicht die Verdunkelung des Pakets, sondern die Fassung der offiziellen Hefte:** die
Karte in Sepia, allein die aktive Region in Farbe, ein weicher Schlagschatten darum. Das hebt die
Region deutlich besser heraus. In einem dunkelgrünen Waldgebiet war die bloß abgedunkelte Fassung
kaum zu erkennen. `aufbereiten.py --rueckseiten` rechnet das aus Maske und Rückseite aus und legt
alle 29 Fassungen als `ruecken-neutral`, `ruecken-mittelreich`, `ruecken-thorwal` und so weiter ab.
Die Sepiarampe ist an zwei gesetzten Rücktiteln gemessen; die Herleitung steht in `doku/MASSE.md`
unter „Die Sepiakarte der Rückseite“.

Für eine eigene Aufteilung gibt es `werkzeuge/regionsmaske.py`: es flutet von einem Saatpunkt
aus innerhalb der Grenzlinien und rechnet aus der gefundenen Fläche dieselbe Sepiafassung wie
`aufbereiten.py`. Das Grenznetz kennt allerdings nur die großen Regionen: eine Saat im Kosch
flutet das ganze Mittelreich.

### Schritt 1c — die Heldendokumente

**<https://www.ulisses-ebooks.de/de/product/159699/dsa5-heldendokumente-pdf-als-download-kaufen>**

Nur für `bogen/` nötig, nicht für die Klasse. Wer keine Heldenbögen setzt, überspringt diesen
Schritt — alles andere baut ohne sie.

Der Bogen legt diese PDF als Grund ein und setzt seine Formularfelder darüber. Erwartet werden
zwei Fassungen, die sich **nicht** nur in der Farbe unterscheiden:

| | Seiten | Format |
|---|---|---|
| `Heldendokument_druckerfreundlich.pdf` | 6 | A4, `MediaBox 595,276 × 841,89` |
| `US25505PDF_Heldendokumente.pdf` | 10 | Druckdatei, `MediaBox 230,8 × 317,8 mm`, `TrimBox 208,8 × 295,8 mm` |

Es sind unterschiedliche Auflagen: die Seitenreihenfolge weicht ab (Ausrüstung ist dort Seite 6,
hier Seite 4), und die Beschriftungen ebenso („Talente“ gegen „FERTIGKEITEN“). Deshalb hat jede
Fassung ihre eigene Koordinatentabelle. Die Farbfassung wird außerdem vor dem Einlegen einmal auf
ihre TrimBox beschnitten und unskaliert auf A4 gesetzt — sonst skalierte `pdfpages` sie um etwa
+0,6 Prozent, und keine gemessene Koordinate träfe mehr. Das erledigt
`bogen/bau/quelle-vorbereiten.py` von selbst.

**Die beiden PDF bleiben außerhalb des Projekts.** Sie sind Verlagsmaterial und stehen anders als
der Baukasten nicht unter der Scriptorium-Vereinbarung. Ihre Pfade — und nur dort — stehen in
`bogen/konfig.tex`; ab Werk zeigen sie nach `~/Downloads`. Näheres in `doku/BOGEN.md`, Abschnitt
„Die zwei Quelldateien“.

### Schritt 2 — aufbereiten

Der bequeme Weg. Das Werkzeug legt alles an, was die Klasse braucht, und benennt es passend:

```sh
python3 werkzeuge/aufbereiten.py "/pfad/zu/Scriptorium Aventuris v4"
```

Für die Rückseite gibt es ein zweites Paket, das Rückseiten-Karten-Paket. Es bringt eine
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
- schneidet die vier Doppelseiten aus `Links/` in je eine linke und eine rechte Einzelseite
  (`seite-links-0` bis `-3`, `seite-rechts-0` bis `-3`); die Klasse rotiert über die ersten drei
- holt aus `Links/DSA5-Kapitelstart-Beispielgrafik.psd` die Pergamentfläche und das
  Drachenornament für den Kapitelanfang
- rechnet mit `--rueckseiten` die 29 Rückseiten aus: Karte in Sepia, die aktive Region in
  Farbe, Schlagschatten darum
- kopiert die fünf Schriftdateien nach `schriften/`
- schreibt am Ende eine Liste dessen, was fehlt

**Für den Heldenbogen (`bogen/`) gibt es `einrichten.py` statt `aufbereiten.py`.** Ein Aufruf,
und alles ist da — auch das, was `bogen/` zusätzlich braucht:

```sh
python3 werkzeuge/einrichten.py "/pfad/zu/Scriptorium Aventuris v4" \
    --rueckseiten "/pfad/zum/Rueckseiten_Karten_Paket"
```

Das `--rueckseiten` ist optional; ohne es fehlen nur die 29 Rückseiten aus Schritt 1b.
`einrichten.py` ist die Klammer um drei Werkzeuge, die die Arbeit tun — und der einzige Ort, an
dem der Pfad zum Baukasten genannt wird:

| | |
|---|---|
| `aufbereiten.py` | Grafiken und Schriften aus dem Baukasten |
| `pergament.py` | die Pergamentfläche der Charaktermappe |
| `pruefen.py` | Pixelmaße gegen `doku/MASSE.md` |

`pergament.py` leitet daraus die beiden Flächen der Charaktermappe ab: `mappe-pergament-a4.jpg`
formatfüllend auf A4 bei 300 ppi, dazu `mappe-pergament-kasten.png` als Fußkasten. Quelle ist
`Kasten_Pergament.png` — die Doppelseiten des Baukastens taugen dafür nicht, ihre Innenfläche ist
mit einer Standardabweichung von 1,0 praktisch glattes Weiß. Die Herleitung steht im Kopf des
Werkzeugs.

Am Ende steht, was noch fehlt — auch die Heldendokumente aus Schritt 1c, die nicht aufbereitet,
sondern nur gesucht werden. Wer nur wissen will, wie es steht, fragt ohne Baukasten:

```sh
python3 werkzeuge/einrichten.py --pruefen
```

Es braucht `Pillow`, `psd-tools` und `numpy`, für `nachmessen.py` außerdem `pdfplumber`:

```sh
python3 -m pip install Pillow psd-tools numpy pdfplumber
```

### Schritt 3 — prüfen

```sh
python3 werkzeuge/pruefen.py
```

Vergleicht jede Datei in `grafiken/` gegen die erwarteten Pixelmaße aus `doku/MASSE.md`. Weicht
eine ab, ist entweder eine andere Fassung des Baukastens im Umlauf oder beim Kopieren etwas
schiefgegangen. Beides würde sonst erst im gesetzten PDF auffallen. `einrichten.py` ruft es am
Ende bereits selbst auf.

### Der Weg von Hand

Wer nicht skripten will: `werkzeuge/aufbereiten.py --liste` gibt die Zuordnung aus, Quelldatei nach
Zieldatei. Die Umbenennung ist nötig, weil der Baukasten Leerzeichen und Umlaute in Dateinamen
verwendet und LaTeX damit schlecht umgeht.

Die Seitenhintergründe und die beiden Kapitelanfang-Teile lassen sich von Hand nicht sinnvoll
herstellen. Dafür braucht es das Werkzeug oder ein Bildbearbeitungsprogramm.

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

Vier Beispieldokumente liegen in `beispiel/`: `beispiel.tex` zeigt jedes Element genau einmal
(22 Seiten), `raster.tex` nur Text und Raster und baut in Sekunden, `kaesten.tex` alle fünfzehn
Kästen, `rest.tex` die Seitentypen. Jedes weitere Feature bringt seine eigenen Beispieldokumente
mit — welche das sind, steht in seiner eigenen Doku-Datei aus der Feature-Liste.

Gebraucht werden aus TeX Live oder MiKTeX: `geometry graphicx xcolor fontspec polyglossia tikz
tcolorbox eso-pic fancyhdr enumitem wrapfig contour changepage intcalc array colortbl textcomp
microtype hyperref tabularx environ`.

**Für den Heldenbogen (`bogen/`)** kommen `pdfpages ifthen fontenc inputenc ebgaramond cinzel`
dazu, dazu zwei Programme außerhalb von Python:

| | wofür | woher |
|---|---|---|
| **XeLaTeX** | die Klasse; ohne das baut kein Beispiel | TeX Live / MacTeX |
| **pdflatex** | `bogen/`, alle Fassungen des Heldenbogens | dieselbe Distribution |
| **Ghostscript** | `bogen/`: `rendern`, `linien-lesen`, Farbquelle normalisieren | siehe unten |

**Ghostscript ist unter Windows kostenlos dabei, anderswo nicht.** TeX Live bringt es dort in
`tlpkg/tlgs` mit, ohne dass man etwas tun muss. Unter macOS gehört es **nicht** zu MacTeX:

```sh
brew install ghostscript          # macOS
sudo apt install ghostscript      # Debian, Ubuntu
```

Ohne Ghostscript baut alles außer den drei genannten Werkzeugen. `werkzeuge/einrichten.py
--pruefen` sagt, was davon da ist. Windows, macOS und Linux: die Bauskripte in `bogen/bau/` sind
Python, zu jedem gibt es eine `.ps1` und eine `.sh`, beide dreizeilig und ohne eigene Logik,
damit die Aufrufe auf allen Plattformen dieselben bleiben.

### Klassenoptionen

```latex
\documentclass[raster]{dsa5latex}              % Grundlinienraster ein, Standard
\documentclass[ohneraster]{dsa5latex}          % Raster aus
\documentclass[raster,rasterzeigen]{dsa5latex} % Grundlinien mitdrucken
\documentclass[raster,entwurf]{dsa5latex}      % Bilder als Rahmen, schnelles Bauen
```

Die Elementreferenz steht in `doku/ELEMENTE.md`.

---

## Mit einer KI setzen

Diese Vorlage ist mit Hilfe einer KI entstanden: nachgemessen, geschrieben und geprüft wurde
mit einem Agenten. Und sie ist dafür gedacht, auch so benutzt zu werden. **Man muss LaTeX
dafür nicht vollständig lernen.** Wer seinen Text fertig hat, kann ihn von einer KI in diese
Klasse setzen lassen und sich um das kümmern, was ihm gehört: das Abenteuer.

Das geht deshalb, weil das Projekt so angelegt ist, dass eine KI die Antworten nachlesen kann,
statt sie zu erfinden:

| Datei | was sie einer KI gibt |
|---|---|
| `CLAUDE.md` | die Einweisung. Teil A: wie man mit der Vorlage ein Dokument setzt (Gerüst, die fünf Fallen, Bauweg). Teil B: wie man an der Vorlage selbst arbeitet |
| `doku/ELEMENTE.md` | jeden der rund neunzig Befehle mit Zweck, Maß und Beispiel |
| `beispiel/beispiel.tex` | jedes Element genau einmal, zum Abschreiben |
| `doku/MASSE.md` | zu jedem Zahlenwert die Quelle, aus der er stammt |

### So fängt man an

Mit Claude Code oder einem anderen Agenten mit Dateizugriff, im Projektordner:

1. Grafiken und Schriften besorgen (siehe oben). Ohne sie kompiliert auch für eine KI nichts.
2. Den eigenen Text danebenlegen, etwa als `mein-abenteuer.md`. Fließtext genügt, mit
   Überschriften und einer Notiz, wo ein Kasten oder eine Tabelle hin soll.
3. Auffordern, etwa so:

   > Lies `CLAUDE.md`, Teil A. Setze `mein-abenteuer.md` damit als DSA5-Abenteuer nach
   > `beispiel/mein-abenteuer.tex`. Nimm nur Befehle, die in `doku/ELEMENTE.md` stehen, und
   > rate keinen. Danach bauen und das Log zeigen.

4. Ins PDF sehen.

In einem reinen Chatfenster, ohne Dateizugriff, erreicht man dasselbe: man kopiert `CLAUDE.md`
und `doku/ELEMENTE.md` in die Unterhaltung und lässt den Satz Stück für Stück
zurückschreiben.

### Was die KI nicht sieht

Sie schreibt gültiges LaTeX, aber sie sieht die Seite nicht. Drei Dinge fallen ihr nicht von
selbst auf, und genau die prüft man selbst:

* Eine Tabelle oder ein Kasten, der unten aus der Spalte läuft. Die Klasse warnt bei
  Tabellen, aber nur als `Class dsa5latex Warning`, und das übersieht man im Log leicht.
* Ein Bild, das das Raster verschiebt. Jedes Bild im Textfluss belegt eine ganze Zahl
  Rastereinheiten; ein nacktes `\includegraphics` verschiebt alles darunter.
* Ob es gut aussieht. Ein Umbruch, der einen Zwischentitel allein unten stehen lässt, ist
  kein Fehler, den ein Log meldet.

Deshalb nach jedem Lauf einmal mit `rasterzeigen` bauen: sitzen die Zeilen beider Spalten auf
einer Höhe, stimmt der Satz.
