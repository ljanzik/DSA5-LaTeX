# Hinweise für Claude Code

Diese Datei ist die Einweisung für Claude Code in dieses Projekt. Sie hat zwei Teile: **wie man mit
der Vorlage ein Dokument setzt** (Teil A) und **wie man an der Vorlage selbst arbeitet** (Teil B).
Wer nur ein Abenteuer schreiben soll, braucht Teil A.

## Was das hier ist

`dsa5latex.cls` setzt Abenteuer im Layout von *Das Schwarze Auge 5*, nach den Maßen des
offiziellen *Scriptorium Aventuris – Layout Baukastens*: A4 hoch, zweispaltig, mit
Grundlinienraster. Die Elementreferenz steht in `doku/ELEMENTE.md`, wie man einrichtet und baut
in `doku/EINRICHTUNG.md`. Dazu acht Python-Werkzeuge in `werkzeuge/`, fünf Dokumente in `doku/`
und vier Beispieldokumente in `beispiel/`.

**Weitere Features** (eigene Klassen oder Erweiterungen wie Aufsteller, Battlemap, SL-Einleger)
bekommen jeweils eine eigene Doku-Datei und einen eigenen Eintrag in der Feature-Liste in
`README.md` — siehe „Dokumentation neuer Features“ in Teil B.

`werkzeuge/einrichten.py` ist die Klammer über alles, was aus dem Baukasten kommt: es ruft
`aufbereiten.py`, `pergament.py` und `pruefen.py` mit **einem** Baukastenpfad auf. Wer wissen
will, was fehlt, ruft es mit `--pruefen` ohne Argument auf — es prüft dann auch XeLaTeX,
pdflatex und Ghostscript. Letzteres steckt unter Windows in TeX Live, unter macOS nicht
(`brew install ghostscript`); ohne es fallen nur `bogen/bau/rendern`, `linien-lesen` und die
Normalisierung der Farbquelle aus.

## Der Heldenbogen ist ein eigener Bereich

`bogen/` ist die Ausnahme von allem, was in dieser Datei steht: es überlagert das offizielle
DSA5-Heldendokument mit AcroForm-Feldern, läuft deshalb **zwingend mit pdflatex** statt
XeLaTeX, kennt kein Grundlinienraster und misst seine 1255 Koordinaten nicht am Baukasten,
sondern aus den PDF-Content-Streams des Verlagsbogens. Dazu gehört die Charaktermappe
(`bogen/mappe/`), der Umschlag für die Bögen.

**Die Regeln von Teil B gelten dort nicht.** Wer an `bogen/` arbeitet, liest `doku/BOGEN.md`;
wer an der Klasse arbeitet, braucht ihn nicht. Berührungspunkte sind heute zwei: die Schriften
in `schriften/`, die beide Seiten aus `werkzeuge/aufbereiten.py` bekommen, und die
Wertedateien `bogen/helden/*.tex`. Die Maße des Bogens stehen in `doku/BOGEN.md`, nicht in
`doku/MASSE.md` — dort bleibt die Dreier-Rangfolge des Baukastens unter sich.

**Skripte sind Python, `.ps1` und `.sh` sind Weiterleitungen.** In `bogen/bau/` liegt zu jedem
Ablauf eine `.py` mit der Logik und daneben zwei dreizeilige Aufrufer. Wer etwas ändert, ändert
die `.py` — sonst hat man wieder zwei Fassungen desselben Ablaufs, und genau davon hatte dieses
Projekt schon vier. Die Schalter sind in PowerShell-Schreibweise (`-Held dorle`, `-Alle`), damit
derselbe Aufruf überall gilt.

---

# Teil A — ein Dokument setzen

## Der schnellste Weg zu einer `.tex`

