[CmdletBinding()]
param([string]$LabelPrefix = 'foundation')
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$attempts = @(Get-ChildItem (Join-Path $workspace 'artifacts') -Recurse -Filter result.json |
    ForEach-Object { Get-Content $_.FullName -Raw | ConvertFrom-Json } |
    Where-Object { $_.label -is [string] -and $_.label.StartsWith($LabelPrefix) })
$results = foreach ($target in @('desktop','tv')) {
    $runs = @($attempts | Where-Object target -eq $target)
    $testTask = if ($target -eq 'desktop') { ':composeApp:desktopTest' } else { ':app:testFullDebugUnitTest' }
    $testRun = $runs | Where-Object { $_.tasks -contains $testTask } | Sort-Object startedAtUtc | Select-Object -Last 1
    $tests = $null
    if ($testRun.status -eq 'passed') {
        if ($testRun.junitSummary) {
            $tests = $testRun.junitSummary
        } else {
        $relative = if ($target -eq 'desktop') { 'composeApp/build/test-results/desktopTest' } else { 'app/build/test-results/testFullDebugUnitTest' }
        $snapshot = Join-Path $workspace "artifacts/$($testRun.label)/$target/junit-snapshot"
        $reports = if (Test-Path $snapshot) { $snapshot } else { Join-Path $workspace "repos/$target/$relative" }
        $totals = [ordered]@{tests=0;failures=0;errors=0;skipped=0;files=0;attempt=$testRun.label}
        Get-ChildItem $reports -Filter 'TEST-*.xml' | ForEach-Object {
            $suite = ([xml](Get-Content $_.FullName -Raw)).testsuite
            foreach ($key in @('tests','failures','errors','skipped')) { $totals[$key] += [int]$suite.$key }
            $totals['files']++
        }
        $tests = $totals
        }
    }
    [ordered]@{target=$target;currentSourceCommit=(git -C (Join-Path $workspace "repos/$target") rev-parse HEAD).Trim();
        attempts=@($runs | ForEach-Object { [ordered]@{label=$_.label;status=$_.status;exitCode=$_.exitCode;startedAtUtc=$_.startedAtUtc;finishedAtUtc=$_.finishedAtUtc;durationSeconds=$_.durationSeconds;tasks=$_.tasks;gradleArgs=$_.gradleArgs} });
        targetedTestResults=$tests}
}
[ordered]@{exportedAtUtc=[DateTime]::UtcNow.ToString('o');milestone=$LabelPrefix;
    scope='Targeted verification; full-suite inherited failures remain in phase-0-results.json';results=@($results)} |
    ConvertTo-Json -Depth 9 | Set-Content (Join-Path $workspace "docs/$LabelPrefix-results.json") -Encoding utf8
Write-Output "Exported $LabelPrefix validation without raw logs or credentials."
