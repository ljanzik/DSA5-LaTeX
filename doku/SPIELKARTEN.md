# Spielkarten

`dsa5spielkarten.cls` setzt Spielkarten im Format der offiziellen DSA5-Kartensets: **63 × 88 mm**,
elf Kartentypen, wahlweise als Einzelkarten für die Druckerei oder als A4-Druckbogen, dessen
Rückseite beim Duplexdruck exakt auf der Vorderseite liegt.

Die Maße stammen aus dem **„Scriptorium Aventuris – Spielkarten“-Baukasten** von Ulisses Spiele,
einem eigenen Paket neben dem allgemeinen Layout-Baukasten. Woher jede einzelne Zahl kommt, steht
in [Die Maße und woher sie kommen](MASSE.md), Abschnitt 8. Was daran geprüft wurde, steht im
[Prüfplan](PRUEFPLAN.md).

---

## Was man braucht

**Beide Ulisses-Pakete**, beide kostenlos und unter demselben Link:

| Paket | wofür | Werkzeug |
|---|---|---|
| Scriptorium Aventuris v4 (allgemein) | Gentium Basic in **fett und kursiv**, Andalus, die Rautenkacheln des Kartenrückens | `werkzeuge/aufbereiten.py` |
| Scriptorium Aventuris – Spielkarten | die Kartenfläche | `werkzeuge/kartengrafik.py` |

```sh
python3 werkzeuge/aufbereiten.py  "/pfad/zu/Scriptorium Aventuris v4"
python3 werkzeuge/kartengrafik.py "/pfad/zu/Scriptorium Aventuris -Spielkarten"
```

**Der allgemeine Baukasten ist dabei nicht der entbehrliche.** Das Kartenpaket bringt zwar in
`Document fonts` eigene Schriften mit, aber nur `GenBasR.ttf` und `andlso.ttf` — der Fett- und der
Kursivschnitt von Gentium Basic fehlen dort. Gebraucht werden sie auf jeder Karte: jedes
Stichwort („Charakterzüge:“, „Waffenvorteil:“) steht fett, und jede Beschriftung der Wertetabelle
ebenso. Fehlen sie, meldet XeLaTeX das nur als Warnung und setzt still mager weiter — ein Fehler,
den man im Abzug leicht übersieht. Dazu kommen die Rautenkacheln, aus denen der generische
Kartenrücken gebaut ist.

`kartengrafik.py` prüft das am Ende nach und sagt, was noch fehlt. Aus dem Kartenpaket selbst
braucht es genau eine Datei, `Links/Spielkarte_Ulisses_Design.tif`, und legt sie als
`grafiken/spielkarte-flaeche.png` ab; `schriften/` fasst es nicht an.

Wie bei allem Bildmaterial dieses Projekts: die Grafiken gehören Ulisses und **dürfen nicht ins
Repository**. `grafiken/` ist in `.gitignore`, und das gilt auch für die Kartenfläche und ihre
Farbvarianten.

### Platzhalterbilder

Ein Kartensatz ist lange vor seinen Illustrationen fertig. Damit man das Layout trotzdem prüfen
kann, legt `werkzeuge/kartenplatzhalter.py` Platzhalter in der richtigen Form an:

```sh
python3 werkzeuge/kartenplatzhalter.py "Bruder Halmrich" "Zwergenspalter"
python3 werkzeuge/kartenplatzhalter.py --rund "Halmrich"
```

Das ergibt `grafiken/platzhalter-bruder-halmrich.png` und so weiter — ein Rahmen mit Kreuz und dem
Namen darin, bewusst als Platzhalter erkennbar. `--rund` erzeugt die quadratische Fassung für
`\dsaKartenmedaillon`.

### Figuren freistellen

Auf einer Karte sitzt die Figur **direkt auf dem Pergament**. Ein Bild mit eigenem Hintergrund
steht statt dessen als helles Rechteck darauf, und man sieht der Karte an, dass da etwas
hineinkopiert wurde; die offiziellen Sets zeigen ausschließlich freigestellte Figuren.

```sh
python3 werkzeuge/hintergrundfrei.py bilder/*.jpeg --ziel grafiken/
python3 werkzeuge/hintergrundfrei.py bild.jpeg --toleranz 40 --weich 3
```

