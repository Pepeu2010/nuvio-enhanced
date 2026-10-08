[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('desktop','tv')][string]$Target,
    [Parameter(Mandatory)][ValidatePattern('^[a-z0-9-]+$')][string]$Label
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$checkout = Join-Path $workspace "repos/$Target"
$output = Join-Path $workspace "artifacts/$Label/$Target"
$result = Get-Content (Join-Path $output 'result.json') -Raw | ConvertFrom-Json
$head = (git -C $checkout rev-parse HEAD).Trim()
if ($result.status -ne 'passed' -or $result.upstreamCommit -ne $head -or
    $result.sourceChangesBefore.Count -or $result.sourceChangesAfter.Count -or
    @(git -C $checkout status --porcelain).Count) { throw 'A successful clean-source build of the current commit is required.' }
$destination = Join-Path $output 'package'
if (Test-Path -LiteralPath $destination) { throw 'Preserved packages cannot be replaced; use a new build label.' }
$files = @(if ($Target -eq 'desktop') {
    $versionLine = Get-Content (Join-Path $checkout 'composeApp/Configuration/DesktopVersion.properties') | Where-Object { $_ -match '^VERSION_NAME=' }
    $versionName = ($versionLine -replace '^VERSION_NAME=','').Trim()
    if ($versionName -notmatch '^[a-zA-Z0-9.-]+$') { throw 'Invalid desktop version name.' }
    @(Get-Item (Join-Path $checkout "composeApp/build/compose/release-msis/Telumia-Windows-x64-$versionName.msi"))
} else {
    @(Get-ChildItem (Join-Path $checkout 'app/build/outputs/apk/full/debug') -Filter '*.apk') +
    @(Get-Item (Join-Path $checkout 'app/build/outputs/apk/androidTest/full/debug/app-full-debug-androidTest.apk'))
})
if (($Target -eq 'desktop' -and $files.Count -ne 1) -or ($Target -eq 'tv' -and $files.Count -ne 6)) { throw 'The expected MSI or five app APKs plus test APK are required.' }
New-Item -ItemType Directory -Path $destination | Out-Null
$records = foreach ($file in $files) {
    $saved = Join-Path $destination $file.Name
    Copy-Item -LiteralPath $file.FullName -Destination $saved
    $hash = (Get-FileHash -LiteralPath $file.FullName).Hash.ToLowerInvariant()
    if ((Get-FileHash -LiteralPath $saved).Hash.ToLowerInvariant() -ne $hash) { throw 'Preserved package hash mismatch.' }
    [ordered]@{file=$file.Name;bytes=$file.Length;sha256=$hash;path="artifacts/$Label/$Target/package/$($file.Name)"}
}
[ordered]@{exportedAtUtc=[DateTime]::UtcNow.ToString('o');label=$Label;target=$Target;sourceCommit=$head;
    buildStatus=$result.status;sourceChangesBefore=$result.sourceChangesBefore;sourceChangesAfter=$result.sourceChangesAfter;
    junitSummary=$result.junitSummary;scope='Clean-source build and preserved package hashes. Development packages are not a new published release; installation/playback/device claims require separate evidence.';
    packages=@($records)} | ConvertTo-Json -Depth 7 | Set-Content (Join-Path $workspace "docs/$Label-build-binding.json") -Encoding utf8
Write-Output "Preserved and bound $($files.Count) compiled $Target packages to $head."
