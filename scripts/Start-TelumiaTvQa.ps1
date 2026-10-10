[CmdletBinding()]
param(
    [ValidateSet('720','1080','2160')][string]$Resolution = '2160',
    [ValidatePattern('^[a-z0-9-]+$')][string]$BootstrapLabel
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$sdk = Join-Path $env:LOCALAPPDATA 'Android/Sdk'
$adb = Join-Path $sdk 'platform-tools/adb.exe'
$emulator = Join-Path $sdk 'emulator/emulator.exe'
$serial = 'emulator-5568'
$avdName = 'NuvioEnhanced_ATV_01a10441'
$dimensions = switch ($Resolution) { '720' { '1280x720' }; '1080' { '1920x1080' }; '2160' { '3840x2160' } }
$pixels = $dimensions.Split('x')
$density = if ($Resolution -eq '2160') { 640 } else { 320 }
$env:ANDROID_AVD_HOME = Join-Path $env:USERPROFILE '.android/avd'
$registration = Join-Path $env:ANDROID_AVD_HOME "$avdName.ini"
if (-not (Test-Path -LiteralPath $registration)) { throw 'The owned API 36 AVD registration is missing.' }
$registeredPath = (Get-Content -LiteralPath $registration | Where-Object { $_ -match '^path=' }) -replace '^path=',''
$expectedPath = Join-Path $workspace "artifacts/android-avd/$avdName.avd"
if ([IO.Path]::GetFullPath($registeredPath) -ne [IO.Path]::GetFullPath($expectedPath)) { throw 'The API 36 AVD registration points outside the owned workspace fixture.' }
$state = & $adb -s $serial get-state 2>&1
if ($LASTEXITCODE -eq 0 -and $state -eq 'device') {
    $existingName = & $adb -s $serial emu avd name
    if ($existingName[0] -ne $avdName) { throw 'Port 5568 belongs to another emulator.' }
    $physical = & $adb -s $serial shell wm size
    if (($physical -join "`n") -notmatch ('Physical size: ' + [regex]::Escape($dimensions))) { throw 'Existing owned emulator has another native framebuffer; stop it and restore its config before changing resolution.' }
    Write-Output "Owned native $dimensions TV emulator already running."
    exit 0
}
$config = Join-Path $workspace "artifacts/android-avd/$avdName.avd/config.ini"
$backup = Join-Path $workspace 'artifacts/cinematic-tv-native-display-original.ini'
if (-not (Test-Path -LiteralPath $config) -or -not (Test-Path -LiteralPath $backup)) { throw 'The owned AVD and its original display backup must exist.' }
if (-not $BootstrapLabel) { $BootstrapLabel = "telumia-tv-qa-emulator-$Resolution-$([DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ').ToLowerInvariant())" }
$output = Join-Path $workspace "artifacts/$BootstrapLabel"
if (Test-Path -LiteralPath $output) { throw 'Choose a new bootstrap label; launch evidence cannot be replaced.' }
$ini = Get-Content -LiteralPath $config -Raw
$ini = [regex]::Replace($ini, '(?m)^hw.lcd.width=.*$', "hw.lcd.width=$($pixels[0])")
$ini = [regex]::Replace($ini, '(?m)^hw.lcd.height=.*$', "hw.lcd.height=$($pixels[1])")
$ini = [regex]::Replace($ini, '(?m)^hw.lcd.density=.*$', "hw.lcd.density=$density")
$ini | Set-Content -LiteralPath $config -Encoding ascii
New-Item -ItemType Directory -Path $output | Out-Null
$process = Start-Process -FilePath $emulator -ArgumentList @('-avd',$avdName,'-port','5568','-no-window','-no-audio','-no-snapshot','-gpu','swiftshader_indirect','-memory','2048','-cores','2','-skin',$dimensions) -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $output 'emulator.log') -RedirectStandardError (Join-Path $output 'emulator-error.log')
[ordered]@{startedAtUtc=[DateTime]::UtcNow.ToString('o');pid=$process.Id;avd=$avdName;port=5568;framebuffer=$dimensions;scope='Owned emulator only; original display config must be restored after QA'} |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $output 'bootstrap.json') -Encoding utf8
$deadline = [DateTime]::UtcNow.AddMinutes(4)
while ([DateTime]::UtcNow -lt $deadline) {
    if ($process.HasExited) { throw 'Owned TV emulator exited before boot; inspect its bootstrap logs.' }
    $boot = & $adb -s $serial shell getprop sys.boot_completed 2>$null
    if ($LASTEXITCODE -eq 0 -and $boot.Trim() -eq '1') {
        $physical = & $adb -s $serial shell wm size
        if (($physical -join "`n") -notmatch ('Physical size: ' + [regex]::Escape($dimensions))) { throw 'Owned TV emulator did not provide the requested native framebuffer.' }
        Write-Output "Owned TV emulator booted with native $dimensions framebuffer, launcher PID $($process.Id)."
        exit 0
    }
    Start-Sleep -Seconds 2
}
throw 'Owned TV emulator did not finish booting in four minutes; inspect the private bootstrap logs.'
