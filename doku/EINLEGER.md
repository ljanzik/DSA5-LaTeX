# Einleger für den Spielleiterschirm

*Alles über `dsa5einleger.cls`: was die Klasse ist, woher ihre Maße kommen, jeder Befehl, und die
Fallstricke, die beim Bauen aufgetreten sind. Wer hier setzt, braucht `ELEMENTE.md` daneben — die
Hälfte der Befehle kommt von der Abenteuerklasse.*

---

## 1. Was das ist

`dsa5einleger.cls` setzt Einleger für einen Spielleiterschirm im Layout von *Das Schwarze Auge 5*:
Tabellenseiten im Querformat, die hinter die Sichtblenden eines Schirms gesteckt werden. Vorbild
ist der offizielle *Universal Spielleiterschirm Einleger, Auflage 5* von Ulisses Spiele, an dessen
Seiten 4 bis 6 jedes Maß dieser Klasse nachgemessen wurde.

**Ein Unterschied ist Absicht: das Papier.** Das Original ist 276 × 216 mm, ein Sonderformat. Diese
Klasse setzt auf **DIN A4 quer, 297 × 210 mm** — damit der Einleger auf jedem Drucker herauskommt.
Alles andere folgt dem Original.

Die Klasse lädt `dsa5latex.cls` und ändert daran nur, was ein Einleger anders macht. Farben,
Schriften, Marken im Text, Aufzählungen und Kästen kommen unverändert von dort; es gibt für jeden
Farbwert und jeden Schriftaufruf weiterhin genau eine Quelle im Projekt.

| | Abenteuer (`dsa5latex`) | Einleger (`dsa5einleger`) |
|---|---|---|
| Papier | A4 hoch, doppelseitig | **A4 quer, einseitig** |
| Spalten | 2 feste, durchlaufend | **4 freie**, ein Block darf über mehrere |
| Grundlinienraster | 12 bp, verbindlich | **keins** |
| Grundschrift | 10 bp auf 12 bp | **9 bp auf 10,8 bp** |
| Tabellenzeile | eine Rastereinheit | **14,56 bp** |
| Farbverlauf | hinter der Titelzeile | **hinter der Kopfzeile** |
| Seitenzahl | in der Kartusche | keine |

### Warum es kein Grundlinienraster gibt

Das ist kein Versäumnis, sondern gemessen. Auf den drei Originalseiten liegen 371 Grundlinien.
Getestet gegen ein Raster von 12, 11 und 10,5 bp treffen davon 17, 26 und 26 — also nicht mehr, als
der Zufall hergibt. Die Abstände zwischen aufeinanderfolgenden Grundlinien sind über 40
verschiedene Werte. Der Einleger ist frei gesetzt, und das passt zur IDML des Baukastens, die für
Tabellen ausdrücklich `GridAlignment="None"` führt.

**Für die Praxis heißt das: `\dsaRasterluft` hat hier nichts zu suchen.** Senkrechte Abstände
kommen von `\dsaLuft{n}` und zählen in Textzeilen zu 10,8 bp.

---

## 2. Vorbereiten

Die Klasse braucht zwei Sorten Grafiken. Die erste holt `aufbereiten.py` wie gewohnt aus dem
Baukasten, die zweite erzeugt `einleger.py` daraus:

```sh
python3 werkzeuge/aufbereiten.py "/pfad/zu/Scriptorium Aventuris v4"
python3 werkzeuge/einleger.py
```

Das legt in `grafiken/` an:

| Datei | Maß | woraus |
|---|---|---|
| `einleger-flaeche-0.jpg` … `-2.jpg` | 303,0 × 216,0 mm | `seite-links-N.jpg`, gedreht, Kante entfernt |
| `einleger-leiste-oben.png` | 303,0 × 8,5 mm | Schuppenkante aus `seite-links-0.jpg`, um 90° gedreht |
| `einleger-leiste-unten.png` | 303,0 × 8,5 mm | dieselbe Kante aus `seite-rechts-0.jpg` |
| `einleger-leiste-links.png` | 8,5 × 216,0 mm | aus `seite-links-0.jpg`, ungedreht |
| `einleger-leiste-rechts.png` | 8,5 × 216,0 mm | aus `seite-rechts-0.jpg` |

