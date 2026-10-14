#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Misst den Innenraum der Kastengrafiken.

Ein Kasten des Baukastens ist eine Grafik mit gezeichnetem Zierrand. Wie
breit dieser Rand ist, steht nirgends — und wer den Text zu weit nach oben
setzt, schreibt in das Ornament. Genau das war am Abzug zu sehen.

Das Verfahren: der Zierrand ist unruhig, die Innenfläche gleichmäßig. Also
entlang der Mittelachsen von außen nach innen laufen und den ersten Punkt
suchen, ab dem die Helligkeit über ein Fenster von zwei Millimetern ruhig
bleibt. Das ist die Innenkante.

Bei den Porträtkästen liegt das Medaillon oben rechts über dem Rand; die
waagerechte Messung läuft deshalb nicht durch die Mitte, sondern bei
60 Prozent der Höhe.

    python3 werkzeuge/innenraum.py
    python3 werkzeuge/innenraum.py grafiken/werte-mittel-portrait.png

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow fehlt: pip install pillow")

PPI = 300.0
MMPX = 25.4 / PPI

# Fenster, über das die Ruhe gemessen wird, und die Schwelle dafür.
FENSTER_MM = 2.0
SCHWELLE = 18.0

KAESTEN = [
    "pergament-klein", "pergament-mittel", "pergament-lang",
    "pergament-breit", "pergament-schmal",
    "werte-klein", "werte-mittel", "werte-gross",
    "werte-klein-portrait", "werte-mittel-portrait", "werte-gross-portrait",
    "meister-schmal", "meister-breit",
    "meister-maske", "meister-maske-klein",
]


def helligkeit(px, x, y):
    r, g, b, a = px[x, y]
    if a < 200:
        return None
    return 0.299 * r + 0.587 * g + 0.114 * b


def ruhig(werte):
    """Ist die Folge gleichmäßig genug, um Fläche zu sein?"""
    echte = [w for w in werte if w is not None]
    if len(echte) < len(werte):
        return False
    mittel = sum(echte) / len(echte)
    abweichung = (sum((w - mittel) ** 2 for w in echte) / len(echte)) ** 0.5
    return abweichung < SCHWELLE


def kante(px, start, ende, schritt, fest, senkrecht):
    """Läuft von start nach ende und gibt den ersten ruhigen Punkt."""
    fenster = max(2, int(FENSTER_MM / MMPX))
    lauf = start
    while (lauf - ende) * schritt < 0:
        werte = []
        for i in range(fenster):
            stelle = lauf + i * schritt
            if (stelle - ende) * schritt >= 0:
                return None
            if senkrecht:
                werte.append(helligkeit(px, fest, stelle))
            else:
                werte.append(helligkeit(px, stelle, fest))
        if ruhig(werte):
            return lauf
        lauf += schritt
    return None


def messen(pfad):
    im = Image.open(pfad).convert("RGBA")
    w, h = im.size
    px = im.load()

    mitte_x = w // 2
    # Bei Portraitkaesten liegt das Medaillon oben rechts; die waagerechte
    # Messung braucht eine Zeile darunter.
    mitte_y = int(h * 0.6)

    oben = kante(px, 0, h, 1, mitte_x, True)
    unten = kante(px, h - 1, 0, -1, mitte_x, True)
    links = kante(px, 0, w, 1, mitte_y, False)
    rechts = kante(px, w - 1, 0, -1, mitte_y, False)

    def mm(v, bezug=None):
        if v is None:
            return None
        return (bezug - v) * MMPX if bezug is not None else v * MMPX

    return {
        "breite": w * MMPX,
        "hoehe": h * MMPX,
        "oben": mm(oben),
        "unten": mm(unten, h - 1),
        "links": mm(links),
        "rechts": mm(rechts, w - 1),
    }


def zeile(name, m):
    def z(v):
        return "  ---" if v is None else "%5.2f" % v
    print("%-22s %6.2f x %6.2f mm   oben %s  unten %s  links %s  rechts %s"
          % (name, m["breite"], m["hoehe"],
             z(m["oben"]), z(m["unten"]), z(m["links"]), z(m["rechts"])))


def main():
    hier = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    if len(sys.argv) > 1:
        for pfad in sys.argv[1:]:
            zeile(os.path.basename(pfad), messen(pfad))
        return

    print("Innenraum der Kastengrafiken, Abstand der Innenkante vom Rand:")
    print()
    for name in KAESTEN:
        gefunden = None
        for endung in (".png", ".jpg"):
            pfad = os.path.join(hier, "grafiken", name + endung)
            if os.path.exists(pfad):
                gefunden = pfad
                break
        if gefunden is None:
            print("%-22s fehlt" % name)
            continue
        zeile(name, messen(gefunden))


if __name__ == "__main__":
    main()
