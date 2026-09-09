# Prüfplan

*Was geprüft wird, woran gemessen wird, und was dabei herauskam.*

Die Klasse ist aus den Maßen des Layout-Baukastens gebaut. Ein Maß im Quelltext ist aber noch kein
Maß auf dem Papier: ein Kasten kann zwei Millimeter zu weit außen sitzen, ein Medaillon um seine
halbe Breite verschoben sein, ein Textblock neben seinem Rahmen liegen. Im PDF sieht man das als
„irgendwie schief", nicht als Zahl. Dieser Plan macht daraus Zahlen.

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
| Titel: Fläche, Rand, Verlauf | 13 pt / 0,24 pt / vier Haltepunkte | PSD, eigene Messung | `#` |
| Impressum: Überschrift, Rubriken, Vermerk | 37,6 mm / 14 pt / 94,5 mm | gesetzte Veröffentlichung | `#` |
| Seitenzahl | 18,4 mm von außen, 5,9 mm über der Kante, Andalus 13 pt | Musterbogen | `#` |
| Kolumnentitel (Kapitelname neben der Zahl) | Andalus 14 bp schwarz, Grundlinie wie die Zahl, rechts 24,29 mm und links 40,35 mm von der Außenkante | gesetzte Veröffentlichung | `#` |
| Kapiteltitel im Banner | erste Grundlinie 33,41 mm unter der Papierkante, linksbündig am inneren Rand | Musterbogen | `ok` |
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
| Werteabsatz, hängender Einzug | 8,50 pt | IDML, Format „Werte" | `ok` |
| Einführung, Stimmung, Zitat | Laufweite +10, Grau 404040 | IDML | — |
| Aufzählungen: Einzug | 17,01 pt = 6,0 mm hängend | IDML, „Aufzählung v2" | `ok` |
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
| Verlauf der Titelzeile | Tabellenrot nach Weiß über die ganze Breite | Farbfeld „Tabelle Überschrift" | `#` |
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
   25 Prozent Schwarz; im Export sind es `#D0D0D0`, weil „Black" im IDML CMYK ist und der
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

Vier Zeilen trugen noch „Abweichung gefunden". An den Abzügen nachgemessen:

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

## Der Einleger

Eigene Klasse, eigene Quelle: `dsa5einleger.cls`, gemessen am *Universal Spielleiterschirm
Einleger, Auflage 5*, Seiten 4 bis 6. Die Maße stehen in [MASSE.md](MASSE.md), Abschnitt 8, die
Anleitung in [EINLEGER.md](EINLEGER.md). Gemessen wurde am Regellauf `beispiel/einleger.pdf`.

| Prüfung | Sollmaß | Quelle | Status |
|---|---|---|---|
| Papierformat | 297 × 210 mm | Vorgabe A4 quer | `ok` |
| Spaltenkanten, alle acht | 31,18 / 217,06 / 229,06 / 414,95 / 426,94 / 612,83 / 624,83 / 810,71 bp | gerechnet aus Rand 31,181 bp und 12 bp Abstand | `ok` |
| Zeilenhöhe, einzeilig | 14,56 bp | Original, Tabelle „Regeneration“ | `#` |
| Kopfband, einzeilig | 14,56 bp hoch | dito | `ok` |
| Kopfband, zweizeilig | 25,36 bp hoch | 14,56 + 10,8 | `ok` |
| Grundschrift | 9,0 bp auf 10,8 bp | Original, alle Spans | `ok` |
| Quellenmarke: Höhe, Grundlinie, Innenluft | 8,79 / 1,85 / 3,8 bp | Original, Rechteck und Textlage | — |
| Farbe der Kopflinie | `#646363` | Original | — |
| Verlauf des Kopfbands über Pergament | links `#B47D62` | Original | — |
| Blöcke sitzen auf ihren Spalten | — | `spaltenzeigen` | — |
| Stimmungsbildseite: Bild randfüllend | 303 × 216 mm | Original, Seiten 1 bis 3 | `ok` |
| Stimmungsbild: Rahmen nur oben und unten | senkrechte Ränder ohne Leiste | Original, Ränder ausgeschnitten und angesehen | `#` |
| Stimmungsbild: deckender Zuschnitt statt Streckung | — | `\dsaBildDeckend` | `ok` |
| Umbau von `dsa5latex` bricht den Abenteuersatz nicht | Textlagen unverändert | Vergleich gegen die alten PDF | `ok` |
| Kästen der Abenteuerklasse im Querformat | — | ungeprüft, siehe MASSE.md „Was offen ist“ | — |

