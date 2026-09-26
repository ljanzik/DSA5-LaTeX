# Prüfplan

*Was geprüft wird, woran gemessen wird, und was dabei herauskam.*

Die Klasse ist aus den Maßen des Layout-Baukastens gebaut. Ein Maß im Quelltext ist aber noch kein
Maß auf dem Papier: ein Kasten kann zwei Millimeter zu weit außen sitzen, ein Medaillon um seine
halbe Breite verschoben sein, ein Textblock neben seinem Rahmen liegen. Im PDF sieht man das als
„irgendwie schief“, nicht als Zahl. Dieser Plan macht daraus Zahlen.

## Wie gemessen wird

```sh
# Bilder und Textzeilen eines gesetzten PDF, mit Lage und Größe in mm
python3 werkzeuge/nachmessen.py probeseiten.pdf --seite 5 --text

# Pixelmaße der Grafiken gegen die Sollwerte des Baukastens
python3 werkzeuge/pruefen.py
```

`nachmessen.py` erkennt jede Grafik an ihren Pixelmaßen und nennt sie beim Namen — die Zuordnung
kommt aus `pruefen.py`. Für Dinge ohne Text und ohne Grafik (Rautenskalen, TikZ-Zeichnungen)
bleibt das Rastern eines Ausschnitts und das Messen im Bild.

**Zu den Quellen.** Der Baukasten selbst ist die erste Quelle: sein Klartext, seine IDML, seine
PSD-Dateien, die Pixelmasse seiner PNG. Wo er schweigt — Impressum, Seitenzahl, Kolumnentitel —,
bleibt eine gesetzte Veroeffentlichung als Anhalt. Deren Satzspiegel ist aber **nicht** der des
Baukastens: gemessen 160,9 mm Satzbreite, 74,6 mm Spalten, 11,7 mm Steg, Hintergrundbilder mit
167 ppi. Der Baukasten nennt 166 mm, 80,5 mm und 5 mm. Eine Veroeffentlichung taugt deshalb nur
fuer Elemente, die der Baukasten nicht kennt, und niemals fuer den Satzspiegel.

Drei Fehlerarten sind zu unterscheiden:

1. **Falsches Sollmaß** — der Wert in der Klasse stimmt nicht mit dem Baukasten überein. Quelle
   prüfen (IDML, PSD, PNG-Pixelmaß), Wert korrigieren, in `MASSE.md` festhalten.
2. **Richtiges Maß, falsch gesetzt** — der Wert ist richtig, kommt aber nicht dort an: falscher
   Anker, `shift` an einem transformationsinvarianten Knoten, ein Maß im Textraum statt im
   Nutzerraum.
3. **Kein Sollmaß vorhanden** — der Baukasten sagt nichts dazu. Dann Augenmaß, und der Wert wird
   als geschätzt gekennzeichnet.

## Status

`—` nicht geprüft · `ok` gemessen und in Ordnung · `!` Abweichung gefunden · `#` behoben und
nachgemessen

### Satzspiegel und Raster

| Prüfung | Sollmaß | Quelle | Status |
|---|---|---|---|
| Satzbreite, Ränder | 166 mm, innen 20, außen 24, oben 24 | Baukasten, Klartext | `ok` |
| Spaltenbreite und -steg | 80,5 mm, 5 mm | daraus gerechnet | `ok` |
| Zeilen je Spalte | 59 auf 12 pt | textheight 708 pt | — |
| Grundlinienraster | erste Linie 12,7 mm, dann 12 pt | Musterbogen | `ok` |
| Beide Spalten auf derselben Linie | — | `rasterzeigen` | — |

Der Satzspiegel ist am Musterbogen des Baukastens dreifach bestätigt:

* Textzeilen der zweiten Spalte beginnen bei **x 105,50 mm** und enden bei 186,8 mm. Das ist genau
  innen 20 + 80,5 + 5 = 105,5 und innen 20 + 166 = 186.
* Die Kästen auf Musterseite 7 sind **exakt 80,50 mm breit** und sitzen bei x 24,00 und
  x 109,39 mm — auf einer linken Seite also außen 24 mm, Spalte 2 bei 24 + 80,5 + 5 = 109,5.
* Alle Zeilen des Fließtextes (10 pt) liegen mit **±0,00 pt** auf dem Raster aus erster Linie
  12,7 mm und 12 pt Schritt. Auch die Kapitelüberschrift sitzt darauf.

Gemessen mit `nachmessen.py`, das die Grundlinie aus der Textmatrix nimmt. Die Unterkante der
Zeichenbox taugt dafür nicht: sie liegt je Schriftgrad anders, bei 13 pt Andalus etwa 1,9 mm
tiefer.

### Seitentypen

| Prüfung | Sollmaß | Quelle | Status |
|---|---|---|---|
| Umschlag vorne, Rahmen randabfallend | 216 × 303 mm, mittig | PNG-Pixelmaß | `#` |
| Covertitel: Grad, Zeilenabstand, Lage | 42,8 pt, 51,4 pt, 31,3 mm über der Kante | `Cover_Buchtitel.psd` | `#` |
| Titel: Fläche, Rand, Verlauf | 8,4 pt / 0,24 pt / vier Haltepunkte | PSD, gegen zwei gesetzte Abenteuer geprüft | `#` |
| Titel: Versatz und Weichzeichnung des Schriftschattens | 6,0 bp unter 150°, 6,8 bp weich — 0,278 der Versalhöhe gegen 0,243–0,270 beim Verlag | US25324 und US25326, Umschlag | `#` |
| Titel: Lagenfolge bei mehreren Zeilen | Flächenschatten, Flächen, Schriftschatten, Lettern — vier Stufen über alle Zeilen | PSD-Ebenenmodell, eigene Messung | `#` |
| Titel: die beiden Schlagschatten | 5,04 bp / 5,04 bp / 75 % und 7,44 bp / 4,32 bp / 63 %, beide unter 120 Grad | `Cover_Buchtitel.psd` | `ok` |
| Titel: Farben der grauen Fassung | `#C5B8CE` / `#3A3442` / `#A6A6A6` / `#2E2832` | `Cover_Buchtitel.psd` | `ok` |
| Titel: Farben der roten Fassung | `#B22526` / `#741C16` / `#C08848` / `#5F1812` | US25533, Umschlag, 300 ppi abgetastet | `!` |
| Impressum: Überschrift, Rubriken, Vermerk | 37,6 mm / 14 pt / 94,5 mm | gesetzte Veröffentlichung | `#` |
| Seitenzahl | 18,4 mm von außen, 5,9 mm über der Kante, Andalus 13 pt | Musterbogen | `#` |
| Kolumnentitel (Kapitelname neben der Zahl) | Andalus 14 bp schwarz, Grundlinie wie die Zahl, rechts 24,29 mm und links 40,35 mm von der Außenkante | gesetzte Veröffentlichung | `#` |
| Kapiteltitel: Grad | **31,73 pt** = 23,5 × 135 % | IDML-Absatzformat, Musterbogen, 8 Kapitel zweier Bände | `#` |
| Kapiteltitel: Grundlinie | y 94,71 pt, linksbündig am inneren Rand | Musterbogen, US25324 | `#` |
| Kapiteltitel: kein „Kapitel N:“ | nur der Titel | 8 Kapitelanfänge, US25324 und US25326 | `#` |
| Textanfang der Kapitelseite | y 168,00 pt = 7 Rastereinheiten | US25324, ein- und zweizeilige Titel | `#` |
| Unterkapitel: Grad | **18,9 pt** = 14 × 135 % | IDML-Absatzformat, 7 Zwischenüberschriften | `#` |
| Impressumtitel | Andalus 31,73 pt, Grundlinie y 94,00 pt | US25324 und US25326 | `#` |
| Seitenhintergrund: Lage, Anschnitt, Folge 0,0,1,1,2,2,3,3 | 213 × 303 mm an der Außenkante | Schnitt der Doppelseiten | — |
| Kapitelanfang: Banner, Bild, Pergamentrand | Banner 210,1 × 43,2 mm am oberen Rand | IDML | — |
| Inhaltsverzeichnis | kein Sollmaß | — | — |
| Ganzseitige Grafik | 184 × 265 mm im Grafikbereich | IDML, zweiter Rahmen | — |
| Umschlag hinten: Textblock am Rahmen | 78,10 / 52,91 / 194,99 mm | IDML | `#` |
| Querformat, Raster danach | kein Sollmaß | — | — |