Das Werkzeug misst die Randfarbe des Bildes (Median der äußersten Zeile und Spalte) und macht
alles durchsichtig, was ihr nahe genug kommt **und** vom Rand aus zusammenhängend erreichbar ist.
Die zweite Bedingung ist die wichtige: ein helles Hemd trifft die Randfarbe genauso, wird aber von
der Figur umschlossen und bleibt deshalb stehen.

Das setzt einen ruhigen, einfarbigen Hintergrund voraus. Bei einem Foto mit Zimmer dahinter
richtet es nichts aus.

Nicht zu verwechseln mit `werkzeuge/freistellen.py`: das überträgt den Alphakanal einer *Vorlage*
(das gerissene Pergamentblatt etwa) auf ein Bild und sucht nichts im Bild selbst.

Fürs Medaillon braucht es das nicht — dort sitzt das Bild hinter dem Messingkranz und wird rund
beschnitten, der eigene Hintergrund füllt den Kreis.

---

## Bauen

```sh
cd beispiel
TEXINPUTS="..;" xelatex spielkarten.tex        # Einzelkarten, 63 x 88 mm
TEXINPUTS="..;" xelatex spielkarten-bogen.tex  # A4-Bogen, 3 x 3, duplexdeckend
```

**Ein Lauf genügt.** Anders als ein Aufstellerbogen benutzt diese Klasse kein
`remember picture`; sie merkt sich nichts über den Lauf hinaus.

Beide Beispieldokumente ziehen ihre Karten aus derselben Datei `beispiel/spielkarten-inhalt.tex`
und unterscheiden sich nur in der Klassenoption. Am gebauten PDF ist damit nachzuprüfen, dass die
Druckfassung am Satz der einzelnen Karte nichts ändert.

### Klassenoptionen

| Option | Wirkung |
|---|---|
| `einzeln` | Vorgabe. Seite = Karte, 63 × 88 mm, eine Seite je Kartenseite |
| `anschnitt` | Seite 69 × 93,98 mm, die Kartenfläche reicht bis an die Blattkante — das, was eine Druckerei als „mit 3 mm Beschnitt“ erwartet |
| `bogen` | Seite = A4 mit 3 × 3 Karten, Vorder- und Rückseitenbogen im Wechsel |
| `kurz` | nur mit `bogen`: Wenden an der kurzen statt an der langen Kante |
| `ohneschnittmarken` | nur mit `bogen`: keine Schnittmarken |
| `entwurf` | Bilder als Rahmen, schneller Lauf |

### Die beiden Druckfassungen

**Einzelkarten** ergeben ein PDF, in dem Seite 1 die Vorderseite der ersten Karte ist, Seite 2
ihre Rückseite, Seite 3 die Vorderseite der zweiten und so fort. Das ist das Format, das
Kartendruckereien erwarten — mit `anschnitt` gebaut auch mit dem Beschnittrand, den sie verlangen.

**Der Druckbogen** legt neun Karten auf A4, 3 × 3, mittig: waagerecht (210 − 3 · 63) / 2 = 10,5 mm
Rand, senkrecht (297 − 3 · 88) / 2 = 16,5 mm. Auf den Vorderseitenbogen folgt jeweils der
zugehörige Rückseitenbogen; sind es mehr als neun Karten, folgt das nächste Bogenpaar.

Gedruckt wird beidseitig mit **Wenden an der langen Kante** — die Vorgabe jedes Druckertreibers
für Hochformat. Das Blatt dreht sich dabei um die senkrechte Mittelachse, links und rechts
vertauschen physisch. Die Klasse spiegelt den Rückseitenbogen dafür spaltenweise:

```
Spalte' = 2 − Spalte        (Zeile bleibt gleich, gezählt ab 0)
```

Mit `kurz` gilt statt dessen `Zeile' = 2 − Zeile`. Die Schnittmarken werden nur für belegte Zeilen
gezeichnet — auf dem letzten Bogen bleiben Plätze frei, und eine Marke dort wiese auf einen
Schnitt, den es nicht zu tun gibt.

### Stückzahl

Zehn Heiltränke sind zehn Karten, aber nur ein Eintrag im Quelltext:

```latex
\dsaKartenanzahl{10}
```

Die Zahl gilt **nur für den Bogen**. In der Einzelkartenfassung bleibt es bei einer Seite je
Kartenseite: das ist die Druckvorlage, und die Auflage vereinbart man mit der Druckerei. Die
Karte wird einmal gesetzt und danach nur noch kopiert, zehn Stück kosten also keine zehn
Umbrüche.

