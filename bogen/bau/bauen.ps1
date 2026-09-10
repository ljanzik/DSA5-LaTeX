<#
    bauen.ps1 — baut eine oder alle Fassungen des Heldenbogens.

    ZWINGEND pdflatex, nicht xelatex. ZWINGEND zwei Läufe: "remember picture"
    braucht zwei Durchgänge, im ersten liegen alle Felder in der linken
    oberen Ecke. Ein Positionsproblem erst nach dem zweiten Lauf glauben.

    Beispiele:
      .\bau\bauen.ps1                                 # ausfüllbar, druckerfreundlich
      .\bau\bauen.ps1 -Messen                         # mit Messgitter zum Ablesen
      .\bau\bauen.ps1 -Quelle farbe -Messen
      .\bau\bauen.ps1 -Modus vorbefuellt -Held dorle
      .\bau\bauen.ps1 -Modus liste -Held dorle        # ohne Originalbogen
      .\bau\bauen.ps1 -Alle -Held dorle
      .\bau\bauen.ps1 -Pruefen                        # unkomprimiert, für felder-pruefen.ps1
#>
param(
    [ValidateSet('ausfuellbar','vorbefuellt','liste')] [string]$Modus  = 'ausfuellbar',
    [ValidateSet('df','farbe')]                        [string]$Quelle = 'df',
    [string]$Held = '',
    [switch]$Messen,
    [switch]$OhneLeere,
    [switch]$Pruefen,
    [switch]$Alle
)

$ErrorActionPreference = 'Stop'
$Projekt = Split-Path -Parent $PSScriptRoot
Set-Location $Projekt

. (Join-Path $PSScriptRoot 'texpfad.ps1')

$Ausgabe = Join-Path $Projekt 'bau\ausgabe'
if (-not (Test-Path $Ausgabe)) { New-Item -ItemType Directory -Path $Ausgabe | Out-Null }

$script:Fehlgeschlagen = 0

function Baue {
    param([string]$m, [string]$q, [string]$h, [bool]$gitter, [bool]$roh,
          [bool]$ohneleere)

    $jobname = "heldenbogen-$q-$m"
    if ($h)      { $jobname = "$jobname-$h" }
    if ($gitter) { $jobname = "$jobname-messgitter" }
    if ($roh)    { $jobname = "$jobname-roh" }
    if ($ohneleere) { $jobname = "$jobname-knapp" }

    $vorspann = ''
    # Unkomprimiert: nur zum Prüfen. So lassen sich /Widget, /Rect und die
    # Feldnamen im PDF direkt lesen — komprimiert findet man sie nicht.
    if ($roh) { $vorspann += '\pdfcompresslevel=0 \pdfobjcompresslevel=0 ' }
    $vorspann += "\def\Modus{$m}\def\Quelle{$q}"
    if ($h)      { $vorspann += "\def\Held{$h}" }
    if ($gitter) { $vorspann += "\def\Messen{1}" }
    if ($ohneleere) { $vorspann += "\def\OhneLeere{1}" }

    Write-Output "=== $jobname"
    # Die Farbfassung braucht die auf A4 normalisierte Quelle, sonst
    # skaliert pdfpages sie und alle Koordinaten sind falsch.
    if ($q -eq 'farbe') {
        & (Join-Path $PSScriptRoot 'quelle-vorbereiten.ps1')
    }
    foreach ($lauf in 1, 2) {
        $null = & pdflatex -interaction=nonstopmode -halt-on-error `
                    -output-directory="$Ausgabe" -jobname="$jobname" `
                    "$vorspann\input{heldenbogen.tex}" 2>&1
        if ($LASTEXITCODE -ne 0) {
            $log = Join-Path $Ausgabe "$jobname.log"
            Write-Output "    Lauf $lauf FEHLGESCHLAGEN. Fehler aus dem Log:"
            Select-String -Path $log -Pattern '^!' -Context 0,4 |
                Select-Object -First 2 | ForEach-Object { "      " + $_.Line }
            Write-Output "    vollstaendig: $log"
            $script:Fehlgeschlagen++
            return
        }
    }
    $pdf = Join-Path $Ausgabe "$jobname.pdf"
    if (-not (Test-Path $pdf)) {
        # pdflatex meldet Erfolg, schreibt aber kein PDF, wenn das
        # Dokument keine Seite hat. Sauber melden statt abstuerzen.
        Write-Output "    kein PDF entstanden - hat das Dokument eine Seite?"
        $script:Fehlgeschlagen++
        return
    }
    $kb  = [math]::Round((Get-Item $pdf).Length / 1KB)
    Write-Output ("    fertig: {0} ({1} KB)" -f $pdf, $kb)
}

if ($Alle) {
    foreach ($q in 'df','farbe') {
        Baue 'ausfuellbar' $q '' $false $false $false
        if ($Held) { Baue 'vorbefuellt' $q $Held $false $false ([bool]$OhneLeere) }
    }
    if ($Held) { Baue 'liste' 'df' $Held $false $false $false }
} else {
    Baue $Modus $Quelle $Held ([bool]$Messen) ([bool]$Pruefen) ([bool]$OhneLeere)
}

if ($script:Fehlgeschlagen -gt 0) {
    Write-Output ""
    Write-Output "$($script:Fehlgeschlagen) Fassung(en) fehlgeschlagen."
    exit 1
}
