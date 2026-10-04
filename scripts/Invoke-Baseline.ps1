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
    status = 'running'
}
$recordPath = Join-Path $outputDir 'result.json'
$record | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $recordPath -Encoding utf8
$timer = [Diagnostics.Stopwatch]::StartNew()
Push-Location $checkout
try {
    & .\gradlew.bat @Tasks @GradleArgs --continue --no-daemon --max-workers=1 "-Dorg.gradle.jvmargs=-Xmx${HeapMiB}m -XX:MaxMetaspaceSize=768m -Dfile.encoding=UTF-8" "-Pkotlin.daemon.jvmargs=-Xmx${KotlinHeapMiB}m" 2>&1 |
        Tee-Object -FilePath (Join-Path $outputDir 'build.log')
    $buildExit = $LASTEXITCODE
} finally {
    Pop-Location
    $timer.Stop()
    $record['finishedAtUtc'] = [DateTime]::UtcNow.ToString('o')
    $record['durationSeconds'] = [Math]::Round($timer.Elapsed.TotalSeconds, 2)
    $record['exitCode'] = if ($null -eq $buildExit) { -1 } else { $buildExit }
    $record['trackedChangesAfter'] = @(git -C $checkout status --porcelain --untracked-files=no)
    $record['status'] = if ($buildExit -eq 0) { 'passed' } else { 'failed' }
    $record | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $recordPath -Encoding utf8
}
exit $buildExit
