-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: inventario_db
-- ------------------------------------------------------
-- Server version	5.5.5-10.8.8-MariaDB-1:10.8.8+maria~ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alertas_stock`
--

DROP TABLE IF EXISTS `alertas_stock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alertas_stock` (
  `id_alerta` int(11) NOT NULL AUTO_INCREMENT,
  `id_producto` int(11) NOT NULL,
  `stock_actual` int(11) NOT NULL,
  `stock_minimo` int(11) NOT NULL,
  `fecha_alerta` datetime NOT NULL DEFAULT current_timestamp(),
  `mensaje` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id_alerta`),
  KEY `id_producto` (`id_producto`),
  CONSTRAINT `alertas_stock_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alertas_stock`
--

LOCK TABLES `alertas_stock` WRITE;
/*!40000 ALTER TABLE `alertas_stock` DISABLE KEYS */;
/*!40000 ALTER TABLE `alertas_stock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_precios`
--

DROP TABLE IF EXISTS `auditoria_precios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria_precios` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `id_producto` int(11) NOT NULL,
  `precio_anterior` decimal(10,2) DEFAULT NULL,
  `precio_nuevo` decimal(10,2) DEFAULT NULL,
  `fecha_cambio` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario_bd` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id_auditoria`),
  KEY `id_producto` (`id_producto`),
  CONSTRAINT `auditoria_precios_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_precios`
--

LOCK TABLES `auditoria_precios` WRITE;
/*!40000 ALTER TABLE `auditoria_precios` DISABLE KEYS */;
/*!40000 ALTER TABLE `auditoria_precios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Computadores','Equipos de escritorio y portatiles'),(2,'Celulares','Telefonos inteligentes y accesorios'),(3,'Tablets','Tabletas electronicas'),(4,'Impresoras','Impresoras y multifuncionales'),(5,'Monitores','Pantallas y monitores'),(6,'Teclados','Teclados mecanicos y de membrana'),(7,'Mouse','Ratones y dispositivos de puntero'),(8,'Audio','Parlantes, audifonos y microfonos'),(9,'Almacenamiento','Discos duros, SSD y memorias'),(10,'Redes','Routers, switches y cables');
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id_cliente` int(11) NOT NULL AUTO_INCREMENT,
  `cedula` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `direccion` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `cedula` (`cedula`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (1,'11111111','Juan Perez','3205551001','juan@email.com','Calle 1 #1-1, Cartago'),(2,'22222222','Maria Lopez','3205551002','maria@email.com','Calle 2 #2-2, Cartago'),(3,'33333333','Carlos Gomez','3205551003','carlos@email.com','Calle 3 #3-3, Pereira'),(4,'44444444','Ana Rodriguez','3205551004','ana@email.com','Calle 4 #4-4, Armenia'),(5,'55555555','Luis Martinez','3205551005','luis@email.com','Calle 5 #5-5, Manizales'),(6,'66666666','Sofia Hernandez','3205551006','sofia@email.com','Calle 6 #6-6, Medellin'),(7,'77777777','Pedro Ramirez','3205551007','pedro@email.com','Calle 7 #7-7, Bogota'),(8,'88888888','Laura Torres','3205551008','laura@email.com','Calle 8 #8-8, Cali'),(9,'99999999','Diego Flores','3205551009','diego@email.com','Calle 9 #9-9, Bucaramanga'),(10,'10101010','Carmen Diaz','3205551010','carmen@email.com','Calle 10 #10-10, Cartagena');
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_factura`
--

DROP TABLE IF EXISTS `detalle_factura`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalle_factura` (
  `id_detalle` int(11) NOT NULL AUTO_INCREMENT,
  `id_factura` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `id_factura` (`id_factura`),
  KEY `id_producto` (`id_producto`),
  CONSTRAINT `detalle_factura_ibfk_1` FOREIGN KEY (`id_factura`) REFERENCES `facturas` (`id_factura`),
  CONSTRAINT `detalle_factura_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_factura`
--

LOCK TABLES `detalle_factura` WRITE;
/*!40000 ALTER TABLE `detalle_factura` DISABLE KEYS */;
INSERT INTO `detalle_factura` VALUES (1,1,1,1,2500000.00,2500000.00),(2,2,2,1,1400000.00,1400000.00),(3,3,3,1,950000.00,950000.00),(4,4,4,1,1100000.00,1100000.00),(5,5,5,1,750000.00,750000.00),(6,6,6,1,220000.00,220000.00),(7,7,7,1,280000.00,280000.00),(8,8,8,1,1300000.00,1300000.00),(9,9,9,1,420000.00,420000.00),(10,10,10,1,350000.00,350000.00);
/*!40000 ALTER TABLE `detalle_factura` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `facturas`
--

DROP TABLE IF EXISTS `facturas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facturas` (
  `id_factura` int(11) NOT NULL AUTO_INCREMENT,
  `numero_factura` varchar(20) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `id_cliente` int(11) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `iva` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id_factura`),
  UNIQUE KEY `numero_factura` (`numero_factura`),
  KEY `id_cliente` (`id_cliente`),
  CONSTRAINT `facturas_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `facturas`
--

LOCK TABLES `facturas` WRITE;
/*!40000 ALTER TABLE `facturas` DISABLE KEYS */;
INSERT INTO `facturas` VALUES (1,'FAC-001','2024-09-01 10:30:00',1,2500000.00,475000.00,2975000.00),(2,'FAC-002','2024-09-02 11:15:00',2,1400000.00,266000.00,1666000.00),(3,'FAC-003','2024-09-03 09:45:00',3,950000.00,180500.00,1130500.00),(4,'FAC-004','2024-09-04 14:20:00',4,1100000.00,209000.00,1309000.00),(5,'FAC-005','2024-09-05 16:00:00',5,750000.00,142500.00,892500.00),(6,'FAC-006','2024-09-06 12:00:00',6,220000.00,41800.00,261800.00),(7,'FAC-007','2024-09-07 13:30:00',7,280000.00,53200.00,333200.00),(8,'FAC-008','2024-09-08 15:45:00',8,1300000.00,247000.00,1547000.00),(9,'FAC-009','2024-09-09 10:00:00',9,420000.00,79800.00,499800.00),(10,'FAC-010','2024-09-10 17:20:00',10,350000.00,66500.00,416500.00);
/*!40000 ALTER TABLE `facturas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos` (
  `id_producto` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(30) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `id_proveedor` int(11) NOT NULL,
  `precio_compra` decimal(10,2) NOT NULL DEFAULT 0.00,
  `precio_venta` decimal(10,2) NOT NULL DEFAULT 0.00,
  `stock` int(11) NOT NULL DEFAULT 0,
  `stock_minimo` int(11) NOT NULL DEFAULT 5,
  PRIMARY KEY (`id_producto`),
  UNIQUE KEY `codigo` (`codigo`),
  KEY `id_categoria` (`id_categoria`),
  KEY `id_proveedor` (`id_proveedor`),
  CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`),
  CONSTRAINT `productos_ibfk_2` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (1,'P001','Portatil HP Pavilion',1,1,1800000.00,2500000.00,15,3),(2,'P002','Celular Samsung A54',2,2,900000.00,1400000.00,20,5),(3,'P003','Tablet Lenovo M10',3,3,600000.00,950000.00,12,3),(4,'P004','Impresora Epson L3250',4,4,700000.00,1100000.00,8,2),(5,'P005','Monitor LG 24 pulgadas',5,5,450000.00,750000.00,10,3),(6,'P006','Teclado Mecanico Redragon',6,6,120000.00,220000.00,25,5),(7,'P007','Mouse Logitech G502',7,7,150000.00,280000.00,30,5),(8,'P008','Audifonos Sony WH1000',8,8,800000.00,1300000.00,6,2),(9,'P009','SSD Kingston 1TB',9,9,250000.00,420000.00,18,4),(10,'P010','Router TP-Link AX3000',10,10,200000.00,350000.00,14,3);
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedores`
--

DROP TABLE IF EXISTS `proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proveedores` (
  `id_proveedor` int(11) NOT NULL AUTO_INCREMENT,
  `nit` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `direccion` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id_proveedor`),
  UNIQUE KEY `nit` (`nit`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores`
--

LOCK TABLES `proveedores` WRITE;
/*!40000 ALTER TABLE `proveedores` DISABLE KEYS */;
INSERT INTO `proveedores` VALUES (1,'900123456-1','TecnoImport S.A.S','3105551001','ventas@tecnoimport.com','Calle 10 #5-20, Cartago'),(2,'900123456-2','Distribuidora PC','3105551002','contacto@distribuidorapc.com','Carrera 8 #12-30, Cartago'),(3,'900123456-3','Mundo Digital','3105551003','info@mundodigital.com','Av. 3 #15-40, Pereira'),(4,'900123456-4','CompuPartes','3105551004','ventas@compupartes.com','Calle 20 #8-15, Armenia'),(5,'900123456-5','ElectroHogar','3105551005','gerencia@electrohogar.com','Carrera 5 #10-50, Manizales'),(6,'900123456-6','GamerStore','3105551006','soporte@gamerstore.com','Calle 15 #6-25, Medellin'),(7,'900123456-7','OfficeSupply','3105551007','ventas@officesupply.com','Av. 6 #20-10, Bogota'),(8,'900123456-8','SmartTech','3105551008','info@smarttech.com','Carrera 12 #18-35, Cali'),(9,'900123456-9','DataStore','3105551009','contacto@datastore.com','Calle 25 #9-40, Bucaramanga'),(10,'900123456-10','AudioMax','3105551010','ventas@audiomax.com','Av. 8 #14-20, Cartagena');
/*!40000 ALTER TABLE `proveedores` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-06 22:06:46
