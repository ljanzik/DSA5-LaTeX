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
| Covertitel | Andalus 42,8 pt fett | zentriert, aus dem PSD |
| Titel im Impressum | Andalus 23,5 pt | Versalien, zentriert |
| Rubrik im Impressum | Gentium Basic fett 14 pt | zentriert |
| Wert im Impressum | Gentium Basic 10 pt | zentriert |

Trennung laut IDML: Wörter ab 5 Zeichen, mindestens 2 nach dem Anfang und 2 vor dem Ende, auch
Großgeschriebenes.

Der Covertitel stand vorher mit 28 pt hier — das ist der Wert der Formatvorlage „DSA Cover
Vordergrund" aus der Wordvorlage. Der gesetzte Umschlag sagt etwas anderes: die Textebene
*Abenteuertitel* in `Cover_Buchtitel.psd` trägt `FontSize 75` bei einer Ebenentransformation von
2,3776, also 178,3 px, und `Leading 90`, also 213,3 px. Bei 300 ppi sind das **42,8 pt Schriftgrad**
und **51,4 pt Zeilenabstand**. Die Grundlinie liegt 401 px über der unteren Beschnittkante, nach
Abzug der 3 mm Beschnitt also **31,3 mm über der Papierkante**.

### Der Titeleffekt

Vier Effekte liegen im PSD auf der Titelebene, ein fünfter auf der Ebene *Rahmen* darunter:

| Lage | PSD | in der Klasse |
|---|---|---|
| Fläche „Rahmen" | Block mit harter Kante, 35 px um die Textbox, `2E2832` | Silhouette der Schrift, 13 pt Abstand |
| Schlagschatten der Fläche | 21 px Abstand, 21 px Weichzeichnung, 75 % | **nicht enthalten** |
| Schlagschatten der Schrift | 31 px Abstand, 18 px Weichzeichnung, 63 % | **nicht enthalten** |
| Kontur | 3 px, Verlauf `A6A6A6` nach `2B2630` | 0,24 pt in `A6A6A6`, einfarbig |
| Verlauf in der Schrift | senkrecht `C5B8CE` nach `28232D`, 42 % Skalierung | Schattierung mit vier Haltepunkten, vom Schriftzug maskiert |

Beide Schlagschatten sind im PSD weichgezeichnet und teildeckend. Ohne Weichzeichnung nachgebildet
bleibt von ihnen ein zweiter, versetzter Schriftzug, der den hellen Rand auf zwei Seiten überdeckt
und selbst wie die Umrandung wirkt. Sie sind deshalb nicht enthalten.

Die Fläche ist im PSD ein Block, hier eine Silhouette: der Block müsste für jeden Titel neu
gezeichnet werden, die Silhouette passt sich an. 13 pt statt der 35 px des PSD, damit die Flächen
zweier Zeilen ineinanderlaufen — bei 42,8 pt Zeilenabstand und rund 31 pt hoher Tinte bleiben
11,8 pt Luft, in denen sich zwei Ränder von je 13 pt um 14 pt überlappen.

**Warum der Rand ausfranst, und was dagegen hilft.** `\contour` setzt seine Kopien auf einem
*Kreisumfang* vom Radius R, nicht in der Fläche. Bei R = 8,4 pt und 24 Kopien liegen zwei
Nachbarkopien 2π·R/24 = 2,2 mm auseinander — wo ein Buchstabenzug schmaler ist als dieser Abstand,
überlappen die Kopien nicht mehr und der Rand wird zur Perlenschnur. Die Kopienzahl hängt deshalb
am Radius: `ceil(2π·R / \dsatitelperlabstand)` mit 0,6 pt, bei 13 pt Radius also 137 Kopien. Nur
die äußerste Lage braucht das; die inneren füllen die Lücke zwischen Kopienring und Schrift und
bleiben bei `\dsatitelkopieninnen` = 16.

**Und warum die Fläche einen Versatz braucht.** Sie folgt der Tinte, und Oberlängen reichen weiter
nach oben, als die Grundlinie nach unten reicht. Gemessen am gerasterten Titel, Fläche über ihre
Farbe und Schrift über ihre Helligkeit getrennt:

| Versatz | Rand oben | Rand unten |
|---|---|---|
| 0 pt | 18,72 pt | 6,00 pt |
| 6 pt | 12,72 pt | 12,00 pt |
| **6,4 pt** | **12,24 pt** | **12,24 pt** |

Der Wert hängt am Text: Zeilen mit Unterlängen brauchen weniger, Versalien mehr.

