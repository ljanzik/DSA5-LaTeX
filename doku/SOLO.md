# Solo-Abenteuer

*Nummerierte Blöcke, aufgelöste Verweise und ein garantierter Seitenwechsel bei jedem Sprung —
`dsa5solo.sty` und `werkzeuge/solo.py`.*

---

## 1. Was das ist

Ein Solo-Abenteuer liest sich nicht von vorn nach hinten. Es besteht aus nummerierten Blöcken;
über jedem Block steht seine Zahl, und im Fließtext steht, wo es weitergeht. Drei Dinge müssen
dabei stimmen, und alle drei nimmt dieses Feature dem Autor ab:

1. **Die Nummerierung.** Der Autor schreibt sprechende Marken, keine Zahlen. Das Werkzeug
   vergibt die Nummern.
2. **Die Verweise.** `\soloWeiter{marke}` setzt die Zahl, die die Marke am Ende bekommen hat —
   **fett**, wie im gesetzten Solo des Verlags.
3. **Der Seitenwechsel.** Quelle und Ziel eines Sprungs liegen nie auf derselben Doppelseite.
   Wer bei 47 die Wahl trifft und 100 schon vor sich liegen hat, liest beides — und die
   Entscheidung ist entwertet.

Punkt 3 ist der eigentliche Grund für das Werkzeug. Von Hand ist er ab etwa dreißig Blöcken
nicht mehr zu halten, weil jeder eingeschobene Block alles dahinter verschiebt.

## 2. Ein Solo anlegen

Ein Solo besteht aus **zwei** Dateien, die der Autor schreibt. Alles Weitere erzeugt das
Werkzeug.

| Datei | Inhalt |
|---|---|
| `meinsolo.tex` | Umschlag, Impressum, Spielanleitung, Rückseite — das Gerüst |
| `meinsolo-bloecke.tex` | alle nummerierten Blöcke, in beliebiger Reihenfolge |

### Die Blockdatei

Hier steht das Abenteuer. Jeder Block bekommt eine **sprechende Marke** statt einer Zahl:

```latex
\begin{soloBlock}{tor-der-stadt}
Du stehst vor dem Tor. Die Wachen mustern dich unfreundlich und verlangen
einen Wegzoll.

Zahlst du, lies bei Abschnitt \soloWeiter{markt} weiter. Wendest du dich ab,
so geht es bei Abschnitt \soloWeiter{wald} weiter.
\end{soloBlock}

\begin{soloBlock}[zusammen]{hoehle}
\dsaBildSpalte{grafiken/hoehle}{6}

Die Höhle riecht nach kaltem Rauch. Jemand hat hier gelagert.

Weiter bei Abschnitt \soloWeiter{keller}.
\end{soloBlock}

\begin{soloBlock}{ende-gut}
Du hast es geschafft.
\soloEnde
\end{soloBlock}
```

Die Reihenfolge in dieser Datei ist **gleichgültig** — schreib die Blöcke so, wie es beim
Schreiben am leichtesten fällt. Das Werkzeug vergibt die Nummern später und mischt dabei
ohnehin um.

Marken bestehen aus Buchstaben, Ziffern und Bindestrichen. Eine doppelt vergebene Marke meldet
das Werkzeug als Fehler — sie wäre sonst ein stiller: der zweite Block überschriebe den ersten,
und die Verweise zeigten auf den falschen Text.

### Das Gerüst

```latex
\documentclass[raster]{dsa5latex}
\usepackage{dsa5solo}

\graphicspath{{../}}                       % wenn die .tex in beispiel/ liegt
\dsaAbenteuertitel{Der Bote von Havena}    % steht im Kolumnentitel

\begin{document}

\dsaUmschlagVorne{grafiken/titelbild}{%
  \dsaTitelZeile{DER BOTE}%
  \dsaTitelZeile{VON HAVENA}%
  \dsaTitelZeile[27.9]{Ein Solo-Abenteuer}}

\begin{dsaImpressumseite}
\dsaImpressumsblock{Autor}{[Name]}
\dsaImpressumsblock{Satz, Layout und Gestaltung}{[Name]}
\dsaImpressumsblock{Coverbild}{[Name]}
\dsaImpressumsblock{Version}{v1.0 vom [Datum]}
\dsaRechtevermerk{2026}{[Name]}
\end{dsaImpressumseite}

\dsakapitel{Der Bote von Havena}

\dsaEinfuehrung{Ein kursiver Vorspann.}

\dsaabschnitt{So wird gespielt}

Dieses Abenteuer liest sich nicht von vorn nach hinten …

\dsaabschnitt{Was du brauchst}

Einen Helden, Papier und Stift, zwei Würfel …

Beginne bei Abschnitt \soloWeiter{tor-der-stadt}.

\soloStart{tor-der-stadt}          % dieser Block trägt immer die 1
\soloBloecke{meinsolo-bloecke}     % die Datei mit allen Blöcken

\dsaRueckseite{ruecken-mittelreich}{Der Bote von Havena}{von [Name]}{%
  Klappentext, Absätze durch Leerzeilen getrennt.
}{%
  \dsaRueckKopf{Ein DSA-Soloabenteuer\für einen Helden}
  \dsaRueckFeld{Genre}{Ermittlung}
  \dsaRueckStrich
  \dsaAnforderungen{2}{3}{1}{2}
}

\end{document}
```

