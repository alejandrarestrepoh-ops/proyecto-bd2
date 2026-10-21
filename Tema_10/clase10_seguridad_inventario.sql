-- ============================================================
-- CLASE 10: SEGURIDAD EN MARIADB
-- Autor: Alejandra Restrepo
-- ============================================================

-- ============================================================
-- PARTE 1: ACTIVIDAD GUIADA (bbdd_db)
-- ============================================================
USE bbdd_db;

-- Limpieza previa por si acaso
DROP TABLE IF EXISTS auditoria_clientes;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS clientes;
DROP VIEW IF EXISTS vw_clientes_publico;
DROP VIEW IF EXISTS vw_productos_inventario;
DROP VIEW IF EXISTS vw_ventas_detalle;
DROP PROCEDURE IF EXISTS sp_registrar_venta;
DROP TRIGGER IF EXISTS trg_auditar_clientes_update;
DROP FUNCTION IF EXISTS fn_validar_login;
DROP FUNCTION IF EXISTS fn_enmascarar;

-- 3.1 Preparación de tablas
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    documento VARCHAR(15) NOT NULL UNIQUE,
    nombre VARCHAR(60) NOT NULL,
    email VARCHAR(80) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    sal CHAR(16) NOT NULL,
    clave_hash CHAR(64) NOT NULL,
    tarjeta_cifrada VARBINARY(64) NULL
) ENGINE = InnoDB;

CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    registrado_por VARCHAR(100) NOT NULL,
    CONSTRAINT fk_ventas_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    CONSTRAINT fk_ventas_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
) ENGINE = InnoDB;

CREATE TABLE auditoria_clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    campo VARCHAR(30) NOT NULL,
    valor_anterior VARCHAR(100),
    valor_nuevo VARCHAR(100),
    usuario_sesion VARCHAR(100) NOT NULL,
    usuario_privilegios VARCHAR(100) NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- 3.2 y 3.3 Cifrado y Hash
SET @llave = 'Cl4ve_Secreta_Clase1@';
INSERT INTO clientes (documento, nombre, email, telefono, sal, clave_hash, tarjeta_cifrada) VALUES 
('1112000001', 'Laura Gómez', 'laura@correo.com', '3104567890', 's41L4ur4Xy9Qw2Ab', SHA2(CONCAT('s41L4ur4Xy9Qw2Ab', 'Laura2026*'), 256), AES_ENCRYPT('4000123412341234', @llave)), 
('1112000002', 'Andrés Restrepo', 'andres@correo.com', '3157894561', 'Pm8zt1k4vB7Ng0R', SHA2(CONCAT('Pm8zt1kC4vB7Ng0R', 'Andres#2026'), 256), AES_ENCRYPT('4000567856785678', @llave)), 
('1112000003', 'Sofía Marín', 'sofia@correo.com', '3201237894', 'Hd3Lr6Ye9Ui20p5W', SHA2(CONCAT('Hd3Lr6Ye9Ui20p5W', 'Sofia#2026'), 256), AES_ENCRYPT('4000901290129012', @llave));

-- 3.4 Funciones
DELIMITER $$
CREATE FUNCTION fn_validar_login(p_documento VARCHAR(15), p_clave VARCHAR(50)) 
RETURNS TINYINT READS SQL DATA
BEGIN
    DECLARE v_valido TINYINT DEFAULT 0;
    SELECT COUNT(*) INTO v_valido FROM clientes WHERE documento = p_documento AND clave_hash = SHA2(CONCAT(sal, p_clave), 256);
    RETURN v_valido;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION fn_enmascarar(p_texto VARCHAR(100), p_visibles INT) 
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
    RETURN CONCAT(REPEAT('*', GREATEST(CHAR_LENGTH(p_texto) - p_visibles, 0)), RIGHT(p_texto, p_visibles));
END$$
DELIMITER ;

-- 3.5 Vistas seguras
CREATE OR REPLACE SQL SECURITY DEFINER VIEW vw_clientes_publico AS 
SELECT id, nombre, fn_enmascarar(documento, 4) AS documento, fn_enmascarar(telefono, 4) AS telefono, CONCAT(LEFT(email, 2), '***', SUBSTRING(email, LOCATE('@', email))) AS email FROM clientes;

CREATE OR REPLACE SQL SECURITY DEFINER VIEW vw_productos_inventario AS 
SELECT id, nombre, precio, fn_precio_con_iva(precio) AS precio_con_iva, stock, fn_clasificar_stock(stock) AS estado_stock FROM productos;