Die beiden senkrechten Leisten liegen nur bereit; gesetzt werden sie erst, wenn jemand
`\dsaRahmenRundum` aufruft. **Im Original hat keine einzige Seite einen umlaufenden Rahmen** —
weder die Tabellenseiten noch die Bildseiten. Gegenüberliegende Kanten kommen aus verschiedenen
Buchseiten, damit sich das Schuppenmuster nicht spiegelbildlich wiederholt.

Prüfen, ohne etwas zu schreiben: `python3 werkzeuge/einleger.py --pruefen`.

### Zur Zierleiste

Der Baukasten hat keinen Querformat-Hintergrund und keine waagerechte Zierleiste. Er hat aber die
vier Buchseiten, und die tragen am Bund **genau das Motiv, das der offizielle Einleger oben und
unten über die volle Breite legt**: eine Reihe dunkler Drachenschuppen mit Goldkante. Es ist
dieselbe Grafik, nur um 90 Grad gedreht.

Der einzige Unterschied ist die Größe. Die Leiste des Originals ist 1694 × 111 px auf 811 × 53,2 bp
platziert, also 150 ppi und 18,8 mm hoch; die Buchkante misst bei 300 ppi 8,5 mm. `einleger.py`
nimmt sie in ihrer eigenen Auflösung — der Rahmen wird dadurch schlanker als im Original, dafür
steht die Grafik voll da. Wer den breiten Rahmen will:

```sh
python3 werkzeuge/einleger.py --leiste 18.8
```

Dann ist die Leiste auf 136 ppi hochgerechnet. In der Klasse muss dann `\dsaeinlegerleiste`
mitgehen (siehe unten).

Die eine Erfindung des Werkzeugs ist der weiche Auslauf nach innen, 3 mm. Ohne ihn steht eine harte
Kante auf dem Pergament: die Buchseite hat dort den Übergang zum Bund, nicht zum freien Rand.

### Andere Grafiken, die sich anbieten

Aus dem Baukastenmaterial passen in einen Einleger außerdem:

| Grafik | Maß | wofür |
|---|---|---|
| `trenner-oben.png` | 52,8 × 9,8 mm | schmale Zierleiste zwischen zwei Blöcken |
| `trenner-unten.png`, `trenner-buch.png` | 158,5 × 29,5 mm | breite Zierleiste mit Drachenauge, über 2–3 Spalten |
| `kapitelbanner.png` | 210,1 × 43,2 mm | Pergamentband hinter einer Überschrift |
| `pergament-klein/-mittel/-lang/-breit/-schmal` | siehe `MASSE.md` | Kastenflächen mit gezacktem Rand |
| `aufzaehlung.png` | 21,8 × 11,8 mm | die Raute vor jedem `\item`, kommt über `dsaliste` von selbst |

Eingebunden werden sie wie in der Abenteuerklasse, über `\dsagrafik{name}`.

---

## 3. Bauen

```sh
cd beispiel
TEXINPUTS="..;" xelatex einleger.tex
```

Ein Durchlauf genügt — der Einleger hat kein Inhaltsverzeichnis und keine Marken.

| Klassenoption | Wirkung |
|---|---|
| `spaltenzeigen` | druckt die vier Spaltenkanten und den Satzspiegel mit |
| `ohnehintergrund` | lässt Pergament und Leisten weg, spart 8 MB je Seite |
| `entwurf` | wird an `dsa5latex` durchgereicht: Bilder als Rahmen |

**`spaltenzeigen` ist für den Einleger, was `rasterzeigen` für das Abenteuer ist.** Ohne
Grundlinienraster sagt nur der Blick auf die Kanten, ob ein Block sitzt. Nach jeder Änderung am
Aufbau einmal damit bauen.

---

## 4. Der Satzspiegel

Am Original nachgemessen, Seiten 4 bis 6, über alle Tabellenkanten:

| Größe | Original (276 mm breit) | diese Klasse (A4 quer) |
|---|---|---|
| Papier | 276 × 216 mm | **297 × 210 mm** |
| Rand seitlich | 31,181 bp = 11,00 mm | 31,181 bp = **11,00 mm** |
| Rand oben und unten | 37,04 bp / 33,3 bp | **12 mm**, frei gewählt |
| Spalten | 4 | **4** |
| Spaltenbreite | 171,0 bp = 60,32 mm | 185,882 bp = **65,58 mm** |
| Spaltenabstand | 12,0 bp = 4,23 mm | 12,0 bp = **4,23 mm** |
| Satzbreite | 720,0 bp | 779,528 bp = **275,00 mm** |

