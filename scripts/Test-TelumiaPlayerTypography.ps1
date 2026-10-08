[CmdletBinding()]
param([Parameter(Mandatory)][ValidatePattern('^[a-z0-9-]+$')][string]$Label)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$output = Join-Path $workspace "artifacts/$Label/desktop"
$assets = Join-Path $output 'telumia-player-assets'
$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path -LiteralPath $chrome)) { throw 'The installed Chromium browser is required for this renderer gate.' }
if (-not (Test-Path -LiteralPath (Join-Path $assets 'fonts/manrope_variable.ttf'))) { throw 'Export the production native asset map through NativePlayerUiAssetsTest first.' }
$evidence = Join-Path $output 'browser-qa'
if (Test-Path -LiteralPath $evidence) { throw 'Use a new label; browser evidence cannot be replaced.' }
New-Item -ItemType Directory -Path $evidence | Out-Null
$font = Get-Content (Join-Path $workspace 'docs/telumia-typography-source.json') -Raw | ConvertFrom-Json
if ((Get-FileHash (Join-Path $assets 'fonts/manrope_variable.ttf')).Hash.ToLowerInvariant() -ne $font.fontSha256) { throw 'The exported font differs from the pinned licensed font.' }
$baseHtml = Get-Content (Join-Path $assets 'controls.html') -Raw
$setup = @'
<script>
window.telumiaFixtureErrors = [];
window.addEventListener('error', e => window.telumiaFixtureErrors.push(String(e.message)));
window.addEventListener('unhandledrejection', e => window.telumiaFixtureErrors.push(String(e.reason)));
</script>
'@
$fixture = @'
<script>
(async () => {
  document.body.style.background = 'linear-gradient(130deg, #080e18, #182b3d)';
  window.playerControls({
    title: 'Verificação local — Áudio, legendas e próximos episódios',
    episodeText: 'Temporada 1 · Episódio 12',
    streamTitle: 'Arquivo de teste · 1080p', providerName: 'Fixture local',
    subtitlesLabel: 'Legendas', audioLabel: 'Áudio', sourcesLabel: 'Fontes', episodesLabel: 'Episódios',
    playLabel: 'Reproduzir', pauseLabel: 'Pausar', closeLabel: 'Fechar player',
    resizeModeLabel: 'Ajustar', playbackSpeedLabel: '1×',
    showSources: true, showEpisodes: true, pauseOverlayEnabled: false,
    timedMarkers: [{id:'fixture-intro',kind:'INTRO',startFraction:0.04,endFraction:0.06,label:'Introdução',providerId:'fixture'}]
  });
  window.playerUpdate({duration:2400,position:612,paused:true,loading:false,volumeLevel:75,audioTracks:[],subtitleTracks:[]});
  const regular = await document.fonts.load('400 20px "Telumia Manrope"');
  const bold = await document.fonts.load('700 28px "Telumia Manrope"');
  await document.fonts.ready;
  const toggle = document.getElementById('toggle');
  toggle.focus();
  const title = document.getElementById('title');
  const report = {
    regularLoaded:regular.some(f => f.status === 'loaded'), boldLoaded:bold.some(f => f.status === 'loaded'),
    fontFamily:getComputedStyle(title).fontFamily,
    portugueseTitle:title.textContent,
    keyboardFocus:document.activeElement === toggle,
    viewport:{width:innerWidth,height:innerHeight},
    horizontalOverflow:document.documentElement.scrollWidth > innerWidth,
    errors:window.telumiaFixtureErrors,
    fontFaces:Array.from(document.fonts).map(f => ({family:f.family,weight:f.weight,status:f.status}))
  };
  const pre = document.createElement('pre');
  pre.id='telumia-qa-report'; pre.hidden=true; pre.textContent=JSON.stringify(report);
  document.body.append(pre);
})();
</script>
'@
$html = $baseHtml.Replace('</head>', $setup + '</head>').Replace('</body>', $fixture + '</body>')
$fixturePath = Join-Path $assets 'typography-fixture.html'
[IO.File]::WriteAllText($fixturePath,$html,[Text.UTF8Encoding]::new($false))
$record = [ordered]@{
    startedAtUtc=[DateTime]::UtcNow.ToString('o');status='running'
    sourceCommit=(git -C (Join-Path $workspace 'repos/desktop') rev-parse HEAD).Trim()
    sourceChanges=@(git -C (Join-Path $workspace 'repos/desktop') status --porcelain)
    browserVersion=(Get-Item $chrome).VersionInfo.ProductVersion
    fontSha256=$font.fontSha256
    scope='Chromium renders the real native asset map with controlled local metadata; font loading, Portuguese text, programmatic keyboard focus and viewport checks. No JNI/WebView2, playback, installed MSI or authenticated-source claim.'
    viewports=@()
}
try {
    foreach ($size in @('1366x768','1920x1080','2560x1440','3840x2160')) {
        $parts=$size.Split('x'); $width=[int]$parts[0]; $height=[int]$parts[1]
        $profile=Join-Path $evidence "chrome-$size"
        $capture=Join-Path $evidence "controls-$size.png"
        $dom=Join-Path $evidence "dom-$size.html"
        $log=Join-Path $evidence "chrome-$size.log"
        $url=([Uri]$fixturePath).AbsoluteUri
        $arguments=@('--headless','--disable-gpu','--no-first-run','--no-default-browser-check','--force-device-scale-factor=1',
            ('--user-data-dir="'+$profile+'"'),"--window-size=$width,$height",'--virtual-time-budget=2000',
            ('--screenshot="'+$capture+'"'),'--dump-dom',$url)
        $process=Start-Process -FilePath $chrome -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput $dom -RedirectStandardError $log
        if (-not $process.WaitForExit(45000)) { throw "Isolated Chromium fixture timed out at $size; inspect its owned process and log." }
        if ($process.ExitCode -ne 0) { throw "Chromium fixture failed at $size." }
        $markup=Get-Content -LiteralPath $dom -Raw
        $match=[regex]::Match($markup,'<pre id="telumia-qa-report"[^>]*>(.*?)</pre>',[Text.RegularExpressions.RegexOptions]::Singleline)
        if (-not $match.Success) { throw "Renderer did not produce a font report at $size." }
        $report=[Net.WebUtility]::HtmlDecode($match.Groups[1].Value) | ConvertFrom-Json
        if (-not $report.regularLoaded -or -not $report.boldLoaded -or -not $report.keyboardFocus -or
            $report.fontFamily -notmatch 'Telumia Manrope' -or $report.horizontalOverflow -or $report.errors.Count) {
            throw "Font, focus, overflow or JavaScript verification failed at $size."
        }
        $bytes=[IO.File]::ReadAllBytes($capture)
        if ($bytes.Length -lt 24 -or $bytes[0] -ne 137 -or $bytes[1] -ne 80) { throw 'Renderer capture is not a PNG.' }
        $actualWidth=[int64]$bytes[16]*16777216+[int64]$bytes[17]*65536+[int64]$bytes[18]*256+$bytes[19]
        $actualHeight=[int64]$bytes[20]*16777216+[int64]$bytes[21]*65536+[int64]$bytes[22]*256+$bytes[23]
        if ($actualWidth -ne $width -or $actualHeight -ne $height) { throw "Framebuffer differs from $size." }
        $record.viewports += [ordered]@{size=$size;report=$report;captureSha256=(Get-FileHash $capture).Hash.ToLowerInvariant()}
    }
    $record.status='passed'
} catch {
    $record.status='failed';$record.failure=$_.Exception.Message
    throw
} finally {
    $record.finishedAtUtc=[DateTime]::UtcNow.ToString('o')
    $record | ConvertTo-Json -Depth 7 | Set-Content -LiteralPath (Join-Path $evidence 'qa.json') -Encoding utf8
}
Write-Output 'Production native player assets rendered with Manrope at four desktop resolutions.'