---

## Die Kartentypen

Jeder Typ ist eine Umgebung. Die Felder werden darin mit Setzbefehlen benannt und dürfen in
beliebiger Reihenfolge stehen.

| Umgebung | Vorbild | Rückseite |
|---|---|---|
| `dsaKarteNSC` | Aventurische Meisterpersonen | Fließtext, Stichwörter, Medaillon, Illustrationsnachweis |
| `dsaKarteWaffe` | Flusslande | Wertetabelle, darunter Vorteil und Nachteil |
| `dsaKarteRuestung` | Flusslande | wie Waffe, andere Zeilen |
| `dsaKarteGegenstand` | Flusslande | nur Stichwörter, keine Tabelle |
| `dsaKarteMonster` | Flusslande | vierspaltiges Attributraster, Stichwörter, Medaillon |
| `dsaKarteZauber` | Flusslande | Kopf und Text auf beiden Seiten — siehe „Textkarten“ |
| `dsaKarteSonderfertigkeit` | Flusslande | ebenso |
| `dsaKarteKultur` | Flusslande | ebenso |
| `dsaKarteVerbrauch` | — | einseitig, generischer Rücken |
| `dsaKarteText` | beide Sets | Kopf und Text, sonst nichts — beidseitig gleich |
| `dsaKarteImpressum` | Flusslande | wie `dsaKarteText`, Kopf steht schon |

Die **Vorderseite** trägt bei den ersten fünf Typen Kartenfläche, freigestellte Abbildung, Name,
Untertitel und Kartennummer. Der Untertitel ist beim NSC die Kurzbezeichnung, sonst die Gattung —
`dsaKarteWaffe`, `dsaKarteRuestung` und `dsaKarteGegenstand` belegen ihn selbst vor. Beim Monster
steht die Gattung ausgeschrieben („Kreatur, nicht humanoid“, „Tier, nicht humanoid“) und wird
deshalb gesetzt.

### Felder

| Befehl | gilt für | was es tut |
|---|---|---|
| `\dsaKartenname{…}` | alle | Name, Andalus 14 bp, zentriert, wird versal gesetzt |
| `\dsaKartenuntertitel{…}` | alle | Untertitelzeile, Andalus 7 bp, ebenfalls versal |
| `\dsaKartenbild{…}` | alle außer den Textkarten | freigestellte Abbildung, in das Bildfeld eingepasst |
| `\dsaKartennummer{…}` | alle | weiße Nummer mit dunkler Kontur unten rechts |
| `\dsaKartenmedaillon{…}` | NSC, Monster | rundes Porträt unten links, mit Messingkranz darüber |
| `\dsaKartenmedaillonfertig{…}` | NSC, Monster | dasselbe für ein Bild, das den Kranz schon mitbringt |
| `\dsaKartennachweis{…}` | NSC | Illustrationsnachweis, zweizeilig |
| `\dsaKartentext{…}` | alle | ein Absatz |
| `\dsaKartenstich{…}{…}` | alle | Absatz mit fettem Stichwort und hängendem Einzug |
| `\dsaKartenzeile{…}{…}` | alle | Beschriftung über dem Wert, danach eine Leerzeile |
| `\dsaKartenwert{…}{…}` | Waffe, Rüstung | eine Zeile der Wertetabelle |
| `\dsaKartenattribut{…}{…}` | Monster | ein Feld des Attributrasters, vier je Zeile |
| `\dsaKartenfortsetzung` | Textkarten | alles Weitere kommt auf die Rückseite |
| `\dsaKartenanzahl{…}` | alle | wie oft die Karte auf den Bogen soll |

Der Name wird gemischt übergeben und von der Klasse versal gesetzt — so bleibt er im Quelltext
lesbar („Oldewin“ statt „OLDEWIN“). Mehrzeilige Namen entstehen von selbst durch Umbruch; das
Bildfeld rückt dann nach, seine Oberkante ist die Unterkante des Kartenkopfs.

### Die Bausteine darunter

Die Felder oben sammeln nur ein; gesetzt wird von vier Befehlen, die auch einzeln benutzbar sind,
wenn jemand einen eigenen Kartentyp baut. Wer sie nicht braucht, überliest diesen Abschnitt.

