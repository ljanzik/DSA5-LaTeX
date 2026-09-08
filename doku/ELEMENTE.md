# Elementreferenz

*Alle Befehle und Umgebungen der Klasse. Die Maße dahinter stehen in [MASSE.md](MASSE.md).*

Vollständiges Beispiel: `beispiel/beispiel.tex`.

---

## Klassenoptionen

```latex
\documentclass[raster]{dsa5latex}              % Grundlinienraster ein, Standard
\documentclass[ohneraster]{dsa5latex}          % Raster aus
\documentclass[raster,rasterzeigen]{dsa5latex} % Grundlinien mitdrucken
\documentclass[raster,entwurf]{dsa5latex}      % Bilder als Rahmen, schnelles Bauen
```

**Nach jeder Änderung an Kästen, Bildern oder Überschriftenabständen einmal mit `rasterzeigen`
bauen** und nachsehen, ob die Zeilen beider Spalten auf einer Höhe sitzen. Das ist die einzige
Prüfung, die das Raster wirklich prüft.

## Raster

| Aufruf | Wirkung |
|---|---|
| `\dsaRaster{n}` | die Länge n × 12 pt |
| `\dsaRasterluft{n}` | senkrechter Abstand von n × 12 pt |

`\vspace{5mm}` ist im Rastersatz falsch. Jeder senkrechte Abstand ist ein Vielfaches von 12 pt.

Zwei Längen steuern alle Kästen zugleich:

```latex
\setlength{\dsakasteninnen}{8mm}   % seitlicher Innenabstand
\setlength{\dsakastenoben}{6mm}    % oben und unten
```

---

## Seitentypen

Neun Typen. Die aus dem Baukasten abgeleiteten fünf Musterseiten und die 13 Beispielseiten ergeben
diese Aufteilung.

| Typ | Aufruf | Spalten | Seitenzahl | Hintergrund |
|---|---|---|---|---|
| Umschlag vorne | `\dsaUmschlagVorne{Bild}{\dsaTitelZeile{…}…}` | — | nein | nein |
| Umschlag hinten | `\dsaUmschlagHinten{Karte}{Titel}{Inhalt}` | 1 | nein | nein |
| Feld auf der Rückseite | `\dsaRueckenfeld{Inhalt}` | — | nein | nein |
| Impressum | `\begin{dsaImpressumseite}` | 1 | nein | ja |
| Inhaltsverzeichnis | `\dsaInhalt` | 1 | nein | ja |
| Kapitelanfang ohne Rahmen | `\dsakapitel{Titel}` | 2 | ja | ja |
| Kapitelanfang mit Rahmen | `\dsakapitelbild[Bild]{Titel}` | 2 | ja | ja |
| Rückseite | `\dsaRueckseite{Grafik}{Titel}{Autor}{Text}{Kasten}` | — | nein | nein |
| Normalseite | — (Regelfall) | 2 | ja | ja |
| Seite ohne Seitenzahl | `\begin{dsaSeiteOhneZahl}` | 2 | nein | ja |
| Ganzseitige Grafik | `\dsaGanzseite{Bild}` | — | nein | nein |
| Querformat | `\dsaQuerAnfang` … `\dsaQuerEnde` | 1 | nein | nein |

### Der Titel auf dem Umschlag

Die Zeilen kommen einzeln, jede darf ihren eigenen Schriftgrad haben:

```latex
\dsaUmschlagVorne{grafiken/titelbild}{%
  \dsaTitelZeile{Der falsche}%
  \dsaTitelZeile{Ganter}%
  \dsaTitelZeile[27.9]{Akt 1 der Fuchsgrund-Reihe}}
```

Gesetzt wird von unten: die Grundlinie der **letzten** Zeile sitzt auf `\dsatitelunten`, jede
weitere Zeile schiebt nach oben. Ein dreizeiliger Titel wächst also in das Bild hinein und nicht in
den unteren Rahmen.

Der Aufbau hat drei Lagen, von hinten nach vorn: die graue Fläche in der Form des Schriftzugs, der
helle Rand um die Schrift, der Verlauf in der Schrift. Das PSD führt zusätzlich zwei Schlagschatten,
einen für die Fläche und einen für die Schrift; beide sind dort weichgezeichnet und teildeckend.
Hart nachgebildet lasen sie sich als zweiter, versetzter Schriftzug und überdeckten den hellen Rand
— sie sind deshalb nicht enthalten.

Alles einstellbar, in der Präambel:

| Befehl | Voreinstellung | Wirkung |
|---|---|---|
| `\dsaTitelGrad{42.8}` | 42,8 pt | Schriftgrad aller Zeilen |
| `\dsaTitelRand{13}` | 13 pt | Breite der grauen Fläche um die Schrift |
| `\dsaTitelKontur{0.24}` | 0,24 pt | Breite des hellen Rands (1 px bei 300 ppi; das PSD gibt 0,72) |
| `\dsaTitelZeilenfaktor{1.0}` | 1,0 | Zeilenabstand als Vielfaches des Grads; ab etwa 1,25 stehen die Flächen getrennt |
| `\dsaTitelUnten{31.3mm}` | 31,3 mm | Grundlinie der letzten Zeile über der Papierkante |
| `\dsaTitelTiefer{6.4pt}` | 6,4 pt | Versatz der Fläche nach unten, Ausgleich für Oberlängen |
| `\dsaTitelVerlaufAus` | — | schlicht weiß mit Kontur |
| `\dsaTitelFlaecheAus` | — | ohne graue Fläche |
| `\dsaTitelRahmenAus` | — | ohne hellen Rand |

Zwei Werte in der Klasse steuern, wie glatt der Rand der Fläche wird: `\dsatitelperlabstand`
(0,6 pt) und `\dsatitelflaechenstufen` (5). Warum, steht in `MASSE.md`.

### Bilder auf dem Raster

Jedes Bild im Textfluss muss eine ganze Zahl Rastereinheiten belegen, sonst sitzt alles darunter
daneben. Dafür gibt es einen Befehl, der beliebigen Inhalt so setzt:

```latex
\dsaBildRaster{7}{\dsaBildKreis{25mm}{grafiken/portrait}}
\dsaBildRaster{6}{\dsaBildForm{30mm}{20mm}{(0,0) (1,0.6) (1.6,-0.3)}{grafiken/karte}}
```

`\dsaBildSpalte{Bild}{Einheiten}` und `\dsaBildBreit` benutzen ihn schon selbst, ebenso
`\dsaVorlesetext[Einheiten]{Text}` — dort sind vier Einheiten für eine Spalte richtig und acht für
einspaltigen Satz.

Warum keine `\parbox` mit fester Höhe: ihre Grundlinie liegt bei `[t]` an der Oberkante und bei
`[c]` in der Mitte, und beides verschiebt alles darunter. `\dsaBildRaster` gibt dem Inhalt Höhe und
Tiefe null, verschiebt ihn nach unten und lässt den Raum von `\dsaRasterluft` kommen.

Nicht gebaut: der **Buchrücken**. Die Grafik dafür (`Cover_Buchtitel`, 184,3 mm breit — genau der
Grafikbereich) liegt im Baukasten, das Element fehlt.

**Der Seitenhintergrund** rotiert über **drei** der vier Doppelseiten des Baukastens, je zwei
Seiten eine Variante. Die vierte hat in der unteren Außenecke kein Feld für die Seitenzahl und ist
deshalb den Seiten vorbehalten, die keine tragen: `\dsaHintergrundOhneFeld` wählt sie für die
laufende Seite und macht die Fußzeile leer. Impressum und Inhaltsverzeichnis rufen das selbst auf.
`\dsaHintergrundAus` und `\dsaHintergrundAn` schalten den Hintergrund für einzelne Seiten ab und
wieder ein.

**Kapitelanfang.** Banner 210,1 × 43,2 mm am oberen Papierrand, Titel als Versalien darin, dann
beide Spalten darunter. Mit Kapitelbild wird die Außenhälfte belegt; dann muss die Anfangsseite mit
`\dsaKapitelseiteEnde` beendet werden, sonst läuft der Text hinter das Bild — eine Grenze von
LaTeX, nicht der Klasse.

Das Kapitelbild ist nach der Bauweise des Verlags gesetzt: Pergamentfläche, darauf das Bild
eingerückt, sodass der Pergamentrand als Rahmen stehen bleibt, darüber das Drachenornament. Keine
Maske. Die Randbreite ist `\dsakapitelbildrand`, der Bannerversatz von der Papierkante
`\dsabannerversatz`.

### Zwei Arten von Kapitelseiten

```latex
\dsakapitel{Titel}                  % ohne Rahmen, Text über beide Spalten
\dsakapitelbild{Titel}              % mit Rahmen, ohne Bild: Platzhalter
\dsakapitelbild[bilder/hof]{Titel}  % mit Rahmen und Bild
```

