/* ----------------------------------------------------------------
   1. Bases creadas
   ---------------------------------------------------------------- */

USE master;
GO

SELECT 
    name AS BaseDatos,
    create_date
FROM sys.databases
WHERE name IN ('BI_OLTP', 'BI_Staging', 'BI_DW')
ORDER BY name;
GO

/* ----------------------------------------------------------------
   2. Conteos OLTP
   ---------------------------------------------------------------- */

USE BI_OLTP;
GO

SELECT 'Categorias' AS Tabla, COUNT(*) AS Registros FROM dbo.Categorias
UNION ALL
SELECT 'Proveedores', COUNT(*) FROM dbo.Proveedores
UNION ALL
SELECT 'Tiendas', COUNT(*) FROM dbo.Tiendas
UNION ALL
SELECT 'CanalVenta', COUNT(*) FROM dbo.CanalVenta
UNION ALL
SELECT 'Clientes', COUNT(*) FROM dbo.Clientes
UNION ALL
SELECT 'Vendedores', COUNT(*) FROM dbo.Vendedores
UNION ALL
SELECT 'Productos', COUNT(*) FROM dbo.Productos
UNION ALL
SELECT 'Ventas', COUNT(*) FROM dbo.Ventas
UNION ALL
SELECT 'DetalleVentas', COUNT(*) FROM dbo.DetalleVentas
UNION ALL
SELECT 'InventarioDiario', COUNT(*) FROM dbo.InventarioDiario
UNION ALL
SELECT 'Compras', COUNT(*) FROM dbo.Compras
UNION ALL
SELECT 'DetalleCompras', COUNT(*) FROM dbo.DetalleCompras
UNION ALL
SELECT 'Devoluciones', COUNT(*) FROM dbo.Devoluciones
UNION ALL
SELECT 'MetasComerciales', COUNT(*) FROM dbo.MetasComerciales;
GO

/* ----------------------------------------------------------------
   3. Conteos Staging
   ---------------------------------------------------------------- */

USE BI_Staging;
GO

SELECT 'stg_Clientes' AS Tabla, COUNT(*) AS Registros FROM dbo.stg_Clientes
UNION ALL
SELECT 'stg_Productos', COUNT(*) FROM dbo.stg_Productos
UNION ALL
SELECT 'stg_Ventas', COUNT(*) FROM dbo.stg_Ventas
UNION ALL
SELECT 'stg_Inventario', COUNT(*) FROM dbo.stg_Inventario
UNION ALL
SELECT 'stg_Metas', COUNT(*) FROM dbo.stg_Metas
UNION ALL
SELECT 'stg_Devoluciones', COUNT(*) FROM dbo.stg_Devoluciones
UNION ALL
SELECT 'stg_Compras', COUNT(*) FROM dbo.stg_Compras;
GO

/* ----------------------------------------------------------------
   4. Registros invalidos en Staging
   ---------------------------------------------------------------- */

USE BI_Staging;
GO

SELECT 'stg_Clientes' AS Tabla, COUNT(*) AS RegistrosInvalidos
FROM dbo.stg_Clientes
WHERE EsValido = 0 OR EsDuplicado = 1

UNION ALL

SELECT 'stg_Productos', COUNT(*)
FROM dbo.stg_Productos
WHERE EsValido = 0

UNION ALL

SELECT 'stg_Ventas', COUNT(*)
FROM dbo.stg_Ventas
WHERE EsValido = 0

UNION ALL

SELECT 'stg_Inventario', COUNT(*)
FROM dbo.stg_Inventario
WHERE EsValido = 0

UNION ALL

SELECT 'stg_Metas', COUNT(*)
FROM dbo.stg_Metas
WHERE EsValido = 0

UNION ALL

SELECT 'stg_Devoluciones', COUNT(*)
FROM dbo.stg_Devoluciones
WHERE EsValido = 0

UNION ALL

SELECT 'stg_Compras', COUNT(*)
FROM dbo.stg_Compras
WHERE EsValido = 0;
GO

/* ----------------------------------------------------------------
   5. Conteos DW
   ---------------------------------------------------------------- */

USE BI_DW;
GO

SELECT 'DimFecha' AS Tabla, COUNT(*) AS Registros FROM dbo.DimFecha
UNION ALL
SELECT 'DimCliente', COUNT(*) FROM dbo.DimCliente
UNION ALL
SELECT 'DimProducto', COUNT(*) FROM dbo.DimProducto
UNION ALL
SELECT 'DimTienda', COUNT(*) FROM dbo.DimTienda
UNION ALL
SELECT 'DimVendedor', COUNT(*) FROM dbo.DimVendedor
UNION ALL
SELECT 'DimProveedor', COUNT(*) FROM dbo.DimProveedor
UNION ALL
SELECT 'DimCanalVenta', COUNT(*) FROM dbo.DimCanalVenta
UNION ALL
SELECT 'DimPromocion', COUNT(*) FROM dbo.DimPromocion
UNION ALL
SELECT 'DimGeografia', COUNT(*) FROM dbo.DimGeografia
UNION ALL
SELECT 'FactVentas', COUNT(*) FROM dbo.FactVentas
UNION ALL
SELECT 'FactInventarioDiario', COUNT(*) FROM dbo.FactInventarioDiario
UNION ALL
SELECT 'FactMetasComerciales', COUNT(*) FROM dbo.FactMetasComerciales
UNION ALL
SELECT 'FactDevoluciones', COUNT(*) FROM dbo.FactDevoluciones
UNION ALL
SELECT 'FactCompras', COUNT(*) FROM dbo.FactCompras;
GO

