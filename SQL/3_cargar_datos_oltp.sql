USE BI_OLTP;
GO

INSERT INTO dbo.Categorias (NombreCategoria)
VALUES
('Abarrotes'),
('Bebidas'),
('Lacteos'),
('Carnes y Embutidos'),
('Frutas y Verduras'),
('Aseo Hogar'),
('Cuidado Personal'),
('Panaderia'),
('Mascotas'),
('Tecnologia Hogar');
GO

INSERT INTO dbo.Proveedores 
(NIT, NombreProveedor, Ciudad, Departamento, Telefono, Email)
VALUES
('900100001-1', 'Alimentos Antioquia SAS', 'Medellin', 'Antioquia', '6044441001', 'contacto@alimentosantioquia.com'),
('900100002-2', 'Distribuciones Bogota SAS', 'Bogota', 'Cundinamarca', '6015551002', 'ventas@distbogota.com'),
('900100003-3', 'Comercializadora Valle SAS', 'Cali', 'Valle del Cauca', '6025551003', 'info@comercialvalle.com'),
('900100004-4', 'Productos del Caribe SAS', 'Barranquilla', 'Atlantico', '6055551004', 'contacto@prodcaribe.com'),
('900100005-5', 'Lacteos La Sabana SAS', 'Bogota', 'Cundinamarca', '6015551005', 'ventas@lacteossabana.com'),
('900100006-6', 'Carnes Premium Antioquia SAS', 'Medellin', 'Antioquia', '6045551006', 'pedidos@carnespremium.com'),
('900100007-7', 'Agrofrutas del Eje SAS', 'Pereira', 'Risaralda', '6065551007', 'comercial@agrofrutas.com'),
('900100008-8', 'Aseo Colombia SAS', 'Bucaramanga', 'Santander', '6075551008', 'clientes@aseocolombia.com'),
('900100009-9', 'Belleza y Salud SAS', 'Cali', 'Valle del Cauca', '6025551009', 'ventas@bellezaysalud.com'),
('900100010-0', 'Panificadora Nacional SAS', 'Medellin', 'Antioquia', '6045551010', 'info@panificadora.com'),
('900100011-1', 'Mascotas Felices SAS', 'Bogota', 'Cundinamarca', '6015551011', 'ventas@mascotasfelices.com'),
('900100012-2', 'TecnoHogar Colombia SAS', 'Bogota', 'Cundinamarca', '6015551012', 'comercial@tecnohogar.com'),
('900100013-3', 'Bebidas Tropicales SAS', 'Cartagena', 'Bolivar', '6055551013', 'pedidos@bebidastropicales.com'),
('900100014-4', 'Mercantil Paisa SAS', 'Envigado', 'Antioquia', '6045551014', 'contacto@mercantilpaisa.com'),
('900100015-5', 'Distribuidora Santandereana SAS', 'Bucaramanga', 'Santander', '6075551015', 'ventas@distsantander.com'),
('900100016-6', 'Proveedora del Pacifico SAS', 'Pasto', 'Narino', '6025551016', 'info@proveedorapacifico.com'),
('900100017-7', 'Alimentos Tolima Grande SAS', 'Ibague', 'Tolima', '6085551017', 'ventas@tolimagrande.com'),
('900100018-8', 'Comercial Huila SAS', 'Neiva', 'Huila', '6085551018', 'contacto@comercialhuila.com'),
('900100019-9', 'Central de Abastos Llanos SAS', 'Villavicencio', 'Meta', '6085551019', 'ventas@abastosllanos.com'),
('900100020-0', 'Distribuciones Cafeteras SAS', 'Manizales', 'Caldas', '6065551020', 'info@distcafeteras.com');
GO

