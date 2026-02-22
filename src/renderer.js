/* PixelBatch renderer */

let selectedFiles = [];
let conversionResults = null;
let tempDir = null;

// DOM
const dropZone       = document.getElementById('dropZone');
const selectBtn      = document.getElementById('selectBtn');
const filesPanel     = document.getElementById('filesPanel');
const filesContainer = document.getElementById('filesContainer');
const fileCount      = document.getElementById('fileCount');
const clearBtn       = document.getElementById('clearBtn');
const convertBtn     = document.getElementById('convertBtn');

const stepSelect     = document.getElementById('step-select');
const stepConverting = document.getElementById('step-converting');
const stepComplete   = document.getElementById('step-complete');

const progressBar     = document.getElementById('progressBar');
const progressText    = document.getElementById('progressText');
const progressPercent = document.getElementById('progressPercent');
const currentFileName = document.getElementById('currentFileName');
const statusText      = document.getElementById('statusText');
const logBox          = document.getElementById('logBox');

const successCount = document.getElementById('successCount');
const failCount    = document.getElementById('failCount');
const downloadBtn  = document.getElementById('downloadBtn');
const restartBtn   = document.getElementById('restartBtn');
const failedBox    = document.getElementById('failedBox');
const failedList   = document.getElementById('failedList');

const errorPopup   = document.getElementById('errorPopup');
const errorMessage = document.getElementById('errorMessage');

// Steps
function showStep(el) {
  [stepSelect, stepConverting, stepComplete].forEach(s => s.classList.remove('active'));
  el.classList.add('active');
}

// Drag & Drop
dropZone.addEventListener('dragover', e => {
  e.preventDefault();
  dropZone.classList.add('drag-over');
});
dropZone.addEventListener('dragleave', () => dropZone.classList.remove('drag-over'));
dropZone.addEventListener('drop', e => {
  e.preventDefault();
  dropZone.classList.remove('drag-over');
  const files = Array.from(e.dataTransfer.files).filter(f =>
    /\.(heic|heif)$/i.test(f.name)
  );
  if (!files.length) return showError('Yaln\u0131zca HEIC / HEIF dosyalar\u0131 se\u00e7in.');
  files.forEach(f => {
    if (!selectedFiles.find(s => s.path === f.path))
      selectedFiles.push({ name: f.name, path: f.path });
  });
  renderFiles();
});

// File picker
selectBtn.addEventListener('click', async () => {
  const paths = await window.electronAPI.selectFiles();
  paths.forEach(p => {
    const name = p.split(/[\\/]/).pop();
    if (!selectedFiles.find(f => f.path === p))
      selectedFiles.push({ name, path: p });
  });
  renderFiles();
});

// Render file list
function renderFiles() {
  if (!selectedFiles.length) {
    filesPanel.classList.remove('visible');
    return;
  }
  filesPanel.classList.add('visible');
  fileCount.textContent = selectedFiles.length;
  filesContainer.innerHTML = '';
  selectedFiles.forEach((f, i) => {
    const row = document.createElement('div');
    row.className = 'file-row';
    row.innerHTML =
      '<span class="file-row-name">' + f.name + '</span>' +
      '<button class="file-row-remove" data-idx="' + i + '">Kald\u0131r</button>';
    filesContainer.appendChild(row);
  });
}

filesContainer.addEventListener('click', e => {
  if (e.target.classList.contains('file-row-remove')) {
    selectedFiles.splice(+e.target.dataset.idx, 1);
    renderFiles();
  }
});

clearBtn.addEventListener('click', () => { selectedFiles = []; renderFiles(); });

// Convert
convertBtn.addEventListener('click', async () => {
  if (!selectedFiles.length) return showError('L\u00fctfen en az bir dosya se\u00e7in.');
  showStep(stepConverting);
  logBox.innerHTML = '';
  try {
    const results = await window.electronAPI.convertFiles(selectedFiles.map(f => f.path));
    conversionResults = results;
    tempDir = results.outputDir;
    showComplete(results);
  } catch (err) {
    showError('D\u00f6n\u00fc\u015ft\u00fcrme hatas\u0131: ' + err.message);
    showStep(stepSelect);
  }
});

// IPC listeners
window.electronAPI.onConversionProgress(d => {
  const pct = Math.round((d.current / d.total) * 100);
  progressBar.style.width = pct + '%';
  progressText.textContent = d.current + ' / ' + d.total;
  progressPercent.textContent = '%' + pct;
  currentFileName.textContent = d.fileName;
  statusText.textContent = d.status;
});

window.electronAPI.onFileConverted(d => {
  const row = document.createElement('div');
  row.className = 'log-row ' + d.status;
  row.textContent = (d.status === 'success' ? '\u2713 ' : '\u2717 ') + d.fileName;
  logBox.appendChild(row);
  logBox.scrollTop = logBox.scrollHeight;
});

window.electronAPI.onConversionComplete(d => { conversionResults = d; showComplete(d); });
window.electronAPI.onConversionError(d => showError(d.message));

// Complete
function showComplete(r) {
  showStep(stepComplete);
  successCount.textContent = r.successful ?? 0;
  failCount.textContent    = r.failed ?? 0;
  downloadBtn.disabled = !(r.successful > 0 && r.zipPath);

  if (r.failed > 0 && conversionResults && Array.isArray(conversionResults.failed)) {
    failedBox.classList.add('visible');
    failedList.innerHTML = '';
    conversionResults.failed.forEach(f => {
      const d = document.createElement('div');
      d.className = 'failed-item';
      d.innerHTML =
        '<div class="failed-item-name">' + f.fileName + '</div>' +
        '<div class="failed-item-error">' + f.error + '</div>';
      failedList.appendChild(d);
    });
  } else {
    failedBox.classList.remove('visible');
  }
}

// Download
downloadBtn.addEventListener('click', async () => {
  if (!conversionResults?.zipPath) return showError('ZIP dosyas\u0131 bulunamad\u0131.');
  downloadBtn.disabled = true;
  downloadBtn.textContent = '\u0130ndiriliyor\u2026';
  try {
    const saved = await window.electronAPI.saveFile(conversionResults.zipPath);
    if (saved) {
      if (tempDir) await window.electronAPI.cleanup(tempDir).catch(() => {});
      downloadBtn.textContent = '\u0130ndirildi!';
      setTimeout(restart, 1500);
    } else {
      downloadBtn.disabled = false;
      downloadBtn.textContent = 'ZIP \u0130ndir';
    }
  } catch (err) {
    showError('\u0130ndirme hatas\u0131: ' + err.message);
    downloadBtn.disabled = false;
    downloadBtn.textContent = 'ZIP \u0130ndir';
  }
});

// Restart
restartBtn.addEventListener('click', restart);
function restart() {
  selectedFiles = [];
  conversionResults = null;
  tempDir = null;
  renderFiles();
  downloadBtn.disabled = false;
  downloadBtn.textContent = 'ZIP \u0130ndir';
  showStep(stepSelect);
}

// Error popup
function showError(msg) {
  errorMessage.textContent = msg;
  errorPopup.classList.add('visible');
}

window.closeError = () => errorPopup.classList.remove('visible');
errorPopup.addEventListener('click', e => { if (e.target === errorPopup) window.closeError(); });

// Cleanup
window.addEventListener('beforeunload', async () => {
  if (tempDir) await window.electronAPI.cleanup(tempDir).catch(() => {});
});
