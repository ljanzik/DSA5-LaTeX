#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Misst die rechte Kante einer freigestellten Figur für den Umfluss auf
der Rückseite.

\\dsaRueckBild setzt ein Bild links unten auf die Rückseite, und der
Klappentext weicht seinem Rahmen aus. Soll er der Figur selbst folgen,
braucht die Klasse ihre rechte Kante je Millimeter Papierhöhe. Dieses
Werkzeug liest sie aus dem Alphakanal und gibt die fertige Zeile aus:

    python3 werkzeuge/umfluss.py grafiken/gaensemagd.png --breite 80
    python3 werkzeuge/umfluss.py bild.png --breite 80 --unten 285 --x 0

    \\dsaRueckBildKontur{152:41.3,153:42.0,...}

--breite, --x und --unten sind dieselben Werte wie in der Klasse: die
Breite aus \\dsaRueckBild, \\dsarueckebildx (Vorgabe 0 mm) und
\\dsarueckebildunten (Vorgabe 291,7 mm). Alles in Millimetern.

Gezählt wird ein Pixel ab 25 Prozent Deckung; weichere Schatten zählen
nicht, sonst rückt der Text um ihre ganze Breite ein. Zeilen ganz ohne
Deckung fehlen in der Ausgabe und bleiben im Satz frei.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import sys

SCHWELLE = 64


def wert(name, vorgabe):
    if name in sys.argv:
        i = sys.argv.index(name)
        return float(sys.argv[i + 1].replace(',', '.'))
    return vorgabe


def main():
    if len(sys.argv) < 2 or sys.argv[1].startswith('-'):
        print(__doc__)
        return 2
    try:
        from PIL import Image
    except ImportError:
        print('Pillow fehlt:  python3 -m pip install Pillow')
        return 1
    breite = wert('--breite', None)
    if breite is None:
        print('--breite fehlt: die Breite aus \\dsaRueckBild, in mm.')
        return 2
    x0 = wert('--x', 0.0)
    unten = wert('--unten', 291.7)

    bild = Image.open(sys.argv[1]).convert('RGBA')
    alpha = bild.split()[3]
    w, h = bild.size
    k = w / breite                      # Pixel je Millimeter im Satz
    oben = unten - h / k
    px = alpha.load()

    paare = []
    y_mm = int(oben)
    while y_mm < unten:
        y0 = max(0, int((y_mm - oben) * k))
        y1 = min(h, int((y_mm + 1 - oben) * k))
        rechts = -1
        for y in range(y0, y1):
            for x in range(w - 1, rechts, -1):
                if px[x, y] >= SCHWELLE:
                    rechts = x
                    break
        if rechts >= 0:
            paare.append('%d:%.1f' % (y_mm, x0 + (rechts + 1) / k))
        y_mm += 1

    if not paare:
        print('Keine deckenden Pixel gefunden -- hat das Bild einen Alphakanal?')
        return 1
    print('\\dsaRueckBildKontur{%s}' % ','.join(paare))
    return 0


if __name__ == '__main__':
    sys.exit(main())
