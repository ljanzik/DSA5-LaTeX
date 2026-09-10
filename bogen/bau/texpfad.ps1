# texpfad.ps1 — TeX Live in den PATH holen.
# TeX Live liegt hier unter %USERPROFILE%\texlive\current und ist nicht
# zwingend im PATH der aufrufenden Shell. Ghostscript bringt TeX Live selbst
# mit (tlpkg\tlgs) — es muss nichts zusaetzlich installiert werden.
#
# NICHT eine zweite TeX-Distribution daneben installieren. Zwei streiten um
# PATH und Formatdateien, und der Fehler sieht dann wie ein LaTeX-Fehler aus.

$texwurzel = Join-Path $env:USERPROFILE 'texlive\current'
$texbin    = Join-Path $texwurzel 'bin\windows'
$gsbin     = Join-Path $texwurzel 'tlpkg\tlgs\bin'

if (Test-Path (Join-Path $texbin 'pdflatex.exe')) { $env:PATH = "$texbin;$env:PATH" }
if (Test-Path (Join-Path $gsbin  'gswin64c.exe')) { $env:PATH = "$gsbin;$env:PATH" }

if (-not (Get-Command pdflatex -ErrorAction SilentlyContinue)) {
    Write-Error "pdflatex nicht gefunden. Erwartet unter $texbin"
}

$global:Ghostscript = Join-Path $gsbin 'gswin64c.exe'

# Ghostscript aus TeX Live findet seine Initialisierungsdateien nicht von
# selbst — lib, kanji und Resource muessen per -I mitgegeben werden, sonst:
# "Can't find initialization file gs_init.ps".
$global:GsInclude = "-I$texwurzel\tlpkg\tlgs\lib;$texwurzel\tlpkg\tlgs\kanji;$texwurzel\tlpkg\tlgs\Resource\Init;$texwurzel\tlpkg\tlgs\Resource"