**Erst nachsehen, dann schreiben.** `beispiel/beispiel.tex` zeigt jedes Element der Klasse
genau einmal und ist als Vorlage zum Abschreiben gedacht. Was ein Befehl tut und welche Maße
dahinterstehen, steht in `doku/ELEMENTE.md` — **nie einen Befehl raten**, die Klasse hat rund
neunzig davon und keine Fehlermeldung, wenn einer fehlt.

### Gerüst für ein Abenteuer

```latex
\documentclass[raster]{dsa5latex}
\graphicspath{{../}}                    % wenn die .tex in einem Unterordner liegt
\dsaAbenteuertitel{Titel des Abenteuers} % steht im Kolumnentitel

\begin{document}

\dsaUmschlagVorne{grafiken/titelbild}{%
  \dsaTitelZeile{Titel des}%
  \dsaTitelZeile{Abenteuers}}

\begin{dsaImpressumseite}
\dsaImpressumsblock{Autor}{[Name]}
\dsaRechtevermerk{2026}{[Name oder Firma]}
\end{dsaImpressumseite}

\dsaInhalt

\dsakapitel{Erstes Kapitel}            % oder \dsakapitelbild[grafiken/bild]{…}

\dsaEinfuehrung{Ein kursiver Vorspann.}

\dsaabschnitt{Ein Abschnitt}

Fließtext. Absätze durch Leerzeilen, kein Einzug, kein \verb|\vspace|.

\dsaRueckseite{ruecken-mittelreich}{Titel}{von [Name]}{Klappentext}{%
  \dsaRueckKopf{Ein DSA-Gruppenabenteuer\\für 3 bis 5 Helden}}

\end{document}
```

## Wo was steht

| Frage | Antwort steht in |
|---|---|
| Welcher Befehl setzt X? | `doku/ELEMENTE.md`, Abschnitt nach Elementart |
| Welche Kästen gibt es, wie groß sind sie? | `doku/ELEMENTE.md`, „Kästen“ — fünfzehn Umgebungen mit Maßen |
| Wie setze ich eine Tabelle? | `doku/ELEMENTE.md`, „Tabellen und Raster“ |
| Wie geht Textumfluss um ein Bild? | `doku/ELEMENTE.md`, „Textumfluss“ |
| Woher kommt dieser Zahlenwert? | `doku/MASSE.md` |
| Ist das geprüft? | `doku/PRUEFPLAN.md` |
| Wie besorge ich Grafiken und Schriften? | `doku/EINRICHTUNG.md`, „Grafiken und Schriften besorgen“ |

## Die fünf Fallen beim Setzen

1. **Jeder senkrechte Abstand ist ein Vielfaches von 12 bp.** `\vspace{5mm}` ist immer falsch,
   `\dsaRasterluft{n}` ist richtig.
2. **Jedes Bild im Textfluss belegt eine ganze Zahl Rastereinheiten.** `\dsaBildSpalte{Bild}{7}`
   oder `\dsaBildRaster{7}{…}`. Ein `\includegraphics` mitten im Text verschiebt alles darunter.
3. **Kein `$…$`.** Die Klasse lädt kein Mathematikpaket. Zahlenangaben mit `\dsaFormel{1W6+4}`,
   Modifikatoren mit `\dsaMod{-}{2}`.
4. **Tabellen kommen in `dsaTabelle`, nicht in `tabular`**, und die Umgebung zieht die Linien
   selbst. Ein eigenes `\hline` bricht das Raster.
5. **Ohne `grafiken/` und `schriften/` kompiliert nichts.** Beide Ordner sind bis auf
   `grafiken/titelbild.jpg` absichtlich leer im Repository; `werkzeuge/aufbereiten.py` füllt
   sie aus dem Baukasten.

## Bauen und ansehen

Die `.tex` liegt am einfachsten in `beispiel/`, dann findet sie Klasse, Grafiken und Schriften
ohne Zutun:

```sh
cd beispiel
TEXINPUTS="..;" xelatex meinabenteuer.tex     # dreimal, wegen Inhalt und Marken
```

