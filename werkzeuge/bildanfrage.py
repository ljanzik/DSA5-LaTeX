#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fordert ein Gegenstandsbild bei Gemini an.

    python3 werkzeuge/bildanfrage.py "ein aufgerolltes Hanfseil" --ziel grafiken/kletterseil.png
    python3 werkzeuge/bildanfrage.py "..." --ziel x.png --vorlage grafiken/heiltrank-q3.png
    python3 werkzeuge/bildanfrage.py "..." --ziel x.png --modell gemini-3-pro-image
    python3 werkzeuge/bildanfrage.py "..." --ziel x.png --magisch
    python3 werkzeuge/bildanfrage.py "..." --ziel x.png --ohne-stil

Wofuer: Gegenstandskarten brauchen eine Abbildung, und die soll zu den
vorhandenen passen. Deshalb setzt das Werkzeug vor jede Beschreibung einen
festen Stilvorsatz (STIL unten): gemalt, ein einzelner Gegenstand, ruhiger
einfarbiger Hintergrund. Letzteres ist kein Geschmack, sondern die
Voraussetzung fuer werkzeuge/hintergrundfrei.py, das danach freistellt:

    python3 werkzeuge/hintergrundfrei.py grafiken/kletterseil.png --breite 700

Mit --vorlage gehen ein oder mehrere Bilder als Stilreferenz mit. Eine
fertige Karte des Satzes als Vorlage haelt die Reihe einheitlicher als jede
Beschreibung.

Der Schluessel kommt aus der Umgebungsvariable GEMINI_API_KEY und steht nie
in einer Datei. Die Anfrage geht ueber HTTPS an die Gemini-API; das Werkzeug
braucht nur die Standardbibliothek.

Heraus kommt die Datei unter --ziel. Liefert das Modell ein anderes Format
als die Endung verspricht, wird die Endung angepasst und gemeldet.

Copyright 2026 Leif Janzik. Apache License 2.0.
"""

import argparse
import base64
import json
import mimetypes
import os
import sys
import urllib.error
import urllib.request

MODELL = "gemini-3.1-flash-image"
ENDPUNKT = "https://generativelanguage.googleapis.com/v1beta/models/{}:generateContent"

STIL = (
    "Detailed painterly fantasy illustration in the style of a tabletop "
    "role-playing game item card: realistic proportions, soft warm light "
    "from the upper left, fine brushwork, muted natural colours. "
    "Exactly one object, centred, fully visible, not cropped, filling most "
    "of the frame. Plain uniform pure white background, no cast shadow, "
    "no drop shadow, no halo or outline around the object, "
    "no floor, no text, no frame, no border. "
    # Ohne diesen Satz greift das Modell bei Zelt, Decke und Rucksack zu
    # Militaerzeug des 19. Jahrhunderts: Segeltuch, Koppelschnallen, Blechdosen.
    "Setting: a medieval high-fantasy world, roughly 13th to 15th century "
    "Central Europe. Everything is hand-made from natural materials: "
    "hand-woven wool and linen, tanned leather laced with thongs, wood, "
    "horn, hand-forged iron, bronze, copper. Nothing modern and nothing "
    "from the 19th century: no army canvas, no military webbing, no "
    "machine-made buckles, no tin cans, no rivets. "
)

# Faellt mit --magisch weg: ein Seil soll nicht funkeln, ein Zaubertrank darf.
WELTLICH = ("A mundane object: no sparkles, no glitter, no floating particles, "
            "no magic glow. ")

ENDUNGEN = {"image/png": ".png", "image/jpeg": ".jpg", "image/webp": ".webp"}


def vorlage_teil(pfad):
    art = mimetypes.guess_type(pfad)[0] or "image/png"
    with open(pfad, "rb") as f:
        daten = base64.b64encode(f.read()).decode("ascii")
    return {"inlineData": {"mimeType": art, "data": daten}}


def anfragen(schluessel, modell, text, vorlagen, format_):
    teile = [vorlage_teil(p) for p in vorlagen]
    if vorlagen:
        text = ("Match the painting style of the attached reference "
                "image(s), but depict a different object. " + text)
    teile.append({"text": text})
    koerper = {
        "contents": [{"parts": teile}],
        "generationConfig": {
            "responseModalities": ["IMAGE"],
            "imageConfig": {"aspectRatio": format_},
        },
    }
    anfrage = urllib.request.Request(
        ENDPUNKT.format(modell),
        data=json.dumps(koerper).encode("utf-8"),
        headers={"Content-Type": "application/json",
                 "x-goog-api-key": schluessel},
    )
    try:
        with urllib.request.urlopen(anfrage, timeout=180) as antwort:
            return json.load(antwort)
    except urllib.error.HTTPError as e:
        sys.exit("Gemini antwortet mit {}: {}".format(
            e.code, e.read().decode("utf-8", "replace")[:800]))


def bild_aus(antwort):
    for kandidat in antwort.get("candidates", []):
        for teil in kandidat.get("content", {}).get("parts", []):
            if "inlineData" in teil:
                return teil["inlineData"]
    grund = [k.get("finishReason") for k in antwort.get("candidates", [])]
    sys.exit("Kein Bild in der Antwort. finishReason: {}; promptFeedback: {}"
             .format(grund, antwort.get("promptFeedback")))


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("beschreibung", help="was zu sehen sein soll, am besten englisch")
    p.add_argument("--ziel", required=True, help="Ausgabedatei")
    p.add_argument("--vorlage", action="append", default=[],
                   help="Stilreferenz, mehrfach erlaubt")
    p.add_argument("--modell", default=MODELL)
    p.add_argument("--format", default="3:4", help="Seitenverhaeltnis, Vorgabe 3:4")
    p.add_argument("--magisch", action="store_true",
                   help="Funkeln und Leuchten erlauben (Traenke, Artefakte)")
    p.add_argument("--ohne-stil", action="store_true",
                   help="Beschreibung ohne Stilvorsatz senden")
    a = p.parse_args()

    schluessel = os.environ.get("GEMINI_API_KEY")
    if not schluessel:
        sys.exit("GEMINI_API_KEY ist nicht gesetzt.")

    if a.ohne_stil:
        text = a.beschreibung
    else:
        text = STIL + ("" if a.magisch else WELTLICH) + "Object: " + a.beschreibung
    daten = bild_aus(anfragen(schluessel, a.modell, text, a.vorlage, a.format))

    ziel = a.ziel
    endung = ENDUNGEN.get(daten.get("mimeType"))
    if endung and os.path.splitext(ziel)[1].lower() != endung:
        ziel = os.path.splitext(ziel)[0] + endung
        print("Modell liefert {}, gespeichert als {}".format(daten["mimeType"], ziel))
    os.makedirs(os.path.dirname(os.path.abspath(ziel)), exist_ok=True)
    with open(ziel, "wb") as f:
        f.write(base64.b64decode(daten["data"]))
    print(ziel)


if __name__ == "__main__":
    main()
