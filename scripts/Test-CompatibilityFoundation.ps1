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
$reviewedCompatibilitySources = @(
    @{target='tv';path='app/src/main/java/com/nuvio/tv/core/auth/AuthManager.kt';baselineBlob='98695da674da0c93e9ab8a644ffe69649f15ada5';reviewedBlob='44e343b60c2af99541904890540daa419ebd0b50'},
    @{target='tv';path='app/src/main/java/com/nuvio/tv/core/auth/diagnostics/AuthDiagnostics.kt';baselineBlob='60fbda03f5977ab1a45b2bc77462f0a354fa50d0';reviewedBlob='4c08658dc756ff2922f5aa7dc34192e47b04784c'},
    @{target='tv';path='app/src/main/java/com/nuvio/tv/core/sync/ProfileSyncService.kt';baselineBlob='b37677c99af35c8a57dc78f7815d94f7e83c7c4d';reviewedBlob='5e49ba6e805566a95a46649841273fde3ee3293a';review='pull-identity-only'}
)
foreach ($target in @('desktop', 'tv')) {
    $checkout = Join-Path $workspace "repos/$target"
    $pin = ($lock.repositories | Where-Object checkout -eq "repos/$target").commit
    $diagnosticExclusions = @()
    foreach ($review in @($reviewedCompatibilitySources | Where-Object target -eq $target)) {
        $baselineBlob = (git -C $checkout rev-parse "${pin}:$($review.path)").Trim()
        $currentBlob = (git -C $checkout hash-object $review.path).Trim()
        if ($baselineBlob -ne $review.baselineBlob) { throw "Diagnostic baseline changed: $target/$($review.path)" }
        if ($currentBlob -eq $review.reviewedBlob) {
            if ($review.review -eq 'pull-identity-only') {
                $baselineText = ((git -C $checkout show "${pin}:$($review.path)") -join "`n").TrimEnd()
                $currentText = (Get-Content -LiteralPath (Join-Path $checkout $review.path) -Raw).Replace("`r`n","`n").TrimEnd()
                $identityAddition = ",`n                        studioOwnerId = userId,`n                        studioRemoteId = entry.id?.takeIf { it.isNotBlank() }"
                if ($currentText.Replace($identityAddition,'') -cne $baselineText) { throw 'Profile sync review exceeded the two local pull identity fields.' }
                Write-Output 'TV profile sync source exactly matches baseline after removing only two local pull identity fields; RPC/push payloads are unchanged.'
            }
            # Exact reviewed contents only; every future auth/sync edit still fails.
            $diagnosticExclusions += ":(exclude)$($review.path)"
        } elseif ($currentBlob -ne $baselineBlob) {
            throw "Unreviewed protected source edit: $target/$($review.path)"
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
    Write-Output "$target protected auth/sync/transport sources match baseline, except exact reviewed diagnostic redactions and TV local pull identity fields."
}
Write-Output 'Static preservation check passed. This does not test the remote Nuvio service.'
