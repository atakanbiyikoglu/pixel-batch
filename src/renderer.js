// State
let selectedFiles = [];
let conversionResults = null;
let tempDir = null;

// DOM Elements
const dropZone = document.getElementById('dropZone');
const selectBtn = document.getElementById('selectBtn');
const filesList = document.getElementById('filesList');
const filesContainer = document.getElementById('filesContainer');
const fileCount = document.getElementById('fileCount');
const clearFilesBtn = document.getElementById('clearFilesBtn');
const convertBtn = document.getElementById('convertBtn');

const stepSelect = document.getElementById('step-select');
const stepConverting = document.getElementById('step-converting');
const stepComplete = document.getElementById('step-complete');

const progressFill = document.getElementById('progressFill');
const progressText = document.getElementById('progressText');
const currentFileName = document.getElementById('currentFileName');
const statusText = document.getElementById('statusText');
const filesLog = document.getElementById('filesLog');

const successCount = document.getElementById('successCount');
const failCount = document.getElementById('failCount');
const downloadBtn = document.getElementById('downloadBtn');
const startOverBtn = document.getElementById('startOverBtn');
const failedFilesContainer = document.getElementById('failedFilesContainer');
const failedFilesList = document.getElementById('failedFilesList');

const errorPopup = document.getElementById('errorPopup');
const errorMessage = document.getElementById('errorMessage');

// Drag and Drop
dropZone.addEventListener('dragover', (e) => {
  e.preventDefault();
  dropZone.classList.add('drag-over');
});

dropZone.addEventListener('dragleave', () => {
  dropZone.classList.remove('drag-over');
});

dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  dropZone.classList.remove('drag-over');

  const files = Array.from(e.dataTransfer.files);
  const heicFiles = files.filter(f => 
    f.name.toLowerCase().endsWith('.heic') || 
    f.name.toLowerCase().endsWith('.heif')
  );

  if (heicFiles.length > 0) {
    heicFiles.forEach(f => {
      if (!selectedFiles.find(sf => sf.path === f.path)) {
        selectedFiles.push({ name: f.name, path: f.path });
      }
    });
    updateFilesList();
  } else {
    showError('Lütfen sadece HEIC/HEIF dosyaları seçin');
  }
});

// Select Button
selectBtn.addEventListener('click', async () => {
  const files = await window.electronAPI.selectFiles();
  
  files.forEach(filePath => {
    const name = filePath.split(/[\\/]/).pop();
    if (!selectedFiles.find(f => f.path === filePath)) {
      selectedFiles.push({ name, path: filePath });
    }
  });

  updateFilesList();
});

// Update Files List UI
function updateFilesList() {
  if (selectedFiles.length === 0) {
    filesList.classList.add('hidden');
    return;
  }

  filesList.classList.remove('hidden');
  fileCount.textContent = selectedFiles.length;

  filesContainer.innerHTML = '';
  selectedFiles.forEach((file, index) => {
    const div = document.createElement('div');
    div.className = 'file-item';
    div.innerHTML = `
      <span class="file-item-name">${file.name}</span>
      <button class="file-item-remove" onclick="removeFile(${index})">Kaldır</button>
    `;
    filesContainer.appendChild(div);
  });
}

// Remove File
function removeFile(index) {
  selectedFiles.splice(index, 1);
  updateFilesList();
}

// Clear Files
clearFilesBtn.addEventListener('click', () => {
  selectedFiles = [];
  updateFilesList();
});

// Convert Button
convertBtn.addEventListener('click', async () => {
  if (selectedFiles.length === 0) {
    showError('Lütfen en az bir dosya seçin');
    return;
  }

  // Hide select step, show converting step
  stepSelect.classList.add('hidden');
  stepConverting.classList.remove('hidden');
  stepComplete.classList.add('hidden');

  // Clear logs
  filesLog.innerHTML = '';

  // Get file paths
  const filePaths = selectedFiles.map(f => f.path);

  try {
    // Start conversion
    const results = await window.electronAPI.convertFiles(filePaths);
    
    conversionResults = results;
    tempDir = results.outputDir;

    // Show completion step
    showCompletionStep(results);

  } catch (error) {
    showError(`Dönüştürme hatası: ${error.message}`);
    stepSelect.classList.remove('hidden');
    stepConverting.classList.add('hidden');
  }
});

