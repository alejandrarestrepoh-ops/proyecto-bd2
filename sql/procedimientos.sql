USE inventario_db;

DELIMITER $$

CREATE PROCEDURE registrar_venta(
    IN p_id_cliente INT,
    IN p_id_producto INT,
    IN p_cantidad INT,
    OUT p_mensaje VARCHAR(200),
    OUT p_total DECIMAL(12,2)
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_subtotal DECIMAL(12,2);
    DECLARE v_iva DECIMAL(12,2);
    DECLARE v_numero VARCHAR(20);

    SELECT stock, precio_venta, nombre INTO v_stock, v_precio, v_nombre
    FROM productos WHERE id_producto = p_id_producto;

    IF v_stock < p_cantidad THEN
        SET p_mensaje = CONCAT('Stock insuficiente. Solo hay ', v_stock, ' unidades de ', v_nombre);
        SET p_total = 0;
    ELSE
        SET v_subtotal = v_precio * p_cantidad;
        SET v_iva = v_subtotal * 0.19;
        SET p_total = v_subtotal + v_iva;
        SET v_numero = CONCAT('FAC-', LPAD((SELECT IFNULL(MAX(id_factura),0)+1 FROM facturas), 3, '0'));

        INSERT INTO facturas (numero_factura, id_cliente, subtotal, iva, total)
        VALUES (v_numero, p_id_cliente, v_subtotal, v_iva, p_total);

        INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio_unitario, subtotal)
        VALUES (LAST_INSERT_ID(), p_id_producto, p_cantidad, v_precio, v_subtotal);

        UPDATE productos SET stock = stock - p_cantidad WHERE id_producto = p_id_producto;

        SET p_mensaje = CONCAT('Venta registrada. Factura: ', v_numero);
    END IF;
END$$

CREATE PROCEDURE consultar_stock_producto(
    IN p_codigo VARCHAR(30),
    OUT p_nombre VARCHAR(100),
    OUT p_stock INT,
    OUT p_precio DECIMAL(10,2)
)
BEGIN
    SELECT nombre, stock, precio_venta INTO p_nombre, p_stock, p_precio
    FROM productos WHERE codigo = p_codigo;
END$$

CREATE PROCEDURE calcular_ganancia_periodo(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    OUT p_ganancia_total DECIMAL(12,2)
)
BEGIN
    SELECT IFNULL(SUM((df.precio_unitario - p.precio_compra) * df.cantidad), 0)
    INTO p_ganancia_total
    FROM detalle_factura df
    INNER JOIN facturas f ON df.id_factura = f.id_factura
    INNER JOIN productos p ON df.id_producto = p.id_producto
    WHERE DATE(f.fecha) BETWEEN p_fecha_inicio AND p_fecha_fin;
END$$

CREATE PROCEDURE listar_productos_por_categoria(IN p_categoria VARCHAR(50))
BEGIN
    SELECT p.codigo, p.nombre, p.precio_venta, p.stock, c.nombre AS categoria
    FROM productos p
    INNER JOIN categorias c ON p.id_categoria = c.id_categoria
    WHERE c.nombre = p_categoria;
END$$

CREATE PROCEDURE aplicar_descuento(
    INOUT p_precio DECIMAL(10,2),
    IN p_porcentaje DECIMAL(5,2)
)
BEGIN
    SET p_precio = p_precio - (p_precio * p_porcentaje / 100);
END$$

DELIMITER ;
