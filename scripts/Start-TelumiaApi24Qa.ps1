[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$sdk = Join-Path $env:LOCALAPPDATA 'Android/Sdk'
$adb = Join-Path $sdk 'platform-tools/adb.exe'
$emulator = Join-Path $sdk 'emulator/emulator.exe'
$serial = 'emulator-5570'
$avdName = 'Telumia_API24_01a10441'
$env:ANDROID_AVD_HOME = Join-Path $workspace 'artifacts/android-avd'
$state = & $adb -s $serial get-state 2>&1
if ($LASTEXITCODE -eq 0 -and $state -eq 'device') {
    $existing = & $adb -s $serial emu avd name
    if ($existing[0] -ne $avdName) { throw 'Port 5570 belongs to another emulator.' }
    Write-Output 'Owned API 24 TV emulator already running.'
    exit 0
}
$config = Join-Path $env:ANDROID_AVD_HOME "$avdName.avd/config.ini"
if (-not (Test-Path -LiteralPath $config)) { throw 'Create the isolated API 24 TV AVD first.' }
$output = Join-Path $workspace 'artifacts/telumia-api24-qa-emulator'
New-Item -ItemType Directory -Force -Path $output | Out-Null
$process = Start-Process -FilePath $emulator -ArgumentList @('-avd',$avdName,'-port','5570','-no-window','-no-audio','-no-snapshot','-gpu','swiftshader_indirect','-memory','1536','-cores','2') -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $output 'emulator.log') -RedirectStandardError (Join-Path $output 'emulator-error.log')
[ordered]@{startedAtUtc=[DateTime]::UtcNow.ToString('o');pid=$process.Id;avd=$avdName;port=5570;scope='Isolated API 24 TV test AVD only'} |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $output 'bootstrap.json') -Encoding utf8
$deadline = [DateTime]::UtcNow.AddMinutes(4)
while ([DateTime]::UtcNow -lt $deadline) {
    if ($process.HasExited) { throw 'Owned API 24 emulator exited before boot; inspect its bootstrap logs.' }
    $boot = & $adb -s $serial shell getprop sys.boot_completed 2>$null
    if ($LASTEXITCODE -eq 0 -and $boot.Trim() -eq '1') {
        $api = (& $adb -s $serial shell getprop ro.build.version.sdk).Trim()
        if ($api -ne '24') { throw 'The owned fixture must use Android API 24.' }
        Write-Output "Owned API 24 TV emulator booted, launcher PID $($process.Id)."
        exit 0
    }
    Start-Sleep -Seconds 2
}
throw 'Owned API 24 TV emulator did not boot; inspect its private bootstrap logs.'
