# Hinweise für Claude Code

Diese Datei ist die Einweisung für Claude Code in dieses Projekt. Sie hat zwei Teile: **wie man mit
der Vorlage ein Dokument setzt** (Teil A) und **wie man an der Vorlage selbst arbeitet** (Teil B).
Wer nur ein Abenteuer schreiben soll, braucht Teil A.

## Was das hier ist

Zwei LaTeX-Dokumentklassen im Layout von *Das Schwarze Auge 5*, nach den Maßen des offiziellen
*Scriptorium Aventuris – Layout Baukastens*:

| Klasse | wofür | Dokumentation |
|---|---|---|
| `dsa5latex.cls` | Abenteuer, A4 hoch, zweispaltig mit Grundlinienraster | `doku/ELEMENTE.md` |
| `dsa5einleger.cls` | Einleger für den Spielleiterschirm, A4 quer, vier freie Spalten, kein Raster | `doku/EINLEGER.md` |

`dsa5einleger` lädt `dsa5latex` und ändert nur, was ein Einleger anders macht. Wie man einrichtet
und baut, steht featureübergreifend in `doku/EINRICHTUNG.md`. Dazu sieben Python-Werkzeuge in
`werkzeuge/`, fünf Dokumente in `doku/` und fünf Beispieldokumente in `beispiel/`.

**Weitere Features** (eigene Klassen oder Erweiterungen wie Charakterbogen, Aufsteller,
Battlemap) bekommen jeweils eine eigene Doku-Datei und einen eigenen Eintrag in der Feature-Liste
in `README.md` — siehe „Dokumentation neuer Features“ in Teil B.

---

# Teil A — ein Dokument setzen

## Der schnellste Weg zu einer `.tex`

**Erst nachsehen, dann schreiben.** `beispiel/beispiel.tex` zeigt jedes Element der
Abenteuerklasse genau einmal, `beispiel/einleger.tex` jedes der Einlegerklasse. Beide sind als
Vorlage zum Abschreiben gedacht. Was ein Befehl tut und welche Maße dahinterstehen, steht in
`doku/ELEMENTE.md` beziehungsweise `doku/EINLEGER.md` — **nie einen Befehl raten**, die Klassen
haben rund neunzig davon und keine Fehlermeldung, wenn einer fehlt.

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

### Gerüst für einen Einleger

Der Einleger hat keinen durchlaufenden Satz. Seine Seiten sind aus **Reihen** gebaut, und in einer
Reihe stehen **Kolumnen** von einer bis vier Spalten Breite nebeneinander. Verschachteln ist der
Normalfall.

```latex
\documentclass{dsa5einleger}
\begin{document}

\begin{dsaReihe}
  \dsaKolumne{1}{%
    \begin{dsaEinlegertabelle}[RW 19]{Eigenschaftsmodifikatoren}{Xl}
      \dsaKopfzeile Modifikator & \dsaKopfschrift Bewertung \\
      \dsaMod{+}{2} & leichte Probe \\
      \dsaMod{-}{2} & schwere Probe \\
    \end{dsaEinlegertabelle}}
  \dsaKolumne{3}{ …Block über die restlichen drei Spalten… }
\end{dsaReihe}

\end{document}
```

Drei Dinge, die im Einleger anders heißen als im Abenteuer: Abstand ist `\dsaLuft{n}` statt
`\dsaRasterluft{n}`, feste Spaltenbreiten sind `T{22mm}` statt `L{22mm}`, und Tabellen kommen in
`dsaEinlegertabelle` statt `dsaTabelle`. Alles Weitere in `doku/EINLEGER.md`.

## Wo was steht

| Frage | Antwort steht in |
|---|---|
| Welcher Befehl setzt X? | `doku/ELEMENTE.md`, Abschnitt nach Elementart |
| Welche Kästen gibt es, wie groß sind sie? | `doku/ELEMENTE.md`, „Kästen“ — fünfzehn Umgebungen mit Maßen |
| Wie setze ich eine Tabelle? | `doku/ELEMENTE.md`, „Tabellen und Raster“ |
| Wie geht Textumfluss um ein Bild? | `doku/ELEMENTE.md`, „Textumfluss“ |
| Einleger: Reihen, Kolumnen, Tabellen | `doku/EINLEGER.md`, Abschnitte 5 bis 7 |
| Woher kommt dieser Zahlenwert? | `doku/MASSE.md` |
| Ist das geprüft? | `doku/PRUEFPLAN.md` |
| Wie besorge ich Grafiken und Schriften? | `doku/EINRICHTUNG.md`, „Grafiken und Schriften besorgen“ |

## Die fünf Fallen beim Setzen