| Befehl | was er setzt |
|---|---|
| `\dsaKartenkopf{Name}{Untertitel}` | den Kopf in Andalus, zentriert und versal |
| `\dsaKartenabsatz{…}` | einen Absatz im Format „Beschreibung“ |
| `\dsaKarteStich{Wort}{Text}` | einen Stichwortabsatz mit hängendem Einzug |
| `\dsaKarteZeile{Wort}{Text}` | Beschriftung über dem Wert |
| `\dsaKartenwertkopf{…}` | die Kopfzeile der Wertetabelle |

**Achtung auf die zwei ähnlichen Namen:** `\dsaKartenstich` (kleines s) ist das Feld — es sammelt
ein und entscheidet, ob der Absatz auf die Vorder- oder die Rückseite kommt. `\dsaKarteStich`
(großes S) setzt ihn. In einer Karte steht immer das Feld.

Für Zahlenangaben im Text gelten dieselben drei Befehle wie in der Kernklasse, weil die Klasse
wie jene kein Mathematikpaket lädt: `\dsaFormel{1W6+4}`, `\dsaMod{+}{2}` und `\dsaMinus` für das
Minuszeichen. Ein `$…$` gibt es auf einer Karte so wenig wie im Heft.

### Beispiel: ein NSC

```latex
\begin{dsaKarteNSC}
  \dsaKartenname{Bruder Halmrich}
  \dsaKartenuntertitel{Wandernder Efferdgeweihter}
  \dsaKartenbild{platzhalter-bruder-halmrich}
  \dsaKartennummer{UFR 01}
  \dsaKartenmedaillon{platzhalter-halmrich-rund}
  \dsaKartennachweis{Platzhalter}

  \dsaKartentext{Bedächtiger Zuhörer, Götter \& Kulte (12/13/11) 9}
  \dsaKartentext{Zieht seit dreißig Jahren den Uferpfad entlang.}
  \dsaKartenstich{Charakterzüge}{gelassen, wortkarg, unbestechlich}
  \dsaKartenstich{Dienstleistungen}{Wettervorhersage, Segnung von Booten}
\end{dsaKarteNSC}
```

### Beispiel: eine Waffe

```latex
\begin{dsaKarteWaffe}
  \dsaKartenname{Zwergenspalter aus Wehrheim}
  \dsaKartenbild{platzhalter-zwergenspalter}
  \dsaKartennummer{UFR 03}

  \dsaKartenwert{KT}{Zweihandhiebwaffen}
  \dsaKartenwert{TP}{\dsaFormel{1W6+5}}
  \dsaKartenwert{Preis}{190 S}

  \dsaKartenstich{Waffenvorteil}{Gegen Rüstungen mit RS~4 oder höher
    richtet der Zwergenspalter \dsaMod{+}{2}~TP an.}
\end{dsaKarteWaffe}
```

Der Name der Karte ist zugleich die Kopfzeile der Tabelle; sie wird nicht eigens gesetzt.

### Beispiel: ein Monster

```latex
\begin{dsaKarteMonster}
  \dsaKartenname{Moorschrecke}
  \dsaKartenuntertitel{Tier, nicht humanoid}
  \dsaKartenbild{platzhalter-moorschrecke}
  \dsaKartennummer{UFR 11}
  \dsaKartenmedaillon{platzhalter-moorschrecke-rund}

  \dsaKartenattribut{MU}{11}  \dsaKartenattribut{KL}{3 (t)}
  \dsaKartenattribut{IN}{13}  \dsaKartenattribut{CH}{8}

  \dsaKartenstich{RS/BE}{2/0}
  \dsaKartenstich{Größenkategorie}{mittel}
\end{dsaKarteMonster}
```

Das Raster füllt sich von links nach rechts, vier Felder je Zeile. Wie viele Zeilen es werden,
rechnet die Klasse aus; der Text darunter beginnt eine Zeile nach der letzten.

### Das Porträtmedaillon

Das Medaillon des Sets ist kein bloßes Porträt, sondern Porträt **und Messingkranz** in einem
Bild — nachgesehen an der 237-×-237-Grafik der Karte AMP 01a, die beides enthält. Der Kranz ist
derselbe, den die Kernklasse in ihre Wertekästen setzt: `portraitrahmen.png`, im Baukasten
`Ornament_Portrait_Wertekasten.psd`.