### Kästen

Für jeden Kasten sind vier Dinge zu prüfen: die **Größe** der Hintergrundgrafik (steht in der
Klasse, prüfbar über die Pixelmaße), die **Lage** in der Spalte samt Überhang, die **Innenabstände**
des Textes und ob der Text nach dem Kasten **wieder auf der Grundlinie** sitzt.

**Die Größen sind geprüft.** Dreizehn von fünfzehn stimmen mit den Platzierungen der IDML auf ein
Zehntel Millimeter überein — `Kasten_Pergament_ver3` 85,51 × 50,72 mm, `Kleiner Wertekasten`
84,41 × 54,78 mm, `MeisterkastenMitMaske` 83,99 × 108,03 mm und so weiter, jeweils bei 300 gegen
300 ppi, also in 100 Prozent platziert. Zwei Fälle sehen im ersten Blick anders aus:

* `Kasten_Pergament_sehr schmal` wird im Musterbogen **gedreht** gezeigt, 186,08 × 47,26 mm statt
  48,86 × 192,37 mm hochkant. Das ist eine Vorführung, keine Vorschrift.
* `Meisterkasten.psd` erscheint mit 84,60 × 42,25 mm quer, obwohl die Grafik hochkant ist —
  ebenfalls gedreht platziert.

**Der Text im Kasten ist 9,5 pt auf 11,4 pt** und folgt *nicht* dem Grundlinienraster der Seite: im
Musterbogen weichen seine Zeilen um 0,4 bis 2,8 pt davon ab, wachsend von Zeile zu Zeile. Ein
Kasten ist ein eigener Satzraum. Die Kastenüberschrift ist 12 pt.

**Die Innenabstände** der gezeichneten Kästen auf Musterseite 7: Text 3,0 mm vom linken und
2,25 mm vom rechten Kastenrand, Titel 1,46 mm, Titelgrundlinie 5,16 mm unter der Oberkante. Diese
Kästen sind spaltenbreit und haben keinen Überhang. Für die Grafikkästen, die über die Spalte
hinausragen, gilt das nicht unmittelbar: dort kommt die Breite des Zierrandes hinzu, und der
Musterbogen zeigt sie ohne Text.

| Kasten | Grafik | Rastereinheiten | Innenabstände | Status |
|---|---|---|---|---|
| `dsaPergamentKlein` | 85,5 × 50,7 mm, Überhang 2,5 mm | 12 | geschätzt | `#` |
| `dsaPergamentMittel` | 85,5 × 99,5 mm, Überhang 2,5 mm | 24 | geschätzt | `#` |
| `dsaPergamentLang` | 85,5 × 192,4 mm, Überhang 2,5 mm | 46 | geschätzt | `#` |
| `dsaPergamentBreit` | 136,9 × 192,4 mm | 46 | geschätzt | — |
| `dsaPergamentSchmal` | 48,9 × 192,4 mm | 46 | 6 mm | `#` |
| `dsaWerteKlein` | 84,4 × 54,8 mm, Überhang 1,95 mm | 13 | 7 mm | `#` |
| `dsaWerteMittel` | 86,9 × 103,8 mm, Überhang 3,2 mm | 25 | 7 mm | `#` |
| `dsaWerteGross` | 85,0 × 197,1 mm, Überhang 2,25 mm | 47 | 7 mm | `#` |
| `dsaWerteKleinPortrait` | 94,0 × 59,2 mm, 13,5 mm nach außen | 14 | 7/24 mm | `#` |
| `dsaWerteMittelPortrait` | 94,0 × 104,0 mm, 13,5 mm nach außen | 25 | 7/24 mm | `#` |
| `dsaWerteGrossPortrait` | 94,0 × 199,1 mm, 13,5 mm nach außen | 47 | 7/24 mm | `#` |
| `dsaMeisterSchmal` | 59,9 × 114,2 mm | 27 | 6/8 mm | `#` |
| `dsaMeisterBreit` | 177,9 × 114,2 mm, Überhang 5,95 mm | 27 | 10/8 mm | `#` |
| `dsaMeisterMaske` | 84,0 × 108,0 mm, Überhang 1,75 mm | 26 | 7/10/8 mm | `#` |
| `dsaMeisterMaskeKlein` | 84,0 × 45,0 mm, Überhang 1,75 mm | 11 | 7/10/6 mm | `#` |
| `dsaKastenFrei` | Höhe in Rastereinheiten, Zierleisten in wahrer Größe | frei | wie Pergament | — |
| Porträtmedaillon | 35,39 × 34,97 mm, Lage im Kasten noch geschätzt | `Ornament_Portrait_Wertekasten.psd` | — | `#` |

### Gliederung und Fließtext

