USE BI_Staging;
GO

DROP TABLE IF EXISTS dbo.stg_Ventas;
DROP TABLE IF EXISTS dbo.stg_Productos;
DROP TABLE IF EXISTS dbo.stg_Clientes;
DROP TABLE IF EXISTS dbo.stg_Inventario;
DROP TABLE IF EXISTS dbo.stg_Metas;
DROP TABLE IF EXISTS dbo.stg_Devoluciones;
DROP TABLE IF EXISTS dbo.stg_Compras;
GO

CREATE TABLE dbo.stg_Clientes (
    ClienteID_OLTP INT NOT NULL,
    Documento VARCHAR(20) NOT NULL,
    NombreCompleto VARCHAR(150) NOT NULL,
    Genero CHAR(1) NOT NULL,
    Ciudad VARCHAR(80) NOT NULL,
    Departamento VARCHAR(80) NOT NULL,
    Region VARCHAR(40) NULL,
    Segmento VARCHAR(20) NOT NULL,
    Email VARCHAR(120) NOT NULL,
    FechaRegistro DATE NOT NULL,
    EsDuplicado BIT NOT NULL DEFAULT 0,
    EsValido BIT NOT NULL DEFAULT 1,
    MensajeValidacion VARCHAR(300) NULL,
    FechaCargaStaging DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.stg_Productos (
    ProductoID_OLTP INT NOT NULL,
    SKU VARCHAR(30) NOT NULL,
    NombreProducto VARCHAR(150) NOT NULL,
    CategoriaID_OLTP INT NOT NULL,
    NombreCategoria VARCHAR(80) NOT NULL,
    ProveedorID_OLTP INT NOT NULL,
    NombreProveedor VARCHAR(120) NOT NULL,
    CostoUnitario DECIMAL(12,2) NOT NULL,
    PrecioVenta DECIMAL(12,2) NOT NULL,
    MargenUnitario DECIMAL(12,2) NULL,
    EsValido BIT NOT NULL DEFAULT 1,
    MensajeValidacion VARCHAR(300) NULL,
    FechaCargaStaging DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.stg_Ventas (
    VentaID_OLTP BIGINT NOT NULL,
    DetalleVentaID_OLTP BIGINT NOT NULL,
    NumeroFactura VARCHAR(30) NOT NULL,
    FechaVenta DATE NOT NULL,
    HoraVenta TIME(0) NOT NULL,
    ClienteID_OLTP INT NOT NULL,
    ProductoID_OLTP INT NOT NULL,
    TiendaID_OLTP INT NOT NULL,
    VendedorID_OLTP INT NOT NULL,
    CanalVentaID_OLTP INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(12,2) NOT NULL,
    CostoUnitario DECIMAL(12,2) NOT NULL,
    ValorVenta DECIMAL(14,2) NOT NULL,
    CostoTotal DECIMAL(14,2) NULL,
    UtilidadBruta DECIMAL(14,2) NULL,
    EsValido BIT NOT NULL DEFAULT 1,
    MensajeValidacion VARCHAR(300) NULL,
    FechaCargaStaging DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.stg_Inventario (
    InventarioID_OLTP BIGINT NOT NULL,
    FechaInventario DATE NOT NULL,
    ProductoID_OLTP INT NOT NULL,
    TiendaID_OLTP INT NOT NULL,
    StockInicial INT NOT NULL,
    Entradas INT NOT NULL,
    Salidas INT NOT NULL,
    StockFinal INT NOT NULL,
    EsValido BIT NOT NULL DEFAULT 1,
    MensajeValidacion VARCHAR(300) NULL,
    FechaCargaStaging DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.stg_Metas (
    MetaID_OLTP BIGINT NOT NULL,
    Anio SMALLINT NOT NULL,
    Mes TINYINT NOT NULL,
    FechaMeta DATE NOT NULL,
    TiendaID_OLTP INT NOT NULL,
    CategoriaID_OLTP INT NOT NULL,
    ValorMeta DECIMAL(14,2) NOT NULL,
    EsValido BIT NOT NULL DEFAULT 1,
    MensajeValidacion VARCHAR(300) NULL,
    FechaCargaStaging DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.stg_Devoluciones (
    DevolucionID_OLTP BIGINT NOT NULL,
    DetalleVentaID_OLTP BIGINT NOT NULL,
    FechaDevolucion DATE NOT NULL,
    ClienteID_OLTP INT NOT NULL,
    ProductoID_OLTP INT NOT NULL,
    TiendaID_OLTP INT NOT NULL,
    CantidadDevuelta INT NOT NULL,
    Motivo VARCHAR(100) NOT NULL,
    ValorDevuelto DECIMAL(14,2) NOT NULL,
    EsValido BIT NOT NULL DEFAULT 1,
    MensajeValidacion VARCHAR(300) NULL,
    FechaCargaStaging DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.stg_Compras (
    CompraID_OLTP BIGINT NOT NULL,
    DetalleCompraID_OLTP BIGINT NOT NULL,
    NumeroOrden VARCHAR(30) NOT NULL,
    FechaCompra DATE NOT NULL,
    ProveedorID_OLTP INT NOT NULL,
    TiendaID_OLTP INT NOT NULL,
    ProductoID_OLTP INT NOT NULL,
    Cantidad INT NOT NULL,
    CostoUnitario DECIMAL(12,2) NOT NULL,
    ValorCompra DECIMAL(14,2) NOT NULL,
    EsValido BIT NOT NULL DEFAULT 1,
    MensajeValidacion VARCHAR(300) NULL,
    FechaCargaStaging DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO