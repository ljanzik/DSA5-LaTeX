#!/usr/bin/env python3
"""Findet pdflatex und Ghostscript, auf jeder Plattform. Ersetzt texpfad.ps1.

Von den Bauskripten importiert, nicht selbst aufgerufen -- ausser zum
Nachsehen, was gefunden wird:

    python3 bau/werkzeugpfad.py

Warum ueberhaupt eine eigene Suche? Unter Windows liegt TeX Live hier unter
%USERPROFILE%\\texlive\\current und ist nicht zwingend im PATH der aufrufenden
Shell; Ghostscript bringt TeX Live dort selbst mit (tlpkg\\tlgs), es muss also
nichts zusaetzlich installiert werden. Unter macOS und Linux ist beides im
PATH, wenn es installiert ist -- MacTeX legt nach /Library/TeX/texbin --, aber
Ghostscript gehoert dort NICHT zur Distribution und fehlt oft.

NICHT eine zweite TeX-Distribution daneben installieren. Zwei streiten um
PATH und Formatdateien, und der Fehler sieht dann wie ein LaTeX-Fehler aus.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path

# bogen/ -- eine Ebene ueber bau/. Alle Pfade der Skripte sind dazu relativ,
# genau wie frueher bei $Projekt = Split-Path -Parent $PSScriptRoot.
PROJEKT = Path(__file__).resolve().parent.parent
AUSGABE = PROJEKT / "bau" / "ausgabe"
BILDER = PROJEKT / "bau" / "bilder"

WINDOWS = sys.platform.startswith("win")


def _texlive_windows():
    """TeX Live im Benutzerprofil, wie es hier installiert ist."""
    wurzel = Path(os.environ.get("USERPROFILE", "")) / "texlive" / "current"
    return wurzel, wurzel / "bin" / "windows", wurzel / "tlpkg" / "tlgs"


def pdflatex():
    """Pfad zu pdflatex. Bricht mit einer brauchbaren Meldung ab, wenn es
    fehlt -- "command not found" mitten in einem Bauskript sagt zu wenig."""
    gefunden = shutil.which("pdflatex")
    if gefunden:
        return gefunden
    if WINDOWS:
        _, texbin, _ = _texlive_windows()
        kandidat = texbin / "pdflatex.exe"
        if kandidat.exists():
            # In den PATH, damit auch Kindprozesse es finden.
            os.environ["PATH"] = str(texbin) + os.pathsep + os.environ["PATH"]
            return str(kandidat)
        raise SystemExit(f"pdflatex nicht gefunden. Erwartet unter {texbin}")
    raise SystemExit(
        "pdflatex nicht gefunden.\n"
        "  macOS : brew install --cask mactex-no-gui   (dann neue Shell)\n"
        "  Linux : die texlive-Pakete der Distribution")


def ghostscript():
    """(Programm, Zusatzargumente) fuer Ghostscript.

    Die Zusatzargumente sind nur unter Windows noetig: das Ghostscript aus
    TeX Live findet seine Initialisierungsdateien nicht von selbst, lib,
    kanji und Resource muessen per -I mitgegeben werden. Sonst bricht es mit
    "Can't find initialization file gs_init.ps" ab."""
    if WINDOWS:
        wurzel, _, tlgs = _texlive_windows()
        exe = tlgs / "bin" / "gswin64c.exe"
        if exe.exists():
            include = "-I" + ";".join(str(tlgs / t) for t in
                                      ("lib", "kanji", "Resource/Init", "Resource"))
            return str(exe), [include]
        gefunden = shutil.which("gswin64c") or shutil.which("gs")
        if gefunden:
            return gefunden, []
        raise SystemExit(f"Ghostscript nicht gefunden. Erwartet unter {exe}")

    gefunden = shutil.which("gs")
    if gefunden:
        return gefunden, []
    raise SystemExit(
        "Ghostscript nicht gefunden. Anders als unter Windows bringt TeX Live\n"
        "es hier nicht mit.\n"
        "  macOS : brew install ghostscript\n"
        "  Linux : das ghostscript-Paket der Distribution")


def gs_lauf(argumente):
    """Ghostscript starten und (Erfolg, Ausgabe) zurueckgeben. Die Ausgabe
    wird eingesammelt statt durchgereicht: im Erfolgsfall interessiert sie
    niemanden, im Fehlerfall zeigen die Skripte die letzten Zeilen."""
    exe, include = ghostscript()
    fertig = subprocess.run([exe] + include + argumente,
                            capture_output=True, text=True, errors="replace")
    return fertig.returncode == 0, (fertig.stdout or "") + (fertig.stderr or "")


def groesse(pfad, einheit="KB"):
    b = Path(pfad).stat().st_size
    return f"{round(b / 1024)} KB" if einheit == "KB" else f"{b / 1048576:.1f} MB"


def tabelle(zeilen, spalten):
    """Eine schlichte Tabelle, wie Format-Table -AutoSize sie gab: jede
    Spalte so breit wie ihr laengster Eintrag, Kopfzeile unterstrichen."""
    if not zeilen:
        return
    breiten = [max(len(str(s)), max(len(str(z[i])) for z in zeilen))
               for i, s in enumerate(spalten)]
    print("  ".join(s.ljust(b) for s, b in zip(spalten, breiten)).rstrip())
    print("  ".join("-" * b for b in breiten).rstrip())
    for z in zeilen:
        print("  ".join(str(w).ljust(b) for w, b in zip(z, breiten)).rstrip())


if __name__ == "__main__":
    print(f"Projekt     : {PROJEKT}")
    print(f"Plattform   : {sys.platform}")
    try:
        print(f"pdflatex    : {pdflatex()}")
    except SystemExit as f:
        print(f"pdflatex    : {f}")
    try:
        exe, inc = ghostscript()
        print(f"Ghostscript : {exe}")
        if inc:
            print(f"              mit {inc[0][:60]}...")
    except SystemExit as f:
        print(f"Ghostscript : {f}")
