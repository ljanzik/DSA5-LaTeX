# solo-bauen.ps1 -- Weiterleitung. Die Logik steht in solo-bauen.py.
#
# Zwei Fassungen desselben Ablaufs zu pflegen ist genau die Sorte Duplikat,
# die dieses Projekt anderswo schon eingeholt hat. Deshalb steht hier nichts
# ausser dem Aufruf: dasselbe Python laeuft unter Windows, macOS und Linux,
# und die Schalter sind ueberall dieselben (--bloecke, --aus, --praefix).
#
# Unter macOS und Linux: werkzeuge/solo-bauen.sh
#
# Copyright 2026 Leif Janzik. Apache License 2.0.

$ErrorActionPreference = 'Stop'
$py = if (Get-Command python -ErrorAction SilentlyContinue) { 'python' } else { 'python3' }
& $py (Join-Path $PSScriptRoot 'solo-bauen.py') @args
exit $LASTEXITCODE
