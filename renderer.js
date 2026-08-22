const $ = (id) => document.getElementById(id);
const sharedFields = ['testId','project','objectiveType','objective','location','operator','observer','droneCategory','droneModel','serialNumber','flightController','groundControl','equipmentHardware','weather'];
const flightFields = ['flightDateTime','batteryId','duration','flightModes','missionPerformed','telemetrySummary','anomalies','expectedBehaviour','immediateAction','findings','operatorNotes','flightResult'];
const state = { report: {}, flights: [], activeFlight: 0, attachments: [], flightLogPath: '', captureFilePath: '' };
let recognition = null;
function esc(value = '') { return String(value).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\"/g,'&quot;'); }
const MAX_ATTACHMENT_BYTES = 15 * 1024 * 1024;
function attachmentName(a) { return typeof a === 'string' ? a : (a && a.name) || 'Attachment'; }
function normalizeAttachment(a) {
  if (typeof a === 'string') return { name: a, type: '', size: 0, dataUrl: '' };
  return { name: (a && a.name) || 'Attachment', type: (a && a.type) || '', size: (a && a.size) || 0, dataUrl: (a && a.dataUrl) || '' };
}
function isImageAttachment(a) { const item = normalizeAttachment(a); return Boolean(item.dataUrl && String(item.type || '').startsWith('image/')); }
function fileToDataURL(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = () => reject(reader.error || new Error('Failed to read file'));
    reader.readAsDataURL(file);
  });
}
function evidenceListHTML(attachments = []) {
  return attachments.map((a) => {
    const item = normalizeAttachment(a);
    if (isImageAttachment(item)) {
      return `<li><div>${esc(item.name)}</div><img class="evidence-image" src="${item.dataUrl}" alt="${esc(item.name)}"></li>`;
    }
    if (item.dataUrl) {
      return `<li><a href="${item.dataUrl}" download="${esc(item.name)}">${esc(item.name)}</a></li>`;
    }
    return `<li>${esc(item.name)}</li>`;
  }).join('');
}
function nowLocal() { const d = new Date(); d.setMinutes(d.getMinutes() - d.getTimezoneOffset()); return d.toISOString().slice(0,16); }
function newFlight(number = state.flights.length + 1) { return { id: crypto.randomUUID(), flightNumber:number, flightDateTime:nowLocal(), batteryId:'', duration:'', flightModes:'', missionPerformed:'', telemetrySummary:'', anomalies:'', expectedBehaviour:'', immediateAction:'', findings:'', operatorNotes:'', flightResult:'Pending', flightLogPath:'', captureFilePath:'', attachments:[] }; }
function readShared() { sharedFields.forEach(k => state.report[k] = $(k).value.trim()); }
function writeShared() { sharedFields.forEach(k => { $(k).value = state.report[k] || ''; }); }
function readFlight() { const f=state.flights[state.activeFlight]; if(!f)return; flightFields.forEach(k=>f[k]=$(k).value); f.flightLogPath=state.flightLogPath; f.captureFilePath=state.captureFilePath; f.attachments=[...state.attachments]; }
function writeFlight() { const f=state.flights[state.activeFlight]; if(!f)return; flightFields.forEach(k=>$(k).value=f[k]??''); state.flightLogPath=f.flightLogPath||''; state.captureFilePath=f.captureFilePath||''; state.attachments=[...(f.attachments||[])]; $('flightTitle').textContent=`Flight ${String(f.flightNumber).padStart(2,'0')}`; $('flightLogPathDisplay').textContent=state.flightLogPath||'Not selected'; $('captureFilePathDisplay').textContent=state.captureFilePath||'Not selected'; renderAttachments(); renderFlights(); }
function renderFlights() { $('flightCount').textContent=state.flights.length; $('flightList').innerHTML=state.flights.map((f,i)=>`<button class="flight-item ${i===state.activeFlight?'active':''}" data-index="${i}"><span>Flight ${String(f.flightNumber).padStart(2,'0')}</span><small>${esc(f.flightResult)}</small></button>`).join(''); document.querySelectorAll('.flight-item').forEach(b=>b.addEventListener('click',()=>{readFlight();state.activeFlight=Number(b.dataset.index);writeFlight();})); }
function renumberFlights() { state.flights.forEach((f,i)=>f.flightNumber=i+1); }
function addFlight() { readFlight(); state.flights.push(newFlight()); state.activeFlight=state.flights.length-1; writeFlight(); }
function removeCurrentFlight() { if(state.flights.length<=1){alert('A report must contain at least one flight.');return;} if(!confirm(`Remove Flight ${String(state.activeFlight+1).padStart(2,'0')} from this report?`))return; state.flights.splice(state.activeFlight,1); renumberFlights(); state.activeFlight=Math.min(state.activeFlight,state.flights.length-1); writeFlight(); }
function resetReport() { state.report={};state.flights=[newFlight(1)];state.activeFlight=0;state.attachments=[];state.flightLogPath='';state.captureFilePath='';writeShared();writeFlight();$('reportPreview').innerHTML='<p>Add flights and generate the report.</p>'; }
function loadReport(data) { if(!data||!Array.isArray(data.flights)||!data.flights.length){alert('This JSON file is not a valid Drone Flight Test Report.');return;} state.report={}; sharedFields.forEach(k=>state.report[k]=data[k]||''); state.flights=data.flights.map((f,i)=>({...newFlight(i+1),...f,flightNumber:i+1,attachments:(f.attachments||[]).map(normalizeAttachment),flightLogPath:f.flightLogPath||'',captureFilePath:f.captureFilePath||''})); state.activeFlight=0; writeShared();writeFlight();generate(); }
function renderAttachments() { $('attachmentList').innerHTML=state.attachments.length?state.attachments.map((p,i)=>{ const name=attachmentName(p); return `<div class="attachment-item"><span title="${esc(name)}">${esc(name)}</span><button class="remove-attachment secondary" data-index="${i}">Remove</button></div>`; }).join(''):'<em>No evidence attached.</em>'; document.querySelectorAll('.remove-attachment').forEach(b=>b.addEventListener('click',()=>{readFlight();state.attachments.splice(Number(b.dataset.index),1);writeFlight();})); }
function timeline(text) { return text.split(/\n+/).map(x=>x.trim()).filter(Boolean).map(line=>{const m=line.match(/^(\d{1,2}:\d{2}(?:\s*[AP]M)?)\s*[—\-:]?\s*(.*)$/i);return m?{time:m[1],note:m[2]}:{time:'',note:line};}); }
function overallResult() { const r=state.flights.map(f=>f.flightResult); if(r.includes('Fail'))return 'FAIL'; if(r.includes('Aborted'))return 'ABORTED'; if(r.includes('Pass with observations'))return 'PASS WITH OBSERVATIONS'; if(r.length&&r.every(x=>x==='Pass'))return 'PASS'; return 'PENDING'; }
function reportData() { readShared();readFlight();return {version:5,createdAt:new Date().toISOString(),...state.report,overallResult:overallResult(),flights:state.flights.map((f,i)=>{ const {missionId, ...flight} = f; return {...flight,flightNumber:i+1,attachments:(flight.attachments||[]).map(normalizeAttachment),timeline:timeline(f.operatorNotes)}; })}; }
function buildMarkdown(data) { const out=[`# Drone Flight Test Report — ${data.testId||'Untitled'}`,'',`**Project / Customer:** ${data.project||'N/A'}  `,`**Test Objective Type:** ${data.objectiveType||'N/A'}  `,`**Overall Result:** ${data.overallResult}  `,`**Location:** ${data.location||'N/A'}  `,`**Operator:** ${data.operator||'N/A'}  `,`**Observer:** ${data.observer||'N/A'}  `,'','## Test Objective','',data.objective||'N/A','','## Aircraft & Configuration','',`- UAV Category: ${data.droneCategory||'N/A'}`,`- Aircraft / Model: ${data.droneModel||'N/A'}`,`- Serial Number: ${data.serialNumber||'N/A'}`,`- Flight Controller: ${data.flightController||'N/A'}`,`- Ground Control: ${data.groundControl||'N/A'}`,`- Equipment / Hardware: ${data.equipmentHardware||'N/A'}`,`- Weather: ${data.weather||'N/A'}`,'','## Flight Summary','','| Flight | Mission | Result | Battery | Duration |','|---:|---|---|---|---|']; data.flights.forEach(f=>out.push(`| ${f.flightNumber} | ${f.missionPerformed||'N/A'} | ${f.flightResult} | ${f.batteryId||'N/A'} | ${f.duration||'N/A'} |`)); data.flights.forEach(f=>{out.push('','## Flight '+String(f.flightNumber).padStart(2,'0')+' — '+f.flightResult,'',`**Date / Time:** ${f.flightDateTime||'N/A'}  `,`**Battery:** ${f.batteryId||'N/A'}  `,`**Duration:** ${f.duration||'N/A'}  `,`**Flight Modes:** ${f.flightModes||'N/A'}`,'','### Mission',f.missionPerformed||'N/A','','### Telemetry',f.telemetrySummary||'N/A','','### Anomaly / Bug',f.anomalies||'None reported','','### Expected Behaviour',f.expectedBehaviour||'N/A','','### Immediate Action',f.immediateAction||'None','','### Findings',f.findings||'N/A','','### Operator Timeline'); f.timeline.forEach(e=>out.push(`- ${e.time?e.time+' — ':''}${e.note}`)); out.push('','### Evidence',`- Flight log: ${f.flightLogPath||'None'}`,`- Wireshark capture: ${f.captureFilePath||'None'}`,...(f.attachments||[]).map(x=>`- Attachment: ${attachmentName(x)}`)); }); out.push('','## Conclusion','',`Overall test result: **${data.overallResult}**.`); return out.join('\n'); }
function buildReportHTML(data) { const summary=data.flights.map(f=>`<tr><td>${f.flightNumber}</td><td>${esc(f.missionPerformed||'N/A')}</td><td>${esc(f.flightResult)}</td><td>${esc(f.batteryId||'N/A')}</td><td>${esc(f.duration||'N/A')}</td></tr>`).join(''); const flights=data.flights.map(f=>`<section class="flight"><h2>Flight ${String(f.flightNumber).padStart(2,'0')} — ${esc(f.flightResult)}</h2><div class="facts"><b>Date:</b> ${esc(f.flightDateTime||'N/A')} <b>Battery:</b> ${esc(f.batteryId||'N/A')} <b>Duration:</b> ${esc(f.duration||'N/A')} <b>Flight Modes:</b> ${esc(f.flightModes||'N/A')}</div><h3>Mission</h3><p>${esc(f.missionPerformed||'N/A').replace(/\n/g,'<br>')}</p><h3>Telemetry</h3><p>${esc(f.telemetrySummary||'N/A').replace(/\n/g,'<br>')}</p><h3>Anomaly / Bug</h3><p>${esc(f.anomalies||'None reported').replace(/\n/g,'<br>')}</p><h3>Expected Behaviour</h3><p>${esc(f.expectedBehaviour||'N/A').replace(/\n/g,'<br>')}</p><h3>Immediate Action</h3><p>${esc(f.immediateAction||'None').replace(/\n/g,'<br>')}</p><h3>Findings</h3><p>${esc(f.findings||'N/A').replace(/\n/g,'<br>')}</p><h3>Operator Timeline</h3><ul>${f.timeline.map(e=>`<li>${e.time?`<b>${esc(e.time)}</b> — `:''}${esc(e.note)}</li>`).join('')||'<li>No timeline entries.</li>'}</ul><h3>Evidence</h3><ul><li>Flight log: ${esc(f.flightLogPath||'None')}</li><li>Wireshark capture: ${esc(f.captureFilePath||'None')}</li>${evidenceListHTML(f.attachments)}</ul></section>`).join(''); return `<!doctype html><html><head><meta charset="utf-8"><style>body{font-family:Arial,sans-serif;margin:40px;color:#20242b}h1{font-size:28px}h2{border-bottom:1px solid #bbb;padding-bottom:6px;margin-top:30px}.facts{background:#f3f4f6;padding:10px;line-height:1.8}.flight{page-break-before:always}table{border-collapse:collapse;width:100%}th,td{border:1px solid #bbb;padding:7px;text-align:left}th{background:#eee}p,li{line-height:1.5}.cover{page-break-after:always}.evidence-image{display:block;max-width:100%;max-height:420px;margin-top:8px;border:1px solid #bbb}</style></head><body><section class="cover"><h1>Drone Flight Test Report</h1><h2>${esc(data.testId||'Untitled')}</h2><p><b>Project:</b> ${esc(data.project||'N/A')}</p><p><b>Test Objective Type:</b> ${esc(data.objectiveType||'N/A')}</p><p><b>Overall Result:</b> ${esc(data.overallResult)}</p><p><b>Objective:</b><br>${esc(data.objective||'N/A').replace(/\n/g,'<br>')}</p><h3>Aircraft</h3><p><b>UAV Category:</b> ${esc(data.droneCategory||'N/A')}<br><b>Aircraft / Model:</b> ${esc(data.droneModel||'N/A')}<br><b>Serial Number:</b> ${esc(data.serialNumber||'N/A')}<br><b>Equipment / Hardware:</b><br>${esc(data.equipmentHardware||'N/A').replace(/\n/g,'<br>')}</p><p><b>Operator:</b> ${esc(data.operator||'N/A')}<br><b>Observer:</b> ${esc(data.observer||'N/A')}<br><b>Location:</b> ${esc(data.location||'N/A')}</p><h3>Flight Summary</h3><table><thead><tr><th>Flight</th><th>Mission</th><th>Result</th><th>Battery</th><th>Duration</th></tr></thead><tbody>${summary}</tbody></table></section>${flights}<h2>Conclusion</h2><p>Overall test result: <b>${esc(data.overallResult)}</b>.</p></body></html>`; }
function generate() { const data=reportData(); $('reportPreview').innerHTML=buildReportHTML(data).replace(/^<!doctype html><html><head>[\s\S]*?<\/head><body>|<\/body><\/html>$/g,''); return data; }
async function selectFile(kind){ readFlight(); const options=kind==='log'?{title:'Select Flight Log',filters:[{name:'Flight Logs',extensions:['ulg','bin','log','tlog','csv']}] }:{title:'Select Wireshark Capture',filters:[{name:'Capture Files',extensions:['pcap','pcapng','cap']}]}; const r=await window.api.selectFiles(options); if(r.canceled)return; if(kind==='log')state.flightLogPath=r.filePaths[0]; else state.captureFilePath=r.filePaths[0]; writeFlight(); }
async function addAttachments(){
  readFlight();
  const r = await window.api.selectFiles({ title: 'Select Evidence / Attachments', multi: true });
  if (r.canceled || !r.files || !r.files.length) return;
  const existing = new Map(state.attachments.map((a) => [attachmentName(a), normalizeAttachment(a)]));
  const skipped = [];
  for (const file of r.files) {
    if (file.size > MAX_ATTACHMENT_BYTES) {
      skipped.push(file.name);
      continue;
    }
    try {
      const dataUrl = await fileToDataURL(file);
      existing.set(file.name, { name: file.name, type: file.type || 'application/octet-stream', size: file.size, dataUrl });
    } catch (error) {
      skipped.push(file.name);
    }
  }
  state.attachments = [...existing.values()];
  writeFlight();
  if (skipped.length) alert(`These files could not be added (over 15 MB or unreadable):\n${skipped.join('\n')}`);
}
async function openReport(){ const r=await window.api.openJSON(); if(r.canceled)return; if(r.error){alert(r.error);return;} loadReport(r.data); $('voiceStatus').textContent=`Opened ${r.filePath}`; }

