#!/bin/sh
# solo-bauen.sh -- Weiterleitung. Die Logik steht in solo-bauen.py.
#
# Zwei Fassungen desselben Ablaufs zu pflegen ist genau die Sorte Duplikat,
# die dieses Projekt anderswo schon eingeholt hat. Deshalb steht hier nichts
# ausser dem Aufruf: dasselbe Python laeuft unter Windows, macOS und Linux,
# und die Schalter sind ueberall dieselben (--bloecke, --aus, --praefix).
#
# Unter Windows: werkzeuge/solo-bauen.ps1
#
# Copyright 2026 Leif Janzik. Apache License 2.0.

exec python3 "$(dirname "$0")/solo-bauen.py" "$@"
