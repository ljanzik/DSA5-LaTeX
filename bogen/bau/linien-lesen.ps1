<#
    linien-lesen.ps1 — liest die Geometrie des Originalbogens aus dem PDF.

    Das Werkzeug, das Schritt 4 des Briefings von Schätzarbeit in Messarbeit
    verwandelt. Ghostscript schreibt die Seite unkomprimiert neu, dann werden
    aus dem Content-Stream gelesen:

      LINIEN   waagerechte Pfade (x y m x2 y2 l) — die Schreiblinien.
               Ein Feld sitzt DARÜBER, mit der Unterkante auf der Linie.
      KAESTEN  Rechtecke (x y b h re) — die Wertekästchen.
               Ein Feld sitzt DARIN, deckungsgleich.

    Alles in Millimeter von der linken oberen Papierecke, also in genau den
    Koordinaten der Feldtabelle.

    Was das Werkzeug NICHT weiss: wo eine Beschriftung endet. Die Linie läuft
    unter ihr durch, das Feld darf erst dahinter beginnen. Diesen x-Startwert
    am gerenderten Bogen ablesen (bau\rendern.ps1) und in der Feldtabelle als
    abgelesen kennzeichnen.

      .\bau\linien-lesen.ps1 -Seite 3
      .\bau\linien-lesen.ps1 -Seite 3 -Quelle farbe
      .\bau\linien-lesen.ps1 -Seite 2 -Nur linien -MinBreite 30
#>
param(
    [int]$Seite = 1,
    [ValidateSet('df','farbe')] [string]$Quelle = 'df',
    [ValidateSet('alles','linien','senkrecht','kaesten')] [string]$Nur = 'alles',
    [double]$MinBreite = 14,       # mm — kürzere Striche sind Raster, keine Schreiblinien
    [double]$MaxDicke  = 1.0,      # mm — dickere Rechtecke sind keine Linien
    [double]$KastenMin = 3.5,      # mm — Kantenlänge eines Wertekästchens
    [double]$KastenMax = 14
)

$ErrorActionPreference = 'Stop'
$Projekt = Split-Path -Parent $PSScriptRoot
Set-Location $Projekt
. (Join-Path $PSScriptRoot 'texpfad.ps1')

# Fuer die Farbfassung wird die auf A4 normalisierte Datei gemessen, nicht
# das Original: dessen TrimBox ist um 11 mm versetzt, und Messwerte darin
# liegen nicht in Seitenkoordinaten. Siehe bau\quelle-vorbereiten.ps1.
if ($Quelle -eq 'farbe') { & (Join-Path $PSScriptRoot 'quelle-vorbereiten.ps1') }

$quellen = @{
    df    = Join-Path $env:USERPROFILE 'Downloads\Heldendokument_druckerfreundlich.pdf'
    farbe = Join-Path $Projekt 'bau\ausgabe\quelle-farbe-a4.pdf'
}
$quellpfad = $quellen[$Quelle]
if (-not (Test-Path $quellpfad)) { Write-Error "Quelldatei nicht gefunden: $quellpfad" }

# Die physische Seite: -Seite meint hier die Seite der QUELLDATEI, nicht den
# logischen Bogen. Die Zuordnung steht in konfig.tex.
$tmp = Join-Path $env:TEMP "heldenbogen-roh-$Quelle-s$Seite.pdf"
if (Test-Path $tmp) { Remove-Item $tmp -Force }