let voiceDesired = false;
let mediaRecorder = null;
let mediaStream = null;
let recordedChunks = [];

function setVoiceStatus(text) { $('voiceStatus').textContent = text; }
function setVoiceButtons(listening) {
  $('startVoiceButton').disabled = listening;
  $('stopVoiceButton').disabled = !listening;
}
function appendOperatorNote(text) {
  if (!text || !String(text).trim()) return;
  const el = $('operatorNotes');
  const stamp = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  el.value += (el.value ? '\n' : '') + `${stamp} — ${String(text).trim()}`;
  readFlight();
}
function voiceErrorMessage(code) {
  const map = {
    'not-allowed': 'Microphone permission denied. Allow mic access for this site, then try again.',
    'service-not-allowed': 'Speech service blocked (common in Brave). Allow Google speech services or use Chrome, or use audio recording fallback.',
    'network': 'Speech service network error. Check internet connection, or use Chrome. Audio recording still works offline.',
    'audio-capture': 'No microphone found or mic is busy.',
    'no-speech': 'No speech detected. Click Start Voice Note and speak again.',
    'aborted': 'Voice note stopped.',
  };
  return map[code] || `Voice error: ${code}`;
}
function getSpeechRecognition() {
  return window.SpeechRecognition || window.webkitSpeechRecognition || null;
}
async function ensureMicrophone() {
  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    throw new Error('This browser cannot access the microphone.');
  }
  mediaStream = await navigator.mediaDevices.getUserMedia({ audio: true });
  return mediaStream;
}
function stopMediaTracks() {
  if (mediaStream) {
    mediaStream.getTracks().forEach((t) => t.stop());
    mediaStream = null;
  }
}
function startSpeechRecognition() {
  const SR = getSpeechRecognition();
  if (!SR) return false;
  recognition = new SR();
  recognition.continuous = true;
  recognition.interimResults = true;
  recognition.lang = 'en-US';
  recognition.onstart = () => {
    setVoiceButtons(true);
    setVoiceStatus('Listening… speak now. Click Stop when finished.');
  };
  recognition.onresult = (event) => {
    let finalText = '';
    let interim = '';
    for (let i = event.resultIndex; i < event.results.length; i++) {
      const piece = event.results[i][0].transcript;
      if (event.results[i].isFinal) finalText += piece;
      else interim += piece;
    }
    if (finalText) appendOperatorNote(finalText);
    if (interim) setVoiceStatus(`Listening… ${interim}`);
    else if (voiceDesired) setVoiceStatus('Listening… speak now. Click Stop when finished.');
  };
  recognition.onerror = (event) => {
    const code = event.error || 'unknown';
    setVoiceStatus(voiceErrorMessage(code));
    if (code === 'not-allowed' || code === 'service-not-allowed' || code === 'network') {
      // Keep mic recording fallback running if already started.
      if (!mediaRecorder || mediaRecorder.state === 'inactive') {
        startAudioRecordingFallback().catch(() => {});
      }
    }
  };
  recognition.onend = () => {
    if (voiceDesired) {
      // Chromium ends recognition after pauses; restart while user still wants listening.
      try { recognition.start(); }
      catch (err) {
        setVoiceButtons(false);
        voiceDesired = false;
        setVoiceStatus('Voice recognition stopped. Click Start Voice Note to try again.');
      }
      return;
    }
    setVoiceButtons(false);
    if (!mediaRecorder || mediaRecorder.state === 'inactive') {
      setVoiceStatus('Voice transcription idle.');
    }
  };
  recognition.start();
  return true;
}
async function startAudioRecordingFallback() {
  const stream = mediaStream || await ensureMicrophone();
  recordedChunks = [];
  mediaRecorder = new MediaRecorder(stream);
  mediaRecorder.ondataavailable = (event) => {
    if (event.data && event.data.size) recordedChunks.push(event.data);
  };
  mediaRecorder.onstop = async () => {
    try {
      if (!recordedChunks.length) {
        setVoiceStatus('No audio captured.');
        return;
      }
      const blob = new Blob(recordedChunks, { type: mediaRecorder.mimeType || 'audio/webm' });
      const ext = (blob.type.includes('mp4') && 'mp4') || (blob.type.includes('ogg') && 'ogg') || 'webm';
      const name = `voice-note-${new Date().toISOString().replace(/[:.]/g, '-')}.${ext}`;
      const dataUrl = await new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = () => reject(reader.error || new Error('Failed to read audio'));
        reader.readAsDataURL(blob);
      });
      readFlight();
      const existing = new Map(state.attachments.map((a) => [attachmentName(a), normalizeAttachment(a)]));
      existing.set(name, { name, type: blob.type || 'audio/webm', size: blob.size, dataUrl });
      state.attachments = [...existing.values()];
      appendOperatorNote(`Voice audio recorded: ${name}`);
      writeFlight();
      setVoiceStatus(`Audio voice note saved as attachment: ${name}`);
    } catch (error) {
      setVoiceStatus(`Could not save audio note: ${error.message || error}`);
    } finally {
      stopMediaTracks();
      mediaRecorder = null;
      recordedChunks = [];
    }
  };
  mediaRecorder.start();
  setVoiceButtons(true);
  setVoiceStatus('Recording audio note… click Stop Voice Note to save it.');
}
async function startVoice() {
  if (voiceDesired) return;
  voiceDesired = true;
  setVoiceStatus('Requesting microphone permission…');
  try {
    await ensureMicrophone();
  } catch (error) {
    voiceDesired = false;
    setVoiceButtons(false);
    setVoiceStatus(error && error.name === 'NotAllowedError'
      ? voiceErrorMessage('not-allowed')
      : `Microphone error: ${error.message || error}`);
    return;
  }

  const hasSpeech = Boolean(getSpeechRecognition());
  if (hasSpeech) {
    try {
      startSpeechRecognition();
      // Also record audio in parallel so Brave/network speech failures still capture a note.
      if (!mediaRecorder || mediaRecorder.state === 'inactive') {
        await startAudioRecordingFallback();
        setVoiceStatus('Listening + recording… speak now. Click Stop when finished.');
      }
      return;
    } catch (error) {
      setVoiceStatus(`Speech recognition failed: ${error.message || error}. Falling back to audio recording.`);
    }
  } else {
    setVoiceStatus('Live transcription unavailable here. Recording audio note instead…');
  }
  try {
    await startAudioRecordingFallback();
  } catch (error) {
    voiceDesired = false;
    setVoiceButtons(false);
    stopMediaTracks();
    setVoiceStatus(`Voice note failed: ${error.message || error}`);
  }
}
function stopVoice() {
  voiceDesired = false;
  if (recognition) {
    try { recognition.onend = null; recognition.stop(); } catch (err) {}
    recognition = null;
  }
  if (mediaRecorder && mediaRecorder.state !== 'inactive') {
    try { mediaRecorder.stop(); } catch (err) {}
  } else {
    stopMediaTracks();
    setVoiceButtons(false);
    setVoiceStatus('Voice transcription idle.');
  }
}

