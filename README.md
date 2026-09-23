# Sistema de Inventario y Facturación - Proyecto BD2

Base de datos para comercios locales de Cartago (Proyecto #5).

## Requisitos

- Docker Desktop con WSL2
- Ubuntu (WSL)
- MySQL Workbench

## Estructura del repositorio

proyecto-bd2/
├── docs/informe_avance.pdf
├── sql/
│   ├── esquema.sql
│   ├── datos_prueba.sql
│   ├── procedimientos.sql
│   └── triggers.sql
├── modelado/mer.mwb
├── docker-compose.yml
├── Dockerfile
└── README.md

## Cómo ejecutar

### 1. Clonar el repositorio
git clone https://github.com/alejandrarestrepoh-ops/proyecto-bd2.git
cd proyecto-bd2

### 2. Levantar contenedores
docker-compose up -d
docker ps

### 3. Ejecutar scripts SQL
docker exec -i proyecto_mariadb mysql -u root -proot_password < sql/esquema.sql
docker exec -i proyecto_mariadb mysql -u root -proot_password inventario_db < sql/datos_prueba.sql
docker exec -i proyecto_mariadb mysql -u root -proot_password inventario_db < sql/procedimientos.sql
docker exec -i proyecto_mariadb mysql -u root -proot_password inventario_db < sql/triggers.sql

### 4. Acceder a servicios
- phpMyAdmin: http://localhost:8101 (root / root_password)
- Workbench: 127.0.0.1:3308 (root / root_password)

## Procedimientos almacenados

1. `registrar_venta(IN, IN, IN, OUT, OUT)` - Registra venta y descuenta stock.
2. `consultar_stock_producto(IN, OUT, OUT, OUT)` - Consulta stock por código.
3. `calcular_ganancia_periodo(IN, IN, OUT)` - Calcula ganancia en un periodo.
4. `listar_productos_por_categoria(IN)` - Lista productos por categoría.
5. `aplicar_descuento(INOUT, IN)` - Aplica descuento a un precio.

## Triggers

1. `trg_alerta_stock_minimo` (AFTER UPDATE) - Genera alerta cuando stock baja del mínimo.
2. `trg_auditar_precio` (BEFORE UPDATE) - Registra cambios de precio.
3. `trg_actualizar_total_factura` (AFTER INSERT) - Actualiza totales de factura.

## Autor

Alejandra Restrepo - Ingeniería de Sistemas - COTECNOVA 2026
