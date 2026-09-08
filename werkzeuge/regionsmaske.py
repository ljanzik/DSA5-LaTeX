#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Baut aus dem Rueckseiten-Paket eine Rueckseite mit eigener Region.

Das Paket bringt 28 fertige Masken mit — je eine Region Aventuriens. Wer
eine andere Aufteilung braucht, etwa zwei Nachbarregionen zusammen, kann
sie selbst schneiden: die Arbeitsdatei
`Karte_mit_Grenzen_Paket.pdn` enthaelt zwei Ebenen, die verdunkelte Karte
und ein Netz aus Regionsgrenzen. Dieselben Ebenen liegen als
`KarteVerdunkelt.png` und `Grenzen.png` daneben.

Das Verfahren: von einem Saatpunkt aus wird innerhalb der Grenzlinien
geflutet. Die gefundene Flaeche wird aus der Verdunkelung ausgenommen, und
das Ergebnis kommt ueber die neutrale Rueckseite. Mehrere Saatpunkte
ergeben mehrere Regionen in einer Maske.

    python3 werkzeuge/regionsmaske.py "/pfad/zum/Paket" mittelreich 148.4,105.0
    python3 werkzeuge/regionsmaske.py "/pfad/zum/Paket" zwei-regionen \\
        148.4,105.0 130,150

Die Koordinaten sind Millimeter auf der A4-Seite, von der linken oberen
Ecke. Wer sie nicht kennt: die Karte liegt zwischen 104 und 207 mm
waagerecht und 30 und 187 mm senkrecht.

WIE FEIN DAS NETZ IST. Die Grenzebene kennt die grossen Regionen, nicht die
Provinzen darin. Eine Saat im Kosch flutet das ganze Mittelreich, von 128
bis 193 mm waagerecht und 80 bis 124 mm senkrecht -- und zwar unabhaengig
davon, ab welcher Deckung man eine Linie als Linie zaehlt. Wer eine Provinz
braucht, findet sie also nicht in diesem Netz; fuer den Kosch gibt es eine
fertige Fassung als eigene Datei.

Heraus kommt `grafiken/ruecken-<name>.jpg`, zu benutzen als

    \\dsaRueckseite{ruecken-<name>}{...}

Das Bildmaterial ist NICHT Teil dieses Projekts. Es gehoert Ulisses Spiele
und steht unter der Vereinbarung ueber Gemeinschaftsinhalte fuer
SCRIPTORIUM AVENTURIS.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import sys

try:
    from PIL import Image, ImageDraw
    Image.MAX_IMAGE_PIXELS = None
except ImportError:
    sys.exit("Pillow fehlt: pip install pillow")

PPI = 300.0
MMPX = 25.4 / PPI

NEUTRAL = "ScriptoriumAventuris-hinten.png"
VERDUNKELT = "KarteVerdunkelt.png"
GRENZEN = "Grenzen.png"

# Ab dieser Deckung gilt ein Pixel der Grenzebene als Linie und haelt die
# Flutfuellung auf.
GRENZSCHWELLE = 40
JPEG_QUALITAET = 88


def finde(ordner, name):
    pfad = os.path.join(ordner, name)
    if not os.path.exists(pfad):
        sys.exit("fehlt im Paket: %s" % name)
    return pfad


def flaeche_fluten(grenzen, saaten):
    """Gibt die Maske der geschlossenen Flaeche um die Saatpunkte.

    Die Grenzebene wird zu Schwarzweiss: Linien schwarz, alles andere weiss.
    Die Flutfuellung faerbt von jedem Saatpunkt aus grau, und was grau
    geworden ist, ist die Flaeche.
    """
    a = grenzen.getchannel("A")
    karte = a.point(lambda v: 0 if v > GRENZSCHWELLE else 255).convert("L")
    grau = 128
    for x, y in saaten:
        if karte.getpixel((x, y)) != 255:
            sys.exit("Saatpunkt %.1f, %.1f mm liegt auf einer Grenzlinie"
                     % (x * MMPX, y * MMPX))
        ImageDraw.floodfill(karte, (x, y), grau, thresh=0)
    return karte.point(lambda v: 255 if v == grau else 0)


def main():
    argumente = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(argumente) < 3:
        print(__doc__)
        return 2

    paket = argumente[0].rstrip("/\\")
    name = argumente[1]
    saaten = []
    for wert in argumente[2:]:
        try:
            x, y = (float(z) for z in wert.split(","))
        except ValueError:
            sys.exit("Koordinate erwartet als x,y in mm: %s" % wert)
        saaten.append((int(x / MMPX), int(y / MMPX)))

    if not os.path.isdir(paket):
        sys.exit("Kein Ordner: %s" % paket)

    neutral = Image.open(finde(paket, NEUTRAL)).convert("RGBA")
    verdunkelt = Image.open(finde(paket, VERDUNKELT)).convert("RGBA")
    grenzen = Image.open(finde(paket, GRENZEN)).convert("RGBA")

    if not (neutral.size == verdunkelt.size == grenzen.size):
        sys.exit("Die drei Ebenen haben verschiedene Groessen: %s %s %s"
                 % (neutral.size, verdunkelt.size, grenzen.size))

    flaeche = flaeche_fluten(grenzen, saaten)
    anteil = 100.0 * sum(flaeche.histogram()[255:]) / (flaeche.width * flaeche.height)
    print("Geflutete Flaeche: %.2f Prozent der Seite" % anteil)
    if anteil > 25:
        print("Das ist viel — sind die Grenzen dort offen? Ergebnis pruefen.")

    # Die Verdunkelung mit einem Loch an der Stelle der Region.
    maske = verdunkelt.copy()
    alpha = maske.getchannel("A")
    loch = flaeche.point(lambda v: 0 if v else 255)
    maske.putalpha(Image.composite(loch, alpha, flaeche))

    fertig = Image.alpha_composite(neutral, maske).convert("RGB")

    hier = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    ziel = os.path.join(hier, "grafiken", "ruecken-%s.jpg" % name)
    os.makedirs(os.path.dirname(ziel), exist_ok=True)
    fertig.save(ziel, "JPEG", quality=JPEG_QUALITAET, optimize=True)
    print("geschrieben: %s" % ziel)
    print()
    print("Zu benutzen als:")
    print("    \\dsaRueckseite{ruecken-%s}{Titel}{Autor}{Text}{Kasten}" % name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
