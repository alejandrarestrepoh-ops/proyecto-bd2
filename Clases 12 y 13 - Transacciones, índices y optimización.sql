USE inventario_db;

-- =====================================================================
-- PARTE 1: CLASE 12 - TRANSACCIONES Y MANEJO DE ERRORES
-- =====================================================================

-- 1. Crear la tabla de log de errores para el proyecto
DROP TABLE IF EXISTS log_errores;
CREATE TABLE log_errores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    procedimiento VARCHAR(60) NOT NULL,
    codigo INT,
    estado_sql CHAR(5),
    mensaje VARCHAR(255),
    usuario VARCHAR(100) NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- 2. Procedimiento Transaccional: Registrar Venta Segura
-- Agrupa la creación de factura, detalle y descuento de stock con manejo de errores
DROP PROCEDURE IF EXISTS sp_registrar_venta_tx;
DELIMITER $$
CREATE PROCEDURE sp_registrar_venta_tx(
    IN p_id_cliente INT, 
    IN p_id_producto INT, 
    IN p_cantidad INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_stock INT DEFAULT NULL;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_codigo INT;
    DECLARE v_estado CHAR(5);
    DECLARE v_texto VARCHAR(255);
    DECLARE v_numero VARCHAR(20);

    -- Manejador de errores: si algo falla, deshace todo y registra el error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_codigo = MYSQL_ERRNO,
            v_estado = RETURNED_SQLSTATE,
            v_texto = MESSAGE_TEXT;
        ROLLBACK;
        INSERT INTO log_errores (procedimiento, codigo, estado_sql, mensaje, usuario)
        VALUES ('sp_registrar_venta_tx', v_codigo, v_estado, v_texto, USER());
        SET p_mensaje = CONCAT('Error en venta: ', v_texto);
    END;

    -- Iniciar transacción
    START TRANSACTION;

    -- Bloqueo de la fila del producto (SELECT FOR UPDATE) para evitar concurrencia
    SELECT stock, precio_venta INTO v_stock, v_precio 
    FROM productos WHERE id_producto = p_id_producto FOR UPDATE;

    -- Validaciones con SIGNAL
    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no existe';
    ELSEIF p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor a cero';
    ELSEIF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;

    -- Operaciones
    SET v_numero = CONCAT('TX-', LPAD((SELECT IFNULL(MAX(id_factura),0)+1 FROM facturas), 3, '0'));
    
    INSERT INTO facturas (numero_factura, id_cliente, subtotal, iva, total) 
    VALUES (v_numero, p_id_cliente, (v_precio * p_cantidad), (v_precio * p_cantidad * 0.19), (v_precio * p_cantidad * 1.19));
    
    INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio_unitario, subtotal)
    VALUES (LAST_INSERT_ID(), p_id_producto, p_cantidad, v_precio, (v_precio * p_cantidad));
    
    UPDATE productos SET stock = stock - p_cantidad WHERE id_producto = p_id_producto;

    -- Confirmar cambios
    COMMIT;
    SET p_mensaje = CONCAT('Venta exitosa. Factura: ', v_numero);
END$$
DELIMITER ;


-- =====================================================================
-- PARTE 2: CLASE 13 - OPTIMIZACIÓN E ÍNDICES
-- =====================================================================

-- 1. Generar volumen de datos (10,000 registros) en una tabla histórica
DROP TABLE IF EXISTS historico_ventas;
CREATE TABLE historico_ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    fecha DATETIME NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    estado VARCHAR(15) NOT NULL
) ENGINE = InnoDB;

-- Insertar 10,000 registros de prueba con la tabla virtual seq_1_to_10000
INSERT INTO historico_ventas (cliente_id, producto_id, fecha, total, estado)
SELECT 
    1 + (seq % 10), 
    1 + (seq % 10), 
    TIMESTAMP('2024-01-01') + INTERVAL FLOOR(seq / 10) DAY,
    10000 + (seq * 10),
    ELT(1 + seq % 3, 'PAGADA', 'PENDIENTE', 'ANULADA')
FROM seq_1_to_10000;

-- 2. CONSULTAS FRECUENTES (ANTES DE LOS ÍNDICES)
-- Consulta A: Buscar ventas de un cliente específico
EXPLAIN SELECT * FROM historico_ventas WHERE cliente_id = 5;
-- Consulta B: Buscar ventas en un rango de fechas
EXPLAIN SELECT * FROM historico_ventas WHERE fecha >= '2024-03-01' AND fecha < '2024-04-01';
-- Consulta C: Consulta que anula el índice (Usa una función en la columna)
EXPLAIN SELECT * FROM historico_ventas WHERE YEAR(fecha) = 2024;

-- 3. CREACIÓN DE ÍNDICES (OPTIMIZACIÓN)
CREATE INDEX idx_hist_cliente ON historico_ventas(cliente_id);
CREATE INDEX idx_hist_fecha ON historico_ventas(fecha);
-- Índice compuesto
CREATE INDEX idx_hist_cliente_fecha ON historico_ventas(cliente_id, fecha);

-- 4. CONSULTAS FRECUENTES (DESPUÉS DE LOS ÍNDICES)
-- Consulta A optimizada (usará el índice)
EXPLAIN SELECT * FROM historico_ventas WHERE cliente_id = 5;
-- Consulta B optimizada (usará el índice)
EXPLAIN SELECT * FROM historico_ventas WHERE fecha >= '2024-03-01' AND fecha < '2024-04-01';

-- 5. REESCRITURA DE CONSULTA QUE ANULABA EL ÍNDICE
-- ❌ Mal: WHERE YEAR(fecha) = 2024 (obliga a recorrer todo)
-- ✅ Bien: Usar rango de fechas
EXPLAIN SELECT * FROM historico_ventas WHERE fecha >= '2024-01-01' AND fecha < '2025-01-01';

-- 6. Ver los índices creados
SHOW INDEX FROM historico_ventas;