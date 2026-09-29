#!/usr/bin/env python3
"""Legt Platzhaltergrafiken in grafiken/ an, damit die Beispiele ohne das
Material aus dem Baukasten bauen.

    python3 werkzeuge/platzhalter.py            fehlende Grafiken anlegen
    python3 werkzeuge/platzhalter.py --trotzdem auch neben echtem Material
    python3 werkzeuge/platzhalter.py --weg      angelegte Platzhalter loeschen

Wozu: die Grafiken gehoeren Ulisses Spiele und duerfen nicht ins Repository.
Ohne sie bricht jeder Lauf ab -- die Klasse misst viele Grafiken aus, bevor
sie sie setzt, und dafuer muss die Datei da sein. Die CI hat das Material
nicht, und wer die Klasse nur ansehen will, auch nicht.

Jeder Platzhalter hat genau die Pixelmasse aus werkzeuge/pruefen.py, also bei
300 ppi genau die Produktionsgroesse. Damit stehen Kaesten, Banner und
Seitenhintergruende so gross da wie mit dem echten Material, und das Raster
bleibt pruefbar. Zusammen mit der Klassenoption ersatz (freie Schrift statt
der Baukastenschriften) baut dann jedes Beispiel.

Eigene Bilder, die die Beispiele ueber grafiken/<name> einbinden und die
nicht aus dem Baukasten kommen -- etwa die Battlemap --, bekommen einen
Platzhalter in fester Groesse, 1500 x 1000 px. Die Beispiele setzen solche
Bilder deckend in einen vorgegebenen Rahmen; das Seitenverhaeltnis der
Datei verschiebt dort nichts.

Geschrieben wird nur, was fehlt. Echtes Material wird nie ueberschrieben.
Liegt schon echtes Material in grafiken/, bricht das Werkzeug ab: ein
Ordner halb aus Baukasten, halb aus Platzhaltern baut zwar, aber das PDF
saehe nach einem Fehler in der Klasse aus. Wer das will, sagt --trotzdem.

Jeder Platzhalter traegt eine Kennung in den Metadaten der Datei. Daran
erkennt --weg, was es loeschen darf, und die Pruefung oben, was echt ist.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import re
import sys

from pruefen import SOLL

KENNUNG = 'dsa5latex-platzhalter'
EIGENBILD = (1500, 1000)


def ist_platzhalter(pfad, Image):
    try:
        with Image.open(pfad) as im:
            return KENNUNG in (im.info.get('comment', b'') or b'').decode(
                'latin-1', 'replace') \
                or im.info.get('Kennung') == KENNUNG
    except Exception:
        return False


def vorhanden(zg, name):
    # Wie pruefen.py: die Klasse nennt ihre Grafiken ohne Endung, gefunden
    # wird .jpg oder .png.
    stamm = os.path.splitext(name)[0]
    for endung in ('.png', '.jpg', '.jpeg'):
        p = os.path.join(zg, stamm + endung)
        if os.path.isfile(p):
            return p
    return None


def eigenbilder(projekt):
    # Bilder, die ein Beispiel ueber grafiken/<name> einbindet. Kommentare
    # bleiben aussen vor, sonst wuerde jeder Name aus einem Erklaertext zur
    # Datei.
    namen = set()
    ordner = os.path.join(projekt, 'beispiel')
    for datei in sorted(os.listdir(ordner)):
        if not datei.endswith('.tex'):
            continue
        with open(os.path.join(ordner, datei), encoding='utf-8') as f:
            for zeile in f:
                zeile = re.sub(r'(?<!\\)%.*', '', zeile)
                namen.update(re.findall(r'grafiken/([A-Za-z0-9_\-]+)', zeile))
    soll = {os.path.splitext(n)[0] for n in SOLL}
    return sorted(namen - soll)


def zeichnen(name, groesse, Image, ImageDraw, ImageFont):
    b, h = groesse
    im = Image.new('RGB', groesse, (208, 208, 208))
    d = ImageDraw.Draw(im)
    staerke = max(2, min(b, h) // 150)
    d.rectangle([0, 0, b - 1, h - 1], outline=(96, 96, 96), width=staerke)
    d.line([0, 0, b - 1, h - 1], fill=(150, 150, 150), width=staerke)
    d.line([0, h - 1, b - 1, 0], fill=(150, 150, 150), width=staerke)
    text = '%s\n%d x %d px' % (os.path.splitext(name)[0], b, h)
    grad = max(10, min(b // 14, h // 5))
    try:
        schrift = ImageFont.load_default(size=grad)
    except TypeError:
        # Pillow vor 10.1 kennt keine Groesse fuer die eingebaute Schrift.
        schrift = ImageFont.load_default()
    d.multiline_text((b / 2, h / 2), text, fill=(40, 40, 40), font=schrift,
                     anchor='mm', align='center')
    return im


def speichern(im, pfad, Image):
    if pfad.lower().endswith(('.jpg', '.jpeg')):
        im.save(pfad, quality=60, comment=KENNUNG.encode('ascii'))
    else:
        from PIL import PngImagePlugin
        info = PngImagePlugin.PngInfo()
        info.add_text('Kennung', KENNUNG)
        im.save(pfad, pnginfo=info, dpi=(300, 300))


def main(argv):
    try:
        from PIL import Image, ImageDraw, ImageFont
        Image.MAX_IMAGE_PIXELS = None
    except ImportError:
        print('Pillow fehlt: pip install pillow')
        return 1

    trotzdem = '--trotzdem' in argv
    weg = '--weg' in argv

    projekt = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    zg = os.path.join(projekt, 'grafiken')
    os.makedirs(zg, exist_ok=True)

    if weg:
        n = 0
        for datei in sorted(os.listdir(zg)):
            p = os.path.join(zg, datei)
            if os.path.isfile(p) and ist_platzhalter(p, Image):
                os.remove(p)
                n += 1
        print('%d Platzhalter geloescht.' % n)
        return 0

    echt = [os.path.basename(p) for p in
            (vorhanden(zg, n) for n in SOLL)
            if p and not ist_platzhalter(p, Image)]
    if echt and not trotzdem:
        print('grafiken/ enthaelt schon %d Dateien aus dem Baukasten, etwa %s.'
              % (len(echt), echt[0]))
        print('Platzhalter daneben ergaeben einen gemischten Satz. Abgebrochen.')
        print('Wer das will: --trotzdem')
        return 1

    auftrag = [(n, g) for n, g in sorted(SOLL.items())]
    auftrag += [(n + '.png', EIGENBILD) for n in eigenbilder(projekt)]

    neu = 0
    for name, groesse in auftrag:
        if vorhanden(zg, name):
            continue
        speichern(zeichnen(name, groesse, Image, ImageDraw, ImageFont),
                  os.path.join(zg, name), Image)
        neu += 1

    print('%d Platzhalter angelegt, %d waren schon da.'
          % (neu, len(auftrag) - neu))
    print('Bauen mit der Klassenoption ersatz, etwa:')
    print('    cd beispiel && DSA5_OPTIONEN=ersatz latexmk beispiel.tex')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
