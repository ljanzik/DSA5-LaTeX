#!/usr/bin/env python3
"""Liest die tatsaechlichen Feldpositionen aus dem PDF.

Die Gegenprobe zum Einmessen, ohne hinsehen zu muessen: baut eine
unkomprimierte Fassung und rechnet jedes /Rect zurueck in Millimeter von der
linken oberen Papierecke -- also in genau die Koordinaten, in denen die
Feldtabelle geschrieben ist. Abweichung zur Tabelle = Fehler.

Prueft ausserdem drei Dinge, die still schiefgehen:
  - DOPPELTE Feldnamen. AcroForm macht daraus EIN Feld mit gespiegeltem
    Inhalt. In einer Tabellenschleife passiert das schnell.
  - weisser Hintergrund (/MK<</BG...>>), der den Originalbogen ueberdeckt.
  - Rahmen (/BS<</W ...>> ungleich 0).

Wichtig: /Rect steht im Objekt VOR /T. Deshalb wird je Objekt geparst und
nicht ueber den Token-Strom -- sonst paart man jeden Namen mit dem Rechteck
des naechsten Feldes und alles ist um eine Zeile verschoben.

    python3 bau/felder-pruefen.py
    python3 bau/felder-pruefen.py -Quelle farbe
    python3 bau/felder-pruefen.py -NichtNeuBauen

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import argparse
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from werkzeugpfad import AUSGABE, PROJEKT, tabelle  # noqa: E402

HIER = Path(__file__).resolve().parent

HOEHE = 841.89          # A4 in PDF-Punkten (bp), Ursprung unten links
BP2MM = 25.4 / 72


def entschluessle(roh):
    """/T ist UTF-16BE mit BOM, oktal escaped: \\376\\377\\000s\\0001 ..."""
    bytes_ = bytearray()
    i = 0
    while i < len(roh):
        if roh[i] == "\\" and i + 3 < len(roh) and roh[i + 1] in "01234567":
            bytes_.append(int(roh[i + 1:i + 4], 8))
            i += 4
        else:
            bytes_.append(ord(roh[i]) & 0xFF)
            i += 1
    return bytes_.decode("utf-16-be", errors="replace").lstrip("﻿")


def felder_lesen(pdf):
    # Binaerteile stoeren nicht; bei -pdfobjcompresslevel=0 ist die
    # Objektstruktur Klartext. latin-1 bildet jedes Byte auf ein Zeichen ab,
    # ohne an ungueltigem UTF-8 zu scheitern.
    txt = pdf.read_bytes().decode("latin-1")
    felder = []
    for obj in re.finditer(r"\d+ 0 obj(.{0,600}?)endobj", txt, re.S):
        o = obj.group(1)
        if "/Widget" not in o:
            continue
        rect = re.search(r"/Rect\s*\[([^\]]*)\]", o)
        if not rect:
            continue
        z = [float(t) for t in rect.group(1).split()]
        if len(z) != 4:
            continue
        name = re.search(r"/T\s*\(((?:\\.|[^)])*)\)", o)
        rahmen = re.search(r"/BS\s*<<\s*/W\s*([\d.]+)", o)
        felder.append({
            "Name": entschluessle(name.group(1)) if name else "(ohne Namen)",
            "x": round(z[0] * BP2MM, 2),
            "y": round((HOEHE - z[3]) * BP2MM, 2),
            "Breite": round((z[2] - z[0]) * BP2MM, 2),
            "Hoehe": round((z[3] - z[1]) * BP2MM, 2),
            "Grund": "JA" if re.search(r"/BG\s*\[", o) else "-",
            "Rahmen": rahmen.group(1) if rahmen else "-",
        })
    return felder


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0],
                                allow_abbrev=False)
    p.add_argument("-Quelle", choices=["df", "farbe"], default="df")
    p.add_argument("-NichtNeuBauen", action="store_true")
    a = p.parse_args()

    if not a.NichtNeuBauen:
        if subprocess.call([sys.executable, str(HIER / "bauen.py"),
                            "-Quelle", a.Quelle, "-Pruefen"], cwd=PROJEKT) != 0:
            return 1

    pdf = AUSGABE / f"heldenbogen-{a.Quelle}-ausfuellbar-roh.pdf"
    if not pdf.exists():
        raise SystemExit(f"Nicht gefunden: {pdf}")

    felder = felder_lesen(pdf)
    spalten = ["Name", "x", "y", "Breite", "Hoehe", "Grund", "Rahmen"]
    print(f"\nFelder im PDF: {len(felder)}   (Masse in mm von links oben)\n")
    tabelle([[f[s] for s in spalten] for f in sorted(felder, key=lambda f: f["Name"])],
            spalten)

    fehler = 0

    doppelt = [(n, z) for n, z in Counter(f["Name"] for f in felder).items() if z > 1]
    if doppelt:
        print("\nFEHLER -- doppelte Feldnamen, AcroForm macht daraus je EIN Feld:")
        for n, z in sorted(doppelt):
            print(f"  {n}  ({z}x)")
        fehler += 1
    else:
        print("\nFeldnamen eindeutig.")

    mit_grund = [f for f in felder if f["Grund"] == "JA"]
    if mit_grund:
        print(f"FEHLER -- {len(mit_grund)} Feld(er) mit weissem Hintergrund; "
              f"sie ueberdecken den Originalbogen.")
        fehler += 1
    else:
        print("Kein Feld hat Hintergrund.")

    mit_rahmen = [f for f in felder
                  if f["Rahmen"] != "-" and float(f["Rahmen"]) != 0]
    if mit_rahmen:
        print(f"HINWEIS -- {len(mit_rahmen)} Feld(er) mit Rahmen.")
    else:
        print("Kein Feld hat Rahmen.")

    return 1 if fehler else 0


if __name__ == "__main__":
    sys.exit(main())
