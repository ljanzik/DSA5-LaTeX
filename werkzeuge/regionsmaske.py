#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Baut aus dem Rueckseiten-Paket eine Rueckseite mit eigener Region.

Das Paket bringt 28 fertige Masken mit — je eine Region Aventuriens. Wer
eine andere Aufteilung braucht, etwa zwei Nachbarregionen zusammen, kann
sie selbst schneiden: die Arbeitsdatei
`Karte_mit_Grenzen_Paket.pdn` enthaelt zwei Ebenen, die verdunkelte Karte
und ein Netz aus Regionsgrenzen. Dieselben Ebenen liegen als
`KarteVerdunkelt.png` und `Grenzen.png` daneben.

Das Verfahren: von einem Saatpunkt aus wird innerhalb der Grenzlinien
geflutet. Die gefundene Flaeche ist die Region. Gesetzt wird daraus
dieselbe Fassung, die aufbereiten.py --rueckseiten fuer die 28 fertigen
Masken rechnet: die Karte in Sepia, allein die Region in Farbe, ein
weicher Schlagschatten darum. Mehrere Saatpunkte ergeben mehrere
Regionen in einer Fassung.

    python3 werkzeuge/regionsmaske.py "/pfad/zum/Paket" mittelreich 148.4,105.0
    python3 werkzeuge/regionsmaske.py "/pfad/zum/Paket" zwei-regionen \\
        148.4,105.0 130,150

Die zweite Betriebsart nimmt die Flaeche aus einer vorliegenden Fassung,
statt sie zu fluten:

    python3 werkzeuge/regionsmaske.py "/pfad/zum/Paket" kosch \\
        --aus-fassung "/pfad/eigene-fassung.png" \\
                      "/pfad/derselbe-grund-ohne-region.png"

Das ist der Weg fuer Karten, die schon eine Region hervorheben, aber auf
dem falschen Grund sitzen: aus dem Unterschied der beiden Bilder nimmt das
Werkzeug die Flaeche und setzt sie auf den Grund des Kartenpakets. Die
zweite Datei ist dieselbe Karte ohne die Hervorhebung.

So kommt man auch an Regionen, die das Grenznetz nicht kennt -- den Kosch
zum Beispiel. Wie hell die Vorlage die Region zeichnet, ist dabei gleich;
gebraucht wird nur ihre Form. An einer solchen Fassung gemessen lag die
Region bei einer mittleren Helligkeit von 76,1 gegen 75,1 der verdunkelten
Karte -- also kaum aufgehellt -- und war als Flaeche trotzdem brauchbar.

Die Koordinaten sind Millimeter auf der A4-Seite, von der linken oberen
Ecke. Wer sie nicht kennt: die Karte liegt zwischen 104 und 207 mm
waagerecht und 30 und 187 mm senkrecht.

WIE FEIN DAS NETZ IST. Die Grenzebene kennt die grossen Regionen, nicht die
Provinzen darin. Eine Saat im Kosch flutet das ganze Mittelreich, von 128
bis 193 mm waagerecht und 80 bis 124 mm senkrecht -- und zwar unabhaengig
davon, ab welcher Deckung man eine Linie als Linie zaehlt. Wer eine Provinz
braucht, findet sie also nicht in diesem Netz. Ausgezaehlt hat das Netz 30
geschlossene Flaechen ueber 200 Pixel -- die 28 Regionen und zwei
Binnengewaesser. Wer den Kosch braucht, schneidet ihn von Hand und gibt ihn
ueber --aus-fassung mit.

Heraus kommt `grafiken/ruecken-<name>.jpg`, zu benutzen als

    \\dsaRueckseite{ruecken-<name>}{...}

Das Bildmaterial ist NICHT Teil dieses Projekts. Es gehoert Ulisses Spiele
und steht unter der Vereinbarung ueber Gemeinschaftsinhalte fuer
SCRIPTORIUM AVENTURIS.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import sys

