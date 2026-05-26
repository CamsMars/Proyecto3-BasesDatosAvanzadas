USE BI_OLTP;
GO

CREATE TABLE dbo.Categorias (
    CategoriaID INT IDENTITY(1,1) PRIMARY KEY,
    NombreCategoria VARCHAR(80) NOT NULL UNIQUE,
    Activa BIT NOT NULL DEFAULT 1,
    CONSTRAINT CK_Categorias_Nombre CHECK (LEN(NombreCategoria) >= 3)
);
GO

CREATE TABLE dbo.Proveedores (
    ProveedorID INT IDENTITY(1,1) PRIMARY KEY,
    NIT VARCHAR(20) NOT NULL UNIQUE,
    NombreProveedor VARCHAR(120) NOT NULL,
    Ciudad VARCHAR(80) NOT NULL,
    Departamento VARCHAR(80) NOT NULL,
    Telefono VARCHAR(20) NOT NULL,
    Email VARCHAR(120) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT CK_Proveedores_Email CHECK (Email LIKE '%@%.%')
);
GO

CREATE TABLE dbo.Tiendas (
    TiendaID INT IDENTITY(1,1) PRIMARY KEY,
    NombreTienda VARCHAR(120) NOT NULL,
    Ciudad VARCHAR(80) NOT NULL,
    Departamento VARCHAR(80) NOT NULL,
    Region VARCHAR(40) NOT NULL,
    Direccion VARCHAR(150) NOT NULL,
    Activa BIT NOT NULL DEFAULT 1,
    CONSTRAINT CK_Tiendas_Region CHECK 
    (
        Region IN ('Andina', 'Caribe', 'Pacifica', 'Orinoquia', 'Amazonia')
    )
);
GO

CREATE TABLE dbo.Clientes (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Documento VARCHAR(20) NOT NULL UNIQUE,
    NombreCompleto VARCHAR(150) NOT NULL,
    Genero CHAR(1) NOT NULL,
    Ciudad VARCHAR(80) NOT NULL,
    Departamento VARCHAR(80) NOT NULL,
    Segmento VARCHAR(20) NOT NULL,
    Email VARCHAR(120) NOT NULL,
    FechaRegistro DATE NOT NULL,
    CONSTRAINT CK_Clientes_Genero CHECK (Genero IN ('F', 'M', 'O')),
    CONSTRAINT CK_Clientes_Segmento CHECK 
    (
        Segmento IN ('Bronce', 'Plata', 'Oro', 'Platino')
    ),
    CONSTRAINT CK_Clientes_Email CHECK (Email LIKE '%@%.%')
);
GO

CREATE TABLE dbo.Vendedores (
    VendedorID INT IDENTITY(1,1) PRIMARY KEY,
    NombreCompleto VARCHAR(150) NOT NULL,
    TiendaID INT NOT NULL,
    FechaIngreso DATE NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Vendedores_Tiendas 
        FOREIGN KEY (TiendaID) REFERENCES dbo.Tiendas(TiendaID)
);
GO

CREATE TABLE dbo.Productos (
    ProductoID INT IDENTITY(1,1) PRIMARY KEY,
    SKU VARCHAR(30) NOT NULL UNIQUE,
    NombreProducto VARCHAR(150) NOT NULL,
    CategoriaID INT NOT NULL,
    ProveedorID INT NOT NULL,
    CostoUnitario DECIMAL(12,2) NOT NULL,
    PrecioVenta DECIMAL(12,2) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Productos_Categorias 
        FOREIGN KEY (CategoriaID) REFERENCES dbo.Categorias(CategoriaID),
    CONSTRAINT FK_Productos_Proveedores 
        FOREIGN KEY (ProveedorID) REFERENCES dbo.Proveedores(ProveedorID),
    CONSTRAINT CK_Productos_Precios 
        CHECK (CostoUnitario > 0 AND PrecioVenta > CostoUnitario)
);
GO

