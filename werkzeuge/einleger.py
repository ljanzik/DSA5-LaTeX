#!/usr/bin/env python3
"""Erzeugt die Hintergrundgrafiken fuer den Spielleiterschirm-Einleger.

    python3 werkzeuge/einleger.py
    python3 werkzeuge/einleger.py --grafiken /pfad/zu/grafiken
    python3 werkzeuge/einleger.py --ppi 200
    python3 werkzeuge/einleger.py --pruefen

Der Baukasten hat keinen Querformat-Hintergrund. Er hat aber die vier
Buchseiten, und die tragen am Bund genau das Motiv, das der offizielle
Einleger oben und unten ueber die ganze Breite legt: eine Reihe dunkler
Drachenschuppen mit Goldkante. Am Original-Einleger nachgemessen ist die
obere Leiste 1694 x 111 px auf 811 x 53,2 bp, also 150 ppi und 18,8 mm hoch;
die Schuppenkante der Buchseiten ist bei 300 ppi 8,5 mm breit. Dasselbe
Motiv, andere Groesse. Dieses Werkzeug dreht die Buchkante um 90 Grad und
macht daraus die Leiste, und aus dem Rest der Seite die Pergamentflaeche.

Damit ist die Frage beantwortet, ob sich eine Zierleiste zweckentfremden
laesst: ja, und zwar nicht als Ersatz, sondern als dieselbe Grafik in ihrer
eigentlichen Aufloesung. Der Einleger wird dadurch schlanker gerahmt als das
Original — 8,5 statt 18,8 mm —, weil die Kante nicht hochskaliert wird.
Wer den breiteren Rahmen will, nimmt --leiste 18.8; dann steht die Grafik
auf 136 ppi.

Erzeugt werden, mit N = 0, 1, 2 fuer die drei Buchseitenvarianten:

    einleger-flaeche-N.jpg   303,0 x 216,0 mm   Pergament quer, ohne Kante
    einleger-leiste-oben.png 303,0 x   8,5 mm   Schuppen nach oben
    einleger-leiste-unten.png                   Schuppen nach unten

Die Leisten laufen nach innen ueber 3 mm weich aus. Ohne den Auslauf steht
eine harte Kante auf dem Pergament: die Buchseite hat dort den Uebergang zum
Bund, nicht zum freien Rand. Der Auslauf ist die einzige Erfindung dieses
Werkzeugs und als solche gekennzeichnet.

Die Masse in Millimeter, nicht in Pixel: die Klasse setzt jede Grafik in
ihrer Produktionsgroesse, die Aufloesung ist ihr gleich. Mit --ppi wird das
Ergebnis kleiner, ohne dass sich am Satz etwas aendert.

Das Bildmaterial ist NICHT Teil dieses Projekts. Es gehoert Ulisses Spiele
und steht unter der Vereinbarung ueber Gemeinschaftsinhalte fuer SCRIPTORIUM
AVENTURIS. Dieses Werkzeug arbeitet auf dem, was werkzeuge/aufbereiten.py
zuvor aus dem selbst heruntergeladenen Baukasten nach grafiken/ gelegt hat,
und legt sein Ergebnis daneben — ebenfalls nicht ins Repository.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import argparse
import os
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit('Pillow fehlt. Installieren mit: pip install Pillow')

# ---------------------------------------------------------------- Masse

# Das Papier des Einlegers: DIN A4 quer plus 3 mm Anschnitt an allen vier
# Seiten. Der Baukasten sagt zum Anschnitt „fuers Scriptorium unerheblich",
# die Hintergrundgrafiken liegen aber mit Zugabe ueber dem Papierrand, sonst
# bleiben weisse Raender stehen.
BLATT_BREITE = 297.0 + 2 * 3.0        # 303,0 mm
BLATT_HOEHE = 210.0 + 2 * 3.0         # 216,0 mm

# Die Hoehe der Zierleiste. Vorgabe ist die gemessene Breite der Buchkante
# bei 300 ppi, damit sie in ihrer eigenen Aufloesung steht.
LEISTE_HOEHE = 8.5

# Der weiche Auslauf nach innen. Erfunden, siehe Kopf.
AUSLAUF = 3.0

# Ab welcher Helligkeit eine Bildspalte als Schuppe zaehlt, und wie viele
# Pixel einer Spalte dunkel sein muessen. Gemessen liegt die Kante der drei
# Buchseiten bei 100, 101 und 100 px; der Pergamentgrund daneben ist ueber
# 200 hell, es gibt also viel Luft in beiden Richtungen.
DUNKEL = 110
DUNKELANTEIL = 0.8

# Die Quellen. Links liegt die Kante am linken Bildrand, rechts am rechten.
QUELLEN = [('seite-links-%d', 'links'), ('seite-rechts-%d', 'rechts')]
VARIANTEN = 3


def mm2px(mm, ppi):
    return max(1, int(round(mm / 25.4 * ppi)))


def laden(ordner, name):
    """Sucht die Datei mit einer der bekannten Endungen."""
    for endung in ('.jpg', '.jpeg', '.png'):
        pfad = os.path.join(ordner, name + endung)
        if os.path.exists(pfad):
            return Image.open(pfad).convert('RGB'), pfad
    return None, os.path.join(ordner, name)


def kante_finden(bild, seite):
    """Die Breite der Schuppenkante in Pixeln.

    Gesucht wird ueber das mittlere Drittel der Hoehe: oben und unten franst
    die Kante in der Buchseite aus, in der Mitte steht sie voll. Zurueck
    kommt die Spaltenzahl vom jeweiligen Bildrand aus.
    """
    breite, hoehe = bild.size
    grau = bild.convert('L')
    mitte = grau.crop((0, int(hoehe * 0.35), breite, int(hoehe * 0.65)))
    hoehe_mitte = mitte.size[1]
    pixel = mitte.load()

    spalten = []
    for x in range(breite):
        dunkel = sum(1 for y in range(0, hoehe_mitte, 4)
                     if pixel[x, y] < DUNKEL)
        spalten.append(dunkel / len(range(0, hoehe_mitte, 4)) > DUNKELANTEIL)

    if seite == 'links':
        n = 0
        while n < breite and spalten[n]:
            n += 1
    else:
        n = 0
        while n < breite and spalten[breite - 1 - n]:
            n += 1
    return n


def streifen_schneiden(bild, seite, kante):
    """Schneidet die Schuppenkante aus der Buchseite heraus, senkrecht.

    Etwas mehr als die reine Kante: der Uebergang zum Pergament gehoert
    dazu, sonst steht die Schuppe frei auf dem Grund. Zurueck kommt der
    Streifen in der Lage der Buchseite — Schuppen links, Auslauf rechts.
    """
    breite, hoehe = bild.size
    tiefe = int(round(kante * 1.35))
    if seite == 'links':
        return bild.crop((0, 0, tiefe, hoehe))
    # Die rechte Buchkante wird gespiegelt, damit auch hier die Schuppen
    # links liegen und alle Leisten aus derselben Vorlage entstehen.
    return bild.crop((breite - tiefe, 0, breite, hoehe)) \
               .transpose(Image.FLIP_LEFT_RIGHT)


def leiste_bauen(bild, seite, kante, ppi, leiste_mm, auslauf_mm, lage):
    """Macht aus der Schuppenkante die Zierleiste einer Blattkante.

    lage ist 'oben', 'unten', 'links' oder 'rechts'. Das Ergebnis liegt so,
    dass die Schuppen an der Papierkante sitzen und der weiche Auslauf nach
    innen zeigt; Laenge ist die Blattkante, Dicke ist leiste_mm.
    """
    streifen = streifen_schneiden(bild, seite, kante)

    # Erst waagerecht bauen — Schuppen oben, Auslauf unten —, dann in die
    # Lage drehen. So gibt es nur einen Weg fuer alle vier Kanten.
    laenge_mm = BLATT_BREITE if lage in ('oben', 'unten') else BLATT_HOEHE
    ziel_b = mm2px(laenge_mm, ppi)
    ziel_h = mm2px(leiste_mm, ppi)
    # ROTATE_270 dreht im Uhrzeigersinn: die linke Bildkante (die Schuppen)
    # wird die obere Kante der Leiste.
    streifen = streifen.transpose(Image.ROTATE_270).resize(
        (ziel_b, ziel_h), Image.LANCZOS)

    # Der Auslauf: eine Maske, die von oben deckend nach unten durchsichtig
    # wird. Nur die untersten auslauf_mm sind betroffen.
    maske = Image.new('L', (ziel_b, ziel_h), 255)
    tiefe_aus = min(ziel_h, mm2px(auslauf_mm, ppi))
    if tiefe_aus > 1:
        zeile = maske.load()
        for k in range(tiefe_aus):
            y = ziel_h - tiefe_aus + k
            # quadratisch, nicht linear: linear bleibt in der Mitte des
            # Auslaufs eine sichtbare Kante stehen.
            wert = int(round(255 * (1.0 - (k + 1) / tiefe_aus) ** 2))
            for x in range(ziel_b):
                zeile[x, y] = wert

    ergebnis = streifen.convert('RGBA')
    ergebnis.putalpha(maske)

    if lage == 'unten':
        ergebnis = ergebnis.transpose(Image.FLIP_TOP_BOTTOM)
    elif lage == 'links':
        # +90 Grad: die Oberkante der waagerechten Leiste wird die linke.
        ergebnis = ergebnis.transpose(Image.ROTATE_90)
    elif lage == 'rechts':
        ergebnis = ergebnis.transpose(Image.ROTATE_270)
    return ergebnis


def flaeche_bauen(bild, seite, kante, ppi):
    """Dreht die Buchseite ins Querformat und schneidet die Kante weg.

    Uebrig bleibt reines Pergament. Die Seite ist nach dem Drehen 303,0 x
    203,7 mm gross und damit 6,3 mm zu niedrig fuer das Blatt; sie wird
    proportional auf die Blatthoehe gebracht und an der Breite mittig
    beschnitten. Der Faktor ist 1,06, die Grafik steht danach auf 283 ppi.
    """
    breite, hoehe = bild.size
    # Grosszuegig schneiden: der ausgefranste Uebergang neben der Kante darf
    # nicht stehen bleiben, sonst laeuft ein dunkler Schatten quer durchs
    # Blatt.
    weg = int(round(kante * 1.6))
    if seite == 'links':
        rest = bild.crop((weg, 0, breite, hoehe)).transpose(Image.ROTATE_270)
    else:
        rest = bild.crop((0, 0, breite - weg, hoehe)).transpose(Image.ROTATE_90)

    ziel_b = mm2px(BLATT_BREITE, ppi)
    ziel_h = mm2px(BLATT_HOEHE, ppi)
    faktor = max(ziel_b / rest.size[0], ziel_h / rest.size[1])
    zwischen = rest.resize((max(ziel_b, int(round(rest.size[0] * faktor))),
                            max(ziel_h, int(round(rest.size[1] * faktor)))),
                           Image.LANCZOS)
    links = (zwischen.size[0] - ziel_b) // 2
    oben = (zwischen.size[1] - ziel_h) // 2
    return zwischen.crop((links, oben, links + ziel_b, oben + ziel_h))


def main():
    p = argparse.ArgumentParser(
        description='Hintergrundgrafiken fuer den Einleger im Querformat.')
    p.add_argument('--grafiken', default='grafiken',
                   help='Ordner mit den aufbereiteten Grafiken (Vorgabe: grafiken)')
    p.add_argument('--ppi', type=int, default=300,
                   help='Aufloesung der Ergebnisse (Vorgabe: 300)')
    p.add_argument('--leiste', type=float, default=LEISTE_HOEHE,
                   help='Hoehe der Zierleiste in mm (Vorgabe: %.1f)' % LEISTE_HOEHE)
    p.add_argument('--auslauf', type=float, default=AUSLAUF,
                   help='Weicher Auslauf nach innen in mm (Vorgabe: %.1f)' % AUSLAUF)
    p.add_argument('--png', action='store_true',
                   help='Flaechen als PNG statt JPEG (verlustlos, viel groesser)')
    p.add_argument('--pruefen', action='store_true',
                   help='Nur messen und berichten, nichts schreiben')
    a = p.parse_args()

    if not os.path.isdir(a.grafiken):
        sys.exit('Ordner %s gibt es nicht. Zuerst werkzeuge/aufbereiten.py '
                 'laufen lassen.' % a.grafiken)

    fehlt = []
    gemessen = []
    for muster, seite in QUELLEN:
        for n in range(VARIANTEN):
            name = muster % n
            bild, pfad = laden(a.grafiken, name)
            if bild is None:
                fehlt.append(pfad)
                continue
            kante = kante_finden(bild, seite)
            gemessen.append((name, seite, bild, kante))
            print('  %-18s %5d x %5d px, Kante %3d px = %4.1f mm'
                  % (name, bild.size[0], bild.size[1], kante,
                     kante / 300 * 25.4))

    if fehlt:
        print('\nEs fehlen: %s' % ', '.join(os.path.basename(f) for f in fehlt))
        if not gemessen:
            sys.exit('Nichts zu tun.')

    if a.pruefen:
        print('\nNur geprueft, nichts geschrieben.')
        return

    print()
    # Die Flaechen: eine je Buchseitenvariante, aus der linken Seite.
    for name, seite, bild, kante in gemessen:
        if seite != 'links':
            continue
        n = name[-1]
        flaeche = flaeche_bauen(bild, seite, kante, a.ppi)
        ziel = os.path.join(a.grafiken, 'einleger-flaeche-%s' % n)
        if a.png:
            flaeche.save(ziel + '.png', optimize=True)
            ziel += '.png'
        else:
            flaeche.save(ziel + '.jpg', quality=88, optimize=True)
            ziel += '.jpg'
        print('  %-28s %5d x %5d px  %.1f x %.1f mm'
              % (os.path.basename(ziel), flaeche.size[0], flaeche.size[1],
                 BLATT_BREITE, BLATT_HOEHE))

    # Die vier Leisten. Oben und links kommen aus der linken Buchkante,
    # unten und rechts aus der rechten: zwei verschiedene Schuppenmuster,
    # damit sich gegenueberliegende Kanten nicht spiegelbildlich
    # wiederholen — das faellt sofort auf.
    for lage, seite_soll in (('oben', 'links'), ('unten', 'rechts'),
                             ('links', 'links'), ('rechts', 'rechts')):
        quelle = next((g for g in gemessen
                       if g[1] == seite_soll and g[0].endswith('0')), None)
        if quelle is None:
            print('  Leiste %s: Quelle fehlt, uebersprungen' % lage)
            continue
        name, seite, bild, kante = quelle
        leiste = leiste_bauen(bild, seite, kante, a.ppi, a.leiste, a.auslauf,
                              lage)
        ziel = os.path.join(a.grafiken, 'einleger-leiste-%s.png' % lage)
        leiste.save(ziel, optimize=True)
        print('  %-28s %5d x %5d px  (aus %s)'
              % (os.path.basename(ziel), leiste.size[0], leiste.size[1],
                 name))

    print('\nFertig. Die Dateien gehoeren nicht ins Repository.')


if __name__ == '__main__':
    main()