**Zwei Fallen dabei**, beide gekostet haben sie einen halben Tag:

`\pgfdeclarefading` nimmt den Namen des Fadings **unexpandiert**, `path fading=` expandiert ihn.
Ein Zählermakro im Namen lässt die Referenz deshalb ins Leere greifen — ohne Fehlermeldung, und pgf
benutzt still das zuletzt gesetzte Fading. Der Name muss mit `\edef` ausgeschrieben werden, bevor er
in die Zeichenroutine geht. Und: `fit fading=false` ist Pflicht, sonst zieht pgf das Fading auf die
Pfadbox und der Verlauf sitzt schräg im Schriftzug.

TikZ-Knoten sind **transformationsinvariant**: ein `shift` am umgebenden `scope` verschiebt sie
nicht. Jeder Versatz muss in die Ankerkoordinate, `([shift={(dx,dy)}]knoten.center)`.

### Das Impressum

Vermessen an einer gesetzten Veröffentlichung mit `pdftotext -bbox-layout`, die Schriftgrade über
den Vergleich der Zeilenbreiten mit denselben Zeichenketten:

| Mass | Sollwert | erreicht |
|---|---|---|
| Grundlinie der Überschrift | 37,6 mm unter der Papieroberkante | 37,58 mm |
| Grundlinie der ersten Rubrik | 47,2 mm | 47,25 mm |
| Grundlinie Rubrik → Wert | 12,8 pt | 12,82 pt |
| Grundlinie Wert → nächste Rubrik | 25,1 pt | 25,04 pt |
| Blockbreite des Rechtevermerks | 94,5 mm | 93,2 mm (Umbruch) |
| Zeilenabstand im Vermerk | 11,5 pt, Absätze 23,2 pt | 11,6 und 23,1 pt |

Zentriert wird auf die **Papiermitte**, nicht auf die Mitte des Satzspiegels: der liegt bei innen
20 mm und außen 24 mm um 2 mm daneben. `\centering` allein kann das nicht, weil es keinen Versatz
kennt — `\leftskip` und `\rightskip` tragen den Versatz als festen und die Zentrierung als
dehnbaren Anteil. `\parfillskip` muss dabei 0 pt bleiben; mit einem `fil`-Anteil stehen bei
einzeiligen Absätzen rechts zwei dehnbare Anteile gegen einen links, und die Zeile rutscht nach
links.

### Laufzeit

Ein Lauf mit Umschlag dauert knapp eine Minute. Das sind **nicht** die Textabzüge des Titels: der
Versuch, sie durch einen einzigen Konturstrich zu ersetzen, brachte 59 auf 59 Sekunden. Es sind die
Seitenhintergründe — 7 bis 8 MB je Seite, und jeder Lauf bettet sie neu ein. Die Klassenoption
`ohnehintergrund` lässt sie weg und bringt den Lauf auf 6 bis 8 Sekunden, das PDF von 19 auf 4 MB.
`entwurf` ersetzt darüber hinaus alle Grafiken durch Rahmen.

Der Konturstrich selbst wäre der elegantere Weg gewesen: PDF kann Text stricheln
(Textrendermodus 2), und unter XeLaTeX geht das über ein dvipdfmx-Special — `pdfrender` kann es
nicht, es braucht pdfTeX. Für den feinen hellen Rand funktioniert es auch. Für die 13 pt breite
Fläche nicht: bei dieser Strichbreite zeichnet der Renderer nichts mehr. Deshalb bleibt es bei
`\contour`. Zwei Fallen dabei, für den Fall, dass es jemand erneut versucht: die Strichbreite `w`
gilt im Textraum, eine Einheit ist Grad/1000 Punkt, und der Strich liegt mittig auf der
Glyphenkante — für einen Außenrand braucht es die doppelte Breite.

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

## Die Rautenskala

Der Baukasten liefert acht fertige Skalen — `DSA5_Rauten_rot_1` bis `_4` und `DSA5_Rauten_gruen_1`
bis `_4`, je 860 × 259 Pixel und damit 72,81 × 21,93 mm bei 300 ppi. Jede zeigt vier Rauten in
einer Reihe, davon n gefüllt und der Rest grau.

Gemessen liegen die vier Rauten bei x 1–204, 216–419, 431–634 und 647–850 Pixel, jede 204 Pixel
breit, senkrecht von 12 bis 247. Die Teilung ist damit 215 Pixel.