INSERT INTO dbo.Tiendas
(NombreTienda, Ciudad, Departamento, Region, Direccion)
VALUES
('Mercamax Medellin Centro', 'Medellin', 'Antioquia', 'Andina', 'Cra 50 # 45-20'),
('Mercamax Bogota Chapinero', 'Bogota', 'Cundinamarca', 'Andina', 'Calle 63 # 13-25'),
('Mercamax Cali Sur', 'Cali', 'Valle del Cauca', 'Pacifica', 'Av Pasoancho # 80-12'),
('Mercamax Barranquilla Norte', 'Barranquilla', 'Atlantico', 'Caribe', 'Cra 53 # 82-100'),
('Mercamax Bucaramanga Cabecera', 'Bucaramanga', 'Santander', 'Andina', 'Cra 35 # 48-60'),
('Mercamax Cartagena Bocagrande', 'Cartagena', 'Bolivar', 'Caribe', 'Av San Martin # 7-90'),
('Mercamax Pereira Centro', 'Pereira', 'Risaralda', 'Andina', 'Calle 19 # 8-34'),
('Mercamax Manizales Cable', 'Manizales', 'Caldas', 'Andina', 'Av Santander # 60-21'),
('Mercamax Villavicencio Viva', 'Villavicencio', 'Meta', 'Orinoquia', 'Av 40 # 25-30'),
('Mercamax Pasto Centro', 'Pasto', 'Narino', 'Pacifica', 'Calle 18 # 24-70');
GO

INSERT INTO dbo.CanalVenta (NombreCanal)
VALUES
('Tienda Fisica'),
('Pagina Web'),
('App Movil'),
('WhatsApp'),
('Marketplace');
GO

;WITH N AS (
    SELECT TOP (20)
        ROW_NUMBER() OVER (ORDER BY a.n, b.n) AS Num
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) a(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) b(n)
)
INSERT INTO dbo.Vendedores
(NombreCompleto, TiendaID, FechaIngreso, Activo)
SELECT
    CASE Num
        WHEN 1 THEN 'Santiago Garcia'
        WHEN 2 THEN 'Valentina Rodriguez'
        WHEN 3 THEN 'Mateo Martinez'
        WHEN 4 THEN 'Isabella Lopez'
        WHEN 5 THEN 'Sebastian Gonzalez'
        WHEN 6 THEN 'Camila Perez'
        WHEN 7 THEN 'Daniel Sanchez'
        WHEN 8 THEN 'Mariana Ramirez'
        WHEN 9 THEN 'Nicolas Torres'
        WHEN 10 THEN 'Gabriela Diaz'
        WHEN 11 THEN 'Alejandro Vargas'
        WHEN 12 THEN 'Laura Castro'
        WHEN 13 THEN 'Juan Rojas'
        WHEN 14 THEN 'Manuela Moreno'
        WHEN 15 THEN 'Andres Mejia'
        WHEN 16 THEN 'Sofia Restrepo'
        WHEN 17 THEN 'Carlos Zuluaga'
        WHEN 18 THEN 'Daniela Quintero'
        WHEN 19 THEN 'Miguel Cardona'
        ELSE 'Natalia Arias'
    END,
    ((Num - 1) / 2) + 1,
    DATEADD(DAY, -Num * 30, CAST('2023-01-01' AS DATE)),
    1
FROM N;
GO

