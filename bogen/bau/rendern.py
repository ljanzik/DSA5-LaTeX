#!/usr/bin/env python3
"""PDF-Seiten als PNG, zum Ablesen am Messgitter.

150 dpi reicht zum Ablesen der Gitterlinien, 300 dpi fuer feine Stellen.

    python3 bau/rendern.py -Seiten 1
    python3 bau/rendern.py -Seiten 1,2,3
    python3 bau/rendern.py -Datei bau/ausgabe/heldenbogen-df-ausfuellbar-messgitter.pdf -Dpi 300

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from werkzeugpfad import AUSGABE, BILDER, PROJEKT, groesse, gs_lauf  # noqa: E402

VORGABE = AUSGABE / "heldenbogen-df-ausfuellbar-messgitter.pdf"


def seitenliste(text):
    """"1,2,3" oder "1 2 3" -- beides, weil die PowerShell-Fassung ein Array
    nahm und man es unter Unix mit Kommas schreibt."""
    return [int(t) for t in text.replace(",", " ").split()]


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0],
                                allow_abbrev=False)
    p.add_argument("-Datei", default="")
    p.add_argument("-Seiten", type=seitenliste, default=[1, 2, 3, 4, 5, 6])
    p.add_argument("-Dpi", type=int, default=150)
    a = p.parse_args()

    datei = Path(a.Datei) if a.Datei else VORGABE
    if not datei.is_absolute():
        datei = PROJEKT / datei
    if not datei.exists():
        raise SystemExit(f"Nicht gefunden: {datei}\n"
                         "Zuerst bauen: python3 bau/bauen.py -Messen")

    BILDER.mkdir(parents=True, exist_ok=True)
    fehler = 0
    for s in a.Seiten:
        ziel = BILDER / f"{datei.stem}-s{s}.png"
        ok, meldung = gs_lauf([
            "-q", "-dNOPAUSE", "-dBATCH", "-sDEVICE=png16m",
            f"-r{a.Dpi}", f"-dFirstPage={s}", f"-dLastPage={s}",
            f"-sOutputFile={ziel}", str(datei)])
        if ok and ziel.exists():
            print(f"  {ziel} ({groesse(ziel)})")
        else:
            print(f"  Seite {s} FEHLGESCHLAGEN. Ghostscript sagt:")
            for zeile in meldung.strip().splitlines()[-5:]:
                print(f"      {zeile}")
            fehler += 1
    return 1 if fehler else 0


if __name__ == "__main__":
    sys.exit(main())