| Prüfung | Sollmaß | Quelle | Status |
|---|---|---|---|
| Kapitel, Unterkapitel, Abschnitt, Unterabschnitt | 23,5 / 14 / 13 / 10 pt | IDML, Absatzformate | `ok` |
| Abstände der Überschriften, Raster gehalten | 12 pt nach Unterkapitel | IDML, `SpaceAfter` | `ok` |
| `\parindent` | **0** — kein Absatzformat der IDML hat `FirstLineIndent` außer den hängenden | IDML | `#` |
| Text im Kasten | 9,5 pt auf 11,4 pt, eigenes Raster | Musterbogen, IDML | `#` |
| Kastenüberschrift | 12 pt, als `\dsaKastentitel` | Musterbogen, Zeichenformat | `#` |
| Vorlesetext, Zierleiste darüber | 15,39 mm breiter als die Spalte, mittig darüber | IDML und gesetzte Veröffentlichung | `#` |
| Werteabsatz, hängender Einzug | 8,50 pt | IDML, Format „Werte“ | `ok` |
| Einführung, Stimmung, Zitat | Laufweite +10, Grau 404040 | IDML | — |
| Aufzählungen: Einzug | 17,01 pt = 6,0 mm hängend | IDML, „Aufzählung v2“ | `ok` |
| Aufzählungen: Zeichengröße | 4,36 × 2,36 mm | IDML, Rahmenmaß | `#` |

### Marken und Zeichen

| Prüfung | Sollmaß | Quelle | Status |
|---|---|---|---|
| Auge schwarz und weiß | 1,69 × 0,92 mm | IDML, Rahmenmaß | `#` |
| Aufzählungszeichen | 4,36 × 2,36 mm | IDML, Rahmenmaß | `#` |
| Fiole, Totenkopf | 9,06 × 9,06 mm bei 100 % | IDML, Rahmenmaß | `#` |
| Gegnerabstufung | Bauer 3,00 / Springer 3,17 / Turm 3,27 / König 3,21 mm hoch | IDML | `#` |
| Fokusregelmarke | 9,86 × 9,61 mm | IDML | `#` |
| Porträtmedaillon, Größe | 35,39 × 34,97 mm bei 100 % | IDML | `#` |
| Porträtmedaillon, Lage im Kasten | je Kasten 17,06/17,97, 17,91/16,87 und 17,57/16,62 mm | Alphakanal der Kastengrafiken | `#` |
| Rautenskalen in TikZ | Vorbild `DSA5_Rauten_*` | PNG | — |
| Bandmarke `\dsaBand` | Text, keine Grafik: hochgestelltes Kürzel plus Seite | Baukasten | `ok` |
| Markengrafiken, Auflösung | mit 1700 bis 2700 ppi platziert, zusammen 2 MB | eigene Messung | `ok` |

### Bilder und Umfluss

| Prüfung | Sollmaß | Quelle | Status |
|---|---|---|---|
| Spaltenbild, ganze Rastereinheiten | Text sitzt danach auf der Linie | — | — |
| `\dsaBildDeckend`: Beschnitt statt Verzerrung | Seitenverhältnis bleibt | — | — |
| Kreis- und Freiformmaske | — | — | — |
| Umfluss mit festem Einzug | — | — | — |
| Umfluss entlang einer Silhouette | gemessene Kontur aus einer Veröffentlichung | eigene Messung | — |

### Tabellen

Der Musterbogen des Baukastens hat auf Seite 8 vier Tabellen, drei davon im Zellenformat der
Waffentabellen. Damit gibt es doch ein Sollmaß, und alle Werte unten sind daran gemessen —
Linien und Flächen aus dem Inhaltsstrom des PDF, Farben aus einem 600-dpi-Rastern.

| Prüfung | Sollmaß | Quelle | Status |
|---|---|---|---|
| Tabellenbreite | volle Spaltenbreite, x 56,69 bis 284,88 pt | Musterbogen S. 8 | `#` |
| Zelleneinzug | 1,2 mm ringsum, erstes Zeichen bei x 60,09 pt | IDML, Zellenformate | `#` |
| Linienstärke | 0,25 pt, keine senkrechten Linien | IDML, Zellenformate | `#` |
| Linie unter jeder Zeile | 25 % Schwarz, gemessen `#D0D0D0` | Musterbogen S. 8 | `#` |
| Linie über und unter der Titelzeile | 60 % Schwarz, gemessen `#878785` | Musterbogen S. 8 | `#` |
| Fläche der Rubrikzeile | 10 % Schwarz, gemessen `#ECECEC` | Musterbogen S. 8 | `#` |
| Verlauf der Titelzeile | Tabellenrot nach Weiß über die ganze Breite | Farbfeld „Tabelle Überschrift“ | `#` |
| Schriftgrade | Titel fett 10 pt, Rubrik fett 9,5 pt, Werte 10 pt | Musterbogen S. 8 | `#` |
| Zeilenhöhe | 15,54 pt — bewusst nicht übernommen, siehe unten | IDML, Zeilenhöhen | `!` |
| Probenzeile | Balken volle Spaltenbreite × 6,985 mm, Text Gentium fett 11 bp, Grundlinie 4,87 mm unter der Oberkante | gesetzte Veröffentlichung | `#` |

**Vier Befunde, alle behoben.**

1. **Der Verlauf der Kopfleiste wurde nie gezeichnet.** Die `tcolorbox` stand auf `blankest`,
   und das schaltet das Innere ab; `interior style` holt es nicht zurück. Am gesetzten PDF
   gemessen war die Leiste über die ganze Breite reinweiß — (239, 230, 223) am linken Rand war
   der Pergamenthintergrund, nicht die Farbe. Jetzt zeichnet TikZ, gemessen (193, 145, 124) am
   linken Rand gegen (193, 144, 122) im Baukasten.
2. **Die Tabelle endete nicht mit der Spalte.** Die Linien liefen von x 56,69 bis 225,04 pt, die
   Kopfleiste über die volle Spalte bis 284,88 — 60 pt Unterschied, im Abzug ein abgebrochener
   Kasten. `dsaTabelle` spannt jetzt `tabular*` über `\linewidth`.
3. **Die Grauwerte waren gerechnet, nicht gemessen.** `#BFBFBF` ist der rechnerische Tonwert von
   25 Prozent Schwarz; im Export sind es `#D0D0D0`, weil „Black“ im IDML CMYK ist und der
   Tonwert durch das Farbprofil geht. Siehe `MASSE.md`, Abschnitt 4.
4. **`\hline` brach das Raster.** Die Linie bringt ihre Strichstärke als Bauhöhe mit, und die
   Grundlinien standen 12,25 statt 12,00 bp auseinander. Die Umgebung zeichnet die Linien jetzt
   selbst, über `\everycr`, mit ausgleichendem `\vskip`. Nachgemessen an `beispiel/raster.pdf`:
   alle Zeilen der Tabelle und der Fließtext danach auf ±0,00 bp.

**Zwei bewusste Abweichungen.** Die Zeilenhöhe des Baukastens ist 15,54 pt und liegt auf keiner
Rasterlinie — seine Tabellen stehen ausdrücklich nicht im Grundlinienraster
(`GridAlignment="None"`). Hier gilt das Raster mit 12 bp. Und das Farbfeld hat seinen
Verlaufsmittelpunkt bei 40,33 statt 50 Prozent; die Klasse blendet linear, gemessener Unterschied
höchstens 5 von 255 Stufen.