`aufbereiten.py` schneidet daraus drei Kacheln — eine gefüllte rote, eine gefüllte grüne und eine
graue, jede eine Raute samt ihrem Anteil am Zwischenraum. `\dsaRauten` setzt sie aneinander, so
viele gefüllte wie verlangt. Damit ist die Skala beliebig lang, und **nichts ist nachgezeichnet**;
vorher zeichnete die Klasse die Rauten in TikZ nach, obwohl das Material vorliegt.

Zwei Fallen dabei: `\dimen@` und `\@tempcnta` sind Kratzregister, die in einer `tabular` schon
belegt sind. Damit kamen die Kacheln mit 0,35 statt 3,75 mm heraus, und die Tabellenzeilen landeten
bei y 346 bis 624 mm — weit unter dem Papier. Die Skala nimmt deshalb eigene Register.

## Der Zierrahmen des Kapitelanfangs

Aus dem Baukasten kommt an dieser Stelle nur die Ebene „Pergament für Bild" — eine vollflächige
Textur, auf die das Bild eingerückt gelegt wird. Am Abzug ist das falsch: gesucht ist der
Zierrahmen, in den das Bild hineinkommt. Den gibt es als fertige Datei `DSA5-Kapitelstart.png` im
Zusatzordner.

Gemessen bei 300 ppi, 109,22 × 299,97 mm:

| Teil | Lage in der Datei |
|---|---|
| linker Schenkel | 3,13 bis 6,60 mm |
| rechter Schenkel | 93,13 bis 97,03 mm |
| Kante oben | 0,00 bis 0,17 mm |
| Ornament unten | 267,80 bis 286,51 mm |
| Innenfenster | 6,60 bis 93,13 mm waagerecht, 0,17 bis 267,80 mm senkrecht |

Das Fenster ist damit 86,53 × 267,63 mm. Die Datei ist breiter als ihre Deckung, deshalb wird sie
nach außen versetzt — rechts um 109,22 − 97,03 = 12,19 mm, links um 3,13 mm. So liegt der äußere
Schenkel im Anschnitt und der innere bleibt sichtbar.

Der Rahmen liegt ganz auf der Seite: die Datei ist auf 80,50 / 96,60 = 0,8333 verkleinert, also auf
91,02 × 249,97 mm, ihre Deckung damit 80,50 × 238,83 mm. Gemessen sitzt er von x 105,14 bis
196,16 mm und y 24,07 bis 274,05 mm. Das Vorbild setzt sein Kapitelbild dagegen randabfallend —
103,33 × 283,62 mm bis 0,2 mm an die Papierkante.

### Die Freistellung des Pergaments

`kapitelstart-pergament` ist ein freigestelltes Blatt. Im Alphakanal gemessen, bei 109,22 ×
299,97 mm:

| Kante | Lage |
|---|---|
| unten | schwankt von 262,97 bis 280,75 mm — 17,78 mm Streuung |
| oben | 0,25 bis 6,69 mm |
| seitlich | 3,56 bis 95,59 mm in der Bildmitte |

Als Füllung eines Rechteckfensters taugt das nicht: `\dsaBildDeckend` rechnet mit der Dateigröße,
nicht mit der Deckung, und dann endet das Blatt sichtbar vor dem Fensterrand. `aufbereiten.py`
schneidet deshalb `kapitelstart-flaeche` heraus — x 5 bis 94 mm, y 8 bis 261 mm, also 88,98 ×
252,98 mm reine Textur, voll deckend.

Dieselbe Kante lässt sich umgekehrt als Maske benutzen: `werkzeuge/freistellen.py` überträgt den
Alphakanal einer Vorlage auf ein eigenes Bild.

## Die Rückseite

Gemessen an der Rückseite einer gesetzten Veröffentlichung:

| Maß | Wert |
|---|---|
| Titel | Andalus 18 bp, x 27,65 mm, Grundlinie 57,6 mm |
| Autorzeile | Gentium 12 bp, Grundlinie 62,0 mm |
| Strich darunter | 65 mm lang, 0,53 mm stark |
| Klappentext | Gentium 12 bp auf 15 bp, Blocksatz, 81,7 mm breit, erste Grundlinie 97,9 mm |
| Absatzabstand im Klappentext | 2,83 mm |
| grauer Kasten, Text | ab x 76,3 mm |
| Kopfzeilen | Gentium fett 12 bp, zentriert, Grundlinien 208,8 und 213,6 mm |
| Rubriken | 9 bp, Grundlinien ab 220,4 mm im Abstand von 3,67 mm |
| Fertigkeiten | 9 bp, ab 258,1 mm |
| Kastenfarbe | rund (160, 157, 154), also A09D9A |

