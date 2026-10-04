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
foreach ($target in @('desktop', 'tv')) {
    $checkout = Join-Path $workspace "repos/$target"
    $pin = ($lock.repositories | Where-Object checkout -eq "repos/$target").commit
    foreach ($path in $paths[$target]) {
        # Refuse a typo that would otherwise look like an unchanged contract.
        if (-not (Test-Path (Join-Path $checkout $path))) { throw "Missing contract path: $target/$path" }
        git -C $checkout diff --exit-code $pin -- $path
        if ($LASTEXITCODE -ne 0) { throw "Foundation changed a protected compatibility surface: $target/$path" }
    }
    # Preserve legacy upstream CRLF files while still rejecting trailing spaces.
    git -C $checkout -c core.whitespace=blank-at-eol,blank-at-eof,space-before-tab,cr-at-eol diff --check
    if ($LASTEXITCODE -ne 0) { throw "Diff check failed: $target" }
    Write-Output "$target auth/sync/transport contract sources unchanged from baseline."
}
Write-Output 'Static preservation check passed. This does not test the remote Nuvio service.'