**Die Probe des Spaltenmodells.** Im Original ist 31,181 + 4 × 171 + 3 × 12 = 751,18 bp, und genau
dort liegt die rechte Kante jeder Tabelle der vierten Spalte. Die sechs inneren Spaltenkanten
treffen auf ein Hundertstel bp: 202,18 / 214,18 / 385,18 / 397,18 / 568,18 / 580,18. Kein einziger
Block der drei Seiten steht daneben.

Auf A4 quer bleiben Rand und Abstand, die Spalten werden 8,7 Prozent breiter. Fünf Spalten wären
mit 51,6 mm schmaler als das Original, und darin geht keine Tabelle mit vier Wertespalten mehr auf.

### Einstellen

```latex
\dsaSpalten{5}                                  % Spaltenzahl, rechnet die Breite neu
\setlength{\dsaeinlegerrandoben}{16mm}          % danach \dsaSpalten{4} wiederholen
\setlength{\dsaeinlegerleiste}{18.5mm}          % passend zu einleger.py --leiste
```

`\dsaSpalten` rechnet die Spaltenbreite und setzt den Satzspiegel neu. Wer eine der Randlängen
ändert, ruft es danach noch einmal auf — sonst bleibt die alte Geometrie stehen.

Lesbare Längen, die im Dokument gebraucht werden können:

| Länge | Wert |
|---|---|
| `\dsaSpaltenbreite` | Breite einer Spalte |
| `\dsaSpaltenabstand` | 12 bp |
| `\dsaKolumnenbreite{n}` | Breite von n Spalten samt der Abstände dazwischen |

---

## 5. Reihen und Kolumnen

Der Einleger hat kein durchlaufendes Spaltenmodell. Seine Seiten sind aus Blöcken gebaut, und ein
Block ist so breit wie eine, zwei, drei oder vier Spalten.

```latex
\begin{dsaReihe}
  \dsaKolumne{1}{ ...Inhalt Spalte 1... }
  \dsaKolumne{3}{ ...breiter Block über Spalte 2 bis 4... }
\end{dsaReihe}
```

Die Kolumnen einer Reihe stehen nebeneinander und oben bündig. **Verschachteln ist der Normalfall**
— so entsteht der Aufbau von Seite 4 des Originals, wo links eine Spalte über die volle Höhe läuft
und rechts eine breite Tabelle über drei schmalen steht:

```latex
\begin{dsaReihe}
  \dsaKolumne{1}{ ...eine Spalte, volle Höhe... }
  \dsaKolumne{3}{%
    ...breite Tabelle...
    \dsaLuft{2}
    \begin{dsaReihe}
      \dsaKolumne{1}{ ... }
      \dsaKolumne{1}{ ... }
      \dsaKolumne{1}{ ... }
    \end{dsaReihe}
  }
\end{dsaReihe}
```

`multicol` kann das nicht: es setzt Text über *alle* Spalten oder über eine, nie über drei von
vier, und den Wechsel nur vor oder nach dem Satz.

### Welche Aufteilungen es gibt

Alle. Jede Kolumne ist 1 bis 4 Spalten breit, mehrere Reihen stehen untereinander, und jede
Kolumne darf wieder eine Reihe enthalten. Der Regellauf zeigt jede dieser Formen einmal:

| Aufteilung | wo im Regellauf | im Original |
|---|---|---|
| 1 + 1 + 1 + 1 | Seite 2 | Seite 6, obere Hälfte |
| 1 + 3, im 3er drei verschachtelte 1er | Seite 3 | Seite 4 |
| 4 über die volle Breite | Seite 4, oben | — |
| 2 + 2 | Seite 4, Mitte | Seite 6, unten |
| Überschrift über alles, darunter 2 + 2 | Seite 4 | Seite 6, unten |
| 1 + 1 + 2 | Seite 4, unten | — |

Die Spaltenzahl selbst ist keine Konstante: `\dsaSpalten{5}` in der Präambel macht fünf daraus und
rechnet die Breite neu (Abschnitt 4). Sie gilt dann für das ganze Dokument — eine Seite mit fünf
und die nächste mit vier Spalten geht nicht, weil der Satzspiegel daran hängt.

