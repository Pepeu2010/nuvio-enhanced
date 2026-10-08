[CmdletBinding()]
param(
    [ValidateSet('desktop','tv')][string[]]$Targets = @('desktop','tv'),
    [ValidatePattern('^[a-z0-9-]+\.json$')][string]$OutputName = 'telumia-display-font-package-inspection.json'
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$manifest = Get-Content (Join-Path $workspace 'docs/telumia-static-manrope.json') -Raw | ConvertFrom-Json
$source = Get-Content (Join-Path $workspace 'docs/telumia-typography-source.json') -Raw | ConvertFrom-Json
if ($manifest.fonts.Count -ne 4 -or $manifest.tool -ne 'fontTools 4.59.0 varLib.instancer') { throw 'Unexpected font manifest.' }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$results = foreach ($target in $Targets) {
    $checkout = Join-Path $workspace "repos/$target"
    $changes = @(git -C $checkout status --porcelain)
    if ($changes.Count) { throw 'Font package inspection requires a clean source checkout.' }
    $package = if ($target -eq 'desktop') { Join-Path $checkout 'composeApp/build/libs/composeApp-desktop.jar' } else { Join-Path $checkout 'app/build/outputs/apk/full/debug/app-full-universal-debug.apk' }
    $prefix = if ($target -eq 'desktop') { 'composeResources/nuvio.composeapp.generated.resources/font' } else { 'res/font' }
    $archive = [IO.Compression.ZipFile]::OpenRead($package)
    try {
        $fonts = foreach ($font in $manifest.fonts) {
            $entry = $archive.GetEntry("$prefix/$($font.file)")
            if (-not $entry -or $entry.Length -ne $font.bytes) { throw "Missing or changed packaged font $($font.file)." }
            $stream = $entry.Open()
            $sha = [Security.Cryptography.SHA256]::Create()
            try { $hash = [Convert]::ToHexString($sha.ComputeHash($stream)).ToLowerInvariant() }
            finally { $stream.Dispose(); $sha.Dispose() }
            if ($hash -ne $font.sha256) { throw "Packaged font hash mismatch $($font.file)." }
            [ordered]@{file=$font.file;weight=$font.weight;bytes=$entry.Length;sha256=$hash}
        }
        $licensePrefix = if ($target -eq 'desktop') { 'composeResources/nuvio.composeapp.generated.resources/files/licenses/manrope' } else { 'assets/licenses/manrope' }
        foreach ($credit in @(@{name='OFL.txt';hash=$source.licenseSha256},@{name='FONTLOG.txt';hash=$source.fontlogSha256})) {
            $entry = $archive.GetEntry("$licensePrefix/$($credit.name)")
            if (-not $entry) { throw 'Packaged font credit is missing.' }
            $stream = $entry.Open(); $sha = [Security.Cryptography.SHA256]::Create()
            try { $hash = [Convert]::ToHexString($sha.ComputeHash($stream)).ToLowerInvariant() }
            finally { $stream.Dispose(); $sha.Dispose() }
            if ($hash -ne $credit.hash) { throw 'Packaged font credit differs from the licensed source.' }
        }
    } finally { $archive.Dispose() }
    [ordered]@{target=$target;sourceCommit=(git -C $checkout rev-parse HEAD).Trim();sourceChanges=$changes;
        packageSha256=(Get-FileHash -LiteralPath $package).Hash.ToLowerInvariant();fonts=@($fonts);sourceLicenseAndFontlogMatch=$true}
}
[ordered]@{exportedAtUtc=[DateTime]::UtcNow.ToString('o');
    scope='Actual built JAR/APK resource hashes; native drawing and UI checks have separate evidence. No playback or full-interface claim.';
    results=@($results)} | ConvertTo-Json -Depth 7 | Set-Content (Join-Path $workspace "docs/$OutputName") -Encoding utf8
Write-Output 'Four static font resources verified in each requested built package.'
