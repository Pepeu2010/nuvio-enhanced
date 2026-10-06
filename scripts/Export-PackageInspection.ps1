[CmdletBinding()]
param(
    [ValidateSet('desktop','tv')][string[]]$Targets = @('desktop','tv'),
    [ValidatePattern('^[a-z0-9-]+\.json$')][string]$OutputName = 'package-inspection.json'
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$results = foreach ($target in $Targets) {
    $checkout = Join-Path $workspace "repos/$target"
    $artifacts = @()
    if ($target -eq 'desktop') {
        $file = Get-ChildItem (Join-Path $checkout 'composeApp/build/compose/release-msis') -Filter 'Telumia-Windows-*.msi' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if (-not $file) { throw 'Enhanced MSI missing.' }
        $installer = New-Object -ComObject WindowsInstaller.Installer
        $database = $installer.OpenDatabase($file.FullName, 0)
        $properties = [ordered]@{}
        foreach ($name in @('ProductName','Manufacturer','UpgradeCode','ProductVersion')) {
            $view = $database.OpenView("SELECT Value FROM Property WHERE Property = '$name'")
            $null = $view.Execute(); $row = $view.Fetch(); $properties[$name] = $row.StringData(1); $null = $view.Close()
        }
        if ($properties.ProductName -ne 'Telumia' -or $properties.UpgradeCode -ne '{1C69D968-D0E0-4B0F-B5C0-615B8EA92F90}') { throw 'MSI identity mismatch.' }
        $dll = Join-Path $checkout 'composeApp/build/native/windows/player_bridge.dll'
        $dllHash = (Get-FileHash $dll).Hash.ToLowerInvariant()
        $unicode = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($dll))
        if (-not $unicode.Contains('\Telumia\WebView2') -or $unicode.Contains('\Nuvio\WebView2')) { throw 'Bridge data path is not isolated.' }
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $archive = [IO.Compression.ZipFile]::OpenRead((Join-Path $checkout 'composeApp/build/libs/composeApp-desktop.jar'))
        try {
            $entry = $archive.GetEntry('native/windows/player_bridge.dll')
            if (-not $entry) { throw 'Packaged bridge missing.' }
            $stream = $entry.Open()
            try { $packedHash = [Convert]::ToHexString([Security.Cryptography.SHA256]::Create().ComputeHash($stream)).ToLowerInvariant() }
            finally { $stream.Dispose() }
            if ($packedHash -ne $dllHash) { throw 'Packaged bridge does not match the compiled bridge.' }
        } finally { $archive.Dispose() }
        $artifacts += [ordered]@{file=$file.Name;bytes=$file.Length;sha256=(Get-FileHash $file.FullName).Hash.ToLowerInvariant()}
        $inspection = [ordered]@{msiProperties=$properties;compiledBridgeSha256=$dllHash;isolatedWebViewPath=$true;packagedBridgeMatchesBuild=$true}
    } else {
        $java = Get-ChildItem (Join-Path $env:USERPROFILE '.gradle/jdks') -Directory | Where-Object Name -Match '-17-' | Select-Object -First 1
        if (-not $java) { throw 'JDK 17 missing.' }
        $env:JAVA_HOME = $java.FullName
        $buildTools = Join-Path $env:LOCALAPPDATA 'Android/Sdk/build-tools/35.0.0'
        $files = @(Get-ChildItem (Join-Path $checkout 'app/build/outputs/apk/full/debug') -Filter '*.apk')
        if (-not $files.Count) { throw 'TV APKs missing.' }
        foreach ($file in $files) {
            $badging = & (Join-Path $buildTools 'aapt2.exe') dump badging $file.FullName
            if ($LASTEXITCODE -ne 0) { throw 'APK manifest inspection failed.' }
            $packageLine = $badging | Where-Object { $_.StartsWith('package:') } | Select-Object -First 1
            $package = [regex]::Match($packageLine, "name='([^']+)'").Groups[1].Value
            if ($package -ne 'io.github.pepeu2010.telumia.tv.debug') { throw "APK identity mismatch: $package" }
            $labelLine = $badging | Where-Object { $_.StartsWith('application-label:') } | Select-Object -First 1
            if ($labelLine -notlike '*Telumia Debug*') { throw 'APK label mismatch.' }
            $null = & (Join-Path $buildTools 'apksigner.bat') verify $file.FullName
            if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed.' }
            $versionName = [regex]::Match($packageLine, "versionName='([^']+)'").Groups[1].Value
            $versionCode = [regex]::Match($packageLine, "versionCode='([^']+)'").Groups[1].Value
            $artifacts += [ordered]@{file=$file.Name;bytes=$file.Length;sha256=(Get-FileHash $file.FullName).Hash.ToLowerInvariant();applicationId=$package;versionName=$versionName;versionCode=$versionCode;signatureVerified=$true}
        }
        $inspection = [ordered]@{label='Telumia Debug';distribution='development debug only'}
    }
    [ordered]@{target=$target;sourceCommit=(git -C $checkout rev-parse HEAD).Trim();installed=$false;inspection=$inspection;artifacts=$artifacts}
}
[ordered]@{exportedAtUtc=[DateTime]::UtcNow.ToString('o');scope='Package and binary inspection; no installation or playback QA';results=@($results)} |
    ConvertTo-Json -Depth 8 | Set-Content (Join-Path $workspace "docs/$OutputName") -Encoding utf8
Write-Output 'Package identities, native contents and hashes exported; no apps installed.'