### Was zu beachten ist

* **Die Summe der Kolumnenbreiten einer Reihe darf die Spaltenzahl nicht überschreiten.** Geprüft
  wird das nicht; TeX meldet es als `Overfull \hbox`.
* **Eine Kolumne wird nicht umbrochen.** Passt ihr Inhalt nicht auf die Seite, läuft er unten
  heraus, ohne Fehlermeldung. Mit `spaltenzeigen` bauen und nachsehen.
* **Passt eine ganze Reihe nicht auf die Seite, rutscht sie vollständig auf die nächste** und
  lässt die vorige leer. Das ist der übliche Befund, wenn plötzlich eine leere Seite auftaucht.
* Leerzeilen zwischen zwei `\dsaKolumne` sind erlaubt. Die Klasse schaltet `\par` innerhalb einer
  Reihe ab und holt es in jeder Kolumne zurück.

### Abstand

```latex
\dsaLuft{2}     % zwei Textzeilen = 21,6 bp
```

Gezählt wird in Textzeilen zu 10,8 bp, nicht in Rastereinheiten. Im Original stehen zwischen zwei
Tabellen einer Spalte zwei bis drei Zeilen — eine Setzerentscheidung, kein Maß.

---

## 6. Blocktitel und Quellenmarke

Über jedem Block steht sein Name, fett, ohne Einzug an der Spaltenkante, und rechts davon das graue
Schildchen mit dem Seitenverweis.

```latex
\dsaBlocktitel[RW 339]{Regeneration}
\dsaBlocktitel{Ohne Quellenangabe}
\dsaQuelle{RW 255/309}                 % das Schildchen allein
```

Die Marke ist am Original nachgemessen: Fläche `#9D9D9C`, 8,79 bp hoch, Ecken gerundet, Text weiß
in 7,0 bp, Grundlinie 1,85 bp über der Unterkante, 3,8 bp Innenluft links und rechts. Ihre Breite
ergibt sich aus dem Text — „RW 339“ misst 30,57 bp, „RW 255/309“ misst 43,09 bp.

Das Original setzt die Marke in Minion Pro. Die Schrift gehört nicht zum Baukasten und liegt hier
nicht vor; gesetzt wird Gentium Basic im selben Grad. Der Unterschied betrifft vier Zeichen je
Marke.

### Überschrift über mehrere Spalten

```latex
\dsaUeberschrift{Modifikationen bei Zaubersprüchen und Liturgien}
```

Gentium Basic in 12,72 bp, zentriert, **nicht fett**. Der Grad ist krumm, weil InDesign ihn im
Original skaliert hat; gesetzt wird er wie gemessen. Im Original kommt sie einmal vor, auf Seite 6
über der unteren Hälfte.

---

## 7. Tabellen

Das Arbeitspferd des Einlegers. Fast alles auf den drei Originalseiten ist eine Tabelle.

```latex
\begin{dsaEinlegertabelle}{Regeneration}{RW 339}{XL{22mm}}
  \dsaKopfzeile Situation & \dsaKopfschrift Regeneration \\
  \textbf{Grundregeneration für 6 Stunden Schlaf} & 1W6 LeP\slash AsP\slash KaP \\
  \textbf{Schlechter Lagerplatz}                  & \dsaMod{-}{1} LeP\slash AsP\slash KaP \\
\end{dsaEinlegertabelle}
```

| Argument | Bedeutung |
|---|---|
| `{Regeneration}` | Titel; **leer lassen** für eine Tabelle ohne Titelzeile |
| `{RW 339}` | Quellenmarke; **leer lassen** für keine |
| `{XL{22mm}}` | Spaltenformat |

**Alle drei sind Pflicht, auch wenn zwei leer bleiben dürfen** — `{}{}{Xl}` ist gültig. Ein
optionales Argument geht hier nicht: `\NewEnviron` aus `environ`, ohne das sich `tabularx` nicht
in eine Umgebung wickeln lässt, verarbeitet ein weggelassenes optionales Argument falsch. Die
übrigen rutschen dann um eins, die Spaltenvorschrift kommt leer an, und die Tabelle hat eine
Spalte statt drei. Siehe Abschnitt 11.

