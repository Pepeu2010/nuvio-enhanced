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
    @{target='tv';path='app/src/main/java/com/nuvio/tv/core/sync/ProfileSyncService.kt';baselineBlob='b37677c99af35c8a57dc78f7815d94f7e83c7c4d';reviewedBlob='5e49ba6e805566a95a46649841273fde3ee3293a';review='pull-identity-only'},
    @{target='desktop';path='composeApp/src/commonMain/kotlin/com/nuvio/app/core/sync/SyncManager.kt';baselineBlob='fccd08be4a2dec90982c5fc56fbd66d9c8037403';reviewedBlob='34e45fbe6d12a1e1ad883d7a5315e6b86ddd49d8';review='account-refresh'},
    @{target='desktop';path='composeApp/src/commonMain/kotlin/com/nuvio/app/core/sync/ProfileSettingsSync.kt';baselineBlob='84e1704a3f237b2b2615d7b62393776e442f825c';reviewedBlob='5d6264d94b214934f70104ead772ee3395812d6a';review='account-refresh'},
    @{target='desktop';path='composeApp/src/commonMain/kotlin/com/nuvio/app/core/sync/AccountSyncOwner.kt';baselineBlob='absent';reviewedBlob='9967b115da2804184d220dfcee47fca791931732';review='account-refresh'},
    @{target='desktop';path='composeApp/src/commonMain/kotlin/com/nuvio/app/core/sync/SnapshotSyncJournal.kt';baselineBlob='absent';reviewedBlob='f19efabab7762049c64c9cbf88f7dad0e3729a66';review='account-refresh'},
    @{target='tv';path='app/src/main/java/com/nuvio/tv/core/sync/StartupSyncService.kt';baselineBlob='bfdf9266165cf8c955920f3ad8589defb2952aba';reviewedBlob='f97bbddbc0ad0952b50e48b418ebbd460e4f8250';review='account-refresh'},
    @{target='tv';path='app/src/main/java/com/nuvio/tv/core/sync/AddonSyncService.kt';baselineBlob='da730d51769e1e2fb0e0003a0944e4fe961fe177';reviewedBlob='4d488198dc43420f82e89ed07f9da51112e8f00b';review='account-refresh'},
    @{target='tv';path='app/src/main/java/com/nuvio/tv/core/sync/CollectionSyncService.kt';baselineBlob='3aead36df81f1ba335eed956e0fe64bd5b21ca9e';reviewedBlob='dcb4061fc34c27e2ff61eb6d63d625d59fc8c9e5';review='account-refresh'},
    @{target='tv';path='app/src/main/java/com/nuvio/tv/core/sync/CollectionSyncRemote.kt';baselineBlob='absent';reviewedBlob='5067939cb071979507c3155911d330ff7f18d981';review='account-refresh'},
    @{target='tv';path='app/src/main/java/com/nuvio/tv/core/sync/SnapshotSyncJournal.kt';baselineBlob='absent';reviewedBlob='2a4fbd6e9e6f8885b5f745d46e5fa3b3228e19cc';review='account-refresh'}
)
foreach ($target in @('desktop', 'tv')) {
    $checkout = Join-Path $workspace "repos/$target"
    $pin = ($lock.repositories | Where-Object checkout -eq "repos/$target").commit
    $diagnosticExclusions = @()
    foreach ($review in @($reviewedCompatibilitySources | Where-Object target -eq $target)) {
        if ($review.baselineBlob -eq 'absent') {
            $baselineEntry = @(git -C $checkout ls-tree $pin -- $review.path)
            if ($LASTEXITCODE -ne 0 -or $baselineEntry.Count) { throw "Added reviewed source already exists upstream: $target/$($review.path)" }
            $baselineBlob = 'absent'
        } else {
            $baselineBlob = (git -C $checkout rev-parse "${pin}:$($review.path)").Trim()
        }
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
            if ($review.review -eq 'account-refresh') {
                Write-Output "Exact reviewed account refresh source: $target/$($review.path). Contracts and remote-account proof are documented separately in ACCOUNT_SYNC_MOTION.md."
            }
            # Exact reviewed contents only; further auth/sync edits still need explicit source review.
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
    Write-Output "$target protected sources match baseline or exact reviewed redaction/identity/account-refresh contents."
}
Write-Output 'Static preservation check passed. This does not test the remote Nuvio service.'