;WITH N AS (
    SELECT TOP (1000)
        ROW_NUMBER() OVER (ORDER BY a.n, b.n, c.n, d.n) AS Num
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) a(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) b(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) c(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) d(n)
)
INSERT INTO dbo.Clientes
(Documento, NombreCompleto, Genero, Ciudad, Departamento, Segmento, Email, FechaRegistro)
SELECT
    CAST(1000000000 + Num AS VARCHAR(20)),
    CONCAT(
        CASE Num % 20
            WHEN 0 THEN 'Ana' WHEN 1 THEN 'Luis' WHEN 2 THEN 'Maria' WHEN 3 THEN 'Carlos'
            WHEN 4 THEN 'Laura' WHEN 5 THEN 'Juan' WHEN 6 THEN 'Daniela' WHEN 7 THEN 'Andres'
            WHEN 8 THEN 'Sofia' WHEN 9 THEN 'Miguel' WHEN 10 THEN 'Paula' WHEN 11 THEN 'Jorge'
            WHEN 12 THEN 'Valentina' WHEN 13 THEN 'Felipe' WHEN 14 THEN 'Camilo' WHEN 15 THEN 'Natalia'
            WHEN 16 THEN 'Juliana' WHEN 17 THEN 'David' WHEN 18 THEN 'Sara' ELSE 'Esteban'
        END,
        ' ',
        CASE Num % 20
            WHEN 0 THEN 'Garcia' WHEN 1 THEN 'Rodriguez' WHEN 2 THEN 'Martinez' WHEN 3 THEN 'Lopez'
            WHEN 4 THEN 'Gonzalez' WHEN 5 THEN 'Perez' WHEN 6 THEN 'Sanchez' WHEN 7 THEN 'Ramirez'
            WHEN 8 THEN 'Torres' WHEN 9 THEN 'Diaz' WHEN 10 THEN 'Vargas' WHEN 11 THEN 'Castro'
            WHEN 12 THEN 'Rojas' WHEN 13 THEN 'Moreno' WHEN 14 THEN 'Mejia' WHEN 15 THEN 'Restrepo'
            WHEN 16 THEN 'Zuluaga' WHEN 17 THEN 'Quintero' WHEN 18 THEN 'Cardona' ELSE 'Arias'
        END
    ),
    CASE Num % 3 WHEN 0 THEN 'F' WHEN 1 THEN 'M' ELSE 'O' END,
    CASE Num % 10
        WHEN 0 THEN 'Medellin' WHEN 1 THEN 'Bogota' WHEN 2 THEN 'Cali' WHEN 3 THEN 'Barranquilla'
        WHEN 4 THEN 'Bucaramanga' WHEN 5 THEN 'Cartagena' WHEN 6 THEN 'Pereira' WHEN 7 THEN 'Manizales'
        WHEN 8 THEN 'Villavicencio' ELSE 'Pasto'
    END,
    CASE Num % 10
        WHEN 0 THEN 'Antioquia' WHEN 1 THEN 'Cundinamarca' WHEN 2 THEN 'Valle del Cauca' WHEN 3 THEN 'Atlantico'
        WHEN 4 THEN 'Santander' WHEN 5 THEN 'Bolivar' WHEN 6 THEN 'Risaralda' WHEN 7 THEN 'Caldas'
        WHEN 8 THEN 'Meta' ELSE 'Narino'
    END,
    CASE 
        WHEN Num % 100 < 55 THEN 'Bronce'
        WHEN Num % 100 < 80 THEN 'Plata'
        WHEN Num % 100 < 95 THEN 'Oro'
        ELSE 'Platino'
    END,
    CONCAT('cliente', Num, '@correo.com'),
    DATEADD(DAY, -1 * (Num % 730), CAST('2024-12-31' AS DATE))
FROM N;
GO

;WITH N AS (
    SELECT TOP (200)
        ROW_NUMBER() OVER (ORDER BY a.n, b.n, c.n) AS Num
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) a(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) b(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) c(n)
),
Base AS (
    SELECT
        Num,
        ((Num - 1) % 10) + 1 AS CategoriaID,
        ((Num - 1) % 20) + 1 AS ProveedorID
    FROM N
)
INSERT INTO dbo.Productos
(SKU, NombreProducto, CategoriaID, ProveedorID, CostoUnitario, PrecioVenta, Activo)
SELECT
    CONCAT('SKU', RIGHT('00000' + CAST(Num AS VARCHAR(5)), 5)),
    CONCAT(
        CASE CategoriaID
            WHEN 1 THEN 'Arroz Premium '
            WHEN 2 THEN 'Jugo Natural '
            WHEN 3 THEN 'Leche Entera '
            WHEN 4 THEN 'Jamon Seleccion '
            WHEN 5 THEN 'Manzana Roja '
            WHEN 6 THEN 'Detergente Hogar '
            WHEN 7 THEN 'Shampoo Familiar '
            WHEN 8 THEN 'Pan Artesanal '
            WHEN 9 THEN 'Concentrado Mascota '
            ELSE 'Licuadora Hogar '
        END,
        Num
    ),
    CategoriaID,
    ProveedorID,
    CAST(
        CASE CategoriaID
            WHEN 1 THEN 2500 + (Num % 20) * 300
            WHEN 2 THEN 1800 + (Num % 20) * 250
            WHEN 3 THEN 2200 + (Num % 20) * 200
            WHEN 4 THEN 6000 + (Num % 20) * 700
            WHEN 5 THEN 1200 + (Num % 20) * 180
            WHEN 6 THEN 5000 + (Num % 20) * 500
            WHEN 7 THEN 7000 + (Num % 20) * 800
            WHEN 8 THEN 1500 + (Num % 20) * 200
            WHEN 9 THEN 9000 + (Num % 20) * 1000
            ELSE 30000 + (Num % 20) * 4500
        END AS DECIMAL(12,2)
    ),
    CAST(
        CASE CategoriaID
            WHEN 1 THEN (2500 + (Num % 20) * 300) * 1.35
            WHEN 2 THEN (1800 + (Num % 20) * 250) * 1.40
            WHEN 3 THEN (2200 + (Num % 20) * 200) * 1.32
            WHEN 4 THEN (6000 + (Num % 20) * 700) * 1.38
            WHEN 5 THEN (1200 + (Num % 20) * 180) * 1.45
            WHEN 6 THEN (5000 + (Num % 20) * 500) * 1.42
            WHEN 7 THEN (7000 + (Num % 20) * 800) * 1.48
            WHEN 8 THEN (1500 + (Num % 20) * 200) * 1.50
            WHEN 9 THEN (9000 + (Num % 20) * 1000) * 1.36
            ELSE (30000 + (Num % 20) * 4500) * 1.30
        END AS DECIMAL(12,2)
    ),
    1
