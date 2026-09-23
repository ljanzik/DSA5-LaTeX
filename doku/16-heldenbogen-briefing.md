# Briefing: ausfüllbarer Heldenbogen mit LaTeX

*Für eine neue Sitzung in einem neuen Projekt. Diese Datei ist absichtlich vollständig — sie lässt
sich in das neue Projektverzeichnis kopieren und reicht dort als einzige Vorgabe. Alles darin ist
gemessen, nicht geschätzt; wo etwas offen ist, steht es als offen.*

---

## 1. Was gebaut werden soll

Aus dem offiziellen DSA5-Heldendokument sollen **zwei** PDF entstehen, aus **einer** Quelle:

1. **Die ausfüllbare Fassung.** Echte Formularfelder, in die ein Spieler am Rechner tippt und die
   er speichern kann. AcroForm, nicht Bildbearbeitung.
2. **Die vorbefüllte Fassung.** Dieselben Felder, aber die Werte kommen aus einer Datei je Held und
   sind fest eingesetzt. Damit fallen die vier vorgefertigten Helden für „Der falsche Ganter" als
   fertige Bögen an — sie sind im Abenteuer als Ausschneidebogen vorgesehen.

Beide sollen **aussehen wie das Original**. Der Bogen wird nicht nachgebaut, sondern überlagert.

---

## 2. Die Quelldatei, gemessen

`~/Downloads/Heldendokument_druckerfreundlich.pdf`

| | |
|---|---|
| Größe | 826 KB |
| Seiten | **6** |
| Seitenformat | `/MediaBox [0 0 595.276 841.89]` = **A4, 210 × 297 mm**, alle Seiten gleich |
| Formularfelder | **keine** — `/AcroForm` 0 Treffer, `/Widget` 0 Treffer |
| Text | vorhanden und extrahierbar, also keine Bildseiten |

Das ist der entscheidende Befund: eine flache Druckdatei ohne jede Interaktivität. Es gibt nichts
zu reparieren, es muss etwas darübergelegt werden.

---

## 3. Der Weg: überlagern, nicht nachbauen

```
pdfpages  →  Originalseite als Grund
hyperref  →  Formularfelder absolut darüber positioniert
tikz      →  das Koordinatensystem zum Einmessen
```

**Warum nicht nachbauen.** Der Bogen hat auf sechs Seiten mehrere hundert Linien, Raster und
Beschriftungen. Ein Nachbau dauert Tage, sieht anders aus und muss bei jeder neuen Auflage des
Bogens wiederholt werden. Die Überlagerung braucht nur die Feldpositionen und bleibt beim Original.

**Warum ein eigenes Projekt.** Das Satzprojekt des Abenteuers liegt unter
`kampagnen/fuchsgrund/satz/` und läuft zwingend mit **XeLaTeX**, weil DSaTeX `fontspec` lädt. Der
Heldenbogen braucht keine dieser Schriften und keine dieser Klasse. Er sollte mit **pdflatex**
gebaut werden, weil `hyperref`s Formularfelder dort weit besser erprobt sind als unter XeLaTeX. Die
beiden Projekte haben nichts gemeinsam außer dem Anlass — sie gehören getrennt.

---

## 4. Vorgehen in fünf Schritten

### Schritt 1 — Grundgerüst, eine Seite, ein Feld

Das kleinste Ding, das läuft. Erst wenn das steht, weitermachen.

```latex
\documentclass[a4paper]{article}
\usepackage[margin=0pt]{geometry}
\usepackage{pdfpages}
\usepackage{tikz}
\usepackage[pdftex]{hyperref}

\begin{document}
\begin{Form}
  \includepdf[pages=1, picturecommand={%
    \begin{tikzpicture}[remember picture, overlay]
      \node[anchor=north west] at ([shift={(20mm,-20mm)}]current page.north west)
        {\TextField[name=name, width=60mm, height=5mm, bordercolor=]{}};
    \end{tikzpicture}}]{Heldendokument_druckerfreundlich.pdf}
\end{Form}
\end{document}
```

Prüfen: kommt ein Feld heraus, in das man im PDF-Betrachter tippen kann? Wenn ja, ist der ganze
Ansatz tragfähig und der Rest ist Fleißarbeit.

`bordercolor=` leer lässt den Rahmen weg — das Original hat seine Linien schon.

### Schritt 2 — Das Messgitter