try:
    from PIL import Image, ImageChops, ImageDraw, ImageFilter
    Image.MAX_IMAGE_PIXELS = None
except ImportError:
    sys.exit("Pillow fehlt: pip install pillow")

# Die Sepiarampe und der Schlagschatten stehen in aufbereiten.py, samt
# Herleitung. Hier nur benutzt, nicht noch einmal aufgeschrieben: zwei
# Kopien derselben Zahl laufen frueher oder spaeter auseinander.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from aufbereiten import (JPEG_QUALITAET, SCHATTEN_TIEFE,  # noqa: E402
                         SCHATTEN_WEICH, SEPIA)

PPI = 300.0
MMPX = 25.4 / PPI

NEUTRAL = "ScriptoriumAventuris-hinten.png"
VERDUNKELT = "KarteVerdunkelt.png"
GRENZEN = "Grenzen.png"

# Ab dieser Deckung gilt ein Pixel der Grenzebene als Linie und haelt die
# Flutfuellung auf.
GRENZSCHWELLE = 40
# Ab diesem Unterschied gilt ein Pixel als hervorgehoben, wenn die Flaeche
# aus zwei Fassungen kommt.
FASSUNGSSCHWELLE = 12
# Ab diesem Unterschied zwischen heller und verdunkelter Fassung gilt ein
# Pixel als Teil der Karte. Derselbe Wert wie in aufbereiten.py.
KARTENSCHWELLE = 3


def finde(ordner, name):
    pfad = os.path.join(ordner, name)
    if not os.path.exists(pfad):
        sys.exit("fehlt im Paket: %s" % name)
    return pfad


def flaeche_fluten(grenzen, saaten):
    """Gibt die Maske der geschlossenen Flaeche um die Saatpunkte.

    Die Grenzebene wird zu Schwarzweiss: Linien schwarz, alles andere weiss.
    Die Flutfuellung faerbt von jedem Saatpunkt aus grau, und was grau
    geworden ist, ist die Flaeche.
    """
    a = grenzen.getchannel("A")
    karte = a.point(lambda v: 0 if v > GRENZSCHWELLE else 255).convert("L")
    grau = 128
    for x, y in saaten:
        if karte.getpixel((x, y)) != 255:
            sys.exit("Saatpunkt %.1f, %.1f mm liegt auf einer Grenzlinie"
                     % (x * MMPX, y * MMPX))
        ImageDraw.floodfill(karte, (x, y), grau, thresh=0)
    return karte.point(lambda v: 255 if v == grau else 0)


def flaeche_aus_fassungen(hervorgehoben, grund):
    """Gibt die Flaeche, in der sich die beiden Fassungen unterscheiden.

    Fuer Karten, die eine Region schon hervorheben, aber auf dem falschen
    Grund sitzen: die Geometrie ist brauchbar, die Farben nicht.
    """
    a = hervorgehoben.convert("RGB")
    b = grund.convert("RGB")
    if a.size != b.size:
        sys.exit("Die beiden Fassungen haben verschiedene Groessen: %s %s"
                 % (a.size, b.size))
    d = ImageChops.difference(a, b).convert("L")
    return d.point(lambda v: 255 if v > FASSUNGSSCHWELLE else 0)


