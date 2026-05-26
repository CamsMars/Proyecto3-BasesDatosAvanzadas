USE BI_DW;
GO

CREATE OR ALTER PROCEDURE dbo.CargarFactVentas
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;
    DECLARE @Rechazados INT = 0;

    BEGIN TRY

        SELECT @Leidos = COUNT(*)
        FROM BI_Staging.dbo.stg_Ventas;

        SELECT @Rechazados = COUNT(*)
        FROM BI_Staging.dbo.stg_Ventas sv
        LEFT JOIN dbo.DimFecha df
            ON df.Fecha = sv.FechaVenta
        LEFT JOIN dbo.DimCliente dc
            ON dc.ClienteID_OLTP = sv.ClienteID_OLTP
        LEFT JOIN dbo.DimProducto dp
            ON dp.ProductoID_OLTP = sv.ProductoID_OLTP
        LEFT JOIN dbo.DimTienda dt
            ON dt.TiendaID_OLTP = sv.TiendaID_OLTP
        LEFT JOIN dbo.DimVendedor dv
            ON dv.VendedorID_OLTP = sv.VendedorID_OLTP
        LEFT JOIN dbo.DimCanalVenta dcv
            ON dcv.CanalVentaID_OLTP = sv.CanalVentaID_OLTP
        WHERE sv.EsValido = 0
           OR df.FechaKey IS NULL
           OR dc.ClienteKey IS NULL
           OR dp.ProductoKey IS NULL
           OR dt.TiendaKey IS NULL
           OR dv.VendedorKey IS NULL
           OR dcv.CanalVentaKey IS NULL;

        INSERT INTO dbo.FactVentas
        (
            DetalleVentaID_OLTP,
            VentaID_OLTP,
            NumeroFactura,
            FechaKey,
            ClienteKey,
            ProductoKey,
            TiendaKey,
            VendedorKey,
            CanalVentaKey,
            PromocionKey,
            Cantidad,
            PrecioUnitario,
            CostoUnitario,
            ValorVenta,
            CostoTotal,
            UtilidadBruta
        )
        SELECT
            sv.DetalleVentaID_OLTP,
            sv.VentaID_OLTP,
            sv.NumeroFactura,
            df.FechaKey,
            dc.ClienteKey,
            dp.ProductoKey,
            dt.TiendaKey,
            dv.VendedorKey,
            dcv.CanalVentaKey,
            1 AS PromocionKey,
            sv.Cantidad,
            sv.PrecioUnitario,
            sv.CostoUnitario,
            sv.ValorVenta,
            sv.CostoTotal,
            sv.UtilidadBruta
        FROM BI_Staging.dbo.stg_Ventas sv
        INNER JOIN dbo.DimFecha df
            ON df.Fecha = sv.FechaVenta
        INNER JOIN dbo.DimCliente dc
            ON dc.ClienteID_OLTP = sv.ClienteID_OLTP
        INNER JOIN dbo.DimProducto dp
            ON dp.ProductoID_OLTP = sv.ProductoID_OLTP
        INNER JOIN dbo.DimTienda dt
            ON dt.TiendaID_OLTP = sv.TiendaID_OLTP
        INNER JOIN dbo.DimVendedor dv
            ON dv.VendedorID_OLTP = sv.VendedorID_OLTP
        INNER JOIN dbo.DimCanalVenta dcv
            ON dcv.CanalVentaID_OLTP = sv.CanalVentaID_OLTP
        WHERE sv.EsValido = 1
          AND NOT EXISTS (
                SELECT 1
                FROM dbo.FactVentas fv
                WHERE fv.DetalleVentaID_OLTP = sv.DetalleVentaID_OLTP
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
            'CargarFactVentas',
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
            'CargarFactVentas',
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

CREATE OR ALTER PROCEDURE dbo.CargarFactInventarioDiario
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;
    DECLARE @Rechazados INT = 0;

    BEGIN TRY

        SELECT @Leidos = COUNT(*)
        FROM BI_Staging.dbo.stg_Inventario;

        SELECT @Rechazados = COUNT(*)
        FROM BI_Staging.dbo.stg_Inventario si
        LEFT JOIN dbo.DimFecha df
            ON df.Fecha = si.FechaInventario
        LEFT JOIN dbo.DimProducto dp
            ON dp.ProductoID_OLTP = si.ProductoID_OLTP
        LEFT JOIN dbo.DimTienda dt
            ON dt.TiendaID_OLTP = si.TiendaID_OLTP
        WHERE si.EsValido = 0
           OR df.FechaKey IS NULL
           OR dp.ProductoKey IS NULL
           OR dt.TiendaKey IS NULL;

        INSERT INTO dbo.FactInventarioDiario
        (
            InventarioID_OLTP,
            FechaKey,
            ProductoKey,
            TiendaKey,
            StockInicial,
            Entradas,
            Salidas,
            StockFinal
        )
        SELECT
            si.InventarioID_OLTP,
            df.FechaKey,
            dp.ProductoKey,
            dt.TiendaKey,
            si.StockInicial,
            si.Entradas,
            si.Salidas,
            si.StockFinal
        FROM BI_Staging.dbo.stg_Inventario si
        INNER JOIN dbo.DimFecha df
            ON df.Fecha = si.FechaInventario
        INNER JOIN dbo.DimProducto dp
            ON dp.ProductoID_OLTP = si.ProductoID_OLTP
        INNER JOIN dbo.DimTienda dt
            ON dt.TiendaID_OLTP = si.TiendaID_OLTP
        WHERE si.EsValido = 1
          AND NOT EXISTS (
                SELECT 1
                FROM dbo.FactInventarioDiario fi
                WHERE fi.InventarioID_OLTP = si.InventarioID_OLTP
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
            'CargarFactInventarioDiario',
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
            'CargarFactInventarioDiario',
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

CREATE OR ALTER PROCEDURE dbo.CargarFactMetasComerciales
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;
    DECLARE @Rechazados INT = 0;

    BEGIN TRY

        SELECT @Leidos = COUNT(*)
        FROM BI_Staging.dbo.stg_Metas;

        SELECT @Rechazados = COUNT(*)
        FROM BI_Staging.dbo.stg_Metas sm
        LEFT JOIN dbo.DimFecha df
            ON df.Fecha = sm.FechaMeta
        LEFT JOIN dbo.DimTienda dt
            ON dt.TiendaID_OLTP = sm.TiendaID_OLTP
        LEFT JOIN BI_OLTP.dbo.Categorias c
            ON c.CategoriaID = sm.CategoriaID_OLTP
        WHERE sm.EsValido = 0
           OR df.FechaKey IS NULL
           OR dt.TiendaKey IS NULL
           OR c.CategoriaID IS NULL;

        INSERT INTO dbo.FactMetasComerciales
        (
            MetaID_OLTP,
            FechaKey,
            TiendaKey,
            CategoriaID_OLTP,
            NombreCategoria,
            ValorMeta
        )
        SELECT
            sm.MetaID_OLTP,
            df.FechaKey,
            dt.TiendaKey,
            sm.CategoriaID_OLTP,
            c.NombreCategoria,
            sm.ValorMeta
        FROM BI_Staging.dbo.stg_Metas sm
        INNER JOIN dbo.DimFecha df
            ON df.Fecha = sm.FechaMeta
        INNER JOIN dbo.DimTienda dt
            ON dt.TiendaID_OLTP = sm.TiendaID_OLTP
        INNER JOIN BI_OLTP.dbo.Categorias c
            ON c.CategoriaID = sm.CategoriaID_OLTP
        WHERE sm.EsValido = 1
          AND NOT EXISTS (
                SELECT 1
                FROM dbo.FactMetasComerciales fm
                WHERE fm.MetaID_OLTP = sm.MetaID_OLTP
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
            'CargarFactMetasComerciales',
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
            'CargarFactMetasComerciales',
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

CREATE OR ALTER PROCEDURE dbo.CargarFactDevoluciones
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;
    DECLARE @Rechazados INT = 0;

    BEGIN TRY

        SELECT @Leidos = COUNT(*)
        FROM BI_Staging.dbo.stg_Devoluciones;

        SELECT @Rechazados = COUNT(*)
        FROM BI_Staging.dbo.stg_Devoluciones sd
        LEFT JOIN dbo.DimFecha df
            ON df.Fecha = sd.FechaDevolucion
        LEFT JOIN dbo.DimCliente dc
            ON dc.ClienteID_OLTP = sd.ClienteID_OLTP
        LEFT JOIN dbo.DimProducto dp
            ON dp.ProductoID_OLTP = sd.ProductoID_OLTP
        LEFT JOIN dbo.DimTienda dt
            ON dt.TiendaID_OLTP = sd.TiendaID_OLTP
        WHERE sd.EsValido = 0
           OR df.FechaKey IS NULL
           OR dc.ClienteKey IS NULL
           OR dp.ProductoKey IS NULL
           OR dt.TiendaKey IS NULL;

        INSERT INTO dbo.FactDevoluciones
        (
            DevolucionID_OLTP,
            DetalleVentaID_OLTP,
            FechaKey,
            ClienteKey,
            ProductoKey,
            TiendaKey,
            CantidadDevuelta,
            Motivo,
            ValorDevuelto
        )
        SELECT
            sd.DevolucionID_OLTP,
            sd.DetalleVentaID_OLTP,
            df.FechaKey,
            dc.ClienteKey,
            dp.ProductoKey,
            dt.TiendaKey,
            sd.CantidadDevuelta,
            sd.Motivo,
            sd.ValorDevuelto
        FROM BI_Staging.dbo.stg_Devoluciones sd
        INNER JOIN dbo.DimFecha df
            ON df.Fecha = sd.FechaDevolucion
        INNER JOIN dbo.DimCliente dc
            ON dc.ClienteID_OLTP = sd.ClienteID_OLTP
        INNER JOIN dbo.DimProducto dp
            ON dp.ProductoID_OLTP = sd.ProductoID_OLTP
        INNER JOIN dbo.DimTienda dt
            ON dt.TiendaID_OLTP = sd.TiendaID_OLTP
        WHERE sd.EsValido = 1
          AND NOT EXISTS (
                SELECT 1
                FROM dbo.FactDevoluciones fd
                WHERE fd.DevolucionID_OLTP = sd.DevolucionID_OLTP
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
            'CargarFactDevoluciones',
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
            'CargarFactDevoluciones',
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

CREATE OR ALTER PROCEDURE dbo.CargarFactCompras
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;
    DECLARE @Rechazados INT = 0;

    BEGIN TRY

        SELECT @Leidos = COUNT(*)
        FROM BI_Staging.dbo.stg_Compras;

        SELECT @Rechazados = COUNT(*)
        FROM BI_Staging.dbo.stg_Compras sc
        LEFT JOIN dbo.DimFecha df
            ON df.Fecha = sc.FechaCompra
        LEFT JOIN dbo.DimProducto dp
            ON dp.ProductoID_OLTP = sc.ProductoID_OLTP
        LEFT JOIN dbo.DimProveedor dpr
            ON dpr.ProveedorID_OLTP = sc.ProveedorID_OLTP
        LEFT JOIN dbo.DimTienda dt
            ON dt.TiendaID_OLTP = sc.TiendaID_OLTP
        WHERE sc.EsValido = 0
           OR df.FechaKey IS NULL
           OR dp.ProductoKey IS NULL
           OR dpr.ProveedorKey IS NULL
           OR dt.TiendaKey IS NULL;

        INSERT INTO dbo.FactCompras
        (
            DetalleCompraID_OLTP,
            CompraID_OLTP,
            NumeroOrden,
            FechaKey,
            ProductoKey,
            ProveedorKey,
            TiendaKey,
            Cantidad,
            CostoUnitario,
            ValorCompra
        )
        SELECT
            sc.DetalleCompraID_OLTP,
            sc.CompraID_OLTP,
            sc.NumeroOrden,
            df.FechaKey,
            dp.ProductoKey,
            dpr.ProveedorKey,
            dt.TiendaKey,
            sc.Cantidad,
            sc.CostoUnitario,
            sc.ValorCompra
        FROM BI_Staging.dbo.stg_Compras sc
        INNER JOIN dbo.DimFecha df
            ON df.Fecha = sc.FechaCompra
        INNER JOIN dbo.DimProducto dp
            ON dp.ProductoID_OLTP = sc.ProductoID_OLTP
        INNER JOIN dbo.DimProveedor dpr
            ON dpr.ProveedorID_OLTP = sc.ProveedorID_OLTP
        INNER JOIN dbo.DimTienda dt
            ON dt.TiendaID_OLTP = sc.TiendaID_OLTP
        WHERE sc.EsValido = 1
          AND NOT EXISTS (
                SELECT 1
                FROM dbo.FactCompras fc
                WHERE fc.DetalleCompraID_OLTP = sc.DetalleCompraID_OLTP
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
            'CargarFactCompras',
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
            'CargarFactCompras',
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

;WITH FechasFaltantes AS (
    SELECT DISTINCT
        sd.FechaDevolucion AS Fecha
    FROM BI_Staging.dbo.stg_Devoluciones sd
    LEFT JOIN dbo.DimFecha df
        ON df.Fecha = sd.FechaDevolucion
    WHERE df.FechaKey IS NULL
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
    CONVERT(INT, FORMAT(Fecha, 'yyyyMMdd')),
    Fecha,
    YEAR(Fecha),
    DATEPART(QUARTER, Fecha),
    MONTH(Fecha),
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
    END,
    DATEPART(WEEK, Fecha),
    DAY(Fecha),
    CASE DATEPART(WEEKDAY, Fecha)
        WHEN 1 THEN 'Domingo'
        WHEN 2 THEN 'Lunes'
        WHEN 3 THEN 'Martes'
        WHEN 4 THEN 'Miercoles'
        WHEN 5 THEN 'Jueves'
        WHEN 6 THEN 'Viernes'
        ELSE 'Sabado'
    END,
    CASE 
        WHEN DATEPART(WEEKDAY, Fecha) IN (1,7) THEN 1 
        ELSE 0 
    END
FROM FechasFaltantes;
GO

EXEC dbo.CargarFactVentas;
EXEC dbo.CargarFactInventarioDiario;
EXEC dbo.CargarFactMetasComerciales;
EXEC dbo.CargarFactDevoluciones;
EXEC dbo.CargarFactCompras;
GO