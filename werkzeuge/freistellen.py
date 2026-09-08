#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Stellt ein Bild mit der Kante einer Vorlagengrafik frei.

Mehrere Grafiken des Baukastens haben eine gezeichnete Kante, die sich als
Maske benutzen lässt — allen voran das Pergamentblatt des Kapitelanfangs mit
seiner gerissenen Unterkante. Wer ein eigenes Bild in derselben Form
braucht, muss sie nicht nachzeichnen: dieses Werkzeug überträgt den
Alphakanal der Vorlage auf das Bild.

    python3 werkzeuge/freistellen.py bilder/hof.jpg kapitelstart-pergament \\
        grafiken/hof-pergament.png

Das Bild wird auf die Vorlage deckend skaliert und mittig beschnitten, dann
maskiert. Heraus kommt ein PNG mit Alphakanal, das sich wie jede andere
Grafik platzieren lässt.

Vorlagen im Bestand, mit dem Anteil durchsichtiger Fläche:

    kapitelstart-pergament   109,2 x 300,0 mm   gerissenes Blatt
    pergament-klein           85,5 x  50,7 mm   Kasten mit Zierrand
    pergament-mittel          85,5 x  99,5 mm
    pergament-lang            85,5 x 192,4 mm
    pergament-schmal          48,9 x 192,4 mm
    maske                     20,0 x  12,1 mm   Meistermaske
    portraitrahmen            35,4 x  35,0 mm   Medaillonring

Ein Name ohne Pfad wird in grafiken/ gesucht, mit Endung .png oder .jpg.

Mit --weich <n> wird die Kante um n Pixel weicher gezeichnet, mit --hart
wird sie auf voll oder durchsichtig gerundet. Ohne beides bleibt der
Alphakanal der Vorlage, wie er ist.

Das Bildmaterial ist NICHT Teil dieses Projekts. Es gehoert Ulisses Spiele
und steht unter der Vereinbarung ueber Gemeinschaftsinhalte fuer
SCRIPTORIUM AVENTURIS.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import sys

try:
    from PIL import Image, ImageFilter
    Image.MAX_IMAGE_PIXELS = None
except ImportError:
    sys.exit("Pillow fehlt: pip install pillow")


def finde_vorlage(name):
    """Sucht die Maske: als Pfad, sonst in grafiken/."""
    if os.path.exists(name):
        return name
    hier = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for endung in ("", ".png", ".jpg"):
        pfad = os.path.join(hier, "grafiken", name + endung)
        if os.path.exists(pfad):
            return pfad
    sys.exit("Vorlage nicht gefunden: %s" % name)


def deckend_zuschneiden(bild, breite, hoehe):
    """Skaliert das Bild deckend und schneidet mittig zu.

    Dasselbe Verfahren wie \\dsaBildDeckend in der Klasse: nach dem
    groesseren der beiden Faktoren skalieren, den Ueberschuss abschneiden.
    """
    faktor = max(breite / bild.width, hoehe / bild.height)
    neu = (max(1, int(round(bild.width * faktor))),
           max(1, int(round(bild.height * faktor))))
    bild = bild.resize(neu, Image.LANCZOS)
    links = (bild.width - breite) // 2
    oben = (bild.height - hoehe) // 2
    return bild.crop((links, oben, links + breite, oben + hoehe))


def main():
    argumente = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(argumente) < 3:
        print(__doc__)
        return 2

    weich = 0
    if "--weich" in sys.argv:
        i = sys.argv.index("--weich")
        if i + 1 >= len(sys.argv):
            sys.exit("--weich braucht eine Zahl")
        weich = float(sys.argv[i + 1])
        argumente = [a for a in argumente if a != sys.argv[i + 1]]
    hart = "--hart" in sys.argv

    quelle, vorlage, ziel = argumente[0], argumente[1], argumente[2]
    if not os.path.exists(quelle):
        sys.exit("Bild nicht gefunden: %s" % quelle)

    maske = Image.open(finde_vorlage(vorlage)).convert("RGBA")
    alpha = maske.getchannel("A")
    if alpha.getextrema()[0] == 255:
        sys.exit("Die Vorlage hat keine durchsichtigen Stellen — als Maske "
                 "taugt sie nicht: %s" % vorlage)

    if weich:
        alpha = alpha.filter(ImageFilter.GaussianBlur(weich))
    if hart:
        alpha = alpha.point(lambda v: 255 if v > 127 else 0)

    bild = Image.open(quelle).convert("RGBA")
    bild = deckend_zuschneiden(bild, maske.width, maske.height)
    bild.putalpha(alpha)

    ordner = os.path.dirname(os.path.abspath(ziel))
    if ordner:
        os.makedirs(ordner, exist_ok=True)
    bild.save(ziel)

    mm = 25.4 / 300.0
    print("geschrieben: %s" % ziel)
    print("  %d x %d Pixel, bei 300 ppi also %.2f x %.2f mm"
          % (bild.width, bild.height, bild.width * mm, bild.height * mm))
    frei = 100.0 * alpha.histogram()[0] / (alpha.width * alpha.height)
    print("  durchsichtig: %.1f Prozent der Flaeche" % frei)
    return 0


if __name__ == "__main__":
    sys.exit(main())
