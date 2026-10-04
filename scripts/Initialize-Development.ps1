[CmdletBinding()]
param([Parameter(Mandatory)][ValidateSet('desktop', 'tv')][string]$Target)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$checkout = Join-Path $workspace "repos/$Target"
$discovery = Invoke-RestMethod 'https://api.nuvio.tv/.well-known/nuvio' -TimeoutSec 30
if (-not $discovery.backend_url -or -not $discovery.publishable_key -or
    -not $discovery.backend_url.StartsWith('https://')) {
    throw 'Official discovery did not return usable public client configuration.'
}
$propertyFile = Join-Path $checkout 'local.properties'
$propertyLines = if (Test-Path $propertyFile) { @(Get-Content $propertyFile) } else { @() }
foreach ($setting in @(@('NUVIO_SUPABASE_URL', $discovery.backend_url),
    @('NUVIO_SUPABASE_ANON_KEY', $discovery.publishable_key))) {
    if ($setting[1] -match '[\r\n]') { throw 'Invalid discovery property.' }
    # Preserve existing developer configuration. Only add missing public values.
    if (-not ($propertyLines | Where-Object { $_ -match "^$($setting[0])=" })) {
        $propertyLines += "$($setting[0])=$($setting[1])"
    }
}
$propertyLines | Set-Content -LiteralPath $propertyFile -Encoding utf8
if ($Target -eq 'tv') {
    $tooling = Join-Path $workspace '.tooling'
    New-Item -ItemType Directory -Force -Path $tooling | Out-Null
    $credentialFile = Join-Path $tooling 'tv-development-signing.xml'
    if (Test-Path $credentialFile) {
        $credential = Import-Clixml -LiteralPath $credentialFile
    } else {
        $password = [Guid]::NewGuid().ToString('N') + [Guid]::NewGuid().ToString('N')
        $credential = [PSCredential]::new('enhanced-development', (ConvertTo-SecureString $password -AsPlainText -Force))
        $credential | Export-Clixml -LiteralPath $credentialFile
    }
    $env:NUVIO_RELEASE_STORE_FILE = Join-Path $tooling 'tv-development.keystore'
    $env:NUVIO_RELEASE_KEY_ALIAS = $credential.UserName
    $env:NUVIO_RELEASE_KEY_PASSWORD = $credential.GetNetworkCredential().Password
    $env:NUVIO_RELEASE_STORE_PASSWORD = $env:NUVIO_RELEASE_KEY_PASSWORD
    if (-not (Test-Path $env:NUVIO_RELEASE_STORE_FILE)) {
        $jdk = Get-ChildItem (Join-Path $env:USERPROFILE '.gradle/jdks') -Directory |
            Where-Object { $_.Name -match '-17-' } | Select-Object -First 1
        if (-not $jdk) { throw 'A JDK 17 keytool is required.' }
        & (Join-Path $jdk.FullName 'bin/keytool.exe') -genkeypair -noprompt -keystore $env:NUVIO_RELEASE_STORE_FILE `
            -storepass:env NUVIO_RELEASE_STORE_PASSWORD -keypass:env NUVIO_RELEASE_KEY_PASSWORD `
            -alias $env:NUVIO_RELEASE_KEY_ALIAS -keyalg RSA -keysize 3072 -validity 3650 `
            -dname 'CN=Nuvio Enhanced Local Development,OU=Development,O=Independent Fork,C=BR'
        if ($LASTEXITCODE -ne 0) { throw 'Development key generation failed.' }
    }
}
Write-Output "Local $Target configuration prepared using official public discovery; no user credentials collected."