Die Klasse zeichnet beide Lagen getrennt, und das ist der Punkt: wer eine Karte setzt, hat ein
Porträt, keinen fertig montierten Kranz.

```latex
\dsaKartenmedaillon{portraet-halmrich}
```

Das Bild wird rund beschnitten und reicht unter den Kranz, sodass keine Fuge bleibt. Wer schon ein
montiertes Medaillon hat, nimmt `\dsaKartenmedaillonfertig` — dann zeichnet die Klasse keinen
zweiten Kranz.

**Der Ausschnitt.** Ohne weitere Angabe zeigt das Medaillon die Mitte des Bildes. Bei einem
Brustbild ist das richtig; bei einer Halb- oder Dreiviertelfigur ist die Bildmitte der Bauch, und
der Kopf steht über dem Kreis. Deshalb nimmt der Befehl ein optionales Argument aus drei Zahlen:

```latex
\dsaKartenmedaillon[0.59,0.515,0.243]{portraet-halmrich}
```

| Zahl | was sie bedeutet |
|---|---|
| erste | Kantenlänge des sichtbaren Quadrats, als Anteil der **kürzeren** Bildseite. 1 ist der deckende Ausschnitt und die Vorgabe, kleinere Werte zoomen hinein |
| zweite, dritte | wo die Mitte dieses Quadrats im Bild liegt, als Anteil der Bildbreite und der Bildhöhe. 0,5 / 0,5 ist die Bildmitte |

Abgelesen wird das am Bild: Kopfbreite und Augenhöhe in Pixeln, geteilt durch die Bildmaße. Mit
einem engen Ausschnitt lässt sich auch aus einer **Ganzfigur** ein Medaillon holen, wenn kein
Brustbild vorliegt.

Automatisch geht das nicht verlässlich. Ein Versuch, den Kopf über die Silhouette zu finden
(oberste Figurzeile, Kopfbreite in der oberen Zone, Schulterlinie am Breitensprung), traf bei
schmalköpfigen Figuren gut und scheiterte an Haaren, Bärten, getragenen Dingen und an einer Gans
mit ausgebreiteten Flügeln — dort wurde die Kopfbreite um das Zwei- bis Dreifache zu groß
gemessen. Drei abgelesene Zahlen sind verlässlicher als eine Heuristik, die in einem von vier
Fällen danebenliegt.

### Textkarten: Zauber, Sonderfertigkeit, Kultur

Diese drei haben keine Abbildung, und sie tragen **auf beiden Seiten denselben Text**. Das ist
nicht erfunden, sondern am Set abgelesen: von 126 Flusslande-Karten sind 39 beidseitig gleich —
genau die, deren Text auf eine Seite ging. Die Karte liest sich damit, wie herum sie auch liegt.

```latex
\begin{dsaKarteZauber}
  \dsaKartenname{Windhauch}
  \dsaKartenuntertitel{Zaubertrick}
  \dsaKartennummer{UFR 07}

  \dsaKartentext{Ein kurzer Luftzug fährt über das Wasser und legt sich wieder.}
  \dsaKartenstich{Reichweite}{16 Schritt}
  \dsaKartenstich{Merkmal}{Elementar (Luft)}
\end{dsaKarteZauber}
```

Passt der Text nicht auf eine Seite, teilt ihn `\dsaKartenfortsetzung`: alles davor steht auf der
Vorderseite, alles danach auf der Rückseite — dort ohne Kopf, beginnend auf der ersten
Rückseitengrundlinie. Auch das macht das Set so.

```latex
  \dsaKartenstich{Reichweite}{Berührung}
  \dsaKartenfortsetzung
  \dsaKartenstich{Wirkungsdauer}{QS Spielrunden}
```

Der Untertitel ist bei allen dreien nur vorbelegt („Zauberspruch“, „Sonderfertigkeit“,
„Wesenszug“) und wird in der Regel gesetzt: das Set kennt „Zaubertrick“, „Ritual“, „Liturgie“,
„Zeremonie“ und „Dolchritual“ als denselben Aufbau.

### Textkarten ohne Gattung: was ein Set über sich selbst setzt

Beide veröffentlichten Sets haben Karten, die nicht zum Inhalt gehören, sondern zum Set: die
Impressumskarte der *Flusslande* und die Regelkarte der *Meisterpersonen*. Kopf und Text, kein
Bild, keine Tabelle, auf beiden Seiten dasselbe.