Der Rahmen belegt die Außenhälfte der Seite. Der Text muss deshalb in die innere Spalte passen und
die Seite mit `\dsaKapitelseiteEnde` beendet werden, sonst läuft er dahinter — eine Grenze von
LaTeX, nicht der Klasse.

Gezeichnet wird in dieser Reihenfolge: Seitenhintergrund, Rahmen, Banner, Text. Beides steht in
**einem** TikZ-Bild; zwei Bilder mit `remember picture` im selben `\twocolumn`-Vorspann setzen die
Positionen von `current page` durcheinander. Die Grafiken lassen die Fußzeile von selbst frei — das
Pergament deckt bis 280,8 mm der 300 mm, das Ornament sitzt zwischen 236,1 und 286,7 mm.
`\dsakapitelrahmenversatz` (13,4 mm) schiebt die Fläche an den Anschnitt, weil sie in der Datei
nicht bis zum Rand deckt.

### Die Rückseite

```latex
\dsaRueckseite{ruecken-mittelreich}{Der falsche Ganter}{von Leif Janzik}{%
  Klappentext, Absätze durch Leerzeilen getrennt.
}{%
  \dsaRueckKopf{Ein DSA-Gruppenabenteuer\\für 3 bis 5 Helden}
  \dsaRueckFeld{Genre}{Ermittlung}
  \dsaRueckStrich
  \dsaAnforderungen{1}{4}{2}{1}
}
```

Die Grafik kommt aus dem **Rückseiten-Karten-Paket** von Ulisses, einem zweiten Paket neben dem
Baukasten. Es bringt eine fertige Rückseite mit Zierrahmen (`ruecken-neutral`) und 28 Fassungen, in
denen je eine Region Aventuriens hervorgehoben ist (`ruecken-mittelreich` und so weiter).
`werkzeuge/aufbereiten.py --rueckseiten <pfad>` holt sie.

Der Aufbau ist an der Rückseite einer gesetzten Veröffentlichung vermessen: Titel in Andalus 18 bp,
Autorzeile 12 bp, ein Strich darunter, der Klappentext 81,7 mm breit im Blocksatz, und der graue
Kasten unten rechts mit Kopfzeile, Rubriken und Fertigkeiten. Die Maße stehen in `MASSE.md`.

### Die Probenzeile

```latex
\dsaProbe{Sinnesschärfe (Suchen), erschwert um 2}
\dsaProbe[dsatabellenrot]{Odem Arcanum}
```

Ein Balken über die Spaltenbreite, 6,985 mm hoch, darin der Name der Probe in Gentium Basic fett
auf 11 bp. Beides ist an einer gesetzten Veröffentlichung gemessen. Die Farbe wechselt dort je
Probenart und steht im PDF nur als Pantone-Name, nicht als Wert — deshalb ist sie hier ein
optionales Argument, voreingestellt auf das Pergamentgelb des Baukastens.

Die 6,985 mm sind kein Vielfaches des Rasters. Der Balken behält sein Maß und wird in eine Box ohne
Höhe gesetzt, die zwei Rastereinheiten belegt; sein Text sitzt damit auf einer Grundlinie und der
Text darunter auch.

### Fußzeile: Seitenzahl und Kolumnentitel

Beides sitzt auf einer Grundlinie 5,9 mm über der unteren Papierkante, gesetzt als TikZ-Knoten an
der Papierkante — nicht über die Spalten von `fancyhdr`, die im Satzspiegel sitzen und nichts vom
Anschnitt wissen.

| Element | Schrift | Lage |
|---|---|---|
| Seitenzahl | Andalus 13 bp, weiß mit Kontur | Mitte 18,4 mm von der Außenkante |
| Kolumnentitel | Andalus 14 bp, schwarz | bündig am Satzspiegel, also 24 mm von der Außenkante |

Der Kolumnentitel ist `Abenteuertitel – Kapitelname`. Den Titel setzt die Präambel, der Kapitelname
kommt über die Marken von LaTeX aus `\dsakapitel`:

```latex
\dsaAbenteuertitel{Der falsche Ganter}
```

Ohne diesen Befehl bleibt der Kapitelname allein stehen, vor dem ersten Kapitel bleibt die Zeile
leer.

