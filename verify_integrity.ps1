<#
.SYNOPSIS
    Verification d'integrite externe pour rssi_deck.html
.DESCRIPTION
    Executee hors navigateur (PowerShell), donc immunisee contre toute
    manipulation par du code JavaScript malveillant.
     1) Extrait LIBS_CDN depuis rssi_deck.html et compare les hash des
        fichiers dans lib/
     2) Verifie l'integrite de rssi_deck.html lui-meme via reference
        stockee dans rssi_deck.sha256
.PARAMETER Init
    Initialise la reference de hachage pour rssi_deck.html
    (cree/met a jour rssi_deck.sha256)
.PARAMETER Quiet
    Supprime les couleurs (utile pour redirection vers un fichier)
#>

param(
    [switch]$Init,
    [switch]$Quiet
)

$ScriptDir = Split-Path -Parent $PSCommandPath
$HtmlFile  = Join-Path $ScriptDir "rssi_deck.html"
$LibDir    = Join-Path $ScriptDir "lib"
$RefFile   = Join-Path $ScriptDir "rssi_deck.sha256"

# ---- helpers ----
function Color($C) { if (-not $Quiet -and $Host.UI.RawUI.ForegroundColor) { $P = @{ForegroundColor=$C}; return $P } else { return @{} } }
function Ok($T)   { Write-Host "  $(Checkmark) $T" @Color('Green') }
function Err($T)  { Write-Host "  $(Cross)    $T" @Color('Red') }
function Warn($T) { Write-Host "  !  $T" @Color('Yellow') }
function Info($T) { Write-Host $T @Color('Cyan') }
function Dim($T)  { if (-not $Quiet) { Write-Host $T @Color('DarkGray') } }
$Checkmark = [char]0x2713
$Cross     = [char]0x2717

# ---- pre-checks ----
if (-not (Test-Path $HtmlFile)) { Write-Host "ERREUR : $HtmlFile introuvable" @Color('Red'); exit 1 }

# ---- 1) Parse LIBS_CDN from HTML ----
$html = Get-Content $HtmlFile -Raw -Encoding UTF8
$cdnMatch = [regex]::Match($html, '(?s)const\s+LIBS_CDN\s*=\s*\{(.*?)\};')
if (-not $cdnMatch.Success) {
    Write-Host "ERREUR : impossible d'extraire LIBS_CDN depuis $HtmlFile" @Color('Red')
    exit 1
}
$cdnEntries = @{}
$entryPattern = "'([^']+)'\s*:\s*\{[^}]*?hash:\s*'([^']+)'"
$entryMatches = [regex]::Matches($cdnMatch.Groups[1].Value, $entryPattern)
if ($entryMatches.Count -eq 0) {
    Write-Host "ERREUR : aucune entree trouvee dans LIBS_CDN" @Color('Red')
    exit 1
}
foreach ($m in $entryMatches) { $cdnEntries[$m.Groups[1].Value] = $m.Groups[2].Value }

# ---- 2) Verify lib files ----
Info "=== Librairies ==="
$libOk = 0; $libTotal = $cdnEntries.Count
foreach ($f in $cdnEntries.Keys) {
    $libPath = Join-Path $LibDir $f
    if (-not (Test-Path $libPath)) {
        Err "($f) fichier introuvable dans lib/"
        continue
    }
    $actualHash = Get-FileHash $libPath -Algorithm SHA256
    $actual = 'sha256-' + $actualHash.Hash.ToLower()
    $expected = $cdnEntries[$f]
    if ($actual -eq $expected) {
        Ok "$f : hash conforme"
        $libOk++
    } else {
        Err "$f : HASH NON CONFORME"
        Dim "    Attendu : $expected"
        Dim "    Reçu    : $actual"
    }
}
Write-Host "  -> $libOk/$libTotal librairies OK" @(if ($libOk -eq $libTotal) { Color('Green') } else { Color('Red') })
Write-Host ""

# ---- 3) Verify rssi_deck.html integrity ----
Info "=== Fichier HTML ==="
$htmlHash = Get-FileHash $HtmlFile -Algorithm SHA256
$htmlHashStr = $htmlHash.Hash.ToLower()

if ($Init) {
    Set-Content -Path $RefFile -Value $htmlHashStr -Encoding ASCII -NoNewline
    Ok "Reference initialisee : $RefFile"
    Write-Host "  Empreinte : $htmlHashStr" @Color('DarkGray')
} elseif (Test-Path $RefFile) {
    $saved = Get-Content $RefFile -Raw -Encoding ASCII
    $saved = $saved.Trim()
    if ($htmlHashStr -eq $saved) {
        Ok "rssi_deck.html : integrite verifiee (reference $RefFile)"
    } else {
        Err "rssi_deck.html : EMPREINTE MODIFIEE"
        Dim "    Reference ($RefFile) : $saved"
        Dim "    Actuelle              : $htmlHashStr"
    }
} else {
    Warn "$HtmlFile : aucune reference trouvee. Lancez avec -Init pour creer $RefFile"
    Dim "    Empreinte actuelle : $htmlHashStr"
}
Write-Host ""

# ---- Summary ----
if ($libOk -eq $libTotal) {
    $libStatus = "OK"
} else {
    $libStatus = "ALERTE : $($libTotal - $libOk) librairie(s) non conforme(s)"
}
if (Test-Path $RefFile) {
    $refOk = (Get-Content $RefFile -Raw -Encoding ASCII).Trim() -eq $htmlHashStr
    $htmlStatus = if ($refOk) { "OK" } else { "MODIFIE" }
} else {
    $htmlStatus = "non initialisee (lancer avec -Init)"
}
Write-Host "Bilan : librairies [$libStatus] | HTML [$htmlStatus]" @Color('Cyan')
