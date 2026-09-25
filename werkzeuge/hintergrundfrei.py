#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Stellt eine Figur von ihrem einfarbigen Hintergrund frei.

    python3 werkzeuge/hintergrundfrei.py bilder/viburn-ganzfigur.jpeg
    python3 werkzeuge/hintergrundfrei.py bilder/*.jpeg --ziel grafiken/
    python3 werkzeuge/hintergrundfrei.py bild.jpeg --toleranz 40 --weich 3
    python3 werkzeuge/hintergrundfrei.py bild.jpeg --breite 700

Wofuer: auf einer Spielkarte sitzt die Figur direkt auf dem Pergament. Ein
Bild mit eigenem Hintergrund steht statt dessen als helles Rechteck darauf,
und man sieht der Karte an, dass da etwas hineinkopiert wurde. Die
offiziellen Sets zeigen ausschliesslich freigestellte Figuren.

Anders als werkzeuge/freistellen.py, das den Alphakanal einer VORLAGE
uebertraegt (das gerissene Pergamentblatt etwa), sucht dieses Werkzeug den
Hintergrund im Bild selbst: alles, was vom Rand aus zusammenhaengend
erreichbar ist und der Randfarbe nahe genug kommt, wird durchsichtig.

Das setzt einen ruhigen, einfarbigen Hintergrund voraus -- wie ihn Bilder
haben, die fuer genau diesen Zweck erzeugt wurden. Bei einem Foto mit
Zimmer dahinter richtet es nichts aus; dann hilft nur ein Bildwerkzeug.

Die Randfarbe wird nicht geraten, sondern gemessen: Median der aeussersten
Bildzeile und -spalte. Die Toleranz ist der zulaessige Abstand davon,
gemessen als groesste Abweichung eines Farbkanals.

Heraus kommt ein PNG mit Alphakanal, gleicher Name, Endung .png.

Mit --breite wird das Ergebnis auf diese Pixelbreite verkleinert. Das lohnt
sich: ein PNG mit Alphakanal ist um ein Vielfaches groesser als das JPEG,
aus dem es kommt, und das Bildfeld einer Spielkarte ist 57 mm breit -- bei
300 ppi also 673 Pixel. Eine Vorlage mit 1792 Pixeln traegt daraus nichts
bei ausser Dateigroesse. Vergroessert wird nie, nur verkleinert.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import sys
from collections import deque

# Abstand von der Randfarbe, ab dem ein Bildpunkt als Figur gilt. 32 von
# 255 traegt die Bilder, die hier bisher durchgelaufen sind: der
# Hintergrund streut um 9 bis 16, die Figurkanten liegen deutlich weiter weg.
TOLERANZ = 32

# Die Kante wird um so viele Bildpunkte weich gezeichnet. Ohne das steht an
# der Silhouette eine Treppe, und bei einer Figur auf Pergament faellt die
# auf. Zwei Punkte bei 300 ppi sind 0,17 mm.
WEICH = 2


def randfarbe(a):
    """Median der aeussersten Zeile und Spalte."""
    import numpy as np
    rand = np.concatenate([a[0, :], a[-1, :], a[:, 0], a[:, -1]])
    return np.median(rand, axis=0)


def hintergrund(a, toleranz):
    """Maske: True, wo Hintergrund ist.

    Zwei Bedingungen, beide noetig. Nahe genug an der Randfarbe -- das
    allein genuegt nicht, denn ein helles Hemd trifft die Randfarbe
    genauso. Und vom Bildrand aus zusammenhaengend erreichbar; das
    schliesst alles aus, was von der Figur umschlossen ist.
    """
    import numpy as np
    farbe = randfarbe(a)
    nah = (np.abs(a - farbe).max(axis=2) <= toleranz)

    h, w = nah.shape
    erreicht = np.zeros((h, w), dtype=bool)
    schlange = deque()
    for x in range(w):
        for y in (0, h - 1):
            if nah[y, x] and not erreicht[y, x]:
                erreicht[y, x] = True
                schlange.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if nah[y, x] and not erreicht[y, x]:
                erreicht[y, x] = True
                schlange.append((y, x))

    # Breitensuche. Reines Python, aber nur ueber die Hintergrundpunkte --
    # bei einem 896 x 1200 grossen Bild sind das unter einer Sekunde.
    while schlange:
        y, x = schlange.popleft()
        for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and nah[ny, nx] \
                    and not erreicht[ny, nx]:
                erreicht[ny, nx] = True
                schlange.append((ny, nx))
    return erreicht


def freistellen(pfad, toleranz, weich, breite):
    import numpy as np
    from PIL import Image, ImageFilter

    bild = Image.open(pfad).convert('RGB')
    a = np.asarray(bild).astype(np.int16)
    maske = hintergrund(a, toleranz)

    alpha = Image.fromarray(((~maske) * 255).astype(np.uint8), mode='L')
    if weich > 0:
        alpha = alpha.filter(ImageFilter.GaussianBlur(weich))

    aus = bild.convert('RGBA')
    aus.putalpha(alpha)

    # Verkleinert wird erst am Schluss. Die Maske aus dem grossen Bild ist
    # genauer, und die weiche Kante verkleinert sich mit.
    if breite and aus.width > breite:
        hoehe = max(1, round(aus.height * breite / aus.width))
        aus = aus.resize((breite, hoehe), Image.LANCZOS)
    return aus, float(maske.mean())


def main():
    args = sys.argv[1:]
    ziel = None
    toleranz = TOLERANZ
    weich = WEICH
    breite = 0
    dateien = []
    i = 0
    while i < len(args):
        if args[i] == '--ziel':
            i += 1
            ziel = args[i]
        elif args[i] == '--toleranz':
            i += 1
            toleranz = int(args[i])
        elif args[i] == '--weich':
            i += 1
            weich = int(args[i])
        elif args[i] == '--breite':
            i += 1
            breite = int(args[i])
        elif args[i].startswith('-'):
            print('Unbekannte Option: %s' % args[i])
            return 2
        else:
            dateien.append(args[i])
        i += 1

    if not dateien:
        print(__doc__)
        return 2

    try:
        import numpy  # noqa: F401
        from PIL import Image  # noqa: F401
    except ImportError:
        print('Pillow und numpy werden gebraucht:')
        print('    pip install pillow numpy')
        return 1

    for p in dateien:
        if not os.path.isfile(p):
            print('Nicht gefunden: %s' % p)
            continue
        aus, anteil = freistellen(p, toleranz, weich, breite)
        name = os.path.splitext(os.path.basename(p))[0] + '.png'
        zielpfad = os.path.join(ziel, name) if ziel else \
            os.path.join(os.path.dirname(p), name)
        if ziel:
            os.makedirs(ziel, exist_ok=True)
        aus.save(zielpfad)
        hinweis = ''
        if anteil < 0.05:
            hinweis = '   <- fast nichts entfernt, Toleranz zu klein?'
        elif anteil > 0.90:
            hinweis = '   <- fast alles entfernt, Toleranz zu gross?'
        print('%-40s %5d x %-5d %2.0f %% Hintergrund%s'
              % (os.path.basename(zielpfad), aus.width, aus.height,
                 anteil * 100, hinweis))
    return 0


if __name__ == '__main__':
    sys.exit(main())