**Offen: lange Tabellen.** Eine Tabelle ist ein Block und wird nicht umbrochen. Passt sie in
keine Spalte — mehr als 58 Rastereinheiten —, läuft sie unten heraus; gemessen an einer Probe mit
70 Zeilen stand Zeile 56 bei y 782,8 pt, also 6,8 pt unter dem Satzspiegel, und die Zeilen 57 bis
69 fehlten ganz. Die Klasse warnt jetzt mit `dsa5latex Warning` und nennt die Höhe; geteilt werden
muss von Hand. Ein automatischer Umbruch bräuchte `\halign` in einer `\vbox` und `\vsplit`, weil
`longtable` im zweispaltigen Satz nicht arbeitet.


### Ergebnis des Kastenblocks

Gemessen mit `beispiel/kaesten.tex` — jeder Kasten auf eigener Seite, ohne
Seitenhintergrund, ein Lauf dauert eine Minute.

**Ein einziger Wert war die Ursache für alle Verschiebungen.** Dreizehn Kästen saßen um genau
3,58 mm zu weit innen, unabhängig von ihrem Überhang. 3,58 mm ist 1 em bei 10 pt, also
`\parindent`: eine `tcolorbox` ist ein Absatz und wurde eingerückt wie einer. Mit `\parindent=0pt`
— was die Absatzformate des Baukastens ohnehin verlangen — sitzen alle auf 0,07 mm genau:

| Kasten | Überhang Soll | Ist |
|---|---|---|
| `pergament-klein`, `-mittel`, `-lang` | −2,50 mm | −2,43 mm |
| `werte-klein` | −1,95 mm | −1,88 mm |
| `werte-mittel` | −3,20 mm | −3,13 mm |
| `werte-gross` | −2,25 mm | −2,18 mm |
| `werte-klein-portrait` | −5,10 mm | −5,03 mm |
| `meister-maske`, `-klein` | −1,75 mm | −1,68 mm |
| `pergament-schmal`, `-breit`, `meister-schmal` | 0 | +0,07 mm |

**Das Porträtmedaillon** hatte drei Fehler zugleich: die 35,4 mm aus der IDML sind das Ornament,
nicht das Bild — der freie Innenkreis ist **21,0 mm**, die Kranzbreite 5,0 mm. Der Ring steckt
zudem schon in der Kastengrafik, seine Mitte 17,6 mm von der rechten Bildkante und 19,4 mm unter
der Oberkante. Und der Anker war der tcolorbox-`frame`, der durch den Überhang 13,5 mm breiter ist
als die Grafik; deshalb ragte das Medaillon um genau diesen Betrag hinaus. Jetzt hängt es an der
Grafik: gemessen sitzt es bei x 95,30 mm gegen 95,38 mm Soll und y 43,40 gegen 43,47.

**Offen bleibt** `dsaMeisterBreit`: einspaltig gesetzt sitzt er bei x 14,12 mm statt 18,05 mm.
Ein Kasten, der breiter ist als der einspaltige Satz, wird von tcolorbox anders behandelt als einer
in der Spalte.

## Was der Prüflauf ergeben hat

Vierzehn Fehler, alle erst am gesetzten Abzug sichtbar:

| Element | Fehler | Ursache |
|---|---|---|
| alle Kästen | 3,58 mm zu weit innen | `\parindent` — eine `tcolorbox` ist ein Absatz |
| alle Kästen | Text rechts 2,7 mm, links 7,9 mm vom Rand | `grow to left by` verbreitert die Box, nicht nur ihre Lage |
| `dsaMeisterBreit` | einspaltig 3,9 mm daneben | dieselbe Ursache |
| Porträtkasten | Text 5,7 mm unter dem Medaillon | rechter Innenabstand zu klein; maßgeblich ist der Kranz, nicht das Bild |
| Porträtmedaillon | 13,5 mm über den Kasten hinaus | Anker war der `frame`, nicht die Grafik |
| Porträtbild | verdeckte Kranz und Schlagschatten | lag über dem Ring statt darunter |
| Fließtext | 4,5 pt neben dem Raster | `\topskip`, und alle Maße sind bp statt pt |
| fünf Elemente | verließen das Raster | `\lineskip`, Überschriftendurchschuss, `partopsep` |
| drei Bildbefehle | verließen das Raster | eigene Höhe statt Rastereinheiten |
| Inhaltsverzeichnis | 0,8 pt daneben | Überschrift höher als `\topskip` |
| Kapitelbanner | 11,3 mm zu hoch, Titel zentriert | geschätzt statt gemessen |
| Seitenzahl | 20 pt statt 13 bp, 2,6 mm zu weit innen | aus der falschen Quelle |
| Seitenhintergrund | auf jeder Seite derselbe | `\value{page}` ist im Ausschießen nicht die Seitenzahl |
| Querformat | war keins | `\newgeometry` kann kein Papierformat |
| `dsaKastenFrei` | Pergament um Faktor 3,2 gestaucht | Höhe erzwungen statt beschnitten |
| Umschlagrückseite | Text im Satzspiegel statt im Rahmen | Rahmenmaße lagen ungenutzt in der IDML |

Zur Aufloesung der Marken: sie sind klein platziert und deshalb mit sehr hohem ppi-Wert, aber
jede Datei wird nur einmal in das PDF eingebettet. Alle Marken zusammen kosten 2 MB; die Groesse
der Abzuege kommt von den Seitenhintergruenden und Pergamenten. Kein Handlungsbedarf.

Nicht behoben, weil kein Fehler: `\dsaBildKreis`, `\dsaBildForm` und `\dsaGanzseite` platzieren
ihre Bilder größer als das Ziel und beschneiden. `nachmessen.py` zeigt die Platzierung.

Behoben nach dem Prüflauf: die Tabellenzeilen begannen 0,7 bp neben dem Raster, und der
Fließtext danach blieb 0,9 bp daneben. Ursache war zweifach — `tabular` ohne Positionsargument
wird ein `\vcenter` und ist höher als eine Grundlinie, und die Kopfleiste ist mit genau einer
Rastereinheit ebenso hoch wie der Durchschuss. In beiden Fällen greift TeXs Grundlinienregel nicht
mehr. `dsaTabelle` und der umgebaute `\dsaTabellenkopf` setzen beides in Boxen ohne Höhe und
Tiefe; gemessen liegen alle Zeilen auf +0,00 bp.

