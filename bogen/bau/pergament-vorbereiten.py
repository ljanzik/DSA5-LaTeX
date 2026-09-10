# bau/pergament-vorbereiten.py
#
# Erzeugt die A4-Pergamentflaeche fuer die Charaktermappe aus dem
# Scriptorium-Aventuris-Baukasten.
#
# Warum ueberhaupt ableiten? Zwei Gruende, beide gemessen:
#
# 1. Die Baukasten-Doppelseiten (Doppelseite1..4) bringen eigene Randgrafik
#    mit -- Schuppenruecken links und rechts, braune Flecken oben und unten,
#    einen nachgedunkelten Bundsteg. Davon darf nichts zu sehen sein: die
#    Mappe hat ihren eigenen Rahmen. Und ihre Innenflaeche ist als Textur
#    wertlos: Standardabweichung 1,0 von 255, also praktisch ein glattes
#    Weiss. Sie sind deshalb NICHT die Quelle.
#
# 2. Kasten_Pergament.png ist es. Das ist eine echte Pergamenttextur
#    (Standardabweichung 6,2, Mittelton #FAF3E2) und hat mit 1617 x 2272
#    Pixeln fast genau das A4-Verhaeltnis (0,7117 gegen 0,7071). Nur ihr
#    gerissener Blattrand muss weg -- der Charakterbogen hat eine gerade
#    Kante mit braunem Auslauf. Also leicht ueberformatig einpassen, den
#    Deckelrand abschneiden und einen eigenen Papierrand aufbringen.
#
# Die Quelle ist Verlagsmaterial und liegt ausserhalb des Projekts (wie die
# beiden Heldenbogen-PDF, siehe konfig.tex). Die abgeleitete Datei landet in
# bau/ausgabe/ und wird nicht weitergegeben.
#
#   python bau/pergament-vorbereiten.py [--zeigen]

import sys
from pathlib import Path

import numpy as np
from PIL import Image

BAUKASTEN = Path.home() / "Downloads" / "Scriptorium_Aventuris_Layout_Baukasten" \
    / "Scriptorium Aventuris v4" / "PNG innen"
QUELLE = BAUKASTEN / "Kasten_Pergament.png"

AUSGABE = Path(__file__).resolve().parent / "ausgabe"

# JPEG, nicht PNG. Die Flaeche ist eine gefleckte Textur ohne Kanten und
# ohne Transparenz -- verlustfrei bringt hier nichts und kostet viel: als
# PNG waren es 5,3 MB und damit eine 6-MB-Mappe, als JPEG bleibt ein
# Bruchteil davon. Fuer die digitale Weitergabe ist das der Unterschied
# zwischen Anhang und Downloadlink.
ZIEL = AUSGABE / "pergament-a4.jpg"
GUETE = 88

# Der Fusskasten der Mappe. Dieselbe Textur, quer, mit gerissenem Rand --
# genau der Kasten, der beim Vorbild am Seitenfuss steht. Der Alphakanal muss
# erhalten bleiben, sonst sitzt der Kasten in einem weissen Rechteck.
QUELLE_KASTEN = BAUKASTEN / "Kasten_Pergament_ver3 Kopie.png"
ZIEL_KASTEN = AUSGABE / "pergament-kasten.png"

DPI = 300
BREITE = round(210 / 25.4 * DPI)   # 2480
HOEHE = round(297 / 25.4 * DPI)    # 3508

# Anteil, der an jeder Kante abgeschnitten wird, damit der gerissene
# Blattrand der Vorlage verschwindet.
BESCHNITT = 0.055

# Zielton der Papiermitte, am HvS-Charakterbogen gemessen (#FCFAF6).
# Die Baukasten-Textur ist waermer (#FAF3E2) und wird darauf eingestellt.
PAPIERTON = (252, 250, 246)

# Papierrand, ebenfalls am Charakterbogen gemessen: satter Saum bis 1,75 mm,
# danach ein weicher Auslauf. Der Auslauf ist bewusst breit und flau -- beim
# Vorbild ist die Kante eine Tonung, kein Brandrand.
RANDTON = (123, 98, 80)
SAUM_MM = 1.75
AUSLAUF_MM = 16.0
RANDSTAERKE = 0.88     # wie satt der Rand hoechstens wird
SAETTIGUNG = 0.62      # die Baukasten-Textur ist gelber als das Vorbild


def auf_a4(bild: Image.Image) -> Image.Image:
    """Schneidet den gerissenen Blattrand ab und passt den Rest formatfuellend
    auf A4 ein. Formatfuellend, nicht verzerrt: das Verhaeltnis der Vorlage
    (0,7117) weicht nur um 0,7 Prozent von A4 ab, der Ueberschuss faellt in
    den Beschnitt."""
    bw, bh = bild.size
    dx, dy = round(bw * BESCHNITT), round(bh * BESCHNITT)
    kern = bild.crop((dx, dy, bw - dx, bh - dy))
    kw, kh = kern.size
    faktor = max(BREITE / kw, HOEHE / kh)
    gross = kern.resize((round(kw * faktor), round(kh * faktor)), Image.LANCZOS)
    lx = (gross.size[0] - BREITE) // 2
    ly = (gross.size[1] - HOEHE) // 2
    return gross.crop((lx, ly, lx + BREITE, ly + HOEHE))


