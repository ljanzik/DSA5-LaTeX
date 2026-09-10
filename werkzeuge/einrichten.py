#!/usr/bin/env python3
"""Richtet das Projekt ein: Grafiken, Schriften, Pergament, Pruefung.

    python3 werkzeuge/einrichten.py "/pfad/zu/Scriptorium Aventuris v4"
    python3 werkzeuge/einrichten.py "/pfad/zum/Baukasten" \\
        --rueckseiten "/pfad/zum/Rueckseiten_Karten_Paket"
    python3 werkzeuge/einrichten.py --pruefen

Es ruft die Werkzeuge auf, die es dafuer schon gibt, und gibt allen
denselben Baukastenpfad:

    aufbereiten.py   Grafiken und Schriften aus dem Baukasten
    pergament.py     die Pergamentflaeche der Charaktermappe
    pruefen.py       Pixelmasse gegen doku/MASSE.md

Warum eine Klammer darum? Weil der Pfad zum Baukasten an mehr als einer
Stelle gebraucht wird und deshalb an mehr als einer Stelle stand: einmal
als Argument von aufbereiten.py, einmal fest verdrahtet im Kopf des
Pergamentwerkzeugs. Beim naechsten Baukasten waere einer davon
liegengeblieben, und der Fehler haette wie ein Bildfehler ausgesehen, nicht
wie ein Pfadfehler. Jetzt nennt ihn der Anwender einmal.

--pruefen richtet nichts ein, sondern sagt nur, was da ist und was fehlt.
Das ist der schnellste Weg zu der Frage "warum kompiliert das nicht".

Die Heldendokumente fuer bogen/ werden nur gesucht, nicht aufbereitet: sie
sind ein eigenes, kostenpflichtiges Verlagsprodukt und werden vom Bogen
unveraendert eingelegt. Ihre Pfade stehen in bogen/konfig.tex.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import re
import subprocess
import sys
from pathlib import Path

PROJEKT = Path(__file__).resolve().parent.parent

# Modulname, Name auf PyPI, wofuer. Der dritte Eintrag steht in der
# Fehlermeldung: "numpy fehlt" allein sagt niemandem, was dann nicht geht.
PAKETE = [
    ("PIL", "Pillow", "aufbereiten.py, pergament.py, pruefen.py"),
    ("psd_tools", "psd-tools", "aufbereiten.py, Kapitelanfang aus dem PSD"),
    ("numpy", "numpy", "pergament.py, Papierrand und Farbton"),
    ("pdfplumber", "pdfplumber", "nachmessen.py, Lage und Groesse im PDF"),
]

# Was am Ende dasein muss, damit die Beispiele bauen. Eine Stichprobe, keine
# vollstaendige Liste -- die fuehrt pruefen.py gegen doku/MASSE.md.
PROBEN = [
    ("schriften/GenBasR.ttf", "Grundschrift Gentium Basic"),
    ("schriften/andlso.ttf", "Auszeichnungsschrift Andalus"),
    ("grafiken/umschlag-vorne.png", "Zierrahmen des Umschlags"),
    ("grafiken/mappe-pergament-a4.jpg", "Pergamentflaeche der Charaktermappe"),
]


def fehlende_pakete():
    fehlt = []
    for modul, paket, wofuer in PAKETE:
        try:
            __import__(modul)
        except ImportError:
            fehlt.append((paket, wofuer))
    return fehlt


def heldendokumente():
    """Die beiden Quell-PDF des Bogens, gelesen aus bogen/konfig.tex. Der
    Bogen legt sie ein, aufbereitet wird an ihnen nichts -- ausser der
    Normalisierung der Farbfassung, und die macht quelle-vorbereiten.ps1
    beim Bauen von selbst."""
    konfig = PROJEKT / "bogen" / "konfig.tex"
    if not konfig.is_file():
        return []
    text = konfig.read_text(encoding="utf-8")
    gefunden = []
    for marke, wofuer in (("quelleDF", "druckerfreundliche Fassung, 6 Seiten"),
                          ("quelleFarbeRoh", "Farbfassung, 10 Seiten")):
        treffer = re.search(r"\\def\\" + marke + r"\{([^}]*)\}", text)
        if treffer:
            gefunden.append((Path(treffer.group(1)), marke, wofuer))
    return gefunden


def lauf(werkzeug, argumente):
    """Ein Werkzeug mit demselben Interpreter starten, der hier laeuft.
    Nicht "python3": unter Windows heisst es "python", und in einer
    virtuellen Umgebung ist beides das falsche."""
    befehl = [sys.executable, str(PROJEKT / "werkzeuge" / werkzeug)] + argumente
    # flush, sonst steht die Ueberschrift hinter der Ausgabe des Werkzeugs:
    # unser print ist gepuffert, der Unterprozess schreibt direkt auf den
    # Handle. Ohne das ist nicht zuzuordnen, welche Zeile von wem kommt.
    print(f"\n=== {werkzeug}", flush=True)
    return subprocess.call(befehl)


def bestand():
    """Was ist da, was fehlt. Gibt die Zahl der fehlenden Stuecke zurueck."""
    fehlt = 0

    print("Python-Pakete")
    for paket, wofuer in fehlende_pakete():
        print(f"  FEHLT  {paket:<12} {wofuer}")
        fehlt += 1
    if not fehlende_pakete():
        print("  alle da")

    print("\nGrafiken und Schriften")
    for name, wofuer in PROBEN:
        pfad = PROJEKT / name
        stand = "da   " if pfad.exists() else "FEHLT"
        if not pfad.exists():
            fehlt += 1
        print(f"  {stand}  {name:<36} {wofuer}")

    print("\nHeldendokumente (nur fuer bogen/)")
    doks = heldendokumente()
    if not doks:
        print("  bogen/konfig.tex nicht lesbar oder ohne Pfadangaben")
    for pfad, marke, wofuer in doks:
        stand = "da   " if pfad.exists() else "FEHLT"
        print(f"  {stand}  {marke:<16} {wofuer}")
        if not pfad.exists():
            print(f"         erwartet: {pfad}")
    return fehlt


def main():
    argv = sys.argv[1:]

    if "--pruefen" in argv:
        offen = bestand()
        if offen:
            print(f"\n{offen} Stueck fehlen. Ohne Grafiken und Schriften "
                  f"kompiliert nichts.")
            print('  python3 werkzeuge/einrichten.py "/pfad/zum/Baukasten"')
            print("Die Heldendokumente werden nicht aufbereitet, sondern")
            print("gekauft und in bogen/konfig.tex eingetragen. Siehe README,")
            print('Abschnitt "Schritt 1c".')
        else:
            print("\nAlles da.")
        return 1 if offen else 0

    stellen = [a for a in argv if not a.startswith("--")]
    # --rueckseiten nimmt selbst einen Pfad; der ist kein Baukastenpfad.
    if "--rueckseiten" in argv:
        i = argv.index("--rueckseiten")
        if i + 1 >= len(argv):
            print("--rueckseiten braucht einen Pfad.")
            return 2
        rueck = argv[i + 1]
        stellen = [a for a in stellen if a != rueck]
    else:
        rueck = None

    if not stellen:
        print(__doc__)
        return 2
    baukasten = stellen[0].rstrip("/\\")
    if not Path(baukasten).is_dir():
        print(f"Kein Ordner: {baukasten}")
        return 2

    fehlt = fehlende_pakete()
    if fehlt:
        print("Es fehlen Python-Pakete:")
        for paket, wofuer in fehlt:
            print(f"  {paket:<12} {wofuer}")
        print("\n  python3 -m pip install " + " ".join(p for p, _ in fehlt))
        return 2

    # Reihenfolge: erst die Masse aus dem Baukasten, dann das Abgeleitete,
    # dann die Pruefung. pruefen.py vergleicht gegen doku/MASSE.md und haette
    # vor dem Aufbereiten nichts zu vergleichen.
    args = [baukasten] + (["--rueckseiten", rueck] if rueck else [])
    if lauf("aufbereiten.py", args) != 0:
        print("\naufbereiten.py ist fehlgeschlagen. Abbruch.")
        return 1
    if lauf("pergament.py", [baukasten]) != 0:
        print("\npergament.py ist fehlgeschlagen. Abbruch.")
        return 1
    lauf("pruefen.py", [])

    print("\n=== Bestand")
    offen = bestand()

    print("\nBauen:")
    print("  cd beispiel && xelatex beispiel.tex        (dreimal)")
    if (PROJEKT / "bogen").is_dir():
        print("  .\\bogen\\bau\\bauen.ps1                      Heldenbogen")
        print("  .\\bogen\\bau\\mappe-bauen.ps1 -Held dorle    Charaktermappe")
    return 1 if offen else 0


if __name__ == "__main__":
    sys.exit(main())