Ebenfalls behoben: `\dsaAbschnittGelb` lag 4,1 bp neben dem Raster und schob den Fließtext danach
auf −1,9 bp — dieselbe Ursache, eine `tcolorbox` als eigener Absatz, knapp 19 bp hoch. Der
Baukasten gibt für dieses Element keine Maße her, also nach der Regel des Rasters: die Fläche ist
zwei Einheiten hoch, ihr Text sitzt mittig darin auf einer Grundlinie, davor und danach eine
Leerzeile. Gemessen +0,00 bp für die Überschrift und den Text danach.

Damit weicht in `raster.pdf`, `kaesten.pdf`, `rest.pdf`, `beispiel.pdf`, `probeseiten.pdf` und
`ganter.pdf` keine Zeile mehr vom Raster ab, außer den Elementen mit eigenem Maß.

Behoben nach dem Prüflauf: im Porträtkasten wich der Text dem Medaillon über die ganze Höhe aus und
behielt nur 53 mm Breite. `\dsaPortraitfluss` setzt jetzt `\parshape` im Kasten — acht schmale
Zeilen, danach volle Breite. Nachgemessen an `beispiel/kaesten.pdf` Seite 9: Zeile 1 bis 8 enden bei
74,9 mm, Zeile 9 und die folgenden bei 101,5 mm, der Kranz beginnt bei 76,6 mm und endet 58,9 mm unter der Papierkante, die erste breite Zeile liegt bei 64,7 mm.

### Drei Funde beim Messen des Rasters über alle Abzüge

Die Messung aller sechs Abzüge, Zeile für Zeile, hat drei Fehler gezeigt, die einzelne Elemente
nicht verraten hätten:

**Tabellen mit `\hline` lagen 3,2 bp daneben**, ohne Linie saßen sie. Bei `tabular[t]` ist die
Referenzgrundlinie die der ersten Reihe — steht dort eine Linie, ist sie diese Reihe. Ihr `\ht`
ist dann 0,0 pt, die Linie liegt vollständig unter der Referenz, und die erste Textgrundlinie folgt
erst nach Linienstärke plus Strut. `dsaTabelle` erkennt den Fall an der Boxhöhe und hebt um
`\ht\strutbox` plus `\arrayrulewidth`.

**Der Durchschuss fiel im Querformat auf 12,0 pt** — den TeX-Punkt statt den bp — und blieb dort
auch nach `\dsaQuerEnde`. Jede Seite nach einem Querformat lief also 0,37 Prozent zu eng, über
59 Zeilen 2,6 bp Drift. Ursache: `\newgeometry` ruft `\normalsize`, und das war die
Voreinstellung der Basisklasse. Die bp-Maße standen nur in einem `\AtBeginDocument`. Jetzt ist
`\normalsize` selbst auf die bp-Maße gesetzt — der Haken, den LaTeX für die Grundschrift vorsieht.

**Die Querseite selbst lag 1,5 bp unter dem Raster**, weil `\topskip` für einen Satzspiegel ab
24 mm gerechnet ist und dort 15 mm gelten. `\dsaQuerAnfang` rechnet ihn neu, `\dsaQuerEnde`
stellt den alten Wert zurück.

### Vier Statuszeilen nachgeprüft

Vier Zeilen trugen noch „Abweichung gefunden“. An den Abzügen nachgemessen:

* **Kapiteltitel im Banner** — kein Fehler. Die 12,93 mm der IDML sind die Oberkante des
  Textrahmens, nicht die Grundlinie; die liegt bei Andalus 23,5 bp rund 9,2 mm darunter, also
  33,41 mm unter der Papierkante — genau der Wert vom Musterbogen. Gemessen sitzt der Titel dort.
* **`dsaMeisterBreit`** — kein Fehler. Gemessen 177,90 × 114,20 mm bei einem Überhang von 5,88 mm
  gegen 5,95 mm Sollmaß.
* **`\parindent`** — steht auf 0, in allen Abzügen beginnt jede Zeile am Satzspiegel.
* **Zierleiste über dem Vorlesetext** — echter Fehler, behoben. Sie lag auf Spaltenbreite; der
  Baukasten platziert sie 15,39 mm breiter, und eine gesetzte Veröffentlichung bestätigt das mit
  89,9 mm Leiste über einer 73,4-mm-Spalte. Sie steht jetzt mittig über der Spalte und ragt
  beidseitig 7,7 mm hinaus, wie der Zierrand der Kästen. Mit der größeren Breite wächst die Höhe
  auf 50,5 bp, deshalb sind fünf Rastereinheiten die Voreinstellung und neun der einspaltige Fall.

Dazu neu: `\dsaKastentitel` für die Kastenüberschrift mit den 12 bp des Musterbogens. Die dort
genannte Titelgrundlinie von 5,16 mm unter der Oberkante gilt für die gezeichneten Kästen ohne
Zierrand; in den Grafikkästen beginnt der Inhalt bei `\dsakastenoben`.

### Was die Sichtprüfung am Abzug ergeben hat

Gemessene Zahlen finden nicht alles. Diese Fehler waren erst am gerenderten Abzug zu sehen:

| Befund | Ursache | Behoben |
|---|---|---|
| Kolumnentitel links 20 mm von der Zahl weg, rechts 4 mm | Vorbildlage übernommen, die zu unserem Satzspiegel nicht passt | bündig am Satzspiegel, beidseitig 24 mm von außen |
| Text im Porträtkasten lag in der oberen Zierleiste | 6 mm oberer Innenabstand für alle Kästen, gemessen brauchen die Wertekästen 6,2 bis 9,3 mm | je Kasten die gemessene Innenkante |
| Umfluss um das Medaillon rechteckig | `\parshape` mit gleichem Einzug für alle Zeilen | Einzug je Zeile nach dem Kreis |
| Breite Zeilen liefen rechts über das Pergament | die Zeilen nutzten die Kastenbreite, nicht den Kastenkörper | Textende an der Innenkante, 81,82 mm |
| Vorlesetext nur oben mit Zierleiste | das Gegenstück lag als `trenner-unten-breit` im Ordner, ungenutzt | beide Leisten |
| Seitenzahl auf blankem Pergament | die vierte Hintergrundvariante hat kein Feld dafür | Rotation über drei Varianten |
| Impressum und Inhalt mit Zahl und Titel | beides gehört dort nicht hin | `\dsaHintergrundOhneFeld`, Fußzeile leer |
| Inhaltsverzeichnis einspaltig | 166 mm Zeilen mit Punktführung | zweispaltig über `multicol` |
| Kapitelseiten ohne Bildrahmen | die Klasse konnte ihn nur mit Bild setzen | `\dsakapitelbild`, mit Bild oder als Platzhalter |
| Rückseite: Karte ganzseitig, Text dunkel darauf | es fehlte die Vorlage | Rückseiten-Karten-Paket, Aufbau am Vorbild vermessen |

### Die beiden Schlagschatten am Titel

