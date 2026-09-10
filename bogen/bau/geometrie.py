#!/usr/bin/env python3
"""geometrie.py - liest die Geometrie einer Bogenseite aus dem PDF.

Loest das Problem, an dem die Regex-Fassung (linien-lesen.ps1) scheitert:
Pfade im Content-Stream sind Ketten. "x y m x2 y2 l x3 y3 l" enthaelt zwei
Segmente, ein Regex auf "m ... l" findet nur das erste. Die Spaltenlinien der
Tabellen sind genau solche Ketten - deshalb blieben sie unsichtbar.

Hier wird der Stream stattdessen tokenisiert und mit Zustand gelesen:
aktueller Punkt, Grafikzustandsstapel (q/Q) und die volle Transformations-
matrix (cm). Ausgegeben wird in Millimeter von der linken oberen Papierecke,
also in den Koordinaten der Feldtabelle.

    python bau/geometrie.py <entpacktes.pdf> [--waag] [--senk] [--rechteck]
                            [--min 14] [--von 0] [--bis 297]

Das entpackte PDF erzeugt bau/linien-lesen.ps1, oder direkt:
    gswin64c -I<...> -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite \
        -dCompressStreams=false -dCompressPages=false \
        -dFirstPage=N -dLastPage=N -sOutputFile=roh.pdf quelle.pdf
"""

import argparse
import re
import sys
import zlib

BP2MM = 25.4 / 72.0

# Bezugsrahmen der Seite. Wird aus der Datei gelesen, NICHT angenommen:
# die Farbfassung ist eine Druckdatei mit 11 mm Beschnittzugabe
# (MediaBox 230.8 x 317.8 mm, TrimBox 208.8 x 295.8 mm bei 11 mm Versatz).
# Wer hier A4 fest verdrahtet, misst dort jede Koordinate um 11 mm falsch.
# Bezug ist die TrimBox, wenn vorhanden, sonst die MediaBox.
REF_X0 = 0.0
REF_Y1 = 841.89


def lies_bezugsrahmen(rohdaten):
    """TrimBox bevorzugt, sonst MediaBox. Setzt REF_X0 und REF_Y1."""
    global REF_X0, REF_Y1
    for kasten in (b"TrimBox", b"CropBox", b"MediaBox"):
        treffer = re.findall(rb"/" + kasten + rb"\s*\[([^\]]*)\]", rohdaten)
        if not treffer:
            continue
        werte = [float(v) for v in treffer[0].split()]
        if len(werte) == 4:
            REF_X0, REF_Y1 = werte[0], werte[3]
            return kasten.decode(), werte
    return "Vorgabe A4", [0.0, 0.0, 595.28, 841.89]

ZAHL = re.compile(rb"[-+]?(?:\d+\.?\d*|\.\d+)")


def mal(a, b):
    """Zwei 2x3-Matrizen [a b c d e f] verketten: a angewendet, dann b."""
    a0, a1, a2, a3, a4, a5 = a
    b0, b1, b2, b3, b4, b5 = b
    return (
        a0 * b0 + a1 * b2,
        a0 * b1 + a1 * b3,
        a2 * b0 + a3 * b2,
        a2 * b1 + a3 * b3,
        a4 * b0 + a5 * b2 + b4,
        a4 * b1 + a5 * b3 + b5,
    )


def wende_an(m, x, y):
    return (m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5])


def streams(rohdaten):
    """Alle Streams ausschneiden, Flate-komprimierte entpacken.

    Ghostscripts -dCompressStreams=false laesst Form-XObjects komprimiert.
    Genau darin stecken bei diesem Bogen die Zeilenlinien der Talenttabelle -
    ohne Entpacken bleiben sie unsichtbar, und man haelt die Tabelle
    faelschlich fuer rasterlos.
    """
    for treffer in re.finditer(rb"stream\r?\n?", rohdaten):
        anfang = treffer.end()
        ende = rohdaten.find(b"endstream", anfang)
        if ende <= anfang:
            continue
        roh = rohdaten[anfang:ende]
        for kandidat in _entpacke(roh):
            if _ist_inhalt(kandidat):
                yield kandidat


def _entpacke(roh):
    """Erst entpackt, sonst roh."""
    try:
        return [zlib.decompress(roh)]
    except zlib.error:
        pass
    try:
        # Manche Streams tragen ein Byte zu viel am Ende.
        return [zlib.decompressobj().decompress(roh)]
    except zlib.error:
        return [roh]