Umschlag, Impressum und Rückseite kommen unverändert aus der Kernklasse; sie stehen in
[der Elementreferenz](ELEMENTE.md). Die Rückenkarten liegen als `ruecken-bornland`,
`ruecken-thorwal` und so weiter bereit — eine je Region.

**Die Spielanleitung lohnt sich.** Sie steht auf Seite 1, und der erste Block beginnt
zwangsläufig auf einer neuen Doppelseite — sonst läge er neben dem Verweis, der auf ihn zeigt.
Was die Einleitung an Text nicht hergibt, bleibt dort leer. Zwei Absätze füllen keine Seite;
eine ordentliche Anleitung mit Proben, Kämpfen und einem Bild schon.

### Was dabei entsteht

Nichts davon gehört ins Versionsverwaltungssystem, alles wird bei jedem Lauf neu erzeugt:

| Datei | woher |
|---|---|
| `meinsolo.solo` | Messlauf: Höhe und Sprungziele je Block |
| `meinsolo.solonummern` | Werkzeug: die Zuordnung Marke → Nummer |
| `solo-aus/<marke>.tex` | Werkzeug: die Blöcke, bytegetreu einzeln |
| `solo-aus/reihenfolge.tex` | Werkzeug: `\input`-Liste mit den Doppelseitengrenzen |

## 3. Bauen

**In einem Aufruf:**

```sh
python3 werkzeuge/solo-bauen.py beispiel/solo.tex --bloecke solo-bloecke.tex
```

Unter Windows `werkzeuge\solo-bauen.ps1`, sonst `werkzeuge/solo-bauen.sh` — beide reichen nur
an dasselbe Python weiter. Das Skript führt die vier Schritte nacheinander aus und **bricht bei
jedem ab, der nicht durchläuft**. Das ist der eigentliche Zweck: Scheitert der Messlauf und man
tippt die Schritte einzeln, läuft das Werkzeug gar nicht erst, der Satzlauf arbeitet mit der
alten Zuordnung weiter, und niemand merkt es.

Vor dem ersten Schritt prüft es außerdem, ob sich das PDF überhaupt schreiben lässt — ein im
Betrachter geöffnetes sperrt die Datei, und was danach entsteht, sieht stimmig aus, ist es aber
nicht.

Liegen die Blöcke nicht neben der `.tex`, kommen `--aus` und `--praefix` dazu; sie werden
unverändert an `solo.py` durchgereicht.

### Die vier Schritte einzeln

Drei Schritte, weil LaTeX messen muss, bevor Python rechnen kann.

**Messen** — schreibt `solo.solo` mit der Höhe jedes Blocks und seinen Sprungzielen:

```sh
cd beispiel
xelatex -jobname=solo '\PassOptionsToPackage{messen}{dsa5solo}\input{solo}'
```

**Lösen** — verteilt die Blöcke auf Doppelseiten, vergibt die Nummern und teilt die
Autorendatei auf:

```sh
python3 ../werkzeuge/solo.py solo.solo --bloecke solo-bloecke.tex
```

**Setzen und prüfen** — dreimal wegen Inhalt und Marken:

```sh
xelatex solo.tex
python3 ../werkzeuge/solo.py --pruefen solo.aux
```

## 4. Die Befehle

