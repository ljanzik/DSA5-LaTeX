#!/usr/bin/env python3
"""Bereitet die Grafiken und Schriften fuer dsa5-latex aus dem offiziellen
Scriptorium-Baukasten auf.

    python3 werkzeuge/aufbereiten.py "/pfad/zu/Scriptorium Aventuris v4"
    python3 werkzeuge/aufbereiten.py "/pfad/zum/Baukasten" --ziel /pfad/zum/projekt
    python3 werkzeuge/aufbereiten.py --liste
    python3 werkzeuge/aufbereiten.py "/pfad/zum/Baukasten" --png

Mit --ziel schreibt es grafiken/ und schriften/ in ein anderes Projekt,
das diese Klasse benutzt. Ohne --ziel in dieses hier.

Die vier Doppelseiten und der Rueckumschlag werden als JPEG abgelegt: als PNG
sind das 7 bis 13 MB je Datei und im gesetzten PDF ueber 50 MB, als JPEG in
Qualitaet 88 unter 1,5 MB, ohne sichtbaren Unterschied an einer
Pergamentflaeche. Mit --png bleibt alles verlustlos.

Das Bildmaterial ist NICHT Teil dieses Projekts und darf es nicht sein: es
gehoert Ulisses Spiele und steht unter der Vereinbarung ueber
Gemeinschaftsinhalte fuer SCRIPTORIUM AVENTURIS, die mit Apache 2.0 nicht
vereinbar ist. Dieses Werkzeug holt es aus dem Paket, das jeder selbst
herunterlaedt, und benennt es auf Namen ohne Leerzeichen und Umlaute um,
weil LaTeX mit beidem schlecht umgeht.

Der Baukasten, kostenlos bei Ulisses:
https://www.ulisses-ebooks.de/de/product/197880/scriptorium-aventuris-layout-baukasten

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import shutil
import sys

ZIEL_GRAFIK = 'grafiken'
ZIEL_SCHRIFT = 'schriften'

# ---------------------------------------------------------------- Tabellen

# Einfaches Kopieren mit Umbenennung.
# Zielname -> Liste moeglicher Quellpfade im Baukasten.
# Mehrere Kandidaten, weil manche Dateien mit dem Zusatz " Kopie" vorliegen.
KOPIEREN = {
    # Pergamentkaesten
    'pergament-klein.png':        ['PNG innen/Kasten_Pergament_ver3 Kopie.png',
                                   'PNG innen/Kasten_Pergament_ver3.png'],
    'pergament-mittel.png':       ['PNG innen/Kasten_Pergament_ver2_1 Kopie.png',
                                   'PNG innen/Kasten_Pergament_ver2_1.png'],
    'pergament-lang.png':         ['PNG innen/Kasten_Pergament_ver1 Kopie.png',
                                   'PNG innen/Kasten_Pergament_ver1.png'],
    'pergament-breit.png':        ['PNG innen/Kasten_Pergament.png'],
    'pergament-schmal.png':       ['PNG innen/Kasten_Pergament_sehr schmal.png'],
    # Wertekaesten
    'werte-klein.png':            ['PNG innen/Kleiner Wertekasten.png'],
    'werte-mittel.png':           ['PNG innen/Mittlerer Wertekaste.png',
                                   'PNG innen/Mittlerer Wertekasten.png'],
    'werte-gross.png':            ['PNG innen/Grosser Wertekasten.png'],
    'werte-klein-portrait.png':   ['PNG innen/Kleiner Wertekasten mit Portrait.png'],
    'werte-mittel-portrait.png':  ['PNG innen/Mittlerer Wertekaste mit Portrait.png',
                                   'PNG innen/Mittlerer Wertekasten mit Portrait.png'],
    'werte-gross-portrait.png':   ['PNG innen/Grosser Wertekasten mit Portrait.png'],
    # Graue Kaesten
    'meister-schmal.png':         ['PNG innen/Meisterkasten Kopie.png',
                                   'PNG innen/Meisterkasten.png'],
    'meister-breit.png':          ['PNG innen/Maskenfeld_schwarz2 Kopie.png',
                                   'PNG innen/Maskenfeld_schwarz2.png'],
    'meister-maske.png':          ['PNG innen/MeisterkastenMitMaske.png'],
    'meister-maske-klein.png':    ['PNG innen/MeisterkastenMitMaskeSml.png'],
    'kastenfeld-schwarz.png':     ['PNG innen/Kastenfeld_schwarz Kopie.png',
                                   'PNG innen/Kastenfeld_schwarz.png'],
    # Meistermasken mit fertiger Verbindung
    'meistermaske-1.png':         ['PNG innen/FertigeMeistermaske-1.png'],
    'meistermaske-2.png':         ['PNG innen/FertigeMeistermaske-2.png'],
    'meistermaske-3.png':         ['PNG innen/FertigeMeistermaske-3.png'],
    'maske.png':                  ['PNG innen/Maske.png'],
    # Zierleisten und Kopfleisten
    'trenner-oben.png':           ['PNG innen/Absatztrenner_oben Kopie.png',
                                   'PNG innen/Absatztrenner_oben.png'],
    'trenner-unten.png':          ['PNG innen/Absatztrenner_unten_Maske Kopie.png',
                                   'PNG innen/Absatztrenner_unten_Maske.png'],
    'trenner-unten-breit.png':    ['PNG innen/Absatztrenner_unten Kopie.png',
                                   'PNG innen/Absatztrenner_unten.png'],
    'vorlesetext.png':            ['PNG innen/Text zum NachlesenV3.png'],
    'nsc-kopf.png':               ['PNG innen/NPC_Kasten_Oben Kopie.png',
                                   'PNG innen/NPC_Kasten_Oben.png'],
    # Marken im Text
    'aufzaehlung.png':            ['PNG innen/Aufzaehlungszeichen Kopie.png',
                                   'PNG innen/Aufzaehlungszeichen.png'],
    'auge-schwarz.png':           ['PNG innen/Auge_Schwarz Kopie.png',
                                   'PNG innen/Auge_Schwarz.png'],
    'auge-weiss.png':             ['PNG innen/Auge_Weiss Kopie.png',
                                   'PNG innen/Auge_Weiss.png'],
    'icon-bauer.png':             ['PNG innen/BauerIcon.png'],
    'icon-springer.png':          ['PNG innen/SpringerIcon.png'],
    'icon-turm.png':              ['PNG innen/TurmIcon.png'],
    'icon-koenig.png':            ['PNG innen/KoenigIcon.png'],
    'fiole.png':                  ['PNG innen/Einfach_Fiole.png'],
    'totenkopf.png':              ['PNG innen/Schwierig_Totenkopf.png'],
    'fokusregel.png':             ['PNG innen/fokusregeln_matthias_rothenaicher_v2.png'],
    # Banner und Zierrahmen
    'kapitelbanner.png':          ['PNG innen/DSA5-Kapitelstart-Banner Kopie.png',
                                   'PNG innen/DSA5-Kapitelstart-Banner.png'],
    'zierrahmen-einfach.png':     ['PNG innen/einfacher_Kasten Kopie.png',
                                   'PNG innen/einfacher_Kasten.png'],
    'ornament-links.png':         ['PNG innen/Ornament_Kasten_links Kopie.png',
                                   'PNG innen/Ornament_Kasten_links.png'],
    'ornament-rechts.png':        ['PNG innen/Ornament_Kasten_rechts.png'],
    'ornament-mittig.png':        ['PNG innen/Ornament_Kasten_mittig Kopie.png',
                                   'PNG innen/Ornament_Kasten_mittig.png'],
    # Umschlag
    'umschlag-vorne.png':         ['PNG aussen/Scriptorium Aventuris -vorne.png'],
    'umschlag-hinten.png':        ['PNG aussen/Scriptorium Aventuris -hinten.png'],
}

# PSD-Dateien, aus denen die flache Gesamtansicht genuegt.
PSD_FLACH = {
    'aufzaehlung-blau.png':       ['Links/AufzaehlerDSA5_Rueckseite_blau.psd'],
    'aufzaehlung-rot.png':        ['Links/AufzaehlerDSA5_Rueckseite_rot.psd'],
    'portraitrahmen.png':         ['Links/Ornament_Portrait_Wertekasten.psd'],
    'aventurienkarte.png':        ['Links/Aventurienkarte-Komplett.psd'],
}

# Die vier Doppelseiten, die in Einzelseiten geschnitten werden.
DOPPELSEITEN = [
    ['Links/Doppelseite1_A4_scriptorium_3mm.jpg.jpg',
     'Links/Doppelseite1_A4_scriptorium_3mm.jpg'],
    ['Links/Doppelseite2_A4_scriptorium_3mm.jpg'],
    ['Links/Doppelseite3_A4_scriptorium_3mm.jpg'],
    ['Links/Doppelseite4_A4_scriptorium_3mm.jpg'],
]

# Der Kapitelanfang wird aus der geschichteten PSD zusammengesucht.
# Die Ebenennamen stammen aus DSA5-Kapitelstart-Beispielgrafik.psd.
KAPITELSTART_PSD = ['Links/DSA5-Kapitelstart-Beispielgrafik.psd']
KAPITELSTART_EBENEN = {
    'kapitelstart-pergament.png': 'Pergament',   # Teiltreffer im Ebenennamen
    'kapitelstart-ornament.png':  'Ebene 10',
}

# Diese Grafiken werden als JPEG abgelegt, nicht als PNG. Es sind die
# Vollseitengrafiken: 2516 x 3579 px in RGB, als PNG 7 bis 13 MB je Datei, als
# JPEG in Qualitaet 88 unter 1,5 MB. Einen Alphakanal haben sie nicht, und
# ihre Motive sind Pergamentflaechen mit weichen Verlaeufen — dafuer ist JPEG
# gemacht. Wer sie doch verlustlos will, ruft das Werkzeug mit --png auf.
#
# Der Coverrahmen ist NICHT dabei: er hat echte Transparenz.
ALS_JPEG = {
    'umschlag-hinten',
    'seite-links-0', 'seite-links-1', 'seite-links-2', 'seite-links-3',
    'seite-rechts-0', 'seite-rechts-1', 'seite-rechts-2', 'seite-rechts-3',
}
JPEG_QUALITAET = 88

SCHRIFTEN = ['andlso.ttf', 'GenBasR.ttf', 'GenBasB.ttf',
             'GenBasI.ttf', 'GenBasBI.ttf']


# ---------------------------------------------------------------- Helfer

def hat_alpha(bild):
    """Ist wirklich etwas durchsichtig, oder nur ein leerer Alphakanal?"""
    if bild.mode not in ('RGBA', 'LA', 'P'):
        return False
    a = bild.convert('RGBA').split()[3]
    return a.getextrema()[0] < 255


def speichern(bild, ordner, name, nur_png=False):
    """Legt das Bild unter <name> ab, als JPEG wenn es dafuer vorgesehen ist.

    <name> kommt mit der Endung .png herein; steht der Name in ALS_JPEG und
    hat das Bild keine Transparenz, wird daraus .jpg. Die Klasse nennt ihre
    Grafiken ohne Endung, deshalb ist der Wechsel dort nicht zu merken.
    Zurueck kommt der wirklich geschriebene Dateiname.
    """
    stamm = os.path.splitext(name)[0]
    if not nur_png and stamm in ALS_JPEG and not hat_alpha(bild):
        ziel = os.path.join(ordner, stamm + '.jpg')
        bild.convert('RGB').save(ziel, 'JPEG',
                                 quality=JPEG_QUALITAET, optimize=True,
                                 progressive=False, subsampling=0)
        # Ein altes PNG desselben Namens muss weg, sonst findet graphicx es
        # zuerst und die Ersparnis verpufft.
        alt = os.path.join(ordner, stamm + '.png')
        if os.path.isfile(alt):
            os.remove(alt)
        return stamm + '.jpg'
    bild.save(os.path.join(ordner, name))
    return name


def finde(wurzel, kandidaten):
    for k in kandidaten:
        p = os.path.join(wurzel, *k.split('/'))
        if os.path.isfile(p):
            return p
    return None


def liste_ausgeben():
    print('Zuordnung Quelle -> Ziel. Quellpfade sind relativ zum Baukastenordner.')
    print()
    print('== einfaches Kopieren nach %s/ ==' % ZIEL_GRAFIK)
    for ziel, quellen in sorted(KOPIEREN.items()):
        print('  %-28s <- %s' % (ziel, quellen[0]))
    print()
    print('== aus PSD flach gerendert ==')
    for ziel, quellen in sorted(PSD_FLACH.items()):
        print('  %-28s <- %s' % (ziel, quellen[0]))
    print()
    print('== aus den Doppelseiten geschnitten, je 50 zu 50 ==')
    for i, q in enumerate(DOPPELSEITEN):
        print('  %-28s <- %s' % ('seite-links-%d.png' % i, q[0]))
        print('  %-28s <- %s' % ('seite-rechts-%d.png' % i, q[0]))
    print()
    print('== aus %s einzeln gerendert ==' % KAPITELSTART_PSD[0])
    for ziel, ebene in sorted(KAPITELSTART_EBENEN.items()):
        print('  %-28s <- Ebene mit "%s" im Namen' % (ziel, ebene))
    print()
    print('== Schriften nach %s/ ==' % ZIEL_SCHRIFT)
    for s in SCHRIFTEN:
        print('  %-28s <- Document fonts/%s' % (s, s))


# ---------------------------------------------------------------- Hauptlauf

def main():
    if '--liste' in sys.argv:
        liste_ausgeben()
        return 0

    nur_png = '--png' in sys.argv
    argumente = [a for a in sys.argv[1:] if not a.startswith('--')]
    if not argumente:
        print(__doc__)
        return 2

    wurzel = argumente[0].rstrip('/\\')
    if not os.path.isdir(wurzel):
        print('Kein Ordner: %s' % wurzel)
        return 2

    # Ziel ist normalerweise dieses Projekt. Mit --ziel <pfad> schreibt es in
    # ein anderes, das diese Klasse benutzt.
    if '--ziel' in sys.argv:
        i = sys.argv.index('--ziel')
        if i + 1 >= len(sys.argv):
            print('--ziel braucht einen Pfad.')
            return 2
        projekt = os.path.abspath(sys.argv[i + 1].rstrip('/\\'))
        if not os.path.isdir(projekt):
            print('Kein Ordner: %s' % projekt)
            return 2
    else:
        projekt = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    print('Ziel               : %s' % projekt)
    zg = os.path.join(projekt, ZIEL_GRAFIK)
    zs = os.path.join(projekt, ZIEL_SCHRIFT)
    os.makedirs(zg, exist_ok=True)
    os.makedirs(zs, exist_ok=True)

    fehlt = []
    getan = 0

    # Pillow braucht es fuer die Seitenhintergruende, den Kapitelanfang und
    # die JPEG-Wandlung des Rueckumschlags — also schon beim Kopieren.
    try:
        from PIL import Image
        Image.MAX_IMAGE_PIXELS = None
    except ImportError:
        print()
        print('Pillow fehlt. Nachinstallieren mit:')
        print('    python3 -m pip install Pillow psd-tools')
        return 1

    # 1 -- einfaches Kopieren
    for ziel, quellen in sorted(KOPIEREN.items()):
        q = finde(wurzel, quellen)
        if q is None:
            fehlt.append('%s (gesucht: %s)' % (ziel, quellen[0]))
            continue
        # Kandidaten fuer JPEG gehen durch Pillow, alle anderen werden
        # unveraendert kopiert.
        if os.path.splitext(ziel)[0] in ALS_JPEG and not nur_png:
            speichern(Image.open(q), zg, ziel, nur_png)
        else:
            shutil.copyfile(q, os.path.join(zg, ziel))
        getan += 1
    print('kopiert            : %d von %d' % (getan, len(KOPIEREN)))

    # 2 -- Doppelseiten schneiden
    #
    # Eine Doppelseite ist 5032 x 3579 px = 426,0 x 303,0 mm bei 300 ppi:
    # zwei A4-Seiten von je 210 mm plus 3 mm Anschnitt an den beiden
    # Aussenkanten, und 297 mm plus je 3 mm oben und unten. Der Schnitt in
    # der Mitte ergibt zwei Seiten von 213,0 x 303,0 mm, jede mit Anschnitt
    # an drei Kanten und keinem am Bund. Genau so braucht sie die Klasse.
    geschnitten = 0
    for i, quellen in enumerate(DOPPELSEITEN):
        q = finde(wurzel, quellen)
        if q is None:
            fehlt.append('seite-links-%d.png und seite-rechts-%d.png '
                         '(gesucht: %s)' % (i, i, quellen[0]))
            continue
        bogen = Image.open(q)
        mitte = bogen.width // 2
        speichern(bogen.crop((0, 0, mitte, bogen.height)), zg,
                  'seite-links-%d.png' % i, nur_png)
        speichern(bogen.crop((mitte, 0, bogen.width, bogen.height)), zg,
                  'seite-rechts-%d.png' % i, nur_png)
        geschnitten += 1
    print('Doppelseiten       : %d von %d geschnitten' % (geschnitten, len(DOPPELSEITEN)))

    try:
        from psd_tools import PSDImage
    except ImportError:
        print()
        print('psd-tools fehlt. Ohne psd-tools bleiben die aus PSD gewonnenen')
        print('Grafiken aus. Nachinstallieren mit:')
        print('    python3 -m pip install psd-tools')
        if fehlt:
            print()
            print('Fehlt ausserdem:')
            for f in fehlt:
                print('  %s' % f)
        return 1

    # 3 -- PSD flach rendern
    flach = 0
    for ziel, quellen in sorted(PSD_FLACH.items()):
        q = finde(wurzel, quellen)
        if q is None:
            fehlt.append('%s (gesucht: %s)' % (ziel, quellen[0]))
            continue
        bild = PSDImage.open(q).composite()
        if bild is None:
            fehlt.append('%s (PSD liess sich nicht rendern)' % ziel)
            continue
        bild.save(os.path.join(zg, ziel))
        flach += 1
    print('aus PSD flach      : %d von %d' % (flach, len(PSD_FLACH)))

    # 4 -- Kapitelanfang aus der geschichteten PSD
    #
    # Der Verlag baut den Kapitelanfang so: eine Pergamentflaeche, darauf das
    # Bild leicht eingerueckt, sodass der Pergamentrand als Rahmen stehen
    # bleibt, und darueber unten mittig das Drachenornament. Keine Maske.
    # Nachgesehen in der PSD: die Gruppe "Vertikaler_Halbseiter" enthaelt
    # "Pergament fuer Bild" und einen weissen Platzhalter, dazu kommt
    # "Ebene 10" mit dem Ornament.
    q = finde(wurzel, KAPITELSTART_PSD)
    kapitel = 0
    if q is None:
        fehlt.append('Kapitelanfang (gesucht: %s)' % KAPITELSTART_PSD[0])
    else:
        psd = PSDImage.open(q)

        def alle(knoten):
            for lage in knoten:
                if lage.is_group():
                    yield from alle(lage)
                else:
                    yield lage

        lagen = list(alle(psd))
        for ziel, teil in sorted(KAPITELSTART_EBENEN.items()):
            treffer = [l for l in lagen if teil.lower() in l.name.lower()]
            if not treffer:
                fehlt.append('%s (keine Ebene mit "%s" in %s)'
                             % (ziel, teil, os.path.basename(q)))
                continue
            # Auf die volle Leinwand rendern, damit die Teile deckungsgleich
            # bleiben und die Klasse sie uebereinander legen kann.
            leinwand = Image.new('RGBA', (psd.width, psd.height), (0, 0, 0, 0))
            bild = treffer[0].composite()
            if bild is not None:
                b = treffer[0].bbox
                leinwand.alpha_composite(bild.convert('RGBA'), (b[0], b[1]))
            leinwand.save(os.path.join(zg, ziel))
            kapitel += 1
    print('Kapitelanfang      : %d von %d' % (kapitel, len(KAPITELSTART_EBENEN)))

    # 5 -- Schriften
    sch = 0
    for name in SCHRIFTEN:
        q = finde(wurzel, ['Document fonts/%s' % name])
        if q is None:
            fehlt.append('schriften/%s (gesucht: Document fonts/%s)' % (name, name))
            continue
        shutil.copyfile(q, os.path.join(zs, name))
        sch += 1
    print('Schriften          : %d von %d' % (sch, len(SCHRIFTEN)))

    print()
    if fehlt:
        print('FEHLT (%d):' % len(fehlt))
        for f in fehlt:
            print('  %s' % f)
        print()
        print('Andere Fassung des Baukastens? Mit --liste die erwarteten')
        print('Quellpfade ausgeben und von Hand nachsehen.')
        return 1

    print('Vollstaendig. Weiter mit:')
    print('    python3 werkzeuge/pruefen.py')
    return 0


if __name__ == '__main__':
    sys.exit(main())
