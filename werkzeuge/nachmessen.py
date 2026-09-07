#!/usr/bin/env python3
"""Vermisst ein gesetztes PDF: wo sitzt welche Grafik, wo welche Textzeile.

    python3 werkzeuge/nachmessen.py heft.pdf
    python3 werkzeuge/nachmessen.py heft.pdf --seite 5
    python3 werkzeuge/nachmessen.py heft.pdf --seite 5 --text

Warum es das braucht: die Klasse ist aus den Massen des Baukastens gebaut,
aber ein Mass im Quelltext ist noch kein Mass auf dem Papier. Ein Kasten kann
2 mm zu weit links stehen, ein Bild um seine halbe Breite verschoben sein, ein
Textblock neben seinem Rahmen liegen — und im PDF sieht man das als
„irgendwie schief", nicht als Zahl. Dieses Werkzeug gibt die Zahl.

Ausgegeben wird je Seite:

  * jede Grafik mit ihrer Lage und Groesse in Millimeter, dazu ihre
    Pixelmasse. Ueber die Pixelmasse ist sie zu erkennen: sie stehen in
    doku/MASSE.md und werden von werkzeuge/pruefen.py geprueft.
  * mit --text zusaetzlich jede Textzeile mit Grundlinie, Rand und Schriftgrad

Alle Masse in Millimeter, gemessen von der linken oberen Papierecke, weil
das die Blickrichtung beim Vergleich mit einer Vorlage ist. Die Grundlinie
wird von oben angegeben, die Angabe „von unten" steht daneben, weil manche
Masse des Baukastens von der unteren Kante aus gelten.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import sys

MM = 25.4 / 72.0            # ein PDF-Punkt in Millimeter


def hilfe():
    print(__doc__)
    return 0


def bildname(px, py):
    """Ordnet Pixelmasse einer Grafik des Baukastens zu, wenn sie bekannt sind.

    Die Zuordnung ist nicht immer eindeutig: die acht Seitenhintergruende
    haben alle 2516 x 3579 px, Pergament und Ornament des Kapitelanfangs
    beide 1290 x 3543. Mehrdeutige Treffer werden deshalb als solche
    ausgewiesen — sonst haelt man zwei Grafiken fuer eine doppelt gesetzte.
    """
    try:
        from pruefen import SOLL
    except ImportError:
        return None
    treffer = [name.rsplit('.', 1)[0]
               for name, mass in SOLL.items() if mass == (px, py)]
    if not treffer:
        return None
    if len(treffer) == 1:
        return treffer[0]
    treffer.sort()
    return '%s oder %d weitere' % (treffer[0], len(treffer) - 1)


def seite_vermessen(seite, nummer, mit_text):
    breite, hoehe = seite.width, seite.height
    print('')
    print('=' * 78)
    print('Seite %d   %.1f x %.1f mm' % (nummer, breite * MM, hoehe * MM))
    print('=' * 78)

    bilder = sorted(seite.images, key=lambda b: (b['top'], b['x0']))
    if bilder:
        print('')
        print('Grafiken (%d):' % len(bilder))
        print('  %-22s %9s %9s %9s %9s %6s' % (
            'Pixelmasse / Name', 'x links', 'y oben', 'Breite', 'Hoehe', 'ppi'))
        for b in bilder:
            px, py = b.get('srcsize', (0, 0))
            br = (b['x1'] - b['x0']) * MM
            ho = (b['bottom'] - b['top']) * MM
            ppi = (px / (br / 25.4)) if br > 0 else 0
            name = bildname(px, py)
            kennung = '%dx%d' % (px, py)
            if name:
                kennung = '%s (%s)' % (name, kennung)
            print('  %-22s %6.2f mm %6.2f mm %6.2f mm %6.2f mm %6.0f' % (
                kennung[:22], b['x0'] * MM, b['top'] * MM, br, ho, ppi))
            if len(kennung) > 22:
                print('      voller Name: %s' % kennung)

    striche = [k for k in seite.rects] + [k for k in seite.lines]
    if striche:
        print('')
        print('Linien und Flaechen: %d' % len(striche))
        for s in striche[:12]:
            print('  x %6.2f..%6.2f mm   y %6.2f..%6.2f mm   %s' % (
                s['x0'] * MM, s['x1'] * MM, s['top'] * MM, s['bottom'] * MM,
                'gefuellt' if s.get('fill') else 'Linie'))
        if len(striche) > 12:
            print('  ... und %d weitere' % (len(striche) - 12))

    if not mit_text:
        return

    # Die echte Grundlinie steht in der Textmatrix des Zeichens, nicht in
    # seiner Box: box['bottom'] ist die Unterkante samt Unterlaenge und liegt
    # je Schriftgrad anders. Fuer eine Rasterpruefung braucht es die
    # Grundlinie, und die ist matrix[5] — in PDF-Koordinaten von unten.
    zeilen = {}
    for z in seite.chars:
        grundlinie = hoehe - z['matrix'][5]
        schluessel = (round(grundlinie, 1), z['fontname'], round(z['size'], 1))
        eintrag = zeilen.setdefault(schluessel, {'x0': z['x0'], 'x1': z['x1'],
                                                 'text': ''})
        eintrag['x0'] = min(eintrag['x0'], z['x0'])
        eintrag['x1'] = max(eintrag['x1'], z['x1'])
        eintrag['text'] += z['text']

    # Das Grundlinienraster: 12 pt Abstand, erste Linie 12,7 mm unter der
    # Papieroberkante. Zu jeder Zeile wird gesagt, wie weit sie davon abweicht.
    raster_erste = 12.7 / MM        # in pt
    raster_schritt = 12.0
    print('')
    print('Textzeilen (%d):' % len(zeilen))
    print('  %10s %9s %9s %9s %6s %7s  %s' % (
        'Grundlinie', 'von unten', 'x links', 'x rechts', 'Grad', 'Raster',
        'Anfang'))
    for (grundlinie, font, grad) in sorted(zeilen):
        e = zeilen[(grundlinie, font, grad)]
        stufen = (grundlinie - raster_erste) / raster_schritt
        ab = (stufen - round(stufen)) * raster_schritt
        print('  %7.2f mm %6.2f mm %6.2f mm %6.2f mm %5.1f %+6.2f  %s' % (
            grundlinie * MM, (hoehe - grundlinie) * MM, e['x0'] * MM,
            e['x1'] * MM, grad, ab, e['text'][:32]))


def main():
    argumente = [a for a in sys.argv[1:] if not a.startswith('--')]
    if not argumente or '--hilfe' in sys.argv or '-h' in sys.argv:
        return hilfe()

    try:
        import pdfplumber
    except ImportError:
        print('pdfplumber fehlt. Nachinstallieren mit:')
        print('    python3 -m pip install pdfplumber')
        return 1

    pdf_pfad = argumente[0]
    mit_text = '--text' in sys.argv
    seitenwahl = None
    if '--seite' in sys.argv:
        i = sys.argv.index('--seite')
        if i + 1 < len(sys.argv):
            seitenwahl = [int(s) for s in sys.argv[i + 1].split(',')]

    # pruefen.py liegt daneben und bringt die Sollmasse mit.
    import os
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

    with pdfplumber.open(pdf_pfad) as pdf:
        print('%s: %d Seiten' % (pdf_pfad, len(pdf.pages)))
        for nummer, seite in enumerate(pdf.pages, start=1):
            if seitenwahl and nummer not in seitenwahl:
                continue
            seite_vermessen(seite, nummer, mit_text)
    return 0


if __name__ == '__main__':
    sys.exit(main())
