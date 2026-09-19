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
2. **Die Verweise.** `\soloWeiter{marke}` setzt die Zahl, die die Marke am Ende bekommen hat.
3. **Der Seitenwechsel.** Quelle und Ziel eines Sprungs liegen nie auf derselben Doppelseite.
   Wer bei 47 die Wahl trifft und 100 schon vor sich liegen hat, liest beides — und die
   Entscheidung ist entwertet.

Punkt 3 ist der eigentliche Grund für das Werkzeug. Von Hand ist er ab etwa dreißig Blöcken
nicht mehr zu halten, weil jeder eingeschobene Block alles dahinter verschiebt.

## 2. Vorbereiten

`dsa5solo` setzt auf der Kernklasse auf und bringt kein eigenes Maß mit:

```latex
\documentclass[raster]{dsa5latex}
\usepackage{dsa5solo}
```

Der Autor schreibt alle Blöcke in **eine** Datei, in beliebiger Reihenfolge:

```latex
\begin{soloBlock}{tor-der-stadt}
Du stehst vor dem Tor. Die Wachen mustern dich unfreundlich.

Gehst du hinein, lies bei Abschnitt \soloWeiter{markt} weiter. Wendest du dich ab,
so geht es bei Abschnitt \soloWeiter{wald} weiter.
\end{soloBlock}
```

Marken bestehen aus Buchstaben, Ziffern und Bindestrichen; das Werkzeug prüft das und meldet
eine doppelt vergebene Marke als Fehler — sie wäre sonst ein stiller: der zweite Block
überschriebe den ersten, und die Verweise zeigten auf den falschen Text.

Im Hauptdokument stehen nur noch drei Zeilen:

```latex
\soloStart{tor-der-stadt}     % dieser Block trägt immer die 1
\soloBloecke{solo-bloecke}    % die Datei mit allen Blöcken
```

## 3. Bauen

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
| `\soloWeiter{marke}` | setzt die Zahl des Zielblocks, sonst nichts — die Einkleidung wählt der Autor |
| `\soloEnde` | dieser Block ist ein gewolltes Ende, keine Sackgasse |
| `\soloStart{marke}` | dieser Block steht am Anfang und trägt die 1 |
| `\soloBloecke{datei}` | bindet die Blöcke ein, im Satzlauf in der berechneten Reihenfolge |
| `\soloOrdner{pfad}` | wohin das Werkzeug geschrieben hat, falls nicht `solo-aus` neben der `.tex` |
| `\soloStellen{n}` | Stellenzahl des Platzhalters im Messlauf; das Werkzeug setzt sie selbst |
| `\soloBehaelterEnde` | Ende einer Doppelseite; steht in der erzeugten Reihenfolgedatei |

`\soloWeiter` setzt bewusst nur die Zahl. „zu Abschnitt \soloWeiter{wald}" und
„(\soloWeiter{wald})" sind damit gleichermaßen möglich.

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
Vollständig füllen lässt sie sich nicht: an den drei inneren Spaltengrenzen bleibt Platz
liegen, weil `\nobreak` und `\clubpenalty` den Block zusammenhalten und was nicht mehr ganz
hinpasst, vollständig in die nächste Spalte rutscht.

Am Satz gemessen wächst dieser Verlust mit der **Zahl** der Blöcke, nicht mit ihrer
Gesamthöhe. Im Lasttest brauchten Behälter mit 5 und mit 11 Blöcken ihre zwei Seiten, die mit
27, 32, 50 und 55 Blöcken eine dritte — bei nahezu gleicher Summe von 226 bis 228 Einheiten.

Der Rückhalt ist deshalb nicht fest, sondern `4 × mittlere Blockhöhe`, mindestens aber der Wert
von `--rueckhalt` (Standard 8).

**Gezählt werden vier Grenzen, nicht drei** — obwohl eine Doppelseite nur drei innere
Spaltengrenzen hat. Der Verlust an der vierten, dem Behälterende, entscheidet nämlich darüber,
ob der Behälter auf eine dritte Seite überläuft, und das ist teuer: Ein übergelaufener Behälter
reicht in die nächste Doppelseite hinein, der folgende darf dort nicht beginnen, und es
entsteht eine **Leerseite**. Genau daher kamen die Leerseiten im Lasttest.