CREATE OR REPLACE SQL SECURITY DEFINER VIEW vw_ventas_detalle AS 
SELECT v.id, v.fecha, c.nombre AS cliente, p.nombre AS producto, v.cantidad, v.total, v.registrado_por FROM ventas v INNER JOIN clientes c ON c.id = v.cliente_id INNER JOIN productos p ON p.id = v.producto_id;

-- 3.6 Procedimiento DEFINER
DELIMITER $$
CREATE PROCEDURE sp_registrar_venta(IN p_cliente_id INT, IN p_producto_id INT, IN p_cantidad INT) 
SQL SECURITY DEFINER MODIFIES SQL DATA
BEGIN
    DECLARE v_stock INT DEFAULT NULL;
    DECLARE v_precio DECIMAL(10,2);
    SELECT stock, precio INTO v_stock, v_precio FROM productos WHERE id = p_producto_id;
    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no existe';
    ELSEIF p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor a cero';
    ELSEIF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;
    INSERT INTO ventas (cliente_id, producto_id, cantidad, total, registrado_por) VALUES (p_cliente_id, p_producto_id, p_cantidad, fn_precio_con_iva(v_precio) * p_cantidad, USER());
    UPDATE productos SET stock = stock - p_cantidad WHERE id = p_producto_id;
    SELECT 'Venta registrada' AS mensaje, LAST_INSERT_ID() AS id_venta, USER() AS usuario_sesion, CURRENT_USER() AS usuario_privilegios;
END$$
DELIMITER ;

-- 3.7 Trigger Auditoría
DELIMITER $$
CREATE TRIGGER trg_auditar_clientes_update 
AFTER UPDATE ON clientes FOR EACH ROW
BEGIN
    IF NOT (OLD.email <=> NEW.email) THEN
        INSERT INTO auditoria_clientes (cliente_id, campo, valor_anterior, valor_nuevo, usuario_sesion, usuario_privilegios) VALUES (NEW.id, 'email', OLD.email, NEW.email, USER(), CURRENT_USER());
    END IF;
    IF NOT (OLD.telefono <=> NEW.telefono) THEN
        INSERT INTO auditoria_clientes (cliente_id, campo, valor_anterior, valor_nuevo, usuario_sesion, usuario_privilegios) VALUES (NEW.id, 'telefono', OLD.telefono, NEW.telefono, USER(), CURRENT_USER());
    END IF;
END$$
DELIMITER ;

-- 3.8 Políticas Contraseñas
INSTALL SONAME 'simple_password_check';

-- 3.9 Roles y Usuarios (Limpieza previa para evitar errores)
DROP ROLE IF EXISTS rol_consulta;
DROP ROLE IF EXISTS rol_vendedor;
DROP ROLE IF EXISTS rol_admin_tienda;
DROP USER IF EXISTS 'ana_consulta'@'%';
DROP USER IF EXISTS 'carlos_vendedor'@'%';
DROP USER IF EXISTS 'maria_admin'@'%';

CREATE ROLE rol_consulta;
CREATE ROLE rol_vendedor;
CREATE ROLE rol_admin_tienda;

GRANT SELECT ON bbdd_db.vw_clientes_publico TO rol_consulta;
GRANT SELECT ON bbdd_db.vw_productos_inventario TO rol_consulta;
GRANT SELECT ON bbdd_db.vw_ventas_detalle TO rol_consulta;

GRANT rol_consulta TO rol_vendedor;
GRANT EXECUTE ON PROCEDURE bbdd_db.sp_registrar_venta TO rol_vendedor;
GRANT EXECUTE ON FUNCTION bbdd_db.fn_validar_login TO rol_vendedor;

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, SHOW VIEW ON bbdd_db.* TO rol_admin_tienda;

CREATE USER 'ana_consulta'@'%' IDENTIFIED BY 'Consulta#2026' PASSWORD EXPIRE INTERVAL 90 DAY;
CREATE USER 'carlos_vendedor'@'%' IDENTIFIED BY 'Vendedor#2026' WITH MAX_USER_CONNECTIONS 2 MAX_QUERIES_PER_HOUR 500;
CREATE USER 'maria_admin'@'%' IDENTIFIED BY 'AdminTienda#2026';

GRANT rol_consulta TO 'ana_consulta'@'%';
GRANT rol_vendedor TO 'carlos_vendedor'@'%';
GRANT rol_admin_tienda TO 'maria_admin'@'%';

SET DEFAULT ROLE rol_consulta FOR 'ana_consulta'@'%';
SET DEFAULT ROLE rol_vendedor FOR 'carlos_vendedor'@'%';
SET DEFAULT ROLE rol_admin_tienda FOR 'maria_admin'@'%';
FLUSH PRIVILEGES;

-- ============================================================
-- PARTE 4: ACTIVIDAD INDEPENDIENTE (inventario_db)
-- ============================================================
USE inventario_db;

-- Modificar tabla clientes para hash/cifrado
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS sal CHAR(16) NOT NULL DEFAULT 's41L4ur4Xy9Qw2Ab';
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS clave_hash CHAR(64) NULL;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS tarjeta_cifrada VARBINARY(64) NULL;

SET @llave_inv = 'Llave_Inventario_2026';
UPDATE clientes SET 
    clave_hash = SHA2(CONCAT(sal, 'Cliente2026*'), 256),
    tarjeta_cifrada = AES_ENCRYPT('4000123412341234', @llave_inv) 
WHERE id_cliente = 1;

-- Vistas Seguras
CREATE OR REPLACE SQL SECURITY DEFINER VIEW vw_clientes_seguro AS 
SELECT id_cliente, nombre, CONCAT(LEFT(cedula, 2), '***') AS cedula_segura, CONCAT(LEFT(correo, 2), '***@***') AS correo_seguro FROM clientes;

CREATE OR REPLACE SQL SECURITY DEFINER VIEW vw_facturas_detalle AS 
SELECT f.numero_factura, c.nombre AS cliente, f.total, f.fecha FROM facturas f INNER JOIN clientes c ON f.id_cliente = c.id_cliente;

-- Procedimiento DEFINER
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_registrar_venta_inv$$
CREATE PROCEDURE sp_registrar_venta_inv(IN p_id_cliente INT, IN p_id_producto INT, IN p_cantidad INT) 
SQL SECURITY DEFINER MODIFIES SQL DATA
BEGIN
    DECLARE v_stock INT;
    DECLARE v_precio DECIMAL(10,2);
    SELECT stock, precio_venta INTO v_stock, v_precio FROM productos WHERE id_producto = p_id_producto;
    IF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente en inventario_db';
    END IF;
    UPDATE productos SET stock = stock - p_cantidad WHERE id_producto = p_id_producto;
    SELECT 'Venta en proyecto OK' AS mensaje;
END$$
DELIMITER ;

-- Trigger Auditoría
CREATE TABLE IF NOT EXISTS auditoria_clientes_inv (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    campo VARCHAR(30),
    valor_anterior VARCHAR(100),
    valor_nuevo VARCHAR(100),
    usuario VARCHAR(100),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$
DROP TRIGGER IF EXISTS trg_auditar_clientes_inv$$
CREATE TRIGGER trg_auditar_clientes_inv 
AFTER UPDATE ON clientes FOR EACH ROW
BEGIN
    IF NOT (OLD.correo <=> NEW.correo) THEN
        INSERT INTO auditoria_clientes_inv (cliente_id, campo, valor_anterior, valor_nuevo, usuario) VALUES (NEW.id_cliente, 'correo', OLD.correo, NEW.correo, USER());
    END IF;
END$$
DELIMITER ;

-- Roles y usuarios del proyecto
DROP ROLE IF EXISTS rol_consulta_inv;
DROP ROLE IF EXISTS rol_admin_inv;
DROP USER IF EXISTS 'ana_inv'@'%';
DROP USER IF EXISTS 'admin_inv'@'%';

CREATE ROLE rol_consulta_inv;
CREATE ROLE rol_admin_inv;

GRANT SELECT ON inventario_db.vw_clientes_seguro TO rol_consulta_inv;
GRANT ALL PRIVILEGES ON inventario_db.* TO rol_admin_inv;

CREATE USER 'ana_inv'@'%' IDENTIFIED BY 'Ana#Inventario2026';
CREATE USER 'admin_inv'@'%' IDENTIFIED BY 'Admin#Inventario2026';

GRANT rol_consulta_inv TO 'ana_inv'@'%';
GRANT rol_admin_inv TO 'admin_inv'@'%';

SET DEFAULT ROLE rol_consulta_inv FOR 'ana_inv'@'%';
SET DEFAULT ROLE rol_admin_inv FOR 'admin_inv'@'%';
FLUSH PRIVILEGES;
