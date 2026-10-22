#!/usr/bin/env python3
"""Faerbt das Schuppenband der Seitenhintergruende von dsa5latex um.

    python3 werkzeuge/seitenfarbe.py karmin
    python3 werkzeuge/seitenfarbe.py blau karmin
    python3 werkzeuge/seitenfarbe.py moor:150:0.45 --ziel /pfad/zum/projekt
    python3 werkzeuge/seitenfarbe.py --farben

Quelle sind die Seiten, die werkzeuge/aufbereiten.py aus dem allgemeinen
Baukasten geschnitten hat: grafiken/seite-links-0 bis -3 und
grafiken/seite-rechts-0 bis -3. Daraus wird je Farbe

    grafiken/seite-links-<n>-<name>.jpg
    grafiken/seite-rechts-<n>-<name>.jpg

und die Klasse holt sie mit \\dsaSeitenfarbe{<name>}.

Die Farben sind DIESELBEN wie die der Spielkarten, mit Absicht: Farbtabelle
und Umfaerbung kommen aus werkzeuge/kartengrafik.py und werden hier nicht
nachgebaut. Das Schuppenband der Seiten ist so dunkel und so unbunt wie das
der Karte -- gemessen V 0,24 bei S 0,14 an der Aussenkante der rechten
Seiten, V 0,20 bei S 0,17 an der der linken, gegen V 0,20 bis 0,35 bei
S 0,11 bis 0,14 auf der Karte --, deshalb greifen dieselben Schwellen, und
aus denselben Werten wird derselbe Ton. Ein Heft und sein Kartenset in
\\dsaSeitenfarbe{blau} und \\dsaKartenfarbe{blau} passen zusammen.

Ausgenommen bleiben wie bei der Karte das Pergament (hell), die Ranke, die
braunen Flecken und die Kartusche der Seitenzahl (bunt). Die Kartusche ist
braun, nicht grau, und behaelt deshalb ihren Ton.

Das Bildmaterial gehoert Ulisses Spiele, siehe kartengrafik.py. Auch die
umgefaerbten Fassungen bleiben in grafiken/ und damit ausserhalb des
Repositorys.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from kartengrafik import FARBEN, HERKUNFT, einfaerben, farbe_lesen  # noqa: E402
from platzhalter import KENNUNG, ist_platzhalter  # noqa: E402

ZIEL_GRAFIK = 'grafiken'
VARIANTEN = range(4)
# Dieselben Werte wie aufbereiten.py fuer die ungefaerbten Seiten, damit
# eine gefaerbte Seite im PDF nicht groesser oder weicher ausfaellt.
JPEG_QUALITAET = 88


def quelle_finden(ordner, stamm):
    for endung in ('.jpg', '.png'):
        p = os.path.join(ordner, stamm + endung)
        if os.path.isfile(p):
            return p
    return None


def main():
    args = sys.argv[1:]
    if '--farben' in args:
        print('    Name        Farbton  Saettigung  woher')
        for n in sorted(FARBEN):
            grad, saet = FARBEN[n]
            print('    %-10s %4d Grad      %4.2f      %s'
                  % (n, grad, saet, HERKUNFT[n]))
        print()
        print('Dieselbe Tabelle wie fuer die Spielkarten. Eigene Farben gehen')
        print('mit name:farbton:saettigung.')
        return 0

    ziel = '.'
    farben = []
    i = 0
    while i < len(args):
        if args[i] == '--ziel':
            i += 1
            ziel = args[i]
        elif args[i].startswith('-'):
            print('Unbekannte Option: %s' % args[i])
            return 2
        else:
            farben.append(args[i])
        i += 1
    if not farben:
        print(__doc__)
        return 2

    try:
        from PIL import Image
        import numpy  # noqa: F401
    except ImportError:
        print('Pillow und numpy werden gebraucht:  pip install pillow numpy')
        return 1

    try:
        angaben = [farbe_lesen(f) for f in farben]
    except ValueError as e:
        print('FEHLER: %s' % e)
        return 1

    zg = os.path.join(ziel, ZIEL_GRAFIK)
    fehlt = []
    for seite in ('links', 'rechts'):
        for n in VARIANTEN:
            stamm = 'seite-%s-%d' % (seite, n)
            q = quelle_finden(zg, stamm)
            if q is None:
                fehlt.append(stamm)
                continue
            # Ist die Quelle ein Platzhalter, traegt die gefaerbte Fassung
            # dieselbe Kennung. Sonst liesse platzhalter.py --weg sie liegen,
            # und die naechste Pruefung dort hielte sie fuer echtes Material.
            kennung = ist_platzhalter(q, Image)
            bild = Image.open(q).convert('RGB')
            for name, grad, saet in angaben:
                neu = einfaerben(bild, grad, saet).convert('RGB')
                dateiname = '%s-%s.jpg' % (stamm, name)
                extra = {'comment': KENNUNG.encode('ascii')} if kennung else {}
                neu.save(os.path.join(zg, dateiname), 'JPEG',
                         quality=JPEG_QUALITAET, optimize=True,
                         progressive=False, subsampling=0, **extra)
                print('%-28s (%3d Grad, %.2f)' % (dateiname, grad, saet))

    if fehlt:
        print()
        print('FEHLT in %s: %s' % (zg, ', '.join(fehlt)))
        print('Die Seiten schneidet werkzeuge/aufbereiten.py aus dem')
        print('allgemeinen Baukasten.')
        return 1
    print()
    print('In der .tex:  \\dsaSeitenfarbe{%s}' % angaben[0][0])
    return 0


if __name__ == '__main__':
    sys.exit(main())
