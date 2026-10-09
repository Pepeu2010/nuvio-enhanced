// Project-owned renderer test only. Never connects to an existing user browser/profile.
import { spawn } from 'node:child_process';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
const [chrome, profile, url, widthText, heightText, capture, dom, osReduced] = process.argv.slice(2);
const width=Number(widthText),height=Number(heightText);
if(!chrome||!profile||!url?.startsWith('file:')||!Number.isInteger(width)||!Number.isInteger(height)||width<320||height<240)
  throw Error('Explicit owned fixture URL/profile and valid viewport are required.');
await mkdir(profile,{recursive:false});
const browser=spawn(chrome,['--headless','--disable-gpu','--no-first-run','--no-default-browser-check',
  '--disable-background-timer-throttling','--remote-debugging-port=0',`--user-data-dir=${profile}`,'about:blank'],
  {windowsHide:true,stdio:['ignore','ignore','ignore']});
const sleep=ms=>new Promise(resolve=>setTimeout(resolve,ms));
let socket;let nextId=0;const pending=new Map();
const request=(method,params={})=>new Promise((resolve,reject)=>{
  const id=++nextId;
  const timer=setTimeout(()=>{pending.delete(id);reject(Error(`Owned CDP request timed out: ${method}`));},5000);
  pending.set(id,{resolve,reject,timer});socket.send(JSON.stringify({id,method,params}));
});
try{
  let port;
  const bootDeadline=Date.now()+15000;
  while(Date.now()<bootDeadline){
    try{const text=await readFile(path.join(profile,'DevToolsActivePort'),'utf8');port=Number(text.split('\n')[0]);if(port>0)break;}catch{}
    await sleep(100);
  }
  if(!port)throw Error('Owned Chromium did not publish its isolated debug port.');
  const tabs=await(await fetch(`http://127.0.0.1:${port}/json/list`)).json();
  const tab=tabs.find(item=>item.type==='page'&&item.url==='about:blank');
  if(!tab)throw Error('Owned blank renderer tab was not found.');
  socket=new WebSocket(tab.webSocketDebuggerUrl);
  await new Promise((resolve,reject)=>{socket.addEventListener('open',resolve,{once:true});socket.addEventListener('error',reject,{once:true});});
  socket.addEventListener('message',event=>{
    const message=JSON.parse(event.data),item=pending.get(message.id);if(!item)return;
    pending.delete(message.id);clearTimeout(item.timer);
    if(message.error)item.reject(Error(JSON.stringify(message.error)));else item.resolve(message.result);
  });
  socket.addEventListener('close',()=>{for(const item of pending.values()){clearTimeout(item.timer);item.reject(Error('Owned renderer closed.'));}pending.clear();});
  await request('Page.enable');
  await request('Emulation.setDeviceMetricsOverride',{width,height,deviceScaleFactor:1,mobile:false});
  await request('Emulation.setEmulatedMedia',{features:[{name:'prefers-reduced-motion',value:osReduced==='true'?'reduce':'no-preference'}]});
  await request('Page.navigate',{url});
  let report;
  const deadline=Date.now()+45000;
  while(Date.now()<deadline){
    const result=await request('Runtime.evaluate',{expression:"document.getElementById('telumia-motion-report')?.textContent",returnByValue:true});
    if(result.result?.value){report=JSON.parse(result.result.value);break;}
    await sleep(200);
  }
  const markup=await request('Runtime.evaluate',{expression:'document.documentElement.outerHTML',returnByValue:true});
  await writeFile(dom,String(markup.result?.value??''),'utf8');
  const screenshot=await request('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});
  await writeFile(capture,Buffer.from(screenshot.data,'base64'));
  if(!report)throw Error('Owned real-time renderer did not finish its motion report.');
  console.log('Owned Chromium fixture finished with real frames and real timer deadlines.');
}finally{
  if(socket?.readyState===WebSocket.OPEN){await request('Browser.close').catch(()=>{});socket.close();}
  if(browser.exitCode===null)browser.kill();
}
