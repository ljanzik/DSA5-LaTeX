#!/usr/bin/env python3
"""Prueft, ob grafiken/ und schriften/ vollstaendig sind und die Grafiken die
erwarteten Pixelmasse haben.

    python3 werkzeuge/pruefen.py

Warum die Pixelmasse geprueft werden: die Klasse setzt jede Grafik in ihrer
Produktionsgroesse, also Pixel geteilt durch 300 ppi. Weicht eine Datei ab,
ist entweder eine andere Fassung des Baukastens im Umlauf oder beim Kopieren
etwas schiefgegangen. Beides faellt sonst erst im gesetzten PDF auf, und dort
sieht man es als „irgendwie verschoben" statt als klaren Fehler.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import sys

# Sollmasse in Pixel, gemessen an Scriptorium Aventuris v4.
# Bei 300 ppi ergibt Pixel / 300 * 25,4 das Mass in Millimeter.
SOLL = {
    # Pergamentkaesten
    'pergament-klein.png':          (1010, 599),
    'pergament-mittel.png':         (1010, 1175),
    'pergament-lang.png':           (1010, 2272),
    'pergament-breit.png':          (1617, 2272),
    'pergament-schmal.png':         (577, 2272),
    # Wertekaesten
    'werte-klein.png':              (997, 647),
    'werte-mittel.png':             (1026, 1226),
    'werte-gross.png':              (1004, 2328),
    'werte-klein-portrait.png':     (1110, 699),
    'werte-mittel-portrait.png':    (1110, 1228),
    'werte-gross-portrait.png':     (1110, 2351),
    # Graue Kaesten
    'meister-schmal.png':           (707, 1349),
    'meister-breit.png':            (2101, 1349),
    'meister-maske.png':            (992, 1276),
    'meister-maske-klein.png':      (992, 532),
    'kastenfeld-schwarz.png':       (4093, 1349),
    # Meistermasken
    'meistermaske-1.png':           (578, 460),
    'meistermaske-2.png':           (578, 777),
    'meistermaske-3.png':           (578, 1139),
    'maske.png':                    (236, 143),
    # Zierleisten und Kopfleisten
    'trenner-oben.png':             (624, 116),
    'trenner-maske.png':            (624, 116),
    'trenner-unten.png':      (1872, 348),
    'trenner-buch.png':              (1872, 348),
    'nsc-kopf.png':                 (1872, 348),
    # Marken
    'aufzaehlung.png':              (257, 139),
    'aufzaehlung-blau.png':         (235, 259),
    'aufzaehlung-rot.png':          (238, 264),
    'auge-schwarz.png':             (3122, 1701),
    'auge-weiss.png':               (6246, 3402),
    'icon-bauer.png':               (304, 384),
    'icon-springer.png':            (414, 567),
    'icon-turm.png':                (414, 567),
    'icon-koenig.png':              (391, 696),
    'fiole.png':                    (107, 107),
    'totenkopf.png':                (107, 107),
    'fokusregel.png':               (1250, 893),
    # Banner, Zierrahmen, Umschlag
    'kapitelbanner.png':            (2481, 510),
    'zierrahmen-einfach.png':       (815, 815),
    'ornament-links.png':           (815, 815),
    'ornament-rechts.png':          (815, 815),
    'ornament-mittig.png':          (206, 964),
    'portraitrahmen.png':           (418, 413),
    'umschlag-vorne.png':           (2551, 3579),
    'umschlag-hinten.png':          (2480, 3508),
    'aventurienkarte.png':          (1417, 2008),
    # Abgeleitet: Kapitelanfang, deckungsgleich auf voller Leinwand
    # Alle drei kommen aus DSA5-Kapitelstart-Beispielgrafik.psd: Pergament
    # und Ornament als Ebenen, der Zierrahmen aus dem erodierten Pergament.
    'kapitelstart-rahmen.png':      (1290, 3543),
    'kapitelstart-pergament.png':   (1290, 3543),
    'kapitelstart-ornament.png':    (1290, 3543),
}

# Die acht Einzelseiten aus den vier Doppelseiten. Eine Doppelseite ist
# 5032 x 3579 px; der Schnitt in der Mitte ergibt je 2516 x 3579 px, also
# 213,0 x 303,0 mm — A4 plus 3 mm Anschnitt an drei Kanten.
for i in range(4):
    SOLL['seite-links-%d.png' % i] = (2516, 3579)
    SOLL['seite-rechts-%d.png' % i] = (2516, 3579)

SCHRIFTEN = ['andlso.ttf', 'GenBasR.ttf', 'GenBasB.ttf',
             'GenBasI.ttf', 'GenBasBI.ttf']

# Ohne diese bricht der Lauf. Der Rest ist nur fuer einzelne Elemente noetig.
# Ohne Endung: eine Vollseitengrafik liegt als .jpg vor, alle anderen als
# .png, und die Klasse nennt sie ohnehin ohne Endung.
UNVERZICHTBAR = {
    'pergament-klein', 'pergament-mittel', 'pergament-lang',
    'werte-klein', 'werte-mittel',
    'kapitelbanner', 'umschlag-vorne',
    'aufzaehlung', 'auge-schwarz', 'auge-weiss',
    'seite-links-0', 'seite-rechts-0',
}


def main():
    projekt = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    zg = os.path.join(projekt, 'grafiken')
    zs = os.path.join(projekt, 'schriften')

    try:
        from PIL import Image
        Image.MAX_IMAGE_PIXELS = None
    except ImportError:
        print('Pillow fehlt. Ohne Pillow kann nur die Vollstaendigkeit')
        print('geprueft werden, nicht die Masse.')
        Image = None

    fehlt, falsch, ok = [], [], 0

    for name, (bs, hs) in sorted(SOLL.items()):
        # Die Vollseitengrafiken liegen als JPEG, alle anderen als PNG. Beide
        # Endungen gelten, denn die Klasse nennt ihre Grafiken ohne Endung.
        p = os.path.join(zg, name)
        if not os.path.isfile(p):
            p = os.path.splitext(p)[0] + '.jpg'
        if not os.path.isfile(p):
            fehlt.append(os.path.splitext(name)[0])
            continue
        if Image is None:
            ok += 1
            continue
        im = Image.open(p)
        if (im.width, im.height) != (bs, hs):
            falsch.append('%s: %d x %d px, erwartet %d x %d'
                          % (os.path.basename(p), im.width, im.height,
                             bs, hs))
        else:
            ok += 1

    sfehlt = [s for s in SCHRIFTEN
              if not os.path.isfile(os.path.join(zs, s))]

    print('Grafiken  : %d von %d in Ordnung' % (ok, len(SOLL)))
    print('Schriften : %d von %d vorhanden' % (len(SCHRIFTEN) - len(sfehlt),
                                               len(SCHRIFTEN)))
    print()

    schwer = False

    if falsch:
        print('MASSE WEICHEN AB (%d):' % len(falsch))
        for f in falsch:
            print('  %s' % f)
        print()
        print('  Andere Fassung des Baukastens? Dann sind die Masse in der')
        print('  Klasse anzupassen — sie stehen dort als Kommentartabelle in')
        print('  Abschnitt 13, und in doku/MASSE.md mit Herleitung.')
        print()
        schwer = True

    if fehlt:
        kritisch = [f for f in fehlt if f in UNVERZICHTBAR]
        print('FEHLT (%d, davon %d unverzichtbar):' % (len(fehlt), len(kritisch)))
        for f in fehlt:
            print('  %s%s' % (f, '   <- unverzichtbar' if f in UNVERZICHTBAR else ''))
        print()
        if kritisch:
            schwer = True

    if sfehlt:
        print('SCHRIFTEN FEHLEN:')
        for s in sfehlt:
            print('  schriften/%s' % s)
        print()
        schwer = True

    if schwer:
        print('Nachholen mit:')
        print('    python3 werkzeuge/aufbereiten.py "/pfad/zu/Scriptorium Aventuris v4"')
        return 1

    if fehlt:
        print('Die fehlenden Dateien betreffen nur einzelne Elemente.')
        print('Der Lauf geht durch, solange sie nicht benutzt werden.')
        return 0

    print('Alles da. Weiter mit:')
    print('    cd beispiel && xelatex beispiel.tex')
    return 0


if __name__ == '__main__':
    sys.exit(main())