| Befehl | was er tut |
|---|---|
| `\begin{soloBlock}{marke} … \end{soloBlock}` | ein nummerierter Block; die Zahl steht als Überschrift darüber |
| `\soloWeiter{marke}` | setzt die Zahl des Zielblocks fett, sonst nichts — die Einkleidung wählt der Autor |
| `\soloEnde` | dieser Block ist ein gewolltes Ende, keine Sackgasse |
| `\soloStart{marke}` | dieser Block steht am Anfang und trägt die 1 |
| `\soloBloecke{datei}` | bindet die Blöcke ein, im Satzlauf in der berechneten Reihenfolge |
| `\soloOrdner{pfad}` | wohin das Werkzeug geschrieben hat, falls nicht `solo-aus` neben der `.tex` |
| `\soloStellen{n}` | Stellenzahl des Platzhalters im Messlauf; das Werkzeug setzt sie selbst |
| `\soloBehaelterEnde` | Ende einer Doppelseite; steht in der erzeugten Reihenfolgedatei |

`\soloWeiter` setzt bewusst nur die Zahl. „zu Abschnitt \soloWeiter{wald}" und
„(\soloWeiter{wald})" sind damit gleichermaßen möglich. Fett ist allein die Zahl; das
einkleidende Wort bleibt Fließtext.

**Die Schriftstärke steht an einer einzigen Stelle** (`\dsaSolo@zahlsatz` in `dsa5solo.sty`), und
das ist keine Stilfrage. Gentium Basic hat Tabellenziffern — jede Ziffer gleich breit —, und fett
ist sie 7,8 Prozent breiter als mager: dreistellig 15,233 statt 14,130 pt. Der Platzhalter des
Messlaufs muss dieselbe Stärke tragen wie die echte Zahl im Satz, sonst misst der Messlauf jede
Verweisstelle 1,10 pt zu schmal, die Blöcke brechen im Satz anders um, und die Behälter laufen
über.

## 5. Der Nummernkopf

Die Zahl steht **über** dem Block, nicht davor. Keine Einrückung, keine
Aufzählungsnummerierung — die Vorlage kennt beides an keiner Stelle.

An einem offiziellen, gesetzten Solo des Verlags nachgemessen, über 26 Köpfe an der
Spaltenkante:

| Größe | Messwert | Folgerung |
|---|---|---|
| Grundlinie mod 12 bp | 0,0 bei allen 23 Köpfen mit Grad 13 | sitzt exakt im Grundlinienraster |
| Schrift | GentiumBasic-Bold 13,0 bp, Farbe (0,0,0) | |
| Grundlinienabstand davor | 24,0 bp, einstimmig | 12 bp Zeile + **1 Rastereinheit** Luft |
| Grundlinienabstand danach | 12,0 bp | **keine** Zusatzluft |
| linke Kante | 24,00 mm bzw. 105,50 mm | Spaltenkante, kein Einzug |

Das ist Zeichen für Zeichen `\dsaabschnitt` der Kernklasse (`dsa5latex.cls:954`). `dsa5solo`
definiert deshalb keinen eigenen Kopf, sondern ruft ihn auf — und **es kommt kein einziges
neues Maß hinzu**, weshalb `doku/MASSE.md` unberührt bleibt.

## 6. Zahl und Block hängen zusammen

Es darf nie vorkommen, dass die Zahl unten auf einer Seite steht und ihr Block erst auf der
nächsten beginnt. Umbrüche sind nur **innerhalb** des Blocktextes erlaubt.

`\dsaabschnitt` bringt dafür schon `\nobreak` mit, das verbietet den Bruch direkt hinter der
Zahl. Das allein genügt nicht: der Bruch wäre dann nach der *ersten* Textzeile erlaubt, und
eine einzelne Zeile bliebe bei ihrer Zahl zurück. Der Blockkopf ruft deshalb zusätzlich
`\@afterheading` auf, das `\clubpenalty` sperrt und die Sperre nach dem ersten Absatz von
selbst zurücknimmt.

Geprüft wird das am fertigen PDF, nicht am Quelltext — siehe Abschnitt 10.

## 7. Wie die Seitenregel zustande kommt

Die Aufgabe ist zirkulär: Wo ein Block steht, folgt aus seiner Nummer, und ob die Bedingung
hält, folgt daraus, wo er steht.

Aufgelöst wird das über **Behälter, und ein Behälter ist genau eine Doppelseite**. Die Nummern
werden behälterweise aufsteigend vergeben, an jeder Behältergrenze steht ein erzwungener
Umbruch. Damit wird aus der Sichtbarkeitsbedingung eine reine Graphbedingung:

> Für jede Sprungkante (a → b): Behälter(a) ≠ Behälter(b).

Das Werkzeug färbt dafür den Sprunggraphen (DSATUR) und packt jede Farbklasse für sich in
Behälter. Weil ein Behälter damit Teilmenge einer Farbklasse bleibt, ist die Bedingung nach dem
Packen automatisch erfüllt.

Eine Doppelseite ist links **gerade**, rechts ungerade (2|3, 4|5); `\soloBehaelterEnde`
erzwingt deshalb eine gerade Folgeseite. `\dsa@aufrechteSeite` der Kernklasse macht das
Gegenteil und ist hier nicht zu gebrauchen — es ist für Kapitelanfänge gebaut, die rechts
beginnen.

**Auch vor dem ersten Behälter steht eine Grenze.** Ohne sie läge die Einleitung, die auf den
Startblock verweist, auf derselben Doppelseite wie dieser. Das ist keine Theorie: ohne diese
Zeile meldete die Prüfung am Lasttest genau einen Verstoß, und zwar diesen.

### Warum das ohne Nachbau des Seitenbauers auskommt

Ein Messfehler kostet Papier, nicht Richtigkeit:

* **Behälter zu voll** → er läuft auf eine dritte Seite über und belegt zwei Doppelseiten. Seine
  Blöcke verteilen sich, aber jeder Sprung aus ihm heraus führt per Konstruktion in einen
  *anderen* Behälter, und der liegt auf einer dritten Doppelseite. Die Regel hält.
* **Behälter zu leer** → eine Füllseite. Die Regel hält.

Deshalb genügen gemessene Rasterhöhen, und TeX' Seitenbauer muss nicht nachgebildet werden.

## 8. Der Rückhalt

Eine Doppelseite fasst 59 Grundlinien je Spalte mal vier Spalten, also 236 Rastereinheiten.
Vollständig füllen lässt sie sich nicht: rund um jeden Blockkopf geht Platz verloren —
`\dsaRasterluft` davor, `\nobreak` dahinter, dazu Widow- und Clubpenalty, die den Umbruch
vorziehen.

**Wie viel, ist gemessen, nicht geschätzt.** Am gesetzten Heft, als Differenz zwischen belegten
und geplanten Rastereinheiten je Behälter:

| Blöcke | 5 | 10 | 22 | 24 | 25 | 34 | 43 | 44 |
|---|---|---|---|---|---|---|---|---|
| Aufschlag | 3 | 8 | 12 | 11 | 10 | 10 | 27 | 25 |

Der Aufschlag wächst mit der **Zahl** der Blöcke, nicht mit ihrer Höhe. Das Werkzeug rechnet
deshalb mit `0,8 × Blockzahl + 4` — dem ungünstigsten gemessenen Verhältnis plus etwas Luft,
denn ein übergelaufener Behälter kostet eine ganze Leerseite, ein zu großer Rückhalt nur ein
paar Zeilen.

Gegen die Nachbarwerte geprüft, jeweils voll gebaut und am PDF gemessen:

| Faktor | Seiten | Leerseiten | Verschnitt |
|---|---|---|---|
| 0,7 | 27 | 3 | 450 |
| **0,8** | **21** | **keine** | **273** |
| 0,9 | 23 | 1 | 332 |

Im Lasttest enden damit 18 von 42 Spalten mit nur einer freien Rastereinheit, weitere 16 mit
zwei bis acht. Die verbliebenen großen Lücken sind die Einleitungsseite und das Heftende —
dort steht schlicht wenig, das ist kein Verschnitt.

### Der Ausgleich

Das Packen füllt gierig: Die ersten Behälter werden randvoll, der letzte bekommt den Rest. Im
Satz ist genau das der schlimmste Fall — ein Behälter mit 95 von 236 Einheiten füllt eine
Seite, und die zweite seiner Doppelseite bleibt **vollständig leer**.

Das Werkzeug gleicht die Füllung deshalb nachträglich an, und zwar nur dorthin, wo kein
Nachbar aus dem Sprunggraphen liegt. Im Lasttest sank die Spanne dadurch von 95–228 auf
189–208 Einheiten.

**Bei kurzen Solos ist das Gegenteil richtig.** Füllt ein Behälter ohnehin keine ganze Seite,
macht Gleichverteilung alles schlimmer: Statt weniger voller Behälter und eines mageren gibt
es dann lauter Behälter, die je eine Seite füllen und die zweite leer lassen. Der Ausgleich
greift deshalb nur, wenn die mittlere Füllung mindestens eine Seite beträgt.

