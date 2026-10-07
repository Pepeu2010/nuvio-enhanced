[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('desktop', 'tv')][string]$Target,
    [string[]]$Tasks,
    [string[]]$GradleArgs = @(),
    [string]$JavaHome,
    [int]$HeapMiB = 4096,
    [int]$KotlinHeapMiB = 6144,
    [string]$Label = 'baseline'
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$checkout = Join-Path $workspace "repos/$Target"
$outputDir = Join-Path $workspace "artifacts/$Label/$Target"
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
if (-not $JavaHome) {
    $cached = Get-ChildItem (Join-Path $env:USERPROFILE '.gradle/jdks') -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '-17-' -and (Test-Path (Join-Path $_.FullName 'bin/java.exe')) } |
        Select-Object -First 1
    if (-not $cached) { throw 'Set -JavaHome to a JDK 17 installation.' }
    $JavaHome = $cached.FullName
}
$env:JAVA_HOME = $JavaHome
$env:PATH = "$(Join-Path $JavaHome 'bin');$env:PATH"
$env:ANDROID_HOME = Join-Path $env:LOCALAPPDATA 'Android/Sdk'
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
if (-not $Tasks) {
    $Tasks = if ($Target -eq 'desktop') {
        @(':composeApp:desktopTest', ':composeApp:packageReleaseMsi')
    } else {
        @(':app:testFullDebugUnitTest', ':app:assembleFullDebug')
    }
}
$before = @(git -C $checkout status --porcelain --untracked-files=no)
if ($Label.StartsWith('baseline') -and $before.Count) { throw 'Baseline requires an unmodified tracked checkout.' }
$record = [ordered]@{
    target = $Target
    label = $Label
    upstreamCommit = (git -C $checkout rev-parse HEAD).Trim()
    startedAtUtc = [DateTime]::UtcNow.ToString('o')
    javaHome = $JavaHome
    heapMiB = $HeapMiB
    kotlinHeapMiB = $KotlinHeapMiB
    tasks = $Tasks
    gradleArgs = $GradleArgs
    trackedChangesBefore = $before
    sourceChangesBefore = @(git -C $checkout status --porcelain)
    status = 'running'
}
$recordPath = Join-Path $outputDir 'result.json'
$record | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $recordPath -Encoding utf8
$timer = [Diagnostics.Stopwatch]::StartNew()
Push-Location $checkout
try {
    $logStream = [IO.StreamWriter]::new((Join-Path $outputDir 'build.log'), $false, [Text.UTF8Encoding]::new($false))
    try {
        & .\gradlew.bat @Tasks @GradleArgs --continue --no-daemon --max-workers=1 "-Dorg.gradle.jvmargs=-Xmx${HeapMiB}m -XX:MaxMetaspaceSize=768m -Dfile.encoding=UTF-8" "-Pkotlin.daemon.jvmargs=-Xmx${KotlinHeapMiB}m" 2>&1 |
            ForEach-Object {
                $line = $_.ToString()
                $logStream.WriteLine($line)
                if ($line -match '^> Task|^BUILD (SUCCESSFUL|FAILED)|^FAILURE:|^\d+ actionable tasks') {
                    $logStream.Flush()
                    Write-Output $line
                }
            }
        $buildExit = $LASTEXITCODE
    } finally {
        $logStream.Dispose()
    }
} finally {
    Pop-Location
    $timer.Stop()
    $record['finishedAtUtc'] = [DateTime]::UtcNow.ToString('o')
    $record['durationSeconds'] = [Math]::Round($timer.Elapsed.TotalSeconds, 2)
    $record['exitCode'] = if ($null -eq $buildExit) { -1 } else { $buildExit }
    $record['trackedChangesAfter'] = @(git -C $checkout status --porcelain --untracked-files=no)
    $record['sourceChangesAfter'] = @(git -C $checkout status --porcelain)
    $record['status'] = if ($buildExit -eq 0) { 'passed' } else { 'failed' }
    $testTask = if ($Target -eq 'desktop') { ':composeApp:desktopTest' } else { ':app:testFullDebugUnitTest' }
    $testTaskPattern = '^> Task ' + [regex]::Escape($testTask) + '(?:$| (?:FAILED|UP-TO-DATE|FROM-CACHE)$)'
    $testTaskReported = Select-String -LiteralPath (Join-Path $outputDir 'build.log') -Pattern $testTaskPattern -Quiet
    if ($Tasks -contains $testTask -and $testTaskReported) {
        $relativeTests = if ($Target -eq 'desktop') { 'composeApp/build/test-results/desktopTest' } else { 'app/build/test-results/testFullDebugUnitTest' }
        $snapshot = Join-Path $outputDir 'junit-snapshot'
        New-Item -ItemType Directory -Force $snapshot | Out-Null
        $totals = [ordered]@{ tests = 0; failures = 0; errors = 0; skipped = 0; files = 0; attempt = $Label }
        foreach ($report in Get-ChildItem (Join-Path $checkout $relativeTests) -Filter 'TEST-*.xml') {
            $suite = ([xml](Get-Content $report.FullName -Raw)).testsuite
            foreach ($key in @('tests', 'failures', 'errors', 'skipped')) { $totals[$key] += [int]$suite.$key }
            $totals['files']++
            Copy-Item -LiteralPath $report.FullName -Destination (Join-Path $snapshot $report.Name)
        }
        $record['junitSummary'] = $totals
    }
    $record | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $recordPath -Encoding utf8
}
exit $buildExit
