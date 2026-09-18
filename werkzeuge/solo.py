#!/usr/bin/env python3
"""Verteilt die Bloecke eines Solo-Abenteuers auf Doppelseiten und vergibt
die Nummern.

Ein Solo besteht aus nummerierten Bloecken mit Verweisen. Drei Dinge muss
dieses Werkzeug leisten:

  1. die Nummern vergeben, lueckenlos und eindeutig,
  2. die Verweise aufloesen, und
  3. dafuer sorgen, dass Quelle und Ziel eines Sprungs nie auf derselben
     Doppelseite stehen -- sonst liest man beides und die Entscheidung ist
     entwertet.

Punkt 3 ist zirkulaer: wo ein Block steht, folgt aus seiner Nummer, und ob
die Bedingung haelt, folgt daraus, wo er steht. Aufgeloest wird das ueber
BEHAELTER, und ein Behaelter ist genau eine Doppelseite. Die Nummern werden
behaelterweise aufsteigend vergeben, an jeder Behaeltergrenze steht ein
erzwungener Umbruch (\\soloBehaelterEnde). Damit wird aus der
Sichtbarkeitsbedingung eine reine Graphbedingung:

    fuer jede Sprungkante (a -> b):  Behaelter(a) != Behaelter(b)

Das ist Graphfaerbung ueber einem Behaelterpacken. Der Sprunggraph eines
Solos ist duenn -- Ausgangsgrad zwei bis vier --, also braucht die Faerbung
wenige Farben, und weil ein Behaelter Teilmenge einer Farbklasse bleibt,
ist die Bedingung nach dem Packen automatisch erfuellt.

Der Grund, warum das ohne Nachbau des Seitenbauers von TeX auskommt: ein
Messfehler kostet Papier, nicht Richtigkeit. Laeuft ein Behaelter ueber,
belegt er zwei Doppelseiten -- aber jeder Sprung aus ihm heraus fuehrt per
Konstruktion in einen anderen Behaelter auf einer dritten Doppelseite.
Bleibt er zu leer, entsteht eine Fuellseite.

Aufrufe:

  python3 werkzeuge/solo.py beispiel/solo.solo \\
      --bloecke beispiel/solo-bloecke.tex --aus beispiel/solo-aus

  python3 werkzeuge/solo.py --pruefen beispiel/solo.aux

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import argparse
import collections
import os
import random
import re
import sys

# Rueckhalt auf jede Doppelseite: an den drei inneren Spaltengrenzen
# bleiben unter \raggedbottom Einheiten liegen, weil \nobreak nach dem
# Blockkopf sowie Widow- und Clubpenalty den Bruch vorziehen. Gemessen ein
# bis drei Einheiten je Grenze; acht ist die vorsichtige Summe.
RUECKHALT = 8

MARKE = re.compile(r'^[A-Za-z0-9][A-Za-z0-9-]*$')


# ---------------------------------------------------------------- einlesen

def solo_lesen(pfad):
    """Liest die Messdatei \\jobname.solo."""
    hoehe, ziele, reihe, start = {}, {}, [], None
    ende = set()
    spalte, spalten = None, None
    with open(pfad, encoding='utf-8') as f:
        text = f.read()

    m = re.search(r'\\solomass\{(\d+)\}\{(\d+)\}', text)
    if m:
        spalte, spalten = int(m.group(1)), int(m.group(2))

    m = re.search(r'\\solostart\{([^}]*)\}', text)
    if m:
        start = m.group(1).strip()

    doppelt = []
    for m in re.finditer(r'\\soloblock\{([^}]*)\}\{(\d+)\}\{([^}]*)\}', text):
        marke = m.group(1).strip()
        # Zwei Bloecke unter derselben Marke sind immer ein Autorenfehler,
        # und ein stiller dazu: der zweite ueberschriebe den ersten, der
        # Block verschwaende aus dem Heft, und der Verweis darauf zeigte
        # auf den falschen Text. Deshalb wird das gemeldet und nicht
        # geheilt.
        if marke in hoehe:
            doppelt.append(marke)
        hoehe[marke] = int(m.group(2))
        roh = m.group(3).split()
        if '*ende*' in roh:
            ende.add(marke)
        z = [t for t in roh if t and t != '*ende*']
        # Reihenfolge erhalten, aber jedes Ziel nur einmal.
        gesehen, sauber = set(), []
        for t in z:
            if t not in gesehen:
                gesehen.add(t)
                sauber.append(t)
        ziele[marke] = sauber
        reihe.append(marke)

    return hoehe, ziele, reihe, start, ende, doppelt, spalte, spalten


def bloecke_teilen(quelle, ausordner):
    """Teilt die Autorendatei bytegetreu in eine Datei je Block.

    Bytegetreu ist der Punkt: LaTeX liest danach dieselben Bytes wie aus
    der Originaldatei, also verhalten sich \\verb, %-Kommentare, "a, & und
    # exakt wie dort. Ein Sammeln als Makroargument wuerde die Katcodes
    einfrieren und genau das kaputtmachen.

    Jede Blockdatei bekommt so viele reine Kommentarzeilen vorangestellt,
    wie ihr Block in der Quelle weit unten anfaengt. Dann meldet LaTeX
    'l.132' und Zeile 132 ist Zeile 132 in der Quelldatei -- der einzige
    echte Nachteil des Teilens ist damit erledigt.
    """
    with open(quelle, encoding='utf-8') as f:
        zeilen = f.readlines()

    anfang = re.compile(r'\\begin\{soloBlock\}\{([^}]*)\}')
    ende = re.compile(r'\\end\{soloBlock\}')

    os.makedirs(ausordner, exist_ok=True)
    gefunden, offen, marke, von = [], False, None, 0
    quellname = os.path.basename(quelle)

    for i, zeile in enumerate(zeilen):
        if not offen:
            m = anfang.search(zeile)
            if m:
                offen, marke, von = True, m.group(1).strip(), i
        elif ende.search(zeile):
            ziel = os.path.join(ausordner, marke + '.tex')
            with open(ziel, 'w', encoding='utf-8') as f:
                f.write('%% aus %s, erzeugt von werkzeuge/solo.py\n'
                        % quellname)
                # -1 fuer die eben geschriebene Zeile.
                f.write('%\n' * (von - 1))
                f.writelines(zeilen[von:i + 1])
            gefunden.append(marke)
            offen = False

    return gefunden


# ------------------------------------------------------------------ loesen

def faerben(knoten, nachbarn):
    """DSATUR: faerbt den Sprunggraphen.

    Farbklassen sind unabhaengige Mengen -- keine zwei benachbarten
    Bloecke teilen eine Farbe. Weil ein Behaelter spaeter Teilmenge einer
    Farbklasse bleibt, ist die Seitenbedingung damit schon erledigt.
    """
    farbe = {}
    offen = set(knoten)
    while offen:
        # Hoechste Saettigung, bei Gleichstand hoechster Grad.
        def schluessel(k):
            saettigung = len({farbe[n] for n in nachbarn[k] if n in farbe})
            return (saettigung, len(nachbarn[k]))

        k = max(sorted(offen), key=schluessel)
        belegt = {farbe[n] for n in nachbarn[k] if n in farbe}
        f = 0
        while f in belegt:
            f += 1
        farbe[k] = f
        offen.discard(k)
    return farbe


def rueckhalt(belegt, anzahl, grenzen=3):
    """Was an den inneren Spaltengrenzen einer Doppelseite liegen bleibt.

    Am Satz gemessen: der Ueberlauf waechst mit der ZAHL der Bloecke, nicht
    mit ihrer Gesamthoehe. Behaelter mit fuenf und mit elf Bloecken passten
    auf ihre zwei Seiten, die mit 27, 32, 50 und 55 Bloecken brauchten eine
    dritte -- bei nahezu gleicher Summe von 226 bis 228 Einheiten.

    Der Grund steht im Kopf des Pakets: \\nobreak nach der Zahl und
    \\clubpenalty fuer die ersten Zeilen halten den Block zusammen. Was an
    einer Spaltengrenze nicht mehr ganz hinpasst, rutscht vollstaendig in
    die naechste Spalte und laesst seinen Platz leer. Der erwartete
    Verlust je Grenze ist also etwa eine mittlere Blockhoehe, und eine
    Doppelseite hat drei innere Grenzen.
    """
    if anzahl <= 0:
        return 0
    return grenzen * belegt // anzahl


def packen(marken, hoehe, gesamt, mindestrueckhalt):
    """First-Fit-Decreasing innerhalb einer Farbklasse."""
    behaelter = []
    for m in sorted(marken, key=lambda x: (-hoehe.get(x, 1), x)):
        h = hoehe.get(m, 1)
        for b in behaelter:
            if passt(b, h, hoehe, gesamt, mindestrueckhalt):
                b.append(m)
                break
        else:
            behaelter.append([m])
    return behaelter


def passt(b, h, hoehe, gesamt, mindestrueckhalt):
    """Passt ein Block der Hoehe h noch in den Behaelter b?"""
    belegt = sum(hoehe.get(x, 1) for x in b) + h
    r = max(mindestrueckhalt, rueckhalt(belegt, len(b) + 1))
    return belegt + r <= gesamt


def nachbessern(behaelter, hoehe, nachbarn, gesamt, mindestrueckhalt):
    """Loest zu leere Behaelter auf und verteilt ihre Bloecke.

    Noetig, weil beim Packen jede Farbklasse fuer sich behandelt wird und
    dabei einen Rest hinterlaesst. Diese Reste sind es, die im Satz als
    halb leere Doppelseiten auffallen: ein Behaelter mit 96 von 236
    Einheiten belegt nur eine Seite, und die Paritaetskorrektur setzt eine
    Fuellseite daneben.

    Verschoben wird nur, wo kein Nachbar aus dem Sprunggraphen im
    Zielbehaelter liegt -- die Seitenregel bleibt also unangetastet.
    """
    geaendert = True
    while geaendert:
        geaendert = False
        # Den leersten zuerst: er laesst sich am ehesten ganz aufloesen.
        for i in sorted(range(len(behaelter)),
                        key=lambda k: sum(hoehe.get(x, 1)
                                          for x in behaelter[k])):
            quelle = behaelter[i]
            if not quelle:
                continue
            plan = {}
            for m in quelle:
                for j, ziel in enumerate(behaelter):
                    if j == i or not ziel:
                        continue
                    if nachbarn[m] & set(ziel):
                        continue
                    # Was in diesem Durchgang schon zugesagt wurde, zaehlt
                    # mit, sonst wird derselbe Platz zweimal vergeben.
                    belegt = [x for x in ziel]
                    belegt += [x for x, k in plan.items() if k == j]
                    if passt(belegt, hoehe.get(m, 1), hoehe, gesamt,
                             mindestrueckhalt):
                        plan[m] = j
                        break
                else:
                    break
            if len(plan) == len(quelle):
                for m, j in plan.items():
                    behaelter[j].append(m)
                behaelter[i] = []
                geaendert = True
                break
    return [b for b in behaelter if b]


def loesen(hoehe, ziele, start, gesamt, mindestrueckhalt,
           seed=20260918):
    """Verteilt die Bloecke auf Behaelter und vergibt die Nummern."""
    knoten = list(hoehe.keys())
    nachbarn = {k: set() for k in knoten}
    for a, zs in ziele.items():
        for b in zs:
            if b in nachbarn and a in nachbarn and a != b:
                nachbarn[a].add(b)
                nachbarn[b].add(a)

    farbe = faerben(knoten, nachbarn)
    klassen = {}
    for k, f in farbe.items():
        klassen.setdefault(f, []).append(k)

    behaelter = []
    for f in sorted(klassen):
        behaelter.extend(packen(klassen[f], hoehe, gesamt,
                                mindestrueckhalt))
    behaelter = nachbessern(behaelter, hoehe, nachbarn, gesamt,
                            mindestrueckhalt)

    # Der Startblock steht immer am Anfang und traegt immer die 1: sein
    # Behaelter nach vorn, und er darin an die erste Stelle.
    rand = random.Random(seed)
    for b in behaelter:
        rand.shuffle(b)
    if start:
        for i, b in enumerate(behaelter):
            if start in b:
                b.remove(start)
                b.insert(0, start)
                behaelter.insert(0, behaelter.pop(i))
                break

    nummer, n = {}, 0
    for b in behaelter:
        for m in b:
            n += 1
            nummer[m] = n
    return behaelter, nummer, nachbarn


# ------------------------------------------------------------------- graph

def erreichbar(von, kanten):
    """Alle Knoten, die von einer Startmenge aus erreichbar sind."""
    gesehen, rand = set(von), list(von)
    while rand:
        k = rand.pop()
        for z in kanten.get(k, ()):  # noqa: E501
            if z not in gesehen:
                gesehen.add(z)
                rand.append(z)
    return gesehen


def graph_pruefen(hoehe, ziele, start, ende):
    """Haengt der Sprunggraph zusammen?

    Drei Fragen, und nur die erste ist offensichtlich:

    1. Kommt man vom Start ueberall hin? Ein Block, den niemand erreicht,
       ist gedrucktes Papier, das nie gelesen wird.
    2. Kommt man von ueberall zu einem Ende? Sonst gibt es Blockgruppen,
       in denen der Leser ewig im Kreis laeuft -- eine Falle, die keine
       sein soll. Das faellt beim Lesen nicht auf, weil jeder einzelne
       Block einen Ausgang hat.
    3. Zeigt ueberhaupt jemand auf den Block? Der Startblock darf als
       einziger ohne eingehenden Verweis dastehen.
    """
    knoten = set(hoehe)
    vorwaerts = {k: [z for z in ziele.get(k, ()) if z in knoten]
                 for k in knoten}
    rueckwaerts = {k: [] for k in knoten}
    for a, zs in vorwaerts.items():
        for b in zs:
            rueckwaerts[b].append(a)

    erreicht = erreichbar([start] if start in knoten else [], vorwaerts)

    # Ein Ende ist, was sich als Ende ausweist oder keinen Ausgang hat.
    endknoten = set(ende) | {k for k in knoten if not vorwaerts[k]}
    findet_ende = erreichbar(endknoten, rueckwaerts)

    eingehend = collections.Counter()
    for a, zs in vorwaerts.items():
        for b in zs:
            eingehend[b] += 1

    return {
        'knoten': len(knoten),
        'kanten': sum(len(z) for z in vorwaerts.values()),
        'unerreichbar': sorted(knoten - erreicht),
        'ohne_ausgang': sorted(knoten - findet_ende),
        'ohne_zugang': sorted(k for k in knoten
                              if eingehend[k] == 0 and k != start),
        'enden': len(endknoten),
    }


# ------------------------------------------------------------------ pruefen

def doppelseite(seite):
    """Doppelseite k umfasst die Seiten 2k und 2k+1 -- links gerade,
    rechts ungerade (2|3, 4|5)."""
    return seite // 2


def aux_pruefen(pfad):
    with open(pfad, encoding='utf-8', errors='replace') as f:
        text = f.read()

    kopf = {}
    for m in re.finditer(r'\\newlabel\{solo:([^}]*)\}\{\{[^}]*\}\{(\d+)\}',
                         text):
        kopf[m.group(1)] = int(m.group(2))

    verstoss, geprueft = [], 0
    for m in re.finditer(
            r'\\soloSprungLage\{([^}]*)\}\{([^}]*)\}\{(\d+)\}', text):
        quelle, ziel, seite = m.group(1), m.group(2), int(m.group(3))
        if ziel not in kopf:
            continue
        geprueft += 1
        if doppelseite(seite) == doppelseite(kopf[ziel]):
            verstoss.append((quelle, ziel, seite, kopf[ziel]))
    return kopf, geprueft, verstoss


def leere_bloecke(auxpfad):
    """Nummern der Bloecke, die ausser ihrer Zahl nichts enthalten.

    Sie sind fuer die Kopfregel auszunehmen: unter einer Zahl, deren Block
    leer ist, KANN nichts stehen. Gebraucht werden dafuer die
    Nummernzuordnung und die gemessenen Hoehen, beide neben der .aux.
    """
    stamm = os.path.splitext(auxpfad)[0]
    try:
        nummern = open(stamm + '.solonummern', encoding='utf-8').read()
        messung = open(stamm + '.solo', encoding='utf-8').read()
    except IOError:
        return set()

    hoehe = {m.group(1): int(m.group(2)) for m in
             re.finditer(r'\\soloblock\{([^}]*)\}\{(\d+)\}', messung)}
    leer = set()
    for m in re.finditer(r'\\soloNummer\{([^}]*)\}\{(\d+)\}', nummern):
        # Hoehe 1 heisst: nur die Zeile mit der Zahl, kein Text darunter.
        if hoehe.get(m.group(1), 99) <= 1:
            leer.add(m.group(2))
    return leer


def koepfe_pruefen(pdfdatei, leer=frozenset()):
    """Prueft am gesetzten PDF: steht unter jeder Blockzahl noch Text?

    Die Zahl darf nie die letzte Zeile ihrer Spalte sein -- sonst stuende
    sie auf der einen Seite und ihr Block begaenne erst auf der naechsten.
    Im Satz sorgen \\nobreak und \\@afterheading dafuer; hier wird es am
    Ergebnis nachgesehen, nicht am Quelltext geglaubt.

    Ist die Hoehe der Bloecke bekannt, wird zusaetzlich der Schusterjunge
    gemeldet: eine einzelne Zeile bei der Zahl, obwohl der Block laenger
    ist. Bloecke, die selbst nur eine Zeile haben, sind dabei in Ordnung.
    """
    try:
        import pdfplumber
    except ImportError:
        return None, ['pdfplumber fehlt. Nachinstallieren mit: '
                      'python3 -m pip install pdfplumber']

    import collections
    mm = 25.4 / 72.0
    gefunden, verstoss = 0, []

    with pdfplumber.open(pdfdatei) as pdf:
        for nr, seite in enumerate(pdf.pages, start=1):
            # Nach Grundlinie UND Spalte gruppieren. Nur nach der
            # Grundlinie zu gruppieren wirft beide Spalten zusammen,
            # sobald ihre Zeilen auf gleicher Hoehe sitzen -- und im
            # Raster tun sie das immer.
            mitte = seite.width / 2.0
            zeilen = collections.defaultdict(list)
            for z in seite.chars:
                sp = 0 if z['x0'] < mitte else 1
                zeilen[(round(z['matrix'][5], 2), sp)].append(z)

            eintraege = []
            for (gl, sp), zs in zeilen.items():
                zs.sort(key=lambda c: c['x0'])
                txt = ''.join(c['text'] for c in zs).strip()
                # Die Blockzahl aus IHREN eigenen Zeichen lesen, nicht aus
                # der ganzen Zeile: microtype schiebt ein oeffnendes
                # Anfuehrungszeichen der Nachbarspalte per Randausgleich
                # ueber die Blattmitte, es landet in dieser Zeile und eine
                # Pruefung auf die ganze Zeile scheitert daran. Genau so
                # ist hier eine von 239 Zahlen durchgerutscht.
                zahl = ''.join(c['text'] for c in zs
                               if 'Bold' in c['fontname']
                               and round(c['size'], 1) == 13.0)
                eintraege.append((gl, sp, txt, zahl))

            for gl, sp, txt, zahl in eintraege:
                if not re.fullmatch(r'\d{1,3}', zahl):
                    continue
                # Die Seitenzahl in der Fusszeile ist keine Blockzahl.
                if gl * mm < 15:
                    continue
                gefunden += 1
                darunter = [e for e in eintraege
                            if e[1] == sp and e[0] < gl - 1
                            and e[0] * mm > 15 and e[2]]
                if not darunter and zahl not in leer:
                    verstoss.append('Seite %d, Spalte %d: die Zahl %s ist '
                                    'die letzte Zeile ihrer Spalte'
                                    % (nr, sp + 1, zahl))
    return gefunden, verstoss


# --------------------------------------------------------------- schreiben

def schreiben(behaelter, nummer, ausordner, nummerndatei, praefix):
    reihenfolge = os.path.join(ausordner, 'reihenfolge.tex')
    with open(reihenfolge, 'w', encoding='utf-8') as f:
        f.write('%% erzeugt von werkzeuge/solo.py -- nicht von Hand '
                'aendern.\n')
        f.write('%% Ein Behaelter ist eine Doppelseite.\n')
        # Auch VOR dem ersten Behaelter eine Grenze: die Einleitung
        # verweist auf den Startblock, und laege sie auf derselben
        # Doppelseite, waere die Regel schon beim ersten Sprung verletzt.
        # Am Satz nachgewiesen -- ohne diese Zeile meldet --pruefen genau
        # einen Verstoss, und zwar diesen.
        f.write('\\soloBehaelterEnde\n')
        for i, b in enumerate(behaelter):
            f.write('%%%% Behaelter %d\n' % (i + 1))
            for m in b:
                f.write('\\input{%s/%s}\n' % (praefix, m))
            if i + 1 < len(behaelter):
                f.write('\\soloBehaelterEnde\n')

    stellen = len(str(max(nummer.values()))) if nummer else 1
    with open(nummerndatei, 'w', encoding='utf-8') as f:
        f.write('%% erzeugt von werkzeuge/solo.py\n')
        f.write('\\soloStellen{%d}\n' % stellen)
        for m in sorted(nummer, key=lambda x: nummer[x]):
            f.write('\\soloNummer{%s}{%d}\n' % (m, nummer[m]))
    return reihenfolge, stellen


# -------------------------------------------------------------------- main

def main():
    p = argparse.ArgumentParser(
        description='Verteilt die Bloecke eines Solo-Abenteuers auf '
                    'Doppelseiten und vergibt die Nummern.')
    p.add_argument('solo', nargs='?',
                   help='die Messdatei, etwa beispiel/solo.solo')
    p.add_argument('--bloecke',
                   help='die Autorendatei mit allen soloBlock-Umgebungen')
    p.add_argument('--aus',
                   help='Ausgabeordner, Standard <ordner der solo>/solo-aus')
    p.add_argument('--praefix',
                   help='Pfad des Ausgabeordners, wie ihn LaTeX beim Bau '
                        'sieht (Standard: der Ordnername selbst). Noetig, '
                        'wenn die Bloecke nicht neben der .tex liegen; '
                        'muss dann zu \\soloOrdner passen')
    p.add_argument('--rueckhalt', type=int, default=RUECKHALT,
                   help='Rastereinheiten Rueckhalt je Doppelseite '
                        '(Standard %d)' % RUECKHALT)
    p.add_argument('--pruefen', metavar='AUX',
                   help='prueft die Doppelseitenregel an einer .aux')
    args = p.parse_args()

    if args.pruefen:
        if not os.path.exists(args.pruefen):
            sys.exit('Datei nicht gefunden: %s' % args.pruefen)
        kopf, geprueft, verstoss = aux_pruefen(args.pruefen)
        print('Bloecke mit Marke   : %d' % len(kopf))
        print('Sprungstellen       : %d' % geprueft)
        if not kopf:
            print()
            print('KEINE MARKEN GEFUNDEN. Wurde das Dokument mit '
                  'dsa5solo gesetzt und danach noch einmal gebaut?')
            return 1
        if verstoss:
            print()
            print('DOPPELSEITENREGEL VERLETZT (%d):' % len(verstoss))
            for q, z, sv, sk in verstoss:
                print('  %-24s -> %-24s Verweis S.%-4d Ziel S.%-4d '
                      '(Doppelseite %d)'
                      % (q, z, sv, sk, doppelseite(sv)))
            print()
            print('Der Satz weicht von der berechneten Aufteilung ab. '
                  'Messlauf und werkzeuge/solo.py erneut laufen lassen.')
            return 1
        print()
        print('Kein Sprung bleibt auf seiner Doppelseite.')

        # Liegt das gesetzte PDF daneben, gleich auch die Kopfregel am
        # Ergebnis nachsehen: eine Zahl darf nie die letzte Zeile ihrer
        # Spalte sein.
        pdfdatei = os.path.splitext(args.pruefen)[0] + '.pdf'
        if os.path.exists(pdfdatei):
            gefunden, kopfverstoss = koepfe_pruefen(
                pdfdatei, leere_bloecke(args.pruefen))
            if gefunden is None:
                print()
                for z in kopfverstoss:
                    print(z)
            else:
                print('Blockzahlen im PDF  : %d' % gefunden)
                # Stimmen .aux und PDF nicht ueberein, ist einer von beiden
                # veraltet -- unter Windows etwa, wenn das PDF im
                # Betrachter offen war und xdvipdfmx es nicht schreiben
                # konnte. Ohne diese Pruefung meldete das Werkzeug "alles
                # in Ordnung", obwohl es eine abgebrochene .aux mit einem
                # alten PDF verglich.
                if gefunden != len(kopf):
                    print()
                    print('AUX UND PDF PASSEN NICHT ZUSAMMEN: %d Marken in '
                          'der .aux, aber %d Blockzahlen im PDF.'
                          % (len(kopf), gefunden))
                    print('Einer der beiden Staende ist veraltet. War das '
                          'PDF beim Bauen in einem Betrachter geoeffnet? '
                          'Schliessen und erneut setzen.')
                    return 1
                if kopfverstoss:
                    print()
                    print('ZAHL OHNE BLOCK (%d):' % len(kopfverstoss))
                    for z in kopfverstoss:
                        print('  %s' % z)
                    print()
                    print('Die Zahl steht am Spaltenfuss und ihr Block '
                          'beginnt erst in der naechsten Spalte.')
                    return 1
                print()
                print('Alles in Ordnung: kein Sprung bleibt auf seiner '
                      'Doppelseite, und unter jeder Zahl steht ihr Block.')
                return 0
        print()
        print('Das gesetzte PDF liegt nicht daneben, die Kopfregel wurde '
              'nicht geprueft.')
        return 0

    if not args.solo:
        p.error('ohne --pruefen wird die Messdatei gebraucht')
    if not os.path.exists(args.solo):
        sys.exit('Messdatei nicht gefunden: %s\n'
                 'Erst den Messlauf machen: xelatex mit '
                 '\\usepackage[messen]{dsa5solo}' % args.solo)

    hoehe, ziele, reihe, start, ende, doppelt, spalte, spalten = solo_lesen(
        args.solo)
    if not hoehe:
        sys.exit('Die Messdatei enthaelt keinen Block.')
    if spalte is None:
        sys.exit('Die Messdatei nennt kein Satzspiegelmass (\\solomass).')

    gesamt = spalte * spalten

    if doppelt:
        print('MARKE DOPPELT VERGEBEN (%d):' % len(doppelt))
        for m in sorted(set(doppelt)):
            print('  %s' % m)
        print()
        print('Jede Marke darf nur einmal vorkommen. Sonst faellt einer '
              'der beiden Bloecke aus dem Heft und die Verweise darauf '
              'zeigen auf den falschen Text.')
        return 1

    fehler = [m for m in hoehe if not MARKE.match(m)]
    if fehler:
        print('UNGUELTIGE MARKEN (%d), erlaubt sind A-Z a-z 0-9 und '
              'Bindestrich:' % len(fehler))
        for m in fehler:
            print('  %s' % m)
        return 1

    ausordner = args.aus or os.path.join(
        os.path.dirname(args.solo) or '.', 'solo-aus')

    behaelter, nummer, nachbarn = loesen(hoehe, ziele, start, gesamt,
                                         args.rueckhalt)

    geteilt = []
    if args.bloecke:
        if not os.path.exists(args.bloecke):
            sys.exit('Autorendatei nicht gefunden: %s' % args.bloecke)
        geteilt = bloecke_teilen(args.bloecke, ausordner)
    else:
        os.makedirs(ausordner, exist_ok=True)

    nummerndatei = os.path.splitext(args.solo)[0] + '.solonummern'
    praefix = args.praefix or os.path.basename(ausordner.rstrip('/\\'))
    reihenfolge, stellen = schreiben(behaelter, nummer, ausordner,
                                     nummerndatei, praefix)

    belegung = [sum(hoehe.get(m, 1) for m in b) for b in behaelter]
    print('Bloecke             : %d' % len(hoehe))
    print('Doppelseiten        : %d  (%d Rastereinheiten je Doppelseite, '
          'Rueckhalt mindestens %d)'
          % (len(behaelter), gesamt, args.rueckhalt))
    print('Fuellung            : %d bis %d, im Mittel %d'
          % (min(belegung), max(belegung), sum(belegung) // len(belegung)))
    print('Nummern             : 1 bis %d, %d Stellen'
          % (len(nummer), stellen))
    if start:
        print('Startblock          : %s, Nummer %d'
              % (start, nummer.get(start, 0)))
    if geteilt:
        print('Blockdateien        : %d in %s' % (len(geteilt), ausordner))
    print('Reihenfolge         : %s' % reihenfolge)
    print('Nummern             : %s' % nummerndatei)

    # ---- Warnungen, die den Lauf nicht scheitern lassen

    zu_gross = [m for m in hoehe if hoehe[m] > gesamt]
    if zu_gross:
        print()
        print('BLOCK GROESSER ALS EINE DOPPELSEITE (%d):' % len(zu_gross))
        for m in zu_gross:
            print('  %-24s %d von %d Rastereinheiten'
                  % (m, hoehe[m], gesamt))
        print('  Er belegt zwei Doppelseiten. Die Regel haelt trotzdem, '
              'weil seine Ziele in anderen Behaeltern liegen.')

    # Hoehe 1 heisst: nur die Zeile mit der Zahl. Im Satz steht die Zahl
    # dann allein da, und das sieht wie ein abgetrennter Kopf aus.
    leer = sorted(m for m in hoehe if hoehe[m] <= 1)
    if leer:
        print()
        print('BLOCK OHNE TEXT (%d):' % len(leer))
        for m in leer:
            print('  %s' % m)
        print('  Im Satz steht dort nur die Zahl.')

    unbekannt = sorted({z for zs in ziele.values() for z in zs
                        if z not in hoehe})
    if unbekannt:
        print()
        print('VERWEIS AUF UNBEKANNTE MARKE (%d):' % len(unbekannt))
        for m in unbekannt:
            print('  %s' % m)

    g = graph_pruefen(hoehe, ziele, start, ende)
    print()
    print('Sprunggraph         : %d Bloecke, %d Kanten, %d Enden'
          % (g['knoten'], g['kanten'], g['enden']))
    if not (g['unerreichbar'] or g['ohne_ausgang'] or g['ohne_zugang']):
        print('                      haengt vollstaendig zusammen')

    def liste(ueberschrift, marken, nachsatz):
        if not marken:
            return
        print()
        print('%s (%d):' % (ueberschrift, len(marken)))
        for m in marken[:30]:
            print('  %s' % m)
        if len(marken) > 30:
            print('  ... und %d weitere' % (len(marken) - 30))
        print('  %s' % nachsatz)

    liste('VOM START NICHT ERREICHBAR', g['unerreichbar'],
          'Diese Bloecke werden gedruckt, aber nie gelesen.')
    liste('OHNE WEG ZU EINEM ENDE', g['ohne_ausgang'],
          'Von hier aus laeuft der Leser im Kreis: jeder einzelne Block '
          'hat einen Ausgang, die Gruppe als ganze aber nicht.')
    liste('OHNE EINGEHENDEN VERWEIS', g['ohne_zugang'],
          'Auf diese Bloecke zeigt kein Verweis. Nur der Startblock darf '
          'das.')

    # Ein Block ohne ausgehenden Verweis ist nur dann ein Fehler, wenn er
    # sich nicht selbst mit \soloEnde als Ende ausgewiesen hat.
    sackgasse = sorted(m for m in hoehe
                       if not ziele.get(m) and m not in ende)
    if sackgasse:
        print()
        print('SACKGASSE, ohne \\soloEnde (%d):' % len(sackgasse))
        for m in sackgasse:
            print('  %s' % m)

    print()
    print('Weiter mit: xelatex (dreimal), dann '
          'python3 werkzeuge/solo.py --pruefen <datei>.aux')
    return 0


if __name__ == '__main__':
    sys.exit(main())