# Argumente mit Variablen MÜSSEN quotiert werden, sonst zerlegt PowerShell sie
# falsch und Ghostscript tut stillschweigend nichts.
$meldung = & $global:Ghostscript $global:GsInclude -q -dNOPAUSE -dBATCH `
               -sDEVICE=pdfwrite -dCompressStreams=false -dCompressPages=false `
               "-dFirstPage=$Seite" "-dLastPage=$Seite" `
               "-sOutputFile=$tmp" "$quellpfad" 2>&1
if (-not (Test-Path $tmp)) {
    Write-Output "Ghostscript hat nichts geschrieben. Meldung:"
    $meldung | Select-Object -Last 6 | ForEach-Object { "    $_" }
    exit 1
}

$txt = [System.Text.Encoding]::GetEncoding(28591).GetString([System.IO.File]::ReadAllBytes($tmp))

$hoehe = 841.89          # A4 in PDF-Punkten (bp), Ursprung unten links
$bp2mm = 25.4 / 72

# Der Content-Stream steht in 1/10 bp — Ghostscript setzt "0.1 0 0 0.1 0 0 cm"
# an den Anfang. Der Faktor wird aus der Datei gelesen, nicht angenommen.
$skala = 1.0
$sm = [regex]::Match($txt, '(?<s>[\d.]+)\s+0\s+0\s+\k<s>\s+0\s+0\s+cm')
if ($sm.Success) { $skala = [double]$sm.Groups['s'].Value }
if ($skala -le 0) { $skala = 1.0 }

function InMm([double]$v) { [math]::Round($v * $skala * $bp2mm, 1) }
function VonOben([double]$y) { [math]::Round(($hoehe - $y * $skala) * $bp2mm, 1) }

Write-Output ""
Write-Output "Seite $Seite der Fassung '$Quelle'   (Skala $skala, Masse in mm von links oben)"

# --- Waagerechte Linien ----------------------------------------------------
if ($Nur -eq 'alles' -or $Nur -eq 'linien') {
    $linien = @()
    foreach ($m in [regex]::Matches($txt, '(-?[\d.]+)\s+(-?[\d.]+)\s+m\s+(-?[\d.]+)\s+(-?[\d.]+)\s+l')) {
        $x1 = [double]$m.Groups[1].Value; $y1 = [double]$m.Groups[2].Value
        $x2 = [double]$m.Groups[3].Value; $y2 = [double]$m.Groups[4].Value
        if ([math]::Abs($y1 - $y2) * $skala * $bp2mm -gt 0.2) { continue }   # nicht waagerecht
        $breite = [math]::Abs($x2 - $x1)
        if ((InMm $breite) -lt $MinBreite) { continue }
        $linien += [pscustomobject]@{
            x      = InMm ([math]::Min($x1, $x2))
            y      = VonOben $y1
            Breite = InMm $breite
        }
    }
    $linien = $linien | Sort-Object y, x -Unique
    Write-Output ""
    Write-Output "SCHREIBLINIEN (>= $MinBreite mm): $($linien.Count)   — Feld sitzt DARUEBER"
    $linien | Format-Table -AutoSize
}

# --- Senkrechte Linien -----------------------------------------------------
# Die Spaltengrenzen der Tabellen. Zusammen mit den waagerechten Linien
# ergeben sie das Zellenraster: Feld = Zelle, etwas eingerückt.
if ($Nur -eq 'alles' -or $Nur -eq 'senkrecht') {
    $senk = @()
    foreach ($m in [regex]::Matches($txt, '(-?[\d.]+)\s+(-?[\d.]+)\s+m\s+(-?[\d.]+)\s+(-?[\d.]+)\s+l')) {
        $x1 = [double]$m.Groups[1].Value; $y1 = [double]$m.Groups[2].Value
        $x2 = [double]$m.Groups[3].Value; $y2 = [double]$m.Groups[4].Value
        if ([math]::Abs($x1 - $x2) * $skala * $bp2mm -gt 0.2) { continue }   # nicht senkrecht
        $laenge = [math]::Abs($y2 - $y1)
        if ((InMm $laenge) -lt $MinBreite) { continue }
        $senk += [pscustomobject]@{
            x       = InMm $x1
            yOben   = VonOben ([math]::Max($y1, $y2))
            yUnten  = VonOben ([math]::Min($y1, $y2))
            Laenge  = InMm $laenge
        }
    }
    $senk = $senk | Sort-Object x, yOben -Unique
    Write-Output ""
    Write-Output "SPALTENGRENZEN (>= $MinBreite mm lang): $($senk.Count)"
    $senk | Format-Table -AutoSize
}

# --- Kästchen --------------------------------------------------------------
if ($Nur -eq 'alles' -or $Nur -eq 'kaesten') {
    $kaesten = @()
    foreach ($m in [regex]::Matches($txt, '(-?[\d.]+)\s+(-?[\d.]+)\s+(-?[\d.]+)\s+(-?[\d.]+)\s+re')) {
        $x = [double]$m.Groups[1].Value; $y = [double]$m.Groups[2].Value
        $b = [double]$m.Groups[3].Value; $h = [double]$m.Groups[4].Value
        if ($b -lt 0) { $x += $b; $b = -$b }
        if ($h -lt 0) { $y += $h; $h = -$h }
        $bm = InMm $b; $hm = InMm $h
        if ($bm -lt $KastenMin -or $bm -gt $KastenMax) { continue }
        if ($hm -lt $KastenMin -or $hm -gt $KastenMax) { continue }
        $kaesten += [pscustomobject]@{
            x      = InMm $x
            y      = VonOben ($y + $h)
            Breite = $bm
            Hoehe  = $hm
        }
    }
    $kaesten = $kaesten | Sort-Object y, x -Unique
    Write-Output ""
    Write-Output "KAESTEN ($KastenMin..$KastenMax mm): $($kaesten.Count)   — Feld sitzt DARIN"
    $kaesten | Format-Table -AutoSize
}
