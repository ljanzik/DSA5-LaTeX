# Farben für Karten und Seiten

*Die Schuppenleiste der Heftseiten und das Schuppenband der Spielkarten lassen sich umfärben, beide
mit derselben Farbtabelle. Ein Heft und sein Kartenset mit demselben Farbnamen haben denselben Ton.
Die Messungen dazu stehen in [MASSE.md](MASSE.md), Abschnitt 8.*

---

## Kurzfassung

```sh
python3 werkzeuge/seitenfarbe.py karmin                                    # Heftseiten
python3 werkzeuge/kartengrafik.py "/pfad/zum/Kartenpaket" --farbe karmin    # Spielkarten
python3 werkzeuge/seitenfarbe.py --farben                                  # die Tabelle
```

```latex
\dsaSeitenfarbe{karmin}   % im Heft, dsa5latex.cls
\dsaKartenfarbe{karmin}   % im Kartenset, dsa5spielkarten.cls
```

Beide Befehle gelten ab der Stelle, an der sie stehen, und lassen sich mitten im Dokument
wechseln. Mit einem leeren Argument (`{}`) gilt wieder die ungefärbte Fassung des Baukastens.

## Die sieben Farben

| Name | Farbton | Sättigung | woher | auf der Karte | auf der Seite |
|---|---:|---:|---|---|---|
| `blau` | 200° | 0,46 | gemessen, *Aventurische Meisterpersonen* | kühles Stahlblau | ebenso |
| `rot` | 10° | 0,55 | gemessen, *Flusslande* | mattes Rotbraun | wirkt braun |
| `karmin` | 0° | 0,90 | Angebot, an den Seiten gewählt | kräftiges Dunkelrot | ebenso |
| `gruen` | 120° | 0,45 | Angebot | sattes Moosgrün | die grüne Ranke geht darin unter |
| `violett` | 280° | 0,40 | Angebot | gedämpftes Purpur | ebenso |
| `bernstein` | 30° | 0,90 | Angebot | warmes Braun | ebenso |
| `petrol` | 175° | 0,45 | Angebot | dunkles, graugrünes Petrol | ebenso |

`blau` und `rot` stammen aus den Schuppenbändern der beiden veröffentlichten Kartensets, dort
wurden sie gemessen. Die übrigen fünf sind Angebote in derselben Machart. Die Tabelle steht an
einer Stelle, in `FARBEN` in `werkzeuge/kartengrafik.py`, und `seitenfarbe.py` liest sie von dort.
Wer eine Farbe ändert oder dazunimmt, ändert sie für beide.

Am Abzug abgenommen sind bisher `karmin`, `violett` und `petrol`. `petrol` hieß zuerst `tuerkis`,
aber der Ton ist kein Türkis, sondern ein dunkles Petrol, und so heißt er jetzt. Wer
`\dsaKartenfarbe{tuerkis}` benutzt hat, schreibt `petrol` und legt die Fassung mit
`--farbe petrol` neu an.

**Wer ein Rot will, nimmt `karmin`.** Das gemessene `rot` ist das Rotbraun des Flusslande-Sets. Auf
der Karte passt es, auf den breiten Leisten der Heftseiten wirkt es braun. Deshalb bleibt `rot`
unverändert, weil es als Messwert stimmt, und `karmin` steht daneben.

**`gruen` auf den Seiten:** Die Leiste trägt eine grüne Ranke, und die bleibt beim Umfärben, wie sie
ist. Vor grünen Schuppen ist sie kaum noch zu sehen. Am Bildschirm angesehen, gedruckt nicht
geprüft.

## Warum Karte und Seite denselben Ton bekommen

Umgefärbt werden nur Bildpunkte, die dunkel **und** fast grau sind, und die Helligkeit jedes Punkts
bleibt erhalten. Die Zielfarbe liefert nur Farbton und Sättigung. Deshalb hängt das Ergebnis davon
ab, wie hell die Schuppen vorher waren, und die sind auf Karte und Seite gleich hell:

| | Helligkeit | Sättigung vorher |
|---|---|---|
| Schuppenband der Karte | 0,20 bis 0,35 | 0,11 bis 0,14 |
| Leiste der rechten Seiten | 0,24 | 0,14 |
| Leiste der linken Seiten | 0,20 | 0,17 |

