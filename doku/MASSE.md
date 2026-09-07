# Die Maße und woher sie kommen

*Ein Nachschlagewerk und ein Sicherheitsnetz. Wer ein Maß ändern will oder einem Wert nicht traut,
findet hier, woher er kommt — und muss nicht raten und nicht neu messen.*

---

## 1. Wie gemessen wurde

Drei Wege, die sich gegenseitig bestätigen. Wo sie einander widersprächen, gilt der Klartext.

**Weg 1 — der Klartext des Verlags.** Seite 2 des Baukasten-PDF nennt Satzspiegel, Grafikbereich,
Raster und Anschnitt in Worten. `Scriptorium Aventuris Lies mich zuerst v1.4.pdf` nennt die
Schriftenhierarchie. Das ist die verlässlichste Quelle, weil keine Messung dazwischensteht.

**Weg 2 — die Pixelmaße der Vorlagengrafiken.** Alle sind mit 300 ppi angelegt; Pixel geteilt durch
300, mal 25,4 ergibt das Produktionsmaß direkt aus der Datei. `werkzeuge/pruefen.py` hält diese
Werte maschinenlesbar und schlägt Alarm, wenn eine Datei abweicht.

**Weg 3 — die Rahmenmaße im InDesign-Dokument.** `Scriptorium Aventuris v4.idml` ist ein ZIP. Darin
steht zu jedem platzierten Bild der Rahmen — und entscheidend: `ActualPpi` und `EffectivePpi`. Sind
beide gleich, liegt das Bild auf **100 %** und der Rahmen ist das Produktionsmaß. Von 46 platzierten
Bildern erfüllen 27 das; die übrigen sind für den Musterbogen verkleinert und taugen nicht als
Beleg.

Weg 2 und Weg 3 stimmen bei allen auf 100 % platzierten Bildern überein. Beispiel:
`Kasten_Pergament_ver1` hat 1010 × 2272 px, das sind 85,5 × 192,4 mm — und genau so groß ist der
Rahmen im IDML.

---

## 2. Satzspiegel

Wortlaut, Baukasten Seite 2:

> Spalten: Zwei Spalten, 5 mm Abstand zueinander.
> Textbereich-Ränder: 20mm Rand-Abstand innen, 24mm außen, oben und unten.
> Grafikbereich-Ränder: 13mm Rand-Abstand innen und außen, 19,25mm unten, 12,75mm oben.
> Raster: 12pt. Grundlinienraster ab 12,7mm.
> Anschnitt: 3mm Anschnitt; fürs Scriptorium unerheblich.

| Größe | Wert |
|---|---|
| Papier | A4, 210 × 297 mm, Doppelseiten, Ränder gespiegelt |
| Rand innen | 20,00 mm |
| Rand außen | 24,00 mm |
| Rand oben und unten | 24,00 mm |
| Satzbreite | **166,00 mm** |
| Satzhöhe | 249,00 mm — in der Klasse **708 pt = 249,66 mm** |
| Spalten | 2, Steg **5,00 mm**, Spaltenbreite **80,50 mm** |
| Grafikbereich | **184 × 265 mm** (13 innen und außen, 12,75 oben, 19,25 unten) |
| Grundlinienraster | **12 pt**, erste Linie 12,7 mm unter der Oberkante |
| Zeilen je Spalte | **59** |
| Anschnitt | 3 mm angelegt, für PDF nicht genutzt |

**Die 0,66 mm Aufschlag auf die Satzhöhe sind Absicht.** 59 Grundlinien brauchen
12 pt + 58 × 12 pt = 708 pt. Ohne den Aufschlag geht eine Zeile je Spalte verloren, und 59 ist der
Wert, mit dem die offiziellen Bände gesetzt sind. Der untere Rand wird dadurch 23,34 statt
24,00 mm.

