<#
    quelle-vorbereiten.ps1 — normalisiert die Farbfassung auf A4.

    Die Farbfassung ist eine DRUCKDATEI, nicht ein A4-Dokument:
        MediaBox 230.8 x 317.8 mm   (A4 plus 11 mm Beschnittzugabe)
        TrimBox  208.8 x 295.8 mm   um 11 mm versetzt
    Legt man sie ungeprüft mit pdfpages ein, skaliert pdfpages sie um etwa
    +0,6 % auf A4 — dann stimmt keine im Quelldokument gemessene Koordinate
    mehr mit der Seite überein.

    Deshalb hier einmal: auf die TrimBox beschneiden und ohne Skalierung
    mittig auf A4 setzen. Ergebnis ist eine A4-Datei, die sich genau wie die
    druckerfreundliche Fassung behandeln lässt — 1:1, ohne Umrechnung.
    Das Werk sitzt darin mit 0,59 mm Rand, weil die TrimBox 1,2 mm kleiner
    als A4 ist.

    Die erzeugte Datei landet in bau/ausgabe/ und ist abgeleitetes
    Verlagsmaterial — nicht weitergeben, siehe CLAUDE.md.
#>
param([switch]$Neu)

$ErrorActionPreference = 'Stop'
$Projekt = Split-Path -Parent $PSScriptRoot
Set-Location $Projekt
. (Join-Path $PSScriptRoot 'texpfad.ps1')

$quelle = Join-Path $env:USERPROFILE 'Downloads\US25505PDF_Heldendokumente.pdf'
$ziel   = Join-Path $Projekt 'bau\ausgabe\quelle-farbe-a4.pdf'

if (-not (Test-Path $quelle)) { Write-Error "Quelle nicht gefunden: $quelle" }

$ausgabe = Split-Path -Parent $ziel
if (-not (Test-Path $ausgabe)) { New-Item -ItemType Directory -Path $ausgabe | Out-Null }

if ((Test-Path $ziel) -and -not $Neu -and
    (Get-Item $ziel).LastWriteTime -gt (Get-Item $quelle).LastWriteTime) {
    Write-Output "  Farbquelle schon vorbereitet: $ziel"
    return
}

# A4 in PDF-Punkten und der Versatz, der die 1,2 mm kleinere TrimBox mittig
# setzt: (595.276 - 591.921) / 2 = 1.678 bp, ebenso in der Hoehe.
$a4b = 595.276
$a4h = 841.890
$versatz = 1.678

Write-Output "  bereite Farbquelle vor (TrimBox -> A4, ohne Skalierung)..."
$meldung = & $global:Ghostscript $global:GsInclude -q -dNOPAUSE -dBATCH `
    -sDEVICE=pdfwrite -dUseTrimBox -dFIXEDMEDIA `
    "-dDEVICEWIDTHPOINTS=$a4b" "-dDEVICEHEIGHTPOINTS=$a4h" `
    "-sOutputFile=$ziel" `
    -c "<</PageOffset [$versatz $versatz]>> setpagedevice" `
    -f "$quelle" 2>&1

if (-not (Test-Path $ziel)) {
    Write-Output "  FEHLGESCHLAGEN. Ghostscript sagt:"
    $meldung | Select-Object -Last 6 | ForEach-Object { "      $_" }
    exit 1
}
$mb = [math]::Round((Get-Item $ziel).Length / 1MB, 1)
Write-Output "  fertig: $ziel ($mb MB)"
