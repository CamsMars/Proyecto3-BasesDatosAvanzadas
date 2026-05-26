USE BI_DW;
GO

DROP TABLE IF EXISTS dbo.FactVentas;
DROP TABLE IF EXISTS dbo.FactInventarioDiario;
DROP TABLE IF EXISTS dbo.FactMetasComerciales;
DROP TABLE IF EXISTS dbo.FactDevoluciones;
DROP TABLE IF EXISTS dbo.FactCompras;

DROP TABLE IF EXISTS dbo.DimCliente;
DROP TABLE IF EXISTS dbo.DimProducto;
DROP TABLE IF EXISTS dbo.DimTienda;
DROP TABLE IF EXISTS dbo.DimVendedor;
DROP TABLE IF EXISTS dbo.DimProveedor;
DROP TABLE IF EXISTS dbo.DimCanalVenta;
DROP TABLE IF EXISTS dbo.DimPromocion;
DROP TABLE IF EXISTS dbo.DimGeografia;
DROP TABLE IF EXISTS dbo.DimFecha;

DROP TABLE IF EXISTS dbo.ETL_Log;
GO

CREATE TABLE dbo.ETL_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    NombreProceso VARCHAR(120) NOT NULL,
    FechaInicio DATETIME2(0) NOT NULL,
    FechaFin DATETIME2(0) NULL,
    Estado VARCHAR(20) NOT NULL,
    RegistrosLeidos INT NOT NULL DEFAULT 0,
    RegistrosCargados INT NOT NULL DEFAULT 0,
    RegistrosRechazados INT NOT NULL DEFAULT 0,
    MensajeError VARCHAR(1000) NULL
);
GO

CREATE TABLE dbo.DimFecha (
    FechaKey INT NOT NULL PRIMARY KEY,
    Fecha DATE NOT NULL UNIQUE,
    Anio SMALLINT NOT NULL,
    Trimestre TINYINT NOT NULL,
    Mes TINYINT NOT NULL,
    NombreMes VARCHAR(20) NOT NULL,
    Semana TINYINT NOT NULL,
    Dia TINYINT NOT NULL,
    NombreDia VARCHAR(20) NOT NULL,
    EsFinSemana BIT NOT NULL
);
GO

CREATE TABLE dbo.DimCliente (
    ClienteKey INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID_OLTP INT NOT NULL UNIQUE,
    Documento VARCHAR(20) NOT NULL,
    NombreCompleto VARCHAR(150) NOT NULL,
    Genero CHAR(1) NOT NULL,
    Ciudad VARCHAR(80) NOT NULL,
    Departamento VARCHAR(80) NOT NULL,
    Region VARCHAR(40) NULL,
    Segmento VARCHAR(20) NOT NULL,
    Email VARCHAR(120) NOT NULL,
    FechaRegistro DATE NOT NULL
);
GO

CREATE TABLE dbo.DimProveedor (
    ProveedorKey INT IDENTITY(1,1) PRIMARY KEY,
    ProveedorID_OLTP INT NOT NULL UNIQUE,
    NIT VARCHAR(20) NOT NULL,
    NombreProveedor VARCHAR(120) NOT NULL,
    Ciudad VARCHAR(80) NOT NULL,
    Departamento VARCHAR(80) NOT NULL,
    Email VARCHAR(120) NOT NULL
);
GO

CREATE TABLE dbo.DimProducto (
    ProductoKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductoID_OLTP INT NOT NULL UNIQUE,
    SKU VARCHAR(30) NOT NULL,
    NombreProducto VARCHAR(150) NOT NULL,
    CategoriaID_OLTP INT NOT NULL,
    NombreCategoria VARCHAR(80) NOT NULL,
    ProveedorID_OLTP INT NOT NULL,
    NombreProveedor VARCHAR(120) NOT NULL,
    CostoUnitario DECIMAL(12,2) NOT NULL,
    PrecioVenta DECIMAL(12,2) NOT NULL,
    MargenUnitario DECIMAL(12,2) NOT NULL
);
GO

CREATE TABLE dbo.DimTienda (
    TiendaKey INT IDENTITY(1,1) PRIMARY KEY,
    TiendaID_OLTP INT NOT NULL UNIQUE,
    NombreTienda VARCHAR(120) NOT NULL,
    Ciudad VARCHAR(80) NOT NULL,
    Departamento VARCHAR(80) NOT NULL,
    Region VARCHAR(40) NOT NULL,
    Direccion VARCHAR(150) NOT NULL
);
GO

