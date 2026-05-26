USE BI_Staging;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CargarStgClientes
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.stg_Clientes;

    INSERT INTO dbo.stg_Clientes
    (
        ClienteID_OLTP,
        Documento,
        NombreCompleto,
        Genero,
        Ciudad,
        Departamento,
        Region,
        Segmento,
        Email,
        FechaRegistro,
        EsDuplicado,
        EsValido,
        MensajeValidacion
    )
    SELECT
        c.ClienteID,
        ISNULL(NULLIF(LTRIM(RTRIM(c.Documento)), ''), 'SIN_DOCUMENTO'),
        UPPER(ISNULL(NULLIF(LTRIM(RTRIM(c.NombreCompleto)), ''), 'SIN NOMBRE')),
        ISNULL(c.Genero, 'O'),

        CASE 
            WHEN UPPER(LTRIM(RTRIM(c.Ciudad))) IN ('BOGOTA', 'BOGOTÁ') THEN 'Bogota'
            WHEN UPPER(LTRIM(RTRIM(c.Ciudad))) IN ('MEDELLIN', 'MEDELLÍN') THEN 'Medellin'
            WHEN UPPER(LTRIM(RTRIM(c.Ciudad))) = 'CALI' THEN 'Cali'
            WHEN UPPER(LTRIM(RTRIM(c.Ciudad))) = 'BARRANQUILLA' THEN 'Barranquilla'
            WHEN UPPER(LTRIM(RTRIM(c.Ciudad))) = 'BUCARAMANGA' THEN 'Bucaramanga'
            WHEN UPPER(LTRIM(RTRIM(c.Ciudad))) = 'CARTAGENA' THEN 'Cartagena'
            WHEN UPPER(LTRIM(RTRIM(c.Ciudad))) = 'PEREIRA' THEN 'Pereira'
            WHEN UPPER(LTRIM(RTRIM(c.Ciudad))) = 'MANIZALES' THEN 'Manizales'
            WHEN UPPER(LTRIM(RTRIM(c.Ciudad))) = 'VILLAVICENCIO' THEN 'Villavicencio'
            WHEN UPPER(LTRIM(RTRIM(c.Ciudad))) = 'PASTO' THEN 'Pasto'
            ELSE ISNULL(NULLIF(LTRIM(RTRIM(c.Ciudad)), ''), 'Sin ciudad')
        END,

        CASE 
            WHEN UPPER(LTRIM(RTRIM(c.Departamento))) IN ('BOGOTA', 'BOGOTÁ', 'CUNDINAMARCA') THEN 'Cundinamarca'
            WHEN UPPER(LTRIM(RTRIM(c.Departamento))) = 'ANTIOQUIA' THEN 'Antioquia'
            WHEN UPPER(LTRIM(RTRIM(c.Departamento))) IN ('VALLE', 'VALLE DEL CAUCA') THEN 'Valle del Cauca'
            WHEN UPPER(LTRIM(RTRIM(c.Departamento))) IN ('ATLANTICO', 'ATLÁNTICO') THEN 'Atlantico'
            ELSE ISNULL(NULLIF(LTRIM(RTRIM(c.Departamento)), ''), 'Sin departamento')
        END,

        CASE 
            WHEN c.Departamento IN ('Antioquia', 'Cundinamarca', 'Santander', 'Risaralda', 'Caldas') THEN 'Andina'
            WHEN c.Departamento IN ('Atlantico', 'Bolivar') THEN 'Caribe'
            WHEN c.Departamento IN ('Valle del Cauca', 'Narino') THEN 'Pacifica'
            WHEN c.Departamento IN ('Meta') THEN 'Orinoquia'
            ELSE 'Otra'
        END,

        ISNULL(c.Segmento, 'Bronce'),
        LOWER(ISNULL(NULLIF(LTRIM(RTRIM(c.Email)), ''), 'sinemail@correo.com')),
        c.FechaRegistro,

        CASE 
            WHEN COUNT(*) OVER (PARTITION BY c.Documento) > 1 THEN 1 
            ELSE 0 
        END,

        CASE 
            WHEN c.Documento IS NULL THEN 0
            WHEN c.Email NOT LIKE '%@%.%' THEN 0
            WHEN c.Segmento NOT IN ('Bronce', 'Plata', 'Oro', 'Platino') THEN 0
            ELSE 1
        END,

        CASE 
            WHEN c.Documento IS NULL THEN 'Documento nulo'
            WHEN c.Email NOT LIKE '%@%.%' THEN 'Email invalido'
            WHEN c.Segmento NOT IN ('Bronce', 'Plata', 'Oro', 'Platino') THEN 'Segmento invalido'
            ELSE NULL
        END

    FROM BI_OLTP.dbo.Clientes c;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CargarStgProductos
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.stg_Productos;

    INSERT INTO dbo.stg_Productos
    (
        ProductoID_OLTP,
        SKU,
        NombreProducto,
        CategoriaID_OLTP,
        NombreCategoria,
        ProveedorID_OLTP,
        NombreProveedor,
        CostoUnitario,
        PrecioVenta,
        MargenUnitario,
        EsValido,
        MensajeValidacion
    )
    SELECT
        p.ProductoID,
        p.SKU,
        UPPER(p.NombreProducto),
        p.CategoriaID,
        UPPER(c.NombreCategoria),
        p.ProveedorID,
        UPPER(pr.NombreProveedor),
        p.CostoUnitario,
        p.PrecioVenta,
        p.PrecioVenta - p.CostoUnitario,

        CASE
            WHEN c.CategoriaID IS NULL THEN 0
            WHEN pr.ProveedorID IS NULL THEN 0
            WHEN p.CostoUnitario <= 0 THEN 0
            WHEN p.PrecioVenta <= p.CostoUnitario THEN 0
            ELSE 1
        END,

        CASE
            WHEN c.CategoriaID IS NULL THEN 'Categoria inexistente'
            WHEN pr.ProveedorID IS NULL THEN 'Proveedor inexistente'
            WHEN p.CostoUnitario <= 0 THEN 'Costo invalido'
            WHEN p.PrecioVenta <= p.CostoUnitario THEN 'Precio menor o igual al costo'
            ELSE NULL
        END

    FROM BI_OLTP.dbo.Productos p
    LEFT JOIN BI_OLTP.dbo.Categorias c
        ON p.CategoriaID = c.CategoriaID
    LEFT JOIN BI_OLTP.dbo.Proveedores pr
        ON p.ProveedorID = pr.ProveedorID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CargarStgVentas
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.stg_Ventas;

    INSERT INTO dbo.stg_Ventas
    (
        VentaID_OLTP,
        DetalleVentaID_OLTP,
        NumeroFactura,
        FechaVenta,
        HoraVenta,
        ClienteID_OLTP,
        ProductoID_OLTP,
        TiendaID_OLTP,
        VendedorID_OLTP,
        CanalVentaID_OLTP,
        Cantidad,
        PrecioUnitario,
        CostoUnitario,
        ValorVenta,
        CostoTotal,
        UtilidadBruta,
        EsValido,
        MensajeValidacion
    )
    SELECT
        v.VentaID,
        d.DetalleVentaID,
        v.NumeroFactura,
        CAST(v.FechaVenta AS DATE),
        CAST(v.FechaVenta AS TIME(0)),
        v.ClienteID,
        d.ProductoID,
        v.TiendaID,
        v.VendedorID,
        v.CanalVentaID,
        d.Cantidad,
        d.PrecioUnitario,
        d.CostoUnitario,
        d.ValorLinea,
        d.Cantidad * d.CostoUnitario,
        d.ValorLinea - (d.Cantidad * d.CostoUnitario),

        CASE
            WHEN c.ClienteID IS NULL THEN 0
            WHEN p.ProductoID IS NULL THEN 0
            WHEN t.TiendaID IS NULL THEN 0
            WHEN ven.VendedorID IS NULL THEN 0
            WHEN cv.CanalVentaID IS NULL THEN 0
            WHEN d.Cantidad <= 0 THEN 0
            WHEN d.ValorLinea <= 0 THEN 0
            ELSE 1
        END,

        CASE
            WHEN c.ClienteID IS NULL THEN 'Cliente inexistente'
            WHEN p.ProductoID IS NULL THEN 'Producto inexistente'
            WHEN t.TiendaID IS NULL THEN 'Tienda inexistente'
            WHEN ven.VendedorID IS NULL THEN 'Vendedor inexistente'
            WHEN cv.CanalVentaID IS NULL THEN 'Canal inexistente'
            WHEN d.Cantidad <= 0 THEN 'Cantidad invalida'
            WHEN d.ValorLinea <= 0 THEN 'Valor de venta invalido'
            ELSE NULL
        END

    FROM BI_OLTP.dbo.Ventas v
    INNER JOIN BI_OLTP.dbo.DetalleVentas d
        ON v.VentaID = d.VentaID
    LEFT JOIN BI_OLTP.dbo.Clientes c
        ON v.ClienteID = c.ClienteID
    LEFT JOIN BI_OLTP.dbo.Productos p
        ON d.ProductoID = p.ProductoID
    LEFT JOIN BI_OLTP.dbo.Tiendas t
        ON v.TiendaID = t.TiendaID
    LEFT JOIN BI_OLTP.dbo.Vendedores ven
        ON v.VendedorID = ven.VendedorID
    LEFT JOIN BI_OLTP.dbo.CanalVenta cv
        ON v.CanalVentaID = cv.CanalVentaID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CargarStgInventario
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.stg_Inventario;

    INSERT INTO dbo.stg_Inventario
    (
        InventarioID_OLTP,
        FechaInventario,
        ProductoID_OLTP,
        TiendaID_OLTP,
        StockInicial,
        Entradas,
        Salidas,
        StockFinal,
        EsValido,
        MensajeValidacion
    )
    SELECT
        i.InventarioID,
        i.FechaInventario,
        i.ProductoID,
        i.TiendaID,
        i.StockInicial,
        i.Entradas,
        i.Salidas,
        i.StockFinal,

        CASE
            WHEN p.ProductoID IS NULL THEN 0
            WHEN t.TiendaID IS NULL THEN 0
            WHEN i.StockInicial < 0 THEN 0
            WHEN i.Entradas < 0 THEN 0
            WHEN i.Salidas < 0 THEN 0
            WHEN i.StockFinal < 0 THEN 0
            ELSE 1
        END,

        CASE
            WHEN p.ProductoID IS NULL THEN 'Producto inexistente'
            WHEN t.TiendaID IS NULL THEN 'Tienda inexistente'
            WHEN i.StockInicial < 0 THEN 'Stock inicial negativo'
            WHEN i.Entradas < 0 THEN 'Entradas negativas'
            WHEN i.Salidas < 0 THEN 'Salidas negativas'
            WHEN i.StockFinal < 0 THEN 'Stock final negativo'
            ELSE NULL
        END

    FROM BI_OLTP.dbo.InventarioDiario i
    LEFT JOIN BI_OLTP.dbo.Productos p
        ON i.ProductoID = p.ProductoID
    LEFT JOIN BI_OLTP.dbo.Tiendas t
        ON i.TiendaID = t.TiendaID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CargarStgMetas
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.stg_Metas;

    INSERT INTO dbo.stg_Metas
    (
        MetaID_OLTP,
        Anio,
        Mes,
        FechaMeta,
        TiendaID_OLTP,
        CategoriaID_OLTP,
        ValorMeta,
        EsValido,
        MensajeValidacion
    )
    SELECT
        m.MetaID,
        m.Anio,
        m.Mes,
        DATEFROMPARTS(m.Anio, m.Mes, 1),
        m.TiendaID,
        m.CategoriaID,
        m.ValorMeta,

        CASE
            WHEN t.TiendaID IS NULL THEN 0
            WHEN c.CategoriaID IS NULL THEN 0
            WHEN m.Mes NOT BETWEEN 1 AND 12 THEN 0
            WHEN m.ValorMeta <= 0 THEN 0
            ELSE 1
        END,

        CASE
            WHEN t.TiendaID IS NULL THEN 'Tienda inexistente'
            WHEN c.CategoriaID IS NULL THEN 'Categoria inexistente'
            WHEN m.Mes NOT BETWEEN 1 AND 12 THEN 'Mes invalido'
            WHEN m.ValorMeta <= 0 THEN 'Meta invalida'
            ELSE NULL
        END

    FROM BI_OLTP.dbo.MetasComerciales m
    LEFT JOIN BI_OLTP.dbo.Tiendas t
        ON m.TiendaID = t.TiendaID
    LEFT JOIN BI_OLTP.dbo.Categorias c
        ON m.CategoriaID = c.CategoriaID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CargarStgDevoluciones
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.stg_Devoluciones;

    INSERT INTO dbo.stg_Devoluciones
    (
        DevolucionID_OLTP,
        DetalleVentaID_OLTP,
        FechaDevolucion,
        ClienteID_OLTP,
        ProductoID_OLTP,
        TiendaID_OLTP,
        CantidadDevuelta,
        Motivo,
        ValorDevuelto,
        EsValido,
        MensajeValidacion
    )
    SELECT
        dev.DevolucionID,
        dev.DetalleVentaID,
        dev.FechaDevolucion,
        v.ClienteID,
        d.ProductoID,
        v.TiendaID,
        dev.CantidadDevuelta,
        dev.Motivo,
        dev.ValorDevuelto,

        CASE
            WHEN d.DetalleVentaID IS NULL THEN 0
            WHEN dev.CantidadDevuelta <= 0 THEN 0
            WHEN dev.ValorDevuelto <= 0 THEN 0
            ELSE 1
        END,

        CASE
            WHEN d.DetalleVentaID IS NULL THEN 'Detalle de venta inexistente'
            WHEN dev.CantidadDevuelta <= 0 THEN 'Cantidad devuelta invalida'
            WHEN dev.ValorDevuelto <= 0 THEN 'Valor devuelto invalido'
            ELSE NULL
        END

    FROM BI_OLTP.dbo.Devoluciones dev
    LEFT JOIN BI_OLTP.dbo.DetalleVentas d
        ON dev.DetalleVentaID = d.DetalleVentaID
    LEFT JOIN BI_OLTP.dbo.Ventas v
        ON d.VentaID = v.VentaID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CargarStgCompras
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.stg_Compras;

    INSERT INTO dbo.stg_Compras
    (
        CompraID_OLTP,
        DetalleCompraID_OLTP,
        NumeroOrden,
        FechaCompra,
        ProveedorID_OLTP,
        TiendaID_OLTP,
        ProductoID_OLTP,
        Cantidad,
        CostoUnitario,
        ValorCompra,
        EsValido,
        MensajeValidacion
    )
    SELECT
        c.CompraID,
        dc.DetalleCompraID,
        c.NumeroOrden,
        c.FechaCompra,
        c.ProveedorID,
        c.TiendaID,
        dc.ProductoID,
        dc.Cantidad,
        dc.CostoUnitario,
        dc.ValorLinea,

        CASE
            WHEN p.ProductoID IS NULL THEN 0
            WHEN pr.ProveedorID IS NULL THEN 0
            WHEN t.TiendaID IS NULL THEN 0
            WHEN dc.Cantidad <= 0 THEN 0
            WHEN dc.ValorLinea <= 0 THEN 0
            ELSE 1
        END,

        CASE
            WHEN p.ProductoID IS NULL THEN 'Producto inexistente'
            WHEN pr.ProveedorID IS NULL THEN 'Proveedor inexistente'
            WHEN t.TiendaID IS NULL THEN 'Tienda inexistente'
            WHEN dc.Cantidad <= 0 THEN 'Cantidad invalida'
            WHEN dc.ValorLinea <= 0 THEN 'Valor de compra invalido'
            ELSE NULL
        END

    FROM BI_OLTP.dbo.Compras c
    INNER JOIN BI_OLTP.dbo.DetalleCompras dc
        ON c.CompraID = dc.CompraID
    LEFT JOIN BI_OLTP.dbo.Productos p
        ON dc.ProductoID = p.ProductoID
    LEFT JOIN BI_OLTP.dbo.Proveedores pr
        ON c.ProveedorID = pr.ProveedorID
    LEFT JOIN BI_OLTP.dbo.Tiendas t
        ON c.TiendaID = t.TiendaID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CargarStagingCompleto
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.sp_CargarStgClientes;
    EXEC dbo.sp_CargarStgProductos;
    EXEC dbo.sp_CargarStgVentas;
    EXEC dbo.sp_CargarStgInventario;
    EXEC dbo.sp_CargarStgMetas;
    EXEC dbo.sp_CargarStgDevoluciones;
    EXEC dbo.sp_CargarStgCompras;
END;
GO

EXEC dbo.sp_CargarStagingCompleto;
GO