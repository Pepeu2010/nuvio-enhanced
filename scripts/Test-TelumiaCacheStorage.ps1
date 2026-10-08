[CmdletBinding()]
param(
    [ValidateSet('24','36')][string]$AndroidApi = '36',
    [Parameter(Mandatory)][ValidatePattern('^[a-z0-9-]+$')][string]$Label,
    [switch]$Install,
    [switch]$DisplayFonts
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$checkout = Join-Path $workspace 'repos/tv'
$adb = Join-Path $env:LOCALAPPDATA 'Android/Sdk/platform-tools/adb.exe'
$serial = if ($AndroidApi -eq '24') { 'emulator-5570' } else { 'emulator-5568' }
$expectedAvd = if ($AndroidApi -eq '24') { 'Telumia_API24_01a10441' } else { 'NuvioEnhanced_ATV_01a10441' }
$appId = 'io.github.pepeu2010.telumia.tv.debug'
$state = & $adb -s $serial get-state 2>&1
if ($LASTEXITCODE -ne 0 -or $state -ne 'device') { throw 'The owned TV emulator must be running.' }
$avd = & $adb -s $serial emu avd name
if ($avd[0] -ne $expectedAvd) { throw 'Refusing to operate another emulator.' }
$actualApi = ((& $adb -s $serial shell getprop ro.build.version.sdk) -join '').Trim()
if ($actualApi -ne $AndroidApi) { throw 'The actual Android API differs from the requested test gate.' }
$output = Join-Path $workspace "artifacts/$Label"
if (Test-Path -LiteralPath $output) { throw 'Use a new label; native evidence cannot be replaced.' }
New-Item -ItemType Directory -Path $output | Out-Null
$apk = Join-Path $checkout 'app/build/outputs/apk/full/debug/app-full-universal-debug.apk'
$testApk = Join-Path $checkout 'app/build/outputs/apk/androidTest/full/debug/app-full-debug-androidTest.apk'
foreach ($file in @($apk,$testApk)) { if (-not (Test-Path -LiteralPath $file)) { throw 'Compiled app/test APK missing.' } }
$classes = 'com.nuvio.tv.ui.screens.settings.MediaCacheSettingsTvTest'
$expectedTests = 6
if ($DisplayFonts) {
    $classes += ',com.nuvio.tv.ui.theme.NativeDisplayFontTvTest'
    $expectedTests += 2
}
$record = [ordered]@{
    startedAtUtc=[DateTime]::UtcNow.ToString('o');status='running'
    sourceCommit=(git -C $checkout rev-parse HEAD).Trim()
    sourceChanges=@(git -C $checkout status --porcelain)
    apkSha256=(Get-FileHash $apk).Hash.ToLowerInvariant()
    testApkSha256=(Get-FileHash $testApk).Hash.ToLowerInvariant()
    emulator=$avd[0];androidApi=$actualApi
    class=$classes
    expectedTests=$expectedTests
    scope='Real SharedPreferences, bounded NIO occupancy/symlink exclusion, budget wiring and D-pad cache controls in isolated fixtures. With DisplayFonts: APK font hashes and actual Android font-loader raster weights. No personal preferences, playback, offline session or physical performance claim.'
}
try {
    if ($Install) {
        foreach ($file in @($apk,$testApk)) {
            $installation = & $adb -s $serial install -r $file 2>&1
            $installation | Add-Content (Join-Path $output 'install.log')
            if ($LASTEXITCODE -ne 0) { throw 'Owned package installation failed; see private install log.' }
        }
    }
    $log = & $adb -s $serial shell am instrument -w -r -e class $record.class "$appId.test/androidx.test.runner.AndroidJUnitRunner" 2>&1
    $log | Set-Content (Join-Path $output 'instrumentation.log') -Encoding utf8
    $text = $log -join "`n"
    if ($text -notmatch "OK \($expectedTests tests\)" -or $text -match 'FAILURES!!!|INSTRUMENTATION_FAILED|Process crashed|Test run failed|INSTRUMENTATION_STATUS_CODE: -2') {
        throw 'Native cache tests did not pass; see the private instrumentation log.'
    }
    $record.testsPassed=$expectedTests
    $record.status='passed'
} catch {
    $record.status='failed'
    $record.failure=$_.Exception.Message
    throw
} finally {
    $record.finishedAtUtc=[DateTime]::UtcNow.ToString('o')
    $record | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $output 'qa.json') -Encoding utf8
}
Write-Output "$expectedTests native cache/font tests passed on Android API $AndroidApi."