Liegt sie woanders, muss `TEXINPUTS` auf den Ordner mit der `.cls` zeigen und `\graphicspath` auf
den mit `grafiken/`.

Beim Schreiben `entwurf` in die Klassenoptionen nehmen — Bilder werden zu Rahmen, der Lauf dauert
Sekunden statt Minuten. Vor dem Abgeben einmal ohne bauen und **einmal mit `rasterzeigen`**: sitzen
die Zeilen beider Spalten auf einer Höhe?

**Was schiefgehen kann, ohne dass LaTeX etwas sagt:** eine Tabelle, die höher ist als eine
Spalte, läuft unten heraus — die Klasse warnt, aber nur als `Class dsa5latex Warning`. Deshalb
nach dem Bau **ins PDF sehen**, nicht nur ins Log.

---

# Teil B — an der Vorlage arbeiten

## Die vier Regeln

**1. Maße werden gemessen, nicht geschätzt.** Jeder Zahlenwert in der Klasse hat eine Quelle, und
die steht in `doku/MASSE.md`. Es gibt drei zulässige Quellen, in dieser Rangfolge:

1. der Klartext des Verlags — Seite 2 des Baukasten-PDF, `Lies mich zuerst v1.4.pdf`
2. die Pixelmaße der Vorlagengrafiken, geteilt durch 300 ppi
3. die Rahmenmaße im IDML, aber nur dort, wo `ActualPpi` und `EffectivePpi` gleich sind

Wo alle Quellen schweigen, wird der Wert als geschätzt gekennzeichnet und kommt in
`doku/MASSE.md` unter „Was offen ist“. **Nie eine Zahl erfinden und nie eine ändern, ohne die
Quelle nachzusehen.**

**2. Das Grundlinienraster ist nicht verhandelbar.** 12 bp, nicht 12 pt — der Baukasten ist in
InDesign gesetzt, und dort ist ein Punkt 1/72 Zoll. Jeder senkrechte Abstand ist ein Vielfaches
von `\dsaRaster{1}`. `\vspace{5mm}` ist in diesem Projekt immer falsch; `\dsaRasterluft{n}` ist
richtig. Wer ein Element einbaut, das höher ist als eine Zeile, muss es in eine Box ohne Höhe und
Tiefe setzen und den Raum mit `\dsaRasterluft` liefern — sonst greift die Grundlinienregel nicht,
TeX fällt auf `\lineskip` zurück, und alles darunter liegt daneben.

**3. Grafiken und Schriften gehören nicht ins Repository.** `grafiken/` und `schriften/` sind in
`.gitignore`. Das Material gehört Ulisses Spiele und steht unter der Scriptorium-Vereinbarung, die
mit Apache 2.0 nicht vereinbar ist. Nie eine Datei aus diesen Ordnern einchecken, auch keine
verkleinerte Fassung, auch nicht „nur zum Testen“.

Eine einzige Datei ist ausgenommen und in `.gitignore` freigestellt:
`grafiken/titelbild.jpg`, der Zwerg am Setzkasten. Sie ist mit einer KI erzeugt und stammt
nicht aus dem Baukasten. Was neu dazukommt, gehört nur dann ebenfalls freigestellt, wenn es
nachweislich nicht von Ulisses stammt — im Zweifel nicht.

**4. Nichts gilt als fertig, bevor es gemessen ist.** Eine Änderung am Satz wird gebaut und am PDF
nachgemessen — nicht am Quelltext beurteilt. Wie, steht unten.

## Bauen

XeLaTeX ist Pflicht (`fontspec`, `polyglossia`). Die Klasse sucht die Schriften in `./schriften/`
oder `./../schriften/`, jeweils vom **Arbeitsverzeichnis** aus.

```sh
cd beispiel
TEXINPUTS="..;" xelatex beispiel.tex     # dreimal, wegen Inhalt und Marken
```

