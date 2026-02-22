const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const fs = require('fs').promises;
const fsSync = require('fs');
const os = require('os');
const archiver = require('archiver');

let mainWindow;
const ffmpegPath = require('ffmpeg-static');

// Create main window
function createWindow() {
  mainWindow = new BrowserWindow({
    width: 900,
    height: 700,
    minWidth: 600,
    minHeight: 500,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      enableRemoteModule: false,
      nodeIntegration: false,
      sandbox: true
    },
    icon: path.join(__dirname, 'src', 'icon.png')
  });

  mainWindow.loadFile(path.join(__dirname, 'src', 'index.html'));
  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  // Dev tools - remove in production
  // mainWindow.webContents.openDevTools();
}

app.on('ready', () => {
  createWindow();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});

// IPC Handler - Select files
ipcMain.handle('select-files', async () => {
  const { canceled, filePaths } = await dialog.showOpenDialog(mainWindow, {
    properties: ['openFile', 'multiSelections'],
    filters: [
      { name: 'HEIC Images', extensions: ['heic', 'heif'] },
      { name: 'All Files', extensions: ['*'] }
    ]
  });

  if (canceled) {
    return [];
  }

  return filePaths.filter(f => 
    f.toLowerCase().endsWith('.heic') || f.toLowerCase().endsWith('.heif')
  );
});

// Convert single HEIC file to JPEG
async function convertHeicToJpeg(inputPath, outputPath) {
  return new Promise((resolve, reject) => {
    const ffmpeg = spawn(ffmpegPath, [
      '-i', inputPath,
      '-q:v', '2',
      '-pix_fmt', 'yuvj444p',
      '-y', // Overwrite output
      outputPath
    ], {
      stdio: ['ignore', 'pipe', 'pipe']
    });

    let errorOutput = '';

    ffmpeg.stderr.on('data', (data) => {
      errorOutput += data.toString();
    });

    ffmpeg.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`FFmpeg error (exit code ${code}): ${errorOutput}`));
      }
    });

    ffmpeg.on('error', (err) => {
      reject(err);
    });
  });
}

// IPC Handler - Convert files
ipcMain.handle('convert-files', async (event, filePaths) => {
  const results = {
    successful: [],
    failed: [],
    outputDir: null,
    zipPath: null
  };

  try {
    // Create temp directory for outputs
    const tempDir = path.join(os.tmpdir(), `pixelbatch-${Date.now()}`);
    await fs.mkdir(tempDir, { recursive: true });
    results.outputDir = tempDir;

    // Convert each file
    for (let i = 0; i < filePaths.length; i++) {
      const inputPath = filePaths[i];
      const fileName = path.basename(inputPath);
      const baseName = path.parse(fileName).name;
      const outputPath = path.join(tempDir, `${baseName}.jpg`);

      try {
        // Send progress update
        mainWindow.webContents.send('conversion-progress', {
          current: i + 1,
          total: filePaths.length,
          fileName: fileName,
          status: 'Converting...'
        });

        // Convert file
        await convertHeicToJpeg(inputPath, outputPath);

        results.successful.push({
          original: fileName,
          converted: `${baseName}.jpg`,
          path: outputPath
        });

        // Send success update
        mainWindow.webContents.send('file-converted', {
          fileName: fileName,
          status: 'success'
        });

      } catch (error) {
        results.failed.push({
          fileName: fileName,
          error: error.message
        });

        // Send error update
        mainWindow.webContents.send('file-converted', {
          fileName: fileName,
          status: 'failed',
          error: error.message
        });
      }
    }

    // Create ZIP if there are successful conversions
    if (results.successful.length > 0) {
      const zipPath = path.join(os.tmpdir(), `PixelBatch-${Date.now()}.zip`);
      
      await new Promise((resolve, reject) => {
        const output = fsSync.createWriteStream(zipPath);
        const archive = archiver('zip', { zlib: { level: 9 } });

        output.on('close', resolve);
        archive.on('error', reject);

        archive.pipe(output);

        // Add all converted files
        results.successful.forEach(file => {
          archive.file(file.path, { name: file.converted });
        });

        archive.finalize();
      });

      results.zipPath = zipPath;

      mainWindow.webContents.send('conversion-complete', {
        successful: results.successful.length,
        failed: results.failed.length,
        zipPath: zipPath
      });
    } else {
      mainWindow.webContents.send('conversion-complete', {
        successful: 0,
        failed: results.failed.length,
        zipPath: null
      });
    }

    return results;

  } catch (error) {
    mainWindow.webContents.send('conversion-error', {
      message: error.message
    });
    throw error;
  }
});

// IPC Handler - Save ZIP file
ipcMain.handle('save-file', async (event, sourcePath) => {
  const { canceled, filePath } = await dialog.showSaveDialog(mainWindow, {
    defaultPath: sourcePath,
    filters: [{ name: 'ZIP Archive', extensions: ['zip'] }]
  });

  if (canceled) {
    return null;
  }

  try {
    await fs.copyFile(sourcePath, filePath);
    return filePath;
  } catch (error) {
    throw new Error(`Failed to save file: ${error.message}`);
  }
});

// IPC Handler - Clean temp files
ipcMain.handle('cleanup', async (event, dirPath) => {
  try {
    if (dirPath && fsSync.existsSync(dirPath)) {
      const files = await fs.readdir(dirPath);
      for (const file of files) {
        await fs.unlink(path.join(dirPath, file));
      }
      await fs.rmdir(dirPath);
    }
  } catch (error) {
    console.error('Cleanup error:', error);
  }
});
