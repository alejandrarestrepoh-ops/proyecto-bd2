USE inventario_db;

INSERT INTO categorias (nombre, descripcion) VALUES
('Computadores', 'Equipos de escritorio y portatiles'),
('Celulares', 'Telefonos inteligentes y accesorios'),
('Tablets', 'Tabletas electronicas'),
('Impresoras', 'Impresoras y multifuncionales'),
('Monitores', 'Pantallas y monitores'),
('Teclados', 'Teclados mecanicos y de membrana'),
('Mouse', 'Ratones y dispositivos de puntero'),
('Audio', 'Parlantes, audifonos y microfonos'),
('Almacenamiento', 'Discos duros, SSD y memorias'),
('Redes', 'Routers, switches y cables');

INSERT INTO proveedores (nit, nombre, telefono, correo, direccion) VALUES
('900123456-1', 'TecnoImport S.A.S', '3105551001', 'ventas@tecnoimport.com', 'Calle 10 #5-20, Cartago'),
('900123456-2', 'Distribuidora PC', '3105551002', 'contacto@distribuidorapc.com', 'Carrera 8 #12-30, Cartago'),
('900123456-3', 'Mundo Digital', '3105551003', 'info@mundodigital.com', 'Av. 3 #15-40, Pereira'),
('900123456-4', 'CompuPartes', '3105551004', 'ventas@compupartes.com', 'Calle 20 #8-15, Armenia'),
('900123456-5', 'ElectroHogar', '3105551005', 'gerencia@electrohogar.com', 'Carrera 5 #10-50, Manizales'),
('900123456-6', 'GamerStore', '3105551006', 'soporte@gamerstore.com', 'Calle 15 #6-25, Medellin'),
('900123456-7', 'OfficeSupply', '3105551007', 'ventas@officesupply.com', 'Av. 6 #20-10, Bogota'),
('900123456-8', 'SmartTech', '3105551008', 'info@smarttech.com', 'Carrera 12 #18-35, Cali'),
('900123456-9', 'DataStore', '3105551009', 'contacto@datastore.com', 'Calle 25 #9-40, Bucaramanga'),
('900123456-10', 'AudioMax', '3105551010', 'ventas@audiomax.com', 'Av. 8 #14-20, Cartagena');

INSERT INTO clientes (cedula, nombre, telefono, correo, direccion) VALUES
('11111111', 'Juan Perez', '3205551001', 'juan@email.com', 'Calle 1 #1-1, Cartago'),
('22222222', 'Maria Lopez', '3205551002', 'maria@email.com', 'Calle 2 #2-2, Cartago'),
('33333333', 'Carlos Gomez', '3205551003', 'carlos@email.com', 'Calle 3 #3-3, Pereira'),
('44444444', 'Ana Rodriguez', '3205551004', 'ana@email.com', 'Calle 4 #4-4, Armenia'),
('55555555', 'Luis Martinez', '3205551005', 'luis@email.com', 'Calle 5 #5-5, Manizales'),
('66666666', 'Sofia Hernandez', '3205551006', 'sofia@email.com', 'Calle 6 #6-6, Medellin'),
('77777777', 'Pedro Ramirez', '3205551007', 'pedro@email.com', 'Calle 7 #7-7, Bogota'),
('88888888', 'Laura Torres', '3205551008', 'laura@email.com', 'Calle 8 #8-8, Cali'),
('99999999', 'Diego Flores', '3205551009', 'diego@email.com', 'Calle 9 #9-9, Bucaramanga'),
('10101010', 'Carmen Diaz', '3205551010', 'carmen@email.com', 'Calle 10 #10-10, Cartagena');

INSERT INTO productos (codigo, nombre, id_categoria, id_proveedor, precio_compra, precio_venta, stock, stock_minimo) VALUES
('P001', 'Portatil HP Pavilion', 1, 1, 1800000, 2500000, 15, 3),
('P002', 'Celular Samsung A54', 2, 2, 900000, 1400000, 20, 5),
('P003', 'Tablet Lenovo M10', 3, 3, 600000, 950000, 12, 3),
('P004', 'Impresora Epson L3250', 4, 4, 700000, 1100000, 8, 2),
('P005', 'Monitor LG 24 pulgadas', 5, 5, 450000, 750000, 10, 3),
('P006', 'Teclado Mecanico Redragon', 6, 6, 120000, 220000, 25, 5),
('P007', 'Mouse Logitech G502', 7, 7, 150000, 280000, 30, 5),
('P008', 'Audifonos Sony WH1000', 8, 8, 800000, 1300000, 6, 2),
('P009', 'SSD Kingston 1TB', 9, 9, 250000, 420000, 18, 4),
('P010', 'Router TP-Link AX3000', 10, 10, 200000, 350000, 14, 3);

INSERT INTO facturas (numero_factura, fecha, id_cliente, subtotal, iva, total) VALUES
('FAC-001', '2024-09-01 10:30:00', 1, 2500000, 475000, 2975000),
('FAC-002', '2024-09-02 11:15:00', 2, 1400000, 266000, 1666000),
('FAC-003', '2024-09-03 09:45:00', 3, 950000, 180500, 1130500),
('FAC-004', '2024-09-04 14:20:00', 4, 1100000, 209000, 1309000),
('FAC-005', '2024-09-05 16:00:00', 5, 750000, 142500, 892500),
('FAC-006', '2024-09-06 12:00:00', 6, 220000, 41800, 261800),
('FAC-007', '2024-09-07 13:30:00', 7, 280000, 53200, 333200),
('FAC-008', '2024-09-08 15:45:00', 8, 1300000, 247000, 1547000),
('FAC-009', '2024-09-09 10:00:00', 9, 420000, 79800, 499800),
('FAC-010', '2024-09-10 17:20:00', 10, 350000, 66500, 416500);

INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio_unitario, subtotal) VALUES
(1, 1, 1, 2500000, 2500000),
(2, 2, 1, 1400000, 1400000),
(3, 3, 1, 950000, 950000),
(4, 4, 1, 1100000, 1100000),
(5, 5, 1, 750000, 750000),
(6, 6, 1, 220000, 220000),
(7, 7, 1, 280000, 280000),
(8, 8, 1, 1300000, 1300000),
(9, 9, 1, 420000, 420000),
(10, 10, 1, 350000, 350000);
