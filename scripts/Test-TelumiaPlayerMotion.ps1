[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[a-z0-9-]+$')][string]$BuildLabel,
    [Parameter(Mandatory)][ValidatePattern('^[a-z0-9-]+$')][string]$EvidenceLabel
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$checkout = Join-Path $workspace 'repos/desktop'
$sourceAssets = Join-Path $workspace "artifacts/$BuildLabel/desktop/telumia-player-assets"
$output = Join-Path $workspace "artifacts/$EvidenceLabel/desktop/browser-qa"
$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
$binding = Get-Content (Join-Path $workspace "docs/$BuildLabel-build-binding.json") -Raw | ConvertFrom-Json
$head = (git -C $checkout rev-parse HEAD).Trim()
if ($binding.buildStatus -ne 'passed' -or $binding.sourceCommit -ne $head -or @(git -C $checkout status --porcelain).Count) {
    throw 'A successful preserved build of the current clean desktop source is required.'
}
if (-not (Test-Path -LiteralPath $chrome)) { throw 'Installed Chromium is required.' }
if (Test-Path -LiteralPath $output) { throw 'Choose a new evidence label; renderer evidence cannot be replaced.' }
New-Item -ItemType Directory -Path $output | Out-Null
$assets = Join-Path $output 'telumia-player-assets'
Copy-Item -LiteralPath $sourceAssets -Destination $assets -Recurse
$assetHashes = [ordered]@{}
foreach ($file in @('controls.html','controls.js','timed-metadata.js')) {
    $hash = (Get-FileHash (Join-Path $assets $file)).Hash.ToLowerInvariant()
    if ($hash -ne (Get-FileHash (Join-Path $checkout "composeApp/src/desktopMain/resources/player-ui/$file")).Hash.ToLowerInvariant()) {
        throw "The exported production asset differs from the clean source: $file"
    }
    $assetHashes[$file] = $hash
}
$assetHashes['controls.css'] = (Get-FileHash (Join-Path $assets 'controls.css')).Hash.ToLowerInvariant()
$setup = @'
<script>
window.telumiaErrors=[]; window.telumiaCommands=[];
window.addEventListener('error',e=>window.telumiaErrors.push(String(e.message)));
window.addEventListener('unhandledrejection',e=>window.telumiaErrors.push(String(e.reason)));
window.webkit={messageHandlers:{player:{postMessage:m=>window.telumiaCommands.push(m)}}};
</script>
'@
$fixture = @'
<script>
(async()=>{
  const checks=[];
  const assert=(condition,name)=>{checks.push({name,passed:Boolean(condition)});if(!condition)throw Error(name);};
  const sleep=ms=>new Promise(resolve=>setTimeout(resolve,ms));
  const root=document.getElementById('playerRoot'),modal=document.getElementById('speedModal');
  const key=code=>document.dispatchEvent(new KeyboardEvent('keydown',{key:code==='Escape'?'Escape':'`',code,bubbles:true}));
  const cases=[];let token=0;
  try {
    document.body.style.background='linear-gradient(130deg,#080e18,#182b3d)';
    window.playerControls({title:'Telumia — Áudio e legendas',episodeText:'Temporada 1 · Episódio 12',
      audioLabel:'Áudio',subtitlesLabel:'Legendas',speedPanelTitle:'Velocidade de reprodução',
      pauseOverlayEnabled:false,controlsVisible:true,playbackSpeedLabel:'1x',
      timedMarkers:[{id:'qa-intro',kind:'INTRO',startFraction:0.04,endFraction:0.06,label:'Introdução',providerId:'fixture'}]});
    window.playerUpdate({duration:2400,position:612,paused:true,loading:false,volumeLevel:0.75,audioTracks:[],subtitleTracks:[]});
    await document.fonts.ready;
    for(const mode of ['FULL','REDUCED','OFF'])for(const intensity of [0.65,1,1.25]){
      const expected=mode==='OFF'?'off':mode==='REDUCED'||matchMedia('(prefers-reduced-motion: reduce)').matches?'reduced':'full';
      const duration=base=>mode==='OFF'?0:mode==='REDUCED'?Math.min(120,Math.trunc(base*intensity)):Math.trunc(base*intensity);
      window.playerControls({navigationMotion:mode,animationIntensity:intensity,motionFastMillis:duration(120),
        motionStandardMillis:duration(180),motionPanelMillis:duration(220),controlsVisible:true,skipPromptVisible:false});
      root.focus();key('Backquote');
      await sleep(360);
      assert(root.dataset.navigationMotion===expected,`${mode}/${intensity}: effective policy`);
      assert(!modal.hidden&&modal.classList.contains('modal-visible'),`${mode}/${intensity}: keyboard opens panel`);
      const panel=modal.querySelector('.track-panel'),style=getComputedStyle(panel);
      const durations=style.transitionDuration.split(',').map(s=>parseFloat(s)*1000);
      if(expected==='off')assert(durations.every(n=>n===0),`${mode}/${intensity}: transitions disabled`);
      if(expected==='reduced')assert(durations.every(n=>n<=120.01),`${mode}/${intensity}: short fades`);
      if(expected!=='full'){
        assert(style.transform==='none',`${mode}/${intensity}: no panel travel`);
        assert(getComputedStyle(document.querySelector('.opening-artwork')).animationName==='none',`${mode}/${intensity}: no ambient drift`);
      }
      const rows=Array.from(modal.querySelectorAll('.track-row'));
      rows[0].focus();key('ArrowRight');
      assert(document.activeElement===rows[1],`${mode}/${intensity}: arrow navigation`);
      const speed=rows.find(row=>row.textContent.trim()==='1.5x');
      assert(Boolean(speed),`${mode}/${intensity}: real speed option`);speed.click();
      assert(window.telumiaCommands.some(m=>m.type==='setPlaybackSpeed'&&m.value===1.5),`${mode}/${intensity}: speed command preserved`);
      await sleep(440);
      root.focus();key('Backquote');await sleep(360);key('Escape');
      assert(document.activeElement===root,`${mode}/${intensity}: Escape restores player focus`);
      if(expected==='off')assert(modal.hidden,`${mode}/${intensity}: instant close`);
      await sleep(320);assert(modal.hidden,`${mode}/${intensity}: closing panel released`);
      cases.push({mode,intensity,effective:expected,panelTransitionMillis:durations});
    }
    // A policy update and a close token can arrive in the same real bridge message.
    window.playerControls({navigationMotion:'FULL',controlsVisible:true});key('Backquote');await sleep(360);
    window.playerControls({navigationMotion:'OFF',closeModalsToken:++token});
    assert(modal.hidden,'Off policy applies before a simultaneous close token');
    // Closing then reopening must cancel the previous close timer.
    window.playerControls({navigationMotion:'FULL',motionPanelMillis:220});key('Backquote');await sleep(360);
    key('Escape');key('Backquote');await sleep(360);
    assert(!modal.hidden&&modal.classList.contains('modal-visible'),'Rapid reopen cancels the old close timer');
    key('Escape');await sleep(320);
    for(const mode of ['REDUCED','OFF']){
      window.playerControls({navigationMotion:mode,controlsVisible:false,skipPromptVisible:true,
        skipPromptLabel:'Pular introdução',skipPromptStartMs:1000,skipPromptEndMs:12000+token++});
      await sleep(300);
      assert(document.getElementById('skipPrompt').getAttribute('aria-hidden')==='false',`${mode}: skip prompt keeps its reading time`);
    }
    window.playerControls({navigationMotion:'FULL',motionFastMillis:120,motionStandardMillis:180,motionPanelMillis:220,
      animationIntensity:1,controlsVisible:true,skipPromptVisible:false});root.focus();key('Backquote');await sleep(360);
    assert(document.documentElement.scrollWidth<=innerWidth,'No horizontal viewport overflow');
    const bounds=modal.querySelector('.track-panel').getBoundingClientRect();
    assert(bounds.left>=0&&bounds.right<=innerWidth&&bounds.top>=0&&bounds.bottom<=innerHeight,'Panel stays inside viewport');
    assert(window.telumiaErrors.length===0,'No JavaScript error or rejected promise');
  }catch(error){window.telumiaErrors.push(String(error));}
  const report={checks,cases,errors:window.telumiaErrors,osReduced:matchMedia('(prefers-reduced-motion: reduce)').matches,
    viewport:{width:innerWidth,height:innerHeight},commands:window.telumiaCommands.filter(m=>m.type==='setPlaybackSpeed')};
  const pre=document.createElement('pre');pre.id='telumia-motion-report';pre.hidden=true;pre.textContent=JSON.stringify(report);document.body.append(pre);
})();
</script>
'@
$html=(Get-Content (Join-Path $assets 'controls.html') -Raw).Replace('</head>',$setup+'</head>').Replace('</body>',$fixture+'</body>')
$fixturePath=Join-Path $assets 'motion-fixture.html'
[IO.File]::WriteAllText($fixturePath,$html,[Text.UTF8Encoding]::new($false))
$record=[ordered]@{startedAtUtc=[DateTime]::UtcNow.ToString('o');status='running';sourceCommit=$head;buildLabel=$BuildLabel;
    browserVersion=(Get-Item $chrome).VersionInfo.ProductVersion;assetHashes=$assetHashes;viewports=@();
    scope='Actual packaged native player assets in isolated Chromium with controlled local metadata and a recording message bridge. Keyboard dispatch, policy changes, panel timing/focus and command checks; no JNI/WebView2, playback, installed MSI, authenticated source or physical-device proof.'}
try {
    foreach($size in @('1366x768','1920x1080','2560x1440','3840x2160')) {
      foreach($osReduced in @($false,$true)){
        $suffix=if($osReduced){'os-reduced'}else{'os-full'};$case="$size-$suffix"
        $parts=$size.Split('x');$width=[int]$parts[0];$height=[int]$parts[1]
        $capture=Join-Path $output "$case.png";$dom=Join-Path $output "$case.html"
        & node (Join-Path $PSScriptRoot 'Invoke-TelumiaChromiumFixture.mjs') $chrome (Join-Path $output "chrome-$case") `
            ([Uri]$fixturePath).AbsoluteUri $width $height $capture $dom $osReduced.ToString().ToLowerInvariant()
        if($LASTEXITCODE -ne 0){throw "Owned real-time Chromium fixture failed: $case"}
        $markup=Get-Content -LiteralPath $dom -Raw
        $match=[regex]::Match($markup,'<pre id="telumia-motion-report"[^>]*>(.*?)</pre>',[Text.RegularExpressions.RegexOptions]::Singleline)
        if(-not $match.Success){throw "Missing motion report: $case"}
        $report=[Net.WebUtility]::HtmlDecode($match.Groups[1].Value)|ConvertFrom-Json
        $record.viewports+=@{size=$size;osReduced=$osReduced;report=$report;captureSha256=(Get-FileHash $capture).Hash.ToLowerInvariant()}
        if($report.errors.Count -or @($report.checks|Where-Object {-not $_.passed}).Count -or $report.cases.Count -ne 9 -or $report.osReduced -ne $osReduced){
            throw "Player motion behavior failed: $case; inspect preserved report."
        }
      }
    }
    $record.status='passed'
}catch{$record.status='failed';$record.failure=$_.Exception.Message;throw}
finally{$record.finishedAtUtc=[DateTime]::UtcNow.ToString('o');$record|ConvertTo-Json -Depth 10|Set-Content (Join-Path $output 'qa.json') -Encoding utf8}
Write-Output 'Native player motion and keyboard behavior passed at four desktop resolutions, with both OS motion settings.'