// Listen to conversion progress
window.electronAPI.onConversionProgress((data) => {
  const percentage = (data.current / data.total) * 100;
  progressFill.style.width = percentage + '%';
  progressText.textContent = `${data.current}/${data.total}`;
  currentFileName.textContent = data.fileName;
  statusText.textContent = data.status;
});

// Listen to file conversion status
window.electronAPI.onFileConverted((data) => {
  const logItem = document.createElement('div');
  logItem.className = `log-item ${data.status}`;

  if (data.status === 'success') {
    logItem.innerHTML = `✓ ${data.fileName}`;
  } else {
    logItem.innerHTML = `✗ ${data.fileName} - ${data.error}`;
  }

  filesLog.appendChild(logItem);
  filesLog.scrollTop = filesLog.scrollHeight;
});

// Listen to conversion complete
window.electronAPI.onConversionComplete((data) => {
  conversionResults = data;
  showCompletionStep(data);
});

// Listen to conversion error
window.electronAPI.onConversionError((data) => {
  showError(`Hata: ${data.message}`);
});

// Show Completion Step
function showCompletionStep(results) {
  stepConverting.classList.add('hidden');
  stepComplete.classList.remove('hidden');

  successCount.textContent = results.successful;
  failCount.textContent = results.failed;

  // Show failed files if any
  if (results.failed > 0 && conversionResults && conversionResults.failed) {
    failedFilesContainer.classList.remove('hidden');
    failedFilesList.innerHTML = '';

    conversionResults.failed.forEach(failedFile => {
      const div = document.createElement('div');
      div.className = 'failed-item';
      div.innerHTML = `
        <div class="failed-item-name">${failedFile.fileName}</div>
        <div class="failed-item-error">${failedFile.error}</div>
      `;
      failedFilesList.appendChild(div);
    });
  } else {
    failedFilesContainer.classList.add('hidden');
  }

  // Enable/disable download button
  if (results.successful > 0 && results.zipPath) {
    downloadBtn.disabled = false;
  } else {
    downloadBtn.disabled = true;
  }
}

// Download ZIP
downloadBtn.addEventListener('click', async () => {
  if (!conversionResults || !conversionResults.zipPath) {
    showError('ZIP dosyası bulunamadı');
    return;
  }

  try {
    downloadBtn.disabled = true;
    downloadBtn.textContent = '📥 İndirilyor...';

    const savedPath = await window.electronAPI.saveFile(conversionResults.zipPath);

    if (savedPath) {
      // Success - cleanup temp files
      await cleanupTempFiles();
      downloadBtn.textContent = '✓ İndirildi!';
      
      setTimeout(() => {
        startOver();
      }, 2000);
    } else {
      downloadBtn.disabled = false;
      downloadBtn.textContent = '📥 ZIP İndir';
    }
  } catch (error) {
    showError(`İndirme hatası: ${error.message}`);
    downloadBtn.disabled = false;
    downloadBtn.textContent = '📥 ZIP İndir';
  }
});

// Start Over
startOverBtn.addEventListener('click', () => {
  startOver();
});

function startOver() {
  selectedFiles = [];
  conversionResults = null;
  tempDir = null;

  updateFilesList();
  stepSelect.classList.remove('hidden');
  stepConverting.classList.add('hidden');
  stepComplete.classList.add('hidden');

  downloadBtn.disabled = false;
  downloadBtn.textContent = '📥 ZIP İndir';
}

// Cleanup Temp Files
async function cleanupTempFiles() {
  if (tempDir) {
    try {
      await window.electronAPI.cleanup(tempDir);
    } catch (error) {
      console.error('Cleanup error:', error);
    }
  }
}

// Show Error
function showError(message) {
  errorMessage.textContent = message;
  errorPopup.classList.remove('hidden');
}

// Close Error
function closeError() {
  errorPopup.classList.add('hidden');
}

// Close error on outside click
errorPopup.addEventListener('click', (e) => {
  if (e.target === errorPopup) {
    closeError();
  }
});

// Cleanup on window close
window.addEventListener('beforeunload', async () => {
  await cleanupTempFiles();
});