Er schließt mit dem Satzspiegel ab, auf beiden Seiten 24 mm von der Außenkante — rechts
rechtsbündig bei 186 mm, links linksbündig bei 24 mm. Damit steht er bündig unter dem Textblock,
und der Abstand zur Zahl ist auf beiden Seiten gleich. Im Vorbild ist die Lage **nicht**
spiegelbildlich (rechts 24,29 mm, links 40,35 mm, beides stabil über mehrere Seiten), aber dessen
Satzspiegel ist ein anderer, und am Abzug sieht die Asymmetrie schief aus. Wer sie haben will,
setzt `\dsakolumneaussenlinks` auf 40,35 mm.

---

## Gliederung

| Aufruf | Schrift |
|---|---|
| `\dsakapitel[Bild]{Titel}` | Andalus 23,5 pt, Versalien |
| `\dsaunterkapitel{Titel}` | Andalus 14 pt, zentriert, 12 pt danach |
| `\dsaabschnitt{Titel}` | Gentium Basic fett 13 pt |
| `\dsaunterabschnitt{Titel}` | Gentium Basic fett 10 pt |
| `\dsaAbschnittGelb{Titel}` | wie Abschnitt, auf Pergamentverlauf, Fläche zwei Rastereinheiten |

---

## Fließtext

| Aufruf | Wirkung |
|---|---|
| `\dsaEinfuehrung{Text}` | kursiv, Laufweite +10 |
| `\dsaStimmung{Text}{Quelle}` | Pfeile aufrecht, Text kursiv, Quelle mit Bindestrich, ohne Punkt |
| `\dsaZitat{Text}` | `#404040`, kursiv, zentriert |
| `\dsaVorlesetext[Einheiten]{Text}` | Zierleisten darüber **und** darunter, 15,39 mm breiter als die Spalte |
| `\dsaKastentitel{Titel}` | Überschrift im Kasten, 12 bp fett |
| `\begin{dsaWerteabsatz}` | hängender Einzug 8,504 pt |
| `\dsaBand{ABE}{8}` | hochgestelltes Bandkürzel |
| `\dsaKapitaelchen{Text}` | nachgebildete Kapitälchen, 82 % Versalien |
| `\dsaFormel{1W6+4}` | Zahlenangabe im Textfont — **statt `$…$`** |
| `\dsaMod{-}{2}` | Modifikator mit echtem Minuszeichen: −2 |
| `\dsaMinus`, `\dsaMal` | echtes Minus- und Malzeichen |

**Kein `$…$`.** Die Klasse lädt kein Mathematik-Schriftpaket — ein Abenteuerheft braucht keinen
Formelsatz, und ein Times-Mathefont neben Gentium fällt bei jeder Ziffer auf.

## Aufzählungen

`dsaliste` (schwarze Raute), `dsalisteblau`, `dsalisterot`. Alle mit `topsep`, `itemsep` und
`parsep` auf null, damit sie das Raster nicht verschieben.

---

## Kästen

Die Spalte ist 80,5 mm, die Kästen sind breiter — sie ragen bewusst darüber hinaus, weil der
Zierrand außerhalb des Textbereichs liegt.

| Umgebung | mm | in einer Spalte |
|---|---|---|
| `dsaPergamentKlein` | 85,5 × 50,7 | ja, +2,5 mm je Seite |
| `dsaPergamentMittel` | 85,5 × 99,5 | ja |
| `dsaPergamentLang` | 85,5 × 192,4 | ja |
| `dsaPergamentBreit` | 136,9 × 192,4 | **nein**, einspaltig |
| `dsaPergamentSchmal` | 48,9 × 192,4 | ja, als Randspalte |
| `dsaWerteKlein` | 84,4 × 54,8 | ja |
| `dsaWerteMittel` | 86,9 × 103,8 | ja |
| `dsaWerteGross` | 85,0 × 197,1 | ja |
| `dsaWerteKleinPortrait` | 94,0 × 59,2 | ja, Medaillon tritt heraus |
| `dsaWerteMittelPortrait` | 94,0 × 104,0 | ja |
| `dsaWerteGrossPortrait` | 94,0 × 199,1 | ja |
| `dsaMeisterSchmal` | **59,9 × 114,2** hochkant | ja |
| `dsaMeisterBreit` | 177,9 × 114,2 | **nein**, einspaltig |
| `dsaMeisterMaske` | 84,0 × 108,0 | ja, der Regelfall |
| `dsaMeisterMaskeKlein` | 84,0 × 45,0 | ja |

Text in den grauen Kästen ist weiß.

