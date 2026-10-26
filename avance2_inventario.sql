USE inventario_db;

-- ============================================================
-- 1. FUNCIÓN: Calcular valor del inventario (R4)
-- ============================================================
DROP FUNCTION IF EXISTS fn_valor_inventario;
DELIMITER $$
CREATE FUNCTION fn_valor_inventario() 
RETURNS DECIMAL(15,2) READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(15,2);
    SELECT IFNULL(SUM(precio_venta * stock), 0) INTO v_total FROM productos;
    RETURN v_total;
END$$
DELIMITER ;

-- ============================================================
-- 2. PROCEDIMIENTO CON VALIDACIÓN SIGNAL (R3)
-- ============================================================
DROP PROCEDURE IF EXISTS sp_vender_producto_seguro;
DELIMITER $$
CREATE PROCEDURE sp_vender_producto_seguro(
    IN p_id_producto INT, 
    IN p_cantidad INT, 
    OUT p_total DECIMAL(12,2)
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_precio DECIMAL(10,2);
    
    SELECT stock, precio_venta INTO v_stock, v_precio 
    FROM productos WHERE id_producto = p_id_producto;
    
    -- Validación con SIGNAL
    IF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Stock insuficiente para realizar la venta';
    END IF;
    
    -- Si pasa la validación, calculamos y actualizamos
    SET p_total = v_precio * p_cantidad;
    UPDATE productos SET stock = stock - p_cantidad WHERE id_producto = p_id_producto;
END$$
DELIMITER ;

-- ============================================================
-- 3. TRIGGER DE AUDITORÍA CON USER() Y CURRENT_USER() (R5)
-- ============================================================

CREATE TABLE IF NOT EXISTS auditoria_precios_v2 (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    usuario_sesion VARCHAR(100),
    usuario_privilegios VARCHAR(100),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_auditar_precio_v2;
DELIMITER $$
CREATE TRIGGER trg_auditar_precio_v2
BEFORE UPDATE ON productos FOR EACH ROW
BEGIN
    IF NOT (NEW.precio_venta <=> OLD.precio_venta) THEN
        INSERT INTO auditoria_precios_v2 (id_producto, precio_anterior, precio_nuevo, usuario_sesion, usuario_privilegios)
        VALUES (OLD.id_producto, OLD.precio_venta, NEW.precio_venta, USER(), CURRENT_USER());
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- 4. SEGURIDAD: HASH, CIFRADO, ROLES Y USUARIOS (R7)
-- ============================================================
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS sal CHAR(16) NOT NULL DEFAULT 's41L4ur4Xy9Qw2Ab';
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS clave_hash CHAR(64) NULL;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS tarjeta_cifrada VARBINARY(64) NULL;

SET @llave_inv = 'Llave_Inventario_2026';
UPDATE clientes SET 
    clave_hash = SHA2(CONCAT(sal, 'Cliente2026*'), 256),
    tarjeta_cifrada = AES_ENCRYPT('4000123412341234', @llave_inv) 
WHERE id_cliente = 1;

-- Limpiar roles y usuarios anteriores para evitar errores
DROP ROLE IF EXISTS rol_consulta_inv;
DROP ROLE IF EXISTS rol_operativo_inv;
DROP ROLE IF EXISTS rol_admin_inv;
DROP USER IF EXISTS 'ana_inv'@'%';
DROP USER IF EXISTS 'carlos_inv'@'%';
DROP USER IF EXISTS 'maria_inv'@'%';

-- Crear los 3 roles
CREATE ROLE rol_consulta_inv;
CREATE ROLE rol_operativo_inv;
CREATE ROLE rol_admin_inv;

-- Otorgar privilegios a roles
GRANT SELECT ON inventario_db.vw_clientes_seguro TO rol_consulta_inv;
GRANT SELECT ON inventario_db.vw_facturas_detalle TO rol_consulta_inv;

GRANT rol_consulta_inv TO rol_operativo_inv;
GRANT EXECUTE ON PROCEDURE inventario_db.sp_vender_producto_seguro TO rol_operativo_inv;

GRANT SELECT, INSERT, UPDATE, DELETE ON inventario_db.* TO rol_admin_inv;

-- Crear los 3 usuarios
CREATE USER 'ana_inv'@'%' IDENTIFIED BY 'Ana2026*';
CREATE USER 'carlos_inv'@'%' IDENTIFIED BY 'Carlos2026*';
CREATE USER 'maria_inv'@'%' IDENTIFIED BY 'Maria2026*';

-- Asignar roles
GRANT rol_consulta_inv TO 'ana_inv'@'%';
GRANT rol_operativo_inv TO 'carlos_inv'@'%';
GRANT rol_admin_inv TO 'maria_inv'@'%';

-- Activar roles por defecto
SET DEFAULT ROLE rol_consulta_inv FOR 'ana_inv'@'%';
SET DEFAULT ROLE rol_operativo_inv FOR 'carlos_inv'@'%';
SET DEFAULT ROLE rol_admin_inv FOR 'maria_inv'@'%';

FLUSH PRIVILEGES;
