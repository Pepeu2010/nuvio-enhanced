$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$lock = Get-Content (Join-Path $workspace 'docs/upstream-lock.json') -Raw | ConvertFrom-Json
$paths = @{
    desktop = @('composeApp/src/commonMain/kotlin/com/nuvio/app/core/auth',
        'composeApp/src/commonMain/kotlin/com/nuvio/app/core/sync',
        'composeApp/src/commonMain/kotlin/com/nuvio/app/core/network/SupabaseProvider.kt',
        'composeApp/src/commonMain/kotlin/com/nuvio/app/features/addons/AddonModels.kt',
        'composeApp/src/commonMain/kotlin/com/nuvio/app/features/addons/AddonTransportUrls.kt')
    tv = @('app/src/main/java/com/nuvio/tv/core/auth',
        'app/src/main/java/com/nuvio/tv/core/sync',
        'app/src/main/java/com/nuvio/tv/data/remote/api',
        'app/src/main/java/com/nuvio/tv/data/remote/dto')
}
$reviewedDiagnosticSources = @(
    @{target='tv';path='app/src/main/java/com/nuvio/tv/core/auth/AuthManager.kt';baselineBlob='98695da674da0c93e9ab8a644ffe69649f15ada5';reviewedBlob='44e343b60c2af99541904890540daa419ebd0b50'},
    @{target='tv';path='app/src/main/java/com/nuvio/tv/core/auth/diagnostics/AuthDiagnostics.kt';baselineBlob='60fbda03f5977ab1a45b2bc77462f0a354fa50d0';reviewedBlob='1b2e216b2b8ca9b38b8a5977270d452e30c65029'}
)
foreach ($target in @('desktop', 'tv')) {
    $checkout = Join-Path $workspace "repos/$target"
    $pin = ($lock.repositories | Where-Object checkout -eq "repos/$target").commit
    $diagnosticExclusions = @()
    foreach ($review in @($reviewedDiagnosticSources | Where-Object target -eq $target)) {
        $baselineBlob = (git -C $checkout rev-parse "${pin}:$($review.path)").Trim()
        $currentBlob = (git -C $checkout hash-object $review.path).Trim()
        if ($baselineBlob -ne $review.baselineBlob) { throw "Diagnostic baseline changed: $target/$($review.path)" }
        if ($currentBlob -eq $review.reviewedBlob) {
            # Exact reviewed contents only; future auth edits still fail this gate.
            $diagnosticExclusions += ":(exclude)$($review.path)"
        } elseif ($currentBlob -ne $baselineBlob) {
            throw "Unreviewed protected diagnostic edit: $target/$($review.path)"
        }
    }
    foreach ($path in $paths[$target]) {
        # Refuse a typo that would otherwise look like an unchanged contract.
        if (-not (Test-Path (Join-Path $checkout $path))) { throw "Missing contract path: $target/$path" }
        git -C $checkout diff --exit-code $pin -- $path @diagnosticExclusions
        if ($LASTEXITCODE -ne 0) { throw "Foundation changed a protected compatibility surface: $target/$path" }
    }
    # Preserve legacy upstream CRLF files while still rejecting trailing spaces.
    git -C $checkout -c core.whitespace=blank-at-eol,blank-at-eof,space-before-tab,cr-at-eol diff --check
    if ($LASTEXITCODE -ne 0) { throw "Diff check failed: $target" }
    Write-Output "$target protected auth/sync/transport sources match baseline, except exact reviewed diagnostic redactions."
}
Write-Output 'Static preservation check passed. This does not test the remote Nuvio service.'