**Das Porträtbild ist ein Schlüssel, kein Befehl im Inhalt** — der TikZ-Knoten `frame` existiert nur
im `underlay`:

```latex
\begin{dsaWerteMittelPortrait}[dsaportrait=bilder/dorle]
\textbf{Dorle Griesgram}
\begin{dsaWerteblock}
\dsaFeld{MU}{11} \dsaFeld{KL}{13}
\end{dsaWerteblock}
\end{dsaWerteMittelPortrait}
```

Alle drei Porträtvarianten sind 94,0 mm breit; das Medaillon tritt 13,5 mm zur Außenseite heraus.
**Vorläufig nur die rechte Lage** — der Baukasten liefert die Grafik nur in einer Richtung, also
Porträtkästen auf rechte Seiten setzen.

Die Lage des Medaillons ist **nicht** einstellbar geschätzt, sondern gemessen: die drei
Kastengrafiken enthalten das Medaillon bereits, und der Ring der Klasse muss deckungsgleich darauf
liegen. Weil die Dateien unterschiedlich beschnitten sind, setzt jeder Kasten seine eigene Lage
über `dsaportraitlagen`:

| Kasten | Kranzmitte von rechts | unter der Oberkante |
|---|---|---|
| `dsaWerteKleinPortrait` | 17,06 mm | 17,97 mm |
| `dsaWerteMittelPortrait` | 17,91 mm | 16,87 mm |
| `dsaWerteGrossPortrait` | 17,57 mm | 16,62 mm |

Der sichtbare Kranzradius ist überall 15,62 mm. Nachgemessen an `beispiel/kaesten.pdf` liegt der
Ring in allen drei Kästen mit 0,15 mm auf dem eingebauten Medaillon.

Der Text weicht dem Medaillon aus, und zwar dem **Kranz** des Ornaments, nicht dem Bild darin: der
Kranz reicht 33,2 mm nach innen, also hält `\dsaportraitfrei` 34 mm frei. Damit bleiben 53 mm
Textbreite — für den ganzen Kasten zu schmal, denn das Medaillon sitzt nur oben. Ein Befehl am
Anfang des Inhalts gibt die Breite darunter zurück:

```latex
\begin{dsaWerteMittelPortrait}[dsaportrait=bilder/dorle]
\dsaPortraitfluss
Die ersten acht Zeilen bleiben schmal, ab der neunten läuft der Satz auf die volle Kastenbreite.
\end{dsaWerteMittelPortrait}
```

Gemessen: Zeile 1 bis 8 enden bei 74,9 mm, Zeile 9 und die folgenden bei 101,5 mm; der Kranz
beginnt bei 76,6 mm und endet 58,9 mm unter der Papierkante; die erste breite Zeile liegt bei
64,7 mm, also 5,8 mm darunter.

Acht Zeilen, und zwar so gerechnet: der Kranz reicht 34,9 mm unter die Kastenoberkante, der Text
beginnt 6 mm darunter, eine Zeile ist 11,4 bp = 4,02 mm hoch. Unter dem Kranz liegen muss nicht die
Grundlinie der ersten breiten Zeile, sondern ihre Oberkante — die Grundlinie also eine Versalhöhe
von 2,4 mm tiefer, unter 37,3 mm. Das sind acht schmale Zeilen; die neunte beginnt bei 38,2 mm. Mit
sieben lief die erste breite Zeile noch in den Kranz, und das sieht man nur, wenn man neben dem
rechten Zeilenende auch die Höhe misst. `\parshape` verlangt seine Zeilen
ausgeschrieben — wer die Zahl ändert, ändert die Liste in der Klasse und die `9` davor. Der Befehl
gilt für den Absatz, der folgt; bei mehreren Absätzen also nur für den ersten. Ohne ihn bleibt der
Satz durchgehend schmal: sicher, nur enger.

### Freie Höhe

```latex
\begin{dsaKastenFrei}{18}
Achtzehn Rastereinheiten hoch, also 216 pt oder 76,2 mm.
\end{dsaKastenFrei}
```

Der Weg des Verlags — der Baukasten sagt es selbst: *„Die Wertekästen in unseren Büchern sind
normalerweise eine Kombination aus verschiedenen Elementen: Pergamentkästen von Seite 2/3, sowie
die Zierleisten und ggf. den Portrait-Rahmen von Seite 10."* Und zum Abstand: *„Feste Abstände für
Objekte haben wir nicht."* Die fertigen Kästen sind Bequemlichkeit, nicht das Verfahren.