CREATE TABLE dbo.CanalVenta (
    CanalVentaID INT IDENTITY(1,1) PRIMARY KEY,
    NombreCanal VARCHAR(60) NOT NULL UNIQUE,
    Activo BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE dbo.Ventas (
    VentaID BIGINT IDENTITY(1,1) PRIMARY KEY,
    NumeroFactura VARCHAR(30) NOT NULL UNIQUE,
    FechaVenta DATETIME2(0) NOT NULL,
    ClienteID INT NOT NULL,
    TiendaID INT NOT NULL,
    VendedorID INT NOT NULL,
    CanalVentaID INT NOT NULL,
    TotalVenta DECIMAL(14,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Ventas_Clientes 
        FOREIGN KEY (ClienteID) REFERENCES dbo.Clientes(ClienteID),
    CONSTRAINT FK_Ventas_Tiendas 
        FOREIGN KEY (TiendaID) REFERENCES dbo.Tiendas(TiendaID),
    CONSTRAINT FK_Ventas_Vendedores 
        FOREIGN KEY (VendedorID) REFERENCES dbo.Vendedores(VendedorID),
    CONSTRAINT FK_Ventas_CanalVenta 
        FOREIGN KEY (CanalVentaID) REFERENCES dbo.CanalVenta(CanalVentaID),
    CONSTRAINT CK_Ventas_Total CHECK (TotalVenta >= 0)
);
GO

CREATE TABLE dbo.DetalleVentas (
    DetalleVentaID BIGINT IDENTITY(1,1) PRIMARY KEY,
    VentaID BIGINT NOT NULL,
    ProductoID INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(12,2) NOT NULL,
    CostoUnitario DECIMAL(12,2) NOT NULL,
    ValorLinea DECIMAL(14,2) NOT NULL,
    CONSTRAINT FK_DetalleVentas_Ventas 
        FOREIGN KEY (VentaID) REFERENCES dbo.Ventas(VentaID),
    CONSTRAINT FK_DetalleVentas_Productos 
        FOREIGN KEY (ProductoID) REFERENCES dbo.Productos(ProductoID),
    CONSTRAINT CK_DetalleVentas_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CK_DetalleVentas_Valores 
        CHECK (PrecioUnitario > 0 AND CostoUnitario > 0 AND ValorLinea > 0)
);
GO

CREATE TABLE dbo.InventarioDiario (
    InventarioID BIGINT IDENTITY(1,1) PRIMARY KEY,
    FechaInventario DATE NOT NULL,
    ProductoID INT NOT NULL,
    TiendaID INT NOT NULL,
    StockInicial INT NOT NULL,
    Entradas INT NOT NULL,
    Salidas INT NOT NULL,
    StockFinal INT NOT NULL,
    CONSTRAINT FK_Inventario_Productos 
        FOREIGN KEY (ProductoID) REFERENCES dbo.Productos(ProductoID),
    CONSTRAINT FK_Inventario_Tiendas 
        FOREIGN KEY (TiendaID) REFERENCES dbo.Tiendas(TiendaID),
    CONSTRAINT UQ_Inventario UNIQUE (FechaInventario, ProductoID, TiendaID),
    CONSTRAINT CK_Inventario_Valores 
        CHECK 
        (
            StockInicial >= 0 
            AND Entradas >= 0 
            AND Salidas >= 0 
            AND StockFinal >= 0
        )
);
GO

CREATE TABLE dbo.Compras (
    CompraID BIGINT IDENTITY(1,1) PRIMARY KEY,
    NumeroOrden VARCHAR(30) NOT NULL UNIQUE,
    FechaCompra DATE NOT NULL,
    ProveedorID INT NOT NULL,
    TiendaID INT NOT NULL,
    TotalCompra DECIMAL(14,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Compras_Proveedores 
        FOREIGN KEY (ProveedorID) REFERENCES dbo.Proveedores(ProveedorID),
    CONSTRAINT FK_Compras_Tiendas 
        FOREIGN KEY (TiendaID) REFERENCES dbo.Tiendas(TiendaID),
    CONSTRAINT CK_Compras_Total CHECK (TotalCompra >= 0)
);
GO

CREATE TABLE dbo.DetalleCompras (
    DetalleCompraID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CompraID BIGINT NOT NULL,
    ProductoID INT NOT NULL,
    Cantidad INT NOT NULL,
    CostoUnitario DECIMAL(12,2) NOT NULL,
    ValorLinea DECIMAL(14,2) NOT NULL,
    CONSTRAINT FK_DetalleCompras_Compras 
        FOREIGN KEY (CompraID) REFERENCES dbo.Compras(CompraID),
    CONSTRAINT FK_DetalleCompras_Productos 
        FOREIGN KEY (ProductoID) REFERENCES dbo.Productos(ProductoID),
    CONSTRAINT CK_DetalleCompras_Valores 
        CHECK (Cantidad > 0 AND CostoUnitario > 0 AND ValorLinea > 0)
);
GO

CREATE TABLE dbo.Devoluciones (
    DevolucionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    DetalleVentaID BIGINT NOT NULL,
    FechaDevolucion DATE NOT NULL,
    CantidadDevuelta INT NOT NULL,
    Motivo VARCHAR(100) NOT NULL,
    ValorDevuelto DECIMAL(14,2) NOT NULL,
    CONSTRAINT FK_Devoluciones_DetalleVentas 
        FOREIGN KEY (DetalleVentaID) REFERENCES dbo.DetalleVentas(DetalleVentaID),
    CONSTRAINT CK_Devoluciones_Cantidad CHECK (CantidadDevuelta > 0),
    CONSTRAINT CK_Devoluciones_Valor CHECK (ValorDevuelto > 0)
);
GO

CREATE TABLE dbo.MetasComerciales (
    MetaID BIGINT IDENTITY(1,1) PRIMARY KEY,
    Anio SMALLINT NOT NULL,
    Mes TINYINT NOT NULL,
    TiendaID INT NOT NULL,
    CategoriaID INT NOT NULL,
    ValorMeta DECIMAL(14,2) NOT NULL,
    CONSTRAINT FK_Metas_Tiendas 
        FOREIGN KEY (TiendaID) REFERENCES dbo.Tiendas(TiendaID),
    CONSTRAINT FK_Metas_Categorias 
        FOREIGN KEY (CategoriaID) REFERENCES dbo.Categorias(CategoriaID),
    CONSTRAINT UQ_Metas UNIQUE (Anio, Mes, TiendaID, CategoriaID),
    CONSTRAINT CK_Metas_Mes CHECK (Mes BETWEEN 1 AND 12),
    CONSTRAINT CK_Metas_Valor CHECK (ValorMeta > 0)
);
GO