[CmdletBinding()]
param([ValidatePattern('^v[0-9]+\.[0-9]+\.[0-9]+-alpha\.[0-9]+$')][string]$Tag = 'v0.2.0-alpha.1')
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$output = Join-Path $workspace "artifacts/releases/$Tag"
$verification = Get-Content (Join-Path $workspace 'docs/telumia-results.json') -Raw | ConvertFrom-Json
foreach ($result in $verification.results) {
    $last = $result.attempts | Sort-Object startedAtUtc | Select-Object -Last 1
    if ($last.status -ne 'passed' -or -not $result.targetedTestResults -or
        $result.targetedTestResults.failures -ne 0 -or $result.targetedTestResults.errors -ne 0) {
        throw "Release preparation requires passing current gates: $($result.target)"
    }
    $checkout = Join-Path $workspace "repos/$($result.target)"
    $head = (git -C $checkout rev-parse HEAD).Trim()
    if ($head -ne $result.currentSourceCommit -or @(git -C $checkout status --porcelain).Count) {
        throw "Source must be committed and match the gate record: $($result.target)"
    }
}
New-Item -ItemType Directory -Force -Path $output | Out-Null
$inspection = Get-Content (Join-Path $workspace 'docs/telumia-package-inspection.json') -Raw | ConvertFrom-Json
$pc = $inspection.results | Where-Object target -eq desktop
$tv = $inspection.results | Where-Object target -eq tv
$msi = Join-Path $workspace "repos/desktop/composeApp/build/compose/release-msis/$($pc.artifacts[0].file)"
Copy-Item -LiteralPath $msi -Destination (Join-Path $output 'Telumia-Windows-x64.msi')
foreach ($apk in $tv.artifacts) {
    $abi = [regex]::Match($apk.file, '^app-full-(.+)-debug\.apk$').Groups[1].Value
    if ($abi -notin @('universal','arm64-v8a','armeabi-v7a','x86','x86_64')) { throw "Unexpected ABI: $abi" }
    Copy-Item -LiteralPath (Join-Path $workspace "repos/tv/app/build/outputs/apk/full/debug/$($apk.file)") `
        -Destination (Join-Path $output "Telumia-TV-$abi-debug.apk")
}
foreach ($target in @('desktop','tv')) {
    git -C (Join-Path $workspace "repos/$target") archive --format=zip "--output=$(Join-Path $output "Telumia-$target-source.zip")" HEAD
    if ($LASTEXITCODE -ne 0) { throw "Source archive failed: $target" }
}
$assets = @(Get-ChildItem -LiteralPath $output -File | Where-Object Extension -in @('.msi','.apk','.zip') | ForEach-Object {
    [ordered]@{name=$_.Name;bytes=$_.Length;sha256=(Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}
})
if ($assets.Count -ne 8) { throw 'Expected MSI, five APKs and two source archives.' }
$manifest = [ordered]@{tag=$Tag;product='Telumia';preparedAtUtc=[DateTime]::UtcNow.ToString('o');
    sourceCommits=@{desktop=$pc.sourceCommit;tv=$tv.sourceCommit};
    scope='Experimental branding, Brazil catalog and native motion increment; full approved product remains incomplete';assets=$assets}
$manifest | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $output 'release-manifest.json') -Encoding utf8
$assets | ForEach-Object { "$($_.sha256)  $($_.name)" } | Set-Content (Join-Path $output 'SHA256SUMS.txt') -Encoding ascii
Write-Output "Prepared 10 release assets in $output; publishing is a separate step."
