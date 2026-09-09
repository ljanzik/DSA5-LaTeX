#!/usr/bin/env python3
"""Bereitet die Grafiken und Schriften fuer dsa5-latex aus dem offiziellen
Scriptorium-Baukasten auf.

    python3 werkzeuge/aufbereiten.py "/pfad/zu/Scriptorium Aventuris v4"
    python3 werkzeuge/aufbereiten.py "/pfad/zum/Baukasten" --ziel /pfad/zum/projekt
    python3 werkzeuge/aufbereiten.py --liste
    python3 werkzeuge/aufbereiten.py "/pfad/zum/Baukasten" --png
    python3 werkzeuge/aufbereiten.py "/pfad/zum/Baukasten" --ppi 200
    python3 werkzeuge/aufbereiten.py "/pfad/zum/Baukasten" \
        --rueckseiten "/pfad/zum/Rueckseiten_Karten_Paket"

Mit --ziel schreibt es grafiken/ und schriften/ in ein anderes Projekt,
das diese Klasse benutzt. Ohne --ziel in dieses hier.

Die vier Doppelseiten und der Rueckumschlag werden als JPEG abgelegt: als PNG
sind das 7 bis 13 MB je Datei und im gesetzten PDF ueber 50 MB, als JPEG in
Qualitaet 88 unter 1,5 MB, ohne sichtbaren Unterschied an einer
Pergamentflaeche. Mit --png bleibt alles verlustlos.

Alle uebrigen Grafiken haben echte Transparenz und bleiben PNG. Wer das PDF
kleiner braucht, verkleinert sie mit --ppi: die Klasse setzt jede Grafik in
ihrer Produktionsgroesse in Millimeter, die Aufloesung ist ihr gleich.
300 ppi ist Druckqualitaet, 200 ppi ergibt 44 Prozent der Pixel, und eine
gesetzte Veroeffentlichung, die wir vermessen haben, kommt mit 167 ppi aus.

Das Bildmaterial ist NICHT Teil dieses Projekts und darf es nicht sein: es
gehoert Ulisses Spiele und steht unter der Vereinbarung ueber
Gemeinschaftsinhalte fuer SCRIPTORIUM AVENTURIS, die mit Apache 2.0 nicht
vereinbar ist. Dieses Werkzeug holt es aus dem Paket, das jeder selbst
herunterlaedt, und benennt es auf Namen ohne Leerzeichen und Umlaute um,
weil LaTeX mit beidem schlecht umgeht.

Mit --rueckseiten kommt das zweite Paket dazu: eine fertige Rueckseite mit
Zierrahmen und 28 Masken, die je eine Region Aventuriens hervorheben. Eine
Maske ist die verdunkelte Karte mit einem Loch an der Stelle der Region.
Daraus baut das Werkzeug die Rueckseite so, wie die offiziellen Hefte sie
zeigen: die Karte in Sepia, die Region in Farbe, ein weicher Schlagschatten
darum. Ergebnis ist ruecken-<region>.

Andere Pakete braucht es nicht. Der Zierrahmen des Kapitelanfangs und die
drei Rautenkacheln kamen frueher ueber ein --zusatz aus einer fremden
Sammlung; beide stehen im Baukasten selbst und werden hier daraus erzeugt.

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
    # Vier Leisten, alle mit Mittelornament. Oben steht immer dieselbe; das
    # Motiv unten sagt, um welche Art Block es sich handelt.
    'trenner-oben.png':           ['PNG innen/Absatztrenner_oben Kopie.png',
                                   'PNG innen/Absatztrenner_oben.png'],
    'trenner-unten.png':          ['PNG innen/Absatztrenner_unten Kopie.png',
                                   'PNG innen/Absatztrenner_unten.png'],
    'trenner-maske.png':          ['PNG innen/Absatztrenner_unten_Maske Kopie.png',
                                   'PNG innen/Absatztrenner_unten_Maske.png'],
    'trenner-buch.png':           ['PNG innen/Text zum NachlesenV3.png'],
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

# Die Rautenskala. Eine Kachel ist eine Raute samt ihrem Anteil am
# Zwischenraum. An der fertigen Viererskala gemessen sitzt die Raute mit
# 204 x 236 px in einer Teilung von 215 x 259.
RAUTE_KACHEL = (215, 259)
RAUTEN = {
    'raute-rot.png':   'AufzaehlerDSA5_Rueckseite_rot.psd',
    'raute-gruen.png': 'AufzaehlerDSA5_Rueckseite_blau.psd',
    'raute-grau.png':  'AufzaehlerDSA5_Rueckseite_schwarz.psd',
}

# Der Zierrahmen entsteht aus denselben zwei Ebenen: das Pergamentblatt,
# innen ausgeschnitten, mit dem Drachenornament davor. Ausgeschnitten wird
# durch Erosion des Alphakanals -- was uebrig bleibt, ist ein Rand in der
# Breite der Erosion, und der behaelt die gerissene Aussenkante.
#
# 20 px sind an der Fassung gemessen, die frueher ueber --zusatz kam: bei
# dieser Breite unterscheiden sich die beiden Umrisse in 1,71 Prozent der
# Pixel, und die liegen samtlich auf der weichen Innenkante. 10 px ergeben
# 2,71 Prozent, 32 px ergeben 3,00.
KAPITELSTART_RAND = 20

# Diese Grafiken werden als JPEG abgelegt, nicht als PNG. Es sind die
# Vollseitengrafiken: 2516 x 3579 px in RGB, als PNG 7 bis 13 MB je Datei, als
# JPEG in Qualitaet 88 unter 1,5 MB. Einen Alphakanal haben sie nicht, und
# ihre Motive sind Pergamentflaechen mit weichen Verlaeufen — dafuer ist JPEG
# gemacht. Wer sie doch verlustlos will, ruft das Werkzeug mit --png auf.
#
# Der Coverrahmen ist NICHT dabei: er hat echte Transparenz.
ALS_JPEG = {
    'umschlag-hinten',
    'ruecken-neutral',
    'seite-links-0', 'seite-links-1', 'seite-links-2', 'seite-links-3',
    'seite-rechts-0', 'seite-rechts-1', 'seite-rechts-2', 'seite-rechts-3',
}
JPEG_QUALITAET = 88

SCHRIFTEN = ['andlso.ttf', 'GenBasR.ttf', 'GenBasB.ttf',
             'GenBasI.ttf', 'GenBasBI.ttf']

# Aus dem Rueckseiten-Paket. Der Dateiname wird zum Kuerzel: Umlaute
# ausgeschrieben, Grossbuchstaben klein, Wortgrenzen zu Bindestrichen.
RUECKEN_NEUTRAL = 'ScriptoriumAventuris-hinten.png'
RUECKEN_VERDUNKELT = 'KarteVerdunkelt.png'
RUECKEN_PRAEFIX = 'Aventurien_'

# ---- Die Sepiarampe der Rueckseite ----
#
# Die offiziellen Hefte zeigen die Karte nicht verdunkelt, sondern in Sepia,
# und nur die aktive Region in Farbe. Nachgemessen an zwei Ruecktiteln --
# „Ketten fuer die Ewigkeit" (US25324, Karte als eingebettetes Bild) und
# „Schrecken aus der Tiefe" (US25326) -- ist das kein Farbfilter, sondern
# eine Funktion allein der Helligkeit: die Streuung um die Gerade liegt bei
# fuenf von 255 Stufen.
#
#   Ketten     R = 1,023 L + 14,6   G = 0,999 L - 3,8   B = 0,948 L - 18,6
#   Schrecken  R = 0,994 L + 16,6   G = 1,002 L - 4,4   B = 1,006 L - 21,3
#
# Alle Steigungen sind eins. Es bleibt ein fester Farbversatz auf das Grau,
# und der ist helligkeitserhaltend: 0,299*15 + 0,587*(-4) + 0,114*(-20) =
# -0,14. Die Karte behaelt also ihre Zeichnung und wechselt nur den Farbort.
# Restfehler gegen beide Hefte: im Mittel 0,4 bis 3,7 Stufen, 95 Prozent
# unter 10.
SEPIA = (15, -4, -20)

# ---- Der Schlagschatten um die Region ----
#
# Am selben Ruecktitel gemessen, in Ringen um die farbige Region:
#
#    3 px  94,1      21 px  117,0
#    7 px 107,5      31 px  119,0
#   11 px 105,8      45 px  119,5
#   15 px 112,0      fern   115,0
#
# Also rund 25 Stufen Abdunklung unmittelbar am Rand, ausklingend ueber
# etwa 20 px bei 319 ppi. Nachgebildet als weichgezeichnete Silhouette der
# Region, multipliziert auf die Sepiaflaeche.
#
# Tiefe und Weichzeichnung sind an diesem Verlauf angepasst. Gemessen wird
# als Anteil der oertlichen Helligkeit, damit das Gelaende herausfaellt:
#
#            3 px   7 px  11 px  15 px  21 px   Summe der Fehler
#   Vorbild  0,210  0,092  0,109  0,059  0,017
#   0,55/ 9  0,165  0,080  0,034  0,014  0,000       0,193
#   0,55/12  0,185  0,113  0,062  0,032  0,011       0,126
#   0,55/15  0,196  0,135  0,087  0,053  0,024       0,093   <-
#   0,65/15  0,230  0,158  0,101  0,061  0,027       0,106
#   0,55/18  0,201  0,149  0,105  0,071  0,037       0,102
#
# Dass der Vorbildwert bei 7 px unter dem bei 11 px liegt, ist Rauschen aus
# dem Gelaende -- gemessen wird schliesslich auf der Karte, nicht auf einer
# leeren Flaeche.
SCHATTEN_TIEFE = 0.55     # Faktor auf die weichgezeichnete Silhouette
SCHATTEN_WEICH = 15       # Radius der Weichzeichnung in Pixeln bei 300 ppi


def kuerzel(name):
    """Aventurien_TieferSueden.png -> tiefer-sueden"""
    stamm = os.path.splitext(name)[0]
    if stamm.startswith(RUECKEN_PRAEFIX):
        stamm = stamm[len(RUECKEN_PRAEFIX):]
    ersatz = {'\u00e4': 'ae', '\u00f6': 'oe', '\u00fc': 'ue',
              '\u00c4': 'Ae', '\u00d6': 'Oe', '\u00dc': 'Ue',
              '\u00df': 'ss'}
    for a, b in ersatz.items():
        stamm = stamm.replace(a, b)
    # Wortgrenzen: vor jedem Grossbuchstaben, der auf einen Kleinbuchstaben
    # folgt, ein Bindestrich. Unterstriche werden ebenfalls Bindestriche.
    aus = []
    for i, z in enumerate(stamm):
        if z == '_':
            aus.append('-')
            continue
        if i > 0 and z.isupper() and stamm[i - 1].islower():
            aus.append('-')
        aus.append(z.lower())
    return ''.join(aus)


# ---------------------------------------------------------------- Helfer

def hat_alpha(bild):
    """Ist wirklich etwas durchsichtig, oder nur ein leerer Alphakanal?"""
    if bild.mode not in ('RGBA', 'LA', 'P'):
        return False
    a = bild.convert('RGBA').split()[3]
    return a.getextrema()[0] < 255


def verkleinern(bild, ppi):
    """Rechnet ein Bild von 300 ppi auf eine andere Aufloesung herunter.

    Die Klasse setzt jede Grafik in ihrer Produktionsgroesse in Millimeter,
    also Pixel geteilt durch 300. Weniger Pixel heisst deshalb nicht kleiner
    im Satz, sondern nur weniger Daten.
    """
    if ppi >= 300:
        return bild
    faktor = ppi / 300.0
    neu = (max(1, int(round(bild.width * faktor))),
           max(1, int(round(bild.height * faktor))))
    return bild.resize(neu, Image.LANCZOS)


def speichern(bild, ordner, name, nur_png=False, ppi=300):
    """Legt das Bild unter <name> ab, als JPEG wenn es dafuer vorgesehen ist.

    <name> kommt mit der Endung .png herein; steht der Name in ALS_JPEG und
    hat das Bild keine Transparenz, wird daraus .jpg. Die Klasse nennt ihre
    Grafiken ohne Endung, deshalb ist der Wechsel dort nicht zu merken.
    Zurueck kommt der wirklich geschriebene Dateiname.
    """
    stamm = os.path.splitext(name)[0]
    bild = verkleinern(bild, ppi)
    if not nur_png and (stamm in ALS_JPEG
                        or stamm.startswith('ruecken-')) and not hat_alpha(bild):
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
    print('  %-28s <- Pergamentebene, innen um %d px erodiert, mit Ornament'
          % ('kapitelstart-rahmen.png', KAPITELSTART_RAND))
    print('  %-28s <- aus kapitelstart-rahmen geflutet'
          % 'kapitelstart-fenster.png')
    print('  %-28s <- kapitelstart-pergament in der Form des Fensters'
          % 'kapitelstart-flaeche.png')
    print()
    print('== die Rautenskala, je eine Raute auf %d x %d px ==' % RAUTE_KACHEL)
    for ziel, datei in sorted(RAUTEN.items()):
        print('  %-28s <- Links/%s' % (ziel, datei))
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
    ppi = 300
    if '--ppi' in sys.argv:
        i = sys.argv.index('--ppi')
        if i + 1 >= len(sys.argv):
            print('--ppi braucht eine Zahl.')
            return 2
        ppi = int(sys.argv[i + 1])
        print('Aufloesung          : %d ppi statt 300' % ppi)
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
        from PIL import Image, ImageChops, ImageFilter
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
        if (os.path.splitext(ziel)[0] in ALS_JPEG and not nur_png) or ppi < 300:
            speichern(Image.open(q), zg, ziel, nur_png, ppi)
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
                  'seite-links-%d.png' % i, nur_png, ppi)
        speichern(bogen.crop((mitte, 0, bogen.width, bogen.height)), zg,
                  'seite-rechts-%d.png' % i, nur_png, ppi)
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
        speichern(bild, zg, ziel, nur_png, ppi)
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
        teile = {}
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
            teile[ziel] = leinwand
            speichern(leinwand, zg, ziel, nur_png, ppi)
            kapitel += 1

        # Der Zierrahmen: dasselbe Pergamentblatt, innen ausgeschnitten,
        # mit dem Ornament davor. Frueher kam er als fertige Datei ueber
        # --zusatz aus einem fremden Paket; er steckt aber in derselben
        # PSD wie seine beiden Teile.
        perg = teile.get('kapitelstart-pergament.png')
        orn = teile.get('kapitelstart-ornament.png')
        if perg is None:
            fehlt.append('kapitelstart-rahmen (braucht kapitelstart-pergament)')
        else:
            voll = perg.split()[3]
            innen = voll
            # Erosion in Schritten von einem Pixel. MinFilter(2r+1) auf einen
            # Schlag waere r^2 Vergleiche je Pixel; r-mal MinFilter(3) sind
            # neun, und das Ergebnis ist dasselbe Quadrat.
            for _ in range(KAPITELSTART_RAND):
                innen = innen.filter(ImageFilter.MinFilter(3))
            rand = ImageChops.subtract(voll, innen)
            rahmen = perg.copy()
            rahmen.putalpha(rand)
            if orn is not None:
                rahmen = Image.alpha_composite(rahmen, orn)
            speichern(rahmen, zg, 'kapitelstart-rahmen.png', nur_png, ppi)
            kapitel += 1
    print('Kapitelanfang      : %d von %d' % (kapitel, len(KAPITELSTART_EBENEN) + 1))

    # 5 -- Schriften
    # 5 -- Rueckseiten aus dem zweiten Paket
    if '--rueckseiten' in sys.argv:
        i = sys.argv.index('--rueckseiten')
        if i + 1 >= len(sys.argv):
            print('--rueckseiten braucht einen Pfad.')
            return 2
        paket = sys.argv[i + 1].rstrip('/\\')
        if not os.path.isdir(paket):
            print('Kein Ordner: %s' % paket)
            return 2
        rueck = 0
        quelle = os.path.join(paket, RUECKEN_NEUTRAL)
        if os.path.exists(quelle):
            speichern(Image.open(quelle), zg, 'ruecken-neutral.png',
                      nur_png, ppi)
            rueck += 1
        else:
            fehlt.append('ruecken-neutral (gesucht: %s)' % RUECKEN_NEUTRAL)
        # ---- Sepia statt Verdunkelung ----
        #
        # Das Paket bietet die Regionalfassungen als Masken an: die um die
        # Haelfte verdunkelte Karte mit einem Loch an der Stelle der Region,
        # zum Auflegen auf die helle Rueckseite. So stand es hier bis zur
        # Messung an zwei offiziellen Ruecktiteln -- und die machen es
        # anders: die Karte steht in Sepia, nur die aktive Region in Farbe,
        # und um sie liegt ein weicher Schlagschatten. Das hebt die Region
        # ungleich deutlicher heraus; in einem ohnehin dunkelgruenen
        # Waldgebiet war die halbierte Fassung kaum zu erkennen.
        #
        # Gebraucht werden dafuer drei Dinge, alle im Paket:
        #
        #   die Karte in Farbe   ScriptoriumAventuris-hinten.png
        #   die Kartenflaeche    | hell - KarteVerdunkelt | > 8
        #   die Region           der Alphakanal der Maske, wo er 0 ist
        #
        # Der zweite Punkt ist der Kniff. KarteVerdunkelt.png halbiert genau
        # die Karte und laesst den Zierrahmen unberuehrt -- gemessen liegt
        # das Verhaeltnis bei 0,507, und die Differenz zur hellen Fassung
        # deckt 13,2 Prozent der Seite. Das ist die Kartenflaeche, punktgenau
        # und ohne Freistellen von Hand.
        unterlage = None
        karte = None
        if os.path.exists(quelle):
            unterlage = Image.open(quelle).convert('RGB')
            qv = os.path.join(paket, RUECKEN_VERDUNKELT)
            if os.path.exists(qv):
                dunkel = Image.open(qv).convert('RGB')
                if dunkel.size == unterlage.size:
                    karte = ImageChops.difference(unterlage, dunkel) \
                        .convert('L').point(lambda v: 255 if v > 3 else 0)
            if karte is None:
                fehlt.append('Kartenflaeche (gesucht: %s) -- ohne sie bleiben '
                             'die Rueckseiten ohne Sepia' % RUECKEN_VERDUNKELT)

        sepia = None
        if unterlage is not None and karte is not None:
            grau = unterlage.convert('L')
            sepia = Image.merge('RGB', [grau.point(
                lambda v, s=s: max(0, min(255, v + s))) for s in SEPIA])

        for name in sorted(os.listdir(paket)):
            if not name.startswith(RUECKEN_PRAEFIX) or not name.endswith('.png'):
                continue
            maske = Image.open(os.path.join(paket, name)).convert('RGBA')
            if sepia is None or unterlage.size != maske.size:
                # Ohne die beiden Grundlagen bleibt die Maske, was sie ist.
                speichern(maske, zg, 'ruecken-%s.png' % kuerzel(name),
                          nur_png, ppi)
                rueck += 1
                continue
            # Das Loch der Maske ist die Region.
            region = maske.split()[3].point(lambda v: 255 if v < 8 else 0)
            # Der Schatten: die weichgezeichnete Silhouette der Region,
            # multipliziert auf die Sepiaflaeche. Weichgezeichnet wird die
            # Region selbst, nicht ihr Rand -- innerhalb liegt sie ohnehin
            # unter der Farbfassung und faellt dort nicht auf.
            weich = region.filter(ImageFilter.GaussianBlur(SCHATTEN_WEICH))
            dunkler = Image.eval(weich, lambda v: 255 - int(v * SCHATTEN_TIEFE))
            beschattet = ImageChops.multiply(
                sepia, Image.merge('RGB', (dunkler, dunkler, dunkler)))
            # Zusammensetzen: Sepia mit Schatten ueberall auf der Karte,
            # die Farbfassung in der Region.
            fertig = Image.composite(beschattet, unterlage, karte)
            fertig = Image.composite(unterlage, fertig, region)
            speichern(fertig, zg, 'ruecken-%s.png' % kuerzel(name),
                      nur_png, ppi)
            rueck += 1
        print('Rueckseiten        : %d aus dem Kartenpaket%s'
              % (rueck, '' if sepia is not None else ' (ohne Sepia)'))

    # 6 -- die Rautenskala als Kachel
    #
    # Die drei Kacheln kamen frueher aus einem fremden Paket, ueber
    # --zusatz. Sie stehen aber im Baukasten, und zwar als Masterdateien:
    # AufzaehlerDSA5_Rueckseite_rot, _blau und _schwarz sind genau die
    # rote, die tuerkise und die graue Raute, alle drei 204 x 236 px
    # deckend -- Pixel fuer Pixel dieselbe Zeichnung wie in den fertigen
    # Viererskalen, nur ohne deren Leinwandrand.
    #
    # Was der Baukasten „blau" nennt, heisst in der Skala „gruen"; der
    # Stein ist tuerkis. Hier gilt der Name, unter dem die Klasse ihn
    # aufruft.
    #
    # Eine Kachel ist eine Raute samt ihrem Anteil am Zwischenraum. An der
    # Viererskala gemessen sitzt die Raute mit 204 x 236 px in einer
    # Teilung von 215 x 259 -- also 11 px Luft waagerecht und 23 px
    # senkrecht. Die Kachel wird deshalb auf dieses Mass zentriert.
    kach = 0
    for ziel, datei in sorted(RAUTEN.items()):
        q = finde(wurzel, ['Links/%s' % datei])
        if q is None:
            fehlt.append('%s (gesucht: Links/%s)' % (ziel, datei))
            continue
        bild = PSDImage.open(q).composite().convert('RGBA')
        kasten = bild.getchannel('A').point(
            lambda v: 255 if v > 16 else 0).getbbox()
        raute = bild.crop(kasten)
        kachel = Image.new('RGBA', RAUTE_KACHEL, (0, 0, 0, 0))
        kachel.alpha_composite(raute,
                               ((RAUTE_KACHEL[0] - raute.width) // 2,
                                (RAUTE_KACHEL[1] - raute.height) // 2))
        speichern(kachel, zg, ziel, nur_png, ppi)
        kach += 1
    print('Rautenkacheln      : %d von %d' % (kach, len(RAUTEN)))

    # Die Oeffnung des Kapitelrahmens als Maske, und ein Platzhalter
    # darin.
    #
    # Die Kanten des Rahmens sind gezeichnet: die untere schwankt ueber
    # 8 mm, und unten sitzt das Drachenornament mitten in der Flaeche.
    # Ein Rechteck muss deshalb entweder darunter enden -- dann bleibt
    # Platz leer -- oder darunter hervorschauen.
    #
    # Also die Oeffnung selbst: von der Fenstermitte aus wird im
    # transparenten Bereich geflutet, begrenzt durch die Deckung des
    # Rahmens. Das sind 69,5 Prozent der Datei, von 6,01 bis 93,73 mm
    # waagerecht und 0,00 bis 267,97 mm senkrecht -- die Form folgt der
    # gerissenen Kante und umschliesst das Ornament.
    quelle_ra = os.path.join(zg, 'kapitelstart-rahmen.png')
    quelle_pg = os.path.join(zg, 'kapitelstart-pergament.png')
    if os.path.exists(quelle_ra):
        from PIL import ImageDraw
        rahmen = Image.open(quelle_ra).convert('RGBA')
        je_mm = rahmen.width / 109.22
        karte = rahmen.getchannel('A').point(
            lambda v: 0 if v > 40 else 255).convert('L')
        saat = (int(50 * je_mm), int(120 * je_mm))
        if karte.getpixel(saat) != 255:
            fehlt.append('kapitelstart-fenster (Saatpunkt liegt im Rahmen)')
        else:
            ImageDraw.floodfill(karte, saat, 128, thresh=0)
            oeffnung = karte.point(lambda v: 255 if v == 128 else 0)
            # Die Oeffnung muss unter den Rahmen reichen, sonst
            # bleibt eine helle Linie: die Kanten der Grafik sind
            # weichgezeichnet, und die Flutfuellung stoppt bei einer
            # Deckung von 40 von 255 -- dort deckt der Rahmen noch
            # kaum, und der Seitenhintergrund scheint durch. Gemessen
            # waren das 0,28 bis 0,71 mm heller Streifen.
            #
            # Die Schwelle hochzusetzen hilft nicht: ab 128 entweicht
            # die Fuellung nach draussen, der Rahmen ist nicht
            # ueberall dicht.
            #
            # Also eine zweite Flutfuellung, von der Ecke aus: die
            # gibt das Aussen. Was weder Oeffnung noch Aussen ist, ist
            # der Rahmenkoerper. Die Oeffnung wird um 1,5 mm
            # ausgedehnt und darauf beschnitten -- sie kriecht unter
            # den Rahmen und bleibt innerhalb seiner Silhouette.
            from PIL import ImageChops, ImageFilter
            rand = karte.copy()
            ImageDraw.floodfill(rand, (0, 0), 64, thresh=0)
            innen = ImageChops.invert(
                rand.point(lambda v: 255 if v == 64 else 0))
            weite = max(3, int(round(1.5 * je_mm)))
            oeffnung = ImageChops.lighter(
                oeffnung,
                ImageChops.multiply(
                    oeffnung.filter(ImageFilter.MaxFilter(2 * weite + 1)),
                    innen))
            # Die Maske: weisse Flaeche mit der Oeffnung als Alphakanal.
            maske = Image.new('RGBA', rahmen.size, (255, 255, 255, 0))
            maske.putalpha(oeffnung)
            speichern(maske, zg, 'kapitelstart-fenster.png', nur_png, ppi)
            # Der Platzhalter: Pergamenttextur in dieser Form.
            if os.path.exists(quelle_pg):
                blatt = Image.open(quelle_pg).convert('RGBA')
                # Die Textur ohne ihre eigenen gerissenen Kanten: der
                # Bereich innerhalb aller Kanten, dann deckend auf die
                # Rahmengroesse gebracht.
                innen = blatt.crop((int(5 * je_mm), int(8 * je_mm),
                                    int(94 * je_mm), int(261 * je_mm)))
                faktor = max(rahmen.width / innen.width,
                             rahmen.height / innen.height)
                innen = innen.resize(
                    (max(1, int(round(innen.width * faktor))),
                     max(1, int(round(innen.height * faktor)))),
                    Image.LANCZOS)
                links = (innen.width - rahmen.width) // 2
                oben = (innen.height - rahmen.height) // 2
                innen = innen.crop((links, oben,
                                    links + rahmen.width,
                                    oben + rahmen.height))
                innen.putalpha(oeffnung)
                speichern(innen, zg, 'kapitelstart-flaeche.png',
                          nur_png, ppi)
                print('Kapitelfenster     : Maske und Platzhalter')
            else:
                fehlt.append('kapitelstart-flaeche (braucht '
                             'kapitelstart-pergament)')
    else:
        fehlt.append('kapitelstart-fenster (braucht kapitelstart-rahmen)')

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
