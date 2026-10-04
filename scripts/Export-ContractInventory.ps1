$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$lock = Get-Content (Join-Path $workspace 'docs/upstream-lock.json') -Raw | ConvertFrom-Json
$migrationText = (Get-ChildItem (Join-Path $workspace 'references/self-host/database/migrations') -Filter '*.sql' |
    Get-Content -Raw) -join "`n"
$records = foreach ($target in @('desktop', 'tv')) {
    $checkout = Join-Path $workspace "repos/$target"
    $repo = $lock.repositories | Where-Object { $_.checkout -eq "repos/$target" }
    foreach ($file in Get-ChildItem (Join-Path $checkout 'composeApp/src/commonMain'),
        (Join-Path $checkout 'app/src/main') -Recurse -Filter '*.kt' -ErrorAction SilentlyContinue) {
        $lineNumber = 0
        foreach ($line in Get-Content -LiteralPath $file.FullName) {
            $lineNumber++
            foreach ($match in [regex]::Matches($line, '\.rpc\("([a-z_][a-z_0-9]*)"')) {
                $name = $match.Groups[1].Value
                [ordered]@{
                    client = $target
                    upstreamCommit = $repo.commit
                    operation = $name
                    source = [IO.Path]::GetRelativePath($checkout, $file.FullName).Replace('\', '/')
                    line = $lineNumber
                    declaredInSelfHostMigrations = [regex]::IsMatch($migrationText,
                        '(?i)CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+public\.' + [regex]::Escape($name) + '\s*\(')
                }
            }
        }
    }
}
@($records) | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $workspace 'docs/contract-inventory.json') -Encoding utf8
Write-Output "Recorded $(@($records).Count) literal RPC call sites; multiline/dynamic calls require manual inspection."