**Der Grafikbereich ist der zweite Rahmen** und erklärt die Kastenmaße: der Text sitzt in 166 mm,
Grafiken dürfen 184 mm nehmen. Die Pergamentkästen mit 85,5 mm liegen dazwischen — sie ragen über
die Textspalte hinaus, aber nicht über den Grafikbereich.

### Das Raster ist nicht Zierde

Der Baukasten begründet es im eigenen Beispieltext:

> Wir verwenden bei DSA ein Grundlinienraster [...] Ja, klar, das schränkt einen ein bisschen ein
> bzw. fordert etwas mehr Fingerspitzengefühl, aber es führt auch dazu, dass die Textzeilen bei
> zwei Spalten immer auf einer Höhe sind und das sieht so viel ordentlicher aus.

Und es wird eingehalten. Am Baukasten-PDF nachgemessen — Textpositionen aus dem Inhaltsstrom —
liegen alle Grundlinien auf 36 + 12·k Punkt unter der Oberkante, gemessen etwa 84,00 / 168,00 /
300,00 / 540,00 pt. Die Abstände zwischen Absätzen und Überschriften sind ausschließlich 12, 24, 36
oder 72 pt. Kein einzelner Wert fällt heraus; nur eine freistehende Überschrift sitzt daneben
(94,71 pt). Überschriften dürfen also aus dem Raster treten, Fließtext nicht.

---

## 3. Typografie

Wortlaut, `Scriptorium Aventuris Lies mich zuerst v1.4.pdf`:

> Unser Fließtext: Gentium Basic, 10 pt.
> Kapitelüberschrift: Andalus, 23,5 pt. · Unterkapitel: Andalus, 14 pt.
> Abschnittsüberschrift: Gentium Basic, Fett, 13 pt. · Unterabschnitt: Gentium Basic, Fett, 10 pt.

| Ebene | Schrift | Ausrichtung |
|---|---|---|
| Fließtext | Gentium Basic 10 pt auf 12 pt | Blocksatz |
| Kapitel | Andalus 23,5 pt | Versalien, im Banner |
| Unterkapitel | Andalus 14 pt | **zentriert**, 12 pt Abstand danach |
| Abschnitt | Gentium Basic fett 13 pt | linksbündig |
| Unterabschnitt | Gentium Basic fett 10 pt | linksbündig |
| Covertitel | Andalus 28 pt fett | zentriert |

Trennung laut IDML: Wörter ab 5 Zeichen, mindestens 2 nach dem Anfang und 2 vor dem Ende, auch
Großgeschriebenes.

**Zwei Eigenheiten der Schriften.** Andalus hat nur einen Schnitt — Fett und Kursiv rechnet XeLaTeX
daraus selbst. Und **keine** der fünf Dateien hat das OpenType-Feature `smcp`, echte Kapitälchen
gibt es also nicht; `\dsaKapitaelchen` bildet sie nach.

---

## 4. Farben

Aus `Resources/Graphic.xml` des IDML, unverändert.

| Name in der Klasse | Baukasten | Wert |
|---|---|---|
| `dsatabellenrot` | Tabellenrot | RGB 193 144 123 = `#C1907B` |
| `dsadunkelrot` | dunkles rot | CMYK 51 91 81 6 |
| `dsadunkelblau` | dunkle Blau | CMYK 75 53 10 2 |
| `dsagruenverlauf` | Grün für gradient | CMYK 70 53 91 17 |
| `dsapergamentgelb` | Für Gelb | CMYK 9 26 56 9 |
| `dsawesenzug` | Wesenzüge Lokal | CMYK 64 17 82 13 |
| `dsatuerkis` | Word_R0_G176_B240 | RGB 0 176 240 |
| `dsaprofession` | professionspaket | LAB 50,6 / 21 / 43, umgerechnet zu RGB 170 105 46 |

---

## 5. Produktionsmaße der Grafiken

