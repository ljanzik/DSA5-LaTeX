#!/usr/bin/env python3
"""Baut eine oder alle Fassungen des Heldenbogens.

ZWINGEND pdflatex, nicht xelatex. ZWINGEND zwei Laeufe: "remember picture"
braucht zwei Durchgaenge, im ersten liegen alle Felder in der linken oberen
Ecke. Ein Positionsproblem erst nach dem zweiten Lauf glauben.

Beispiele:
    python3 bau/bauen.py                                # ausfuellbar, druckerfreundlich
    python3 bau/bauen.py -Messen                        # mit Messgitter zum Ablesen
    python3 bau/bauen.py -Quelle farbe -Messen
    python3 bau/bauen.py -Modus vorbefuellt -Held dorle
    python3 bau/bauen.py -Modus liste -Held dorle       # ohne Originalbogen
    python3 bau/bauen.py -Alle -Held dorle
    python3 bau/bauen.py -Pruefen                       # unkomprimiert, fuer felder-pruefen

Die Schalter sind in PowerShell-Schreibweise, damit derselbe Aufruf unter
Windows und unter Unix gilt und die Wrapper .ps1/.sh nichts umsetzen muessen.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import argparse
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from werkzeugpfad import AUSGABE, PROJEKT, groesse, pdflatex  # noqa: E402

HIER = Path(__file__).resolve().parent


def baue(modus, quelle, held, gitter, roh, ohneleere):
    """Ein Lauf. Gibt True zurueck, wenn ein PDF entstanden ist."""
    teile = [f"heldenbogen-{quelle}-{modus}"]
    if held:
        teile.append(held)
    if gitter:
        teile.append("messgitter")
    if roh:
        teile.append("roh")
    if ohneleere:
        teile.append("knapp")
    jobname = "-".join(teile)

    vorspann = ""
    # Unkomprimiert: nur zum Pruefen. So lassen sich /Widget, /Rect und die
    # Feldnamen im PDF direkt lesen -- komprimiert findet man sie nicht.
    if roh:
        vorspann += r"\pdfcompresslevel=0 \pdfobjcompresslevel=0 "
    vorspann += r"\def\Modus{%s}\def\Quelle{%s}" % (modus, quelle)
    if held:
        vorspann += r"\def\Held{%s}" % held
    if gitter:
        vorspann += r"\def\Messen{1}"
    if ohneleere:
        vorspann += r"\def\OhneLeere{1}"

    # flush, sonst steht die Ueberschrift hinter der Ausgabe des
    # Unterprozesses: unser print ist gepuffert, pdflatex und
    # quelle-vorbereiten schreiben direkt auf den Handle.
    print(f"=== {jobname}", flush=True)
    # Die Farbfassung braucht die auf A4 normalisierte Quelle, sonst skaliert
    # pdfpages sie und alle Koordinaten sind falsch.
    if quelle == "farbe":
        if subprocess.call([sys.executable, str(HIER / "quelle-vorbereiten.py")],
                           cwd=PROJEKT) != 0:
            return False

    befehl = [pdflatex(), "-interaction=nonstopmode", "-halt-on-error",
              f"-output-directory={AUSGABE}", f"-jobname={jobname}",
              vorspann + r"\input{heldenbogen.tex}"]
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
        # pdflatex meldet Erfolg, schreibt aber kein PDF, wenn das Dokument
        # keine Seite hat. Sauber melden statt abstuerzen.
        print("    kein PDF entstanden - hat das Dokument eine Seite?")
        return False
    print(f"    fertig: {pdf} ({groesse(pdf)})")
    return True


def print_logfehler(log, hoechstens=2, danach=4):
    """Die ersten Fehlerzeilen aus dem Log, mit etwas Umfeld. Das Log ist
    zehntausende Zeilen lang; die Meldung steht hinter einem Ausrufezeichen
    am Zeilenanfang."""
    if not log.exists():
        return
    zeilen = log.read_text(encoding="utf-8", errors="replace").splitlines()
    gezeigt = 0
    for i, zeile in enumerate(zeilen):
        if zeile.startswith("!"):
            for w in zeilen[i:i + 1 + danach]:
                print(f"      {w}")
            gezeigt += 1
            if gezeigt >= hoechstens:
                return


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0],
                                allow_abbrev=False)
    p.add_argument("-Modus", choices=["ausfuellbar", "vorbefuellt", "liste"],
                   default="ausfuellbar")
    p.add_argument("-Quelle", choices=["df", "farbe"], default="df")
    p.add_argument("-Held", default="")
    p.add_argument("-Messen", action="store_true")
    p.add_argument("-OhneLeere", action="store_true")
    p.add_argument("-Pruefen", action="store_true")
    p.add_argument("-Alle", action="store_true")
    a = p.parse_args()

    AUSGABE.mkdir(parents=True, exist_ok=True)
    fehlgeschlagen = 0

    if a.Alle:
        for q in ("df", "farbe"):
            if not baue("ausfuellbar", q, "", False, False, False):
                fehlgeschlagen += 1
            if a.Held and not baue("vorbefuellt", q, a.Held, False, False,
                                   a.OhneLeere):
                fehlgeschlagen += 1
        if a.Held and not baue("liste", "df", a.Held, False, False, False):
            fehlgeschlagen += 1
    else:
        if not baue(a.Modus, a.Quelle, a.Held, a.Messen, a.Pruefen, a.OhneLeere):
            fehlgeschlagen += 1

    if fehlgeschlagen:
        print(f"\n{fehlgeschlagen} Fassung(en) fehlgeschlagen.")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
