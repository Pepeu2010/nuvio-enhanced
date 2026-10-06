[CmdletBinding()]
param(
    [ValidatePattern('^v[0-9]+\.[0-9]+\.[0-9]+-alpha\.[0-9]+$')][string]$Tag = 'v0.2.0-alpha.1',
    [ValidatePattern('^[a-z0-9-]+\.json$')][string]$OutputName = 'telumia-release-verification.json'
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$directory = Join-Path $workspace "artifacts/releases/$Tag"
$manifest = Get-Content -LiteralPath (Join-Path $directory 'release-manifest.json') -Raw | ConvertFrom-Json
$definitions = @(
    @{repository='Pepeu2010/telumia';count=10},
    @{repository='Pepeu2010/telumia-desktop';count=4},
    @{repository='Pepeu2010/telumia-tv';count=8}
)
$records = foreach ($definition in $definitions) {
    $raw = gh api "repos/$($definition.repository)/releases/tags/$Tag"
    if ($LASTEXITCODE -ne 0) { throw "Release unavailable: $($definition.repository)" }
    $release = $raw | ConvertFrom-Json
    if ($release.draft -or -not $release.prerelease -or $release.assets.Count -ne $definition.count) {
        throw "Unexpected release state or asset count: $($definition.repository)"
    }
    $assets = foreach ($asset in $release.assets) {
        $local = Join-Path $directory $asset.name
        if (-not (Test-Path -LiteralPath $local)) { throw "Unexpected remote asset: $($asset.name)" }
        $file = Get-Item -LiteralPath $local
        $hash = (Get-FileHash -LiteralPath $local -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($asset.state -ne 'uploaded' -or $asset.size -ne $file.Length -or $asset.digest -ne "sha256:$hash") {
            throw "Remote checksum/state mismatch: $($asset.name)"
        }
        [ordered]@{name=$asset.name;bytes=$asset.size;sha256=$hash;remoteDigestVerified=$true;url=$asset.browser_download_url}
    }
    $ref = gh api "repos/$($definition.repository)/git/ref/tags/$Tag" | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) { throw 'Tag verification failed' }
    $tagCommit = $ref.object.sha
    if ($ref.object.type -eq 'tag') {
        $tag = gh api "repos/$($definition.repository)/git/tags/$tagCommit" | ConvertFrom-Json
        if ($LASTEXITCODE -ne 0 -or $tag.object.type -ne 'commit') { throw 'Tag does not resolve to a source commit.' }
        $tagCommit = $tag.object.sha
    }
    $expectedCommit = switch ($definition.repository) {
        'Pepeu2010/telumia-desktop' { $manifest.sourceCommits.desktop }
        'Pepeu2010/telumia-tv' { $manifest.sourceCommits.tv }
        default { $null }
    }
    if ($expectedCommit -and $tagCommit -ne $expectedCommit) { throw 'Published client tag differs from the packaged source commit.' }
    [ordered]@{repository=$definition.repository;url=$release.html_url;tag=$Tag;tagObject=$ref.object.sha;tagCommit=$tagCommit;sourceCommitVerified=[bool]$expectedCommit;prerelease=$release.prerelease;assets=@($assets)}
}
[ordered]@{verifiedAtUtc=[DateTime]::UtcNow.ToString('o');scope='Published release assets compared with local SHA-256; not runtime or device QA';releases=@($records)} |
    ConvertTo-Json -Depth 9 | Set-Content (Join-Path $workspace "docs/$OutputName") -Encoding utf8
Write-Output 'Three published prereleases and 22 remote asset digests verified.'