Die vierte Grenze mitzuzählen macht das Heft deshalb nicht länger, sondern kürzer:

| Lasttest, 238 Blöcke | drei Grenzen | vier Grenzen |
|---|---|---|
| überlaufende Behälter | 3 von 10 | **0** |
| Leerseiten | 3 | **keine** |
| Seiten gesamt | 27 | **23** |

### Die Lücken am Spaltenfuß

Im Satz bleibt am Fuß mancher Spalte Platz frei, am auffälligsten in der zweiten Spalte
rechter Seiten — also am Ende jeder Doppelseite. Das sieht nach einem Fehler aus, ist aber der
Rückhalt, sichtbar geworden: Was reserviert wird, damit der Behälter nicht überläuft, steht am
Schluss leer.

Am Lasttest gemessen sind 21 von 44 Spalten bis auf eine Rastereinheit gefüllt; die großen
Lücken von 27 bis 38 Einheiten sitzen sämtlich am Behälterende. Zusammen sind das 449 von
2716 Einheiten, also gut ein Sechstel.

**Wegoptimieren lässt sich dieser Verschnitt nicht, nur verschieben.** Mit halbiertem Rückhalt
füllen sich die Behälter zwar auf 200 statt 182 Einheiten — dafür laufen drei über, und der
gewonnene Platz geht in Füllseiten wieder verloren:

| Rückhalt | Füllung | Verschnitt | Leerseiten | Seiten |
|---|---|---|---|---|
| zwei Grenzen | 200 | 450 | 3 | 27 |
| vier Grenzen | 182 | **449** | **keine** | **23** |

Der Verschnitt ist in beiden Fällen derselbe. Die Frage ist nur, ob er als Lücke am Spaltenfuß
erscheint oder sich zu ganzen Leerseiten ballt — und vier Grenzen sind dabei die bessere Wahl.

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

### Der Rest jeder Farbklasse

Der zweite Grund für halb leere Doppelseiten liegt nicht am Rückhalt, sondern am Packen selbst:
Weil jede Farbklasse für sich gepackt wird, bleibt von jeder ein Rest übrig. Im Lasttest waren
das Behälter mit 80 und 96 von 236 Einheiten — sie belegen nur **eine** Seite, und die
Paritätskorrektur setzt eine Füllseite daneben. Im Satz stehen dann zwei Leerseiten dicht
beieinander.

Das Werkzeug löst solche Behälter deshalb nachträglich auf und verteilt ihre Blöcke auf die
übrigen — aber nur dorthin, wo kein Nachbar aus dem Sprunggraphen liegt, die Seitenregel bleibt
also unangetastet. Im Lasttest stieg der leerste Behälter dadurch von 80 auf 172 Einheiten, die
Zahl der Doppelseiten sank von elf auf zehn und die der Füllseiten von vier auf drei.

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
bringt zwar ein eigenes `
obreak` mit und klebt damit an seinen Nachbarzeilen, aber das bindet
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
  naheliegende Weg — sie ist von sich aus unteilbar. Ihre Höhe müsste aber auf Rastervielfache
  gerundet und die Box um den gerundeten Wert abgesenkt werden, und diese Differenz verschiebt
  den gesamten Inhalt. So gesetzte Blöcke lagen im Satz 0,20 und 2,44 bp neben dem Raster.
  Penalties lassen die vertikale Liste unverändert, das Raster kann also gar nicht brechen.

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
* Die erzeugten Dateien (`*.solo`, `*.solonummern`, `solo-aus/`) sind abgeleitet und stehen in
  `.gitignore`.

## 13. Beispiele

| Datei | wofür |
|---|---|
| `beispiel/solo.tex` | der Regellauf: 30 Blöcke, drei Doppelseiten |
| `beispiel/solo-bloecke.tex` | die Blöcke dazu, in Autorenreihenfolge |