```latex
\begin{dsaKarteText}
  \dsaKartenname{Die Uferlande}
  \dsaKartenuntertitel{Ein Kartensatz zum Nachschlagen}
  \dsaKartennummer{UFR 00}

  \dsaKartentext{Siebzehn Karten für den Spielleiter.}
  \dsaKartenstich{Mischen}{Die Verbrauchsgegenstände lassen sich verdeckt ziehen.}
\end{dsaKarteText}
```

`dsaKarteText` ist zugleich der **Auffangtyp**: Was im Set eine Gattungszeile trägt, für die es
hier keine eigene Umgebung gibt, lässt sich damit setzen.

Die Impressumskarte braucht eine eigene Absatzform — die Beschriftung steht **über** dem Wert,
nicht davor:

```latex
\begin{dsaKarteImpressum}
  \dsaKartennummer{UFR 18}
  \dsaKartenzeile{Verlagsleitung}{Markus Plötz}
  \dsaKartenzeile{Redaktion}{Nikolai Hoch, Johannes Kaub}
\end{dsaKarteImpressum}
```

`\dsaKartenzeile` und `\dsaKartenstich` sind nicht dasselbe und sehen auch nicht so aus: die
Zeile setzt die Beschriftung auf eine eigene Zeile und lässt danach eine frei, der Stichwortabsatz
setzt sie in die Zeile und zieht den Rest hängend ein.

### Karten ohne Gattungszeile

Zehn Karten des Flusslande-Sets tragen nur einen Namen und keine Gattung — die mechanischen Geräte
von `ASTROLABIUM` bis `VORHÄNGESCHLOSS`, dazu der `FLUSSPIRAT` und zwei weitere Kreaturen. Dafür
braucht es keinen eigenen Typ, nur einen leeren Untertitel:

```latex
\dsaKartenuntertitel{}
```

Der Kopf setzt dann nur den Namen, und das Bildfeld rückt um die eingesparte Zeile nach oben.

### Verbrauchsgegenstände

Einseitig und kurz: Name, Abbildung, Wirkung. Zehn Heiltränke im Gepäck sollen sich nicht wie
zehn Regelseiten anfühlen.

```latex
\begin{dsaKarteVerbrauch}
  \dsaKartenanzahl{10}
  \dsaKartenname{Heiltrank}
  \dsaKartenuntertitel{Verbrauchsgegenstand, Stufe 1}
  \dsaKartenbild{platzhalter-heiltrank}
  \dsaKartennummer{UFR 13}

  \dsaKartentext{Heilt \dsaFormel{1W6} Lebenspunkte. Brauqualität 1, Preis 20 S.}
\end{dsaKarteVerbrauch}
```

Der Aufbau unterscheidet sich von allen anderen Typen: **der Text steht unten und wächst nach
oben**, die Abbildung füllt, was dazwischen bleibt. Die Karte bekommt den generischen Rücken.

Wird das Bildfeld dabei sehr klein, steht zu viel Text auf der Karte — dann ist es kein
Verbrauchsgegenstand mehr, sondern ein Gegenstand, und dafür gibt es `dsaKarteGegenstand`.

---

## Der generische Kartenrücken

Einseitige Karten brauchen trotzdem eine Rückseite, sonst kommt aus dem Duplexdruck ein leeres
Blatt. Der Spielkarten-Baukasten liefert dafür nichts — er kennt nur die eine Kartenfläche, und
die gedruckten Sets haben zwar einen gemeinsamen Rücken, aber der steckt in keinem der beiden
PDF.

Zwei Motive kommen deshalb aus dem allgemeinen Layout-Baukasten, aus Grafiken, die
`aufbereiten.py` ohnehin anlegt:

| Befehl | was es ist |
|---|---|
| `\dsaRueckenRaute` | die Rautenkachel groß in der Kartenmitte. **Vorgabe** |
| `\dsaRueckenRautenfeld` | dieselbe Kachel über den Textrahmen gerastert |

```latex
\dsaKartenruecken{\dsaRueckenRautenfeld}   % statt der einzelnen Raute
\dsaKartenruecken{}                        % gar nichts, blanke Fläche
```