### Warum zehn Doppelseiten und nicht neun

2002 Rastereinheiten Inhalt passen rechnerisch auf neun Doppelseiten (2124 Kapazität). Es geht
trotzdem nicht: Bei neun Behältern müssten alle auf 222 von 236 Einheiten gefüllt werden, der
gemessene Aufschlag beträgt aber 3 bis 26. Jeder Behälter am oberen Ende läuft über, reicht in
die nächste Doppelseite hinein und erzwingt dort eine Füllseite — am Satz nachgerechnet 32
Seiten mit sechs Leerseiten statt 21 ohne.

Zehn Doppelseiten sind das Minimum, und die 358 Einheiten Überkapazität verteilen sich als
Luft an den zehn Behälterenden.


### Die Untergrenze: so viele Doppelseiten wie Farben

Ein kleines Solo kann Papier verschwenden, ohne dass daran etwas zu machen ist. Die Zahl der
Doppelseiten ist **mindestens so groß wie die Zahl der Farben**, die der Sprunggraph braucht —
zwei Blöcke mit einem Sprung dazwischen dürfen nie im selben Behälter liegen, und das gilt
auch dann, wenn beide zusammen eine Seite füllen würden.

Der Regellauf zeigt das: 30 Blöcke mit zusammen 322 Rastereinheiten passen rechnerisch auf zwei
Doppelseiten (472 Einheiten Kapazität), brauchen aber drei Behälter, weil der Graph drei Farben
verlangt. Im Schnitt bleiben 107 Einheiten je Behälter — weniger als die 118 einer einzelnen
Seite. Der kleinste Behälter füllt deshalb nur eine Seite, endet auf einer geraden, und die
Paritätskorrektur setzt eine Leerseite daneben.

Bei 238 Blöcken tritt das nicht auf: dort ist genug Material da, um jede Doppelseite zu füllen.
Die Regel lautet also — je kürzer das Solo, desto größer der Verschnitt.

## 9. Bilder im Block

Bilder kommen mit den Befehlen der Kernklasse in den Block, vor allem
`\dsaBildSpalte{datei}{einheiten}`. Sie brauchen nichts Besonderes: der Messlauf setzt den
ganzen Block in eine Box, misst ihn samt Bild und kennt die Höhe. Ein Bild darf also überall
im Block stehen.

```latex
egin{soloBlock}[zusammen]{keller}
\dsaBildSpalte{grafiken/fiole}{6}

Unten ist es trocken und still …
\end{soloBlock}
```

**Damit Bild und Text zusammenbleiben, braucht es die Option `zusammen`.** `\dsaBildRaster`
bringt zwar ein eigenes `\nobreak` mit und klebt damit an seinen Nachbarzeilen, aber das bindet
nicht den ganzen Block — der Satz darf weiter oben oder unten umbrechen, und dann steht das
Bild allein. Mit `zusammen` landet der Block vollständig in einer Spalte oder vollständig in
der nächsten.

Am Regellauf gemessen, drei Blöcke im Vergleich:

| Block | Höhe | Zahl auf Seite | Verweis auf Seite | |
|---|---|---|---|---|
| `dach`, gewöhnlich | 9 | 4 | 5 | umbrochen |
| `keller`, mit Bild und `zusammen` | 18 | 6 | 6 | hält zusammen |
| `ruecken`, `zusammen` | 9 | 7 | 7 | hält zusammen |

Zwei Dinge sind dabei zu beachten:

* **Der Block muss in eine Spalte passen**, also höchstens 59 Rastereinheiten hoch sein. Sonst
  läuft er unten heraus; das Werkzeug meldet es beim Lösen, das Paket warnt im Satz.
* **Umgesetzt ist das über Umbruchsperren, nicht über eine Box.** Eine Box wäre der
  naheliegende Weg, weil sie von sich aus unteilbar ist — sie verträgt sich aber nicht mit dem
  Raster: Ihre Höhe müsste auf Rastervielfache gerundet und die Box um den gerundeten Wert
  abgesenkt werden, und diese Differenz verschiebt den gesamten Inhalt. Penalties lassen die
  vertikale Liste unverändert, das Raster kann also gar nicht erst brechen.

## 10. Prüfen

```sh
python3 werkzeuge/solo.py --pruefen beispiel/solo.aux
```

Geprüft wird zweierlei:

**Die Doppelseitenregel, aus der `.aux`.** Am Blockkopf steht ein `\label`, an jeder
Sprungstelle ein aufgeschobener Write mit `\thepage` — nur der kennt die Seitenzahl, weil sie
erst beim Ausschießen feststeht. Maßgeblich ist die Seite, auf der **der Verweis** steht, nicht
die des Blockkopfes: ein Block darf über die Grenze laufen.

**Die Kopfregel, am PDF.** Liegt das gesetzte PDF neben der `.aux`, sieht das Werkzeug zusätzlich
nach, ob unter jeder Blockzahl noch Text derselben Spalte steht.

Eine Falle bei eigenen Messungen am PDF: Zeilen dürfen **nicht allein nach der Grundlinie**
gruppiert werden. Im Raster sitzen die Zeilen beider Spalten auf gleicher Höhe, verschmelzen
dabei zu einer Zeile, und die Zahl wird nicht mehr als Zahl erkannt. Nach Grundlinie *und*
Spalte gruppiert, stieg die Trefferzahl im Regellauf von 6 auf 30 von 30.

## 11. Was das Werkzeug sonst noch meldet

* **Marke doppelt vergeben** — Abbruch, denn ein Block fiele sonst still aus dem Heft.
* **Block größer als eine Doppelseite** — er belegt zwei; die Regel hält trotzdem.
* **Verweis auf unbekannte Marke** — im Satz erscheint ein rotes `??` in der Breite einer
  echten Zahl, damit der Umbruch derselbe bleibt wie im Messlauf.
* **Vom Start nicht erreichbar** — dieser Block wird gedruckt, aber nie gelesen.
* **Ohne Weg zu einem Ende** — von hier aus läuft der Leser im Kreis. Das ist die Prüfung, die
  beim Lesen am schwersten auffällt: jeder einzelne Block hat einen Ausgang, die Gruppe als
  ganze aber nicht.
* **Ohne eingehenden Verweis** — auf diesen Block zeigt niemand. Nur der Startblock darf das.
* **Sackgasse ohne `\soloEnde`** — ein Block ohne ausgehenden Verweis, der sich nicht als Ende
  ausgewiesen hat.

## 12. Fallstricke

* **Der Messlauf ist Pflicht.** Ohne `solo.solo` weiß das Werkzeug keine Höhen; ohne
  `reihenfolge.tex` setzt `dsa5solo` die Blöcke in Autorenreihenfolge, warnt und die
  Doppelseitenregel gilt dann **nicht**.
* **Nach jeder Textänderung neu messen.** Ein längerer Block verschiebt die Aufteilung.
* **Die Nummernbreite** ist im Messlauf ein Platzhalter mit der größtmöglichen Stellenzahl. Die
  gemessene Höhe ist damit eine obere Schranke — die echte Zahl ist nie breiter, und zu groß
  gemessen kostet nach Abschnitt 7 nur Papier.
* **`\clearpage` in einem Block** zerreißt die Behälteraufteilung.
* **Das PDF im Betrachter schließen, bevor gebaut wird.** Unter Windows sperrt ein geöffnetes
  PDF die Datei; `xdvipdfmx` kann dann nicht schreiben, meldet `Error 1 (driver return code)`
  und der Lauf bricht ab. Tückisch daran: `.aux` und PDF sind danach gemeinsam unvollständig,
  stimmen also miteinander überein. Das Prüfwerkzeug erkennt das an der Nummernzuordnung und
  meldet „UNVOLLSTAENDIG“ — ohne diesen Abgleich meldete es Erfolg für ein halbes Heft. Wer von
  Hand prüfen will, ob eine Datei frei ist: Umbenennen zeigt es zuverlässig, Anhängen von
  leerem Inhalt gelingt auch bei gesperrten Dateien.
* **Die Kette bricht mit dem ersten Fehler ab.** Scheitert der Messlauf, läuft das Werkzeug gar
  nicht erst, und der Satzlauf arbeitet mit der alten Zuordnung weiter — ohne Warnung.
* Die erzeugten Dateien (`*.solo`, `*.solonummern`, `solo-aus/`) sind abgeleitet und stehen in
  `.gitignore`.

## 13. Beispiele

| Datei | wofür |
|---|---|
| `beispiel/solo.tex` | der Regellauf: 30 Blöcke, drei Doppelseiten |
| `beispiel/solo-bloecke.tex` | die Blöcke dazu, in Autorenreihenfolge |