Pixel geteilt durch 300 ppi. Die Spalte „Raster" ist die Zahl der Rastereinheiten von 12 pt, die
der Kasten senkrecht belegt — aufgerundet, damit der Text darunter wieder auf der Grundlinie sitzt.
„Rest" ist die dabei unten leer bleibende Differenz; sie ist unsichtbar, weil dort der
Seitenhintergrund durchscheint.

### Pergamentkästen

| Datei | px | mm | Raster | Rest |
|---|---|---|---:|---:|
| `pergament-klein` | 1010 × 599 | 85,5 × 50,7 | 12 | +0,08 |
| `pergament-mittel` | 1010 × 1175 | 85,5 × 99,5 | 24 | +2,10 |
| `pergament-lang` | 1010 × 2272 | 85,5 × 192,4 | 46 | +2,35 |
| `pergament-breit` | 1617 × 2272 | 136,9 × 192,4 | 46 | +2,35 |
| `pergament-schmal` | 577 × 2272 | 48,9 × 192,4 | 46 | +2,35 |

Die drei Spaltenkästen sind **alle 85,5 mm breit** bei 80,5 mm Spaltenbreite: 2,5 mm Überstand je
Seite. Keine Nachlässigkeit, sondern Gestaltung.

### Wertekästen

| Datei | px | mm | Raster | Rest |
|---|---|---|---:|---:|
| `werte-klein` | 997 × 647 | 84,4 × 54,8 | 13 | +0,23 |
| `werte-mittel` | 1026 × 1226 | 86,9 × 103,8 | 25 | +2,03 |
| `werte-gross` | 1004 × 2328 | 85,0 × 197,1 | 47 | +1,89 |
| `werte-klein-portrait` | 1110 × 699 | 94,0 × 59,2 | 14 | +0,07 |
| `werte-mittel-portrait` | 1110 × 1228 | 94,0 × 104,0 | 25 | +1,83 |
| `werte-gross-portrait` | 1110 × 2351 | 94,0 × 199,1 | 47 | −0,11 |

Die Porträtvarianten sind **alle 94,0 mm** breit; die Differenz von rund 8 mm zu den anderen ist das
Medaillon, das seitlich heraustritt. Wer die Grafik auf Spaltenbreite zwingt, drückt es hinein.

### Graue Kästen

| Datei | px | mm | Raster |
|---|---|---|---:|
| `meister-schmal` | 707 × 1349 | **59,9 × 114,2** | 27 |
| `meister-breit` | 2101 × 1349 | 177,9 × 114,2 | 27 |
| `meister-maske` | 992 × 1276 | 84,0 × 108,0 | 26 |
| `meister-maske-klein` | 992 × 532 | 84,0 × 45,0 | 11 |
| `kastenfeld-schwarz` | 4093 × 1349 | 346,5 × 114,2 | — |

**`meister-schmal` ist hochkant**, 59,9 mm breit bei 114,2 mm Höhe. `meister-breit` ist mit
177,9 mm breiter als die Satzbreite von 166 mm und ragt je Seite 5,95 mm hinaus.

### Meistermasken

Der Baukasten liefert sie **mit** gestrichelter Verbindung, in drei Höhen.

| Datei | px | mm | Raster |
|---|---|---|---:|
| `meistermaske-1` | 578 × 460 | 48,9 × 38,9 | 9 |
| `meistermaske-2` | 578 × 777 | 48,9 × 65,8 | 16 |
| `meistermaske-3` | 578 × 1139 | 48,9 × 96,4 | 23 |
| `maske` | 236 × 143 | 20,0 × 12,1 | — |

### Zierleisten, Banner, Umschlag