def main():
    argumente = [a for a in sys.argv[1:] if not a.startswith("--")]
    aus_fassung = None
    if "--aus-fassung" in sys.argv:
        i = sys.argv.index("--aus-fassung")
        if i + 2 >= len(sys.argv):
            sys.exit("--aus-fassung braucht zwei Dateien: hervorgehoben, Grund")
        aus_fassung = (sys.argv[i + 1], sys.argv[i + 2])
        argumente = [a for a in argumente if a not in aus_fassung]

    if len(argumente) < 2 or (aus_fassung is None and len(argumente) < 3):
        print(__doc__)
        return 2

    paket = argumente[0].rstrip("/\\")
    name = argumente[1]
    saaten = []
    for wert in argumente[2:]:
        try:
            x, y = (float(z) for z in wert.split(","))
        except ValueError:
            sys.exit("Koordinate erwartet als x,y in mm: %s" % wert)
        saaten.append((int(x / MMPX), int(y / MMPX)))

    if not os.path.isdir(paket):
        sys.exit("Kein Ordner: %s" % paket)

    neutral = Image.open(finde(paket, NEUTRAL)).convert("RGBA")
    verdunkelt = Image.open(finde(paket, VERDUNKELT)).convert("RGBA")
    grenzen = Image.open(finde(paket, GRENZEN)).convert("RGBA")

    if not (neutral.size == verdunkelt.size == grenzen.size):
        sys.exit("Die drei Ebenen haben verschiedene Groessen: %s %s %s"
                 % (neutral.size, verdunkelt.size, grenzen.size))

    if aus_fassung is not None:
        for pfad in aus_fassung:
            if not os.path.exists(pfad):
                sys.exit("Datei fehlt: %s" % pfad)
        flaeche = flaeche_aus_fassungen(Image.open(aus_fassung[0]),
                                        Image.open(aus_fassung[1]))
    else:
        flaeche = flaeche_fluten(grenzen, saaten)
    anteil = 100.0 * sum(flaeche.histogram()[255:]) / (flaeche.width * flaeche.height)
    print("Geflutete Flaeche: %.2f Prozent der Seite" % anteil)
    if anteil > 25:
        print("Das ist viel — sind die Grenzen dort offen? Ergebnis pruefen.")

    # Daraus die Rueckseite, Schritt fuer Schritt wie in aufbereiten.py:
    #
    #   die Kartenflaeche   | hell - verdunkelt | > KARTENSCHWELLE
    #   die Sepiafassung    Grau plus fester Farbversatz
    #   der Schlagschatten  die weichgezeichnete Region, multipliziert
    #   zusammengesetzt     Sepia auf der Karte, Farbe in der Region
    #
    # Der Kniff ist die erste Zeile: KarteVerdunkelt.png halbiert genau
    # die Karte und laesst den Zierrahmen unberuehrt. Die Differenz zur
    # hellen Fassung ist damit die Kartenflaeche, punktgenau und ohne
    # Freistellen von Hand.
    unterlage = neutral.convert("RGB")
    karte = ImageChops.difference(unterlage, verdunkelt.convert("RGB")) \
        .convert("L").point(lambda v: 255 if v > KARTENSCHWELLE else 0)
    grau = unterlage.convert("L")
    sepia = Image.merge("RGB", [grau.point(
        lambda v, s=s: max(0, min(255, v + s))) for s in SEPIA])
    # Weichgezeichnet wird die Region selbst, nicht ihr Rand -- innerhalb
    # liegt sie ohnehin unter der Farbfassung und faellt dort nicht auf.
    weich = flaeche.filter(ImageFilter.GaussianBlur(SCHATTEN_WEICH))
    dunkler = Image.eval(weich, lambda v: 255 - int(v * SCHATTEN_TIEFE))
    beschattet = ImageChops.multiply(
        sepia, Image.merge("RGB", (dunkler, dunkler, dunkler)))
    fertig = Image.composite(beschattet, unterlage, karte)
    fertig = Image.composite(unterlage, fertig, flaeche)

    hier = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    ziel = os.path.join(hier, "grafiken", "ruecken-%s.jpg" % name)
    os.makedirs(os.path.dirname(ziel), exist_ok=True)
    fertig.save(ziel, "JPEG", quality=JPEG_QUALITAET, optimize=True,
                progressive=False, subsampling=0)
    print("geschrieben: %s" % ziel)
    print()
    print("Zu benutzen als:")
    print("    \\dsaRueckseite{ruecken-%s}{Titel}{Autor}{Text}{Kasten}" % name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
