// inventario/main.js
// archivo: main.js
// Este archivo es el punto de entrada de la aplicación Electron. Aquí se configuran las ventanas y se manejan los eventos IPC.
// Se utiliza el módulo 'better-sqlite3' para interactuar con la base de datos SQLite.
// Se crean dos ventanas: una para la interfaz principal y otra para registrar salidas de productos. La ventana de salida se abre al hacer clic en un botón en la ventana principal.
// Se utilizan funciones asíncronas para manejar las operaciones de la base de datos y se exponen a través de IPC (Inter-Process Communication) para ser utilizadas en el renderer process.
// Se utiliza 'path' para resolver rutas de archivos y 'electron' para crear la aplicación y las ventanas.
// Se utiliza 'better-sqlite3' para interactuar con la base de datos SQLite. Se crean funciones para obtener productos y usuarios, y para registrar salidas de productos. Estas funciones se exponen a través de IPC para ser utilizadas en el renderer process.
const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');

function crearVentanaPrincipal() {
  const mainWindow = new BrowserWindow({
    width: 600,
    height: 400,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  mainWindow.loadFile('renderer/index.html');
}

function crearVentanaSalida() {
  const salidaWindow = new BrowserWindow({
    width: 500,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  salidaWindow.loadFile('renderer/salida.html');
}

app.whenReady().then(() => {
  crearVentanaPrincipal();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) crearVentanaPrincipal();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

// Solo este handler queda activo
ipcMain.handle('abrir-ventana-salida', () => {
  crearVentanaSalida();
});
