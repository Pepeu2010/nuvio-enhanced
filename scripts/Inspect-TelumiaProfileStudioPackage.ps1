[CmdletBinding()]
param([string]$OutputName = 'telumia-profile-studio-assets.json')
$ErrorActionPreference = 'Stop'
if ($OutputName -notmatch '^[a-z0-9-]+\.json$') { throw 'Invalid evidence filename.' }
$workspace = Split-Path $PSScriptRoot -Parent
$checkout = Join-Path $workspace 'repos/desktop'
$jar = Join-Path $checkout 'composeApp/build/libs/composeApp-desktop.jar'
$catalog = Get-Content (Join-Path $workspace 'assets/avatars/openmoji/catalog.json') -Raw | ConvertFrom-Json
if ($catalog.schemaVersion -ne 1 -or $catalog.sourceCommit -ne 'f9fc506a3f913be9897ab0181d611d4c910a4104' -or $catalog.items.Count -ne 64) { throw 'Unexpected pinned avatar catalog.' }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [IO.Compression.ZipFile]::OpenRead($jar)
try {
    $checked = foreach ($item in $catalog.items) {
        if ($item.code -cnotmatch '^[A-F0-9]{4,6}$' -or $item.sha256 -cnotmatch '^[a-f0-9]{64}$') { throw 'Invalid asset key.' }
        $entry = $archive.GetEntry("profile-studio/avatars/$($item.code).svg")
        if (-not $entry -or $entry.Length -gt 262144) { throw "Missing or oversized packaged avatar: $($item.code)" }
        $stream = $entry.Open()
        $sha = [Security.Cryptography.SHA256]::Create()
        try { $hash = [Convert]::ToHexString($sha.ComputeHash($stream)).ToLowerInvariant() }
        finally { $stream.Dispose(); $sha.Dispose() }
        if ($hash -ne $item.sha256) { throw "Packaged avatar was changed: $($item.code)" }
        [ordered]@{id=$item.id;bytes=$entry.Length;sha256=$hash}
    }
    foreach ($name in @('LICENSE.txt','catalog.json')) {
        $entry = $archive.GetEntry("profile-studio/avatars/$name")
        if (-not $entry) { throw "Packaged attribution missing: $name" }
        $sha = [Security.Cryptography.SHA256]::Create(); $stream = $entry.Open()
        try { $hash = [Convert]::ToHexString($sha.ComputeHash($stream)).ToLowerInvariant() }
        finally { $stream.Dispose(); $sha.Dispose() }
        if ($hash -ne (Get-FileHash (Join-Path $workspace "assets/avatars/openmoji/$name")).Hash.ToLowerInvariant()) { throw "Attribution differs: $name" }
    }
} finally { $archive.Dispose() }
[ordered]@{
    exportedAtUtc=[DateTime]::UtcNow.ToString('o')
    sourceCommit=(git -C $checkout rev-parse HEAD).Trim()
    trackedChanges=@(git -C $checkout status --porcelain --untracked-files=no)
    scope='Desktop JAR resource bytes and attribution; no claim of runtime, native import, or TV completion'
    jarSha256=(Get-FileHash $jar).Hash.ToLowerInvariant()
    upstreamSourceCommit=$catalog.sourceCommit
    license='CC-BY-SA-4.0'
    packagedAssets=@($checked)
    attributionMatches=$true
} | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $workspace "docs/$OutputName") -Encoding utf8
Write-Output '64 pinned avatar assets and attribution verified in the built Desktop JAR.'