Nachgebildet mit gestaffelten Lagen derselben Silhouette; die Rechnung dahinter steht in
`MASSE.md`. Gemessen am 600-ppi-Auszug von `beispiel/_schattentest.tex` — dieselbe Zeile auf
hellem und auf dunklem Grund, ohne Umschlagbild —, senkrechtes Profil unter der Unterkante der
Fläche, 732 Spalten:

| Abstand unter der Flächenkante | gemessene Deckung | Sollkurve |
|---|---|---|
| 0 bp | 0,79 | 0,75 |
| 4,36 bp (harte Kante des Schattens) | 0,69 | 0,75 |
| 6 bp | 0,32 | 0,56 |
| 8 bp | 0,09 | 0,16 |
| 9,4 bp (Ende des Ausklangs) | 0,04 | 0,00 |

Die Kurve sitzt an der richtigen Stelle, fällt aber steiler und läuft weiter aus als gerechnet.
Beides ist die Messung, nicht der Satz: der Schnitt läuft senkrecht, die Kante ist gekrümmt und
seitlich um 2,52 bp versetzt, und die Spaltenstreuung von ±0,26 an der Flanke zeigt genau das.
Der 50-Prozent-Punkt liegt im Median bei 5,8 bp gegen 6,9 bp rechnerisch.

Die Lagenzahl ist am selben Auszug entschieden: bei acht Lagen laufen Wellen durch den Saum des
Schriftschattens, bei sechzehn nicht mehr, zwischen sechzehn und vierundzwanzig ist kein
Unterschied zu sehen.

### Der Rand der Titelfläche, und der Schatten daneben

Anlass war der Eindruck, die graue Fläche um den Schriftzug sei klobig. Sie war es: gemessen an den
Umschlägen von *Ketten für die Ewigkeit* (US25324) und *Schrecken aus der Tiefe* (US25326), in
300 ppi quer durch die Buchstabenstämme geschnitten, liegt der Rand dort bei 0,23 bis 0,34 der
Versalhöhe, im PSD des Baukastens bei 0,29 — in dieser Klasse bei 0,46. Die 13 pt sind deshalb auf
die 8,4 pt des PSD zurückgesetzt; die Tabelle steht in `MASSE.md` unter „Der Titeleffekt“.

Beim selben Schnitt ist ein zweiter Befund aufgefallen, inzwischen behoben: der Schlagschatten der
Schrift stand zu weit weg und fiel zu steil.

Gemessen über die **Kreuzkorrelation** zwischen Schriftmaske und Dunkelheitsbild. Der Schatten ist
eine weichgezeichnete Kopie des Schriftzugs, also liegt das Maximum der Korrelation auf seinem
Versatz — anders als eine Messung der hellen und dunklen Zonen links und rechts des Stamms, die
Versatz und Weichzeichnung vermischt und deshalb in einer ersten Fassung dieses Abschnitts zu einem
falschen Ergebnis geführt hat.

| | dx | dy | Länge | je Versalhöhe | Winkel |
|---|---|---|---|---|---|
| *Ketten*, Zeile 1 | 5,5 pt | 5,8 pt | 8,0 pt | 0,270 | 133° |
| *Ketten*, Zeile 2 | 8,4 pt | 4,6 pt | 9,6 pt | 0,243 | 151° |
| *Schrecken*, Zeile 1 | 8,4 pt | 4,8 pt | 9,7 pt | 0,246 | 150° |
| Klasse mit den PSD-Werten | 8,6 pt | 13,0 pt | 15,6 pt | 0,315 | 124° |
| **Klasse jetzt**, 6,0 bp unter 150° | 12,0 pt | 6,7 pt | 13,8 pt | **0,278** | **151°** |

Die PSD-Werte lagen mit 0,315 der Versalhöhe rund ein Viertel über dem Verlag und mit 120° viel zu
steil: nach unten waren es 13,0 pt statt 4,6 bis 5,8 pt, und der Schatten las sich als zweite Zeile
unter der Schrift statt als Kante an ihrer Flanke. Mit 6,0 bp unter 150° und 6,8 bp Weichzeichnung
liegt die Klasse bei 0,278 und 151°. Alle drei Werte sind jetzt über `\dsaTitelSchattenWeg`,
`\dsaTitelSchattenWinkel` und `\dsaTitelSchattenWeich` stellbar; die Herleitung steht in
`MASSE.md` unter „Der Titeleffekt“.

### Die Lagenfolge bei mehreren Titelzeilen

Aufgefallen ist es erst, als der Rand der Fläche auf 8,4 pt schmaler wurde: unter der oberen Zeile
lief eine waagerechte Kante durch den Schatten. Ursache war die Zeichenfolge. Jede Zeile brachte
alle fünf Lagen mit, also legte sich die **Fläche der unteren Zeile über den Schriftschatten der
oberen**. Die Fläche reicht `\dsatitelrand` über ihre Tinte hinaus und greift bei engem
Zeilenabstand in die Nachbarzeile: bei 88 pt oben, 78 pt unten und Zeilenfaktor 0,9 gemessene
12,2 pt tiefer, als die Versalien der unteren Zeile beginnen.

Die Zeichenfolge der beiden Zeilen einfach zu tauschen hilft nicht — dann verdeckt die Fläche der
oberen Zeile die Oberkante der unteren Versalien, dieselben 12,2 pt. Gezeichnet wird deshalb in
**vier Stufen über alle Zeilen hinweg**: alle Flächenschatten, alle Flächen, alle Schriftschatten,
alle Lettern. Das ist auch das Ebenenmodell des PSD, wo „Rahmen“ eine Fläche unter dem ganzen
Titelblock ist.

Drei Stufen genügten nicht, und das war der zweite Anlauf: solange „Fläche samt ihrem Schatten“ als
*eine* Stufe galt, fiel der Schlagschatten der unteren Fläche auf die obere und legte ein dunkles,
geschupptes Band zwischen die Zeilen — dieselbe Kante, nur eine Lage tiefer. Jede Lage muss über
**alle** Zeilen gezogen sein, bevor die nächste beginnt.

Nachgewiesen am Helligkeitsprofil quer durch das Band, gemittelt über 218 letternfreie Spalten
eines 300-ppi-Auszugs von `beispiel/titel.tex`: der größte Sprung von Bildzeile zu Bildzeile fällt
von 11,0 auf 5,0 Helligkeitsstufen, und die Senke im Profil von 22 auf 29 — aus einer Kante wird
das weiche Auslaufen des Schriftschattens, das dort hingehört. Der Vergleich der Abzüge vor und
nach der Umstellung auf Stufen zeigt 2802 geänderte Pixel, alle in einem Band von 238,6 bis
243,7 mm Höhe, in der Silhouette der Buchstabenunterkanten der oberen Zeile.

### Die Farben des Covertitels

