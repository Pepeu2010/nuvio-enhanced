[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('desktop','tv')][string]$Target,
    [Parameter(Mandatory)][ValidatePattern('^[a-z0-9-]+$')][string]$Label,
    [Parameter(Mandatory)][string[]]$Tasks,
    [string[]]$GradleArgs = @(),
    [ValidateRange(1024,8192)][int]$HeapMiB = 4096,
    [switch]$IsolateDesktopData
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$output = Join-Path $workspace "artifacts/$Label/$Target"
if (Test-Path -LiteralPath $output) { throw 'Choose a new build label; launch evidence cannot be replaced.' }
if ($IsolateDesktopData -and $Target -ne 'desktop') { throw 'Desktop isolation cannot be used for TV.' }
if (@(git -C (Join-Path $workspace "repos/$Target") status --porcelain).Count) { throw 'A clean source checkout is required.' }
New-Item -ItemType Directory -Path $output | Out-Null
$request = [ordered]@{workspace=$workspace;target=$Target;label=$Label;tasks=$Tasks;gradleArgs=$GradleArgs;
    heapMiB=$HeapMiB;isolateDesktopData=[bool]$IsolateDesktopData}
$request | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $output 'launch-request.json') -Encoding utf8
$runner = @'
$ErrorActionPreference = 'Stop'
$request = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'launch-request.json') -Raw | ConvertFrom-Json
if ($request.target -eq 'desktop') {
    $env:TELUMIA_PLAYER_ASSET_EXPORT_DIR = Join-Path $PSScriptRoot 'telumia-player-assets'
}
try {
    & (Join-Path $request.workspace 'scripts/Invoke-Baseline.ps1') -Target $request.target `
        -Tasks $request.tasks -GradleArgs $request.gradleArgs -Label $request.label `
        -HeapMiB $request.heapMiB -IsolateDesktopData:$request.isolateDesktopData
    exit 0
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
'@
$runnerPath = Join-Path $output 'run-baseline.ps1'
[IO.File]::WriteAllText($runnerPath,$runner,[Text.UTF8Encoding]::new($false))
$powershell = (Get-Command pwsh.exe -ErrorAction Stop).Source
$process = Start-Process -FilePath $powershell -ArgumentList @('-NoProfile','-File',('"'+$runnerPath+'"')) `
    -WorkingDirectory $workspace -WindowStyle Hidden -PassThru `
    -RedirectStandardOutput (Join-Path $output 'runner.stdout.log') -RedirectStandardError (Join-Path $output 'runner.stderr.log')
[ordered]@{launchedAtUtc=[DateTime]::UtcNow.ToString('o');pid=$process.Id;target=$Target;label=$Label;
    sourceCommit=(git -C (Join-Path $workspace "repos/$Target") rev-parse HEAD).Trim();runnerPath=$runnerPath;
    scope='Owned hidden build runner. Track this PID and its Gradle children; launch is not build success.'} |
    ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $output 'launcher.json') -Encoding utf8
Write-Output "Started owned $Target build runner PID $($process.Id), label $Label."
