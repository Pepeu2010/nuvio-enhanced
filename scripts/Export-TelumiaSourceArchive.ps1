[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('desktop','tv')][string]$Target,
    [Parameter(Mandatory)][ValidatePattern('^[a-f0-9]{40}$')][string]$Commit,
    [Parameter(Mandatory)][string]$OutputPath
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$checkout = Join-Path $workspace "repos/$Target"
$destination = [IO.Path]::GetFullPath($OutputPath)
$artifactRoot = [IO.Path]::GetFullPath((Join-Path $workspace 'artifacts')) + [IO.Path]::DirectorySeparatorChar
if (-not $destination.StartsWith($artifactRoot,[StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetExtension($destination) -ne '.zip') { throw 'Source archives must be ZIP files inside this workspace artifacts directory.' }
if (Test-Path -LiteralPath $destination) { throw 'Preserve the existing archive; use a new filename.' }
if ((git -C $checkout rev-parse HEAD).Trim() -ne $Commit -or @(git -C $checkout status --porcelain).Count) { throw 'Archive source must be the exact committed, clean checkout.' }
$metadata = (git -C $checkout lfs ls-files --json $Commit) | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'LFS inventory failed.' }
$objects = (git -C $checkout rev-parse --git-path lfs/objects).Trim()
if (-not [IO.Path]::IsPathRooted($objects)) { $objects = Join-Path $checkout $objects }
$hydrated = @()
foreach ($file in @($metadata.files | Where-Object { $null -ne $_ })) {
    if ($file.oid_type -ne 'sha256' -or $file.oid -cnotmatch '^[a-f0-9]{64}$' -or $file.size -le 0 -or
        $file.name -match '(^/|\\|:|(^|/)\.\.(/|$))') { throw 'Invalid LFS source inventory.' }
    $object = Join-Path $objects "$($file.oid.Substring(0,2))/$($file.oid.Substring(2,2))/$($file.oid)"
    if (-not (Test-Path -LiteralPath $object -PathType Leaf) -or (Get-Item -LiteralPath $object).Length -ne $file.size -or
        (Get-FileHash -LiteralPath $object).Hash.ToLowerInvariant() -ne $file.oid) { throw 'Required LFS object is missing or differs from the pinned commit. Fetch it before packaging.' }
    $hydrated += [ordered]@{name=$file.name;bytes=$file.size;sha256=$file.oid;object=$object}
}
New-Item -ItemType Directory -Force -Path (Split-Path $destination -Parent) | Out-Null
$pending = $destination + '.part'
if (Test-Path -LiteralPath $pending) { throw 'Previous source archive attempt exists; preserve it and use a new filename.' }
git -C $checkout archive --format=zip "--output=$pending" $Commit
if ($LASTEXITCODE -ne 0) { throw 'Git source archive failed.' }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::Open($pending,[IO.Compression.ZipArchiveMode]::Update)
$expandedPointers = 0
try {
    foreach ($file in $hydrated) {
        $entry = $zip.GetEntry($file.name)
        if (-not $entry) { throw 'LFS entry is absent from the source archive.' }
        # Some Git/LFS installations already expand entries during archive. Both paths
        # must pass the same byte hashes below; never assume a pointer is present.
        if ($entry.Length -eq $file.bytes) { continue }
        if ($entry.Length -gt 1024) { throw 'LFS archive entry has an unexpected size.' }
        $stream = $entry.Open(); $reader = [IO.StreamReader]::new($stream,[Text.Encoding]::UTF8)
        try { $pointer = $reader.ReadToEnd() } finally { $reader.Dispose() }
        if ($pointer -notmatch '(?m)^version https://git-lfs.github.com/spec/v1\r?$' -or
            $pointer -notmatch "(?m)^oid sha256:$($file.sha256)\r?`$" -or $pointer -notmatch "(?m)^size $($file.bytes)\r?`$") { throw 'Archived LFS pointer differs from the pinned object.' }
        $entry.Delete()
        $new = $zip.CreateEntry($file.name,[IO.Compression.CompressionLevel]::Optimal)
        $input = [IO.File]::OpenRead($file.object); $output = $new.Open()
        try { $input.CopyTo($output) } finally { $input.Dispose();$output.Dispose() }
        $expandedPointers++
    }
} finally { $zip.Dispose() }
$zip = [IO.Compression.ZipFile]::OpenRead($pending)
try {
    foreach ($file in $hydrated) {
        $entry = $zip.GetEntry($file.name)
        if ($entry.Length -ne $file.bytes) { throw 'Hydrated LFS archive size mismatch.' }
        $stream = $entry.Open();$sha = [Security.Cryptography.SHA256]::Create()
        try { $hash = [Convert]::ToHexString($sha.ComputeHash($stream)).ToLowerInvariant() }
        finally { $stream.Dispose();$sha.Dispose() }
        if ($hash -ne $file.sha256) { throw 'Hydrated LFS archive hash mismatch.' }
    }
    foreach ($entry in $zip.Entries) {
        if ($entry.Length -in 1..1024 -and -not $entry.FullName.EndsWith('/')) {
            $reader = [IO.StreamReader]::new($entry.Open(),[Text.Encoding]::UTF8)
            try { $text = $reader.ReadToEnd() } finally { $reader.Dispose() }
            if ($text -match '^version https://git-lfs.github.com/spec/v1\r?\n') { throw 'An unresolved LFS pointer remains in the source archive.' }
        }
    }
} finally { $zip.Dispose() }
Move-Item -LiteralPath $pending -Destination $destination
[ordered]@{sourceCommit=$Commit;target=$Target;file=[IO.Path]::GetFileName($destination);sha256=(Get-FileHash -LiteralPath $destination).Hash.ToLowerInvariant();
    lfsObjects=$hydrated.Count;lfsBytes=[long]($hydrated | ForEach-Object { [long]$_.bytes } | Measure-Object -Sum).Sum;expandedPointers=$expandedPointers;unresolvedLfsPointers=0;scope='Source bytes and LFS hashes; no portability or playback QA'} |
    ConvertTo-Json | Set-Content -LiteralPath ($destination + '.inspection.json') -Encoding utf8
Write-Output "Pinned $Target source archive verified, $($hydrated.Count) LFS objects checked and $expandedPointers pointers expanded."