---

## Meistermaske und Marken

Der Baukasten liefert die Meistermaske **mit** gestrichelter Verbindung als fertige Grafik, in drei
Höhen: `\dsaMeistermaske[1|2|3]{Text}`. Im Text markiert `\dsaAugeSchwarz` die Stelle, von der die
Verbindung ausgeht, `\dsaAugeWeiss` die im Kasten.

| Aufruf | Maß |
|---|---|
| `\dsaAugeSchwarz`, `\dsaAugeWeiss` | 3 mm |
| `\dsaFiole{l}` / `{r}` | 9,1 mm — leichter machen |
| `\dsaSchaedel{l}` / `{r}` | 9,1 mm — schwerer machen |
| `\dsaFokusregel{Kürzel}` | 9,9 mm |
| `\dsaBauer` `\dsaSpringer` `\dsaTurm` `\dsaKoenig` | 4 mm hoch |
| `\dsaRautenRot{1..4}{Breite}` | in TikZ gezeichnet |
| `\dsaRautenGruen{1..4}{Breite}` | dito |
| `\dsaNSCkopf` | Kopfleiste über einem NSC-Kasten |

Die Rautenskalen sind **nicht** aus dem Baukasten — dort gibt es sie nicht als Grafik. Vier Karos in
aufsteigender Zahl zeichnet TikZ selbst.

---

## Bilder und Masken

| Aufruf | Wirkung |
|---|---|
| `\dsaBildDeckend{Breite}{Höhe}{Bild}` | skaliert bis zur Deckung und beschneidet, **statt zu strecken** |
| `\dsaBildKreis{Durchmesser}{Bild}` | kreisrund beschnitten |
| `\dsaBildForm{Breite}{Höhe}{Punkte}{Bild}` | freihändige Form, Punkte als TikZ-Koordinaten |
| `\dsaBildMaskiert{Maske}{Breite}{Höhe}{Bild}` | echte Softmaske aus einer Graustufengrafik |
| `\dsaBildSpalte{Bild}{Raster}` | volle Spaltenbreite |
| `\dsaBildBreit{Bild}{Raster}` | Band über beide Spalten |

Drei Wege zu maskieren, für drei Zwecke: **geometrisch beschneiden** (Kreis, Freiform — echter
Beschnittpfad im PDF, verlustfrei), **eine deckende Grafik mit transparentem Fenster darüberlegen**
(so arbeitet der Verlag; kann nur verdecken, funktioniert also nur, wenn die Überlagerung den
Hintergrund mitbringt), und **eine echte Softmaske** über `\pgfdeclarefading` (der einzige Weg, wenn
wirklich etwas durchscheinen soll). Was LaTeX **nicht** kann: zwei getrennte Dateien zu einem
Alphakanal verrechnen — liegt die Transparenz im PNG, reicht sie durch.

## Textumfluss

**LaTeX kann nicht über die Spaltengrenze umbrechen.** Im zweispaltigen Satz wird erst die linke
Spalte fertig, dann die rechte; wenn die linke gesetzt wird, ist noch nicht bekannt, wo in der
rechten dieselbe Bildhöhe liegt. InDesign kann es, weil dort beide Spalten gleichzeitig im Blick
sind.

| Aufruf | verlässlich |
|---|---|
| `\dsaBildUmflossen{l\|r}{Bild}{Breite}` | Umfluss in einer Spalte, meistens |
| `\dsaBildBund{Bild}{Breite}{oben}` | Bild über dem Bundsteg, ohne Platzbedarf |
| `\dsaUmfluss{Spalte}{Vorlauf}{Zeilen}{Einzug}` | fester Einzug, Handarbeit |
| `\dsaUmflussKontur{Spalte}{Vorlauf}{Liste}` | Einzug je Zeile, Handarbeit |

Das erste Argument ist die **Spalte**, nicht die Seite: `l` = Text links, Bild rechts davon.

**Der Text umfließt nicht den Bildrahmen, sondern den Freistellpfad.** An einem gesetzten
Scriptorium-Abenteuer nachgemessen: ein Bild von 73,8 × 55,3 mm über dem Bundsteg, Rahmen bis
140,3 mm — der Text der rechten Spalte rückt aber nur bis 122,8 mm ein, und zeilenweise
unterschiedlich. Deshalb `\dsaUmflussKontur` mit einer Liste statt einer Zahl. Eine gemessene
Kontur über 31 Zeilen, Einzug in mm ab der Spaltenkante:

```
11.6  12.1  13.5  13.4  11.9  16.4  16.0  17.9  19.0  20.1  21.7  22.6
24.0  26.0  26.8  26.8  26.1  21.3  19.3  18.2  18.3  18.0  17.3  16.7
14.6  14.4  17.1  23.1  22.4
```

Die Liste liest der Setzer am Abzug ab — dieselbe Handarbeit, die ein Setzer in InDesign auch
leistet, nur nimmt ihm dort der Freistellpfad die Zahlen ab.

---

## Tabellen und Raster

`\dsaTabellenkopf{Text}` setzt die Kopfleiste mit Verlauf von `Tabellenrot` nach Weiß,
`\dsaTabellenlinie` die Linienfarbe auf `#BFBFBF`.

**Tabellen kommen in `dsaTabelle`, nicht in `tabular`.** Die Umgebung nimmt dasselbe
Spaltenformat:

```latex
\dsaTabellenkopf{Qualität und Preis einer Herberge}
\dsaTabellenlinie
\begin{dsaTabelle}{@{}ll@{}}
ärmlich & 2 Kreuzer\\
gut & 1 Silbertaler\\
\end{dsaTabelle}
```

Warum nicht `tabular` allein: ohne Positionsargument setzt LaTeX die Tabelle als `\vcenter`,
dessen Höhe halbe Tabellenhöhe plus Mathe-Achse ist. Die Box ist damit höher als eine Grundlinie,
TeX kann die Grundlinienregel nicht anwenden und fällt auf `\lineskip` zurück — der Anfang hängt
dann an der Tiefe der letzten Textzeile. Gemessen begann die Tabelle 0,7 bp neben dem Raster, und
der Fließtext danach blieb 0,9 bp daneben, bis zum Spaltenende.

`dsaTabelle` setzt die Tabelle mit `[t]` in eine Box ohne Höhe und Tiefe: die Referenzgrundlinie
ist damit die erste Zeilengrundlinie und sitzt auf der laufenden Grundlinie. Den Raum liefert
`\dsaRasterluft`, aufgerundet auf ganze Rastereinheiten — deshalb verträgt die Umgebung auch
Linien und mehrzeilige Zellen.

Derselbe Grund gilt für den Kopf: seine `tcolorbox` ist genau eine Rastereinheit hoch, also nicht
niedriger als der Durchschuss. `\dsaTabellenkopf` setzt sie deshalb ebenfalls in eine Box ohne
Höhe und schiebt sie um `\dsatabellenkopftiefer` (3,4 bp) nach unten, damit ihr Text auf der
Grundlinie bleibt. Der Kopf belegt genau die Zeile, in der er steht.

Gemessen an einer Probe mit drei Fällen — Tabelle ohne Kopf, Tabelle mit Kopf, Kopf allein —
liegen alle Zeilen einschließlich des Folgetexts auf +0,00 bp.

| Aufruf | wofür |
|---|---|
| `\dsaFeld{Name}{Wert}` | ein Feld |
| `\begin{dsaWerteblock}` | Werte einer Meisterperson oder Kreatur |
| `\begin{dsaKurzcharakteristik}` | Felder für soziale Begegnungen |
| `\dsaProbe[Farbe]{Name}` | farbiger Balken über die Spalte, danach die QS-Staffel |
| `\dsaZusammenfassung{…}` | fünf Rubriken für den Rücktitel |
| `\dsaAnforderungen{a}{b}{c}{d}` | vier Rautenzeilen, Werte 1 bis 4 |

Die Rubriken der Anforderungen sind der heutige Stand: **Kampftalente, Gesellschaftstalente,
Handwerkstalente, Lebendige Geschichte**.

## Impressum

Im deutschen Buchhandel heißt diese Seite **Impressum**; sie sitzt in der **Titelei**, üblicherweise
auf der **Titelrückseite**. Im Englischen: *copyright page*. Der Markenhinweis darin ist der
**Rechtevermerk** — das ist der Teil mit dem eigenen Namen.

`\begin{dsaImpressumseite}` setzt die Überschrift IMPRESSUM und stellt alles mittig,
`\dsaImpressumsblock{Rubrik}{Inhalt}` je Angabe, `\dsaRechtevermerk{Jahr}{Name}` den
vorgeschriebenen Hinweis mit der Zwischenüberschrift „Disclaimer".

