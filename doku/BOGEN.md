# Der Heldenbogen

Diese Datei beschreibt `bogen/` — das Werkzeug, das aus dem offiziellen DSA5-Heldendokument
einen ausfüllbaren oder vorbefüllten Bogen macht, und die Charaktermappe als Umschlag dazu.
Es ist der einzige Teil dieses Projekts, der mit **pdflatex** läuft und ein Verlags-PDF einlegt;
alles andere setzt mit XeLaTeX aus eigenen Quellen. Die Klasse und ihre Elemente stehen in
`CLAUDE.md`, `doku/ELEMENTE.md` und `doku/MASSE.md`.

Der Bogen lag bis zum 10.09.2026 als eigenes Projekt unter `C:\SVN\dsa-charlatex`, ohne
Versionskontrolle. Er ist unverändert hierher übernommen worden; die Läufe erzeugen dieselben
Dateien wie dort, byte-genau in derselben Größe.

## Projektzustand

**Beide Fassungen sind vollständig befüllbar: alle sechs Bögen eingemessen und sichtgeprüft.**
Druckerfreundlich 1255 Felder, Farbfassung 1275. Alle Ausgabefassungen bauen.

**Die Charaktermappe steht: vier Blätter, zwei Ausgabefassungen, Rahmen selbst gezeichnet.**
Siehe Abschnitt „Die Charaktermappe".

`python bau/fassungen-vergleichen.py` sagt, was je Bogen zu erwarten war — und belegt, wie wenig
die Deckungszahl über den Aufwand verrät:

| Bogen | Deckung mit df | bester Versatz | was tatsächlich zu tun war |
|---|---|---|---|
| 1 | 87 % | 0,0 mm | Linien identisch, **Beschriftungen anders verteilt** |
| 2 | 93 % | 7,2 mm | Zeilen exakt +7,3 mm, aber andere Blockgrenze im Sprachenkasten |
| 3 | 22 % | — | eigenes Layout, vollständig neu eingemessen |
| 4 | 36 % | — | Tabelle zeilengleich mit df, unterer Teil neu |
| 5 | 37 % | — | baugleich mit Bogen 4 — nachgemessen: 92 % Linien, 97 % Kästen |
| 6 | 67 % | 33,9 mm | 36 statt 30 Zeilen, Geldbeutel in **umgekehrter** Reihenfolge |

Der Geldbeutel auf Bogen 6 ist die deutlichste Falle: dort steht Kreuzer, Heller, Silbertaler,
Dukaten — in df genau umgekehrt. Belegt an den Beschriftungen der Quelle (Kreuzer 139,8,
Heller 155,2, Silbertaler 166,2, Dukaten 181,4). Wer df kopiert, vertauscht die Währungen, und
kein Prüfskript merkt es.

Die Versätze sind je Bogen verschieden — es ist **keine** gleichmäßige Verschiebung, sondern eine
andere Auflage. **Deckung ist ein Hinweis, keine Erlaubnis zum Übernehmen.** Zwei Fälle, die das
schon belegt haben, beide nur an der Sichtprobe bzw. an den Textmarken aufgefallen:

- **Bogen 1**, 87 % Deckung: alle Schreiblinien liegen identisch, die Beschriftungen sind
  trotzdem anders verteilt — Kultur steht dort rechts, wo df links Geburtsdatum hat.
- **Bogen 2**, 93 % Deckung: die Talentzeilen liegen exakt 7,3 mm tiefer, aber der Sprachen-Kasten
  hat eine Zeile weniger *und* die Blockgrenze liegt anders (Sprachen 4 + Schriften 3 statt
  4 + 4). Wer den Versatz blind anwendet, setzt die Schrift über ihre Beschriftung.

- **Bogen 3**, 22 % Deckung: eine Kampftechnikspalte mit 14 Zeilen statt zwei mit acht,
  Kampfsonderfertigkeiten rechts statt unten, Nahkampf mit 9 statt 10 Spalten (TP nicht in
  Basis/Gesamt geteilt), Rüstungen und Schild mit vier statt drei Zeilen, Zustandsmatrix mit
  **sieben** statt elf Zeilen.

Deshalb gilt für jeden weiteren Bogen: Beschriftungen mit `--text` lesen, nicht aus df ableiten.

### Drei Fehler, die der Vergleich mit der Farbfassung in der **df**-Tabelle aufgedeckt hat

Sie standen dort seit dem Einmessen und wären ohne die zweite Fassung nicht aufgefallen:

1. **`Bögen` hatte ein PA-Feld, obwohl die Zelle durchgestrichen ist.** Bei 150 dpi verschmelzen
   die X von Armbrüste und Bögen optisch zu einem. Welche Zellen durchgestrichen sind, wird
   seither an den **Diagonalen im Content-Stream** abgelesen (zwei Segmente je X), nicht am Bild.
   Es sind vier: Armbrüste, Bögen, Kettenwaffen, Wurfwaffen.
2. **Die Zustandsmatrix hatte positionsbasierte Feldnamen** (`s3_zu_1` … `s3_zu_11`). Die
   Farbfassung hat nur sieben Zustände und in anderer Reihenfolge — `s3_zu_2` hätte in df
   Berauscht und in der Farbfassung Betäubung bedeutet. Jetzt heißen sie inhaltlich
   (`s3_zu_belastung_stufe1` …).
3. **Die erste Spalte der Waffen- und Rüstungstabellen beginnt nicht am Rahmen.** Links davor
   sitzt das Emblem der Tabelle; die eingedruckte Kopfzeile beginnt erst bei x 25,4…25,9. Meine
   Felder lagen bei 13,7 — also hinter dem Emblem und unlesbar. Beide Fassungen korrigiert.

Aufbau, alles unter `bogen/`:

| | |
|---|---|
| `heldenbogen.tex` | Hauptdatei, sechs `\bogenseite` in genau einem `Form` |
| `konfig.tex` | Pfade der Quell-PDF und die Seitenzuordnung beider Fassungen |
| `mechanik.tex` | Darstellungsebene: `\feld`, `\wert`, Widgets, Messgitter |
| `felder/df.tex`, `felder/farbe.tex` | Koordinatentabellen, je Quellfassung eine |
| `helden/<name>.tex` | Werte je Held (`leer.tex` ist die Probe auf den Leerfall) |
| `werteliste.tex` | dritte Fassung: Werte ohne den Originalbogen |
| `bau/` | Skripte; Ausgaben nach `bau/ausgabe/`, Bilder nach `bau/bilder/` |
| `bau/*.py` | die Logik, plattformneutral |
| `bau/*.ps1`, `bau/*.sh` | dreizeilige Weiterleitungen darauf |
| `bau/werkzeugpfad.py` | findet pdflatex und Ghostscript; ersetzt das frühere `texpfad.ps1` |
| `bau/geometrie.py` | der genaue Geometrie-Parser (siehe „Einmessen") |
| `mappe/mappe.tex` | vierte Ausgabefassung: die Charaktermappe (Umschlag) |
| `mappe/mechanik-mappe.tex` | Flechtbandrahmen, Pergament, Kästen, Titelsatz |
| `mappe/blaetter.tex` | die vier Blätter der Mappe, mit allen Layoutmaßen |

Die Skripte setzen das Arbeitsverzeichnis selbst auf `bogen/` (`PROJEKT` in
`bau/werkzeugpfad.py`, eine Ebene über `bau/`). Sie lassen sich deshalb von überall aufrufen,
und alle Pfade darin — `felder/`, `helden/`, `bau/ausgabe/` — bleiben relativ zu `bogen/`.

`bogen/bau/ausgabe/` und `bogen/bau/bilder/` sind in `.gitignore`. Darin steckt
Verlagsmaterial: jede überlagerte Fassung enthält die Quellseiten vollständig, und die
normalisierte Farbquelle ist eine Kopie der Verlagsdatei.

## Befehle

**Die Logik steht in `.py`, die `.ps1` und `.sh` sind dreizeilige Weiterleitungen.** Die Schalter
sind deshalb überall dieselben — auch unter macOS und Linux heißt es `-Held dorle` und nicht
`--held`. Von der Projektwurzel aus, Windows links, Unix rechts:

| Windows | macOS und Linux |
|---|---|
| `.\bogen\bau\bauen.ps1 -Held dorle` | `./bogen/bau/bauen.sh -Held dorle` |
| `.\bogen\bau\mappe-bauen.ps1 -Beide` | `./bogen/bau/mappe-bauen.sh -Beide` |
| … und so für alle sechs | … |

Wer den Umweg nicht braucht, ruft das Python direkt auf; das ist auf beiden Plattformen gleich
und deshalb die Schreibweise im Folgenden.

```sh
python3 bogen/bau/bauen.py                              # ausfüllbar, druckerfreundlich
python3 bogen/bau/bauen.py -Quelle farbe                # Farbfassung
python3 bogen/bau/bauen.py -Modus vorbefuellt -Held dorle
python3 bogen/bau/bauen.py -Modus liste -Held dorle     # ohne Originalbogen
python3 bogen/bau/bauen.py -Alle -Held dorle            # alle fünf Fassungen
python3 bogen/bau/bauen.py -Messen                      # mit Messgitter
python3 bogen/bau/bauen.py -Modus vorbefuellt -Held gorbas -OhneLeere

python3 bogen/bau/felder-pruefen.py                     # /Rect gegen Feldtabelle
python3 bogen/bau/felder-pruefen.py -Quelle farbe
python3 bogen/bau/linien-lesen.py -Seite 2              # Linien und Kästchen der Quelle
python3 bogen/bau/rendern.py -Datei <pdf> -Seiten 1     # PNG zum Ansehen
python3 bogen/bau/quelle-vorbereiten.py                 # Farbquelle auf A4 normalisieren

python3 bogen/bau/mappe-bauen.py -Held dorle                  # Charaktermappe, 4 x A4
python3 bogen/bau/mappe-bauen.py -Held dorle -Fassung druck   # A3 quer, zweiseitig
python3 bogen/bau/mappe-bauen.py -Held dorle -Beide
```

Zwei Werkzeuge erwarten `bogen/` als Arbeitsverzeichnis, weil sie mit Dateinamen ohne Pfad
umgehen:

```sh
cd bogen
python3 bau/geometrie.py <roh.pdf> --waag --senk --rechteck --text
python3 bau/fassungen-vergleichen.py         # deckt sich Farbfassung mit df?
```

Das Pergament der Mappe liegt in `grafiken/` und kommt vom Einrichten, nicht vom Bauen:

```sh
python3 werkzeuge/einrichten.py "/pfad/zu/Scriptorium Aventuris v4"
python3 werkzeuge/pergament.py  "/pfad/zu/Scriptorium Aventuris v4" --zeigen
```

`bogen/bau/werkzeugpfad.py` findet pdflatex und Ghostscript und lässt `pdflatex` zweimal laufen.
Nichts davon von Hand nachbauen. Was es gefunden hat, sagt es selbst:

```sh
python3 bogen/bau/werkzeugpfad.py
```

**Ghostscript ist unter Windows kostenlos dabei, anderswo nicht.** TeX Live bringt es dort in
`tlpkg/tlgs` mit; unter macOS gehört es nicht zu MacTeX und fehlt oft — `brew install
ghostscript`. Ohne Ghostscript laufen `rendern`, `linien-lesen` und die Normalisierung der
Farbquelle nicht, der Rest schon.

## Einmessen — die Werkzeugkette

Das Briefing sah vor, ~200 Positionen am Messgitter **abzulesen**. Das ist nicht nötig: die
Geometrie des Bogens lässt sich aus der Quelldatei **extrahieren**.

Zwei Werkzeuge, beide auf demselben Weg: Ghostscript schreibt die Seite unkomprimiert neu, dann
wird der Content-Stream gelesen und in Millimeter von links oben umgerechnet.

- **`bau/linien-lesen.py`** — der schnelle Überblick. Regex über den Stream, rechnet den
  1/10-bp-Faktor (`0.1 0 0 0.1 0 0 cm`) ein, den es selbst aus der Datei liest. Legt das
  entpackte PDF unter `%TEMP%` ab — von dort holt es der Python-Parser.
- **`python bau/geometrie.py <roh.pdf>`** — der genaue. `--waag --senk --rechteck --text`,
  eingegrenzt mit `--von`/`--bis` und `--min`.

**Für Tabellen ist der Python-Parser Pflicht, nicht Geschmack.** Drei Gründe, jeder davon hat
mich zunächst zu einem falschen Schluss geführt:

1. **Pfade sind Ketten.** `x y m x2 y2 l x3 y3 l` enthält zwei Segmente; ein Regex auf „m … l"
   findet nur das erste. So sind die Spaltenlinien gezeichnet — mit dem Regex bleiben sie
   unsichtbar, und es sieht aus, als hätte die Tabelle gar kein Raster.
2. **Form-XObjects bleiben komprimiert**, auch mit `-dCompressStreams=false`. Der Parser packt
   sie mit zlib aus. Ohne das fehlt ein Teil des Rasters.
3. **`--text` liefert exakte Zeilenanker.** Die Grundlinie einer eingedruckten Beschriftung sagt,
   wo die Zeile liegt. Damit sind die 59 Talentzeilen auf Bogen 2 nicht abgezählt, sondern
   gelesen — ein Verrutschen um eine Zeile ist ausgeschlossen.

Wie die Bögen gezeichnet sind, aus der Arbeit an allen sechs:

- **Schreiblinien** sind waagerechte Pfade. Das Feld sitzt darüber, Unterkante auf der Linie.
- **Kästchen** sind Rechtecke. Das Feld sitzt deckungsgleich darin.
- **Zeilentrenner** von Tabellen sind Pfade.
- **Spaltengrenzen** von Tabellen sind meist die Kanten der Schattierungsrechtecke, dazu
  einzelne Striche. Beides liefert `geometrie.py --rechteck --senk`.

Was sich **nicht** ermitteln lässt, und was daher am gerenderten Bogen abgelesen und in
`felder/df.tex` genau dort als abgelesen ausgewiesen ist:

- **Wo eine Beschriftung endet.** Die Linie läuft unter ihr durch, das Feld darf erst dahinter
  beginnen. Auf etwa einen halben Millimeter genau.
- **Die Eigenschaftsleiste MU…KK.** Sie ist eine Grafik, kein Vektorraster — `geometrie.py`
  findet dort nichts. Deshalb sitzen die acht Felder mit Abstand in ihrer Zelle (15,5 mm in
  19,5 mm), damit ein Millimeter Fehler nicht auffällt.
- **Das Zellenraster der Eigenschaftsmodifikationen** (Bogen 2) und zwei Spaltengrenzen der
  Zustandsmatrix (Bogen 3): stecken in XObjects mit eigenem Koordinatensystem bzw. folgen aus
  Nachbarblöcken, ohne selbst belegt zu sein.

Die drei Proben, in dieser Reihenfolge:

1. `felder-pruefen.py` — rechnet jedes `/Rect` des Ausgabe-PDF zurück in mm. Bei richtigen
   Optionen ist es **exakt** der Tabellenwert. Findet außerdem doppelte Feldnamen, weißen
   Hintergrund und Rahmen.
2. `rendern.py` + ansehen — sitzt der Wert auf der Linie, verdeckt er keine Beschriftung?
3. Ausfüllen und **Speichern** in zwei Betrachtern. Steht noch aus, siehe unten.

Das Messgitter bleibt trotzdem im Projekt (`-Messen`); für Zweifelsfälle ist es das schnellste
Mittel.

## Ziel

Aus dem offiziellen DSA5-Heldendokument (flache Druck-PDF, keine Interaktivität) entstehen aus
**einer** Quelle zwei Ausgaben:

1. **ausfüllbar** — echte AcroForm-Felder, im Betrachter beschreib- und speicherbar
2. **vorbefüllt** — dieselben Positionen, Werte fest eingesetzt aus einer Datei je Held

Als dritte Variante ist eine **feldtabellengetriebene Werteliste ohne den Originalbogen**
vorgesehen (rechtlich weitergebbar, siehe Abschnitt „Rechtliches" im Briefing). Sie benutzt
dieselbe Feldtabelle und sollte von Anfang an mitgedacht werden.

## Toolchain

**pdflatex, nicht XeLaTeX.** `hyperref`s Formularfelder sind unter pdflatex weit besser erprobt.
Das benachbarte Satzprojekt (`C:\SVN\dsa-sl\kampagnen\fuchsgrund\satz\`) läuft zwingend mit
XeLaTeX, weil DSaTeX `fontspec` lädt — von dort ist **nichts** übernehmbar. Die Projekte teilen nur
den Anlass.

```
pdfpages  →  Originalseite als Grund einbetten
hyperref  →  Formularfelder absolut darüber
tikz      →  Koordinatensystem zum Einmessen
```

Das gilt für den **Bogen**. Die Mappe braucht weder AcroForm noch `pdfpages` und ist an
pdflatex nicht gebunden. Sie setzt heute in Ersatzschriften (`ebgaramond`, `cinzel`), weil
Andalus und Gentium Basic `fontspec` verlangen — und die liegen seit dem Umzug in `schriften/`
der Projektwurzel. Ein XeLaTeX-Lauf steht ihr damit offen; umgestellt ist sie nicht.

**Distribution: TeX Live.** Bei Projektbeginn war auf dem Rechner kein LaTeX (gemessen: `pdflatex`
und `latexmk` fehlten; `pdftotext` aus xpdf 4.06 war vorhanden, kennt aber kein `-bbox`). Die
Installation von TeX Live wurde am 7. September 2026 angestoßen.

**Kein zweites TeX daneben installieren.** Nicht MiKTeX nachschieben, wenn ein Lauf scheitert —
zwei Distributionen auf einem Windows-Rechner streiten um `PATH` und Formatdateien, und der Fehler
sieht dann wie ein LaTeX-Fehler aus, obwohl er einer der Installation ist. Erst prüfen:

```powershell
pdflatex --version          # findet die Shell es? sonst neue Shell — PATH ist erst danach gesetzt
kpsewhich pdfpages.sty      # ist das Paket da?
```

Fehlt ein Paket, wird es nachinstalliert, nicht die Distribution gewechselt:
`tlmgr install pdfpages`.

Kompilieren, sobald es ein Dokument gibt:

```powershell
pdflatex heldenbogen.tex   # zweimal!
pdflatex heldenbogen.tex
```

**Immer zweimal.** `remember picture` braucht zwei Läufe; im ersten liegen alle Felder in der
linken oberen Ecke. Ein Positionsproblem erst nach dem zweiten Lauf für echt nehmen.

## Die zwei Quelldateien — sie sind nicht dasselbe Dokument

Der Anwender will **beide** Fassungen bedienbar haben, umschaltbar per Option (`druckerfreundlich`
als Schalter). Gemessen an den Dateien:

| | `Heldendokument_druckerfreundlich.pdf` | `US25505PDF_Heldendokumente.pdf` |
|---|---|---|
| Ort | `~/Downloads/` | `~/Downloads/` |
| Größe | 826 KB | 8,2 MB |
| Seiten | **6** | **10** |
| Seitenformat | `/MediaBox [0 0 595.276 841.89]` = A4 (gemessen) | **MediaBox 230,8 × 317,8 mm, TrimBox 208,8 × 295,8 mm** — eine Druckdatei mit 11 mm Beschnitt, **nicht** A4 (gemessen) |
| AcroForm / Widget | 0 / 0 | 0 / 0 |

Seitenzuordnung, aus der Textextraktion je Seite:

| Inhalt | druckerfreundlich | Farbfassung |
|---|---|---|
| Persönliche Daten / Charakteristika | 1 | 1 |
| Talente bzw. „Spielwerte / Fertigkeiten" | 2 | 2 |
| Kampfwerte bzw. „Kampf" | 3 | 3 |
| Liturgien & Zeremonien | 4 | 5 |
| Zauber & Rituale | 5 | 6 |
| Ausrüstung bzw. „Besitz" | 6 | **4** |
| Meisterdokument: Meisterpersonen | — | 7 |
| Meisterdokument: Kurzformulare | — | 8 |
| Kampfprotokoll | — | 9 |
| Kampfprotokoll: Tiere und Ungeheuer | — | 10 |

**Folgen für den Schalter — das ist die wichtigste Architekturentscheidung des Projekts:**

- Die Seitenreihenfolge weicht ab (Ausrüstung: Seite 6 gegen Seite 4).
- Die Beschriftungen weichen ab („Talente" gegen „FERTIGKEITEN", `StF` gegen `Stg.`) — es sind
  unterschiedliche Auflagen, nicht Farbe gegen Graustufe.
- Deshalb sind **Koordinaten nicht übertragbar.** Pro Quelle eine eigene Koordinatentabelle.
- Gemeinsam bleiben: **ein** Feldnamenschema und **eine** Wertedatei je Held. Ein Held muss ohne
  Änderung durch beide Fassungen laufen.
- Die Farbfassung hat vier Seiten mehr (7–10: Meisterpersonen, Kurzformulare, Kampfprotokoll,
  Tiere und Ungeheuer). Sie sind kein Heldenbogen. **Entschieden: sie bekommen keine Felder.**
  Der Feldbestand umfasst nur die sechs Seiten, die beide Fassungen gemeinsam haben. In der
  Farbfassung laufen die Seiten 7–10 unverändert und feldlos mit durch. Das ist Absicht, kein
  offener Rest — nicht ungefragt nachrüsten.
- Seiten 4 und 5 der druckerfreundlichen Fassung (bzw. 5 und 6 der Farbfassung) sind dieselbe
  Geometrie mit anderen Beschriftungen: einmal einmessen, zweimal verwenden.

Beide PDF liegen außerhalb des Projektverzeichnisses, in `~/Downloads` — die Pfade stehen in
`konfig.tex`. Das ist Absicht: es ist Verlagsmaterial, siehe „Rechtliches". Nicht ins Projekt
kopieren, ohne das geklärt zu haben.

### Die Farbfassung muss normalisiert werden

Sie ist eine **Druckdatei mit 11 mm Beschnittzugabe**, kein A4-Dokument. Legt man sie direkt ein,
skaliert `pdfpages` sie um etwa +0,6 % auf A4 — und dann stimmt **keine** im Quelldokument
gemessene Koordinate mit der Seite überein. Das ist keine Kleinigkeit: es macht jede Messung für
diese Fassung unbrauchbar, ohne einen Fehler zu melden.

`bau/quelle-vorbereiten.py` beschneidet sie deshalb einmal auf die TrimBox und setzt sie
**unskaliert** mittig auf A4 (`bau/ausgabe/quelle-farbe-a4.pdf`). Erst diese abgeleitete Datei
wird eingelegt und gemessen; `bauen.py` und `linien-lesen.py` erzeugen sie bei Bedarf selbst.
Zwei Nebenwirkungen, beide erwünscht: die Ausgabe schrumpft von 6,5 auf 3,9 MB, weil der
Beschnitt wegfällt, und `Requested size` im Log ist danach für alle Seiten konstant 210 × 297 mm.

Die abgeleitete Datei ist Verlagsmaterial — sie liegt in `bau/ausgabe/` und wird nicht
weitergegeben.

Aus demselben Grund liest `geometrie.py` den **Bezugsrahmen aus der Datei** (TrimBox, sonst
MediaBox) und nimmt kein A4 an. Es meldet ihn in der ersten Ausgabezeile — wer dort etwas anderes
als `210.0 x 297.0 mm` sieht, misst nicht in Seitenkoordinaten.

## Architektur

Drei strikt getrennte Ebenen. Die Trennung ist der ganze Trick des Projekts:

1. **Feldtabelle** — nur Daten, kein Layout. Je Zeile ein Feld:
   `\feld{bogen}{name}{x}{y}{breite}{hoehe}{art}`. Pro Quelldatei eine Tabelle.
   `bogen` ist der **logische** Bogen 1–6, nicht die physische Seite: nur so heißen die Felder in
   beiden Quellfassungen gleich, obwohl die Ausrüstung dort Seite 6 und hier Seite 4 ist. Die
   Umrechnung auf die physische Seite steht allein in `konfig.tex`.
2. **Darstellung** — `\feld` wird einmal als `\TextField` definiert (ausfüllbar), einmal als
   fester Text (vorbefüllt), einmal als schlichte Werteliste (weitergebbare Variante).
   Dieselbe Tabelle erzeugt alle Ausgaben.
3. **Wertedateien** — `helden/<name>.tex` mit `\wert{feldname}{Wert}`. Fehlender Wert heißt leeres
   Feld, **kein Abbruch**.

Feldarten: `text`, `zahl` (zentriert), `mehrzeilig` (`multiline=true`) und `bild`.

## Leere Bögen weglassen

Für einen unmagischen Helden ist Bogen 5 (Zauber) eine leere Seite, für einen Weltlichen ebenso
Bogen 4 (Liturgien). Drei Wege, sie loszuwerden; der erste, der etwas sagt, gewinnt:

| Weg | wo | Wirkung |
|---|---|---|
| `\bogennur{1,2,3,6}` | Heldendatei | nur diese Bögen |
| `\bogenweglassen{4,5}` | Heldendatei | alle außer diesen |
| `-OhneLeere` | Bauoption | Bögen ohne einen einzigen gesetzten Wert fallen weg |

Der Unterschied zwischen den beiden ist wichtig: **`\bogenweglassen` wirft auch Bögen weg, die
Inhalt haben** — `-OhneLeere` behält sie. `helden/dorle-kurz.tex` und `helden/gorbas.tex` sind die
beiden Regressionsproben dafür.

Drei Dinge, die daran nicht offensichtlich sind und jeweils einmal schiefgegangen sind:

1. **Die Eigenschaftsleiste MU…KK zählt bei `-OhneLeere` nicht als Inhalt.** Sonst gilt jeder
   Bogen als gefüllt, sobald die acht Eigenschaften gesetzt sind, und die Automatik läuft leer —
   genau der Fall bei Dorle. Die Leiste markiert ihre Felder deshalb mit `\zaehltnicht`.
2. **`-OhneLeere` wirkt nur in der vorbefüllten Fassung.** In der ausfüllbaren gibt es keine
   Werte; dort würde sie alle Bögen wegwerfen. Sie wird ignoriert, mit Hinweis im Log.
3. **Fällt jeder Bogen weg**, entsteht ein Dokument ohne Seite, pdflatex schreibt gar kein PDF,
   und das sieht nach einem Absturz aus. Für diesen Fall bleibt Bogen 1 stehen
   (`\bogenAuswahlPruefen`), und `bauen.py` meldet ein fehlendes PDF sauber statt abzustürzen.

Die Felder weggelassener Bögen verschwinden mit: geprüft an `-Held dorle-kurz -Modus ausfuellbar`
— 744 statt 1256 Felder, Bogen 4 und 5 mit **0** Feldern, keine Waisen-Widgets.

## Das Heldenbild

`art=bild` — der Wert ist ein Dateipfad statt Text:

```latex
\wert{s1_bild}{helden/bilder/dorle.jpg}
```

Das Bild wird in den Kasten eingepasst, das Seitenverhältnis bleibt erhalten, schmalere Bilder
sitzen mittig. Fehlt der Wert oder die Datei, bleibt der Rahmen leer und der Lauf schreibt nur
einen Hinweis ins Log — wie bei jedem anderen Feld.

**Nur in der vorbefüllten Fassung.** AcroForm kennt kein Bildfeld; in der ausfüllbaren Fassung
bleibt der Rahmen leer, und `s1_bild` erzeugt bewusst **kein** Widget. Wer dort ein Bild
einsetzbar machen will, braucht einen Druckknopf mit Icon (`\PushButton` plus
`buttonImportIcon`) — das läuft nur mit JavaScript und praktisch nur im Adobe-Acrobat, in
Firefox und Edge tut es stillschweigend nichts. Deshalb ist es hier nicht eingebaut.

Der Rahmen auf Bogen 1 ist eine **Klammerform** mit ausgesparten Ecken: die waagerechten Kanten
laufen von x 83,1 bis 126,4, die senkrechten von y 38,5 bis 92,7. Der Bildkasten ist deren
Schnittmenge — 43,3 × 54,2 mm bei (83,1 | 38,5). Nur so schneidet keine Zierecke ins Bild.

`helden/bilder/pruefbild.png` ist ein Prüfbild in genau diesem Seitenverhältnis (Rahmen plus
Diagonalen); daran sieht man auf einen Blick, ob ein Bild vollständig und unverzerrt sitzt.
`helden/bildfehlt.tex` ist die Gegenprobe auf den fehlenden Pfad.

Der Kreis im Tierbogen (Bogen 6) wäre der zweite Platz für ein Bild. Er ist aus Bézierkurven
gezeichnet; seine Ausdehnung ist noch nicht sauber isoliert (die Messung vermischt ihn mit dem
Rahmen des Tierbogens) — dort ist noch kein Feld.

**Koordinaten immer in Millimeter von der linken oberen Papierecke.** Nicht in Punkt, nicht von
unten. Ein Bezugspunkt, konsequent.

**Das Messgitter** (TikZ, Linien alle 10 mm beschriftet, alle 5 mm fein) bleibt dauerhaft im
Projekt, hinter `-Messen`. Seit `linien-lesen.py` ist es nicht mehr das Hauptwerkzeug, sondern
das Mittel für Zweifelsfälle — siehe „Einmessen".

**Tabellenseiten werden generiert, nicht einzeln eingemessen.** Auf den Tabellenseiten (Talente,
Kampfwerte, Liturgien/Zauber, Ausrüstung) je Startwert und Zeilenhöhe aus `linien-lesen.py`
nehmen, dann `\foreach`. Das senkt den Aufwand von mehreren Hundert Feldern auf einige Dutzend
Werte. Bogen 1 zeigt das Muster: `\abgeleiteterwert` erzeugt 22 Felder aus sechs Zeilen.

**Nur leere Felder bekommen Widgets.** Probe, BE und StF auf der Talentseite, Leiteigenschaft und
StF auf der Kampfseite sind im Original eingedruckt — dort keine Felder. Das halbiert die Feldzahl
dieser Seiten.

## Reihenfolge des Einmessens

Seite 1 und 3 zuerst (die meisten Einzelfelder, zeigen die meisten Fehler), Seite 2 zuletzt
(fast nur Tabellenzeilen, dann generierbar).

## Die Charaktermappe

Die Mappe (`mappe/`) ist der **Umschlag** zu den Heldenbögen, nachempfunden den
Charakterbögen der Heldenwerk-Reihe (`~/Downloads/US25015PDF_HvS_PDF_Charakterbogen_Hexe.pdf`
und `…_Streuner.pdf`, jeweils erste und letzte Seite). Vier Blätter:

| Blatt | Inhalt |
|---|---|
| Titel | Kopfzier, Name, Profession, Ganzkörperbild, Kurzempfehlung im Fußkasten |
| Innen links | Pflichttext der Vereinbarung über Gemeinschaftsinhalte, dazu ein freier Kasten |
| Innen rechts | frei betextbar; ohne Text erscheinen Notizlinien |
| Rückseite | Überschrift, Hintergrundtext, Bild als Wasserzeichen, freier Fußkasten |

Zwei Ausgabefassungen: `-Fassung digital` (4 × A4, für die Weitergabe als PDF — dort zählen
die erste und die letzte Seite) und `-Fassung druck` (2 × A3 quer, gefalzt der Umschlag, in
den die Bögen eingelegt werden).

**Sie enthält keine Seite des Originalbogens und ist deshalb weitergebbar** — anders als die
überlagerten Fassungen, siehe „Rechtliches". Voraussetzung ist der Pflichttext, und der steht
fest auf dem linken Innenblatt.

### Die Schriften liegen schon da

Titel und Lesetext gehören in die Schriften des Scriptorium-Baukastens: **Andalus** für den
Titelschriftzug, **Gentium Basic** in vier Schnitten für den Text. Beide liegen in `schriften/`
der Projektwurzel, aufbereitet von `werkzeuge/aufbereiten.py` — dieselben Dateien, die die
Abenteuerklasse benutzt. Es gibt sie also genau einmal, und wer den Baukasten erneuert,
erneuert sie an einer Stelle.

Solange die Mappe unter pdflatex läuft, benutzt sie sie **nicht**: `fontspec` verlangt XeLaTeX,
und deshalb setzt sie heute in `ebgaramond` und `cinzel` als Ersatz. Der Weg zu den echten
Schriften führt über eine `dsa5mappe.cls`, die `dsa5latex` lädt — siehe „Was als Nächstes
ansteht".

Solange das nicht passiert ist, braucht der Bogen von der Wurzel nichts außer `schriften/`,
und auch das nur, wenn die Mappe umgestellt wird. Grafiken braucht er keine: er legt
Originalseiten ein, und die Mappe zeichnet ihren Rahmen selbst und leitet ihr Pergament mit
`bau/pergament-vorbereiten.py` aus dem Baukasten ab.

### Ein Blatt ist eine Box, keine Seite

`\begin{mappenblatt}` baut ein Feld von genau 210 × 297 mm als Box. Die digitale Fassung setzt
eine pro Seite, die Druckfassung zwei nebeneinander in ein `\hbox to 420mm`. Deshalb darf in
`blaetter.tex` **nichts** vom Seitenrand abhängen; alles wird absolut ins Feld gesetzt, in
Millimeter von der linken oberen Feldecke.

### Der Flechtbandrahmen ist eingemessen, nicht geschätzt

Am Vorbild bei 300 dpi, Querschnitt durch den linken Rahmen. Maße in mm von der Blattkante:

| von | bis | Element |
|---|---|---|
| 1,75 | 2,10 | dunkle Kontur ⎫ |
| 2,15 | 2,85 | Creme-Körper ⎬ Strang A (Mitte 2,45, Dicke 1,40) |
| 2,95 | 3,15 | dunkle Kontur ⎭ |
| 3,20 | 4,35 | **Akzentfarbe** |
| 4,40 | 4,60 | dunkle Kontur ⎫ |
| 4,65 | 5,25 | Creme-Körper ⎬ Strang B (Mitte 5,00) |
| 5,35 | 5,60 | dunkle Kontur ⎭ |
| 6,85 | 8,35 | glatte Innenlinie (Creme 7,20…7,95) |

Kettenmaß 18,12 mm, davon 11,00 mm gerader Balken.

**Der Witz des Motivs: es sind zwei parallele Bänder, und die Akzentfarbe ist nichts als der
Zwischenraum.** Auf der Geraden wird daraus ein langer Balken, zwischen zwei Kreuzungen eine
spitze Linse. Ein Farbwert stimmt den ganzen Rahmen um — genau das, was die Vorbilder mit
wechselnden Professionsfarben machen. Gemessen: Hexe `AD6ED0`, Streuner `D88667`.

Der Einzug der Kettenenden (13,6 mm) ist **nicht** gemessen, sondern so gewählt, dass die Kette
waagerecht in 10 und senkrecht in 15 gleiche Glieder aufgeht (18,3 bzw. 17,96 mm gegen die
gemessenen 18,12). Ein halbes Glied in der Ecke fällt auf, eine Abweichung von 1 % nicht.

### Was nicht nachgezeichnet wird

- **Das Verlagslogo im Seitenkopf.** Eingetragene Marke. An seiner Stelle sitzt ein
  freistehendes Stück derselben Kette (`\kopfzier`) — das nimmt die Akzentfarbe mit, was das
  Logo nie getan hätte.
- **Die Titelschrift der Vorbilder.** Sie ist ein Rasterbild; die Schriftliste des PDF nennt
  nur Gentium Basic, und das nur für den Fußtext. Ersatz ist **Cinzel** (`[black]`), in
  TeX Live und pdflatex-fähig.
- **Gentium Basic als Fließtext**, obwohl der Baukasten es vorschreibt: ein pdflatex-fähiges
  Gentium gibt es in TeX Live nicht mehr (`tlmgr: package gentium-tug not present in
  repository`). Genommen ist **EB Garamond**, der nächste Verwandte, der da ist.

### Das Pergament kommt aus dem Baukasten

`werkzeuge/pergament.py` leitet zwei Dateien nach `grafiken/` ab, wie jede andere
Baukastengrafik: `mappe-pergament-a4.jpg` und `mappe-pergament-kasten.png`. Erzeugt werden sie
beim Einrichten, nicht beim Bauen — `werkzeuge/einrichten.py` gibt ihnen denselben
Baukastenpfad wie `aufbereiten.py`. `mappe-bauen.py` prüft nur noch, ob sie da sind, und
verweist sonst aufs Einrichten. Zwei Befunde, beide gemessen:

1. **Die Baukasten-Doppelseiten sind als Textur wertlos** — Standardabweichung 1,0 von 255 in
   der Innenfläche, also praktisch glattes Weiß. Und sie bringen eigene Randgrafik mit
   (Schuppenrücken, Flecken, Bundsteg), die nicht zu sehen sein darf. Sie sind **nicht** die
   Quelle.
2. **`Kasten_Pergament.png` ist es.** Echte Textur (Standardabweichung 6,2, Mittelton
   `FAF3E2`), und mit 1617 × 2272 Pixeln fast genau das A4-Verhältnis (0,7117 gegen 0,7071).
   Nur der gerissene Blattrand muss weg: leicht überformatig einpassen, 5,5 % je Kante
   abschneiden, Farbigkeit auf 62 % zurücknehmen (das Vorbild ist graustichiger), eigenen
   Papierrand aufbringen (satter Saum bis 1,75 mm, Auslauf 16 mm).

Die Fläche wird als **JPEG** abgelegt (`mappe-pergament-a4.jpg`, Güte 88, ohne Farbunterabtastung),
nicht als PNG. Verlustfrei bringt bei einer gefleckten Textur ohne Kanten nichts und kostet
viel: als PNG waren es 5,3 MB und damit eine 6-MB-Mappe, als JPEG sind es 700 KB und 1,5 MB.
Für die digitale Weitergabe ist das der Unterschied zwischen Anhang und Downloadlink.

Der Fußkasten dagegen bleibt PNG: `Kasten_Pergament_ver3` mit erhaltenem Alphakanal — ohne den
sitzt der gerissene Rand in einem weißen Rechteck.

Der Einzug im Fußkasten ist waagerecht 12 mm, senkrecht 6 mm. Das ist Absicht: der gerissene
Rand der Vorlage wird beim Einpassen mitskaliert, und 1010 × 599 Pixel auf 182 × 28 mm streckt
ihn waagerecht auf gut 4 mm, senkrecht auf gut einen. Mit einheitlichem Einzug steht der Text
seitlich in der Faserung.

Beide abgeleiteten Dateien sind Verlagsmaterial und bleiben in `bau/ausgabe/`. Weitergegeben
wird das fertige PDF, nicht die Textur.

### Was im Baukasten nicht drin ist

Geprüft gegen `Links/`, `PNG innen/`, `PNG aussen/` und die 13-seitige Muster-PDF: **das
Flechtband gibt es dort nicht**, in keiner Farbe und keiner Variante. Der Baukasten-Umschlag
ist ein anderer, viel schwererer Rahmentyp. Vorhanden und verwendbar sind Pergamentkästen,
Wertekästen, Absatztrenner, Ornamente, das Scriptorium-Banner und die Innenseiten-Flächen.

## Stand der Gegenproben

Erledigt und nachprüfbar:

- Überlagerung trägt: AcroForm mit Textfeldern über der eingebetteten Originalseite
- `/Rect` im Ausgabe-PDF ist **exakt** der Tabellenwert (`felder-pruefen.py`)
- Feldnamen eindeutig, kein Feld mit Hintergrund, kein Feld mit Rahmen
- alle sechs Bögen sichtgeprüft: jeder Wert auf seiner Linie bzw. in seiner Zelle, nichts
  verdeckt, nichts in der Nachbarspalte
- Held ohne Werte (`helden/leer.tex`) und **nicht vorhandene** Heldendatei laufen ohne Abbruch
- beide Quellfassungen laufen mit derselben Wertedatei
- Dateigröße: 808 KB gegen 826 KB Quelle — `pdfpages` bettet ein, nichts wird neu gerendert
- Charaktermappe: beide Fassungen bauen, A3 ist exakt A3 (1190,55 × 841,89 pt), die Blätter
  sitzen randbündig (Eckpixel geprüft, links 0,0 mm bis rechts 419,3 mm von 420)
- Charaktermappe ohne jeden `mappe_`-Wert (`-Held leer`, `-Held gorbas`, fehlende Datei, gar
  kein `-Held`): läuft, Rahmen im gedeckten Braun statt in Akzentfarbe, Name notfalls aus
  `s1_name`, Kästen entfallen statt leer zu stehen
- Charaktermappe, Dateigröße: 1,5 MB voll bestückt, 757 KB leer

Offen:

- **Die Mappe einmal gedruckt und gefalzt sehen.** Die Wendeachse der A3-Fassung ist
  treiberabhängig; `-Wenden lang` tauscht die beiden Innenblätter. Im Zweifel beides ausgeben
  und das richtige behalten.
- **Ausfüllen und Speichern in zwei Betrachtern.** Das ist die einzige Probe, die sich nicht
  automatisieren lässt, und die einzige verbliebene echte Unbekannte des Projekts. Adobe Reader
  plus ein zweiter (Firefox oder Edge) — die Umsetzungen unterscheiden sich. Scheitert das
  Speichern, ist nicht die Felddefinition der erste Verdacht, sondern die Erlaubnis im PDF.
- **Die Farbfassung fertig einmessen** — Bogen 2 bis 6 in `felder/farbe.tex`. Dieselben
  Feldnamen wie df, damit `helden/*.tex` unverändert durch beide Fassungen läuft; Bogen 1 zeigt,
  wie das geht, wenn die Auflagen inhaltlich abweichen (dort ist „Größe / Gewicht" eine Zeile,
  die in zwei Felder geteilt wird, damit die df-Namen erhalten bleiben).

## Fallgruben

Die ersten fünf sind beim Bauen tatsächlich eingetreten und im Code kommentiert — sie gehen
alle **still** schief, ohne Fehlermeldung oder mit einer irreführenden.

1. **Weißer Hintergrund.** Ohne `backgroundcolor=` setzt hyperref `/MK<</BG[1 1 1]>>` und malt
   jedes Feld weiß über den Originalbogen. Linien und Beschriftungen verschwinden darunter.
2. **`\pdflinkmargin`.** Der pdftex-Treiber baut Formularfelder mit `\pdfstartlink`, und pdfTeX
   bläht jedes Link-Rechteck um `\pdflinkmargin` auf — hyperref setzt die auf 1 pt. Das sind
   0,35 mm nach allen Seiten, auf jedem Feld. Keine Feldoption ändert das; es muss
   `\pdflinkmargin=0pt` sein (steht in `mechanik.tex`).
3. **`\ifthenelse` in der Optionsliste von `\TextField`.** Nicht expandierbar →
   „Undefined control sequence `\equal`". Und ein Makro, das zu `align=1` expandiert, geht auch
   nicht: kvsetkeys zerlegt die Liste vor dem Expandieren → „Undefined key `align=0'". Optionen
   als **Makroargument** durchreichen, dann sind es echte Token.
4. **`/Rect` steht im Objekt vor `/T`.** Wer den PDF-Tokenstrom flach nach Name-dann-Rechteck
   paart, verschiebt jedes Feld um eine Zeile und verliert eines. Je Objekt parsen.
5. **Sonderzeichen in Konsolenausgaben.** Sie haben zweimal Ärger gemacht, auf beiden
   Plattformen anders. In PowerShell 5.1 brauchten `.ps1`-Dateien **UTF-8 mit BOM**: ohne BOM
   las PS als ANSI, ein `—` wurde zu `”`, und der Parser meldete den Fehler in einer ganz
   anderen Zeile. In Python schreibt `print` auf der Windows-Konsole in `cp1252`, und derselbe
   Gedankenstrich kommt dort als `?` heraus. Beides ist umgangen, indem die Ausgaben nur ASCII
   führen — `--` statt `—`. Die Kommentare in den Werkzeugen ebenso, wie überall im Projekt.
6. **Doppelte Feldnamen** — AcroForm behandelt sie als ein Feld mit gespiegeltem Inhalt. Bei
   Tabellenschleifen über sechs bzw. zehn Seiten passiert das schnell. Namensschema einhalten
   (`s2_talent_fw_07`), und in beiden Quellfassungen dieselben Namen, damit die Wertedateien
   austauschbar bleiben. `felder-pruefen.py` prüft es.
7. **`\TextField` außerhalb von `\begin{Form}`** — erzeugt kein Feld und keine Fehlermeldung.
   Genau **ein** `Form` um das ganze Dokument.
8. **Nur ein Lauf** — `remember picture` braucht zwei. `bauen.py` macht das.
9. **Feldhöhe gegen Schriftgröße** — 5 mm Feld mit 11 pt schneidet unten ab; `charsize` klein.
10. **Mehrzeilige Felder** (Vorteile, Nachteile, Ausrüstungszeilen) brauchen `multiline=true` —
    dafür ist `art=mehrzeilig` in der Feldtabelle da.
11. **In der Feldtabelle nicht mit `\the\dimexpr` rechnen.** Das hängt die Einheit mit an, aus
    `\the\dimexpr 73.2pt+10.7pt` wird `83.9pt`, und `\feldWidget` macht daraus `83.9ptmm` →
    „Unknown operator `mm'". Spaltenwerte ausschreiben (siehe `\ktlinks` / `\ktrechts`) oder
    ein Zeilenmakro je Tabellenhälfte anlegen.
12. **`\in@` durchsucht sein zweites Argument auf Token-Ebene.** Übergibt man dort ein Makro
    (`\in@{,4,}{\bogenauswahl}`), sieht `\in@` ein einzelnes Token und findet nie etwas — die
    Bogenauswahl bleibt wirkungslos, ohne Fehlermeldung. Erst expandieren, dann suchen; in
    `\bogenpruefen` steht der `\edef`-Kniff dafür.
13. **Einzeilige Felder dürfen in der vorbefüllten Fassung nicht umbrechen.** Eine Tabellenzelle
    ist hier 4,2 mm hoch; ein Umbruch läuft in die Nachbarzeile. Und ein zu breiter Wert
    („MU/KL/CH" in einer 12,7 mm breiten Probe-Spalte) läuft in die Nachbarspalte. `\einzeilig`
    in `mechanik.tex` setzt den Wert deshalb erst in eine Box und **staucht** ihn, wenn er zu
    breit ist. Wer dort etwas ändert, prüft Bogen 4 Zeile 1 nach — dort tritt beides auf.

Vier weitere, die nur die Charaktermappe betreffen. Alle vier gehen **still** schief:

14. **Schriftwahl im Knotentext gilt nur für die erste Zeile.** In einem TikZ-Knoten mit
    `align=center` fällt die Größe nach einem `\\` auf die Grundschrift zurück, ohne
    Fehlermeldung. Der Titel sieht dann aus wie ein Name in 40 pt mit einem Nachnamen in
    10 pt. Die Schrift muss als **`font=`-Option** des Knotens stehen.
15. **Mehrabsätziger Text braucht ein `\par` am Ende.** Der Zeilenabstand eines Absatzes wird
    bei seinem `\par` festgelegt; fehlt es, setzt TeX den letzten Absatz mit dem Zeilenabstand
    von *außerhalb* des Knotens. Bei drei Absätzen sind dann zwei locker und einer eng.
    `\pergamentkasten` und `\mappetextblock` hängen es selbst an.
16. **`\sbox` mit einer `minipage` darin kommt in einem `tikzpicture` LEER zurück** — gemessen:
    `ht` 2,5 pt, `dp` 0 pt bei richtiger Breite, ohne Fehlermeldung. Der Kasten schrumpft dann
    auf die doppelte Randbreite und der Text fehlt einfach. Abhilfe: `pgfinterruptpicture`
    drumherum und `\global\setbox`, weil die Umgebung eine Gruppe ist.
17. **Makronamen dürfen keine Ziffer enthalten.** `\a3seite` liest LaTeX als `\a` gefolgt vom
    Text `3seite` — Ziffern sind keine Buchstaben, und `\a` ist schon vergeben: „Command `\a`
    already defined". Heißt jetzt `\umschlagseite`.

Und eines, das die Werkzeuge betrifft: **die Bash-Heredocs dieser Umgebung verschlucken
Backslashes.** `\\` in einer `cat <<'EOF'`-Zuweisung landet als einzelnes `\` in der Datei.
Für TeX-Inhalte deshalb nicht über Heredocs gehen.

Zwei weitere, die nur die Skripte betreffen:

- **Ghostscript aus TeX Live** findet seine Initialisierungsdateien nicht von selbst. `lib`,
  `kanji` und `Resource` müssen per `-I` mitgegeben werden, sonst „Can't find initialization
  file gs_init.ps". `bau/werkzeugpfad.py` erledigt das — aber nur unter Windows, denn nur dort
  ist Ghostscript Teil von TeX Live. Unter macOS und Linux kommt es aus dem `PATH` und braucht
  die Zusatzargumente nicht.
- **Ausgabe von Unterprozessen und `print`.** Unser `print` ist gepuffert, `pdflatex` und
  Ghostscript schreiben direkt auf den Handle — ohne `flush=True` steht die Überschrift
  hinter der Ausgabe, die sie ankündigen soll. Zweimal aufgetreten, in `bauen.py` und
  `einrichten.py`.

Die früheren PowerShell-Fallen — unquotierte Argumente mit Variablen (`-r$Dpi`), und dass
`$quelle` denselben Parameter meint wie `$Quelle` — sind mit der Portierung weggefallen. Sie
stehen hier, falls jemand die Wrapper doch wieder mit Logik füllen will: nicht tun.

## Ausdrücklich nicht tun

- **Den Bogen nicht nachbauen** — nicht die Linien, nicht die Raster, nicht die Beschriftungen.
  Überlagern. Ein Nachbau dauert Tage, sieht anders aus und ist bei jeder neuen Auflage hinfällig.
- **Für den Bogen nicht XeLaTeX** verwenden — `hyperref`s Formularfelder sind unter pdflatex
  weit besser erprobt. Für die Mappe gilt das nicht, siehe „Toolchain".
- **Das Verlagslogo der Charakterbögen nicht nachzeichnen** — eingetragene Marke. Die Mappe
  setzt an seine Stelle ein Stück des eigenen Flechtbands.
- **Keine Regelwerte fest eintragen**, die nicht im Bogen stehen. Probenformeln und
  Belastungsstufen sind eingedruckt — nicht wiederholen.
- **Keine abgeleiteten Werte berechnen.** LeP, AsP, KaP, AW, INI, Tragkraft haben ihre Formeln
  aufgedruckt. Ob das Projekt sie rechnet, ist eine eigene Entscheidung und nicht Teil des
  Auftrags — erst die Felder.

## Rechtliches

Der Bogen ist Material von Ulisses Spiele. Eigengebrauch und eigene Spielrunde sind unbedenklich.
**Weitergabe ist etwas anderes:** die Ausgabe enthält die Originaldatei vollständig, sie zu
verteilen heißt, eine Verlagsdatei erneut zu veröffentlichen — von der Vereinbarung über
Gemeinschaftsinhalte für SCRIPTORIUM AVENTURIS nicht ohne weiteres gedeckt. Vor einer Beilage zum
Abenteuer klären. Der Ausweg ist die dritte Ausgabevariante: Werte ohne Originalbogen.

**Die Charaktermappe ist der zweite Ausweg.** Sie enthält keine Seite des Originalbogens,
sondern nur selbst gezeichnete Grafik und Material aus dem Scriptorium-Aventuris-Baukasten.
Der Baukasten ist ausdrücklich zur Verwendung freigegeben — „Lies mich zuerst", Seite 2, und
die Muster-PDF selbst: *„Der folgende Text muss stets im Werk enthalten sein"*. Genau dieser
Text steht wortgleich auf dem linken Innenblatt der Mappe. Variabel ist dort nur die
Copyright-Zeile (`\wert{mappe_copyright}{…}`).

Das heißt nicht, dass damit alles geklärt ist: die eingelegten Bögen bleiben Verlagsdateien.
Weitergebbar ist der Umschlag, nicht sein Inhalt.

## Was als Nächstes ansteht

Der Umzug ist Schritt 1 von vier und hat mit Absicht **nichts** am Inhalt geändert. Was noch
aussteht, in dieser Reihenfolge:

2. **Die Werteschnittstelle in die Klasse.** `\wert`, `\wertvon`, `\wertdaP` und `\wertoder`
   stehen seit dem Umzug nur noch einmal, in `bogen/werte.tex`, und beide Mechanikdateien
   binden sie ein. Der nächste Schritt ist, sie als `\dsaWert` und Geschwister nach Abschnitt 19
   von `dsa5latex.cls` zu heben — dann kennt auch die Abenteuerklasse sie, und die Mappe
   bekommt sie mit `\LoadClass`. Der Unterstrich in den Feldnamen braucht dafür
   `\catcode`\_=12`; das ist gefahrlos, weil die Klasse kein Mathematikpaket lädt.
3. **`dsa5mappe.cls`** nach dem Muster von `dsa5einleger.cls`: `\LoadClass{dsa5latex}` mit
   `ohneraster,ohnehintergrund`, dann A4 randabfallend beziehungsweise A3 quer. Damit bekommt
   die Mappe die echten Schriften, den Titelaufbau aus Abschnitt 18 und `\dsaRechtevermerk`.
   Drei Befunde gehören dabei erledigt:
   - Der **Titel** steht in Cinzel Black mit einem Versatzkranz aus acht Kopien. Der Aufbau der
     Klasse hat fünf Lagen nach dem PSD des Baukastens. Für die Akzentfarbe je Held braucht es
     ein eigenes Shading pro Farbe — dasselbe `\edef`-Muster, das die Klasse für ihre Fadings
     schon fährt, weil pgf den Namen unexpandiert nimmt.
   - Das **Heldenbild** füllt den Kasten nicht: `pruefbild.png` hat 260 × 325 px (0,800), der
     Kasten 85 × 169 mm (0,503). `keepaspectratio` begrenzt an der Breite, das Bild wird
     85 × 106,3 mm statt 85 × 169 und die Oberkante sitzt bei y 137,8 statt 75. Es fehlt ein
     Prüfbild im Mappenverhältnis und ein Hinweis ins Log, wenn ein Bild den Kasten verfehlt.
   - Die **Kopfzier** ist ein freistehendes Stück des Flechtbands. Weil es exakt das
     Rahmenmotiv ist, liest es sich als abgerissenes Rahmenstück, nicht als Ornament. Der
     Rahmen selbst bleibt wie er ist — er ist am Vorbild eingemessen und trägt die Akzentfarbe.
4. **`feature/einleger` einsammeln**, sonst liegen zwei halbfertige Zweigklassen nebeneinander.

**Erledigt:** Der Pflichttext stand zweimal — in `mappe/blaetter.tex` (Blatt 3) in einer
älteren Fassung mit „Ulisses Medien und Spiele Distribution GmbH" und einer anderen
Markenliste, in `dsa5latex.cls` in der aktuellen mit „Ulisses Spiele GmbH, Waldems". Er steht
jetzt in `pflichttext.tex` neben der Klasse; beide binden ihn ein, die Mappe als
`../pflichttext`. Nach außen bleibt `\dsaRechtevermerk{Jahr}{Name}` unverändert.

## Weiterführend

`16-heldenbogen-briefing.md` ist die vollständige Vorgabe, mit lauffähigem Codegerüst für Schritt 1,
dem Messgitter-Makro und dem Feldbestand aller sechs Seiten der druckerfreundlichen Fassung. Bei
Zweifeln dort nachsehen, nicht raten.