Die Tabelle ist immer so breit wie die Kolumne, in der sie steht. Die Linien laufen von Kante zu
Kante, wie im Original von Spaltenkante zu Spaltenkante.

### Spaltentypen

| Typ | Bedeutung |
|---|---|
| `X` | teilt sich die Restbreite, Flattersatz, bricht um |
| `L{22mm}` | feste Breite, Flattersatz, bricht um |
| `l` `r` `c` | einzeilig, links / rechts / zentriert |

`L{}` ist derselbe Spaltentyp wie in der Abenteuerklasse — er wird geteilt, nicht verdoppelt. Dort
trägt er eine Tiefenstütze von 0 pt und tut nichts; hier bekommt sie über `\dsazellstuetze` ihr
Maß von 3,36 bp. Ohne die Stütze richtet sich die Linie unter einer mehrzeiligen Zelle nach der
Unterlänge des letzten Wortes und wandert um bis zu 3,4 bp. `X` bekommt dasselbe über
`\tabularxcolumn`.

**Mindestens eine `X`-Spalte gehört in jede Tabelle**, sonst erreicht sie die Kolumnenbreite nicht
und die Linien enden dort, wo der längste Eintrag endet.

Blocksatz gibt es nicht. In einer Spalte von 30 mm zieht er die Wortabstände auf, und im Original
ist durchweg Flattersatz gesetzt.

### Kopf- und Zwischenzeilen

```latex
\dsaKopfzeile    Situation & \dsaKopfschrift Regeneration \\
\dsaKopfzeile[2] Modifikator-Maximum & \dsaKopfschrift Fertigkeitswert-Minimum \\
```

Das Band hinter der Kopfzeile ist ein Verlauf von Tabellenrot nach durchsichtig, mit einer Linie
in `#646363` darüber und darunter.

**Das optionale Argument ist die Zahl der Textzeilen, die die Kopfzeile hoch wird.** Die Klasse
kann sie nicht ausrechnen: das Band wird gezeichnet, wenn die Zeile beginnt, und wie hoch sie wird,
steht erst fest, wenn sie zu Ende gesetzt ist. Ohne das Argument hängt eine umbrechende Kopfzeile
mit ihrer zweiten Zeile unter dem Band.

`\dsaKopfschrift` (fett) muss in **jede** Zelle der Kopfzeile. Eine Schriftart reicht in LaTeX
nicht über die Zellengrenze; die Begründung steht in `dsa5latex.cls` bei `\dsaRubrikschrift`.

Eine Tabelle mit mehreren Abschnitten bekommt mittendrin dieselbe Fläche:

```latex
\dsaZwischenzeile Zeit\rlap{*} & \dsaKopfschrift Modifikator \\
```

Das Original hat sie auf Seite 6, wo „Ort*“, „Zeit*“ und „Sonstiges“ eine Tabelle in drei Teile
teilen.

### Anmerkung

```latex
\dsaAnmerkung{*Nur einer der Modifikatoren kann gelten}
```

Eine Zeile unter der letzten Tabellenlinie, ohne Einzug an der Spaltenkante.

### Das Zeilenmodell

Am Original nachgemessen, Tabelle „Regeneration“, Seite 6, Spalte 1:

| | y (bp) |
|---|---|
| Titelgrundlinie | 44,01 |
| Linie über dem Kopf, `#646363` | 48,05 |
| Kopfgrundlinie | 59,26 |
| Linie unter dem Kopf | 62,61 |
| erste Wertegrundlinie | 73,80 |
| Linie darunter, `#D0D0D0` | 87,93 |

Daraus:

| Größe | Wert |
|---|---|
| Zeilenhöhe, einzeilig | **14,56 bp** |
| je weitere Zeile | **10,8 bp** |
| Grundlinie unter der Zeilenoberkante | 11,20 bp |
| Grundlinie über der Zeilenunterkante | 3,36 bp |
| Zelleneinzug seitlich | 3,4016 bp = 1,2 mm |
| Linienstärke | 0,25 bp |

Die Probe über die ganze Spalte: die acht Zeilen messen 25,32 / 46,93 / 36,12 / 46,93 / 25,32 /
25,33 / 46,92 / 46,93 bp — zwei-, vier-, drei-, vier-, zwei-, zwei-, vier- und vierzeilige Zellen,
jede auf 14,56 + (n−1) × 10,8. Die größte Abweichung ist 0,04 bp.

