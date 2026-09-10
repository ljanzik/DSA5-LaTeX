<#
    mappe-bauen.ps1 — baut die Charaktermappe.

    Die Mappe ist der Umschlag zu den Heldenbögen: Titel, Rückseite und zwei
    Innenblätter. Sie enthält KEINE Seite des Originalbogens und ist damit
    weitergebbar, solange der Pflichttext der Vereinbarung über
    Gemeinschaftsinhalte mitgeht (steht auf dem linken Innenblatt).

    ZWINGEND pdflatex und ZWINGEND zwei Läufe, wie beim Heldenbogen.

    Beispiele:
      .\bau\mappe-bauen.ps1 -Held dorle                  # 4 x A4, digital
      .\bau\mappe-bauen.ps1 -Held dorle -Fassung druck   # 2 x A3 quer
      .\bau\mappe-bauen.ps1 -Held dorle -Fassung druck -Wenden lang
      .\bau\mappe-bauen.ps1 -Held dorle -Beide
#>
param(
    [string]$Held = '',
    [ValidateSet('digital','druck')] [string]$Fassung = 'digital',
    [ValidateSet('kurz','lang')]     [string]$Wenden  = 'kurz',
    [switch]$Beide
)

$ErrorActionPreference = 'Stop'
$Projekt = Split-Path -Parent $PSScriptRoot
Set-Location $Projekt

. (Join-Path $PSScriptRoot 'texpfad.ps1')

$Ausgabe = Join-Path $Projekt 'bau\ausgabe'
if (-not (Test-Path $Ausgabe)) { New-Item -ItemType Directory -Path $Ausgabe | Out-Null }

# Pergamentfläche und Fusskasten werden aus dem Scriptorium-Baukasten
# abgeleitet. Einmal genügt; fehlt eine der Dateien, wird sie erzeugt.
$Flaeche = Join-Path $Ausgabe 'pergament-a4.jpg'
$Kasten  = Join-Path $Ausgabe 'pergament-kasten.png'
if (-not (Test-Path $Flaeche) -or -not (Test-Path $Kasten)) {
    Write-Output '=== Pergament aus dem Baukasten ableiten'
    & python (Join-Path $PSScriptRoot 'pergament-vorbereiten.py')
    if ($LASTEXITCODE -ne 0) { throw 'pergament-vorbereiten.py fehlgeschlagen' }
}

$script:Fehlgeschlagen = 0

function Baue {
    param([string]$f, [string]$h, [string]$w)

    $jobname = "mappe-$f"
    if ($h) { $jobname = "$jobname-$h" }
    if ($f -eq 'druck' -and $w -eq 'lang') { $jobname = "$jobname-wendenlang" }

    $vorspann = "\def\Fassung{$f}\def\Wenden{$w}"
    if ($h) { $vorspann += "\def\Held{$h}" }

    Write-Output "=== $jobname"
    foreach ($lauf in 1, 2) {
        $null = & pdflatex -interaction=nonstopmode -halt-on-error `
                    -output-directory="$Ausgabe" -jobname="$jobname" `
                    "$vorspann\input{mappe/mappe.tex}" 2>&1
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
        Write-Output "    kein PDF entstanden - hat das Dokument eine Seite?"
        $script:Fehlgeschlagen++
        return
    }
    $kb = [math]::Round((Get-Item $pdf).Length / 1KB)
    Write-Output ("    fertig: {0} ({1} KB)" -f $pdf, $kb)
}

if ($Beide) {
    Baue 'digital' $Held 'kurz'
    Baue 'druck'   $Held $Wenden
} else {
    Baue $Fassung $Held $Wenden
}

if ($script:Fehlgeschlagen -gt 0) {
    Write-Output ""
    Write-Output "$($script:Fehlgeschlagen) Fassung(en) fehlgeschlagen."
    exit 1
}
