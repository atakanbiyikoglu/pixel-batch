const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  // Select files
  selectFiles: () => ipcRenderer.invoke('select-files'),

  // Convert files
  convertFiles: (filePaths) => ipcRenderer.invoke('convert-files', filePaths),

  // Save file
  saveFile: (sourcePath) => ipcRenderer.invoke('save-file', sourcePath),

  // Cleanup
  cleanup: (dirPath) => ipcRenderer.invoke('cleanup', dirPath),

  // Listen to conversion progress
  onConversionProgress: (callback) => {
    ipcRenderer.on('conversion-progress', (event, data) => callback(data));
  },

  // Listen to file conversion status
  onFileConverted: (callback) => {
    ipcRenderer.on('file-converted', (event, data) => callback(data));
  },

  // Listen to conversion complete
  onConversionComplete: (callback) => {
    ipcRenderer.on('conversion-complete', (event, data) => callback(data));
  },

  // Listen to conversion error
  onConversionError: (callback) => {
    ipcRenderer.on('conversion-error', (event, data) => callback(data));
  }
});