| Datei | px | mm |
|---|---|---|
| `trenner-oben` | 624 × 116 | 52,8 × 9,8 |
| `trenner-unten` | 624 × 116 | 52,8 × 9,8 |
| `trenner-unten-breit` | 1872 × 348 | 158,5 × 29,5 |
| `vorlesetext` | 1872 × 348 | 158,5 × 29,5 |
| `nsc-kopf` | 1872 × 348 | 158,5 × 29,5 |
| `kapitelbanner` | 2481 × 510 | 210,1 × 43,2 |
| `zierrahmen-einfach` | 815 × 815 | 69,0 × 69,0 |
| `ornament-links` | 815 × 815 | 69,0 × 69,0 |
| `ornament-rechts` | 815 × 815 | 69,0 × 69,0 |
| `ornament-mittig` | 206 × 964 | 17,4 × 81,6 |
| `portraitrahmen` | 418 × 413 | 35,4 × 35,0 |
| `umschlag-vorne` | 2551 × 3579 | **216,0 × 303,0** |
| `umschlag-hinten` | 2480 × 3508 | 210,0 × 297,0 |

**Der Anschnitt ist belegt:** `umschlag-vorne` mit 216,0 × 303,0 mm ist genau A4 plus 3 mm auf
jeder Seite.

**Drei Dateien sind unklar.** `trenner-unten-breit`, `nsc-kopf` und `vorlesetext` sind pixelgleich
(1872 × 348), also 158,5 × 29,5 mm — aber im Musterbogen liegen alle drei bei 60 %, also 95,9 mm.
158,5 mm passt weder zur Spalte (80,5) noch zur Satzbreite (166) noch zum breiten Kasten (136,9).
Wahrscheinlich absichtlich überzählig angelegt und nach Bedarf skaliert. **Offen.**

### Marken

| Datei | px | mm |
|---|---|---|
| `fiole` | 107 × 107 | **9,1 × 9,1** |
| `totenkopf` | 107 × 107 | **9,1 × 9,1** |
| `fokusregel` | 1250 × 893 | 105,8 × 75,6 — im IDML bei **9,9 mm** platziert |
| `aufzaehlung` | 257 × 139 | 21,8 × 11,8 |
| `aufzaehlung-blau` | 235 × 259 | 19,9 × 21,9 |
| `aufzaehlung-rot` | 238 × 264 | 20,2 × 22,4 |
| `auge-schwarz` | 3122 × 1701 | 264,3 × 144,0 — absichtlich groß angelegt |
| `auge-weiss` | 6246 × 3402 | 528,8 × 288,0 — dito |
| `icon-bauer` | 304 × 384 | 25,7 × 32,5 |
| `icon-springer` | 414 × 567 | 35,1 × 48,0 |
| `icon-turm` | 414 × 567 | 35,1 × 48,0 |
| `icon-koenig` | 391 × 696 | 33,1 × 58,9 |

Fiole und Totenkopf sind mit 9,1 mm eindeutig belegt: Pixelmaß und IDML-Rahmen stimmen auf 100 %.
Bei Auge und Aufzählungszeichen ist die **Sollgröße offen** — sie sitzen im IDML als verankerte
Objekte im Text und haben kein eigenes Rahmenmaß.

### Abgeleitetes

| Datei | px | mm | wie |
|---|---|---|---|
| `seite-links-0..3` | 2516 × 3579 | 213,0 × 303,0 | linke Hälfte der vier Doppelseiten |
| `seite-rechts-0..3` | 2516 × 3579 | 213,0 × 303,0 | rechte Hälfte |
| `kapitelstart-pergament` | 1290 × 3543 | 109,2 × 300,0 | Ebene aus der Kapitelstart-PSD |
| `kapitelstart-ornament` | 1290 × 3543 | 109,2 × 300,0 | dito, deckungsgleich |

Eine Doppelseite ist 5032 × 3579 px = 426,0 × 303,0 mm: zwei A4-Seiten plus 3 mm Anschnitt an den
Außenkanten. Der Schnitt in der Mitte ergibt zwei Seiten mit Anschnitt an drei Kanten und keinem am
Bund — genau richtig für eine Einzelseite. **Es gibt vier Doppelseiten**, die Klasse rotiert über
alle vier.

---

## 6. Zur älteren LaTeX-Vorlage

