$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$workspacePrefix = [IO.Path]::GetFullPath($workspace).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
$lock = Get-Content (Join-Path $workspace 'docs/upstream-lock.json') -Raw | ConvertFrom-Json
$forkLockPath = Join-Path $workspace 'docs/fork-lock.json'
$forks = if (Test-Path $forkLockPath) { (Get-Content $forkLockPath -Raw | ConvertFrom-Json).repositories } else { @() }
foreach ($repo in $lock.repositories) {
    $fork = $forks | Where-Object checkout -eq $repo.checkout | Select-Object -First 1
    $checkout = [IO.Path]::GetFullPath((Join-Path $workspace $repo.checkout))
    if (-not $checkout.StartsWith($workspacePrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Checkout path must stay inside this workspace.'
    }
    if (Test-Path (Join-Path $checkout '.git')) {
        git -C $checkout merge-base --is-ancestor $repo.commit HEAD
        if ($LASTEXITCODE -ne 0) { throw "Existing checkout does not contain pinned history: $($repo.repository)" }
        Write-Output "Preserved existing $($repo.repository) checkout and local work."
        continue
    }
    if (Test-Path $checkout) { throw "Will not overwrite a non-Git directory: $checkout" }
    New-Item -ItemType Directory -Force -Path (Split-Path $checkout -Parent) | Out-Null
    $sourceUrl = if ($fork) { $fork.url } else { $repo.url }
    $sourceBranch = if ($fork) { $fork.branch } else { $repo.branch }
    $sourceCommit = if ($fork) { $fork.commit } else { $repo.commit }
    & git clone --filter=blob:none --branch $sourceBranch $sourceUrl $checkout
    if ($LASTEXITCODE -ne 0) { throw "Clone failed: $($repo.repository)" }
    & git -C $checkout checkout --detach $sourceCommit
    if ($LASTEXITCODE -ne 0) { throw "Cannot select pinned commit: $($repo.repository)" }
    & git -C $checkout merge-base --is-ancestor $repo.commit HEAD
    if ($LASTEXITCODE -ne 0) { throw "Fork does not preserve the audited history: $($repo.repository)" }
    if ($fork) {
        & git -C $checkout remote add upstream $repo.url
        if ($LASTEXITCODE -ne 0) { throw "Cannot register upstream: $($repo.repository)" }
    }
}