1. **Jeder senkrechte Abstand ist ein Vielfaches von 12 bp.** `\vspace{5mm}` ist immer falsch,
   `\dsaRasterluft{n}` ist richtig. Gilt nicht im Einleger, der hat kein Raster.
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
TEXINPUTS="..;" xelatex meineinleger.tex      # einmal genügt, kein Inhaltsverzeichnis
```

Liegt sie woanders, muss `TEXINPUTS` auf den Ordner mit der `.cls` zeigen und `\graphicspath` auf
den mit `grafiken/`.

Beim Schreiben `entwurf` in die Klassenoptionen nehmen — Bilder werden zu Rahmen, der Lauf dauert
Sekunden statt Minuten. Vor dem Abgeben einmal ohne bauen und **einmal mit `rasterzeigen`**: sitzen
die Zeilen beider Spalten auf einer Höhe? Für den Einleger heißt die Option `spaltenzeigen`, und sie
zeigt die vier Spaltenkanten.

**Was schiefgehen kann, ohne dass LaTeX etwas sagt:** eine Tabelle, die höher ist als eine Spalte,
läuft unten heraus (die Klasse warnt, aber nur als `Class dsa5latex Warning`); eine Kolumne im
Einleger, deren Inhalt nicht auf die Seite passt, ebenso — dort ohne jede Meldung. Deshalb nach dem
Bau **ins PDF sehen**, nicht nur ins Log.

---

# Teil B — an der Vorlage arbeiten

## Die vier Regeln

**1. Maße werden gemessen, nicht geschätzt.** Jeder Zahlenwert in der Klasse hat eine Quelle, und
die steht in `doku/MASSE.md`. Es gibt drei zulässige Quellen, in dieser Rangfolge:

1. der Klartext des Verlags — Seite 2 des Baukasten-PDF, `Lies mich zuerst v1.4.pdf`
2. die Pixelmaße der Vorlagengrafiken, geteilt durch 300 ppi
3. die Rahmenmaße im IDML, aber nur dort, wo `ActualPpi` und `EffectivePpi` gleich sind

Für `dsa5einleger.cls` kommt eine vierte Quelle dazu, und **nur für sie**: der offizielle
*Universal Spielleiterschirm Einleger, Auflage 5*, Seiten 4 bis 6. Der Baukasten kennt kein
Querformat und keine Tabellenseite ohne Raster; für alles, was er selbst sagt, bleibt er
maßgeblich. Was aus dem Einleger stammt, steht in `doku/MASSE.md`, Abschnitt 8.

Wo alle Quellen schweigen, wird der Wert als geschätzt gekennzeichnet und kommt in
`doku/MASSE.md` unter „Was offen ist“. **Nie eine Zahl erfinden und nie eine ändern, ohne die
Quelle nachzusehen.**

**2. Das Grundlinienraster ist nicht verhandelbar.** 12 bp, nicht 12 pt — der Baukasten ist in
InDesign gesetzt, und dort ist ein Punkt 1/72 Zoll. Jeder senkrechte Abstand ist ein Vielfaches
von `\dsaRaster{1}`. `\vspace{5mm}` ist in diesem Projekt immer falsch; `\dsaRasterluft{n}` ist
richtig. Wer ein Element einbaut, das höher ist als eine Zeile, muss es in eine Box ohne Höhe und
Tiefe setzen und den Raum mit `\dsaRasterluft` liefern — sonst greift die Grundlinienregel nicht,
TeX fällt auf `\lineskip` zurück, und alles darunter liegt daneben.

**Im Einleger gilt das nicht, und auch das ist gemessen.** Von den 371 Grundlinien der drei
Originalseiten treffen gegen ein 12-bp-Raster 17 — nicht mehr als zufällig. `dsa5einleger.cls`
hat deshalb kein Raster; senkrechte Abstände kommen dort von `\dsaLuft{n}` und zählen in
Textzeilen zu 10,8 bp. An die Stelle der Rasterprüfung tritt die Prüfung der Spaltenkanten.

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

Fünf Beispieldokumente, alle in `beispiel/`:

| Datei | Klasse | wofür |
|---|---|---|
| `beispiel.tex` | `dsa5latex` | jedes Element genau einmal, 22 Seiten — der Regellauf |
| `raster.tex` | `dsa5latex` | nur Text und Raster, baut in Sekunden — für schnelle Prüfungen |
| `kaesten.tex` | `dsa5latex` | alle fünfzehn Kästen |
| `rest.tex` | `dsa5latex` | Seitentypen, Umschlag, Rückseite |
| `einleger.tex` | `dsa5einleger` | jedes Element der Einlegerklasse, drei Seiten A4 quer |

Klassenoptionen zum Arbeiten: `entwurf` setzt Bilder als Rahmen und macht den Lauf um ein
Vielfaches schneller, `ohnehintergrund` lässt die 7-MB-Seitenhintergründe weg, `rasterzeigen`
druckt die Grundlinien mit. Im Einleger heißt letztere `spaltenzeigen` und druckt die
Spaltenkanten.

Der Einleger braucht einmalig eigene Hintergrundgrafiken, die aus den Buchseiten erzeugt werden:

```sh
python3 werkzeuge/einleger.py            # nach aufbereiten.py, einmal
```

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

**Für den Einleger gilt eine andere Prüfung.** Er hat kein Raster; stattdessen muss jede
waagerechte Tabellenlinie auf einer der acht Spaltenkanten beginnen und enden — 31,18 / 217,06 /
229,06 / 414,95 / 426,94 / 612,83 / 624,83 / 810,71 bp —, und jede einzeilige Tabellenzeile muss
14,56 bp hoch sein. Der zweite Weg ist `spaltenzeigen`. Einzelheiten in `doku/EINLEGER.md`,
Abschnitt 10.

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
* `% PRUEFEN:` markiert eine Stelle, die nicht am Ergebnis geprüft ist — anders als `% OFFEN:`
  gibt es hier eine Quelle, nur hat sie noch niemand mit dem Ergebnis verglichen. Wer sie prüft,
  entfernt die Marke und trägt das Ergebnis in `doku/PRUEFPLAN.md` ein.
* Benennung: öffentliche Befehle `\dsaGrossKlein`, Längen und interne Werte `\dsakleinzusammen`,
  Internes mit `@`: `\dsa@name`.
* Die Klassen sind in nummerierte Abschnitte geteilt (`%%% 17  Tabellen`) — `dsa5latex.cls` in
  zwanzig, `dsa5einleger.cls` in neun. Neues kommt in den passenden Abschnitt, nicht ans Ende.

## Was zusammen geändert werden muss

Eine Änderung an einer Klasse ist erst vollständig, wenn diese vier Stellen zusammenpassen:

| | Abenteuer | Einleger |
|---|---|---|
| Umsetzung samt Kommentar mit Begründung | `dsa5latex.cls` | `dsa5einleger.cls` |
| der Befehl in der Referenz | `doku/ELEMENTE.md` | `doku/EINLEGER.md` |
| der Zahlenwert mit seiner Quelle | `doku/MASSE.md` | `doku/MASSE.md`, Abschnitt 8 |
| das Element im Regellauf | `beispiel/beispiel.tex` | `beispiel/einleger.tex` |

Kommt ein Maß aus dem Baukasten neu dazu, gehört es außerdem nach `werkzeuge/pruefen.py`.

**Am Einleger arbeiten heißt fast immer, an `dsa5einleger.cls` zu arbeiten, nicht an
`dsa5latex.cls`.** Die Einlegerklasse lädt die Abenteuerklasse; eine Änderung dort schlägt auf
alle vier Abenteuer-Beispiele durch und muss dort nachgemessen werden.

## Dokumentation neuer Features

Ein neues Feature (eine eigene Klasse wie `dsa5einleger.cls` oder eine Erweiterung der
Kernklasse wie der Aufsteller) bekommt **eine eigene Doku-Datei**, `doku/<FEATURE>.md` in
Großbuchstaben — zum Beispiel `doku/AUFSTELLER.md` oder `doku/BATTLEMAP.md` — statt eines
Abschnitts in `doku/ELEMENTE.md`. `doku/ELEMENTE.md` bleibt der Kernklasse `dsa5latex.cls`
vorbehalten; der Einleger folgt diesem Muster bereits mit `doku/EINLEGER.md`.

Dazu gehört ein eigener Eintrag in der Feature-Liste in `README.md`: eine Zeile mit Kurzform,
Klasse (falls eine eigene) und Verweis auf die neue Doku-Datei. Das Allgemeine — Grafiken und
Schriften besorgen, Bauen, mit einer KI setzen — steht bereits in `doku/EINRICHTUNG.md` und
muss nicht wiederholt werden; ein Feature ergänzt dort nur, was es zusätzlich braucht (eigene
Beispieldokumente, eigene Klassenoptionen).

`doku/MASSE.md` und `doku/PRUEFPLAN.md` bleiben **gemeinsame, projektweite Protokolle** — nicht
aufsplitten. Jedes Feature bekommt darin einen eigenen, klar abgegrenzten Abschnitt (wie
Abschnitt 8 in `doku/MASSE.md` für den Einleger), damit Messungen an einem Ort auffindbar und
über Features hinweg vergleichbar bleiben.

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
