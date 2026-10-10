[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[a-z0-9-]+$')][string]$BuildLabel,
    [Parameter(Mandatory)][ValidatePattern('^[a-z0-9-]+$')][string]$EvidenceLabel,
    [ValidateSet('24','36')][string]$AndroidApi = '24'
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$checkout = Join-Path $workspace 'repos/tv'
$adb = Join-Path $env:LOCALAPPDATA 'Android/Sdk/platform-tools/adb.exe'
$serial = if ($AndroidApi -eq '24') { 'emulator-5570' } else { 'emulator-5568' }
$expectedAvd = if ($AndroidApi -eq '24') { 'Telumia_API24_01a10441' } else { 'NuvioEnhanced_ATV_01a10441' }
$appId = 'io.github.pepeu2010.telumia.tv.debug'
$component = "$appId/com.nuvio.tv.MainActivity"
$output = Join-Path $workspace "artifacts/$EvidenceLabel"
if (Test-Path -LiteralPath $output) { throw 'Choose a new startup evidence label; existing evidence is preserved.' }
$binding = Get-Content -LiteralPath (Join-Path $workspace "docs/$BuildLabel-build-binding.json") -Raw | ConvertFrom-Json
$head = (git -C $checkout rev-parse HEAD).Trim()
if ($binding.buildStatus -ne 'passed' -or $binding.sourceCommit -ne $head -or @(git -C $checkout status --porcelain).Count) {
    throw 'Startup requires a passed preserved build of the current clean checkout.'
}
$package = $binding.packages | Where-Object file -eq 'app-full-universal-debug.apk'
$apk = Join-Path $workspace $package.path
if ((Get-FileHash -LiteralPath $apk).Hash.ToLowerInvariant() -ne $package.sha256) { throw 'Preserved APK hash mismatch.' }
$avd = @(& $adb -s $serial emu avd name)
if ($LASTEXITCODE -ne 0 -or $avd[0] -ne $expectedAvd) { throw 'Startup must use the owned test emulator.' }
$api = ((& $adb -s $serial shell getprop ro.build.version.sdk) -join '').Trim()
if ($LASTEXITCODE -ne 0 -or $api -ne $AndroidApi) { throw 'Unexpected Android API.' }
New-Item -ItemType Directory -Path $output | Out-Null
$record = [ordered]@{
    startedAtUtc = [DateTime]::UtcNow.ToString('o'); sourceCommit = $head; buildLabel = $BuildLabel
    emulator = $avd[0]; androidApi = $api; apkSha256 = $package.sha256; status = 'running'
    scope = 'Owned test AVD, real MainActivity startup and 30-second process/resumed/crash checks. No login, account sync, playback, full navigation or physical-device performance proof. Screenshot and raw device logs remain private.'
}
try {
    & $adb -s $serial install -r $apk | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'APK installation failed.' }
    & $adb -s $serial shell am force-stop $appId
    & $adb -s $serial logcat -c
    if ($LASTEXITCODE -ne 0) { throw 'Owned device log reset failed.' }
    & $adb -s $serial logcat -b events -c
    if ($LASTEXITCODE -ne 0) { throw 'Owned device event log reset failed.' }
    & $adb -s $serial shell am start -W -n $component | Set-Content -LiteralPath (Join-Path $output 'launch.log') -Encoding utf8
    if ($LASTEXITCODE -ne 0) { throw 'MainActivity launch failed.' }
    Start-Sleep -Seconds 30
    $processIds = ((& $adb -s $serial shell pidof $appId) -join '').Trim()
    if ($LASTEXITCODE -ne 0 -or $processIds -notmatch '^\d+( \d+)*$') { throw 'App process did not survive startup.' }
    $activities = @(& $adb -s $serial shell dumpsys activity activities)
    $resumed = @($activities | Where-Object { $_ -match 'mResumedActivity|ResumedActivity|topResumedActivity' -and $_.Contains($component) }).Count -gt 0
    if (-not $resumed) { throw 'The real MainActivity is not resumed after startup.' }
    $crashLog = @(& $adb -s $serial logcat -d -b crash)
    $crashLog | Set-Content -LiteralPath (Join-Path $output 'crash-private.log') -Encoding utf8
    if (@($crashLog | Where-Object { $_ -match ('Process: ' + [regex]::Escape($appId) + ',') }).Count) { throw 'App crash was recorded during startup.' }
    $events = @(& $adb -s $serial logcat -d -b events)
    if ($LASTEXITCODE -ne 0) { throw 'Owned device event log could not be inspected.' }
    $events | Set-Content -LiteralPath (Join-Path $output 'events-private.log') -Encoding utf8
    if (@($events | Where-Object { $_ -match '\bam_anr\b' -and $_.Contains($appId) }).Count) {
        throw 'App ANR was recorded during the current startup gate.'
    }
    $deviceCapture = "/sdcard/$EvidenceLabel.png"
    & $adb -s $serial shell screencap -p $deviceCapture
    if ($LASTEXITCODE -ne 0) { throw 'Startup screenshot failed.' }
    $capture = Join-Path $output 'startup-private.png'
    & $adb -s $serial pull $deviceCapture $capture 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Startup screenshot export failed.' }
    $record['processAliveAfterSeconds'] = 30
    $record['mainActivityResumed'] = $resumed
    $record['appCrashRecorded'] = $false
    $record['appAnrRecorded'] = $false
    $record['privateCaptureSha256'] = (Get-FileHash -LiteralPath $capture).Hash.ToLowerInvariant()
    $record['status'] = 'passed'
    Write-Output "Real MainActivity survived startup on owned Android API $api. Private evidence retained."
} catch {
    $record['status'] = 'failed'
    $record['failure'] = $_.Exception.Message
    throw
} finally {
    $record['finishedAtUtc'] = [DateTime]::UtcNow.ToString('o')
    $record | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $output 'qa.json') -Encoding utf8
}
