USE BI_Staging;
GO

DROP TABLE IF EXISTS dbo.ext_MetasMensualesCSV;
DROP TABLE IF EXISTS dbo.ext_AjustesInventarioCSV;
GO

CREATE TABLE dbo.ext_MetasMensualesCSV (
    Anio SMALLINT NOT NULL,
    Mes TINYINT NOT NULL,
    TiendaID INT NOT NULL,
    CategoriaID INT NOT NULL,
    ValorMeta DECIMAL(14,2) NOT NULL,
    Fuente VARCHAR(80) NOT NULL
);
GO

CREATE TABLE dbo.ext_AjustesInventarioCSV (
    FechaAjuste DATE NOT NULL,
    TiendaID INT NOT NULL,
    ProductoID INT NOT NULL,
    TipoAjuste VARCHAR(20) NOT NULL,
    CantidadAjuste INT NOT NULL,
    Motivo VARCHAR(150) NOT NULL,
    UsuarioResponsable VARCHAR(100) NOT NULL
);
GO

BULK INSERT dbo.ext_MetasMensualesCSV
FROM 'C:\PROYECTO3_BDA\Fuentes_externas\metas_mensuales.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

BULK INSERT dbo.ext_AjustesInventarioCSV
FROM 'C:\PROYECTO3_BDA\Fuentes_externas\ajustes_inventario.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

SELECT 'ext_MetasMensualesCSV' AS Tabla, COUNT(*) AS Registros
FROM dbo.ext_MetasMensualesCSV

UNION ALL

SELECT 'ext_AjustesInventarioCSV', COUNT(*)
FROM dbo.ext_AjustesInventarioCSV;
GO

SELECT TOP 10 *
FROM dbo.ext_MetasMensualesCSV;
GO

SELECT TOP 10 *
FROM dbo.ext_AjustesInventarioCSV;
GO