`TEXINPUTS` ist nötig, weil `dsa5latex.cls` eine Ebene höher liegt und nicht installiert ist. Wer
die Klasse nach `TEXMFHOME/tex/latex/dsa5latex/` legt, kann es weglassen.

Vier Beispieldokumente, alle in `beispiel/`:

| Datei | Klasse | wofür |
|---|---|---|
| `beispiel.tex` | `dsa5latex` | jedes Element genau einmal, 22 Seiten — der Regellauf |
| `raster.tex` | `dsa5latex` | nur Text und Raster, baut in Sekunden — für schnelle Prüfungen |
| `kaesten.tex` | `dsa5latex` | alle fünfzehn Kästen |
| `rest.tex` | `dsa5latex` | Seitentypen, Umschlag, Rückseite |

Klassenoptionen zum Arbeiten: `entwurf` setzt Bilder als Rahmen und macht den Lauf um ein
Vielfaches schneller, `ohnehintergrund` lässt die 7-MB-Seitenhintergründe weg, `rasterzeigen`
druckt die Grundlinien mit.

## Prüfen

```sh
python3 werkzeuge/nachmessen.py beispiel/beispiel.pdf --seite 5 --text
python3 werkzeuge/pruefen.py
```

`nachmessen.py` gibt Lage und Größe jeder Grafik und jeder Textzeile in Millimetern aus und
erkennt die Grafiken an ihren Pixelmaßen. `pruefen.py` vergleicht die Dateien in `grafiken/`
gegen die Sollmaße.

Für das Raster ist die entscheidende Prüfung: **jede Grundlinie muss auf 84 bp + k · 12 bp unter
der Papieroberkante liegen.** Im PDF sind die Einheiten bp, also direkt vergleichbar. Ausnahmen
sind nur die Elemente mit eigenem Maß — Seitenzahl, Kolumnentitel, Kastentext.

Der zweite Weg ist `rasterzeigen`: bauen, ansehen, ob die Zeilen beider Spalten auf einer Höhe
liegen. Das ist die einzige Prüfung, die das Raster wirklich prüft.

Was geprüft wurde und was dabei herauskam, steht in `doku/PRUEFPLAN.md`. Wer etwas prüft, trägt
das Ergebnis dort ein — auch ein „passt“.

## Schreibweise

* **Kommentare in der Klasse sind deutsch und ohne Umlaute** — `ue`, `oe`, `ae`, `ss`. In
  Zeichenketten, die im Satz erscheinen, stehen echte Umlaute. Die Markdown-Dateien haben überall
  echte Umlaute.
* Die Kommentare erklären **warum**, nicht was. Wo ein Wert gemessen wurde, steht die Messung
  daneben: „gemessen 3,3 bp neben dem Raster“. Wo ein Weg verworfen wurde, steht warum er
  verworfen wurde. Das ist der Ton der Datei — wer etwas hinzufügt, hält ihn.
* `% OFFEN:` markiert einen Wert, für den der Baukasten keine Quelle hergibt — nicht eine
  Stelle, die nur noch niemand geprüft hat. Wer eine Quelle findet, entfernt die Marke, trägt
  den Wert mit seiner Quelle in `doku/MASSE.md` ein und die Messung in `doku/PRUEFPLAN.md`.
* Benennung: öffentliche Befehle `\dsaGrossKlein`, Längen und interne Werte `\dsakleinzusammen`,
  Internes mit `@`: `\dsa@name`.
* Die Klasse ist in zwanzig nummerierte Abschnitte geteilt (`%%% 17  Tabellen`). Neues kommt in
  den passenden Abschnitt, nicht ans Ende.

## Was zusammen geändert werden muss

Eine Änderung an der Klasse ist erst vollständig, wenn diese vier Stellen zusammenpassen:

1. `dsa5latex.cls` — die Umsetzung samt Kommentar mit Begründung
2. `doku/ELEMENTE.md` — der Befehl in der Elementreferenz
3. `doku/MASSE.md` — der Zahlenwert mit seiner Quelle, falls einer dazukam
4. `beispiel/beispiel.tex` — das Element im Regellauf, damit es mitgebaut wird

