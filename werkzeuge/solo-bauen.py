#!/usr/bin/env python3
"""Baut ein Solo-Abenteuer in einem Aufruf: messen, loesen, setzen, pruefen.

Die vier Schritte einzeln zu tippen ist fehleranfaellig, und zwar auf eine
tueckische Art: scheitert der Messlauf, laeuft das Werkzeug gar nicht erst,
der Satzlauf arbeitet mit der alten Zuordnung weiter, und niemand merkt es.
Dieses Skript bricht bei jedem Schritt ab, der nicht durchlaeuft.

  python3 werkzeuge/solo-bauen.py beispiel/solo.tex --bloecke solo-bloecke.tex

Liegt die .tex nicht neben den Bloecken, kommen --aus und --praefix dazu.
--doppelseiten und --rueckhalt steuern die Verteilung. Alle vier werden
unveraendert an solo.py durchgereicht.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import argparse
import os
import shutil
import subprocess
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
SOLO = os.path.join(HIER, 'solo.py')


def gesperrt(pfad):
    """Laesst sich die Datei ueberhaupt schreiben?

    Unter Windows sperrt ein geoeffnetes PDF die Datei; xdvipdfmx meldet
    dann 'Error 1 (driver return code)' und der Lauf bricht ab. Das Tueckische
    daran: .aux und PDF sind danach gemeinsam unvollstaendig, stimmen also
    miteinander ueberein.

    Geprueft wird per Umbenennen. Ein Anhaengen von leerem Inhalt gelingt
    auch bei gesperrten Dateien und taugt deshalb nicht.
    """
    if not os.path.exists(pfad):
        return False
    versuch = pfad + '.sperrtest'
    try:
        os.rename(pfad, versuch)
        os.rename(versuch, pfad)
        return False
    except OSError:
        return True


def lauf(befehl, arbeitsverzeichnis, was):
    # flush: der Pruefschritt schreibt direkt auf die Konsole, die
    # eigenen Meldungen gingen sonst gepuffert hinterher.
    print('  %s ...' % was, flush=True)
    ergebnis = subprocess.run(befehl, cwd=arbeitsverzeichnis,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT)
    if ergebnis.returncode != 0:
        print()
        print('ABBRUCH bei: %s' % was)
        text = ergebnis.stdout.decode('utf-8', 'replace')
        # Aus einem LaTeX-Lauf nur die Fehlerzeilen, sonst alles.
        fehler = [z for z in text.split('\n')
                  if z.startswith('!') or 'Error' in z
                  or 'not found' in z or 'Emergency' in z]
        for z in (fehler or text.split('\n'))[-12:]:
            print('  %s' % z)
        return False
    return True


def main():
    p = argparse.ArgumentParser(
        description='Baut ein Solo-Abenteuer: messen, loesen, setzen, '
                    'pruefen.')
    p.add_argument('dokument', help='die .tex des Solos')
    p.add_argument('--bloecke', required=True,
                   help='die Autorendatei mit allen soloBlock-Umgebungen, '
                        'relativ zum Ordner der .tex')
    p.add_argument('--aus', help='Ausgabeordner, an solo.py durchgereicht')
    p.add_argument('--praefix', help='Pfad wie LaTeX ihn sieht, '
                                     'an solo.py durchgereicht')
    p.add_argument('--doppelseiten', type=int,
                   help='wie viele Doppelseiten ein Behaelter umfassen darf, '
                        'an solo.py durchgereicht. Kleinere Behaelter fuellen '
                        'gleichmaessiger, groessere lassen weniger Grenzen')
    p.add_argument('--rueckhalt', type=int,
                   help='Rastereinheiten Rueckhalt je Doppelseite, an solo.py '
                        'durchgereicht')
    p.add_argument('--laeufe', type=int, default=3,
                   help='Satzlaeufe (Standard 3, wegen Inhalt und Marken)')
    p.add_argument('--klickbar', action='store_true',
                   help='zusaetzlich <name>-klickbar.pdf setzen: derselbe '
                        'Satz mit Sprung von jedem Verweis auf seinen Block')
    args = p.parse_args()

    tex = os.path.abspath(args.dokument)
    if not os.path.exists(tex):
        sys.exit('Nicht gefunden: %s' % args.dokument)
    ordner = os.path.dirname(tex)
    name = os.path.splitext(os.path.basename(tex))[0]

    # Erst gar nicht anfangen, wenn das Ergebnis nicht geschrieben werden
    # kann -- sonst steht am Ende ein halbes Heft, das stimmig aussieht.
    pdf = os.path.join(ordner, name + '.pdf')
    if gesperrt(pdf):
        sys.exit('%s.pdf ist gesperrt -- vermutlich in einem Betrachter\n'
                 'geoeffnet. Schliessen und erneut starten.' % name)

    klickpdf = os.path.join(ordner, name + '-klickbar.pdf')
    if args.klickbar and gesperrt(klickpdf):
        sys.exit('%s-klickbar.pdf ist gesperrt -- vermutlich in einem\n'
                 'Betrachter geoeffnet. Schliessen und erneut starten.'
                 % name)

    klasse = os.path.dirname(HIER)
    umgebung = dict(os.environ)
    umgebung['TEXINPUTS'] = klasse + os.pathsep + umgebung.get('TEXINPUTS', '')

    print('%s bauen' % name, flush=True)

    # 1. Messen. Der Jobname muss stimmen, damit die .solo neben der .tex
    #    landet und \jobname.solonummern spaeter gefunden wird.
    messen = ['xelatex', '-interaction=nonstopmode', '-jobname=' + name,
              '\\PassOptionsToPackage{messen}{dsa5solo}\\input{%s}' % name]
    alt = os.environ.get('TEXINPUTS')
    os.environ['TEXINPUTS'] = umgebung['TEXINPUTS']
    try:
        if not lauf(messen, ordner, 'messen'):
            return 1

        solo = os.path.join(ordner, name + '.solo')
        if not os.path.exists(solo):
            print('ABBRUCH: %s.solo wurde nicht geschrieben.' % name)
            print('  Steht \\soloBloecke im Dokument?')
            return 1

        # 2. Loesen.
        loesen = [sys.executable, SOLO, name + '.solo',
                  '--bloecke', args.bloecke]
        if args.aus:
            loesen += ['--aus', args.aus]
        if args.praefix:
            loesen += ['--praefix', args.praefix]
        if args.doppelseiten is not None:
            loesen += ['--doppelseiten', str(args.doppelseiten)]
        if args.rueckhalt is not None:
            loesen += ['--rueckhalt', str(args.rueckhalt)]
        if not lauf(loesen, ordner, 'loesen'):
            return 1

        # 3. Setzen.
        setzen = ['xelatex', '-interaction=nonstopmode', name + '.tex']
        for i in range(args.laeufe):
            if not lauf(setzen, ordner, 'setzen, Lauf %d' % (i + 1)):
                return 1

        # 4. Die klickbare Fassung: derselbe Satz, nur mit Sprungzielen.
        #    Ein eigener Ausgabeordner und NICHT ein eigener Jobname --
        #    die Nummern stehen in <name>.solonummern, und die liest das
        #    Paket unter \jobname. Mit -jobname=<name>-klickbar suchte es
        #    eine Datei, die es nicht gibt, und saetze alle Verweise als
        #    ??. Eingelesen wird aus dem Arbeitsverzeichnis, geschrieben
        #    in den Ordner: .aux und .log des Druckes bleiben unberuehrt.
        if args.klickbar:
            bau = os.path.join(ordner, name + '-klickbar-bau')
            os.makedirs(bau, exist_ok=True)
            klickbar = ['xelatex', '-interaction=nonstopmode',
                        '-output-directory=' + bau, '-jobname=' + name,
                        '\\PassOptionsToPackage{klickbar}{dsa5solo}'
                        '\\input{%s}' % name]
            for i in range(args.laeufe):
                if not lauf(klickbar, ordner,
                            'klickbar setzen, Lauf %d' % (i + 1)):
                    return 1
            shutil.copyfile(os.path.join(bau, name + '.pdf'), klickpdf)
            print('  %s-klickbar.pdf geschrieben' % name, flush=True)
    finally:
        if alt is None:
            os.environ.pop('TEXINPUTS', None)
        else:
            os.environ['TEXINPUTS'] = alt

    # 4. Pruefen -- die Ausgabe gehoert dem Benutzer, deshalb direkt.
    print(flush=True)
    return subprocess.run([sys.executable, SOLO, '--pruefen',
                           name + '.aux'], cwd=ordner).returncode


if __name__ == '__main__':
    sys.exit(main())