Der Kasten ist im PDF des Vorbilds kein Rechteck, sondern gerastert — die Farbe ist deshalb am
gerenderten Bild abgelesen. Blocksatz verträgt die Breite nicht: bei 55 mm wurde
„Komplexität (Spieler/Meister)" gesperrt und trotzdem getrennt, deshalb linksbündig.

Die Grafiken kommen aus dem Rückseiten-Karten-Paket, einem zweiten Paket neben dem Baukasten. Die
28 Regionalfassungen sind **Masken**, keine fertigen Seiten: jede ist die verdunkelte Karte auf
einer A4-Fläche bei 300 ppi, mit einem Loch an der Stelle einer Region. Bei
`Aventurien_Mittelreich.png` sind 2,3 Prozent der Fläche transparent, und sie liegen mitten in der
Karte — von 126,5 bis 194,8 mm waagerecht und 80,2 bis 124,2 mm senkrecht.

Über die neutrale Rückseite gelegt, in der die Karte hell und farbig ist, bleibt die Region hell und
der Rest tritt zurück. `werkzeuge/aufbereiten.py` setzt beides zusammen und speichert das Ergebnis
als JPEG: 1,7 statt 11 MB je Datei.

Wer die Maske stattdessen auf weiß flachlegt, bekommt kein hervorgehobenes Gebiet, sondern ein
weißes Loch in der Karte. Genau das war hier zuerst der Fall.

### Was die Arbeitsdatei hergibt

`Karte_mit_Grenzen_Paket.pdn` ist eine Paint.NET-Datei mit zwei Ebenen: der verdunkelten Karte und
einem Netz aus Regionsgrenzen (0,6 Prozent der Fläche, also feine Linien). Dieselben Ebenen liegen
als `KarteVerdunkelt.png` und `Grenzen.png` daneben. Daraus lässt sich eine eigene Maske schneiden —
`werkzeuge/regionsmaske.py` tut das per Flutfüllung.

Die Grenze des Verfahrens ist die Grenzebene selbst: sie kennt die großen Regionen, nicht die
Provinzen darin. Eine Saat im Kosch flutet das ganze Mittelreich (128 bis 193 mm waagerecht, 80 bis
124 mm senkrecht), unabhängig davon, ab welcher Deckung man eine Linie als Linie zählt. Der Kosch
liegt im Vorbild bei 143 bis 153 mm und 96 bis 112 mm — ein Zehntel davon. Er ist dort von Hand
geschnitten, und die fertige Datei `DSA5-Aventurienkarte_Kosch.png` liegt im Zusatzordner.

## Der Innenraum der Kästen

Ein Kasten des Baukastens ist eine Grafik mit gezeichnetem Zierrand. Wie breit dieser Rand ist,
steht nirgends — und wer den Text zu weit nach oben setzt, schreibt in das Ornament. Genau das war
am Abzug zu sehen: im Porträtkasten lag die erste Zeile mitten in der oberen Zierleiste.

`werkzeuge/innenraum.py` sucht die Innenkante: der Zierrand ist unruhig, die Fläche gleichmäßig,
also liegt die Kante dort, wo die Helligkeit über zwei Millimeter ruhig wird.

| Kasten | oben | unten | links | rechts |
|---|---|---|---|---|
| `pergament-klein` | 3,13 | 3,30 | 4,06 | 3,64 |
| `pergament-mittel` | 3,64 | 3,30 | 3,13 | 4,06 |
| `pergament-lang` | 2,96 | 3,30 | 3,73 | 4,15 |
| `pergament-breit` | 3,56 | 3,05 | 3,73 | 3,73 |
| `pergament-schmal` | 2,88 | 3,81 | 3,73 | 3,81 |
| `werte-klein` | 6,18 | 5,59 | 2,62 | 3,22 |
| `werte-mittel` | 7,28 | 4,74 | 3,89 | 4,23 |
| `werte-gross` | 6,27 | 3,56 | 3,47 | 3,30 |
| `werte-klein-portrait` | 9,31 | 9,57 | 6,77 | 9,31 |
| `werte-mittel-portrait` | 8,38 | 9,06 | 4,66 | 11,18 |
| `werte-gross-portrait` | 8,13 | 4,32 | 4,57 | 11,43 |

