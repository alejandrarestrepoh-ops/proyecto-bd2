USE inventario_db;

DELIMITER $$

CREATE TRIGGER trg_alerta_stock_minimo
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.stock < NEW.stock_minimo AND OLD.stock >= OLD.stock_minimo THEN
        INSERT INTO alertas_stock (id_producto, stock_actual, stock_minimo, mensaje)
        VALUES (NEW.id_producto, NEW.stock, NEW.stock_minimo,
                CONCAT('ALERTA: ', NEW.nombre, ' tiene stock bajo (', NEW.stock, ' unidades). Minimo requerido: ', NEW.stock_minimo));
    END IF;
END$$

CREATE TRIGGER trg_auditar_precio
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NOT (NEW.precio_venta <=> OLD.precio_venta) THEN
        INSERT INTO auditoria_precios (id_producto, precio_anterior, precio_nuevo, usuario_bd)
        VALUES (OLD.id_producto, OLD.precio_venta, NEW.precio_venta, USER());
    END IF;
END$$

CREATE TRIGGER trg_actualizar_total_factura
AFTER INSERT ON detalle_factura
FOR EACH ROW
BEGIN
    UPDATE facturas
    SET subtotal = (SELECT IFNULL(SUM(subtotal),0) FROM detalle_factura WHERE id_factura = NEW.id_factura),
        iva = (SELECT IFNULL(SUM(subtotal),0) * 0.19 FROM detalle_factura WHERE id_factura = NEW.id_factura),
        total = (SELECT IFNULL(SUM(subtotal),0) * 1.19 FROM detalle_factura WHERE id_factura = NEW.id_factura)
    WHERE id_factura = NEW.id_factura;
END$$

DELIMITER ;