CREATE TABLE dbo.DimVendedor (
    VendedorKey INT IDENTITY(1,1) PRIMARY KEY,
    VendedorID_OLTP INT NOT NULL UNIQUE,
    NombreCompleto VARCHAR(150) NOT NULL,
    TiendaID_OLTP INT NOT NULL,
    NombreTienda VARCHAR(120) NOT NULL,
    FechaIngreso DATE NOT NULL,
    Activo BIT NOT NULL
);
GO

CREATE TABLE dbo.DimCanalVenta (
    CanalVentaKey INT IDENTITY(1,1) PRIMARY KEY,
    CanalVentaID_OLTP INT NOT NULL UNIQUE,
    NombreCanal VARCHAR(60) NOT NULL,
    Activo BIT NOT NULL
);
GO

CREATE TABLE dbo.DimPromocion (
    PromocionKey INT IDENTITY(1,1) PRIMARY KEY,
    NombrePromocion VARCHAR(100) NOT NULL,
    TipoPromocion VARCHAR(60) NOT NULL,
    PorcentajeDescuento DECIMAL(5,2) NOT NULL
);
GO

INSERT INTO dbo.DimPromocion
(NombrePromocion, TipoPromocion, PorcentajeDescuento)
VALUES
('Sin promocion', 'Ninguna', 0);
GO

CREATE TABLE dbo.DimGeografia (
    GeografiaKey INT IDENTITY(1,1) PRIMARY KEY,
    Ciudad VARCHAR(80) NOT NULL,
    Departamento VARCHAR(80) NOT NULL,
    Region VARCHAR(40) NOT NULL,
    CONSTRAINT UQ_DimGeografia UNIQUE (Ciudad, Departamento, Region)
);
GO

CREATE TABLE dbo.FactVentas (
    FactVentaID BIGINT IDENTITY(1,1) PRIMARY KEY,
    DetalleVentaID_OLTP BIGINT NOT NULL UNIQUE,
    VentaID_OLTP BIGINT NOT NULL,
    NumeroFactura VARCHAR(30) NOT NULL,
    FechaKey INT NOT NULL,
    ClienteKey INT NOT NULL,
    ProductoKey INT NOT NULL,
    TiendaKey INT NOT NULL,
    VendedorKey INT NOT NULL,
    CanalVentaKey INT NOT NULL,
    PromocionKey INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(12,2) NOT NULL,
    CostoUnitario DECIMAL(12,2) NOT NULL,
    ValorVenta DECIMAL(14,2) NOT NULL,
    CostoTotal DECIMAL(14,2) NOT NULL,
    UtilidadBruta DECIMAL(14,2) NOT NULL,

    CONSTRAINT FK_FactVentas_DimFecha 
        FOREIGN KEY (FechaKey) REFERENCES dbo.DimFecha(FechaKey),

    CONSTRAINT FK_FactVentas_DimCliente 
        FOREIGN KEY (ClienteKey) REFERENCES dbo.DimCliente(ClienteKey),

    CONSTRAINT FK_FactVentas_DimProducto 
        FOREIGN KEY (ProductoKey) REFERENCES dbo.DimProducto(ProductoKey),

    CONSTRAINT FK_FactVentas_DimTienda 
        FOREIGN KEY (TiendaKey) REFERENCES dbo.DimTienda(TiendaKey),

    CONSTRAINT FK_FactVentas_DimVendedor 
        FOREIGN KEY (VendedorKey) REFERENCES dbo.DimVendedor(VendedorKey),

    CONSTRAINT FK_FactVentas_DimCanalVenta 
        FOREIGN KEY (CanalVentaKey) REFERENCES dbo.DimCanalVenta(CanalVentaKey),

    CONSTRAINT FK_FactVentas_DimPromocion 
        FOREIGN KEY (PromocionKey) REFERENCES dbo.DimPromocion(PromocionKey)
);
GO

