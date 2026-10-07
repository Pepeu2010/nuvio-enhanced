[CmdletBinding()]
param(
    [ValidateSet('720','1080','2160')][string]$Resolution = '1080',
    [ValidateSet('movie','live-design','home','timed-metadata','cache-settings','profile-studio','profile-selection')][string]$Suite = 'movie',
    [ValidatePattern('^[a-z0-9-]+$')][string]$EvidenceLabel,
    [ValidateRange(1,100)][int]$ExpectedTests = 3,
    [switch]$Install
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$adb = Join-Path $env:LOCALAPPDATA 'Android/Sdk/platform-tools/adb.exe'
$serial = 'emulator-5568'
$appId = 'io.github.pepeu2010.telumia.tv.debug'
$checkout = Join-Path $workspace 'repos/tv'
$label = switch ($Suite) { 'movie' { 'cinematic-tv-ui' }; 'live-design' { 'live-design-tv-ui' }; 'home' { 'telumia-home-tv-ui' }; 'timed-metadata' { 'telumia-timed-tv-ui' }; 'cache-settings' { 'telumia-cache-tv-ui' }; 'profile-studio' { 'telumia-studio-tv-ui' }; 'profile-selection' { 'telumia-profile-selection-tv-ui' } }
$output = Join-Path $workspace "artifacts/$label-$Resolution"
if ($EvidenceLabel) { $output = Join-Path $workspace "artifacts/$EvidenceLabel-$Resolution" }
if (Test-Path -LiteralPath (Join-Path $output 'qa.json')) { throw 'Refusing to overwrite existing native QA evidence. Choose a new EvidenceLabel.' }
New-Item -ItemType Directory -Force -Path $output | Out-Null
$state = & $adb -s $serial get-state 2>&1
if ($LASTEXITCODE -ne 0 -or $state -ne 'device') { throw 'The owned TV emulator on port 5568 must be running.' }
$avd = & $adb -s $serial emu avd name
if ($avd[0] -ne 'NuvioEnhanced_ATV_01a10441') { throw 'Refusing to change another emulator.' }
$apk = Join-Path $checkout 'app/build/outputs/apk/full/debug/app-full-universal-debug.apk'
$testApk = Join-Path $checkout 'app/build/outputs/apk/androidTest/full/debug/app-full-debug-androidTest.apk'
if ($Install) {
    foreach ($file in @($apk, $testApk)) {
        if (-not (Test-Path -LiteralPath $file)) { throw "Missing compiled package: $file" }
        & $adb -s $serial install -r $file
        if ($LASTEXITCODE -ne 0) { throw 'Package installation failed.' }
    }
}
$dimensions = switch ($Resolution) { '720' { '1280x720' }; '1080' { '1920x1080' }; '2160' { '3840x2160' } }
$density = if ($Resolution -eq '2160') { 640 } else { 320 }
$record = [ordered]@{
    startedAtUtc = [DateTime]::UtcNow.ToString('o')
    sourceCommit = (git -C $checkout rev-parse HEAD).Trim()
    trackedChanges = @(git -C $checkout status --porcelain --untracked-files=no)
    sourceChanges = @(git -C $checkout status --porcelain)
    apkSha256 = (Get-FileHash -LiteralPath $apk).Hash.ToLowerInvariant()
    testApkSha256 = (Get-FileHash -LiteralPath $testApk).Hash.ToLowerInvariant()
    emulator = $avd[0]
    requestedPixels = $dimensions
    density = $density
    suite = $Suite
    scope = 'Owned emulator, native component fixtures and D-pad; no playback, channel availability or physical TV performance claim'
    status = 'running'
}
try {
    & $adb -s $serial shell wm size $dimensions
    & $adb -s $serial shell wm density $density
    $record['displayReported'] = @(& $adb -s $serial shell wm size)
    $testClass = switch ($Suite) {
        'movie' { 'com.nuvio.tv.ui.screens.detail.CinematicMovieHeroTvTest' }
        'live-design' { 'com.nuvio.tv.ui.components.LiveTvVisualComponentsTest' }
        'home' { 'com.nuvio.tv.ui.screens.home.TelumiaHomeHeroTvTest' }
        'timed-metadata' { 'com.nuvio.tv.ui.screens.player.TimedMetadataTimelineTvTest' }
        'cache-settings' { 'com.nuvio.tv.ui.screens.settings.MediaCacheSettingsTvTest' }
        'profile-studio' { 'com.nuvio.tv.ui.screens.profile.ProfileStudioAvatarEditorTvTest' }
        'profile-selection' { 'com.nuvio.tv.ui.screens.profile.TelumiaProfileSelectionTvTest' }
    }
    $log = & $adb -s $serial shell am instrument -w -r -e class $testClass "$appId.test/androidx.test.runner.AndroidJUnitRunner" 2>&1
    $log | Set-Content -LiteralPath (Join-Path $output 'instrumentation.log') -Encoding utf8
    $text = $log -join "`n"
    if ($text -notmatch "OK \($ExpectedTests tests\)" -or $text -match 'INSTRUMENTATION_STATUS_CODE: -2|FAILURES!!!') { throw "Native UI instrumentation did not pass all $ExpectedTests tests. See the local instrumentation log." }
    $capture = Join-Path $output 'movie-hero.png'
    $screenshot = switch ($Suite) {
        'movie' { 'cinematic-movie-hero-tv.png' }
        'live-design' { 'live-guide-components.png' }
        'home' { 'telumia-home-hero-tv.png' }
        'timed-metadata' { 'telumia-timed-timeline-tv.png' }
        'cache-settings' { 'telumia-cache-settings-tv.png' }
        'profile-studio' { 'telumia-studio-library-tv.png' }
        'profile-selection' { 'telumia-profile-selection-tv.png' }
    }
    & $adb -s $serial pull "/sdcard/Android/data/$appId/files/$screenshot" $capture
    if ($LASTEXITCODE -ne 0) { throw 'Fixture screenshot could not be exported.' }
    $bytes = [IO.File]::ReadAllBytes($capture)
    if ($bytes.Length -lt 24 -or $bytes[0] -ne 137 -or $bytes[1] -ne 80) { throw 'Fixture screenshot is not a PNG.' }
    $width = [int64]$bytes[16] * 16777216 + [int64]$bytes[17] * 65536 + [int64]$bytes[18] * 256 + $bytes[19]
    $height = [int64]$bytes[20] * 16777216 + [int64]$bytes[21] * 65536 + [int64]$bytes[22] * 256 + $bytes[23]
    $record['capturedPixels'] = "${width}x${height}"
    if ($record.capturedPixels -ne $dimensions) { throw 'Actual framebuffer differs from the requested viewport; this is not a valid resolution gate.' }
    if ($Suite -eq 'profile-selection' -and $ExpectedTests -ge 4) {
        $cover = Join-Path $output 'profile-cover.png'
        & $adb -s $serial pull "/sdcard/Android/data/$appId/files/telumia-profile-selection-cover-tv.png" $cover
        if ($LASTEXITCODE -ne 0) { throw 'Profile cover screenshot could not be exported.' }
        $coverBytes = [IO.File]::ReadAllBytes($cover)
        if ($coverBytes.Length -lt 24 -or $coverBytes[0] -ne 137 -or $coverBytes[1] -ne 80) { throw 'Profile cover capture is not PNG.' }
        $coverWidth = [int64]$coverBytes[16]*16777216 + [int64]$coverBytes[17]*65536 + [int64]$coverBytes[18]*256 + $coverBytes[19]
        $coverHeight = [int64]$coverBytes[20]*16777216 + [int64]$coverBytes[21]*65536 + [int64]$coverBytes[22]*256 + $coverBytes[23]
        if ("${coverWidth}x${coverHeight}" -ne $dimensions) { throw 'Profile cover framebuffer differs from requested viewport.' }
        $record['coverCapturedPixels'] = "${coverWidth}x${coverHeight}"
    }
    if ($Suite -eq 'profile-studio') {
        $crop = Join-Path $output 'avatar-crop.png'
        & $adb -s $serial pull "/sdcard/Android/data/$appId/files/telumia-studio-crop-tv.png" $crop
        if ($LASTEXITCODE -ne 0) { throw 'Avatar crop screenshot could not be exported.' }
        $cropBytes = [IO.File]::ReadAllBytes($crop)
        if ($cropBytes.Length -lt 24 -or $cropBytes[0] -ne 137 -or $cropBytes[1] -ne 80) { throw 'Avatar crop screenshot is not PNG.' }
        $cropWidth = [int64]$cropBytes[16]*16777216 + [int64]$cropBytes[17]*65536 + [int64]$cropBytes[18]*256 + $cropBytes[19]
        $cropHeight = [int64]$cropBytes[20]*16777216 + [int64]$cropBytes[21]*65536 + [int64]$cropBytes[22]*256 + $cropBytes[23]
        if ("${cropWidth}x${cropHeight}" -ne $dimensions) { throw 'Avatar crop framebuffer differs from the requested viewport.' }
        $record['cropCapturedPixels'] = "${cropWidth}x${cropHeight}"
        if ($ExpectedTests -ge 5) {
            foreach ($extra in @('device-photos','full-dialog')) {
                $extraFile = Join-Path $output "avatar-$extra.png"
                & $adb -s $serial pull "/sdcard/Android/data/$appId/files/telumia-studio-$extra-tv.png" $extraFile
                if ($LASTEXITCODE -ne 0) { throw "Could not export $extra screenshot." }
                $imageBytes = [IO.File]::ReadAllBytes($extraFile)
                if ($imageBytes.Length -lt 24 -or $imageBytes[0] -ne 137 -or $imageBytes[1] -ne 80) { throw "$extra screenshot is not PNG." }
                $imageWidth = [int64]$imageBytes[16]*16777216 + [int64]$imageBytes[17]*65536 + [int64]$imageBytes[18]*256 + $imageBytes[19]
                $imageHeight = [int64]$imageBytes[20]*16777216 + [int64]$imageBytes[21]*65536 + [int64]$imageBytes[22]*256 + $imageBytes[23]
                if ("${imageWidth}x${imageHeight}" -ne $dimensions) { throw "$extra framebuffer differs from requested viewport." }
                $record["${extra}CapturedPixels"] = "${imageWidth}x${imageHeight}"
            }
        }
    }
    $record['testsPassed'] = $ExpectedTests
    $record['status'] = 'passed'
} catch {
    $record['status'] = 'failed'
    $record['failure'] = $_.Exception.Message
    throw
} finally {
    & $adb -s $serial shell wm size reset
    & $adb -s $serial shell wm density reset
    $record['finishedAtUtc'] = [DateTime]::UtcNow.ToString('o')
    $record | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $output 'qa.json') -Encoding utf8
}
Write-Output "Native $Suite components: $ExpectedTests tests passed at $dimensions; actual capture dimensions verified."
