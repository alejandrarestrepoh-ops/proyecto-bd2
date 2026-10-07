-- ============================================================
-- ACTIVIDAD CLASE 7 - PROCEDIMIENTOS ALMACENADOS
-- Bases de Datos II - Jhon James Cano Sánchez
-- Autor: Alejandra Restrepo
-- Fecha: 6 de octubre de 2026
-- ============================================================

-- ============================================================
-- PARTE 1: Base de datos bbd_db (Ejercicios 1-4)
-- ============================================================

USE bbdd_db;

-- ------------------------------------------------------------
-- EJERCICIO 1: sp_hola_mundo
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_hola_mundo;

DELIMITER $$
CREATE PROCEDURE sp_hola_mundo()
BEGIN
    SELECT '¡Hola mundo!' AS mensaje;
END$$
DELIMITER ;

-- Prueba: CALL sp_hola_mundo();


-- ------------------------------------------------------------
-- EJERCICIO 2: sp_clasificar_numero
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_clasificar_numero;

DELIMITER $$
CREATE PROCEDURE sp_clasificar_numero(IN p_numero DOUBLE)
BEGIN
    IF p_numero > 0 THEN
        SELECT 'El número es POSITIVO' AS clasificacion;
    ELSEIF p_numero < 0 THEN
        SELECT 'El número es NEGATIVO' AS clasificacion;
    ELSE
        SELECT 'El número es CERO' AS clasificacion;
    END IF;
END$$
DELIMITER ;

-- Pruebas:
-- CALL sp_clasificar_numero(10);
-- CALL sp_clasificar_numero(-5);
-- CALL sp_clasificar_numero(0);


-- ------------------------------------------------------------
-- EJERCICIO 3: sp_nota_alumno_if
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_nota_alumno_if;

DELIMITER $$
CREATE PROCEDURE sp_nota_alumno_if(IN p_nota DECIMAL(4,2))
BEGIN
    IF p_nota >= 0 AND p_nota < 5 THEN
        SELECT 'Insuficiente' AS clasificacion;
    ELSEIF p_nota >= 5 AND p_nota < 6 THEN
        SELECT 'Aprobado' AS clasificacion;
    ELSEIF p_nota >= 6 AND p_nota < 7 THEN
        SELECT 'Bien' AS clasificacion;
    ELSEIF p_nota >= 7 AND p_nota < 9 THEN
        SELECT 'Notable' AS clasificacion;
    ELSEIF p_nota >= 9 AND p_nota <= 10 THEN
        SELECT 'Sobresaliente' AS clasificacion;
    ELSE
        SELECT 'Nota no válida' AS clasificacion;
    END IF;
END$$
DELIMITER ;

-- Pruebas:
-- CALL sp_nota_alumno_if(4.5);
-- CALL sp_nota_alumno_if(6.5);
-- CALL sp_nota_alumno_if(9.8);
-- CALL sp_nota_alumno_if(11);


-- ------------------------------------------------------------
-- EJERCICIO 3: sp_nota_alumno_case
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_nota_alumno_case;

DELIMITER $$
CREATE PROCEDURE sp_nota_alumno_case(IN p_nota DECIMAL(4,2))
BEGIN
    CASE
        WHEN p_nota >= 0 AND p_nota < 5 THEN
            SELECT 'Insuficiente' AS clasificacion;
        WHEN p_nota >= 5 AND p_nota < 6 THEN
            SELECT 'Aprobado' AS clasificacion;
        WHEN p_nota >= 6 AND p_nota < 7 THEN
            SELECT 'Bien' AS clasificacion;
        WHEN p_nota >= 7 AND p_nota < 9 THEN
            SELECT 'Notable' AS clasificacion;
        WHEN p_nota >= 9 AND p_nota <= 10 THEN
            SELECT 'Sobresaliente' AS clasificacion;
        ELSE
            SELECT 'Nota no válida' AS clasificacion;
    END CASE;
END$$
DELIMITER ;

-- Pruebas:
-- CALL sp_nota_alumno_case(4.5);
-- CALL sp_nota_alumno_case(6.5);
-- CALL sp_nota_alumno_case(9.8);
-- CALL sp_nota_alumno_case(11);


-- ------------------------------------------------------------
-- EJERCICIO 4: sp_dia_semana
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_dia_semana;

DELIMITER $$
CREATE PROCEDURE sp_dia_semana(IN p_numero INT)
BEGIN
    CASE p_numero
        WHEN 1 THEN SELECT 'Lunes' AS dia;
        WHEN 2 THEN SELECT 'Martes' AS dia;
        WHEN 3 THEN SELECT 'Miércoles' AS dia;
        WHEN 4 THEN SELECT 'Jueves' AS dia;
        WHEN 5 THEN SELECT 'Viernes' AS dia;
        WHEN 6 THEN SELECT 'Sábado' AS dia;
        WHEN 7 THEN SELECT 'Domingo' AS dia;
        ELSE SELECT 'Número no válido (debe ser 1 al 7)' AS dia;
    END CASE;
END$$
DELIMITER ;

-- Pruebas:
-- CALL sp_dia_semana(1);
-- CALL sp_dia_semana(3);
-- CALL sp_dia_semana(7);
-- CALL sp_dia_semana(8);


-- ============================================================
-- PARTE 2: Base de datos inventario_db (Ejercicio 5)
-- ============================================================

USE inventario_db;

-- ------------------------------------------------------------
-- EJERCICIO 5: sp_valor_total_inventario
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_valor_total_inventario;

DELIMITER $$
CREATE PROCEDURE sp_valor_total_inventario(OUT p_total DECIMAL(15,2))
BEGIN
    DECLARE v_contador INT DEFAULT 1;
    DECLARE v_total_productos INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_subtotal DECIMAL(15,2);
    
    SET p_total = 0;
    
    SELECT COUNT(*) INTO v_total_productos FROM productos;
    
    WHILE v_contador <= v_total_productos DO
        SELECT precio_venta, stock 
        INTO v_precio, v_stock
        FROM productos
        WHERE id_producto = v_contador;
        
        SET v_subtotal = v_precio * v_stock;
        SET p_total = p_total + v_subtotal;
        SET v_contador = v_contador + 1;
    END WHILE;
END$$
DELIMITER ;

-- Prueba:
-- CALL sp_valor_total_inventario(@total);
-- SELECT @total AS valor_total_inventario;
