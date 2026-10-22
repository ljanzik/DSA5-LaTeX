# felder-pruefen.ps1 -- Weiterleitung. Die Logik steht in felder-pruefen.py.
#
# Zwei Fassungen desselben Ablaufs zu pflegen ist genau die Sorte Duplikat,
# die dieses Projekt anderswo schon eingeholt hat. Deshalb steht hier nichts
# ausser dem Aufruf: dasselbe Python laeuft unter Windows, macOS und Linux,
# und die Schalter sind ueberall dieselben (-Held dorle, -Alle, ...).
#
# Unter macOS und Linux: ./bau/felder-pruefen.sh
#
# Copyright 2026 Leif Janzik. Apache License 2.0.

$ErrorActionPreference = 'Stop'
$py = if (Get-Command python -ErrorAction SilentlyContinue) { 'python' } else { 'python3' }
& $py (Join-Path $PSScriptRoot 'felder-pruefen.py') @args
exit $LASTEXITCODE