Alle Werte in mm, Abstand der Innenkante vom Rand der Grafik. Der Umfluss um das Medaillon rechnet
zusätzlich 2,5 mm Luft auf den Kranzradius — mit 0,8 mm stand der Text zu dicht daran. Die 6 mm, die vorher für alle galten,
reichen bei keinem Wertekasten. Jeder setzt jetzt seine eigenen `top` und `bottom`, die
Pergamentkästen behalten die Voreinstellung. Das große Maß rechts bei den Porträtkästen ist der
Überhang des Medaillons — dort endet der Kastenkörper.

## Die Probenzeile

Gemessen an einer gesetzten Veröffentlichung, drei Vorkommen auf zwei Seiten:

| Maß | Wert |
|---|---|
| Balken | volle Spaltenbreite (dort 73,4 mm), 6,985 mm hoch |
| Text | Gentium Basic fett, 11 bp, schwarz |
| Grundlinie | 4,87 mm unter der Balkenoberkante |
| Farbe | je Probenart eine andere Sonderfarbe (P220, P309, P330) |

Die Sonderfarben stehen im PDF nur als Pantone-Namen; ihre Werte sind daraus nicht zu holen.

## Das Porträtmedaillon

Die drei Kastengrafiken enthalten das Medaillon schon. Damit ist seine Lage kein Schätzwert,
sondern im Alphakanal messbar — und der Ring, den die Klasse darüberlegt, muss genau darauf sitzen.

| Datei | Kranzmitte von rechts | unter der Oberkante | Kranzradius |
|---|---|---|---|
| `werte-klein-portrait` | 17,06 mm | 17,97 mm | 15,62 mm |
| `werte-mittel-portrait` | 17,91 mm | 16,87 mm | 15,62 mm |
| `werte-gross-portrait` | 17,57 mm | 16,62 mm | 15,62 mm |

Zwei Wege führen zur Kranzmitte und stimmen auf 0,2 mm überein: der Scheitel oben plus der
Kranzradius, und der rechteste deckende Punkt. `portraitrahmen.png` deckt die Pixel 15 bis 384 von
418 waagerecht und 20 bis 391 von 413 senkrecht — die Kranzmitte liegt darin 0,81 mm links und
0,08 mm über der Bildmitte, weshalb der Ring um `\dsaportraitringx` versetzt angesetzt wird.

Die früheren 19,4 mm unter der Oberkante kamen daher, dass dort der Außenradius der Ringdatei
gerechnet wurde — 17,7 mm, die halbe Bildbreite — und nicht der Kranz. Das Medaillon saß damit
2,1 mm zu tief.

## Fußzeile

Gemessen an einer gesetzten Veröffentlichung des Verlags, vier Seiten:

| Maß | Wert |
|---|---|
| Grundlinie von Zahl und Kolumnentitel | 291,92 mm von oben, also 5,08 mm über der Papierkante |
| Seitenzahl | Andalus 20 bp, weiß; Mitte 19,47 mm von der Außenkante |
| Kolumnentitel | Andalus 14 bp, schwarz, ohne Kontur |
| Kolumnentitel, rechte Seiten | rechtsbündig, Ende 24,29 mm von der Außenkante |
| Kolumnentitel, linke Seiten | linksbündig, Anfang 40,35 mm von der Außenkante |
| Trennzeichen | Gedankenstrich U+2013, 2,48 mm breit |

Zwei rechte Seiten enden beide bei 185,71 mm, zwei linke beginnen beide bei 40,35 mm — die
Asymmetrie ist also gewollt und keine Streuung.

Die Klasse setzt die Zahl mit Andalus 13 bp und 18,4 mm von der Außenkante, weil sie in das
Ornament des Seitenhintergrunds gehört; das ist am Musterbogen des Baukastens gemessen und weicht
damit bewusst von den 20 bp der Veröffentlichung ab.

## Warum `\normalsize` umdefiniert ist

Die Grundschrift steht auf 10 bp mit 12 bp Durchschuss, nicht auf pt. Es genügt aber nicht, sie
einmal im `\AtBeginDocument` einzustellen: `\normalsize` ist der Haken, den LaTeX für die
Grundschrift vorsieht, und jede Stelle, die ihn zieht, holte sonst die 10 pt auf 12 pt der
Basisklasse zurück. Gemessen hatte `\newgeometry` genau das getan — ab dem ersten Querformat lief
der Satz mit 12,0 statt 12,045 pt, und zwar auch auf allen folgenden Seiten. Über 59 Zeilen sind
das 2,6 bp Drift, also eine viertel Zeile.
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
