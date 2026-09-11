# dsa5-latex

<p align="center">
  <img src="doku/bilder/titel.png" alt="LaTeX Layout" width="400">
</p>

Eine LaTeX-Dokumentklasse, die Abenteuer im Layout von **Das Schwarze Auge 5** setzt, nach den
Maßen des offiziellen *Scriptorium Aventuris – Layout Baukastens* von Ulisses Spiele.

Zweispaltiger Satz auf A4 mit Grundlinienraster, Pergament- und Wertekästen in ihren
Produktionsgrößen, Kapitelbanner, Meistermasken, Seitenhintergründe und die Werkzeuge für
freigestellte Grafiken mit Textumfluss.

**Der Code steht unter Apache 2.0. Die Grafiken und Schriften sind nicht Teil dieses Projekts** und
müssen selbst besorgt werden. Wie, steht im Abschnitt „Grafiken und Schriften besorgen“.
Ohne sie kompiliert nichts.

Die Vorlage ist mit Hilfe einer KI entstanden und dafür gedacht, auch mit einer KI benutzt zu
werden: **LaTeX muss man dafür nicht (vollständig) lernen.** Wie das geht, steht unter
„Mit einer KI setzen“.

Dazu kommt `bogen/`: ein Werkzeug, das das offizielle DSA5-Heldendokument mit Formularfeldern
überlagert — ausfüllbar oder mit den Werten eines Helden vorbefüllt — und eine Charaktermappe
als Umschlag dazu setzt. Es läuft mit pdflatex statt XeLaTeX und folgt eigenen Regeln; alles
darüber steht in [`doku/BOGEN.md`](doku/BOGEN.md).

**Windows, macOS und Linux.** Die Klasse braucht nur XeLaTeX. Die Werkzeuge und die Bauskripte
sind Python; zu jedem gibt es eine `.ps1` und eine `.sh`, beide dreizeilig und ohne eigene
Logik, damit die Aufrufe auf allen Plattformen dieselben bleiben.

---

## Warum keine Grafiken im Projekt

Alles Bildmaterial und beide Schriften gehören Ulisses Spiele beziehungsweise deren Urhebern und
stehen unter der *Vereinbarung über Gemeinschaftsinhalte für SCRIPTORIUM AVENTURIS*. Diese
Vereinbarung ist mit Apache 2.0 nicht vereinbar: Apache erlaubt Weitergabe und Veränderung ohne
Rückfrage, die Scriptorium-Vereinbarung nicht.

Deshalb enthält dieses Repository **ausschließlich eigenes Material**: die Klasse, die
Werkzeuge, die Dokumentation der Maße. `schriften/` ist leer, `grafiken/` bis auf eine
Ausnahme ebenso, und beide sind in `.gitignore` eingetragen. Wer die Klasse benutzt, lädt
das offizielle Paket selbst herunter. Wer im Scriptorium veröffentlichen will, braucht es
sowieso.

Die Ausnahme ist `grafiken/titelbild.jpg`, der Zwerg am Setzkasten. Das Bild ist mit einer KI
erzeugt und gehört diesem Projekt, nicht Ulisses — deshalb darf es hier liegen, und
`\dsaUmschlagVorne` hat nach dem Klonen ein Titelbild, ohne dass man eines suchen muss.

Die Maße in diesem Projekt sind kein Bildmaterial, sondern Messergebnisse. Sie stehen in
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
hier Seite 4), und die Beschriftungen ebenso („Talente" gegen „FERTIGKEITEN"). Deshalb hat jede
Fassung ihre eigene Koordinatentabelle. Die Farbfassung wird außerdem vor dem Einlegen einmal auf
ihre TrimBox beschnitten und unskaliert auf A4 gesetzt — sonst skalierte `pdfpages` sie um etwa
+0,6 Prozent, und keine gemessene Koordinate träfe mehr. Das erledigt
`bogen/bau/quelle-vorbereiten.py` von selbst.

**Die beiden PDF bleiben außerhalb des Projekts.** Sie sind Verlagsmaterial und stehen anders als
der Baukasten nicht unter der Scriptorium-Vereinbarung. Ihre Pfade — und nur dort — stehen in
`bogen/konfig.tex`; ab Werk zeigen sie nach `~/Downloads`. Näheres in
[`doku/BOGEN.md`](doku/BOGEN.md), Abschnitt „Die zwei Quelldateien".

### Schritt 2 — einrichten

Ein Aufruf, und alles ist da:

```sh
python3 werkzeuge/einrichten.py "/pfad/zu/Scriptorium Aventuris v4" \
    --rueckseiten "/pfad/zum/Rueckseiten_Karten_Paket"
```

Das `--rueckseiten` ist optional; ohne es fehlen nur die 29 Rückseiten aus Schritt 1b.

`einrichten.py` ist die Klammer um die drei Werkzeuge, die die Arbeit tun — und der einzige
Ort, an dem der Pfad zum Baukasten genannt wird:

| | |
|---|---|
| `aufbereiten.py` | Grafiken und Schriften aus dem Baukasten |
| `pergament.py` | die Pergamentfläche der Charaktermappe |
| `pruefen.py` | Pixelmaße gegen `doku/MASSE.md` |

Am Ende steht, was noch fehlt — auch die Heldendokumente aus Schritt 1c, die nicht aufbereitet,
sondern nur gesucht werden. Wer nur wissen will, wie es steht, fragt ohne Baukasten:

```sh
python3 werkzeuge/einrichten.py --pruefen
```

Es braucht `Pillow`, `psd-tools` und `numpy`, für `nachmessen.py` außerdem `pdfplumber`:

```sh
python3 -m pip install Pillow psd-tools numpy pdfplumber
```

Die Werkzeuge lassen sich auch einzeln aufrufen, jedes mit demselben Baukastenpfad:

```sh
python3 werkzeuge/aufbereiten.py "/pfad/zu/Scriptorium Aventuris v4"
python3 werkzeuge/pergament.py   "/pfad/zu/Scriptorium Aventuris v4"
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

`pergament.py` leitet daraus die beiden Flächen der Charaktermappe ab: `mappe-pergament-a4.jpg`
formatfüllend auf A4 bei 300 ppi, dazu `mappe-pergament-kasten.png` als Fußkasten. Quelle ist
`Kasten_Pergament.png` — die Doppelseiten des Baukastens taugen dafür nicht, ihre Innenfläche ist
mit einer Standardabweichung von 1,0 praktisch glattes Weiß. Die Herleitung steht im Kopf des
Werkzeugs.

### Schritt 3 — prüfen

`einrichten.py` ruft es am Ende selbst auf; einzeln geht es auch:

```sh
python3 werkzeuge/pruefen.py
```

Vergleicht jede Datei in `grafiken/` gegen die erwarteten Pixelmaße aus `doku/MASSE.md`. Weicht
eine ab, ist entweder eine andere Fassung des Baukastens im Umlauf oder beim Kopieren etwas
schiefgegangen. Beides würde sonst erst im gesetzten PDF auffallen.

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

---

## Stand

**Die Klasse läuft.** Alle vier Beispieldokumente bauen mit XeLaTeX aus TeX Live 2026
fehlerfrei durch, `beispiel.tex` mit 22 Seiten und ohne eine einzige LaTeX-Warnung. Sechs
`Overfull \hbox` sind der gewollte Überhang der Kästen, fünf `Underfull \hbox` sind lockere
Umbrüche im 80,5-mm-Satz.

**Und sie ist nachgemessen.** Von den vierzehn Prüfmarken, die der Quelltext einmal trug,
sind zehn erledigt, darunter zwei echte Fehler: der Kapiteltitel stand mit 23,5 statt
31,73 pt (die IDML skaliert ihn auf 135 %), und vor dem Titel stand ein „Kapitel N:“, das
kein gesetzter Band führt. Die vier verbliebenen heißen im Quelltext `% OFFEN:`: sie warten
nicht auf eine Messung, sondern auf eine Quelle, die es nicht gibt. Welche das sind, steht
in `doku/ELEMENTE.md` unter „Was noch nicht nachgemessen ist“, der Stand jeder Messung in
`doku/PRUEFPLAN.md`.

---

## Woher die Maße kommen

Nicht geschätzt, sondern gemessen, auf drei voneinander unabhängigen Wegen, die sich
gegenseitig bestätigen:

1. Der Klartext des Verlags. Seite 2 des Baukasten-PDF nennt Satzspiegel, Grafikbereich, Raster
   und Anschnitt in Worten. `Scriptorium Aventuris Lies mich zuerst v1.4.pdf` nennt die
   Schriftenhierarchie.
2. Die Pixelmaße der Vorlagengrafiken. Alle sind mit 300 ppi angelegt; Pixel geteilt durch 300,
   mal 25,4 ergibt das Produktionsmaß.
3. Die Rahmenmaße im InDesign-Dokument. `Scriptorium Aventuris v4.idml` ist ein ZIP; darin
   stehen zu jedem platzierten Bild der Rahmen und, entscheidend, `ActualPpi` und `EffectivePpi`.
   Sind beide gleich, liegt das Bild auf 100 % und der Rahmen ist das Produktionsmaß. Von 46
   platzierten Bildern erfüllen 27 das.

Alles einzeln in `doku/MASSE.md`.

---

## Was diese Klasse nicht ist

Sie ist **keine** Fortsetzung von **DSaTeX** von Lukas Ester, der ersten LaTeX-Vorlage für DSA5 im
Scriptorium. Diese Klasse teilt mit ihr keine Zeile Code. Sie ist aber durch sie angeregt, und der
Vergleich mit ihr hat die meisten Maße überhaupt erst hervorgebracht. 24 Abweichungen zwischen
DSaTeX und dem offiziellen Baukasten stehen in `doku/MASSE.md`, weil sie erklären, warum hier
manches anders gelöst ist.

Wer DSaTeX benutzt und sie behalten will, findet dort die Liste der Punkte, die sich lohnen zu
korrigieren. Insbesondere: DSaTeX lädt keine Sprachunterstützung, trennt deutschen Text also nach
englischen Mustern.

---

## Rechtliches

Der Code dieses Projekts steht unter **Apache License 2.0**, siehe `LICENSE` und `NOTICE`.

Die Titelgrafik oben ist keine Ausnahme von der Regel, sondern ihr Ergebnis: sie ist mit
`beispiel/titelgrafik.tex` aus der Klasse gesetzt und zeigt das Titeldesign des Baukastens.
Der Satz gehört diesem Projekt, das Design nicht.

Das gilt **nicht** für das Material, das in `grafiken/` und `schriften/` landet: weder für das aus
dem Baukasten noch für die Karten des Rückseiten-Pakets oder die einzelnen Grafikdateien. Dafür
gilt die *Vereinbarung über Gemeinschaftsinhalte für SCRIPTORIUM AVENTURIS*. Der Baukasten schreibt einen
Wortlaut vor, der in jedem damit gesetzten Werk stehen muss; die Klasse stellt ihn als
`\dsaRechtstext{…}` bereit.

> Das Schwarze Auge und sein Logo sowie Aventuria, Dere, Myranor, Riesland, Tharun, Uthuria, The
> Dark Eye und ihre Logos sind eingetragene Marken von Ulisses Medien und Spiele Distribution GmbH.

Dieses Projekt steht in keiner Verbindung zu Ulisses Spiele und ist nicht von dort autorisiert.