Anlass war ein Vergleich mit einem veröffentlichten Heft: dort ist der Titel rot, hier grau. Der
Vergleich geht aus, ohne dass an der grauen Fassung etwas zu ändern wäre — sie stimmt mit ihrer
Quelle überein. `Cover_Buchtitel.psd` mit `psd-tools` geöffnet: eine Gruppe, drei Ebenen, keine
farbige Alternative darin. Die vier Farben der Klasse sind die des PSD.

Die rote Fassung ist am Umschlag des Aufsteller-Sets (US25533PDF, Seite 1) abgetastet und steht
jetzt als `\dsaTitelRot` bereit; die Werte und die Methode stehen in `MASSE.md` unter „Der rote
Covertitel“. Gebaut wird sie im Umschlag von `beispiel/rest.tex`.

Der Status `!` steht für einen Unterschied, der bleibt und der nichts mit den Farben zu tun hat:
in der Vorlage wird die Fläche zur Schrift hin dunkler, von `#5F1812` an der Kante auf etwa
`#250600` neben den Buchstaben. Das ist der *Schein außen* des PSD (`341811`, 51 px), den die
Klasse nicht zeichnet. An der grauen Fassung fällt das nicht auf, an der roten steht die Schrift
dadurch flacher auf ihrer Fläche als in der Vorlage. Wer den Schein nachbaut, kann dieselbe
Lagenroutine wie für die Schlagschatten nehmen, mit Versatz null — und muss damit rechnen, dass
sich damit auch das Aussehen der grauen Voreinstellung ändert.

## Elemente mit eigenem Raster

Nicht jede Zeile gehört auf das Grundlinienraster der Seite. Diese Elemente weichen bewusst ab —
wer sie in einer Messung als Abweichung findet, hat nichts gefunden:

| Element | eigenes Maß | Grund |
|---|---|---|
| Impressum | Rubrik 24,0 pt, Wert 14,0 pt | gegen ein gesetztes Vorbild vermessen, ±0,04 mm |
| Kapiteltitel im Banner | Banner am Papierrand | sitzt über dem Satzspiegel |
| Seitenzahl | 13 bp in der Fußzeile | TikZ-Knoten an der Papierkante |
| Text in Kästen | 9,5 bp auf 11,4 bp | eigener Durchschuss im Kasten |
| Umschlagrückseite: Klappentext, Anforderungen, Zusammenfassung | 8 und 10 bp | freie Lage im Rahmen des Umschlags |
| Titelzeilen auf dem Umschlag | 42,8 bp, von der Papierkante gesetzt | freie Lage |

Das Querformat gehört **nicht** dazu: seine Zeilen sitzen auf demselben Raster, gerechnet ab der
Papierkante.

Alles andere gehört auf das Raster. Der Prüfbefehl dazu:

```sh
python3 werkzeuge/nachmessen.py <datei>.pdf --text \
  | awk '$2=="mm" && $4=="mm" && $10!="+0.00" {print $9, $10, $11}'
```

## Aufsteller (dsa5aufsteller.sty)

Eigenständiges Extra, kein Teil der Baukasten-Prüfung oben — die Maße kommen aus dem
Ulisses-Produkt „Aufsteller-Set für Das Schwarze Auge“ (US25533PDF), nicht aus dem Scriptorium-
Baukasten, und stehen deshalb auch nicht in `MASSE.md`. Geprüft wird hier nur, ob die eigene
Umsetzung tut, was sie soll.

| Prüfung | Ergebnis | Status |
|---|---|---|
| Kartenrahmen (Bogen oben, gerade Kante unten), vier Größenklassen S/M/L/XL | `beispiel/aufsteller.tex` gebaut und im PDF angesehen — Form, rote Linie, Namensstreifen wie vorgesehen | `ok` |
| Gemischter Bogen (S+M+L+XL auf einem Bogen) | zweiter Bogen in `beispiel/aufsteller.tex`, keine Überlappung, alle vier Klassen sichtbar | `ok` |
| **Duplex-Passung**, Formel `x' = Nutzbreite - x - Breite` | mit `werkzeuge/nachmessen.py` an `beispiel/aufsteller.pdf` (Seite 1↔2, Seite 3↔4) nachgerechnet, siehe Befund unten. Alle Treffer auf den Hundertstelmillimeter, y unverändert | `ok` |

Wichtig beim Bauen: wie jede TikZ-`remember picture`-Seite braucht ein Aufstellerbogen die vollen
drei `xelatex`-Durchläufe — nach nur einem Lauf ist `current page` in der Vorderseiten-Grafik noch
nicht aufgelöst, und die erste Seite bleibt sichtbar leer (beim ersten Testlauf hier tatsächlich so
aufgetreten, durch den dritten Lauf behoben).

### Befund: zwei Fehler in der ersten Fassung, beide beim Ansehen des PDF gefunden

1. **Größenklassen S/L/XL standen quer statt hochkant.** Ursache: die erste Fassung übernahm
   Breite/Höhe direkt aus der Kartenkontur auf dem Stanzbogen der Vorlage. Dort liegen S, L und XL
   aber gedreht — Platzersparnis beim Stanzen, erkennbar an der seitlich statt unten laufenden
   Beschriftung auf den Seiten 6/7 und 10-13 der Vorlage. Die fertig ausgeschnittene Karte steht
   danach hochkant, wie M. Behoben durch Vertauschen von Breite und Höhe bei S, L, XL (nicht bei
   M, die stand schon richtig).
2. **Die obere Rundung wirkte gestaucht.** Ursache: `\dsaAufstellerrundungx`/`...y` skalierten den
   gemessenen Radius anteilig an Breite bzw. Höhe der jeweiligen Karte. Weil die Klassen
   unterschiedliche Seitenverhältnisse haben, wuchsen x- und y-Anteil unterschiedlich stark
   auseinander — sichtbar elliptisch bei L und XL. Behoben durch ein festes Maß
   (`\dsaAufstellerRundungX/Y`, 10,34 × 9,06 mm, an der Vorlage gemessen) für alle Klassen
   gleich, nur bei der kleinen Klasse S über `min()` auf 0,45 der eigenen Kartenmaße gekappt.

Nach beiden Korrekturen erneut mit `nachmessen.py` an `beispiel/aufsteller.pdf` nachgerechnet:
Karte „Ork“ (M, x=15,00 mm): Rückseite bei x=166,46 mm — 180 mm (Nutzbreite) − 15 mm − 28,54 mm =
166,46 mm, exakt. „Drache“ (XL, x=15,00→118,95 mm): 180 − 0 − 76,05 = 103,95, plus 15 mm Rand =
118,95 mm, exakt. „Troll“ (L, x=100,00→61,41 mm): 180 − 85 − 48,59 = 46,41, plus 15 mm Rand =
61,41 mm, exakt.