sharedFields.forEach(id=>$(id).addEventListener('input',readShared)); flightFields.forEach(id=>$(id).addEventListener('input',readFlight));
$('addFlightButton').addEventListener('click',addFlight); $('removeFlightButton').addEventListener('click',removeCurrentFlight); $('newReportButton').addEventListener('click',()=>{if(confirm('Start a new report? Unsaved data will be cleared.'))resetReport();}); $('openReportButton').addEventListener('click',openReport);
$('selectFlightLogButton').addEventListener('click',()=>selectFile('log')); $('selectCaptureButton').addEventListener('click',()=>selectFile('capture')); $('addAttachmentButton').addEventListener('click',addAttachments); $('startVoiceButton').addEventListener('click',startVoice); $('stopVoiceButton').addEventListener('click',stopVoice); $('generateReportButton').addEventListener('click',generate);
$('saveDataButton').addEventListener('click',async()=>{const d=reportData();const r=await window.api.saveJSON(d,`${d.testId||'flight-test-report'}.json`);if(!r.canceled)$('voiceStatus').textContent=`Report saved to ${r.filePath}`;}); $('exportMarkdownButton').addEventListener('click',async()=>{const d=reportData();const r=await window.api.saveMarkdown(buildMarkdown(d),`${d.testId||'flight-test-report'}.md`);if(!r.canceled)$('voiceStatus').textContent='Markdown report exported.';}); $('exportPdfButton').addEventListener('click',async()=>{const d=reportData();const r=await window.api.exportPDF(buildReportHTML(d),`${d.testId||'flight-test-report'}.pdf`);if(!r.canceled)$('voiceStatus').textContent='PDF report exported.';});
resetReport();
