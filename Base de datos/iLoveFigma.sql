



CREATE TABLE usuarios (
    id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    correo TEXT UNIQUE NOT NULL,
    id_institucional TEXT UNIQUE NOT NULL,
    contraseña TEXT NOT NULL,
    rol TEXT CHECK (rol IN ('administrador', 'empleado', 'profesor')) NOT NULL,
    estado TEXT DEFAULT 'activo',
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE productos (
    id_producto INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL UNIQUE,
    categoria TEXT NOT NULL,
    marca TEXT,
    unidad_medida TEXT,
    stock_actual INTEGER NOT NULL DEFAULT 0,
    stock_minimo INTEGER DEFAULT 0,
    estado TEXT DEFAULT 'disponible'
);


CREATE TABLE entradas (
    id_entrada INTEGER PRIMARY KEY AUTOINCREMENT,
    id_producto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_usuario INTEGER NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

CREATE TABLE salidas (
    id_salida INTEGER PRIMARY KEY AUTOINCREMENT,
    id_producto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_usuario INTEGER NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);


CREATE TABLE historial (
    id_historial INTEGER PRIMARY KEY AUTOINCREMENT,
    id_usuario INTEGER,
    accion TEXT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    detalles TEXT,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- CREACIÓN DE TRIGGERS

-- Trigger para incrementar stock 
CREATE TRIGGER trg_incrementar_stock
AFTER INSERT ON entradas
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock_actual = stock_actual + NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END;

-- Trigger para decrementar stock 
CREATE TRIGGER trg_decrementar_stock
AFTER INSERT ON salidas
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock_actual = stock_actual - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END;

-- Trigger para evitar salidas si no hay suficiente stock
CREATE TRIGGER trg_validar_stock
BEFORE INSERT ON salidas
FOR EACH ROW
BEGIN
    SELECT
        CASE
            WHEN (SELECT stock_actual FROM productos WHERE id_producto = NEW.id_producto) < NEW.cantidad
            THEN RAISE(ABORT, 'Stock insuficiente para esta salida.')
        END;
END;