Das ist der Kern der Machbarkeit. Ohne Werkzeug müsste man 200 Positionen raten; mit einem
Messgitter liest man sie ab.

Über jede Originalseite ein TikZ-Gitter legen, Linien alle 10 mm, beschriftet in Millimeter vom
linken und oberen Papierrand. Einmal kompilieren, das PDF auf den Bildschirm, und dann Feld für
Feld ablesen: linke Kante, obere Kante, Breite, Höhe.

```latex
\newcommand{\messgitter}{%
  \begin{tikzpicture}[remember picture, overlay]
    \foreach \x in {0,10,...,210}{
      \draw[cyan!40, line width=0.1pt]
        ([shift={(\x mm,0)}]current page.north west) --
        ([shift={(\x mm,0)}]current page.south west);
      \node[cyan, font=\tiny, anchor=north]
        at ([shift={(\x mm,-2mm)}]current page.north west) {\x};}
    \foreach \y in {0,10,...,290}{
      \draw[cyan!40, line width=0.1pt]
        ([shift={(0,-\y mm)}]current page.north west) --
        ([shift={(0,-\y mm)}]current page.north east);
      \node[cyan, font=\tiny, anchor=west]
        at ([shift={(2mm,-\y mm)}]current page.north west) {\y};}
  \end{tikzpicture}}
```

Das Gitter kommt in eine Option `messen`, die man ein- und ausschaltet. Es bleibt im Projekt — bei
jeder Korrektur wird es wieder gebraucht.

**Alle Koordinaten in Millimeter von der linken oberen Papierecke.** Nicht in Punkt, nicht von
unten. Ein Bezugspunkt, konsequent, sonst wird das Einmessen zur Fehlerquelle.

### Schritt 3 — Die Feldtabelle

Eine Datei, die nur Daten enthält, kein Layout. Jede Zeile ein Feld:

```latex
% \feld{seite}{name}{x}{y}{breite}{hoehe}{art}
\feld{1}{name}         {28}{22}{62}{5}{text}
\feld{1}{geschlecht}   {28}{30}{62}{5}{text}
\feld{1}{spezies}      {28}{38}{62}{5}{text}
\feld{1}{mu_wert}      {96}{74}{ 8}{5}{zahl}
\feld{1}{mu_bonus}     {105}{74}{ 8}{5}{zahl}
...
```

Dieselbe Tabelle erzeugt beide Fassungen: `\feld` wird einmal als `\TextField` definiert und
einmal als fester Text. Das ist der ganze Trick, und er ist der Grund, warum die Tabelle strikt von
der Darstellung getrennt bleiben muss.

Für die vorbefüllte Fassung dazu eine Wertedatei je Held:

```latex
% helden/dorle.tex
\wert{name}{Dorle Griesgram}
\wert{spezies}{Mensch}
\wert{mu_wert}{11}
```

Fehlt ein Wert, bleibt das Feld leer. Kein Abbruch.

### Schritt 4 — Einmessen, Seite für Seite

Die Reihenfolge ist bewusst: Seite 1 und 3 zuerst, weil sie die meisten Einzelfelder haben und die
meisten Fehler zeigen. Seite 2 zuletzt, weil sie fast nur Tabellenzeilen hat und sich dann
generieren lässt.

**Seite 2, 3 und 6 sind Tabellen** — dort werden nicht 80 Felder einzeln eingemessen, sondern eine
Zeilenhöhe und ein Startwert, und die Zeilen entstehen in einer Schleife:

```latex
\foreach \i in {1,...,28}{
  \feldrelativ{2}{talent_fw_\i}{68}{\the\numexpr 62+7*\i}{8}{5}{zahl}}
```

Erst Zeilenhöhe und Startwert am Gitter prüfen, dann die Schleife. Damit fällt der Aufwand von
mehreren Hundert Feldern auf etwa 40 eingemessene Werte.

### Schritt 5 — Gegenprobe

Fertig ist es, wenn:

- die ausfüllbare Fassung sich in mindestens zwei Betrachtern ausfüllen **und speichern** lässt
  (Adobe Reader und ein zweiter, etwa Firefox oder Edge — die Umsetzungen unterscheiden sich)
- kein Feld auf einer Linie des Originals liegt oder eine Beschriftung verdeckt
- die vorbefüllte Fassung für einen Testhelden alle Werte an der richtigen Stelle zeigt
- ein Held mit fehlenden Werten durchläuft, ohne dass der Lauf abbricht

