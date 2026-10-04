$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$attempts = @(Get-ChildItem (Join-Path $workspace 'artifacts') -Recurse -Filter result.json |
    ForEach-Object {
        $result = Get-Content $_.FullName -Raw | ConvertFrom-Json
        [ordered]@{
            target = $result.target
            label = $result.label
            commit = $result.upstreamCommit
            startedAtUtc = $result.startedAtUtc
            finishedAtUtc = $result.finishedAtUtc
            status = $result.status
            exitCode = $result.exitCode
            durationSeconds = $result.durationSeconds
            tasks = $result.tasks
            trackedSourcesUnmodified = ($result.trackedChangesBefore.Count -eq 0 -and
                $result.trackedChangesAfter.Count -eq 0)
            localRecord = [IO.Path]::GetRelativePath($workspace, $_.FullName).Replace('\', '/')
        }
    })
$totals = foreach ($target in @('desktop', 'tv')) {
    $xmlPath = if ($target -eq 'desktop') { 'composeApp/build/test-results/desktopTest' }
        else { 'app/build/test-results/testFullDebugUnitTest' }
    $testCount = 0; $failureCount = 0; $errorCount = 0; $skippedCount = 0
    $files = @(Get-ChildItem (Join-Path $workspace "repos/$target/$xmlPath") -Filter 'TEST-*.xml' -ErrorAction SilentlyContinue)
    foreach ($file in $files) {
        $suite = ([xml](Get-Content $file.FullName -Raw)).testsuite
        $testCount += [int]$suite.tests; $failureCount += [int]$suite.failures
        $errorCount += [int]$suite.errors; $skippedCount += [int]$suite.skipped
    }
    [ordered]@{target=$target; testResultFiles=$files.Count; tests=$testCount;
        failures=$failureCount; errors=$errorCount; skipped=$skippedCount;
        note='Latest local XML results; inspect attempt status before treating as complete.'}
}
[ordered]@{exportedAtUtc=[DateTime]::UtcNow.ToString('o');attempts=$attempts;latestTestResults=@($totals)} |
    ConvertTo-Json -Depth 7 | Set-Content -LiteralPath (Join-Path $workspace 'docs/baseline-results.json') -Encoding utf8
Write-Output 'Baseline outcomes exported without credentials or full build logs.'
