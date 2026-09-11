#!/usr/bin/env python3
"""Normalisiert die Farbfassung des Heldendokuments auf A4.

Die Farbfassung ist eine DRUCKDATEI, nicht ein A4-Dokument:
    MediaBox 230.8 x 317.8 mm   (A4 plus 11 mm Beschnittzugabe)
    TrimBox  208.8 x 295.8 mm   um 11 mm versetzt
Legt man sie ungeprueft mit pdfpages ein, skaliert pdfpages sie um etwa
+0,6 Prozent auf A4 -- dann stimmt keine im Quelldokument gemessene
Koordinate mehr mit der Seite ueberein, und zwar ohne Fehlermeldung.

Deshalb hier einmal: auf die TrimBox beschneiden und ohne Skalierung mittig
auf A4 setzen. Ergebnis ist eine A4-Datei, die sich genau wie die
druckerfreundliche Fassung behandeln laesst -- 1:1, ohne Umrechnung. Das Werk
sitzt darin mit 0,59 mm Rand, weil die TrimBox 1,2 mm kleiner als A4 ist.

Die erzeugte Datei landet in bau/ausgabe/ und ist abgeleitetes
Verlagsmaterial -- nicht weitergeben, siehe doku/BOGEN.md.

    python3 bau/quelle-vorbereiten.py [-Neu]

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from werkzeugpfad import AUSGABE, PROJEKT, groesse, gs_lauf  # noqa: E402

# A4 in PDF-Punkten und der Versatz, der die 1,2 mm kleinere TrimBox mittig
# setzt: (595.276 - 591.921) / 2 = 1.678 bp, ebenso in der Hoehe.
A4B = 595.276
A4H = 841.890
VERSATZ = 1.678

ZIEL = AUSGABE / "quelle-farbe-a4.pdf"


def quellpfad():
    """Der Pfad steht in konfig.tex, nicht hier. Er stand einmal an beiden
    Stellen, und konfig.tex behauptet im Kopf, die einzige Datei zu sein, die
    Pfade kennt -- das soll auch stimmen."""
    konfig = (PROJEKT / "konfig.tex").read_text(encoding="utf-8")
    treffer = re.search(r"^\\def\\quelleFarbeRoh\{([^}]*)\}", konfig, re.M)
    if not treffer:
        raise SystemExit(r"In konfig.tex fehlt \def\quelleFarbeRoh{...}")
    return Path(treffer.group(1))


def vorbereiten(neu=False):
    quelle = quellpfad()
    if not quelle.exists():
        raise SystemExit(f"Quelle nicht gefunden: {quelle}\n"
                         r"Pfad in konfig.tex anpassen (\quelleFarbeRoh).")

    AUSGABE.mkdir(parents=True, exist_ok=True)
    if ZIEL.exists() and not neu and ZIEL.stat().st_mtime > quelle.stat().st_mtime:
        print(f"  Farbquelle schon vorbereitet: {ZIEL}")
        return 0

    print("  bereite Farbquelle vor (TrimBox -> A4, ohne Skalierung)...")
    ok, meldung = gs_lauf([
        "-q", "-dNOPAUSE", "-dBATCH", "-sDEVICE=pdfwrite",
        "-dUseTrimBox", "-dFIXEDMEDIA",
        f"-dDEVICEWIDTHPOINTS={A4B}", f"-dDEVICEHEIGHTPOINTS={A4H}",
        f"-sOutputFile={ZIEL}",
        "-c", f"<</PageOffset [{VERSATZ} {VERSATZ}]>> setpagedevice",
        "-f", str(quelle)])

    if not ok or not ZIEL.exists():
        print("  FEHLGESCHLAGEN. Ghostscript sagt:")
        for zeile in meldung.strip().splitlines()[-6:]:
            print(f"      {zeile}")
        return 1
    print(f"  fertig: {ZIEL} ({groesse(ZIEL, 'MB')})")
    return 0


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0],
                                allow_abbrev=False)
    p.add_argument("-Neu", action="store_true",
                   help="auch neu erzeugen, wenn die Datei schon aktuell ist")
    return vorbereiten(p.parse_args().Neu)


if __name__ == "__main__":
    sys.exit(main())