FROM Base;
GO

;WITH N AS (
    SELECT TOP (50000)
        ROW_NUMBER() OVER (ORDER BY a.n, b.n, c.n, d.n, e.n) AS Num
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) a(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) b(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) c(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) d(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) e(n)
)
INSERT INTO dbo.Ventas
(NumeroFactura, FechaVenta, ClienteID, TiendaID, VendedorID, CanalVentaID, TotalVenta)
SELECT
    CONCAT('FAC-', RIGHT('00000000' + CAST(Num AS VARCHAR(8)), 8)),
    DATEADD(
        SECOND,
        (Num * 37) % 86400,
        DATEADD(DAY, Num % 730, CAST('2023-01-01' AS DATETIME2(0)))
    ),
    ((Num - 1) % 1000) + 1,
    ((Num - 1) % 10) + 1,
    ((((Num - 1) % 10) * 2) + ((Num % 2) + 1)),
    ((Num - 1) % 5) + 1,
    0
FROM N;
GO

INSERT INTO dbo.DetalleVentas
(VentaID, ProductoID, Cantidad, PrecioUnitario, CostoUnitario, ValorLinea)
SELECT
    v.VentaID,
    ((v.VentaID + x.Linea - 2) % 200) + 1,
    ((v.VentaID + x.Linea) % 5) + 1,
    p.PrecioVenta,
    p.CostoUnitario,
    CAST((((v.VentaID + x.Linea) % 5) + 1) * p.PrecioVenta AS DECIMAL(14,2))
FROM dbo.Ventas v
CROSS JOIN (VALUES (1), (2), (3)) x(Linea)
INNER JOIN dbo.Productos p
    ON p.ProductoID = ((v.VentaID + x.Linea - 2) % 200) + 1;
GO

UPDATE v
SET v.TotalVenta = d.TotalVenta
FROM dbo.Ventas v
INNER JOIN (
    SELECT 
        VentaID,
        SUM(ValorLinea) AS TotalVenta
    FROM dbo.DetalleVentas
    GROUP BY VentaID
) d
    ON v.VentaID = d.VentaID;
GO

;WITH Dias AS (
    SELECT TOP (365)
        ROW_NUMBER() OVER (ORDER BY a.n, b.n, c.n) - 1 AS Dia
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) a(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) b(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) c(n)
)
INSERT INTO dbo.InventarioDiario
(FechaInventario, ProductoID, TiendaID, StockInicial, Entradas, Salidas, StockFinal)
SELECT
    DATEADD(DAY, d.Dia, CAST('2024-01-01' AS DATE)),
    p.ProductoID,
    t.TiendaID,
    50 + ((p.ProductoID * 3 + t.TiendaID * 5 + d.Dia) % 80),
    ((p.ProductoID + t.TiendaID + d.Dia) % 20),
    ((p.ProductoID * 2 + t.TiendaID + d.Dia) % 15),
    50 
    + ((p.ProductoID * 3 + t.TiendaID * 5 + d.Dia) % 80)
    + ((p.ProductoID + t.TiendaID + d.Dia) % 20)
    - ((p.ProductoID * 2 + t.TiendaID + d.Dia) % 15)
