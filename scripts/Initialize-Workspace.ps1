$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$workspacePrefix = [IO.Path]::GetFullPath($workspace).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
$lock = Get-Content (Join-Path $workspace 'docs/upstream-lock.json') -Raw | ConvertFrom-Json
foreach ($repo in $lock.repositories) {
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
    & git clone --filter=blob:none --branch $repo.branch $repo.url $checkout
    if ($LASTEXITCODE -ne 0) { throw "Clone failed: $($repo.repository)" }
    & git -C $checkout checkout --detach $repo.commit
    if ($LASTEXITCODE -ne 0) { throw "Cannot select pinned commit: $($repo.repository)" }
}