---

## 5. Die Felder, nach Seiten

Aus der Textextraktion aller sechs Seiten. Das ist der Bestand, nicht eine Auswahl.

**Seite 1 — Persönliche Daten und Charakteristika.** Name, Geschlecht, Spezies, Kultur, Profession,
Sozialstatus, Heimatort, Familie, Alter/Geburtsdatum, Haarfarbe, Augenfarbe, Größe, Gewicht ·
die acht Eigenschaften MU KL IN CH FF GE KO KK, je mit **Wert, Bonus/Malus, Zukauf, Max** ·
Vorteile, Nachteile (mehrzeilig) · Lebensenergie, Astralenergie, Karmaenergie mit ihren
Berechnungshinweisen.

**Seite 2 — Talente.** Belastung · fünf Gruppen: Körper-, Gesellschafts-, Natur-, Wissens-,
Handwerkstalente. Je Talent die Spalten **Talent, Probe, BE, StF, Fw, RPr, Anmerkung**. Probe, BE
und StF sind im Original schon eingedruckt — dort werden **keine** Felder gebraucht, nur für Fw,
RPr und Anmerkung. Das halbiert die Feldzahl dieser Seite.

**Seite 3 — Kampfwerte.** GS, LE, AW, INI, SK, ZK · Kampftechniken in zwei Spalten (Armbrüste,
Bögen, Dolche, Fechtwaffen, Hiebwaffen, Kettenwaffen, Lanzen, Raufen, Schilde, Schwerter,
Stangenwaffen, Wurfwaffen, Zweihandhiebwaffen, Zweihandschwerter), je mit **Leiteigenschaft, StF,
KTW, AT/FK, PA**. Leiteigenschaft und StF sind eingedruckt, nur KTW, AT/FK und PA brauchen Felder.

**Seite 4 — Liturgien und Zeremonien.** KaP max und aktuell · Tradition, Leiteigenschaft, Aspekt,
wohlgefällige Talente, klerikale Sonderfertigkeiten, Zeremonialgegenstand, Segnungen · Tabelle mit
**Liturgie/Zeremonie, Probe, Fw, Kosten, Liturgiedauer, Reichweite, Wirkungsdauer, Aspekt, StF,
Wirkung, S.**

**Seite 5 — Zauber und Rituale.** Baugleich zu Seite 4: AsP max und aktuell · Tradition,
Leiteigenschaft, Merkmal, magische Sonderfertigkeiten, Traditionsartefakt, Zaubertricks · Tabelle
mit **Zauber/Ritual, Probe, Fw, Kosten, Zauberdauer, Reichweite, Wirkungsdauer, Merkmal, StF,
Wirkung, S.**

Seite 4 und 5 sind dieselbe Geometrie mit anderen Beschriftungen — einmal einmessen, zweimal
verwenden.

**Seite 6 — Ausrüstung.** Zwei Spalten **Gegenstand, Gewicht, Wo getragen?** · Gesamtgewicht,
Tragkraft (KK×2) · die vier Belastungsstufen (+4, +8, +12, +16 Stein) · Geldbeutel mit **Dukaten,
Silbertaler, Heller, Kreuzer** · Tierbogen mit Name, Typus, LO, AP, LeP, AsP und den acht
Eigenschaften.

---

## 6. Was gebraucht wird

| Was | Prüfen mit | Anmerkung |
|---|---|---|
| **pdflatex** | `pdflatex --version` | nicht XeLaTeX, siehe Abschnitt 3 |
| `pdfpages` | in jeder vollständigen Installation | |
| `hyperref` | dito | |
| `tikz` | dito | |
| ein zweiter PDF-Betrachter | | zur Gegenprobe, siehe Schritt 5 |

Auf dem Rechner, auf dem dieses Briefing entstand, war **kein LaTeX installiert**. TeX Live sollte
installiert werden; `winget` hat kein Paket dafür, der Installer liegt bei tug.org:

```
curl -o "$env:TEMP\install-tl-windows.exe" https://mirror.ctan.org/systems/texlive/tlnet/install-tl-windows.exe
```

MiKTeX gäbe es über `winget install MiKTeX.MiKTeX` und reicht für diesen Zweck genauso.

---

## 7. Was schiefgehen kann

Nach Wahrscheinlichkeit sortiert.