Am Ergebnis nachgemessen, im Median der umgefärbten Punkte:

| Farbe | Karte | rechte Seite | linke Seite |
|---|---|---|---|
| `blau` | 203,5° / 0,38 | 202,5° / 0,39 | 203,5° / 0,40 |
| `rot` | 4,4° / 0,44 | 8,0° / 0,48 | 6,7° / 0,47 |
| `karmin` | 357,4° / 0,75 | 358,8° / 0,78 | 358,7° / 0,78 |
| `gruen` | 122,7° / 0,37 | 120,0° / 0,39 | 120,0° / 0,37 |
| `violett` | 280,9° / 0,36 | 280,9° / 0,35 | 280,0° / 0,36 |
| `bernstein` | 27,3° / 0,72 | 27,5° / 0,76 | 27,3° / 0,76 |
| `petrol` | 177,3° / 0,37 | 175,0° / 0,39 | 180,0° / 0,37 |

Der Farbton weicht höchstens 5° ab, die Sättigung höchstens 0,04. Karte und Seite im selben
Maßstab nebeneinander zeigen bei keiner der sieben Farben einen Unterschied.

Was **nicht** umgefärbt wird: auf der Karte das Pergament, die Messingecken und der schwarze
Außenrand, auf der Seite das Pergament, die Ranke, die braunen Flecken und die Kartusche der
Seitenzahl. Die Raute auf dem Kartenrücken bekommt denselben Farbton mit eigener Sättigung (0,35).
Der Edelstein darin ist heller als das Band und wirkte mit dessen Sättigung blass.

## Eigene Farben

Beide Werkzeuge nehmen statt eines Namens auch `name:farbton:saettigung`:

```sh
python3 werkzeuge/seitenfarbe.py moor:150:0.45
python3 werkzeuge/kartengrafik.py "/pfad/zum/Kartenpaket" --farbe moor:150:0.45
```

```latex
\dsaSeitenfarbe{moor}
\dsaKartenfarbe{moor}
```

Damit Heft und Karten zusammenpassen, braucht die Farbe auf beiden Seiten denselben Namen und
dieselben Zahlen. Wer sie öfter braucht, trägt sie in `FARBEN` und `HERKUNFT` in
`werkzeuge/kartengrafik.py` ein. Dann gilt sie für beide Werkzeuge.

Beim Wählen gilt: **Die Sättigung nicht nach dem Eindruck auf weißem Grund wählen.** Die Schuppen
sind dunkel, und die Helligkeit kommt aus dem Bild. Zwischen etwa 20° und 70° (Orange bis Gelb)
kippt eine mittlere Sättigung ins Olivgraue oder ins Braune, weil ein dunkles Gelb kein Gelb mehr
ist. Solche Töne brauchen 0,80 bis 0,90. Blau, Grün und Violett kommen mit 0,40 bis 0,46 aus. Rot
erst ab etwa 0,80 und nahe 0°: Mit 10° und 0,55 wurde es auf der Seite braun, mit 5° und 0,70 noch
rotbraun.

Entscheidend ist die erzeugte Datei, nicht die Zahl. Nach dem Erzeugen die Seite ansehen, am besten
eine gebaute Seite im PDF.

## Was fehlt, wenn es nicht klappt

* **`\dsaSeitenfarbe{x}` ohne Wirkung, Warnung `Seitenfarbe 'x' fehlt in grafiken/`:**
  `seitenfarbe.py x` ist nicht gelaufen. Das Heft baut trotzdem, mit den Seiten des Baukastens.
* **`seitenfarbe.py` meldet `FEHLT in grafiken/`:** Es gibt die ungefärbten Seiten noch nicht. Die
  schneidet `werkzeuge/aufbereiten.py` aus dem allgemeinen Baukasten.
* **`\dsaKartenfarbe{x}` bricht mit fehlender Datei ab:** `kartengrafik.py … --farbe x` ist nicht
  gelaufen. Anders als die Seitenfarbe hat die Kartenfarbe keinen Rückfall.

Die gefärbten Fassungen bleiben wie alle Grafiken in `grafiken/` und damit außerhalb des
Repositorys. Das Material gehört Ulisses Spiele, auch in umgefärbter Form.