Aufbau und Rubriken nach dem Vorbild einer gesetzten Scriptorium-Veröffentlichung: Autor,
Redaktion, Lektorat, Korrektorat, Künstlerische Leitung, Coverbild, Satz Layout und Gestaltung,
Innenillustrationen und Pläne, Version — oft mit einer Danksagung am Ende.

**Der Rechtevermerk steht wörtlich in der Klasse und darf nicht umformuliert werden** — nicht
kürzen, die Versalien nicht glätten. Ältere Veröffentlichungen führen einen anderen Wortlaut, unter
anderem mit einem anderen Rechteinhaber; der in der Klasse ist der aktuelle. Wer eine neuere Fassung
vom Verlag hat, ersetzt ihn dort. Es gibt absichtlich nur diesen einen Ort und nur diesen einen
Befehl dafür.

---

## Beim ersten Lauf prüfen

**Diese Klasse ist noch nicht am Ergebnis geprüft** — sie ist aus gemessenen Maßen geschrieben, aber
bei ihrer Entstehung stand keine LaTeX-Installation zur Verfügung. Im Quelltext stehen dieselben
Punkte als `% PRUEFEN:`. Nach Bruchwahrscheinlichkeit sortiert.

### Bricht der Lauf ab

1. **`polyglossia` mit `spelling=new`** — sonst auf `\setdefaultlanguage{german}` zurückfallen; die
   Trennmuster sind dann trotzdem deutsch.
2. **`\dsa@rauten`** benutzt `\ifnum` in einer `\foreach`-Schleife.
3. **`\dsaUmfluss` und `\dsaUmflussKontur`** bauen die `\parshape`-Liste selbst auf. Mit kleinen
   Werten testen, etwa `\dsaUmfluss{l}{2}{4}{25mm}`.
4. **`\f@size` in `\dsaKapitaelchen`** — wenn es bricht, feste `10pt` einsetzen.
5. **`\textminus`, `\texttimes`, `\guillemotright`** — ob Gentium Basic die Zeichen hat.
6. **`\addfontfeature{LetterSpace=1.0}`** in `\dsaEinfuehrung`.
7. **`\contour` mit gesetzter Schriftgröße** im Umschlag und in der Seitenzahl.
8. **`underlay app`** im Porträtschlüssel — braucht die `skins`-Bibliothek von tcolorbox.
9. **`\pgfdeclarefading`** in `\dsaBildMaskiert` — Transparenzgruppen sind unter XeLaTeX weniger
   erprobt als unter pdflatex.
10. **`\dsaBildDeckend`** vergleicht zwei pgfmath-Makros als Längen in pt.

### Läuft durch, sieht aber falsch aus

11. **Innenabstände der Kästen** — geschätzt, an einer Stelle änderbar.
12. **Lage und Durchmesser des Porträtmedaillons** — geschätzt.
13. **Breite des Pergamentrands am Kapitelbild** (`\dsakapitelbildrand`) — geschätzt.
14. **Größe und Abstand der gezeichneten Rauten** — mit den offiziellen vergleichen.
15. **Lage der Kapitelüberschrift im Banner** — 22 mm unter der Kante, mittig auf 150 mm,
    geschätzt. Bei zweizeiligen Titeln reichen 10 Rastereinheiten nicht.
16. **Seitenhintergrund** — Anker an der Außenkante; bleibt ein weißer Streifen, ist der Anker
    falsch gewählt, nicht das Maß. Und: die Folge muss 0,0,1,1,2,2,3,3 sein.
17. **Lage der Titelzeilen im Umschlag** — geschätzt.
18. **Absatzeinzug** — `\parindent` auf 1 em, am offiziellen PDF nachmessen.
19. **Icongrößen** — 4 mm Höhe gewählt, nicht belegt.
20. **Beschnitt der deckenden Bilder** ist mittig. Bei einem Porträt sitzt der Kopf oft oben.
21. **`\dsaVorlesetext`** steht aufrecht auf Spaltenbreite; ob das stimmt, sagt der Baukasten nicht.
22. **`\dsaNSCkopf`** staucht eine 158,5 mm breite Leiste auf Spaltenbreite.
23. **Nach `\dsaQuerEnde`** prüfen, ob die Grundlinien wieder sitzen.
24. **`\dsaBildUmflossen`** — `wrapfig` rundet die Zeilenzahl selbst.
25. **`\dsaBildBund`** — Vorzeichen und Bezugspunkt am Abzug nachsehen.