FROM Dias d
CROSS JOIN dbo.Productos p
CROSS JOIN dbo.Tiendas t;
GO

;WITH N AS (
    SELECT TOP (2000)
        ROW_NUMBER() OVER (ORDER BY a.n, b.n, c.n, d.n) AS Num
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) a(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) b(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) c(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) d(n)
)
INSERT INTO dbo.Compras
(NumeroOrden, FechaCompra, ProveedorID, TiendaID, TotalCompra)
SELECT
    CONCAT('OC-', RIGHT('000000' + CAST(Num AS VARCHAR(6)), 6)),
    DATEADD(DAY, Num % 730, CAST('2023-01-01' AS DATE)),
    ((Num - 1) % 20) + 1,
    ((Num - 1) % 10) + 1,
    0
FROM N;
GO

INSERT INTO dbo.DetalleCompras
(CompraID, ProductoID, Cantidad, CostoUnitario, ValorLinea)
SELECT
    c.CompraID,
    ((c.CompraID + x.Linea - 2) % 200) + 1,
    20 + ((c.CompraID + x.Linea) % 80),
    p.CostoUnitario,
    CAST((20 + ((c.CompraID + x.Linea) % 80)) * p.CostoUnitario AS DECIMAL(14,2))
FROM dbo.Compras c
CROSS JOIN (VALUES (1), (2), (3)) x(Linea)
INNER JOIN dbo.Productos p
    ON p.ProductoID = ((c.CompraID + x.Linea - 2) % 200) + 1;
GO

UPDATE c
SET c.TotalCompra = d.TotalCompra
FROM dbo.Compras c
INNER JOIN (
    SELECT 
        CompraID,
        SUM(ValorLinea) AS TotalCompra
    FROM dbo.DetalleCompras
    GROUP BY CompraID
) d
    ON c.CompraID = d.CompraID;
GO

;WITH N AS (
    SELECT TOP (1000)
        ROW_NUMBER() OVER (ORDER BY a.n, b.n, c.n) AS Num
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) a(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) b(n)
    CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) c(n)
),
DetalleBase AS (
    SELECT
        d.DetalleVentaID,
        d.Cantidad,
        d.PrecioUnitario,
        v.FechaVenta,
        ROW_NUMBER() OVER (ORDER BY d.DetalleVentaID) AS RN
    FROM dbo.DetalleVentas d
    INNER JOIN dbo.Ventas v
        ON d.VentaID = v.VentaID
    WHERE d.DetalleVentaID % 10 = 0
)
INSERT INTO dbo.Devoluciones
(DetalleVentaID, FechaDevolucion, CantidadDevuelta, Motivo, ValorDevuelto)
SELECT
    db.DetalleVentaID,
    DATEADD(DAY, 3 + (n.Num % 20), CAST(db.FechaVenta AS DATE)),
    1,
    CASE n.Num % 5
        WHEN 0 THEN 'Producto defectuoso'
        WHEN 1 THEN 'Cambio de talla'
        WHEN 2 THEN 'Garantia'
        WHEN 3 THEN 'Error de despacho'
        ELSE 'Insatisfaccion'
    END,
    db.PrecioUnitario
FROM N n
INNER JOIN DetalleBase db
    ON db.RN = n.Num;
GO

;WITH Anios AS (
    SELECT 2023 AS Anio
    UNION ALL
    SELECT 2024 AS Anio
),
Meses AS (
    SELECT Mes
    FROM (VALUES 
        (1),(2),(3),(4),(5),(6),
        (7),(8),(9),(10),(11),(12)
    ) m(Mes)
)
INSERT INTO dbo.MetasComerciales
(Anio, Mes, TiendaID, CategoriaID, ValorMeta)
SELECT
    a.Anio,
    m.Mes,
    t.TiendaID,
    c.CategoriaID,
    CAST(
        12000000
        + (t.TiendaID * 850000)
        + (c.CategoriaID * 450000)
        + (m.Mes * 300000)
        + CASE 
            WHEN m.Mes IN (11,12) THEN 4000000
            WHEN m.Mes IN (6,7) THEN 2000000
            ELSE 0
          END
        AS DECIMAL(14,2)
    )
FROM Anios a
CROSS JOIN Meses m
CROSS JOIN dbo.Tiendas t
CROSS JOIN dbo.Categorias c;
GO