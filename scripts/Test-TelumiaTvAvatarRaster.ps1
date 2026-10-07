[CmdletBinding()]
param([switch]$Install, [ValidatePattern('^[a-z0-9-]+$')][string]$Label = 'telumia-tv-avatar-raster-native', [ValidateRange(1,20)][int]$ExpectedTests = 3)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$checkout = Join-Path $workspace 'repos/tv'
$adb = Join-Path $env:LOCALAPPDATA 'Android/Sdk/platform-tools/adb.exe'
$serial = 'emulator-5568'
$appId = 'io.github.pepeu2010.telumia.tv.debug'
$state = & $adb -s $serial get-state 2>&1
if ($LASTEXITCODE -ne 0 -or $state -ne 'device') { throw 'Owned TV emulator must be running.' }
$avd = & $adb -s $serial emu avd name
if ($avd[0] -ne 'NuvioEnhanced_ATV_01a10441') { throw 'Refusing to operate another emulator.' }
$output = Join-Path $workspace "artifacts/$Label"
if (Test-Path -LiteralPath $output) { throw 'Use a new label; native evidence cannot be replaced.' }
New-Item -ItemType Directory -Path $output | Out-Null
$apk = Join-Path $checkout 'app/build/outputs/apk/full/debug/app-full-universal-debug.apk'
$testApk = Join-Path $checkout 'app/build/outputs/apk/androidTest/full/debug/app-full-debug-androidTest.apk'
foreach ($file in @($apk,$testApk)) { if (-not (Test-Path -LiteralPath $file)) { throw 'Compiled app/test APK missing.' } }
$record = [ordered]@{
    startedAtUtc=[DateTime]::UtcNow.ToString('o');status='running'
    sourceCommit=(git -C $checkout rev-parse HEAD).Trim()
    sourceChanges=@(git -C $checkout status --porcelain)
    apkSha256=(Get-FileHash $apk).Hash.ToLowerInvariant()
    testApkSha256=(Get-FileHash $testApk).Hash.ToLowerInvariant()
    emulator=$avd[0]
    androidApi=((& $adb -s $serial shell getprop ro.build.version.sdk) -join '').Trim()
    class='com.nuvio.tv.core.profile.studio.AvatarRasterPipelineTvTest'
    scope='Production Android Bitmap decoder/crop/EXIF/bounds on the owned emulator with synthetic rasters; no UI, import gesture, profile persistence or physical device performance claim'
}
try {
    if ($Install) {
        foreach ($file in @($apk,$testApk)) {
            $null = & $adb -s $serial install -r $file
            if ($LASTEXITCODE -ne 0) { throw 'Owned package installation failed.' }
        }
    }
    $log = & $adb -s $serial shell am instrument -w -r -e class $record.class "$appId.test/androidx.test.runner.AndroidJUnitRunner" 2>&1
    $log | Set-Content (Join-Path $output 'instrumentation.log') -Encoding utf8
    $text = $log -join "`n"
    if ($text -notmatch "OK \($ExpectedTests tests\)" -or $text -match 'FAILURES!!!|INSTRUMENTATION_FAILED|Process crashed|Test run failed|INSTRUMENTATION_STATUS_CODE: -2') {
        throw 'Native raster tests did not pass; see the private instrumentation log.'
    }
    $record.testsPassed=$ExpectedTests
    $record.status='passed'
} catch {
    $record.status='failed'
    $record.failure=$_.Exception.Message
    throw
} finally {
    $record.finishedAtUtc=[DateTime]::UtcNow.ToString('o')
    $record | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $output 'qa.json') -Encoding utf8
}
Write-Output "$ExpectedTests real Android raster/crop/bounds/EXIF tests passed; no UI completion claim."
