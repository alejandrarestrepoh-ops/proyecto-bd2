-- ============================================================
-- ACTIVIDAD CLASE 8 - FUNCIONES Y USUARIOS
-- Proyecto: Sistema de Inventario y Facturación
-- Bases de Datos II - Alejandra Restrepo
-- ============================================================

USE inventario_db;

-- Activar parámetro para crear funciones
SET GLOBAL log_bin_trust_function_creators = 1;

-- ============================================================
-- EJERCICIO 1: fn_calcular_descuento
-- ============================================================
DROP FUNCTION IF EXISTS fn_calcular_descuento;

DELIMITER $$
CREATE FUNCTION fn_calcular_descuento(
    p_precio DECIMAL(10,2),
    p_porcentaje DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_descuento DECIMAL(10,2);
    DECLARE v_precio_final DECIMAL(10,2);
    SET v_descuento = p_precio * (p_porcentaje / 100);
    SET v_precio_final = p_precio - v_descuento;
    RETURN v_precio_final;
END$$
DELIMITER ;

-- Pruebas:
-- SELECT fn_calcular_descuento(100000, 10);   -- 90000
-- SELECT fn_calcular_descuento(50000, 25);    -- 37500


-- ============================================================
-- EJERCICIO 2: fn_clasificar_edad
-- ============================================================
DROP FUNCTION IF EXISTS fn_clasificar_edad;

DELIMITER $$
CREATE FUNCTION fn_clasificar_edad(p_edad INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE v_clasificacion VARCHAR(20);
    IF p_edad < 12 THEN
        SET v_clasificacion = 'Niño';
    ELSEIF p_edad >= 12 AND p_edad <= 17 THEN
        SET v_clasificacion = 'Adolescente';
    ELSEIF p_edad >= 18 AND p_edad <= 59 THEN
        SET v_clasificacion = 'Adulto';
    ELSE
        SET v_clasificacion = 'Adulto mayor';
    END IF;
    RETURN v_clasificacion;
END$$
DELIMITER ;

-- Pruebas:
-- SELECT fn_clasificar_edad(8);    -- Niño
-- SELECT fn_clasificar_edad(15);   -- Adolescente
-- SELECT fn_clasificar_edad(30);   -- Adulto
-- SELECT fn_clasificar_edad(65);   -- Adulto mayor


-- ============================================================
-- EJERCICIO 3: fn_valor_inventario (aplicada al proyecto)
-- ============================================================
DROP FUNCTION IF EXISTS fn_valor_inventario;

DELIMITER $$
CREATE FUNCTION fn_valor_inventario()
RETURNS DECIMAL(15,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(15,2);
    SELECT IFNULL(SUM(precio_venta * stock), 0)
    INTO v_total
    FROM productos;
    RETURN v_total;
END$$
DELIMITER ;

-- Prueba:
-- SELECT fn_valor_inventario();


-- ============================================================
-- EJERCICIO 4: GESTIÓN DE USUARIOS
-- ============================================================

-- Crear usuarios
CREATE USER 'admin_inventario'@'%' IDENTIFIED BY 'Admin123*';
CREATE USER 'consulta_inventario'@'%' IDENTIFIED BY 'Consulta123*';
CREATE USER 'app_inventario'@'%' IDENTIFIED BY 'App123*';

SELECT user, host FROM mysql.user WHERE user LIKE '%inventario%';

-- Otorgar privilegios
GRANT ALL PRIVILEGES ON inventario_db.* TO 'admin_inventario'@'%' WITH GRANT OPTION;
GRANT SELECT ON inventario_db.* TO 'consulta_inventario'@'%';
GRANT SELECT, INSERT, UPDATE, EXECUTE ON inventario_db.* TO 'app_inventario'@'%';

FLUSH PRIVILEGES;

-- Verificar privilegios
SHOW GRANTS FOR 'admin_inventario'@'%';
SHOW GRANTS FOR 'consulta_inventario'@'%';
SHOW GRANTS FOR 'app_inventario'@'%';

-- Privilegio EXECUTE sobre función específica
GRANT EXECUTE ON FUNCTION inventario_db.fn_valor_inventario TO 'app_inventario'@'%';
FLUSH PRIVILEGES;


-- ============================================================
-- EJERCICIO 5: REVOCACIÓN Y ELIMINACIÓN
-- ============================================================

-- Revocar UPDATE al usuario app_inventario
REVOKE UPDATE ON inventario_db.* FROM 'app_inventario'@'%';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'app_inventario'@'%';

-- Eliminar el usuario consulta_inventario
DROP USER 'consulta_inventario'@'%';
FLUSH PRIVILEGES;
SELECT user, host FROM mysql.user WHERE user LIKE '%inventario%';

-- ============================================================
-- PRUEBAS DE CONEXIÓN (comentadas)
-- ============================================================
-- admin_inventario    → Admin123*      → todos los privilegios
-- consulta_inventario → Consulta123*   → ELIMINADO
-- app_inventario      → App123*        → SELECT, INSERT, EXECUTE

-- ============================================================
-- FIN DEL ARCHIVO
-- ============================================================