Die 3,36 bp unten sind der Zelleneinzug des Baukastens, 1,2 mm. Der Einleger benutzt also dasselbe
Maß wie das Buch.

---

## 8. Der Pergamentkasten

Ein Block auf Pergament statt auf blankem Grund, mit dem gezackten Rand der Baukastengrafik. Der
offizielle Einleger hat zwei davon: „Einsatz von Schips“ auf Seite 4 und „Modifikationen im
Überblick“ auf Seite 6.

```latex
\begin{dsaPergament}{1}{9}                    % 1 Spalte breit, 9 Textzeilen hoch
  \dsaBlocktitel[RW 29]{Einsatz von Schips}
  \begin{dsaliste}
    \item \textbf{Erster:} Der Held kann in einer Kampfrunde zuerst handeln.
  \end{dsaliste}
\end{dsaPergament}
```

| Argument | Bedeutung |
|---|---|
| `{1}` | Breite in Spalten — 1 bis 4, wie bei `\dsaKolumne` |
| `{9}` | Höhe in Textzeilen zu 10,8 bp |

**Innen gilt der normale Einlegersatz**: derselbe Schriftgrad, derselbe `\dsaBlocktitel` mit
Quellenmarke, dieselben Aufzählungen. Das ist der Unterschied zum Kasten im Buch, der ein eigener
Satzraum mit 9,5 bp auf 11,4 bp ist — hier ist es ein Stück Einleger auf anderem Grund. Am
Original nachgemessen ist die Kastenschrift 9,0 bp, wie der Fließtext.

Der Kasten hängt links um `\dsapergamentueberhang` aus der Spalte heraus, Vorgabe 3,4 bp = 1,2 mm.
Das ist der Wert von Seite 4; der Kasten auf Seite 6 steht dagegen 2,4 bp *innerhalb* seiner
Spalten. Der Setzer hat frei platziert, ein Sollmaß gibt es nicht. Vier Längen stellen ihn ein:

```latex
\setlength{\dsapergamentueberhang}{0pt}   % bündig statt überhängend
\setlength{\dsapergamentinnen}{3.8mm}     % seitlicher Innenabstand
\setlength{\dsapergamentoben}{4mm}
\setlength{\dsapergamentunten}{3.8mm}
```

Nachgemessen liegt die Titelgrundlinie damit **18,07 bp** unter der Kastenoberkante gegen 17,75 im
Original, und die Textkante steht 10,57 bp vom Rand — zwischen den 11,89 und 10,01 bp der beiden
Originalkästen.

Die Fläche ist `pergament-lang`, über `\dsaBildDeckend` **beschnitten statt gestaucht**. Die
fertigen Kästen der Abenteuerklasse (`dsaPergamentKlein` und die anderen) taugen hier nicht: sie
sind 85,5 mm breit und rechnen ihre Höhe in Rastereinheiten.

---

## 9. Die Stimmungsbildseite

Eine Seite, auf der nur ein Bild steht, randfüllend. Die ersten drei Seiten des offiziellen
Einlegers sind so gebaut.

```latex
\dsaStimmungsbild{\dsagrafik{szene}}     % Bild, Leisten oben und unten
\dsaStimmungsbild*{\dsagrafik{szene}}    % Bild ohne Leisten, sie stecken drin
```

**Der Rahmen liegt oben und unten, nicht rundum** — wie auf den Tabellenseiten. Das ist am Original
nachgemessen: an beiden senkrechten Rändern der Seiten 1 bis 3 steht Bildinhalt bis zur
Papierkante, keine Leiste. Wer den umlaufenden Rahmen doch will:

```latex
\dsaRahmenRundum        % ab hier auch die seitlichen Leisten
\dsaRahmenWaagerecht    % zurück zur Vorgabe
```

Beides gilt ab dem Aufruf für jede folgende Seite, Tabellenseiten eingeschlossen — der Rahmen ist
eine Eigenschaft des Blattes, nicht eines einzelnen Elements.

Das Bild wird **deckend zugeschnitten, nicht gestreckt**: `\dsaBildDeckend` aus der
Abenteuerklasse skaliert an der Kante, an der es zu klein ist, und beschneidet die andere mittig.
Zugeschnitten wird auf 303 × 216 mm, also A4 quer plus 3 mm Anschnitt an allen vier Seiten —
dieselbe Fläche wie beim Pergamenthintergrund. **Ideal ist ein Bild im Verhältnis 303 : 216 =
1,40**; bei jedem anderen geht an einer Kante etwas verloren.

