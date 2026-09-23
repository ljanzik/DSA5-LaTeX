#!/usr/bin/env python3
"""Baut die Charaktermappe.

Die Mappe ist der Umschlag zu den Heldenboegen: Titel, Rueckseite und zwei
Innenblaetter. Sie enthaelt KEINE Seite des Originalbogens und ist damit
weitergebbar, solange der Pflichttext der Vereinbarung ueber
Gemeinschaftsinhalte mitgeht (er steht auf dem linken Innenblatt).

Zwei Laeufe, wie beim Heldenbogen: die Blaetter sind Boxen, aber tikz braucht
seinen zweiten Lauf trotzdem.

Beispiele:
    python3 bau/mappe-bauen.py -Held dorle                  # 4 x A4, digital
    python3 bau/mappe-bauen.py -Held dorle -Fassung druck   # 2 x A3 quer
    python3 bau/mappe-bauen.py -Held dorle -Fassung druck -Wenden lang
    python3 bau/mappe-bauen.py -Held dorle -Beide

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import argparse
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from bauen import print_logfehler  # noqa: E402
from werkzeugpfad import AUSGABE, PROJEKT, groesse, pdflatex  # noqa: E402

# Pergamentflaeche und Fusskasten liegen in grafiken/, wie jede andere
# Baukastengrafik. Erzeugt werden sie beim Einrichten, nicht beim Bauen:
# dafuer braucht es den Pfad zum Baukasten, und den kennt allein der Anwender.
GRAFIKEN = PROJEKT.parent / "grafiken"
NOETIG = ["mappe-pergament-a4.jpg", "mappe-pergament-kasten.png"]


def pergament_pruefen():
    fehlend = [n for n in NOETIG if not (GRAFIKEN / n).exists()]
    if not fehlend:
        return True
    print("Das Pergament der Mappe fehlt in grafiken/:")
    for n in fehlend:
        print(f"  {n}")
    print('  python3 werkzeuge/einrichten.py "/pfad/zu/Scriptorium Aventuris v4"')
    print("oder nur diesen Teil:")
    print('  python3 werkzeuge/pergament.py "/pfad/zu/Scriptorium Aventuris v4"')
    return False


def baue(fassung, held, wenden):
    teile = [f"mappe-{fassung}"]
    if held:
        teile.append(held)
    if fassung == "druck" and wenden == "lang":
        teile.append("wendenlang")
    jobname = "-".join(teile)

    vorspann = r"\def\Fassung{%s}\def\Wenden{%s}" % (fassung, wenden)
    if held:
        vorspann += r"\def\Held{%s}" % held

    # flush, sonst steht die Ueberschrift hinter der Ausgabe des
    # Unterprozesses: unser print ist gepuffert, pdflatex und
    # quelle-vorbereiten schreiben direkt auf den Handle.
    print(f"=== {jobname}", flush=True)
    befehl = [pdflatex(), "-interaction=nonstopmode", "-halt-on-error",
              f"-output-directory={AUSGABE}", f"-jobname={jobname}",
              vorspann + r"\input{mappe/mappe.tex}"]
    for lauf in (1, 2):
        fertig = subprocess.run(befehl, cwd=PROJEKT, capture_output=True,
                                text=True, errors="replace")
        if fertig.returncode != 0:
            log = AUSGABE / f"{jobname}.log"
            print(f"    Lauf {lauf} FEHLGESCHLAGEN. Fehler aus dem Log:")
            print_logfehler(log)
            print(f"    vollstaendig: {log}")
            return False

    pdf = AUSGABE / f"{jobname}.pdf"
    if not pdf.exists():
        print("    kein PDF entstanden - hat das Dokument eine Seite?")
        return False
    print(f"    fertig: {pdf} ({groesse(pdf)})")
    return True


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0],
                                allow_abbrev=False)
    p.add_argument("-Held", default="")
    p.add_argument("-Fassung", choices=["digital", "druck"], default="digital")
    p.add_argument("-Wenden", choices=["kurz", "lang"], default="kurz")
    p.add_argument("-Beide", action="store_true")
    a = p.parse_args()

    AUSGABE.mkdir(parents=True, exist_ok=True)
    if not pergament_pruefen():
        return 1

    fehlgeschlagen = 0
    if a.Beide:
        if not baue("digital", a.Held, "kurz"):
            fehlgeschlagen += 1
        if not baue("druck", a.Held, a.Wenden):
            fehlgeschlagen += 1
    else:
        if not baue(a.Fassung, a.Held, a.Wenden):
            fehlgeschlagen += 1

    if fehlgeschlagen:
        print(f"\n{fehlgeschlagen} Fassung(en) fehlgeschlagen.")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
