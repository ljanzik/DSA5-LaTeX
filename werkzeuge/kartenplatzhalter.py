#!/usr/bin/env python3
"""Erzeugt Platzhalterbilder fuer Spielkarten, solange die richtigen fehlen.

    python3 werkzeuge/kartenplatzhalter.py "Zwergischer Schmied"
    python3 werkzeuge/kartenplatzhalter.py Schmied Streitaxt Kettenhemd
    python3 werkzeuge/kartenplatzhalter.py --rund Portraet
    python3 werkzeuge/kartenplatzhalter.py --ziel /pfad/zum/projekt Schmied

Wofuer: ein Kartensatz ist lange vor seinen Illustrationen fertig. Wer das
Layout pruefen will — sitzt der Name richtig, passt der Text, deckt das
Bildfeld nichts zu —, braucht dafuer irgendein Bild in der richtigen Form.
Genau das legt dieses Werkzeug an:

    grafiken/platzhalter-<name>.png

Die Bilder sind bewusst als Platzhalter erkennbar: ein Rahmen mit Kreuz,
darin der Name. Kein Grau-in-Grau, das man im Abzug fuer eine Illustration
halten koennte.

Mit --rund wird ein quadratischer Platzhalter mit Kreis erzeugt, passend
fuer \\dsaKartenmedaillon.

Anders als alles andere in grafiken/ gehoeren diese Dateien NICHT Ulisses —
sie sind hier erzeugt. Im Repository liegen sie trotzdem nicht: grafiken/
ist vollstaendig in .gitignore, und eine Ausnahme fuer Wegwerfbilder waere
den Eintrag nicht wert. Wer sie braucht, ruft das Werkzeug auf.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import re
import sys

ZIEL_GRAFIK = 'grafiken'

# Das Bildfeld der Klasse ist 57 mm breit und bis 58 mm hoch. Der
# Platzhalter kommt hochkant im Verhaeltnis 3:4 und wird von
# \dsaKartenbild mit keepaspectratio eingepasst -- so sieht man auch, ob
# das Einpassen stimmt. 600 x 800 px sind bei 300 ppi 50,8 x 67,7 mm.
BREITE, HOEHE = 600, 800
RUND = 600

# Warmes Grau auf dem Pergament, kraeftig genug, um als Platzhalter
# aufzufallen, aber nicht so dunkel, dass es den Satz erschlaegt.
LINIE = (120, 104, 88, 200)
FLAECHE = (120, 104, 88, 28)
SCHRIFT = (90, 76, 62, 235)


def slug(name):
    """'Zwergischer Schmied' -> 'zwergischer-schmied'."""
    t = name.strip().lower()
    for a, b in (('ä', 'ae'), ('ö', 'oe'), ('ü', 'ue'), ('ß', 'ss')):
        t = t.replace(a, b)
    t = re.sub(r'[^a-z0-9]+', '-', t)
    return t.strip('-') or 'platzhalter'


def schriftdatei(projekt):
    """Gentium Basic aus schriften/, wenn da -- sonst None."""
    p = os.path.join(projekt, 'schriften', 'GenBasR.ttf')
    return p if os.path.isfile(p) else None


def beschriften(zeichner, bild, text, pfad):
    from PIL import ImageFont

    # Der Name wird so gross gesetzt, wie er quer hineinpasst, hoechstens
    # ein Fuenfzehntel der Bildhoehe. Ohne Schriftdatei bleibt die
    # Bitmapschrift von Pillow; sie ist haesslich, aber lesbar, und ein
    # Platzhalter darf haesslich sein.
    if pfad is None:
        f = ImageFont.load_default()
        k = zeichner.textbbox((0, 0), text, font=f)
        zeichner.text(((bild.width - (k[2] - k[0])) / 2,
                       (bild.height - (k[3] - k[1])) / 2),
                      text, font=f, fill=SCHRIFT)
        return
    grad = max(12, bild.height // 15)
    while grad > 12:
        f = ImageFont.truetype(pfad, grad)
        k = zeichner.textbbox((0, 0), text, font=f)
        if k[2] - k[0] <= bild.width * 0.8:
            break
        grad -= 2
    f = ImageFont.truetype(pfad, grad)
    k = zeichner.textbbox((0, 0), text, font=f)
    zeichner.text(((bild.width - (k[2] - k[0])) / 2 - k[0],
                   (bild.height - (k[3] - k[1])) / 2 - k[1]),
                  text, font=f, fill=SCHRIFT)


def platzhalter(text, rund, pfad):
    from PIL import Image, ImageDraw

    b, h = (RUND, RUND) if rund else (BREITE, HOEHE)
    bild = Image.new('RGBA', (b, h), (0, 0, 0, 0))
    z = ImageDraw.Draw(bild)
    rand = max(2, b // 60)
    strich = max(2, b // 150)

    if rund:
        z.ellipse([rand, rand, b - rand, h - rand],
                  fill=FLAECHE, outline=LINIE, width=strich)
    else:
        z.rectangle([rand, rand, b - rand, h - rand],
                    fill=FLAECHE, outline=LINIE, width=strich)
        # Das Kreuz: die eine Marke, die einen Platzhalter unverwechselbar
        # macht. Es laeuft in die Ecken, nicht auf den Rand.
        z.line([rand, rand, b - rand, h - rand], fill=LINIE, width=strich)
        z.line([b - rand, rand, rand, h - rand], fill=LINIE, width=strich)
        # Ein Feld hinter der Beschriftung, damit sie auf dem Kreuz lesbar
        # bleibt.
        z.rectangle([rand * 2, h * 0.44, b - rand * 2, h * 0.56],
                    fill=(247, 242, 232, 235))

    beschriften(z, bild, text, pfad)
    return bild


def main():
    args = sys.argv[1:]
    ziel = '.'
    rund = False
    namen = []
    i = 0
    while i < len(args):
        if args[i] == '--ziel':
            i += 1
            ziel = args[i]
        elif args[i] == '--rund':
            rund = True
        elif args[i].startswith('-'):
            print('Unbekannte Option: %s' % args[i])
            return 2
        else:
            namen.append(args[i])
        i += 1

    if not namen:
        print(__doc__)
        return 2

    try:
        from PIL import Image  # noqa: F401
    except ImportError:
        print('Pillow fehlt. Installieren mit:  pip install pillow')
        return 1

    projekt = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    zg = os.path.join(ziel, ZIEL_GRAFIK)
    os.makedirs(zg, exist_ok=True)
    pfad = schriftdatei(projekt)
    if pfad is None:
        print('Hinweis: schriften/GenBasR.ttf fehlt, die Beschriftung')
        print('         kommt in der Bitmapschrift von Pillow.')

    for n in namen:
        bild = platzhalter(n, rund, pfad)
        name = 'platzhalter-%s%s.png' % (slug(n), '-rund' if rund else '')
        bild.save(os.path.join(zg, name), dpi=(300, 300))
        print('%-44s %d x %d px' % (name, bild.width, bild.height))

    print()
    print('Im Dokument ansprechen ohne Endung, etwa:')
    print('    \\dsaKartenbild{platzhalter-%s}' % slug(namen[0]))
    return 0


if __name__ == '__main__':
    sys.exit(main())
