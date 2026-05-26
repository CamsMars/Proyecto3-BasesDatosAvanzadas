USE BI_DW;
GO

CREATE OR ALTER PROCEDURE dbo.CargarDimFecha
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;

    BEGIN TRY

        ;WITH N AS (
            SELECT TOP (731)
                ROW_NUMBER() OVER (ORDER BY a.n, b.n, c.n) - 1 AS Num
            FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) a(n)
            CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) b(n)
            CROSS JOIN (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) c(n)
        ),
        Fechas AS (
            SELECT 
                DATEADD(DAY, Num, CAST('2023-01-01' AS DATE)) AS Fecha
            FROM N
            WHERE DATEADD(DAY, Num, CAST('2023-01-01' AS DATE)) <= CAST('2024-12-31' AS DATE)
        )
        INSERT INTO dbo.DimFecha
        (
            FechaKey,
            Fecha,
            Anio,
            Trimestre,
            Mes,
            NombreMes,
            Semana,
            Dia,
            NombreDia,
            EsFinSemana
        )
        SELECT
            CONVERT(INT, FORMAT(Fecha, 'yyyyMMdd')) AS FechaKey,
            Fecha,
            YEAR(Fecha) AS Anio,
            DATEPART(QUARTER, Fecha) AS Trimestre,
            MONTH(Fecha) AS Mes,
            CASE MONTH(Fecha)
                WHEN 1 THEN 'Enero'
                WHEN 2 THEN 'Febrero'
                WHEN 3 THEN 'Marzo'
                WHEN 4 THEN 'Abril'
                WHEN 5 THEN 'Mayo'
                WHEN 6 THEN 'Junio'
                WHEN 7 THEN 'Julio'
                WHEN 8 THEN 'Agosto'
                WHEN 9 THEN 'Septiembre'
                WHEN 10 THEN 'Octubre'
                WHEN 11 THEN 'Noviembre'
                ELSE 'Diciembre'
            END AS NombreMes,
            DATEPART(WEEK, Fecha) AS Semana,
            DAY(Fecha) AS Dia,
            CASE DATEPART(WEEKDAY, Fecha)
                WHEN 1 THEN 'Domingo'
                WHEN 2 THEN 'Lunes'
                WHEN 3 THEN 'Martes'
                WHEN 4 THEN 'Miercoles'
                WHEN 5 THEN 'Jueves'
                WHEN 6 THEN 'Viernes'
                ELSE 'Sabado'
            END AS NombreDia,
            CASE 
                WHEN DATEPART(WEEKDAY, Fecha) IN (1,7) THEN 1 
                ELSE 0 
            END AS EsFinSemana
        FROM Fechas f
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.DimFecha df
            WHERE df.Fecha = f.Fecha
        );

        SET @Cargados = @@ROWCOUNT;
        SET @Leidos = 731;

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimFecha',
            @Inicio,
            SYSDATETIME(),
            'OK',
            @Leidos,
            @Cargados,
            0,
            NULL
        );

    END TRY
    BEGIN CATCH

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimFecha',
            @Inicio,
            SYSDATETIME(),
            'ERROR',
            @Leidos,
            @Cargados,
            0,
            ERROR_MESSAGE()
        );

        THROW;

    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.CargarDimCliente
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;
    DECLARE @Rechazados INT = 0;

    BEGIN TRY

        SELECT @Leidos = COUNT(*)
        FROM BI_Staging.dbo.stg_Clientes;

        SELECT @Rechazados = COUNT(*)
        FROM BI_Staging.dbo.stg_Clientes
        WHERE EsValido = 0 OR EsDuplicado = 1;

        MERGE dbo.DimCliente AS destino
        USING (
            SELECT
                ClienteID_OLTP,
                Documento,
                NombreCompleto,
                Genero,
                Ciudad,
                Departamento,
                Region,
                Segmento,
                Email,
                FechaRegistro
            FROM BI_Staging.dbo.stg_Clientes
            WHERE EsValido = 1
              AND EsDuplicado = 0
        ) AS origen
        ON destino.ClienteID_OLTP = origen.ClienteID_OLTP

        WHEN MATCHED THEN
            UPDATE SET
                destino.Documento = origen.Documento,
                destino.NombreCompleto = origen.NombreCompleto,
                destino.Genero = origen.Genero,
                destino.Ciudad = origen.Ciudad,
                destino.Departamento = origen.Departamento,
                destino.Region = origen.Region,
                destino.Segmento = origen.Segmento,
                destino.Email = origen.Email,
                destino.FechaRegistro = origen.FechaRegistro

        WHEN NOT MATCHED THEN
            INSERT
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
                FechaRegistro
            )
            VALUES
            (
                origen.ClienteID_OLTP,
                origen.Documento,
                origen.NombreCompleto,
                origen.Genero,
                origen.Ciudad,
                origen.Departamento,
                origen.Region,
                origen.Segmento,
                origen.Email,
                origen.FechaRegistro
            );

        SET @Cargados = @@ROWCOUNT;

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimCliente',
            @Inicio,
            SYSDATETIME(),
            'OK',
            @Leidos,
            @Cargados,
            @Rechazados,
            NULL
        );

    END TRY
    BEGIN CATCH

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimCliente',
            @Inicio,
            SYSDATETIME(),
            'ERROR',
            @Leidos,
            @Cargados,
            @Rechazados,
            ERROR_MESSAGE()
        );

        THROW;

    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.CargarDimProveedor
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;

    BEGIN TRY

        SELECT @Leidos = COUNT(*)
        FROM BI_OLTP.dbo.Proveedores;

        MERGE dbo.DimProveedor AS destino
        USING (
            SELECT
                ProveedorID,
                NIT,
                UPPER(NombreProveedor) AS NombreProveedor,
                Ciudad,
                Departamento,
                Email
            FROM BI_OLTP.dbo.Proveedores
        ) AS origen
        ON destino.ProveedorID_OLTP = origen.ProveedorID

        WHEN MATCHED THEN
            UPDATE SET
                destino.NIT = origen.NIT,
                destino.NombreProveedor = origen.NombreProveedor,
                destino.Ciudad = origen.Ciudad,
                destino.Departamento = origen.Departamento,
                destino.Email = origen.Email

        WHEN NOT MATCHED THEN
            INSERT
            (
                ProveedorID_OLTP,
                NIT,
                NombreProveedor,
                Ciudad,
                Departamento,
                Email
            )
            VALUES
            (
                origen.ProveedorID,
                origen.NIT,
                origen.NombreProveedor,
                origen.Ciudad,
                origen.Departamento,
                origen.Email
            );

        SET @Cargados = @@ROWCOUNT;

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimProveedor',
            @Inicio,
            SYSDATETIME(),
            'OK',
            @Leidos,
            @Cargados,
            0,
            NULL
        );

    END TRY
    BEGIN CATCH

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimProveedor',
            @Inicio,
            SYSDATETIME(),
            'ERROR',
            @Leidos,
            @Cargados,
            0,
            ERROR_MESSAGE()
        );

        THROW;

    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.CargarDimProducto
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;
    DECLARE @Rechazados INT = 0;

    BEGIN TRY

        SELECT @Leidos = COUNT(*)
        FROM BI_Staging.dbo.stg_Productos;

        SELECT @Rechazados = COUNT(*)
        FROM BI_Staging.dbo.stg_Productos
        WHERE EsValido = 0;

        MERGE dbo.DimProducto AS destino
        USING (
            SELECT
                ProductoID_OLTP,
                SKU,
                NombreProducto,
                CategoriaID_OLTP,
                NombreCategoria,
                ProveedorID_OLTP,
                NombreProveedor,
                CostoUnitario,
                PrecioVenta,
                MargenUnitario
            FROM BI_Staging.dbo.stg_Productos
            WHERE EsValido = 1
        ) AS origen
        ON destino.ProductoID_OLTP = origen.ProductoID_OLTP

        WHEN MATCHED THEN
            UPDATE SET
                destino.SKU = origen.SKU,
                destino.NombreProducto = origen.NombreProducto,
                destino.CategoriaID_OLTP = origen.CategoriaID_OLTP,
                destino.NombreCategoria = origen.NombreCategoria,
                destino.ProveedorID_OLTP = origen.ProveedorID_OLTP,
                destino.NombreProveedor = origen.NombreProveedor,
                destino.CostoUnitario = origen.CostoUnitario,
                destino.PrecioVenta = origen.PrecioVenta,
                destino.MargenUnitario = origen.MargenUnitario

        WHEN NOT MATCHED THEN
            INSERT
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
                MargenUnitario
            )
            VALUES
            (
                origen.ProductoID_OLTP,
                origen.SKU,
                origen.NombreProducto,
                origen.CategoriaID_OLTP,
                origen.NombreCategoria,
                origen.ProveedorID_OLTP,
                origen.NombreProveedor,
                origen.CostoUnitario,
                origen.PrecioVenta,
                origen.MargenUnitario
            );

        SET @Cargados = @@ROWCOUNT;

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimProducto',
            @Inicio,
            SYSDATETIME(),
            'OK',
            @Leidos,
            @Cargados,
            @Rechazados,
            NULL
        );

    END TRY
    BEGIN CATCH

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimProducto',
            @Inicio,
            SYSDATETIME(),
            'ERROR',
            @Leidos,
            @Cargados,
            @Rechazados,
            ERROR_MESSAGE()
        );

        THROW;

    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.CargarDimTienda
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;

    BEGIN TRY

        SELECT @Leidos = COUNT(*)
        FROM BI_OLTP.dbo.Tiendas;

        MERGE dbo.DimTienda AS destino
        USING (
            SELECT
                TiendaID,
                NombreTienda,
                Ciudad,
                Departamento,
                Region,
                Direccion
            FROM BI_OLTP.dbo.Tiendas
        ) AS origen
        ON destino.TiendaID_OLTP = origen.TiendaID

        WHEN MATCHED THEN
            UPDATE SET
                destino.NombreTienda = origen.NombreTienda,
                destino.Ciudad = origen.Ciudad,
                destino.Departamento = origen.Departamento,
                destino.Region = origen.Region,
                destino.Direccion = origen.Direccion

        WHEN NOT MATCHED THEN
            INSERT
            (
                TiendaID_OLTP,
                NombreTienda,
                Ciudad,
                Departamento,
                Region,
                Direccion
            )
            VALUES
            (
                origen.TiendaID,
                origen.NombreTienda,
                origen.Ciudad,
                origen.Departamento,
                origen.Region,
                origen.Direccion
            );

        SET @Cargados = @@ROWCOUNT;

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimTienda',
            @Inicio,
            SYSDATETIME(),
            'OK',
            @Leidos,
            @Cargados,
            0,
            NULL
        );

    END TRY
    BEGIN CATCH

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimTienda',
            @Inicio,
            SYSDATETIME(),
            'ERROR',
            @Leidos,
            @Cargados,
            0,
            ERROR_MESSAGE()
        );

        THROW;

    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.CargarDimVendedor
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;

    BEGIN TRY

        SELECT @Leidos = COUNT(*)
        FROM BI_OLTP.dbo.Vendedores;

        MERGE dbo.DimVendedor AS destino
        USING (
            SELECT
                v.VendedorID,
                v.NombreCompleto,
                v.TiendaID,
                t.NombreTienda,
                v.FechaIngreso,
                v.Activo
            FROM BI_OLTP.dbo.Vendedores v
            INNER JOIN BI_OLTP.dbo.Tiendas t
                ON v.TiendaID = t.TiendaID
        ) AS origen
        ON destino.VendedorID_OLTP = origen.VendedorID

        WHEN MATCHED THEN
            UPDATE SET
                destino.NombreCompleto = origen.NombreCompleto,
                destino.TiendaID_OLTP = origen.TiendaID,
                destino.NombreTienda = origen.NombreTienda,
                destino.FechaIngreso = origen.FechaIngreso,
                destino.Activo = origen.Activo

        WHEN NOT MATCHED THEN
            INSERT
            (
                VendedorID_OLTP,
                NombreCompleto,
                TiendaID_OLTP,
                NombreTienda,
                FechaIngreso,
                Activo
            )
            VALUES
            (
                origen.VendedorID,
                origen.NombreCompleto,
                origen.TiendaID,
                origen.NombreTienda,
                origen.FechaIngreso,
                origen.Activo
            );

        SET @Cargados = @@ROWCOUNT;

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimVendedor',
            @Inicio,
            SYSDATETIME(),
            'OK',
            @Leidos,
            @Cargados,
            0,
            NULL
        );

    END TRY
    BEGIN CATCH

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimVendedor',
            @Inicio,
            SYSDATETIME(),
            'ERROR',
            @Leidos,
            @Cargados,
            0,
            ERROR_MESSAGE()
        );

        THROW;

    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.CargarDimCanalVenta
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;

    BEGIN TRY

        SELECT @Leidos = COUNT(*)
        FROM BI_OLTP.dbo.CanalVenta;

        MERGE dbo.DimCanalVenta AS destino
        USING (
            SELECT
                CanalVentaID,
                NombreCanal,
                Activo
            FROM BI_OLTP.dbo.CanalVenta
        ) AS origen
        ON destino.CanalVentaID_OLTP = origen.CanalVentaID

        WHEN MATCHED THEN
            UPDATE SET
                destino.NombreCanal = origen.NombreCanal,
                destino.Activo = origen.Activo

        WHEN NOT MATCHED THEN
            INSERT
            (
                CanalVentaID_OLTP,
                NombreCanal,
                Activo
            )
            VALUES
            (
                origen.CanalVentaID,
                origen.NombreCanal,
                origen.Activo
            );

        SET @Cargados = @@ROWCOUNT;

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimCanalVenta',
            @Inicio,
            SYSDATETIME(),
            'OK',
            @Leidos,
            @Cargados,
            0,
            NULL
        );

    END TRY
    BEGIN CATCH

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimCanalVenta',
            @Inicio,
            SYSDATETIME(),
            'ERROR',
            @Leidos,
            @Cargados,
            0,
            ERROR_MESSAGE()
        );

        THROW;

    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.CargarDimGeografia
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;

    BEGIN TRY

        ;WITH Geo AS (
            SELECT DISTINCT Ciudad, Departamento, Region
            FROM BI_Staging.dbo.stg_Clientes
            WHERE EsValido = 1

            UNION

            SELECT DISTINCT Ciudad, Departamento, Region
            FROM BI_OLTP.dbo.Tiendas
        )
        INSERT INTO dbo.DimGeografia
        (
            Ciudad,
            Departamento,
            Region
        )
        SELECT
            g.Ciudad,
            g.Departamento,
            g.Region
        FROM Geo g
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.DimGeografia dg
            WHERE dg.Ciudad = g.Ciudad
              AND dg.Departamento = g.Departamento
              AND dg.Region = g.Region
        );

        SET @Cargados = @@ROWCOUNT;

        SELECT @Leidos = COUNT(*)
        FROM dbo.DimGeografia;

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimGeografia',
            @Inicio,
            SYSDATETIME(),
            'OK',
            @Leidos,
            @Cargados,
            0,
            NULL
        );

    END TRY
    BEGIN CATCH

        INSERT INTO dbo.ETL_Log
        (
            NombreProceso,
            FechaInicio,
            FechaFin,
            Estado,
            RegistrosLeidos,
            RegistrosCargados,
            RegistrosRechazados,
            MensajeError
        )
        VALUES
        (
            'CargarDimGeografia',
            @Inicio,
            SYSDATETIME(),
            'ERROR',
            @Leidos,
            @Cargados,
            0,
            ERROR_MESSAGE()
        );

        THROW;

    END CATCH
END;
GO

EXEC dbo.CargarDimFecha;
EXEC dbo.CargarDimCliente;
EXEC dbo.CargarDimProveedor;
EXEC dbo.CargarDimProducto;
EXEC dbo.CargarDimTienda;
EXEC dbo.CargarDimVendedor;
EXEC dbo.CargarDimCanalVenta;
EXEC dbo.CargarDimGeografia;
GO