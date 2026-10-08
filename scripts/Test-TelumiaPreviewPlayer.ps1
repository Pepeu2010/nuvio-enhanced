[CmdletBinding()]
param(
    [ValidateSet('24','36')][string]$AndroidApi = '36',
    [Parameter(Mandatory)][ValidatePattern('^[a-z0-9-]+$')][string]$Label,
    [ValidatePattern('^[a-z0-9-]+$')][string]$BuildLabel = 'telumia-preview-owner-tv',
    [switch]$Install
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$checkout = Join-Path $workspace 'repos/tv'
$binding = Get-Content (Join-Path $workspace "docs/$BuildLabel-build-binding.json") -Raw | ConvertFrom-Json
$head = (git -C $checkout rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $binding.target -ne 'tv' -or $binding.buildStatus -ne 'passed' -or
    $binding.sourceCommit -ne $head -or @(git -C $checkout status --porcelain).Count) {
    throw 'Native QA requires the preserved successful packages from the current clean commit.'
}
$sdk = Join-Path $env:LOCALAPPDATA 'Android/Sdk'
$adb = Join-Path $sdk 'platform-tools/adb.exe'
$serial = if ($AndroidApi -eq '24') { 'emulator-5570' } else { 'emulator-5568' }
$expectedAvd = if ($AndroidApi -eq '24') { 'Telumia_API24_01a10441' } else { 'NuvioEnhanced_ATV_01a10441' }
$state = & $adb -s $serial get-state 2>&1
if ($LASTEXITCODE -ne 0 -or $state -ne 'device') { throw 'The owned TV emulator must be running.' }
$name = & $adb -s $serial emu avd name
if ($LASTEXITCODE -ne 0 -or $name[0] -ne $expectedAvd) { throw 'Refusing to operate another emulator.' }
$api = ((& $adb -s $serial shell getprop ro.build.version.sdk) -join '').Trim()
if ($LASTEXITCODE -ne 0 -or $api -ne $AndroidApi) { throw 'Unexpected Android API.' }
$app = 'io.github.pepeu2010.telumia.tv.debug'
$appFile = $binding.packages | Where-Object file -eq 'app-full-universal-debug.apk'
$testFile = $binding.packages | Where-Object file -eq 'app-full-debug-androidTest.apk'
foreach ($file in @($appFile,$testFile)) {
    if (-not $file -or (Get-FileHash (Join-Path $workspace $file.path)).Hash.ToLowerInvariant() -ne $file.sha256) {
        throw 'Preserved native package hash differs from its build binding.'
    }
}
$output = Join-Path $workspace "artifacts/$Label"
if (Test-Path -LiteralPath $output) { throw 'Use a new label; native evidence cannot be replaced.' }
New-Item -ItemType Directory -Path $output | Out-Null
$record = [ordered]@{
    startedAtUtc=[DateTime]::UtcNow.ToString('o');sourceCommit=$head;buildLabel=$BuildLabel;
    serial=$serial;avd=$expectedAvd;androidApi=$api;apkSha256=$appFile.sha256;testApkSha256=$testFile.sha256;
    sourceChangesBefore=@(git -C $checkout status --porcelain);
    scope='Real Media3 prepare/ownership using generated local WAV, actual Compose surface disposal, decoder handoff, silent start and selection bounds. No remote-trailer/video/HDR/device-performance/full-player proof.';
    status='running'
}
try {
    if ($Install) {
        foreach ($file in @($appFile,$testFile)) {
            & $adb -s $serial install -r (Join-Path $workspace $file.path)
            if ($LASTEXITCODE -ne 0) { throw 'Preserved package installation failed.' }
        }
    }
    $log = & $adb -s $serial shell am instrument -w -r -e class com.nuvio.tv.core.player.TrailerPlayerPoolTvTest "$app.test/androidx.test.runner.AndroidJUnitRunner" 2>&1
    $exitCode = $LASTEXITCODE
    $log | Set-Content -LiteralPath (Join-Path $output 'instrumentation.log') -Encoding utf8
    $text = $log -join "`n"
    if ($exitCode -ne 0 -or $text -notmatch 'OK \(4 tests\)' -or
        $text -match 'INSTRUMENTATION_STATUS_CODE: -2|FAILURES!!!') {
        throw 'All four native pool tests must pass. Inspect the isolated instrumentation log.'
    }
    $record['testsPassed']=4
    $record['status']='passed'
} catch {
    $record['status']='failed'
    $record['failure']=$_.Exception.Message
    throw
} finally {
    $record['finishedAtUtc']=[DateTime]::UtcNow.ToString('o')
    $record['sourceChangesAfter']=@(git -C $checkout status --porcelain)
    $record | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $output 'qa.json') -Encoding utf8
}
Write-Output "Four native Media3 pool tests passed on Android API $AndroidApi."