Vor diesem Projekt gab es **DSaTeX** von Lukas Ester, die erste LaTeX-Vorlage für DSA5 im
Scriptorium. Diese Klasse teilt mit ihr keine Zeile Code, aber der Vergleich mit ihr hat die Maße
oben überhaupt erst hervorgebracht. Wer DSaTeX benutzt und behalten will, findet hier die Punkte,
die sich zu korrigieren lohnen.

**Die Grafiken dort sind echt** — pixelidentisch mit dem Baukasten, geprüft über die PNG-Kopfdaten.
**Die Maße nicht.** Die Klasse platziert alles relativ zu `\textwidth` und `\paperwidth` statt in
Produktionsgröße. Das ist die gemeinsame Ursache der meisten Abweichungen, und es heißt auch, dass
das Ergebnis von der Installation abhängt und auf zwei Rechnern verschieden aussieht.

Die schwersten Befunde:

1. **Keine Sprachunterstützung.** Weder `babel` noch `polyglossia` — deutscher Text wird nach
   englischen Mustern getrennt. Bei 80,5 mm Spaltenbreite im Blocksatz auf jeder Seite sichtbar.
2. **Der graue Meisterkasten** ist hochkant (59,9 × 114,2 mm), wird aber auf Spaltenbreite bei
   textabhängiger Höhe gezogen — eine Streckung um etwa Faktor sieben.
3. **`watermark stretch=1`** in allen sieben Kästen bricht die Proportionen.
4. **Kapitelbild und Freistellmaske** sind 22 % gegeneinander verschoben; die Maske deckt Bildrand
   mit ab.
5. **Die zweite Spalte läuft hinter das Kapitelbanner.** Das Banner ist ein TikZ-Overlay ohne
   Platzbedarf, der `\vspace` danach wirkt nur in der Spalte, in der er steht.
6. **Der Seitenhintergrund fehlt auf den ersten Seiten.** `\AddToShipoutPictureBG*` steht
   verschachtelt in `\backgroundsetup{contents}`, also doppelt und einen Takt zu spät; dazu setzt
   die Titelseite den Seitenzähler zurück.
7. **Die Option `HQ` wirkt nur zur Hälfte** — `\ProcessOptions` steht vor `\ExecuteOptions{LQ}`,
   der LQ-Block läuft danach noch einmal und setzt die Kästen zurück.
8. **`\Fiole` ist falsch deklariert**, die Argumentangabe steht innerhalb der Klammern des Namens.
9. Kapitelbanner 10 % über das Papier hinaus, Kapitelschrift 31,7 statt 23,5 pt, Zierrahmen 8,7 %
   zu klein, Fiole und Totenkopf 43 % zu groß, Fokusregel 102 % zu groß, Spaltensteg 3,53 statt
   5,00 mm, keine Farbfelder, kein Grundlinienraster.

Befunde 5 und 6 stammen aus dem Käuferfeedback im Scriptorium, nicht aus dem Quelltext — sie fallen
beim Lesen nicht auf, beim Setzen sofort.

---

## 7. Was offen ist

1. Sollgröße von Auge und Aufzählungszeichen — im IDML verankerte Objekte ohne Rahmenmaß.
2. Sollgröße der drei 158,5-mm-Leisten, siehe Abschnitt 5.
3. Genaue Lage der Zierrahmen auf der Seite.
4. Innenabstand des Textes in den Kästen. In der Klasse als `\dsakasteninnen` und
   `\dsakastenoben` geschätzt, an einer Stelle änderbar.
5. Breite des sichtbaren Pergamentrands am Kapitelbild, als `\dsakapitelbildrand` geschätzt.
6. Lage und Durchmesser des Porträtmedaillons.
7. Die Form des Umflusses um freigestellte Grafiken ist an einem gesetzten
   Scriptorium-Abenteuer gemessen, nicht an einem Verlagsband. Die Konturform ist übertragbar, die
   absoluten Werte nicht.