## Battlemap mit Zollraster (`beispiel/battlemap.tex`)

Kein Element der Klasse, sondern ein eigenes Dokument mit eigenem Blattformat — geprüft wird
deshalb hier und nicht in der Statustabelle. Sollmaß ist der Zoll: 25,4 mm, und das sind 72 bp,
also genau sechs Rastereinheiten der Klasse.

Gemessen am Abzug, 100 ppi gerastert, Linien über die Spalten- und Zeilendichte gefunden
(`pdftoppm -r 100 -gray`, Schwelle 230 von 255, 40 Prozent der Blattkante):

| Blatt | Blattmaß im PDF | ganze Kästchen | Soll | Rand quer | Soll | Rand hoch | Soll |
|---|---|---|---|---|---|---|---|
| A4 quer | 297,2 × 210,1 mm | 11 × 8 | 11 × 8 | 8,64 / 9,14 mm | 8,80 mm | 3,30 / 3,56 mm | 3,40 mm |
| A3 quer | 420,1 × 297,2 mm | 16 × 11 | 16 × 11 | 6,60 / 6,86 mm | 6,80 mm | 8,64 / 9,14 mm | 8,80 mm |
| A2 quer | 594,1 × 420,1 mm | 23 × 16 | 23 × 16 | 4,83 / 5,08 mm | 4,90 mm | 6,60 / 6,86 mm | 6,80 mm |
| A1 quer | 841,2 × 594,1 mm | 33 × 23 | 33 × 23 | 1,27 / 1,78 mm | 1,40 mm | 4,83 / 5,08 mm | 4,90 mm |

Die Zahl ganzer Kästchen ist in jeder Richtung die Blattkante durch einen Zoll, abgerundet, und
der Rand die Hälfte dessen, was übrig bleibt. Beides trifft auf allen vier Blättern zu.

Der Linienabstand ist im Inhaltsstrom 72,001 bp, das Strichmuster `[4,50003 4,50003]` — ein
Sechzehntel Zoll Strich und Lücke, acht Striche je Kästchenkante. Die Ränder weichen um bis zu
0,15 mm vom Sollmaß ab, und das ist die Messauflösung: ein Pixel bei 100 ppi sind 0,25 mm, und der
Schwerpunkt einer Linie von 0,4 pt fällt zwischen zwei Pixel. Die beiden Werte je Feld sind die
gegenüberliegenden Ränder; dass sie sich um ein Pixel unterscheiden, ist dieselbe Auflösung.

Alle acht Kombinationen — A4, A3, A2 und A1, hoch und quer — bauen ohne eine LaTeX-Fehlermeldung,
und `pdfinfo` nennt für jede das erwartete DIN-Format. Die vier Blätter oben kommen aus derselben
Quelldatei: Blatt und Lage lassen sich beim Aufruf überschreiben.

```sh
TEXINPUTS="..;" xelatex -jobname=battlemap-a1 \
  "\def\dsablatt{a1}\def\dsalage{quer}\input{battlemap.tex}"
```

**Ein Fund beim Messen.** Zuerst saß in der Blattmitte immer eine Kreuzung. Bei einer ungeraden
Zahl ganzer Kästchen bleibt dann am Rand fast ein ganzes ungenutzt: auf A3 quer (11,69 Zoll hoch)
passten nur zehn Reihen aufs Blatt statt elf, gemessen 21,5 mm Rand oben und unten statt 8,8 mm.
Jetzt entscheidet die Parität der Kästchenzahl je Richtung, ob in der Mitte eine Kreuzung oder
eine Kästchenmitte liegt. Symmetrisch bleibt beides, und mehr als ein halbes Kästchen kann am
Rand nicht mehr verlorengehen.

**Zwei Fallen, die LaTeX nicht meldet.** `\newcommand*{\dsa@bm@a4}{…}` definiert `\dsa@bm@a` und
setzt die `4` in den Text — eine Ziffer ist kein Buchstabe; über `\@namedef` gebaut, darf der Name
Ziffern tragen. Und eine Zahl ohne Einheit ist in einer TikZ-Koordinate ein Vielfaches der
Achseneinheit: `0.5*\paperheight` wären dort 420 Zentimeter, nicht die halbe Blatthöhe. Beides
fiel erst am Abzug auf.

## Ersatzmodus und CI

Geprüft wurde, ob die Beispiele ohne Baukastenmaterial bauen und ob das Raster dabei dasselbe
bleibt. Dazu ein Klon ohne `grafiken/` (bis auf `titelbild.jpg`) und ohne `schriften/`, darin
`werkzeuge/platzhalter.py` und dann `DSA5_OPTIONEN=ersatz,entwurf latexmk <datei>`.

| Prüfung | Ergebnis |
|---|---|
| Platzhalter angelegt | 92, davon 91 aus der Sollmaßliste und einer für die Battlemap; `pruefen.py` meldet 91 von 91 in Ordnung |
| Alle acht Beispiele bauen | `beispiel` 22 Seiten wie mit echtem Material, `kaesten` 15, `rest` 5, `aufsteller` 4, `raster` 2, `battlemap`, `titel`, `titelgrafik` je 1 |
| `logpruefen.py` über alle acht Logs | in Ordnung |
| Grundlinien `raster.pdf`, Ersatz gegen echtes Material | alle 51 Zeilen auf 0,01 mm gleich |
| Fließtext 10 bp in `beispiel.pdf` neben dem Raster | nur, was auch mit echtem Material danebenliegt (Impressum mit eigenem Maß), dazu je Bildrahmen der Dateiname, den `entwurf` hineinschreibt |
| Schutz gegen gemischten Satz | `platzhalter.py` bricht im Arbeitsklon mit echtem Material ab („91 Dateien aus dem Baukasten“) |
| `logpruefen.py` schlägt an | eine eingefügte `Class dsa5latex Warning`, ein `Overfull \vbox` und „There were undefined references“ zählen je als Meldung, Rückgabewert 1 |

Dass das Raster gleich bleibt, ist kein Zufall: die Grundlinien hängen an `\baselineskip` und am
Satzspiegel, nicht an der Schrift. Zeilenfall und Satzbreiten sind mit Gentium dagegen andere,
darum prüft der Ersatzmodus sie nicht.

Offen: der erste Lauf der GitHub Action. Lokal geprüft ist nur, was oben steht.

## Vorgehen

Seriell von oben nach unten, je Block: `probeseiten.tex` bauen, mit `nachmessen.py` die Zahlen
holen, Abweichungen gegen die Quelle prüfen, korrigieren, neu bauen, nachmessen, Status hier
fortschreiben. Jede Korrektur mit Begründung in `MASSE.md`, wenn sie ein Maß betrifft, und in
`ELEMENTE.md`, wenn sie einen Aufruf ändert.