Die Raute trägt **die Randfarbe der Karte**: `\dsaKartenfarbe{blau}` setzt nicht nur die
Kartenfläche, sondern auch `spielkarte-raute-blau`. Beide legt `kartengrafik.py` mit `--farbe` an,
und beide haben denselben Farbton. Wer die Raute eigens wählen will, nimmt `\dsaKartenraute`; die
drei amtlichen Kacheln heißen `raute-grau`, `raute-gruen` und `raute-rot`.

Das Rautenfeld wird **auf den Textrahmen beschnitten**, nicht auf die Kartenkante. Über die ganze
Karte gelegt deckte es den Zierrand zu — und der Zierrand ist das, woran man die Karte erkennt.
Innerhalb des Rahmens liegt es auf dem Pergament und lässt Schuppenband und Messingecken frei.

### Ein Rücken ohne Schuppenband

Das Schuppenband lässt sich **nicht abschalten**: schwarzer Rand, Band, Messingecken und Pergament
stecken in einer einzigen flachen Datei. Das TIF des Baukastens ist RGB, eine Ebene, ohne
Alphakanal, und das IDML legt genau dieses eine Bild auf die Karte.

Ersetzen lässt es sich aber. `kartengrafik.py` leitet dabei jedes Mal
`grafiken/spielkarte-ruecken.png` mit ab: dieselbe Karte, deren Bandzone mit Pergament aus der
Kartenmitte gefüllt und deren dunkler Rand neu aufgebaut ist. Übrig bleibt eine ruhige
Pergamentkarte, auf der die Raute allein steht.

```latex
\dsaKartenrueckflaeche{spielkarte-ruecken}   % ruhiger Rücken
\dsaKartenrueckflaeche{}                     % zurück zur Kartenfläche
```

Eingefärbt wird diese Fläche nicht — es ist nichts Buntes mehr darin. Die Farbe trägt dann die
Raute.

Der Rücken trägt **keine Kartennummer**: sonst wäre er nicht mehr generisch und verriete beim
Mischen, welche Karte darunterliegt.

Was im Baukasten noch liegt und nicht taugt, damit es niemand ein zweites Mal probiert:
`ornament-mittig` ist fast so hoch wie die Karte und als senkrechte Leiste zunächst verlockend,
aber es ist das Mittelstück einer dreiteiligen Leiste und trägt rechts eine dunkle Anschlusskante,
die ohne Zuschnitt als schwarzer Balken auf dem Pergament steht. `ornament-links` und
`ornament-rechts` sind Eckbeschläge mit Messingring, schön, aber auf 69 mm angelegt — auf einer
Karte deckt ein Stück davon die halbe Fläche. Wer den Ring will, schneidet ihn mit
`werkzeuge/freistellen.py` heraus und setzt ihn wie `\dsaRueckenRaute`.

---

## Die Randfarbe

Die Kartenfläche des Baukastens hat ein neutrales, graubraun-violettes Schuppenband. Die beiden
veröffentlichten Sets zeigen dasselbe Band in Farbe: *Aventurische Meisterpersonen* blau,
*Flusslande* rotbraun. Am Satz nachgemessen ist das eine reine Umfärbung — Pergament, Messingecken
und der schwarze Außenrand sind in beiden Sets Bild für Bild dieselben.

`werkzeuge/kartengrafik.py` kann das nachbilden:

```sh
python3 werkzeuge/kartengrafik.py "/pfad/zum/Kartenpaket" --farbe blau --farbe rot
python3 werkzeuge/kartengrafik.py "/pfad/zum/Kartenpaket" --farbe moor:150:0.4
python3 werkzeuge/kartengrafik.py --farben
```

Eingefärbt werden nur die dunklen, fast unbunten Bildpunkte des Bandes; ihre Helligkeit bleibt.
Ausgenommen sind das Pergament (hell), die Messingecken (bunt) und der schwarze Rand — der bleibt
schwarz, weil die Zielfarbe nur den Farbton beiträgt und die Helligkeit aus dem Bild kommt.

`blau` und `rot` sind an den Kartengrafiken der beiden Sets gemessen, die übrigen vier Namen sind
Angebote in derselben Machart. Eigene gehen mit `name:farbton:sättigung`.

Im Dokument umgestellt wird mit

```latex
\dsaKartenfarbe{blau}
```