Die Seite bringt ihre eigene Kulisse mit und schaltet die des Dokuments für die Dauer der Seite
ab — sonst läge das Pergament unter dem Bild, wäre 8 MB groß und nirgends zu sehen. Danach gilt
wieder, was der Autor eingestellt hat, auch die Klassenoption `ohnehintergrund`.

Im Original steckt der Rahmen in der Grafik, hier legt ihn die Klasse darüber. So bleibt die
Grafik eine gewöhnliche Illustration; wer ein Bild hat, in dem er schon steckt, nimmt die
Sternform.

**Der Baukasten hat keine Illustration im Querformat.** Der Regellauf nimmt ein eigenes Bild aus
`grafiken/`, wenn eins da ist, und sonst eine zugeschnittene Buchrückseite — über `\IfFileExists`,
damit er auch bei jemandem baut, der nur die Baukastengrafiken hat.

---

## 10. Was von der Abenteuerklasse kommt

Unverändert nutzbar, dokumentiert in [ELEMENTE.md](ELEMENTE.md):

| Bereich | Befehle |
|---|---|
| Zahlen und Marken | `\dsaMod`, `\dsaMinus`, `\dsaMal`, `\dsaFormel`, `\dsaKapitaelchen` |
| Aufzählungen | `dsaliste`, `dsalisteblau`, `dsalisterot`, `dsaWerteabsatz` |
| Kästen | alle fünfzehn, siehe `beispiel/kaesten.tex` |
| Farben | `dsatabellenrot`, `dsatabellenlinie`, `dsapergamentgelb`, … |
| Grafikpfad | `\dsagrafik{name}` |
| Bildzuschnitt | `\dsaBildDeckend`, `\dsaBildKreis`, `\dsaBildForm`, `\dsaBildMaskiert` |
| Spaltentyp | `L{<breite>}` |

Auch unter der Oberfläche wird geteilt statt verdoppelt. Vier Bausteine stehen in `dsa5latex.cls`
und werden vom Einleger nur anders eingestellt:

| Baustein | wie der Einleger ihn ändert |
|---|---|
| `\dsa@tabellenband` — Rechteck, Füllung, zwei Linien | über `\dsa@bandmasse`: 14,56 bp statt einer Rastereinheit, mehrzeilig möglich |
| `\dsa@tabellenlinienan` — die Linie unter jeder Zeile | unverändert übernommen |
| `L{}` — Absatzspalte mit Flattersatz | über `\dsazellstuetze`: 3,36 bp statt 0 pt |
| `\dsaBildDeckend` — deckender Zuschnitt | unverändert, für die Stimmungsbildseite |

`\dsa@bandmasse` und `\dsazellstuetze` sind in `dsa5latex.cls` eigens dafür angelegt worden. Im
Abenteuersatz sind sie wirkungslos: die Bandmaße rechnen dort wie zuvor, und die Zellstütze ist
0 pt, also eine Box ohne Höhe, Tiefe und Breite. Am Ergebnis nachgemessen liegt nach dem Umbau in
`raster.pdf`, `kaesten.pdf` und `rest.pdf` jede Textzeile auf **±0,0000 bp** ihrer alten Stelle.

**Zwei Namen sind belegt und heißen im Einleger anders.** `\dsaFeld` ist in der Abenteuerklasse
ein Textbefehl der Kurzcharakteristik („Genre: …“); die Kolumne heißt deshalb `\dsaKolumne`.

**Kästen im Querformat sind ungeprüft.** Die Pergamentflächen sind für A4 hoch angelegt und für
das Grundlinienraster gebaut, das es hier nicht gibt. Sie funktionieren, sitzen aber nicht
nachgemessen. Wer sie braucht, prüft nach und trägt das Ergebnis in `PRUEFPLAN.md` ein.

---

## 11. Fallstricke

Alle vier sind beim Bauen dieser Klasse aufgetreten und am gesetzten PDF nachgemessen worden.

