$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$requiredDocs = @('ARCHITECTURE_AUDIT.md', 'FEATURE_GAP.md', 'Nuvio_COMPATIBILITY.md',
    'SECURITY_THREAT_MODEL.md', 'ROADMAP.md', 'APPROVED_SPEC.md', 'PRODUCT_REQUIREMENTS.md')
foreach ($name in $requiredDocs) {
    $file = Get-Item (Join-Path $workspace "docs/$name")
    if ($file.Length -lt 100) { throw "Missing or empty document: $name" }
}
$lock = Get-Content (Join-Path $workspace 'docs/upstream-lock.json') -Raw | ConvertFrom-Json
if ($lock.repositories.Count -ne 6) { throw 'Expected six audited upstreams.' }
foreach ($repo in $lock.repositories) {
    $checkout = Join-Path $workspace $repo.checkout
    if ($repo.commit -notmatch '^[0-9a-f]{40}$') { throw 'Invalid upstream commit.' }
    git -C $checkout merge-base --is-ancestor $repo.commit HEAD
    if ($LASTEXITCODE -ne 0) { throw "Pinned commit is not an ancestor: $($repo.repository)" }
    if (-not (Test-Path (Join-Path $checkout 'LICENSE'))) { throw "Missing upstream LICENSE: $($repo.repository)" }
    Write-Output "$($repo.repository): pinned history and license verified"
}
git -C $workspace diff --check
if ($LASTEXITCODE -ne 0) { throw 'Workspace diff check failed.' }
Write-Output 'Workspace documents and upstream provenance verified.'
