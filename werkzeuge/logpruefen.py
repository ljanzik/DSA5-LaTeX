#!/usr/bin/env python3
"""Prueft die Logs gebauter Beispiele auf Meldungen, die LaTeX nicht als
Fehler behandelt, die hier aber einer sind.

    python3 werkzeuge/logpruefen.py beispiel/*.log

Warum ein eigenes Werkzeug: die Klasse meldet eine Tabelle, die unten aus
der Spalte laeuft, nur als "Class dsa5latex Warning". Der Lauf endet dann
mit Erfolg, und das PDF ist falsch. In der CI muss so ein Lauf rot werden.

Als Fehler gelten:
  * jede "Class dsa5latex Warning" ausser der Ansage der Option ersatz
  * "Overfull \\vbox" -- etwas passt senkrecht nicht, das Raster ist dahin
  * undefinierte Verweise, die auch nach allen Laeufen stehen bleiben

Nicht als Fehler gelten "Overfull \\hbox": die Kaesten ragen mit ihrem
Ueberhang absichtlich ueber die Spalte hinaus (siehe dsaueberhang in der
Klasse), und jeder Kasten meldet das.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import re
import sys

ERLAUBT = [
    re.compile(r'Option ersatz'),
]

REGELN = [
    ('Klassenwarnung', re.compile(r'Class dsa5latex Warning')),
    ('Overfull \\vbox', re.compile(r'Overfull \\vbox')),
    ('Verweis offen', re.compile(r'There were undefined references|'
                                 r'Reference `[^\']*\' on page .* undefined')),
]


def meldungen(pfad):
    # TeX bricht Logzeilen nach 79 Zeichen um. Eine Warnung laeuft ueber
    # mehrere Zeilen und endet an einer Leerzeile oder einem Punkt am
    # Zeilenanfang -- zusammengefuegt wird bis dahin, damit die Ausnahme
    # auch dann greift, wenn ihr Wort ueber den Umbruch faellt.
    with open(pfad, encoding='utf-8', errors='replace') as f:
        zeilen = f.read().splitlines()
    i = 0
    while i < len(zeilen):
        z = zeilen[i]
        for name, muster in REGELN:
            if muster.search(z):
                block = [z]
                j = i + 1
                while j < len(zeilen) and zeilen[j].strip() and len(block) < 8:
                    block.append(zeilen[j])
                    if zeilen[j].startswith('.'):
                        break
                    j += 1
                text = ''.join(block)
                if not any(e.search(text) for e in ERLAUBT):
                    yield i + 1, name, ' '.join(b.strip() for b in block)
                break
        i += 1


def main(dateien):
    if not dateien:
        print(__doc__)
        return 2
    fehler = 0
    for pfad in dateien:
        treffer = list(meldungen(pfad))
        fehler += len(treffer)
        print('%-28s %s' % (pfad, 'in Ordnung' if not treffer
                            else '%d Meldungen' % len(treffer)))
        for zeile, name, text in treffer:
            print('    Zeile %d, %s: %s' % (zeile, name, text[:200]))
    return 1 if fehler else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