**Zahl mal Makro mal Einheit gibt keine Länge.** `\dimexpr2\dsagrunddurchschuss bp` ergibt nicht
21,6 bp, sondern 210,8 bp: TeX liest die `2` und die `10.8` zu einer Zahl zusammen. Zwischen zwei
Tabellen standen dadurch 74,4 statt 7,6 mm. Richtig ist
`\dimexpr#1\dimexpr\dsagrunddurchschuss bp\relax\relax`.

**`\extrarowheight` wird mit `\arraystretch` multipliziert, nicht danach addiert.** array rechnet
`Höhe = \arraystretch × (0,7 × Durchschuss + \extrarowheight)`. Wer die Zugabe nach der
Multiplikation rechnet, bekommt den gestreckten Anteil doppelt: gemessen 14,684 statt 14,560 bp je
Zeile, nach acht Zeilen ein Millimeter.

**`\paperwidth` steht in der Klasse noch nicht.** geometry setzt es erst, wenn es seine Schlüssel
abgearbeitet hat. Die Spaltenbreite wurde deshalb mit den 210 mm von A4 hoch gerechnet und kam auf
43,8 statt 65,6 mm. Die Klasse führt dafür `\dsaeinlegerbreite` und `\dsaeinlegerhoehe`.

**`tabularx` lässt sich nicht in eine `\newenvironment` wickeln.** Es liest seinen Rumpf als
begrenztes Argument bis zum passenden `\end`, und das steht in einer gewickelten Umgebung nicht im
Eingabestrom. Der Lauf endet mit `Runaway argument? ... File ended while scanning use of
\TX@get@body`. Die Klasse nimmt `\NewEnviron` aus `environ`.

**`\NewEnviron` verträgt kein optionales Argument.** Wird es weggelassen, rutschen die übrigen um
eins: aus `\begin{dsaEinlegertabelle}{}{Xl}` wird eine Tabelle mit leerer Spaltenvorschrift, also
einer Spalte statt zwei. Der Lauf meldet je Zeile und je Durchlauf
`Extra alignment tab has been changed to \cr` — bei einer dreizeiligen Tabelle sechsmal, weil
tabularx zweimal setzt. Solange jede Tabelle eine Marke trägt, fällt das nie auf; die erste ohne
bricht. Deshalb hat `dsaEinlegertabelle` drei Pflichtargumente, von denen zwei leer sein dürfen.

**`\verb` geht nicht im Inhalt einer `\dsaKolumne`.** Der Inhalt ist ein Makroargument, und `\verb`
liest seinen Text zeichenweise aus dem Eingabestrom: `\verb illegal in argument`. Im Einleger
`\texttt` mit `\textbackslash` nehmen.

**`\dsaKolumnenbreite{n}` ist ein `\dimexpr`, keine Länge.** Als Argument von `minipage` oder
`\parbox` meldet der Lauf `You can't use \dimexpr in horizontal mode`. Erst in eine eigene Länge
setzen, dann einsetzen.

---

## 12. Prüfen

```sh
python3 werkzeuge/einleger.py --pruefen         # Quellgrafiken und Kantenbreite
python3 werkzeuge/nachmessen.py beispiel/einleger.pdf --seite 1 --text
```

Für den Einleger sind drei Prüfungen die entscheidenden:

1. **Die Spaltenkanten.** Jede waagerechte Tabellenlinie muss auf einer der acht Sollkanten
   beginnen und enden: 31,18 / 217,06 / 229,06 / 414,95 / 426,94 / 612,83 / 624,83 / 810,71 bp.
   Gemessen am Regellauf ist die größte Abweichung über 322 Kanten 0,20 bp, die meisten liegen
   unter 0,005 bp.
2. **Die Zeilenhöhe.** Jede einzeilige Tabellenzeile misst 14,56 bp, jedes Kopfband ebenso, ein
   zweizeiliges 25,36 bp.
3. **Der Blick mit `spaltenzeigen`.** Sitzt jeder Block auf seinen Spalten, läuft keine Kolumne
   unten heraus.

Der Regellauf `beispiel/einleger.tex` baut vier Seiten: eine Stimmungsbildseite und die drei
Tabellenseiten, an denen die Klasse vermessen wurde. Er zeigt jedes Element genau einmal und ist
zum Abschreiben gedacht.

Was geprüft wurde und was dabei herauskam, steht in [PRUEFPLAN.md](PRUEFPLAN.md).
