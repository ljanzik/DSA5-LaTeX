# bauen.ps1 -- Weiterleitung. Die Logik steht in bauen.py.
#
# Zwei Fassungen desselben Ablaufs zu pflegen ist genau die Sorte Duplikat,
# die dieses Projekt anderswo schon eingeholt hat. Deshalb steht hier nichts
# ausser dem Aufruf: dasselbe Python laeuft unter Windows, macOS und Linux,
# und die Schalter sind ueberall dieselben (-Held dorle, -Alle, ...).
#
# Unter macOS und Linux: ./bau/bauen.sh
#
# Copyright 2026 Leif Janzik. Apache License 2.0.

$ErrorActionPreference = 'Stop'
$py = if (Get-Command python -ErrorAction SilentlyContinue) { 'python' } else { 'python3' }
& $py (Join-Path $PSScriptRoot 'bauen.py') @args
exit $LASTEXITCODE