CREATE TABLE dbo.FactInventarioDiario (
    FactInventarioID BIGINT IDENTITY(1,1) PRIMARY KEY,
    InventarioID_OLTP BIGINT NOT NULL UNIQUE,
    FechaKey INT NOT NULL,
    ProductoKey INT NOT NULL,
    TiendaKey INT NOT NULL,
    StockInicial INT NOT NULL,
    Entradas INT NOT NULL,
    Salidas INT NOT NULL,
    StockFinal INT NOT NULL,

    CONSTRAINT FK_FactInventario_DimFecha 
        FOREIGN KEY (FechaKey) REFERENCES dbo.DimFecha(FechaKey),

    CONSTRAINT FK_FactInventario_DimProducto 
        FOREIGN KEY (ProductoKey) REFERENCES dbo.DimProducto(ProductoKey),

    CONSTRAINT FK_FactInventario_DimTienda 
        FOREIGN KEY (TiendaKey) REFERENCES dbo.DimTienda(TiendaKey)
);
GO

CREATE TABLE dbo.FactMetasComerciales (
    FactMetaID BIGINT IDENTITY(1,1) PRIMARY KEY,
    MetaID_OLTP BIGINT NOT NULL UNIQUE,
    FechaKey INT NOT NULL,
    TiendaKey INT NOT NULL,
    CategoriaID_OLTP INT NOT NULL,
    NombreCategoria VARCHAR(80) NOT NULL,
    ValorMeta DECIMAL(14,2) NOT NULL,

    CONSTRAINT FK_FactMetas_DimFecha 
        FOREIGN KEY (FechaKey) REFERENCES dbo.DimFecha(FechaKey),

    CONSTRAINT FK_FactMetas_DimTienda 
        FOREIGN KEY (TiendaKey) REFERENCES dbo.DimTienda(TiendaKey)
);
GO

CREATE TABLE dbo.FactDevoluciones (
    FactDevolucionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    DevolucionID_OLTP BIGINT NOT NULL UNIQUE,
    DetalleVentaID_OLTP BIGINT NOT NULL,
    FechaKey INT NOT NULL,
    ClienteKey INT NOT NULL,
    ProductoKey INT NOT NULL,
    TiendaKey INT NOT NULL,
    CantidadDevuelta INT NOT NULL,
    Motivo VARCHAR(100) NOT NULL,
    ValorDevuelto DECIMAL(14,2) NOT NULL,

    CONSTRAINT FK_FactDevoluciones_DimFecha 
        FOREIGN KEY (FechaKey) REFERENCES dbo.DimFecha(FechaKey),

    CONSTRAINT FK_FactDevoluciones_DimCliente 
        FOREIGN KEY (ClienteKey) REFERENCES dbo.DimCliente(ClienteKey),

    CONSTRAINT FK_FactDevoluciones_DimProducto 
        FOREIGN KEY (ProductoKey) REFERENCES dbo.DimProducto(ProductoKey),

    CONSTRAINT FK_FactDevoluciones_DimTienda 
        FOREIGN KEY (TiendaKey) REFERENCES dbo.DimTienda(TiendaKey)
);
GO

CREATE TABLE dbo.FactCompras (
    FactCompraID BIGINT IDENTITY(1,1) PRIMARY KEY,
    DetalleCompraID_OLTP BIGINT NOT NULL UNIQUE,
    CompraID_OLTP BIGINT NOT NULL,
    NumeroOrden VARCHAR(30) NOT NULL,
    FechaKey INT NOT NULL,
    ProductoKey INT NOT NULL,
    ProveedorKey INT NOT NULL,
    TiendaKey INT NOT NULL,
    Cantidad INT NOT NULL,
    CostoUnitario DECIMAL(12,2) NOT NULL,
    ValorCompra DECIMAL(14,2) NOT NULL,

    CONSTRAINT FK_FactCompras_DimFecha 
        FOREIGN KEY (FechaKey) REFERENCES dbo.DimFecha(FechaKey),

    CONSTRAINT FK_FactCompras_DimProducto 
        FOREIGN KEY (ProductoKey) REFERENCES dbo.DimProducto(ProductoKey),

    CONSTRAINT FK_FactCompras_DimProveedor 
        FOREIGN KEY (ProveedorKey) REFERENCES dbo.DimProveedor(ProveedorKey),

    CONSTRAINT FK_FactCompras_DimTienda 
        FOREIGN KEY (TiendaKey) REFERENCES dbo.DimTienda(TiendaKey)
);
GO