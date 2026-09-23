#!/usr/bin/env python3
"""Liest die Geometrie des Originalbogens aus dem PDF -- der schnelle Weg.

Ghostscript schreibt die Seite unkomprimiert neu, dann werden aus dem
Content-Stream gelesen:

  LINIEN   waagerechte Pfade (x y m x2 y2 l) -- die Schreiblinien.
           Ein Feld sitzt DARUEBER, mit der Unterkante auf der Linie.
  KAESTEN  Rechtecke (x y b h re) -- die Wertekaestchen.
           Ein Feld sitzt DARIN, deckungsgleich.

Alles in Millimeter von der linken oberen Papierecke, also in genau den
Koordinaten der Feldtabelle.

FUER TABELLEN IST bau/geometrie.py PFLICHT, nicht Geschmack. Dieses Werkzeug
liest mit einem Regex ueber den Stream und sieht deshalb nur das erste
Segment einer Pfadkette (x y m x2 y2 l x3 y3 l) -- genau so sind die
Spaltenlinien gezeichnet. Und Form-XObjects bleiben komprimiert, auch mit
-dCompressStreams=false; geometrie.py packt sie mit zlib aus.

Was auch geometrie.py NICHT weiss: wo eine Beschriftung endet. Die Linie
laeuft unter ihr durch, das Feld darf erst dahinter beginnen. Diesen
x-Startwert am gerenderten Bogen ablesen (bau/rendern.py) und in der
Feldtabelle als abgelesen kennzeichnen.

    python3 bau/linien-lesen.py -Seite 3
    python3 bau/linien-lesen.py -Seite 3 -Quelle farbe
    python3 bau/linien-lesen.py -Seite 2 -Nur linien -MinBreite 30

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from werkzeugpfad import AUSGABE, PROJEKT, gs_lauf, tabelle  # noqa: E402

HIER = Path(__file__).resolve().parent

HOEHE = 841.89          # A4 in PDF-Punkten (bp), Ursprung unten links
BP2MM = 25.4 / 72

PFAD = re.compile(r"(-?[\d.]+)\s+(-?[\d.]+)\s+m\s+(-?[\d.]+)\s+(-?[\d.]+)\s+l")
RECHTECK = re.compile(r"(-?[\d.]+)\s+(-?[\d.]+)\s+(-?[\d.]+)\s+(-?[\d.]+)\s+re")


def quellpfad(quelle):
    """Fuer die Farbfassung wird die auf A4 normalisierte Datei gemessen,
    nicht das Original: dessen TrimBox ist um 11 mm versetzt, und Messwerte
    darin liegen nicht in Seitenkoordinaten."""
    if quelle == "farbe":
        if subprocess.call([sys.executable, str(HIER / "quelle-vorbereiten.py")],
                           cwd=PROJEKT) != 0:
            raise SystemExit(1)
        return AUSGABE / "quelle-farbe-a4.pdf"
    # Die druckerfreundliche Fassung steht in konfig.tex, wie alle Pfade.
    konfig = (PROJEKT / "konfig.tex").read_text(encoding="utf-8")
    treffer = re.search(r"^\\def\\quelleDF\{([^}]*)\}", konfig, re.M)
    if not treffer:
        raise SystemExit(r"In konfig.tex fehlt \def\quelleDF{...}")
    return Path(treffer.group(1))


def entpacken(quellpfad, seite, quelle):
    """Die Seite unkomprimiert neu schreiben. Sie landet im Temp-Ordner des
    Systems, weil sie Verlagsmaterial ist und nichts im Projekt zu suchen
    hat -- bau/geometrie.py holt sie von dort."""
    tmp = Path(tempfile.gettempdir()) / f"heldenbogen-roh-{quelle}-s{seite}.pdf"
    tmp.unlink(missing_ok=True)
    ok, meldung = gs_lauf([
        "-q", "-dNOPAUSE", "-dBATCH", "-sDEVICE=pdfwrite",
        "-dCompressStreams=false", "-dCompressPages=false",
        f"-dFirstPage={seite}", f"-dLastPage={seite}",
        f"-sOutputFile={tmp}", str(quellpfad)])
    if not ok or not tmp.exists():
        print("Ghostscript hat nichts geschrieben. Meldung:")
        for zeile in meldung.strip().splitlines()[-6:]:
            print(f"    {zeile}")
        raise SystemExit(1)
    return tmp


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0],
                                allow_abbrev=False)
    p.add_argument("-Seite", type=int, default=1)
    p.add_argument("-Quelle", choices=["df", "farbe"], default="df")
    p.add_argument("-Nur", choices=["alles", "linien", "senkrecht", "kaesten"],
                   default="alles")
    p.add_argument("-MinBreite", type=float, default=14,
                   help="mm; kuerzere Striche sind Raster, keine Schreiblinien")
    p.add_argument("-KastenMin", type=float, default=3.5)
    p.add_argument("-KastenMax", type=float, default=14)
    a = p.parse_args()

    quelle = quellpfad(a.Quelle)
    if not quelle.exists():
        raise SystemExit(f"Quelldatei nicht gefunden: {quelle}")
    tmp = entpacken(quelle, a.Seite, a.Quelle)
    txt = tmp.read_bytes().decode("latin-1")

    # Der Content-Stream steht in 1/10 bp -- Ghostscript setzt
    # "0.1 0 0 0.1 0 0 cm" an den Anfang. Der Faktor wird aus der Datei
    # gelesen, nicht angenommen.
    skala = 1.0
    sm = re.search(r"([\d.]+)\s+0\s+0\s+\1\s+0\s+0\s+cm", txt)
    if sm:
        skala = float(sm.group(1)) or 1.0

    def in_mm(v):
        return round(v * skala * BP2MM, 1)

    def von_oben(y):
        return round((HOEHE - y * skala) * BP2MM, 1)

    print(f"\nSeite {a.Seite} der Fassung '{a.Quelle}'   "
          f"(Skala {skala}, Masse in mm von links oben)")

    if a.Nur in ("alles", "linien"):
        linien = set()
        for m in PFAD.finditer(txt):
            x1, y1, x2, y2 = (float(g) for g in m.groups())
            if abs(y1 - y2) * skala * BP2MM > 0.2:
                continue
            breite = abs(x2 - x1)
            if in_mm(breite) < a.MinBreite:
                continue
            linien.add((von_oben(y1), in_mm(min(x1, x2)), in_mm(breite)))
        zeilen = [[x, y, b] for y, x, b in sorted(linien)]
        print(f"\nSCHREIBLINIEN (>= {a.MinBreite} mm): {len(zeilen)}"
              f"   -- Feld sitzt DARUEBER")
        tabelle(zeilen, ["x", "y", "Breite"])

    if a.Nur in ("alles", "senkrecht"):
        senk = set()
        for m in PFAD.finditer(txt):
            x1, y1, x2, y2 = (float(g) for g in m.groups())
            if abs(x1 - x2) * skala * BP2MM > 0.2:
                continue
            laenge = abs(y2 - y1)
            if in_mm(laenge) < a.MinBreite:
                continue
            senk.add((in_mm(x1), von_oben(max(y1, y2)), von_oben(min(y1, y2)),
                      in_mm(laenge)))
        zeilen = [list(s) for s in sorted(senk)]
        print(f"\nSPALTENGRENZEN (>= {a.MinBreite} mm lang): {len(zeilen)}")
        tabelle(zeilen, ["x", "yOben", "yUnten", "Laenge"])

    if a.Nur in ("alles", "kaesten"):
        kaesten = set()
        for m in RECHTECK.finditer(txt):
            x, y, b, h = (float(g) for g in m.groups())
            if b < 0:
                x, b = x + b, -b
            if h < 0:
                y, h = y + h, -h
            bm, hm = in_mm(b), in_mm(h)
            if not (a.KastenMin <= bm <= a.KastenMax):
                continue
            if not (a.KastenMin <= hm <= a.KastenMax):
                continue
            kaesten.add((von_oben(y + h), in_mm(x), bm, hm))
        zeilen = [[x, y, b, h] for y, x, b, h in sorted(kaesten)]
        print(f"\nKAESTEN ({a.KastenMin}..{a.KastenMax} mm): {len(zeilen)}"
              f"   -- Feld sitzt DARIN")
        tabelle(zeilen, ["x", "y", "Breite", "Hoehe"])

    return 0


if __name__ == "__main__":
    sys.exit(main())
