#!/usr/bin/env python3
"""Bereitet die Kartengrafik fuer dsa5spielkarten aus dem offiziellen
Scriptorium-Spielkarten-Baukasten auf.

    python3 werkzeuge/kartengrafik.py "/pfad/zu/Scriptorium Aventuris -Spielkarten"
    python3 werkzeuge/kartengrafik.py "/pfad/zum/Paket" --ziel /pfad/zum/projekt
    python3 werkzeuge/kartengrafik.py "/pfad/zum/Paket" --farbe blau --farbe rot
    python3 werkzeuge/kartengrafik.py "/pfad/zum/Paket" --farbe nachtgruen:140:0.45
    python3 werkzeuge/kartengrafik.py --farben

Das Paket ist der „Scriptorium Aventuris – Spielkarten"-Baukasten von Ulisses
Spiele. Gebraucht wird daraus genau eine Datei:

    Links/Spielkarte_Ulisses_Design.tif    815 x 1110 px, 300 ppi

BEIDE PAKETE WERDEN GEBRAUCHT. Der allgemeine „Scriptorium Aventuris
v4"-Baukasten ist fuer Spielkarten nicht etwa entbehrlich, weil das
Kartenpaket eigene Schriften mitbringt: es bringt in „Document fonts" nur
GenBasR und andlso mit. Der Fett- und der Kursivschnitt von Gentium Basic
fehlen dort, und die braucht jedes Stichwort einer Karte. Dazu kommen die
Rautenkacheln des generischen Kartenrueckens. Beides holt
werkzeuge/aufbereiten.py aus dem allgemeinen Baukasten; dieses Werkzeug
prueft am Ende nach, ob es da ist.

Das sind 69,003 x 93,980 mm: die Karte 63 x 88 mm mit 3,0 mm Anschnitt an
den Seiten und 2,99 mm oben und unten. Die IDML des Baukastens setzt das
Bild mit ActualPpi = EffectivePpi = 300, also unskaliert — damit ist es
nach Regel 2 und 3 aus doku/MASSE.md eine belastbare Massquelle und nicht
geschaetzt. Daraus wird

    grafiken/spielkarte-flaeche.png

Die Schriften des Kartenpakets (andlso.ttf, GenBasR.ttf) sind dieselben wie
im allgemeinen Baukasten; sie holt werkzeuge/aufbereiten.py. Dieses Werkzeug
fasst schriften/ nicht an.

Das Bildmaterial ist NICHT Teil dieses Projekts und darf es nicht sein: es
gehoert Ulisses Spiele und steht unter der Vereinbarung ueber
Gemeinschaftsinhalte fuer SCRIPTORIUM AVENTURIS, die mit Apache 2.0 nicht
vereinbar ist. Dieses Werkzeug holt es aus dem Paket, das jeder selbst
herunterlaedt.

--- Farbvarianten ---

Das Schuppenband des Baukastens ist neutral graugrau-violett. Die beiden
veroeffentlichten Kartensets zeigen dasselbe Band in Farbe: „Aventurische
Meisterpersonen" (2017) blau, „Flusslande" (2018) rotbraun. Am Satz
nachgemessen ist das eine reine Umfaerbung — Pergament, Messingecken und
der schwarze Aussenrand sind in beiden Sets Bild fuer Bild dieselben.

Genau das macht --farbe: die dunklen, fast unbunten Bildpunkte des Bandes
bekommen einen Farbton, ihre Helligkeit bleibt. Ausgenommen bleiben

  * das Pergament          -- hell (V ueber 0,62)
  * die Messingecken       -- bunt (S ueber 0,45)
  * der schwarze Rand      -- die Helligkeit bleibt, schwarz bleibt schwarz

Ergebnis ist grafiken/spielkarte-flaeche-<name>.png. Dazu wird aus
raute-grau.png die passende grafiken/spielkarte-raute-<name>.png erzeugt --
die Raute des generischen Kartenrueckens im selben Farbton, damit Rand und
Ruecken zusammenpassen. Beides holt die Klasse mit einem Befehl:

    \\dsaKartenfarbe{<name>}

Dazu entsteht immer grafiken/spielkarte-ruecken.png: dieselbe Karte ohne
Schuppenband, fuer einen ruhigen Kartenruecken. Das Band laesst sich nicht
abschalten -- es steckt mit allem anderen in einer flachen Datei --, aber es
laesst sich durch Pergament aus der Kartenmitte ersetzen. Die Klasse nimmt
das mit \\dsaKartenrueckflaeche{spielkarte-ruecken}.

Der Spielkarten-Baukasten, kostenlos bei Ulisses:
https://www.ulisses-ebooks.de/de/product/197880/scriptorium-aventuris-layout-baukasten

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import sys

ZIEL_GRAFIK = 'grafiken'

# Die eine Datei, die gebraucht wird. Mehrere Kandidaten, weil das Paket je
# nach Herkunft mit oder ohne Zwischenordner ausgepackt wird.
QUELLEN = [
    'Links/Spielkarte_Ulisses_Design.tif',
    'Scriptorium Aventuris -Spielkarten/Links/Spielkarte_Ulisses_Design.tif',
]

ZIELNAME = 'spielkarte-flaeche.png'

# Sollmass der Vorlage in Pixeln. Weicht die Datei davon ab, ist es eine
# andere Fassung des Pakets -- dann wird gewarnt, aber weitergearbeitet,
# denn die Klasse setzt die Grafik ohnehin in Millimetern.
SOLL_PIXEL = (815, 1110)

# Die beiden Farbtoene, die die veroeffentlichten Sets zeigen, am Schuppenband
# ihrer eigenen Kartengrafik gemessen (Farbton in Grad, Saettigung 0..1):
#
#   blau   Aventurische Meisterpersonen, 2017 -- Haeufung bei 195 bis 200 Grad
#   rot    Flusslande, 2018               -- Haeufung bei 5 bis 15 Grad
#
# Die uebrigen sind keine Messwerte, sondern Angebote in derselben Machart.
FARBEN = {
    'blau':      (200, 0.46),
    'rot':       (10, 0.55),
    'gruen':     (120, 0.45),
    'violett':   (280, 0.40),
    'bernstein': (40, 0.55),
    'tuerkis':   (175, 0.45),
}

# Die Schwellen der Auswahl, je ein Satz fuer die Kartenflaeche und fuer
# die Raute. Aufbau ist beidesmal derselbe: V_VOLL/V_NULL und S_VOLL/S_NULL
# spannen zwei weiche Rampen auf, damit an den Uebergaengen keine Kante
# entsteht, und nur was dunkel UND unbunt ist, bekommt den Farbton.
#
# Kartenflaeche, an der Vorlage gemessen:
#
#   Pergament         V 0,99   S 0,02
#   Schuppenband      V 0,20 bis 0,35   S 0,11 bis 0,14
#   Messingecke       V 0,15 bis 0,40   S 0,67
#   Aussenrand        V 0,00
SCHWELLEN_FLAECHE = (0.22, 0.62, 0.10, 0.45)

# Raute. Hier ist die Auswahl nicht geraten, sondern am Unterschied der drei
# amtlichen Fassungen abgelesen: raute-grau, raute-gruen und raute-rot sind
# dieselbe Zeichnung, und zwischen ihnen aendern sich genau 37 Prozent der
# deckenden Bildpunkte. Es sind die unbunten -- Saettigung im Mittel 0,11 bei
# einer Helligkeit von 0,42, also der Edelstein. Die uebrigen 63 Prozent
# haben eine Saettigung von 0,50: der Messingrahmen, und der bleibt.
#
# Der Farbton der geaenderten Punkte betraegt im Median 33 Grad bei grau,
# 167 bei gruen und 6 bei rot. Mit diesen Schwellen und Saettigung 0,35
# trifft die Umfaerbung von grau nach gruen auf 0,078 mittlere Abweichung,
# nach rot auf 0,086 -- naeher kommt man einer von Hand kolorierten Fassung
# nicht.
SCHWELLEN_RAUTE = (0.60, 0.95, 0.15, 0.30)
RAUTE_SAETTIGUNG = 0.35

# Die Rautenkachel kommt aus dem ALLGEMEINEN Baukasten, nicht aus dem
# Kartenpaket. werkzeuge/aufbereiten.py legt sie ab.
RAUTE_QUELLE = 'raute-grau.png'

# --- Die bandlose Rueckseitenflaeche ---------------------------------
#
# Schwarzer Rand, Schuppenband, Messingecken und Pergament stecken in EINER
# flachen Datei: das TIF ist RGB, eine Ebene, ohne Alphakanal, und das IDML
# legt genau dieses eine Bild auf die Karte. Trennen laesst sich das nicht.
#
# Ableiten schon. Fuer einen ruhigen Kartenruecken -- Raute auf Pergament,
# ohne das unruhige Band -- wird die Bandzone durch Pergament aus der
# Kartenmitte ersetzt. Der schwarze Rand bleibt dabei im Original stehen.
#
# Das ist der Unterschied zur ersten Fassung, und er war noetig: dort wurde
# auch der Rand neu gebaut, aus dem Helligkeitsprofil der linken Kante ueber
# die ganze Kartenhoehe. Das Ergebnis war ein weicher Grauverlauf statt
# einer Kante -- die Karte hatte auf dem Bogen keinen sichtbaren Rand mehr
# und stach zwischen den anderen als blasses Rechteck heraus.
#
# Die vier Zeilenmarken sind am Bild gemessen:
#
#   Zeile   46   Ende des schwarzen Rahmens oben. Entlang der Mittelspalte
#                ist die Helligkeit bis dahin unter 0,12.
#   Zeile  210   Ende des Bandes samt Messingecken. Der Pergamentanteil je
#                Zeile steigt zwar schon ab Zeile 120, die Ecken reichen
#                aber tiefer -- deshalb grosszuegig 210.
#   Zeile  930   Anfang des Bandes unten, entsprechend.
#   Zeile 1061   Anfang des schwarzen Rahmens unten.
#
# Ersetzt wird aus den Zeilen 330 und 560: reines Pergament. Ein erster
# Anlauf spiegelte die Zeilen unmittelbar neben dem Band und holte damit
# die Messingecken wieder herein.
#
# Die Seitenraender bleiben unangetastet: das Pergament wird zeilenweise
# uebernommen und bringt den seitlichen Rahmen mit.
#
# Eingefaerbt wird die Flaeche nicht: es ist nichts Buntes mehr darin. Die
# Farbe traegt die Raute.
RUECKEN_NAME = 'spielkarte-ruecken.png'
RAND_OBEN, RAND_UNTEN = 46, 1061
BAND_OBEN, BAND_UNTEN = 210, 930
PERGAMENT_OBEN, PERGAMENT_UNTEN = 330, 560
UEBER = 34               # Ueberblendung am schwarzen Rand, in Zeilen
NAHT = 40                # Ueberblendung am Bandrand, in Zeilen


def rueckenflaeche(bild):
    """Dieselbe Karte ohne Schuppenband, fuer den Ruecken."""
    import numpy as np
    from PIL import Image

    a = np.asarray(bild.convert('RGB'), dtype=np.float32) / 255.0
    h = a.shape[0]
    neu = a.copy()

    hoch = BAND_OBEN - RAND_OBEN
    neu[RAND_OBEN:BAND_OBEN] = a[PERGAMENT_OBEN:PERGAMENT_OBEN + hoch][::-1]
    tief = RAND_UNTEN - BAND_UNTEN
    neu[BAND_UNTEN:RAND_UNTEN] = a[PERGAMENT_UNTEN:PERGAMENT_UNTEN + tief][::-1]

    # Vom Rahmen auf das Pergament ueberblenden. Das Profil kommt aus der
    # Kartenmitte, wo derselbe Rahmen ohne Band liegt.
    profil = a[h // 2 - 60:h // 2 + 60,
               RAND_OBEN:RAND_OBEN + UEBER].mean(axis=(0, 2))
    profil = np.clip(profil / max(profil[-1], 1e-6), 0, 1)
    for i, f in enumerate(profil):
        neu[RAND_OBEN + i] *= f
        neu[RAND_UNTEN - 1 - i] *= f

    # Am Bandrand auf das Original ueberblenden, sonst steht dort eine Kante.
    for i in range(NAHT):
        t = i / NAHT
        neu[BAND_OBEN + i] = neu[BAND_OBEN + i] * (1 - t) + a[BAND_OBEN + i] * t
        neu[BAND_UNTEN - 1 - i] = (neu[BAND_UNTEN - 1 - i] * (1 - t)
                                   + a[BAND_UNTEN - 1 - i] * t)

    return Image.fromarray(
        (np.clip(neu, 0, 1) * 255.0 + 0.5).astype(np.uint8))


def finde(wurzel, kandidaten):
    """Erster vorhandener Kandidat unter wurzel, sonst None."""
    for k in kandidaten:
        p = os.path.join(wurzel, k.replace('/', os.sep))
        if os.path.exists(p):
            return p
    return None


def farbe_lesen(angabe):
    """'blau' oder 'name:farbton:saettigung' -> (name, grad, saettigung)."""
    teile = angabe.split(':')
    if len(teile) == 1:
        name = teile[0]
        if name not in FARBEN:
            raise ValueError(
                'Unbekannte Farbe "%s". Bekannt sind: %s. Eigene gehen mit '
                'name:farbton:saettigung, etwa moor:150:0.4'
                % (name, ', '.join(sorted(FARBEN))))
        return (name,) + FARBEN[name]
    if len(teile) == 3:
        return teile[0], float(teile[1]), float(teile[2])
    raise ValueError('Farbangabe "%s" verstehe ich nicht. Entweder ein Name '
                     'oder name:farbton:saettigung.' % angabe)


def einfaerben(bild, grad, saettigung, schwellen=SCHWELLEN_FLAECHE):
    """Faerbt das Schuppenband um und laesst alles andere, wie es ist.

    Arbeitet in HSV-Naehe, aber ohne echte HSV-Umrechnung: gebraucht werden
    nur V (der groesste Kanal) und S (die Spanne der Kanaele, auf V
    bezogen). Das genuegt fuer die Auswahl und ist auf dem ganzen Bild
    schnell.
    """
    import colorsys

    import numpy as np

    v_voll, v_null, s_voll, s_null = schwellen
    hat_alpha = bild.mode.endswith('A')
    voll = np.asarray(bild.convert('RGBA'), dtype=np.float32) / 255.0
    a, alpha = voll[:, :, :3], voll[:, :, 3]
    gross = a.max(axis=2)
    klein = a.min(axis=2)
    saet = np.where(gross > 0, (gross - klein) / np.maximum(gross, 1e-6), 0.0)

    # Zwei Rampen, multipliziert: dunkel UND unbunt.
    w_v = np.clip((v_null - gross) / (v_null - v_voll), 0.0, 1.0)
    w_s = np.clip((s_null - saet) / (s_null - s_voll), 0.0, 1.0)
    w = (w_v * w_s)[..., None]

    r, g, b = colorsys.hsv_to_rgb(grad / 360.0, saettigung, 1.0)
    # Die Zielfarbe traegt nur den Farbton; die Helligkeit kommt aus dem
    # Bild. Deshalb schwarz mal Farbe gleich schwarz -- der Aussenrand
    # bleibt, wie er ist, ohne ihn eigens ausnehmen zu muessen.
    ziel = np.stack([gross * r, gross * g, gross * b], axis=2)

    from PIL import Image
    neu = np.clip(a * (1.0 - w) + ziel * w, 0.0, 1.0)
    # Der Alphakanal bleibt unberuehrt. Die Kartenflaeche hat keinen, die
    # Raute schon -- und ohne ihn saesse sie als Rechteck auf dem Pergament.
    if hat_alpha:
        neu = np.dstack([neu, alpha])
    return Image.fromarray((neu * 255.0 + 0.5).astype(np.uint8))


def main():
    args = sys.argv[1:]
    if '--farben' in args:
        print('Vorgegebene Farben (Farbton in Grad, Saettigung):')
        for n in sorted(FARBEN):
            print('    %-10s %3d Grad, %.2f' % ((n,) + FARBEN[n]))
        print()
        print('blau und rot sind an den Kartengrafiken der beiden')
        print('veroeffentlichten Sets gemessen, die uebrigen sind Angebote.')
        print('Eigene gehen mit --farbe name:farbton:saettigung.')
        return 0

    wurzel = None
    ziel = '.'
    farben = []
    i = 0
    while i < len(args):
        if args[i] == '--ziel':
            i += 1
            ziel = args[i]
        elif args[i] == '--farbe':
            i += 1
            farben.append(args[i])
        elif args[i].startswith('-'):
            print('Unbekannte Option: %s' % args[i])
            print(__doc__.split('\n\n')[1])
            return 2
        else:
            wurzel = args[i]
        i += 1

    if wurzel is None:
        print(__doc__)
        return 2

    try:
        from PIL import Image
    except ImportError:
        print('Pillow fehlt. Installieren mit:  pip install pillow')
        return 1

    quelle = finde(wurzel, QUELLEN)
    if quelle is None:
        print('Nicht gefunden in %s:' % wurzel)
        for k in QUELLEN:
            print('    %s' % k)
        print()
        print('Das ist der Spielkarten-Baukasten, nicht der allgemeine')
        print('Layout-Baukasten -- der hat diese Datei nicht. Beide liegen')
        print('unter demselben Ulisses-Link, siehe doku/EINRICHTUNG.md.')
        return 1

    zg = os.path.join(ziel, ZIEL_GRAFIK)
    os.makedirs(zg, exist_ok=True)

    bild = Image.open(quelle).convert('RGB')
    if bild.size != SOLL_PIXEL:
        print('WARNUNG: %s ist %d x %d px, erwartet waren %d x %d.'
              % ((os.path.basename(quelle),) + bild.size + SOLL_PIXEL))
        print('         Andere Fassung des Pakets? Die Klasse setzt die')
        print('         Grafik in Millimetern, es passt also trotzdem --')
        print('         aber die Masse in doku/MASSE.md sind dann zu pruefen.')

    bild.save(os.path.join(zg, ZIELNAME))
    print('Kartenflaeche      : %s  (%d x %d px)'
          % (ZIELNAME, bild.width, bild.height))

    try:
        import numpy  # noqa: F401
    except ImportError:
        print('Hinweis: numpy fehlt, die bandlose Rueckseitenflaeche wird')
        print('         nicht erzeugt. Installieren mit: pip install numpy')
    else:
        rueck = rueckenflaeche(bild)
        rueck.save(os.path.join(zg, RUECKEN_NAME))
        print('Rueckseitenflaeche : %s  (ohne Schuppenband)' % RUECKEN_NAME)

    if farben:
        try:
            import numpy  # noqa: F401
        except ImportError:
            print('numpy fehlt, --farbe braucht es. Installieren mit:')
            print('    pip install numpy')
            return 1
        raute = os.path.join(zg, RAUTE_QUELLE)
        if not os.path.isfile(raute):
            print('Hinweis: %s fehlt, die Rauten des Kartenrueckens werden'
                  % RAUTE_QUELLE)
            print('         nicht mitgefaerbt. Sie kommt aus dem allgemeinen')
            print('         Baukasten, siehe werkzeuge/aufbereiten.py.')
            raute = None
        for angabe in farben:
            try:
                name, grad, saet = farbe_lesen(angabe)
            except ValueError as e:
                print('FEHLER: %s' % e)
                return 1
            eingefaerbt = einfaerben(bild, grad, saet)
            dateiname = 'spielkarte-flaeche-%s.png' % name
            eingefaerbt.save(os.path.join(zg, dateiname))
            print('Farbvariante       : %-32s (%3d Grad, %.2f)'
                  % (dateiname, grad, saet))
            if raute is None:
                continue
            # Die Raute bekommt denselben Farbton, aber ihre eigene
            # Saettigung: der Edelstein ist kraeftiger als das Schuppenband,
            # und mit der Saettigung der Flaeche wirkte er blass.
            r = einfaerben(Image.open(raute), grad, RAUTE_SAETTIGUNG,
                           SCHWELLEN_RAUTE)
            rname = 'spielkarte-raute-%s.png' % name
            r.save(os.path.join(zg, rname))
            print('  dazu die Raute   : %-32s (%3d Grad, %.2f)'
                  % (rname, grad, RAUTE_SAETTIGUNG))

    # Der allgemeine Baukasten wird trotzdem gebraucht, und zwar nicht
    # nebenbei: das Kartenpaket liefert in "Document fonts" nur GenBasR und
    # andlso. Der Fett- und der Kursivschnitt fehlen dort, und ohne sie
    # steht jedes Stichwort ("Charakterzuege:", "Waffenvorteil:") mager
    # statt fett -- ein Fehler, den XeLaTeX nur als Warnung meldet und den
    # man im Abzug leicht uebersieht. Die Rautenkacheln des generischen
    # Kartenrueckens kommen ebenfalls von dort.
    projekt = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    fehlt = [n for n in ('schriften/GenBasB.ttf', 'schriften/GenBasI.ttf',
                         'grafiken/raute-grau.png')
             if not os.path.isfile(os.path.join(projekt,
                                                n.replace('/', os.sep)))]
    if fehlt:
        print()
        print('FEHLT NOCH aus dem ALLGEMEINEN Layout-Baukasten:')
        for f in fehlt:
            print('    %s' % f)
        print()
        print('Das Kartenpaket bringt nur GenBasR und andlso mit. Fett und')
        print('kursiv braucht aber jedes Stichwort, und die Rautenkacheln')
        print('braucht der generische Kartenruecken. Nachholen mit:')
        print('    python3 werkzeuge/aufbereiten.py '
              '"/pfad/zu/Scriptorium Aventuris v4"')
        return 1

    print()
    print('Fertig. Weiter mit:')
    print('    cd beispiel')
    print('    TEXINPUTS="..;" xelatex spielkarten.tex')
    return 0


if __name__ == '__main__':
    sys.exit(main())