/* ----------------------------------------------------------------
   6. ETL_Log
   ---------------------------------------------------------------- */

USE BI_DW;
GO

SELECT *
FROM dbo.ETL_Log
ORDER BY LogID DESC;
GO

/* ----------------------------------------------------------------
   7. Validacion de calidad
   ---------------------------------------------------------------- */

USE BI_DW;
GO

EXEC dbo.ValidarCalidadDatos;
GO

/* ----------------------------------------------------------------
   8. Ventas, costos, utilidad y margen
   ---------------------------------------------------------------- */

USE BI_DW;
GO

SELECT
    SUM(ValorVenta) AS TotalVentas,
    SUM(CostoTotal) AS TotalCosto,
    SUM(UtilidadBruta) AS UtilidadBruta,
    CAST(
        SUM(UtilidadBruta) * 100.0 / NULLIF(SUM(ValorVenta), 0)
        AS DECIMAL(10,2)
    ) AS MargenBrutoPorcentaje
FROM dbo.FactVentas;
GO

/* ----------------------------------------------------------------
   9. Ventas por mes
   ---------------------------------------------------------------- */

USE BI_DW;
GO

SELECT
    f.Anio,
    f.Mes,
    f.NombreMes,
    SUM(v.ValorVenta) AS TotalVentas,
    SUM(v.UtilidadBruta) AS UtilidadBruta
FROM dbo.FactVentas v
INNER JOIN dbo.DimFecha f
    ON v.FechaKey = f.FechaKey
GROUP BY
    f.Anio,
    f.Mes,
    f.NombreMes
ORDER BY
    f.Anio,
    f.Mes;
GO

/* ----------------------------------------------------------------
   10. Top productos por ventas
   ---------------------------------------------------------------- */

USE BI_DW;
GO

SELECT TOP 10
    p.NombreProducto,
    p.NombreCategoria,
    SUM(v.Cantidad) AS UnidadesVendidas,
    SUM(v.ValorVenta) AS TotalVentas,
    SUM(v.UtilidadBruta) AS UtilidadBruta
FROM dbo.FactVentas v
INNER JOIN dbo.DimProducto p
    ON v.ProductoKey = p.ProductoKey
GROUP BY
    p.NombreProducto,
    p.NombreCategoria
ORDER BY
    TotalVentas DESC;
GO

/* ----------------------------------------------------------------
   11. Top tiendas por ventas
   ---------------------------------------------------------------- */

USE BI_DW;
GO

SELECT
    t.NombreTienda,
    t.Ciudad,
    t.Departamento,
    t.Region,
    SUM(v.ValorVenta) AS TotalVentas,
    SUM(v.UtilidadBruta) AS UtilidadBruta
FROM dbo.FactVentas v
INNER JOIN dbo.DimTienda t
    ON v.TiendaKey = t.TiendaKey
GROUP BY
    t.NombreTienda,
    t.Ciudad,
    t.Departamento,
    t.Region
ORDER BY
    TotalVentas DESC;
GO

/* ----------------------------------------------------------------
   12. Devoluciones por motivo
   ---------------------------------------------------------------- */

USE BI_DW;
GO

SELECT
    Motivo,
    COUNT(*) AS NumeroDevoluciones,
    SUM(CantidadDevuelta) AS UnidadesDevueltas,
    SUM(ValorDevuelto) AS ValorDevuelto
FROM dbo.FactDevoluciones
GROUP BY
    Motivo
ORDER BY
    NumeroDevoluciones DESC;
GO

/* ----------------------------------------------------------------
   13. Inventario promedio por categoria
   ---------------------------------------------------------------- */

USE BI_DW;
GO

SELECT
    p.NombreCategoria,
    AVG(CAST(i.StockFinal AS DECIMAL(14,2))) AS InventarioPromedio,
    MIN(i.StockFinal) AS StockMinimo,
    MAX(i.StockFinal) AS StockMaximo
FROM dbo.FactInventarioDiario i
INNER JOIN dbo.DimProducto p
    ON i.ProductoKey = p.ProductoKey
GROUP BY
    p.NombreCategoria
ORDER BY
    InventarioPromedio DESC;
GO

/* ----------------------------------------------------------------
   14. Validacion de granularidad FactVentas
   ---------------------------------------------------------------- */

USE BI_DW;
GO

SELECT
    COUNT(*) AS FilasFactVentas,
    COUNT(DISTINCT DetalleVentaID_OLTP) AS LineasVentaUnicas,
    COUNT(DISTINCT VentaID_OLTP) AS FacturasUnicas
FROM dbo.FactVentas;
GO