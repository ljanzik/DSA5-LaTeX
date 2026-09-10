<#
    felder-pruefen.ps1 — liest die tatsächlichen Feldpositionen aus dem PDF.

    Die Gegenprobe zum Einmessen, ohne hinsehen zu müssen: baut eine
    unkomprimierte Fassung und rechnet jedes /Rect zurück in Millimeter von
    der linken oberen Papierecke — also in genau die Koordinaten, in denen
    die Feldtabelle geschrieben ist. Abweichung zur Tabelle = Fehler.

    Prüft ausserdem drei Dinge, die still schiefgehen:
      - DOPPELTE Feldnamen. AcroForm macht daraus EIN Feld mit gespiegeltem
        Inhalt. In einer Tabellenschleife passiert das schnell.
      - weisser Hintergrund (/MK<</BG…>>), der den Originalbogen überdeckt.
      - Rahmen (/BS<</W …>> ungleich 0).

    Wichtig: /Rect steht im Objekt VOR /T. Deshalb wird je Objekt geparst und
    nicht über den Token-Strom — sonst paart man jeden Namen mit dem Rechteck
    des nächsten Feldes und alles ist um eine Zeile verschoben.

      .\bau\felder-pruefen.ps1
      .\bau\felder-pruefen.ps1 -Quelle farbe
#>
param(
    [ValidateSet('df','farbe')] [string]$Quelle = 'df',
    [switch]$NichtNeuBauen
)

$ErrorActionPreference = 'Stop'
$Projekt = Split-Path -Parent $PSScriptRoot
Set-Location $Projekt

if (-not $NichtNeuBauen) {
    & (Join-Path $PSScriptRoot 'bauen.ps1') -Quelle $Quelle -Pruefen
}
$pdf = Join-Path $Projekt "bau\ausgabe\heldenbogen-$Quelle-ausfuellbar-roh.pdf"
if (-not (Test-Path $pdf)) { Write-Error "Nicht gefunden: $pdf" }

# Binärteile stören nicht; bei -pdfobjcompresslevel=0 ist die Objektstruktur Klartext.
$txt = [System.Text.Encoding]::GetEncoding(28591).GetString([System.IO.File]::ReadAllBytes($pdf))

$hoehe = 841.89          # A4 in PDF-Punkten (bp), Ursprung unten links
$bp2mm = 25.4 / 72

function Entschluessle([string]$s) {
    # /T ist UTF-16BE mit BOM, oktal escaped: \376\377\000s\0001 ...
    $bytes = New-Object System.Collections.Generic.List[byte]
    for ($i = 0; $i -lt $s.Length; $i++) {
        if ($s[$i] -eq '\' -and $i + 3 -lt $s.Length -and $s[$i+1] -match '[0-7]') {
            $bytes.Add([Convert]::ToByte($s.Substring($i+1,3), 8)); $i += 3
        } else { $bytes.Add([byte][char]$s[$i]) }
    }
    [System.Text.Encoding]::BigEndianUnicode.GetString($bytes.ToArray()).TrimStart([char]0xFEFF)
}

$felder = @()
foreach ($obj in [regex]::Matches($txt, '(?s)\d+ 0 obj(.{0,600}?)endobj')) {
    $o = $obj.Groups[1].Value
    if ($o -notmatch '/Widget') { continue }
    if ($o -notmatch '/Rect\s*\[([^\]]*)\]') { continue }
    $z = $Matches[1] -split '\s+' | Where-Object { $_ } | ForEach-Object { [double]$_ }
    if ($z.Count -ne 4) { continue }
    $name = if ($o -match '/T\s*\(((?:\.|[^)])*)\)') { Entschluessle $Matches[1] } else { '(ohne Namen)' }

    $felder += [pscustomobject]@{
        Name   = $name
        x      = [math]::Round($z[0] * $bp2mm, 2)
        y      = [math]::Round(($hoehe - $z[3]) * $bp2mm, 2)
        Breite = [math]::Round(($z[2] - $z[0]) * $bp2mm, 2)
        Hoehe  = [math]::Round(($z[3] - $z[1]) * $bp2mm, 2)
        Grund  = if ($o -match '/BG\s*\[') { 'JA' } else { '-' }
        Rahmen = if ($o -match '/BS\s*<<\s*/W\s*([\d.]+)') { $Matches[1] } else { '-' }
    }
}

Write-Output ""
Write-Output "Felder im PDF: $($felder.Count)   (Masse in mm von links oben)"
Write-Output ""
$felder | Sort-Object Name | Format-Table -AutoSize

$fehler = 0

$doppelt = $felder | Group-Object Name | Where-Object { $_.Count -gt 1 }
if ($doppelt) {
    Write-Output "FEHLER — doppelte Feldnamen, AcroForm macht daraus je EIN Feld:"
    $doppelt | ForEach-Object { "  $($_.Name)  ($($_.Count)x)" }
    $fehler++
} else { Write-Output "Feldnamen eindeutig." }

$mitGrund = $felder | Where-Object { $_.Grund -eq 'JA' }
if ($mitGrund) {
    Write-Output "FEHLER — $($mitGrund.Count) Feld(er) mit weissem Hintergrund; sie ueberdecken den Originalbogen."
    $fehler++
} else { Write-Output "Kein Feld hat Hintergrund." }

$mitRahmen = $felder | Where-Object { $_.Rahmen -ne '-' -and [double]$_.Rahmen -ne 0 }
if ($mitRahmen) {
    Write-Output "HINWEIS — $($mitRahmen.Count) Feld(er) mit Rahmen."
} else { Write-Output "Kein Feld hat Rahmen." }

if ($fehler -gt 0) { exit 1 }