auch mitten im Satz: von da an hat jede weitere Karte den neuen Rand — **und die passende Raute
auf dem Rücken**. `\dsaKartenfarbe{}` ohne Argument stellt auf die unbehandelte Fassung des
Baukastens zurück. Wer Fläche und Raute getrennt wählen will, nimmt `\dsaKartenflaeche` und
`\dsaKartenraute` einzeln.

Das Beispieldokument nutzt das, um seine siebzehn Karten in fünf Farben zu gruppieren.

---

## Was die Klasse anders macht als die veröffentlichten Sets

Drei Stellen, an denen Baukasten und Sets auseinandergehen. Die Klasse folgt dem Baukasten, weil
er die Vorlage ist und die Sets Produkte daraus sind.

**Die Schrift.** Beide Sets sind in Times New Roman gesetzt. Der Spielkarten-Baukasten gibt
Gentium Basic vor und liefert sie mit; Times liegt in keinem der beiden Pakete und dürfte hier
auch nicht mitgeliefert werden. Gesetzt wird deshalb in Gentium Basic. Es läuft breiter als Times,
weshalb auf eine Karte etwas weniger Text geht.

**Der Grad.** Die Sets setzen ihren Fließtext 6,5 bp auf 7,8 bp, der Baukasten 7 bp auf 8 bp. Es
gilt der Baukasten. Nur die Wertetabelle setzt kleiner — sie kommt nicht aus dem Baukasten,
sondern ganz aus dem Flusslande-Set, und übernimmt von dort auch die Grade (Beschriftung 6 bp
fett, Wert 6,5 bp).

**Das Stichwort.** *Meisterpersonen* setzt es kursiv, *Flusslande* fett. Die Klasse setzt fett,
dem jüngeren Set folgend.

---

## Maße zum Nachstellen

Die Längen der Klasse sind alle öffentlich und lassen sich vor der ersten Karte umsetzen. Hier
stehen die, die man am ehesten braucht; die übrigen — Anschnitt, Zierabstände, Lage von
Kartennummer und Nachweis, die Maße des Bildfelds — stehen im Quelltext der Klasse, jede mit
ihrer Herleitung daneben.

| Länge | Vorgabe | was sie ist |
|---|---:|---|
| `\dsakartenbreite` | 63 mm | Kartenbreite |
| `\dsakartenhoehe` | 88 mm | Kartenhöhe |
| `\dsakartenrahmenoben` | 12,20 mm | Oberkante des Textrahmens |
| `\dsakartenrahmenunten` | 76,40 mm | Unterkante des Textrahmens |
| `\dsakartensatzlinks` | 5,50 mm | linke Satzkante |
| `\dsakartensatzbreite` | 52,00 mm | Satzbreite |
| `\dsakartenerstezeile` | 17,657 mm | erste Grundlinie der Vorderseite |
| `\dsakartenrueckzeile` | 14,790 mm | erste Grundlinie der Rückseite |
| `\dsakartenzeilenschritt` | 8 bp | Zeilenschritt des Attributrasters |
| `\dsakartenzeilenhoehe` | 4 mm | Zeilenhöhe der Wertetabelle |
| `\dsakartenwertspalte` | 21,48 mm | Beginn der Wertespalte |
| `\dsakartenspaltenschritt` | 12,70 mm | Spaltenschritt des Attributrasters |
| `\dsakartenbildunten` | 82 mm | Unterkante des Bildfelds |
| `\dsakartenrautenhoehe` | 34 mm | Raute auf dem Rücken |
| `\dsakartenrautenkachel` | 14 mm | Kachel des Rautenfelds |
| `\dsakartenmedaillongroesse` | 20 mm | sichtbarer Durchmesser des Messingkranzes |
| Ausschnitt (optionales Argument) | 1 / 0,5 / 0,5 | Quadratseite als Anteil der kürzeren Bildseite, dann dessen Mitte im Bild |
| `\dsakartenmedaillonlinks` / `-oben` | 2,50 / 65,90 mm | obere linke Ecke des Medaillons |
| `\dsabogenrandx` / `\dsabogenrandy` | 10,5 / 16,5 mm | Rand des Druckbogens |

Die Oberkante des Bildfelds ist kein Maß, sondern gerechnet: sie ist die Unterkante des
Kartenkopfs. Ein fester Wert ginge nicht, weil der Kopf ein-, zwei- oder dreizeilig sein kann.