def weichesrauschen(breite: int, hoehe: int, grob: int, saat: int) -> np.ndarray:
    """Tieffrequentes Rauschen in [0,1]: ein kleines Zufallsfeld, glatt
    hochskaliert. Ohne das bekommt der Randauslauf konzentrische Streifen."""
    rng = np.random.default_rng(saat)
    klein = rng.random((max(2, hoehe // grob), max(2, breite // grob)))
    return np.asarray(
        Image.fromarray((klein * 255).astype(np.uint8))
        .resize((breite, hoehe), Image.BICUBIC),
        dtype=float) / 255.0


def randmaske(breite: int, hoehe: int) -> np.ndarray:
    """1 am Blattrand, 0 in der Flaeche -- mit gefleckter Kante."""
    px_mm = DPI / 25.4
    x = np.arange(breite)
    y = np.arange(hoehe)
    dx = np.minimum(x, breite - 1 - x)
    dy = np.minimum(y, hoehe - 1 - y)
    abstand = np.minimum(dx[None, :], dy[:, None]) / px_mm   # mm zum Rand

    # Die Breite des Saums schwankt leicht, sonst sieht die Kante gedruckt aus
    # -- aber nur leicht, sonst wird daraus ein Brandrand.
    saum = SAUM_MM * (1.0 + 0.18 * (weichesrauschen(breite, hoehe, 120, 7) - 0.5))
    auslauf = AUSLAUF_MM * (1.0 + 0.30 * (weichesrauschen(breite, hoehe, 200, 11) - 0.5))

    m = np.clip(1.0 - (abstand - saum) / auslauf, 0.0, 1.0)
    m = m ** 2.6
    m[abstand <= saum] = 1.0
    # sachte Wolkigkeit im Auslauf
    m *= 0.85 + 0.30 * weichesrauschen(breite, hoehe, 110, 23)
    return np.clip(m, 0.0, 1.0) * RANDSTAERKE


def main() -> None:
    if not QUELLE.exists():
        raise SystemExit(f"Baukasten-Quelle nicht gefunden:\n  {QUELLE}")

    # Die Vorlage ist RGBA mit transparentem Aussenbereich -- erst auf Weiss
    # legen, sonst wird der Alphakanal beim convert() einfach verworfen und
    # der Rand schwarz.
    quelle = Image.open(QUELLE).convert("RGBA")
    grund = Image.new("RGBA", quelle.size, (255, 255, 255, 255))
    grund.alpha_composite(quelle)
    flaeche = auf_a4(grund.convert("RGB"))

    a = np.asarray(flaeche, dtype=float)

    # Auf den Papierton des Charakterbogens einstellen: die Baukasten-Textur
    # ist waermer (#FAF3E2 gegen #FCFAF6). Nur der Mittelwert wird verschoben,
    # die Textur bleibt -- sonst waere die Flaeche glatt.
    mitte = a[HOEHE // 4:3 * HOEHE // 4, BREITE // 4:3 * BREITE // 4]
    for k in range(3):
        ist = mitte[..., k].mean()
        a[..., k] = np.clip(a[..., k] * (PAPIERTON[k] / ist), 0, 255)

    # Farbigkeit der Textur zuruecknehmen: das Vorbild ist graustichiger.
    grau = a.mean(axis=2, keepdims=True)
    a = grau + (a - grau) * SAETTIGUNG

    # Papierrand einmultiplizieren
    m = randmaske(BREITE, HOEHE)[..., None]
    rand = np.asarray(RANDTON, dtype=float)[None, None, :]
    a = a * (1.0 - m) + rand * m

    ZIEL.parent.mkdir(parents=True, exist_ok=True)
    bild = Image.fromarray(a.astype(np.uint8))
    bild.save(ZIEL, dpi=(DPI, DPI), quality=GUETE, subsampling=0, optimize=True)
    print(f"{ZIEL}  {BREITE}x{HOEHE} px  {ZIEL.stat().st_size / 1024:.0f} KB")

    kasten()

    if "--zeigen" in sys.argv:
        vorschau = ZIEL.with_name("pergament-a4-vorschau.png")
        bild.resize((BREITE // 4, HOEHE // 4), Image.LANCZOS).save(vorschau)
        print(vorschau)


def kasten() -> None:
    """Uebernimmt den Fusskasten unter einem Namen ohne Leerzeichen und
    Umlaute -- \\includegraphics kommt mit "Kasten_Pergament_ver3 Kopie.png"
    nicht ohne Klimmzuege zurecht. Die Farbigkeit wird wie bei der Flaeche
    zurueckgenommen, damit beides zusammenpasst. Der Alphakanal bleibt."""
    if not QUELLE_KASTEN.exists():
        raise SystemExit(f"Baukasten-Quelle nicht gefunden:\n  {QUELLE_KASTEN}")
    im = Image.open(QUELLE_KASTEN).convert("RGBA")
    a = np.asarray(im, dtype=float)
    rgb, alpha = a[..., :3], a[..., 3:]
    grau = rgb.mean(axis=2, keepdims=True)
    rgb = grau + (rgb - grau) * SAETTIGUNG
    aus = np.concatenate([np.clip(rgb, 0, 255), alpha], axis=2).astype(np.uint8)
    Image.fromarray(aus, "RGBA").save(ZIEL_KASTEN, optimize=True)
    print(f"{ZIEL_KASTEN}  {im.size[0]}x{im.size[1]} px  "
          f"{ZIEL_KASTEN.stat().st_size / 1024:.0f} KB")


if __name__ == "__main__":
    main()
