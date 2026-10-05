[CmdletBinding()]
param([int]$RetrySeconds = 30, [int]$MaximumAttempts = 960)
$ErrorActionPreference = 'Stop'
$oldRoot = 'C:\Users\Usuario\Documents\ChatGPT\Nuvio - Open source'
$newRoot = 'C:\Users\Usuario\Documents\ChatGPT\Telumia - Open source'
$parent = Split-Path $oldRoot -Parent
$checkpoint = Join-Path $parent 'telumia-workspace-rename.json'
Set-Location -LiteralPath $parent
for ($attempt = 1; $attempt -le $MaximumAttempts; $attempt++) {
    if (Test-Path -LiteralPath $newRoot) {
        if (-not (Test-Path -LiteralPath $oldRoot)) {
            Write-Output 'Workspace already renamed.'
            exit 0
        }
        throw 'Both paths exist; refusing to merge or replace directories.'
    }
    if ((Resolve-Path -LiteralPath $oldRoot).Path -ne $oldRoot -or
        -not (Test-Path -LiteralPath (Join-Path $oldRoot '.git'))) {
        throw 'The exact approved source directory must be an existing Git checkout.'
    }
    try {
        Move-Item -LiteralPath $oldRoot -Destination $newRoot
    } catch [System.IO.IOException] {
        if ($attempt -eq $MaximumAttempts) { throw }
        Start-Sleep -Seconds $RetrySeconds
        continue
    }
    $ownedAvd = Join-Path $env:USERPROFILE '.android/avd/NuvioEnhanced_ATV_01a10441.ini'
    if (Test-Path -LiteralPath $ownedAvd) {
        $ini = Get-Content -LiteralPath $ownedAvd -Raw
        if ($ini.Contains($oldRoot)) {
            $ini.Replace($oldRoot, $newRoot) | Set-Content -LiteralPath $ownedAvd -Encoding ascii
        }
    }
    [ordered]@{renamedAtUtc=[DateTime]::UtcNow.ToString('o');oldRoot=$oldRoot;newRoot=$newRoot;
        oldRootExists=(Test-Path -LiteralPath $oldRoot);
        commits=@{project=(git -C $newRoot rev-parse HEAD).Trim();desktop=(git -C "$newRoot/repos/desktop" rev-parse HEAD).Trim();tv=(git -C "$newRoot/repos/tv" rev-parse HEAD).Trim()}} |
        ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $checkpoint -Encoding utf8
    Write-Output "Workspace renamed: $newRoot"
    exit 0
}
