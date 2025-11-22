const { app, BrowserWindow } = require('electron');
const { setWindowCornerRadius, addVibrancyView } = require('electrolyx');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 360,
    height: 240,
    titleBarStyle: 'hiddenInset',
    transparent: true,
    backgroundColor: '#00000000',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  });

  mainWindow.loadFile('index.html');

  mainWindow.once('ready-to-show', () => {
    mainWindow.show();

    // Set rounded corners
    setWindowCornerRadius(mainWindow, 16);

    // Add vibrancy background
    addVibrancyView(mainWindow, {
      x: 0,
      y: 0,
      width: 600,
      height: 400,
      material: 'hudWindow',
      blendingMode: 'behindWindow',
      cornerRadius: 16,
      autoresizingMask: {
        width: true,
        height: true
      }
    });
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