def _ist_inhalt(stream):
    """Nur Content-Streams weiterreichen, keine Schrift- und Bilddaten.

    Wichtig fuer die Laufzeit: der Regex fuer PDF-Zeichenketten
    Der Regex fuer PDF-Zeichenketten backtrackt auf Binaerdaten
    Schriftdatei laesst den Lauf minutenlang haengen. Content-Streams
    sind fast reiner ASCII-Text.
    """
    probe = stream[:2048]
    if not probe:
        return False
    if b"\x00" in probe:
        return False
    druckbar = sum(1 for b in probe if 9 <= b <= 13 or 32 <= b <= 126)
    return druckbar / len(probe) > 0.9


def lies(stream):
    """Tokenisieren und Pfade sammeln. Gibt (segmente, rechtecke) zurueck.

    segmente:  ((x1, y1), (x2, y2)) in Geraetekoordinaten (bp)
    rechtecke: (x, y, breite, hoehe) in bp, Ursprung unten links
    """
    einheit = (1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
    ctm = einheit
    stapel = []
    zahlen = []
    segmente = []
    rechtecke = []
    texte = []
    punkt = None
    start = None
    tm = einheit          # Textmatrix
    tlm = einheit         # Textzeilenmatrix
    tl = 0.0              # Zeilenabstand (TL)
    tf = 0.0              # Schriftgroesse
    zeichen = []          # Zeichenketten der laufenden Zeigeoperation

    for tok in re.finditer(
        rb"\((?:\\.|[^\\)])*\)|[-+]?(?:\d+\.?\d*|\.\d+)|[A-Za-z*'\"]+", stream
    ):
        t = tok.group()
        if t.startswith(b"("):
            zeichen.append(t[1:-1])
            continue
        if ZAHL.fullmatch(t):
            zahlen.append(float(t))
            continue

        op = t.decode("latin-1")

        if op == "q":
            stapel.append(ctm)
        elif op == "Q":
            if stapel:
                ctm = stapel.pop()
        elif op == "cm" and len(zahlen) >= 6:
            ctm = mal(tuple(zahlen[-6:]), ctm)
        elif op == "m" and len(zahlen) >= 2:
            punkt = wende_an(ctm, zahlen[-2], zahlen[-1])
            start = punkt
        elif op in ("l",) and len(zahlen) >= 2 and punkt:
            neu = wende_an(ctm, zahlen[-2], zahlen[-1])
            segmente.append((punkt, neu))
            punkt = neu
        elif op in ("c", "v", "y") and len(zahlen) >= 2 and punkt:
            # Kurven interessieren nicht, aber der aktuelle Punkt wandert mit.
            punkt = wende_an(ctm, zahlen[-2], zahlen[-1])
        elif op == "h" and punkt and start:
            segmente.append((punkt, start))
            punkt = start
        elif op == "BT":
            tm = tlm = einheit
        elif op == "Tf" and zahlen:
            tf = zahlen[-1]
        elif op == "TL" and zahlen:
            tl = zahlen[-1]
        elif op == "Tm" and len(zahlen) >= 6:
            tm = tlm = tuple(zahlen[-6:])
        elif op in ("Td", "TD") and len(zahlen) >= 2:
            if op == "TD":
                tl = -zahlen[-1]
            tlm = mal((1.0, 0.0, 0.0, 1.0, zahlen[-2], zahlen[-1]), tlm)
            tm = tlm
        elif op == "T*":
            tlm = mal((1.0, 0.0, 0.0, 1.0, 0.0, -tl), tlm)
            tm = tlm
        elif op in ("Tj", "TJ", "'", '"'):
            if op in ("'", '"'):
                tlm = mal((1.0, 0.0, 0.0, 1.0, 0.0, -tl), tlm)
                tm = tlm
            gm = mal(tm, ctm)
            txt = b"".join(zeichen).decode("latin-1")
            if txt.strip():
                texte.append((gm[4], gm[5], tf * abs(gm[3]), txt))
            zeichen = []
        elif op == "re" and len(zahlen) >= 4:
            x, y, b, h = zahlen[-4:]
            ecken = [wende_an(ctm, x, y), wende_an(ctm, x + b, y + h)]
            x0 = min(ecken[0][0], ecken[1][0])
            y0 = min(ecken[0][1], ecken[1][1])
            x1 = max(ecken[0][0], ecken[1][0])
            y1 = max(ecken[0][1], ecken[1][1])
            rechtecke.append((x0, y0, x1 - x0, y1 - y0))
            punkt = None

        zahlen = []

    return segmente, rechtecke, texte


def mm(v):
    return round(v * BP2MM, 1)


def von_x(x):
    """x in mm vom linken Rand des Bezugsrahmens."""
    return round((x - REF_X0) * BP2MM, 1)


def von_oben(y):
    """y in mm von der Oberkante des Bezugsrahmens."""
    return round((REF_Y1 - y) * BP2MM, 1)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("pdf")
    p.add_argument("--waag", action="store_true", help="waagerechte Linien")
    p.add_argument("--senk", action="store_true", help="senkrechte Linien")
    p.add_argument("--rechteck", action="store_true", help="Rechtecke")
    p.add_argument("--text", action="store_true",
                   help="Textmarken mit Position - liefert exakte Zeilenanker")
    p.add_argument("--min", type=float, default=4.0, help="Mindestlaenge in mm")
    p.add_argument("--von", type=float, default=0.0, help="ab y (mm von oben)")
    p.add_argument("--bis", type=float, default=297.0, help="bis y (mm von oben)")
    a = p.parse_args()

    if not (a.waag or a.senk or a.rechteck or a.text):
        a.waag = a.senk = a.rechteck = True

    with open(a.pdf, "rb") as f:
        roh = f.read()

    name, werte = lies_bezugsrahmen(roh)
    print(f"Bezugsrahmen: {name} "
          f"[{werte[0]:.1f} {werte[1]:.1f} {werte[2]:.1f} {werte[3]:.1f}] "
          f"= {(werte[2]-werte[0])*BP2MM:.1f} x {(werte[3]-werte[1])*BP2MM:.1f} mm")

    segmente, rechtecke, texte = [], [], []
    for s in streams(roh):
        sg, re_, tx = lies(s)
        segmente += sg
        rechtecke += re_
        texte += tx

    def im_fenster(y):
        return a.von <= y <= a.bis

    if a.waag:
        treffer = set()
        for (x1, y1), (x2, y2) in segmente:
            if abs(y1 - y2) * BP2MM > 0.2:
                continue
            laenge = abs(x2 - x1)
            if laenge * BP2MM < a.min:
                continue
            y = von_oben(y1)
            if im_fenster(y):
                treffer.add((y, von_x(min(x1, x2)), mm(laenge)))
        print(f"\nWAAGERECHT ({len(treffer)}), Feld sitzt DARUEBER")
        print(f"{'y':>7} {'x':>7} {'Breite':>7}")
        for y, x, b in sorted(treffer):
            print(f"{y:>7} {x:>7} {b:>7}")

    if a.senk:
        treffer = set()
        for (x1, y1), (x2, y2) in segmente:
            if abs(x1 - x2) * BP2MM > 0.2:
                continue
            laenge = abs(y2 - y1)
            if laenge * BP2MM < a.min:
                continue
            yo = von_oben(max(y1, y2))
            if im_fenster(yo):
                treffer.add((von_x(x1), yo, von_oben(min(y1, y2)), mm(laenge)))
        print(f"\nSENKRECHT ({len(treffer)}) - Spaltengrenzen")
        print(f"{'x':>7} {'yOben':>7} {'yUnten':>7} {'Laenge':>7}")
        for x, yo, yu, l in sorted(treffer):
            print(f"{x:>7} {yo:>7} {yu:>7} {l:>7}")

    if a.text:
        _textausgabe(texte, im_fenster)

    if a.rechteck:
        treffer = set()
        for x, y, b, h in rechtecke:
            if b * BP2MM < a.min and h * BP2MM < a.min:
                continue
            yo = von_oben(y + h)
            if im_fenster(yo):
                treffer.add((yo, von_x(x), mm(b), mm(h)))
        print(f"\nRECHTECKE ({len(treffer)}) - Feld sitzt DARIN")
        print(f"{'y':>7} {'x':>7} {'Breite':>7} {'Hoehe':>7}")
        for y, x, b, h in sorted(treffer):
            print(f"{y:>7} {x:>7} {b:>7} {h:>7}")


def _textausgabe(texte, im_fenster):
    """Textmarken mit Grundlinie in mm von oben.

    Damit sind Zeilenanker exakt statt am Bild abgelesen: die Grundlinie
    einer eingedruckten Beschriftung sagt, wo die Zeile liegt, und ihr x
    sagt, wo das Feld beginnen darf.
    """
    treffer = []
    for x, y, groesse, txt in texte:
        yo = von_oben(y)
        if im_fenster(yo):
            treffer.append((yo, von_x(x), round(groesse, 1), txt))
    print(f"\nTEXTMARKEN ({len(treffer)}), y = Grundlinie")
    print(f"{'y':>7} {'x':>7} {'pt':>5}  Text")
    for yo, x, groesse, txt in sorted(treffer):
        print(f"{yo:>7} {x:>7} {groesse:>5}  {txt}")


if __name__ == "__main__":
    sys.exit(main())
