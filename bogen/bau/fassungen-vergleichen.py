#!/usr/bin/env python3
"""fassungen-vergleichen.py - deckt sich die Farbfassung mit der druckerfreundlichen?

Vergleicht je logischem Bogen die waagerechten Linien beider Fassungen und
sucht die beste konstante Verschiebung. Deckt sich ein Bogen, laesst sich
seine Feldtabelle mit einem Versatz uebernehmen; deckt er sich nicht, muss
er eigenstaendig eingemessen werden.

Erwartet die entpackten Einzelseiten unter %TEMP%:
    heldenbogen-roh-df-s<n>.pdf        (A4)
    heldenbogen-roh-farbe-a4-s<n>.pdf  (auf A4 normalisiert)
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import geometrie as g

# logischer Bogen -> (physische Seite df, physische Seite farbe)
ZUORDNUNG = {1: (1, 1), 2: (2, 2), 3: (3, 3), 4: (4, 5), 5: (5, 6), 6: (6, 4)}
TEMP = os.environ["TEMP"]


def linien(pfad, mindestbreite=25.0):
    with open(pfad, "rb") as f:
        roh = f.read()
    g.lies_bezugsrahmen(roh)
    segmente = []
    for s in g.streams(roh):
        seg, _, _ = g.lies(s)
        segmente += seg
    treffer = set()
    for (x1, y1), (x2, y2) in segmente:
        if abs(y1 - y2) * g.BP2MM > 0.2:
            continue
        breite = abs(x2 - x1)
        if breite * g.BP2MM < mindestbreite:
            continue
        treffer.add((g.von_oben(y1), g.von_x(min(x1, x2)), g.mm(breite)))
    return sorted(treffer)


def bester_versatz(a, b):
    """Verschiebung dy, die die meisten Linien zur Deckung bringt."""
    bestes, bester = 0, 0.0
    kandidaten = sorted({round(yb - ya, 1)
                         for ya, xa, wa in a for yb, xb, wb in b
                         if abs(xa - xb) < 0.4 and abs(wa - wb) < 0.4})
    for dy in kandidaten:
        n = sum(1 for ya, xa, wa in a
                if any(abs(yb - (ya + dy)) < 0.35 and abs(xb - xa) < 0.4
                       and abs(wb - wa) < 0.4 for yb, xb, wb in b))
        if n > bestes:
            bestes, bester = n, dy
    return bester, bestes


print(f"{'Bogen':>5} {'df':>4} {'farbe':>5} {'Linien df':>10} {'farbe':>6}"
      f" {'dy':>6} {'deckt':>6} {'Urteil'}")
for logisch, (sdf, sfa) in ZUORDNUNG.items():
    pdf = f"{TEMP}/heldenbogen-roh-df-s{sdf}.pdf"
    pfa = f"{TEMP}/heldenbogen-roh-farbe-a4-s{sfa}.pdf"
    if not (os.path.exists(pdf) and os.path.exists(pfa)):
        print(f"{logisch:>5} {sdf:>4} {sfa:>5}   Seiten fehlen")
        continue
    a, b = linien(pdf), linien(pfa)
    dy, n = bester_versatz(a, b)
    anteil = n / max(len(a), 1)
    urteil = ("deckungsgleich" if anteil > 0.9 else
              "teilweise" if anteil > 0.5 else "eigenes Layout")
    print(f"{logisch:>5} {sdf:>4} {sfa:>5} {len(a):>10} {len(b):>6}"
          f" {dy:>6.1f} {n:>6} {urteil} ({anteil:.0%})")
