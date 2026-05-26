USE BI_DW;
GO

CREATE OR ALTER PROCEDURE dbo.EjecutarETLCompleto
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @Leidos INT = 0;
    DECLARE @Cargados INT = 0;
    DECLARE @Rechazados INT = 0;

    BEGIN TRY

        EXEC BI_Staging.dbo.sp_CargarStagingCompleto;

        EXEC dbo.CargarDimFecha;
        EXEC dbo.CargarDimCliente;
        EXEC dbo.CargarDimProveedor;
        EXEC dbo.CargarDimProducto;
        EXEC dbo.CargarDimTienda;
        EXEC dbo.CargarDimVendedor;
        EXEC dbo.CargarDimCanalVenta;
        EXEC dbo.CargarDimGeografia;

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

        EXEC dbo.CargarFactVentas;
        EXEC dbo.CargarFactInventarioDiario;
        EXEC dbo.CargarFactMetasComerciales;
        EXEC dbo.CargarFactDevoluciones;
        EXEC dbo.CargarFactCompras;

        SELECT @Cargados =
            (SELECT COUNT(*) FROM dbo.FactVentas)
            + (SELECT COUNT(*) FROM dbo.FactInventarioDiario)
            + (SELECT COUNT(*) FROM dbo.FactMetasComerciales)
            + (SELECT COUNT(*) FROM dbo.FactDevoluciones)
            + (SELECT COUNT(*) FROM dbo.FactCompras);

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
            'EjecutarETLCompleto',
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
            'EjecutarETLCompleto',
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

CREATE OR ALTER PROCEDURE dbo.ValidarCalidadDatos
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2(0) = SYSDATETIME();
    DECLARE @RegistrosLeidos INT = 0;
    DECLARE @RegistrosRechazados INT = 0;

    BEGIN TRY

        SELECT 
            'stg_Clientes' AS Tabla,
            COUNT(*) AS RegistrosInvalidos
        FROM BI_Staging.dbo.stg_Clientes
        WHERE EsValido = 0 OR EsDuplicado = 1

        UNION ALL

        SELECT 
            'stg_Productos',
            COUNT(*)
        FROM BI_Staging.dbo.stg_Productos
        WHERE EsValido = 0

        UNION ALL

        SELECT 
            'stg_Ventas',
            COUNT(*)
        FROM BI_Staging.dbo.stg_Ventas
        WHERE EsValido = 0

        UNION ALL

        SELECT 
            'stg_Inventario',
            COUNT(*)
        FROM BI_Staging.dbo.stg_Inventario
        WHERE EsValido = 0

        UNION ALL

        SELECT 
            'stg_Metas',
            COUNT(*)
        FROM BI_Staging.dbo.stg_Metas
        WHERE EsValido = 0

        UNION ALL

        SELECT 
            'stg_Devoluciones',
            COUNT(*)
        FROM BI_Staging.dbo.stg_Devoluciones
        WHERE EsValido = 0

        UNION ALL

        SELECT 
            'stg_Compras',
            COUNT(*)
        FROM BI_Staging.dbo.stg_Compras
        WHERE EsValido = 0;

        SELECT 
            'Ventas' AS Proceso,
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Ventas WHERE EsValido = 1) AS RegistrosValidosStaging,
            (SELECT COUNT(*) FROM dbo.FactVentas) AS RegistrosDW,
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Ventas WHERE EsValido = 1)
                - (SELECT COUNT(*) FROM dbo.FactVentas) AS Diferencia

        UNION ALL

        SELECT 
            'Inventario',
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Inventario WHERE EsValido = 1),
            (SELECT COUNT(*) FROM dbo.FactInventarioDiario),
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Inventario WHERE EsValido = 1)
                - (SELECT COUNT(*) FROM dbo.FactInventarioDiario)

        UNION ALL

        SELECT 
            'Metas',
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Metas WHERE EsValido = 1),
            (SELECT COUNT(*) FROM dbo.FactMetasComerciales),
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Metas WHERE EsValido = 1)
                - (SELECT COUNT(*) FROM dbo.FactMetasComerciales)

        UNION ALL

        SELECT 
            'Devoluciones',
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Devoluciones WHERE EsValido = 1),
            (SELECT COUNT(*) FROM dbo.FactDevoluciones),
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Devoluciones WHERE EsValido = 1)
                - (SELECT COUNT(*) FROM dbo.FactDevoluciones)

        UNION ALL

        SELECT 
            'Compras',
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Compras WHERE EsValido = 1),
            (SELECT COUNT(*) FROM dbo.FactCompras),
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Compras WHERE EsValido = 1)
                - (SELECT COUNT(*) FROM dbo.FactCompras);

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

        SELECT @RegistrosLeidos =
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Clientes)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Productos)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Ventas)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Inventario)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Metas)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Devoluciones)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Compras);

        SELECT @RegistrosRechazados =
            (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Clientes WHERE EsValido = 0 OR EsDuplicado = 1)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Productos WHERE EsValido = 0)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Ventas WHERE EsValido = 0)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Inventario WHERE EsValido = 0)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Metas WHERE EsValido = 0)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Devoluciones WHERE EsValido = 0)
            + (SELECT COUNT(*) FROM BI_Staging.dbo.stg_Compras WHERE EsValido = 0);

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
            'ValidarCalidadDatos',
            @Inicio,
            SYSDATETIME(),
            'OK',
            @RegistrosLeidos,
            0,
            @RegistrosRechazados,
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
            'ValidarCalidadDatos',
            @Inicio,
            SYSDATETIME(),
            'ERROR',
            @RegistrosLeidos,
            0,
            @RegistrosRechazados,
            ERROR_MESSAGE()
        );

        THROW;

    END CATCH
END;
GO

EXEC dbo.ValidarCalidadDatos;
GO