1. **`\TextField` außerhalb von `\begin{Form}`.** Erzeugt kein Feld und keine Fehlermeldung. Genau
   ein `Form` um das ganze Dokument.
2. **Feldnamen doppelt.** Zwei Felder mit demselben `name` werden von AcroForm als **ein** Feld mit
   gespiegeltem Inhalt behandelt — tippt man in das eine, ändert sich das andere. Bei einer
   Tabellenschleife über sechs Seiten passiert das schnell. Namensschema festlegen und einhalten,
   etwa `s2_talent_fw_07`.
3. **`picturecommand` und `remember picture`.** `remember picture` braucht zwei Läufe. Beim ersten
   Lauf liegen alle Felder in der linken oberen Ecke. Immer zweimal kompilieren, bevor man ein
   Positionsproblem für echt nimmt.
4. **Feldhöhe gegen Schriftgröße.** Ein 5 mm hohes Feld mit 11 pt Schrift schneidet unten ab.
   `\TextField[height=5mm, charsize=8pt]`.
5. **Mehrzeilige Felder** (Vorteile, Nachteile, Ausrüstungszeilen) brauchen `multiline=true`, sonst
   scrollt der Text in einer Zeile weg.
6. **Speichern.** Manche Betrachter speichern Formulardaten nur, wenn das PDF es erlaubt. Wenn die
   Gegenprobe scheitert, ist das der erste Verdacht — nicht die Felddefinition.
7. **Die Größe.** Sechs Originalseiten plus Felder: das PDF wird kaum größer als das Original, weil
   `pdfpages` die Seiten einbettet und nicht neu rendert. Wird es deutlich größer, wird irgendwo neu
   gerendert.

---

## 8. Rechtliches

Der Bogen ist **Material von Ulisses Spiele**. Für den Eigengebrauch und die eigene Spielrunde ist
das Überlagern mit Formularfeldern unbedenklich.

**Weitergabe ist etwas anderes.** Die veränderte Fassung enthält die Originaldatei vollständig; sie
zu verteilen heißt, eine Verlagsdatei erneut zu veröffentlichen. Das ist von der Vereinbarung über
Gemeinschaftsinhalte für SCRIPTORIUM AVENTURIS nicht ohne weiteres gedeckt. Vor einer Beilage zum
Abenteuer klären.

**Praktischer Ausweg, falls die Weitergabe nicht geht:** die vorbefüllte Fassung nur als **Bild der
Werte ohne den Originalbogen** ausgeben — also ein eigenes, schlichtes Blatt mit denselben Werten.
Das ist keine Verlagsdatei mehr. Es sieht weniger gut aus, ist aber weitergebbar. Diese Variante
sollte im Projekt von Anfang an mitgedacht werden, weil sie dieselbe Feldtabelle benutzt.

---

## 9. Was nicht gemacht werden soll

- **Den Bogen nicht nachbauen.** Nicht die Linien, nicht die Raster, nicht die Beschriftungen.
  Überlagern.
- **Nicht mit XeLaTeX.** Siehe Abschnitt 3.
- **Keine Regelwerte fest eintragen**, die nicht im Bogen stehen. Der Bogen enthält Probenformeln
  und Belastungsstufen bereits eingedruckt; die werden nicht wiederholt und nicht nachgerechnet.
- **Keine Berechnung der abgeleiteten Werte.** LeP, AsP, KaP, AW, INI und Tragkraft haben im Bogen
  ihre Formeln aufgedruckt. Ob das Projekt sie rechnet, ist eine eigene Entscheidung und nicht Teil
  dieses Auftrags — erst die Felder, dann darüber reden.

---

## 10. Herkunft dieses Briefings

Entstanden am 7. September 2026 als Nebenzweig der Arbeit am LaTeX-Satz von „Der falsche Ganter".
Alle Angaben zur Quelldatei sind gemessen: Seitenzahl und `/MediaBox` aus der Datei selbst, die
Abwesenheit von Formularfeldern über die Suche nach `/AcroForm` und `/Widget`, die Feldbestände über
`pdftotext -layout` je Seite.

Verwandt, aber getrennt: das Satzprojekt unter `kampagnen/fuchsgrund/satz/` mit
`kampagnen/fuchsgrund/satz/ANLEITUNG.md`. Von dort ist **nichts** wiederverwendbar außer der
Erkenntnis, dass Maße gemessen und nicht geschätzt werden.

*Kein Kanon. Werkzeug, keine Spielwelt.*
