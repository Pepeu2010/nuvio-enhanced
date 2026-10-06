[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$source = Join-Path $workspace 'artifacts/profile-studio-source'
$archive = Join-Path $source 'openmoji-svg-color.zip'
$expectedArchive = '59b0cd9f6fe033818fc02585cea42bea9fba5d68a4d3a3639bfe5d5cc3805689'
if ((Get-FileHash -LiteralPath $archive).Hash.ToLowerInvariant() -ne $expectedArchive) { throw 'Unexpected pinned OpenMoji archive.' }
$pin = Get-Content (Join-Path $source 'source.json') -Raw | ConvertFrom-Json
if ($pin.Commit -ne 'f9fc506a3f913be9897ab0181d611d4c910a4104' -or $pin.Tag -ne '17.0.0') { throw 'Unexpected OpenMoji source pin.' }
$catalog = Get-Content (Join-Path $source 'openmoji.json') -Raw | ConvertFrom-Json
$selected = @'
1F98A|animals|Raposa
1F431|animals|Gato
1F436|animals|Cachorro
1F981|animals|Leão
1F42F|animals|Tigre
1F43C|animals|Panda
1F428|animals|Coala
1F43B|animals|Urso
1F430|animals|Coelho
1F438|animals|Sapo
1F989|animals|Coruja
1F427|animals|Pinguim
1F99C|animals|Papagaio
1F98B|animals|Borboleta
1F422|animals|Tartaruga
1F419|animals|Polvo
1F433|animals|Baleia
1F980|animals|Caranguejo
1F41D|animals|Abelha
1F40C|animals|Caracol
1F43A|animals|Lobo
1F984|fantasy|Unicórnio
1F409|fantasy|Dragão
1F47D|space|Alienígena
1F47E|space|Criatura espacial
1F916|space|Robô
1F680|space|Foguete
1F6F8|space|Disco voador
1F319|space|Lua crescente
1F31D|space|Lua cheia
1F30C|space|Via Láctea
1F6F0|space|Satélite
1FA90|space|Planeta com anéis
2604|space|Cometa
1F9DA|fantasy|Fada
1F9DD|fantasy|Elfo
1F9D9|fantasy|Mago
1F9DB|fantasy|Vampiro
1F9DE|fantasy|Gênio
1F9DF|fantasy|Zumbi
1F9DC|fantasy|Sereia
1F52E|fantasy|Bola de cristal
1FA84|fantasy|Varinha mágica
1F3F0|fantasy|Castelo
1F338|nature|Flor de cerejeira
1F33B|nature|Girassol
1F339|nature|Rosa
1F337|nature|Tulipa
1F33A|nature|Hibisco
1F335|nature|Cacto
1F334|nature|Palmeira
1F332|nature|Pinheiro
1F333|nature|Árvore
1F344|nature|Cogumelo
1F340|nature|Trevo
1F341|nature|Folha de bordo
1F342|nature|Folha caída
1F343|nature|Folha ao vento
2744|nature|Floco de neve
1F525|nature|Fogo
1F4A7|nature|Gota
1F308|nature|Arco-íris
1F30A|nature|Onda
1F31E|nature|Sol
'@ -split '\r?\n'
$output = Join-Path $workspace 'assets/avatars/openmoji'
New-Item -ItemType Directory -Force $output | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($archive)
try {
    $items = foreach ($row in $selected) {
        $code, $category, $name = $row.Split('|')
        if ($code -notmatch '^[A-F0-9]{4,6}$') { throw 'Unsafe avatar asset key.' }
        $entry = $zip.GetEntry("$code.svg")
        $metadata = $catalog | Where-Object hexcode -eq $code | Select-Object -First 1
        if (-not $entry -or -not $metadata -or $entry.Length -gt 262144) { throw "Missing or oversized avatar asset: $code" }
        $file = Join-Path $output "$code.svg"
        $inputStream = $entry.Open()
        try {
            $destination = [IO.File]::Create($file)
            try { $inputStream.CopyTo($destination) } finally { $destination.Dispose() }
        } finally { $inputStream.Dispose() }
        $svg = [IO.File]::ReadAllText($file)
        if ($svg -match '(?i)<!DOCTYPE|<!ENTITY|<script|<foreignObject|(?:href|onload)\s*=') { throw "Unexpected active/external SVG content: $code" }
        [ordered]@{id="openmoji-$($code.ToLowerInvariant())";code=$code;category=$category;namePtBr=$name;nameEn=$metadata.annotation;file="$code.svg";bytes=(Get-Item $file).Length;sha256=(Get-FileHash $file).Hash.ToLowerInvariant()}
    }
} finally { $zip.Dispose() }
Copy-Item -LiteralPath (Join-Path $source 'LICENSE.txt') -Destination (Join-Path $output 'LICENSE.txt')
[ordered]@{schemaVersion=1;provider='OpenMoji';tag=$pin.Tag;sourceCommit=$pin.Commit;sourceUrl="https://github.com/hfg-gmuend/openmoji/tree/$($pin.Commit)";graphicsLicense='CC-BY-SA-4.0';licenseUrl='https://creativecommons.org/licenses/by-sa/4.0/';attribution='OpenMoji, Benedikt Groß, Daniel Utz and contributors (HfG Schwäbisch Gmünd)';modifiedArtwork=$false;archiveSha256=$expectedArchive;items=@($items)} |
    ConvertTo-Json -Depth 8 | Set-Content (Join-Path $output 'catalog.json') -Encoding utf8
Write-Output "Prepared $($items.Count) unchanged licensed avatar assets. Application integration is a separate gate."