**Spaltenkanten, gemessen.** Über 322 waagerechte Linienkanten der drei Seiten des Regellaufs ist
die größte Abweichung von der Sollkante **0,20 bp**; der häufigste Wert ist 0,003 bp, und alle
außer einer Handvoll liegen unter 0,005 bp.

**Zeilenhöhe, Befund und Behebung.** Gemessen waren zunächst 14,684 statt 14,560 bp je Zeile,
gleichmäßig über alle Tabellen und alle Spaltentypen. Ursache: `array` rechnet
`Höhe = rraystretch × (0,7 × Durchschuss + \extrarowheight)`, die Zugabe wird also mit
gestreckt. Die Klasse hatte sie nach der Multiplikation gerechnet und bekam den gestreckten Anteil
doppelt — nach acht Zeilen ein Millimeter. Behoben mit `\extrarowheight = \dp\strutbox` und
`rraystretch = 1,037037`; nachgemessen liegt jede Zeile jetzt auf 14,5600 bp.

**Der Rahmen der Bildseiten, Befund und Behebung.** Die Klasse legte um eine Stimmungsbildseite
zuerst einen umlaufenden Rahmen. Das war aus einem 100-dpi-Abzug der Originalseiten geschlossen,
in dem die senkrechten Ränder dunkel wirkten — es war der dunkle Bildinhalt. Ausgeschnitten und
bei 300 dpi angesehen steht an beiden Rändern der Seiten 1 bis 3 Wiese und Wald bis zur
Papierkante, keine Leiste. Die Vorgabe ist jetzt der waagerechte Rahmen wie auf den
Tabellenseiten; `\dsaRahmenRundum` schaltet die seitlichen Leisten zu.

**Der Umbau von `dsa5latex`, gemessen.** Für den Einleger sind vier Bausteine der Abenteuerklasse
geöffnet worden, statt sie zu verdoppeln: `\dsa@tabellenband` bekam seine Maße in ein eigenes Makro
`\dsa@bandmasse`, und `L{}` bekam eine Tiefenstütze über die neue Länge `\dsazellstuetze`, die dort
0 pt ist. Beides ist im Abenteuersatz wirkungslos, und das ist nachgemessen: in `raster.pdf`
(2 Seiten), `kaesten.pdf` (15) und `rest.pdf` (5) liegt nach dem Umbau **jede** Textzeile auf
±0,0000 bp ihrer alten Stelle, bei gleicher Zahl und gleichem Inhalt der Spans. `beispiel.pdf` baut
weiter mit 21 Seiten ohne Fehlermeldung.

**Was hier nicht gilt.** Die Regel „jede Grundlinie auf 84 bp + k × 12 bp“ gilt für den Einleger
**nicht**. Er hat kein Grundlinienraster, und das ist am Original nachgewiesen: von 371
Grundlinien treffen gegen ein 12-bp-Raster 17. An seine Stelle tritt die Prüfung der
Spaltenkanten.

## Vorgehen

Seriell von oben nach unten, je Block: `probeseiten.tex` bauen, mit `nachmessen.py` die Zahlen
holen, Abweichungen gegen die Quelle prüfen, korrigieren, neu bauen, nachmessen, Status hier
fortschreiben. Jede Korrektur mit Begründung in `MASSE.md`, wenn sie ein Maß betrifft, und in
`ELEMENTE.md`, wenn sie einen Aufruf ändert.
