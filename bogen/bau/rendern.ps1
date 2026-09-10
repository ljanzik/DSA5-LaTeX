<#
    rendern.ps1 — PDF-Seiten als PNG, zum Ablesen am Messgitter.

    Ghostscript bringt TeX Live selbst mit; es muss nichts installiert werden.
    150 dpi reicht zum Ablesen der Gitterlinien, 300 dpi für feine Stellen.

      .\bau\rendern.ps1 -Seiten 1
      .\bau\rendern.ps1 -Datei bau\ausgabe\heldenbogen-df-ausfuellbar-messgitter.pdf -Dpi 300
#>
param(
    [string]$Datei = '',
    [int[]]$Seiten = @(1,2,3,4,5,6),
    [int]$Dpi = 150
)

$ErrorActionPreference = 'Stop'
$Projekt = Split-Path -Parent $PSScriptRoot
Set-Location $Projekt
. (Join-Path $PSScriptRoot 'texpfad.ps1')

if (-not $Datei) { $Datei = 'bau\ausgabe\heldenbogen-df-ausfuellbar-messgitter.pdf' }
if (-not (Test-Path $Datei)) { Write-Error "Nicht gefunden: $Datei. Zuerst bauen: .\bau\bauen.ps1 -Messen" }

$ziel = Join-Path $Projekt 'bau\bilder'
if (-not (Test-Path $ziel)) { New-Item -ItemType Directory -Path $ziel | Out-Null }

$basis = [System.IO.Path]::GetFileNameWithoutExtension($Datei)
foreach ($s in $Seiten) {
    $aus = Join-Path $ziel "$basis-s$s.png"
    $meldung = & $global:Ghostscript $global:GsInclude -q -dNOPAUSE -dBATCH `
                   -sDEVICE=png16m "-r$Dpi" "-dFirstPage=$s" "-dLastPage=$s" `
                   "-sOutputFile=$aus" "$Datei" 2>&1
    if (Test-Path $aus) {
        $kb = [math]::Round((Get-Item $aus).Length / 1KB)
        Write-Output ("  {0} ({1} KB)" -f $aus, $kb)
    } else {
        Write-Output "  Seite $s FEHLGESCHLAGEN. Ghostscript sagt:"
        $meldung | Select-Object -Last 5 | ForEach-Object { "      $_" }
    }
}