Kommt ein Maß aus dem Baukasten neu dazu, gehört es außerdem nach `werkzeuge/pruefen.py`.

## Dokumentation neuer Features

Ein neues Feature (eine eigene Klasse wie `dsa5einleger.cls` oder ein eigener Bereich wie der
Heldenbogen oder eine Erweiterung der Kernklasse wie der Aufsteller) bekommt **eine eigene
Doku-Datei**, `doku/<FEATURE>.md` in Großbuchstaben — zum Beispiel `doku/AUFSTELLER.md` oder
`doku/BATTLEMAP.md` — statt eines Abschnitts in `doku/ELEMENTE.md`. `doku/ELEMENTE.md` bleibt
der Kernklasse `dsa5latex.cls` vorbehalten; der Heldenbogen folgt diesem Muster bereits mit
`doku/BOGEN.md`.

Dazu gehört ein eigener Eintrag in der Feature-Liste in `README.md`: eine Zeile mit Kurzform,
Klasse (falls eine eigene) und Verweis auf die neue Doku-Datei. Das Allgemeine — Grafiken und
Schriften besorgen, Bauen, mit einer KI setzen — steht bereits in `doku/EINRICHTUNG.md` und
muss nicht wiederholt werden; ein Feature ergänzt dort nur, was es zusätzlich braucht (eigene
Beispieldokumente, eigene Klassenoptionen).

`doku/MASSE.md` und `doku/PRUEFPLAN.md` bleiben **gemeinsame, projektweite Protokolle für alles,
was sich am Baukasten misst** — nicht aufsplitten. Jedes Feature bekommt darin einen eigenen,
klar abgegrenzten Abschnitt (wie Abschnitt 8 in `doku/MASSE.md` für den Einleger), damit
Messungen an einem Ort auffindbar und über Features hinweg vergleichbar bleiben. Die einzige
Ausnahme ist der Heldenbogen: seine Koordinaten stammen nicht aus dem Baukasten, sondern aus den
PDF-Content-Streams des Verlagsbogens, und stehen deshalb eigenständig in `doku/BOGEN.md` — siehe
„Der Heldenbogen ist ein eigener Bereich“ oben.

## Git

* Commit-Nachrichten sind deutsch, ohne Umlaute, Betreff im Aussagesatz ohne Punkt:
  „Kapitel auf rechte Seiten, und sechs Warnungsursachen behoben“. Der Rumpf nennt Befund,
  Ursache und Messung — er ist oft dreißig Zeilen lang, und das ist so gewollt.
* Der Autor kommt aus der Git-Konfiguration des jeweiligen Klons. Nie `--author` setzen und
  nie einen Namen aus dieser Datei übernehmen: wer hier arbeitet, committet unter seiner
  eigenen Kennung.
* Nichts committen oder pushen ohne ausdrückliche Aufforderung.

## Der Baukasten

Die Quelle aller Maße ist der *Scriptorium Aventuris – Layout Baukasten* von Ulisses Spiele
(kostenlos, siehe README). Er liegt nicht im Repository. Die IDML darin ist ein ZIP:

```
Scriptorium Aventuris v4.idml
├── Resources/Styles.xml    Absatz-, Zeichen-, Tabellen- und Zellenformate
├── Resources/Graphic.xml   Farben und Farbverläufe
├── Stories/*.xml           die Texte samt Tabellen
└── Spreads/*.xml           die Rahmen mit ActualPpi und EffectivePpi
```

Das gesetzte `Scriptorium Aventuris v4.pdf` daneben ist der Musterbogen. Wo die IDML einen Wert
nennt, der im PDF anders aussieht — Tonwerte von CMYK-Schwarz zum Beispiel —, gilt das PDF: das
ist die Farbe, die der Leser sieht. Beides gehört dann in den Kommentar.
