// archivo: db/conexion.js
const Database = require('better-sqlite3');
const db = new Database('inventario.db');

module.exports = {
  obtenerProductos() {
    const stmt = db.prepare("SELECT id_producto, nombre FROM productos WHERE estado = 'disponible'");
    return stmt.all();
  },

  obtenerUsuarios() {
    const stmt = db.prepare("SELECT id_usuario, nombre FROM usuarios WHERE estado = 'activo'");
    return stmt.all();
  },

  registrarSalida({ id_producto, cantidad, id_usuario, observaciones }) {
    const producto = db.prepare("SELECT stock_actual FROM productos WHERE id_producto = ?").get(id_producto);
    if (!producto) return { mensaje: 'Producto no encontrado' };
    if (producto.stock_actual < cantidad) return { mensaje: 'Stock insuficiente' };

    const insert = db.prepare(`
      INSERT INTO salidas (id_producto, cantidad, id_usuario, observaciones)
      VALUES (?, ?, ?, ?)
    `);
    insert.run(id_producto, cantidad, id_usuario, observaciones);

    const update = db.prepare("UPDATE productos SET stock_actual = stock_actual - ? WHERE id_producto = ?");
    update.run(cantidad, id_producto);

    return { mensaje: 'Salida registrada correctamente' };
  }
};
