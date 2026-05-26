# Proyecto BI - Empresa Minorista Colombiana

## 1. Descripción general

Este repositorio contiene el desarrollo práctico de una solución de Business Intelligence para una empresa minorista colombiana. El proyecto integra una base de datos operacional, una zona intermedia de preparación de datos, un Data Warehouse dimensional y un dashboard en Power BI.

La idea principal fue construir un flujo completo de datos, desde la operación diaria hasta el análisis gerencial. Por eso el proyecto no se limita a crear gráficos, sino que incluye diseño de bases de datos, generación de datos sintéticos, procesos ETL, validaciones, medidas DAX, visualizaciones y evidencias.

La arquitectura general implementada fue:

```text
BI_OLTP → BI_Staging → BI_DW → Power BI
```

El proyecto fue desarrollado con:

- SQL Server 2022
- T-SQL
- Power BI Desktop
- Archivos CSV como fuentes externas
- GitHub para organización y entrega de archivos fuente

---

## 2. Objetivo del proyecto

El objetivo principal fue implementar una solución BI que permitiera transformar datos transaccionales de una empresa minorista en información útil para la toma de decisiones.

La solución permite analizar:

- ventas;
- costos;
- utilidad bruta;
- margen bruto;
- inventario;
- compras;
- devoluciones;
- cumplimiento de metas;
- desempeño de tiendas;
- desempeño de vendedores;
- ventas por canal;
- comportamiento por categoría de producto;
- análisis OLAP por jerarquías.

---

## 3. Arquitectura implementada

La solución está dividida en cuatro capas:

```text
1. BI_OLTP
2. BI_Staging
3. BI_DW
4. Power BI
```

## 3.1 BI_OLTP

`BI_OLTP` representa la base operacional de la empresa. Allí se simulan las operaciones diarias: ventas, compras, clientes, productos, tiendas, vendedores, inventario, devoluciones y metas.

Esta base está normalizada y contiene claves primarias, claves foráneas, restricciones `CHECK`, campos `NOT NULL` y validaciones básicas de integridad.

## 3.2 BI_Staging

`BI_Staging` es la zona intermedia de preparación de datos. En esta etapa los datos se copian desde el OLTP y se preparan antes de llegar al Data Warehouse.

En esta base se realizan procesos como:

- limpieza de datos;
- estandarización de ciudades y departamentos;
- asignación de regiones;
- validación de códigos inexistentes;
- detección de duplicados;
- cálculo de campos derivados;
- marcación de registros válidos o inválidos;
- integración de archivos CSV externos.

## 3.3 BI_DW

`BI_DW` es el Data Warehouse. Se diseñó con un modelo estrella para facilitar el análisis en Power BI.

Contiene dimensiones y tablas de hechos. Las dimensiones describen el contexto de los datos y las tablas de hechos almacenan las métricas principales.

## 3.4 Power BI

Power BI se conectó al Data Warehouse `BI_DW` para construir un dashboard con cinco páginas:

1. Resumen Ejecutivo
2. Análisis de Ventas
3. Inventario
4. Metas y Operación
5. Rentabilidad y OLAP

---

## 4. Estructura del repositorio

```text
Proyecto-BI-Retail-Colombia/

SQL/
   01_resetear_base_de_datos.sql
   02_creacion_oltp.sql
   03_carga_datos_oltp.sql
   04_creacion_staging.sql
   05_procedimientos_staging.sql
   06_creacion_datawarehouse.sql
   07_etl_dimensiones.sql
   08_etl_hechos.sql
   09_etl_validacion.sql
   10_consultas_evidencia.sql
   11_medidas_dax_powerbi.dax
   12_fuentes_externas.sql

PowerBI/
   Proyecto_Retail_Colombia.pbix

Documentacion/
   informe_tecnico.md
   preguntas_sustentacion.md
   decisiones_y_mejoras.md
   diccionario_datos.xlsx
   diagrama_modelo_dimensional.png

Evidencias/
   1_bases_creadas.png
   2_conteos_oltp.png
   3_conteos_staging.png
   4_conteos_dw.png
   5_etl_log.png
   6_validacion_calidad.png
   6_2_validacion_calidad.png
   7_fuentes_externas.png
   8_resumen_ejecutivo.png
   9_analisis_ventas.png
   10_inventario.png
   11_metas_operacion.png
   12_rentabilidad_olap.png

Fuentes_Externas/
   metas_mensuales.csv
   ajustes_inventario.csv
```

---

## 5. Scripts SQL

Los scripts se encuentran en la carpeta `01_SQL`.

## 5.1 Orden de ejecución

Los scripts deben ejecutarse en el siguiente orden:

```text
1. 01_resetear_base_de_datos.sql
2. 02_creacion_oltp.sql
3. 03_carga_datos_oltp.sql
4. 04_creacion_staging.sql
5. 05_procedimientos_staging.sql
6. 06_creacion_datawarehouse.sql
7. 07_etl_dimensiones.sql
8. 08_etl_hechos.sql
9. 09_etl_validacion.sql
10. 10_consultas_evidencia.sql
11. 12_fuentes_externas.sql
```

El archivo `11_medidas_dax_powerbi.dax` no se ejecuta en SQL Server. Ese archivo contiene las medidas DAX que se deben crear dentro de Power BI.

---

## 6. Descripción de los scripts

## 6.1 `01_reset_bases.sql`

Elimina y vuelve a crear las tres bases principales:

- `BI_OLTP`
- `BI_Staging`
- `BI_DW`

Este script se usa cuando se quiere ejecutar el proyecto desde cero.

## 6.2 `02_creacion_oltp.sql`

Crea las tablas operacionales del OLTP con sus claves, restricciones y relaciones.

Tablas principales:

- `Categorias`
- `Proveedores`
- `Productos`
- `Tiendas`
- `Vendedores`
- `Clientes`
- `CanalVenta`
- `Ventas`
- `DetalleVentas`
- `InventarioDiario`
- `Compras`
- `DetalleCompras`
- `Devoluciones`
- `MetasComerciales`

## 6.3 `03_carga_datos_oltp.sql`

Carga datos sintéticos en la base `BI_OLTP`.

Los datos fueron generados con instrucciones basadas en conjuntos, principalmente usando `INSERT INTO ... SELECT` y `CROSS JOIN`, evitando ciclos `WHILE`.

## 6.4 `04_creacion_staging.sql`

Crea las tablas de la zona intermedia `BI_Staging`.

Estas tablas reciben datos del OLTP y contienen campos de control como:

- `EsValido`
- `MensajeValidacion`
- `FechaCargaStaging`

## 6.5 `05_procedimientos_staging.sql`

Crea procedimientos almacenados para cargar datos desde `BI_OLTP` hacia `BI_Staging`.

También realiza transformaciones como:

- limpieza de nulos;
- estandarización;
- validación;
- cálculo de campos derivados.

## 6.6 `06_creacion_dw.sql`

Crea el Data Warehouse `BI_DW` con modelo estrella.

Incluye dimensiones, hechos y la tabla de auditoría `ETL_Log`.

## 6.7 `07_etl_dimensiones.sql`

Crea y ejecuta los procedimientos para cargar dimensiones:

- `CargarDimFecha`
- `CargarDimCliente`
- `CargarDimProveedor`
- `CargarDimProducto`
- `CargarDimTienda`
- `CargarDimVendedor`
- `CargarDimCanalVenta`
- `CargarDimGeografia`

## 6.8 `08_etl_hechos.sql`

Crea y ejecuta los procedimientos para cargar tablas de hechos:

- `CargarFactVentas`
- `CargarFactInventarioDiario`
- `CargarFactMetasComerciales`
- `CargarFactDevoluciones`
- `CargarFactCompras`

También incluye una corrección para completar `DimFecha` con fechas faltantes de devoluciones.

## 6.9 `09_etl_general_validacion.sql`

Crea dos procedimientos principales:

- `EjecutarETLCompleto`
- `ValidarCalidadDatos`

El primero ejecuta el flujo general del ETL. El segundo valida la calidad de los datos y compara registros entre Staging y DW.

## 6.10 `10_consultas_evidencia.sql`

Contiene consultas para generar evidencias del proyecto:

- bases creadas;
- conteos OLTP;
- conteos Staging;
- conteos DW;
- ETL_Log;
- validaciones;
- análisis de ventas, inventario y devoluciones.

## 6.11 `11_medidas_dax_powerbi.dax`

Contiene las medidas DAX utilizadas en Power BI.

## 6.12 `12_fuentes_externas_bulk_insert.sql`

Carga los archivos CSV externos hacia tablas auxiliares en `BI_Staging` mediante `BULK INSERT`.

---

## 7. Datos generados

El proyecto genera datos sintéticos realistas para Colombia.

Volúmenes principales:

| Entidad | Registros |
|---|---:|
| Categorías | 10 |
| Proveedores | 20 |
| Tiendas | 10 |
| Vendedores | 20 |
| Clientes | 1.000 |
| Productos | 200 |
| Ventas | 50.000 |
| Líneas de venta | 150.000 |
| Inventario diario | 730.000 |
| Compras | 2.000 |
| Líneas de compra | 6.000 |
| Devoluciones | 1.000 |
| Metas comerciales | 2.400 |

---

## 8. Fuentes externas CSV

El proyecto incluye dos archivos CSV:

```text
05_Fuentes_Externas/metas_mensuales.csv
05_Fuentes_Externas/ajustes_inventario.csv
```

## 8.1 `metas_mensuales.csv`

Este archivo representa metas comerciales por:

- año;
- mes;
- tienda;
- categoría;
- valor meta.

La idea es simular información que podría venir desde un archivo externo manejado por el área comercial.

## 8.2 `ajustes_inventario.csv`

Este archivo representa ajustes manuales de inventario, como:

- entradas;
- salidas;
- mermas;
- productos vencidos;
- diferencias de conteo;
- correcciones de recepción.

## 8.3 Carga de CSV en SQL Server

Los archivos se cargan mediante el script:

```text
01_SQL/12_fuentes_externas_bulk_insert.sql
```

Antes de ejecutarlo, los archivos deben estar disponibles en la ruta local del servidor SQL:

```text
C:\BI_Proyecto\05_Fuentes_Externas\
```

Si se usa otra ruta, se debe modificar la variable `@RutaBase` dentro del script.

---

## 9. Modelo dimensional

## 9.1 Dimensiones

El Data Warehouse contiene las siguientes dimensiones:

- `DimFecha`
- `DimCliente`
- `DimProducto`
- `DimTienda`
- `DimVendedor`
- `DimProveedor`
- `DimCanalVenta`
- `DimPromocion`
- `DimGeografia`

## 9.2 Tablas de hechos

El Data Warehouse contiene las siguientes tablas de hechos:

- `FactVentas`
- `FactInventarioDiario`
- `FactMetasComerciales`
- `FactDevoluciones`
- `FactCompras`

## 9.3 Granularidad

| Tabla de hechos | Granularidad |
|---|---|
| FactVentas | Línea de venta |
| FactInventarioDiario | Producto, tienda y día |
| FactMetasComerciales | Meta mensual por tienda y categoría |
| FactDevoluciones | Devolución asociada a línea de venta |
| FactCompras | Línea de compra |

---

## 10. Power BI

El archivo `.pbix` se encuentra en:

```text
02_PowerBI/Proyecto_BI_Retail_Colombia.pbix
```

El dashboard contiene cinco páginas:

## 10.1 Resumen Ejecutivo

Incluye KPIs principales:

- Total Ventas
- Utilidad Bruta
- Margen Bruto %
- Cumplimiento Meta %
- Ticket Promedio

También incluye análisis de ventas por mes, categoría y tienda.

## 10.2 Análisis de Ventas

Permite analizar ventas por:

- vendedor;
- canal;
- segmento;
- categoría;
- tienda;
- región.

## 10.3 Inventario

Analiza:

- inventario promedio;
- entradas;
- salidas;
- stock mínimo;
- productos con menor inventario;
- rotación de inventario en unidades.

## 10.4 Metas y Operación

Compara ventas reales contra metas comerciales y analiza:

- brecha de metas;
- cumplimiento por tienda;
- devoluciones;
- compras por proveedor.

## 10.5 Rentabilidad y OLAP

Analiza:

- ventas;
- costos;
- utilidad bruta;
- margen bruto;
- ventas por categoría;
- utilidad por tienda;
- matriz OLAP con jerarquías de tiempo, región, tienda y categoría.

---

## 11. Medidas DAX principales

Algunas de las medidas creadas fueron:

- Total Ventas
- Total Costo
- Utilidad Bruta
- Margen Bruto %
- Ventas Año Anterior
- Crecimiento Ventas %
- Total Meta
- Cumplimiento Meta %
- Brecha Meta
- Ranking Productos
- Ranking Tiendas
- Promedio Móvil Ventas 3 meses
- Participación % por Categoría
- Ticket Promedio
- Inventario Promedio
- Rotación de Inventario Unidades
- Entradas Totales
- Salidas Totales
- Stock Mínimo
- Total Devoluciones
- Tasa Devolución %
- Total Compras
- Unidades Compradas

---

## 12. Evidencias

La carpeta `04_Evidencias` contiene capturas que demuestran el funcionamiento del proyecto.

Evidencias SQL:

- bases creadas;
- conteos OLTP;
- conteos Staging;
- conteos DW;
- ETL_Log;
- validación de calidad;
- carga de fuentes externas.

Evidencias Power BI:

- modelo de relaciones;
- página de resumen ejecutivo;
- página de análisis de ventas;
- página de inventario;
- página de metas y operación;
- página de rentabilidad y OLAP.

---

## 13. Azure

El proyecto fue construido inicialmente en ambiente local. Para replicarlo en Azure, se recomienda:

1. Crear una máquina virtual en Azure con Windows Server.
2. Instalar SQL Server y SQL Server Management Studio.
3. Descargar o copiar el repositorio dentro de la VM.
4. Ejecutar los scripts SQL en orden.
5. Copiar los CSV a la ruta esperada por el script de `BULK INSERT`.
6. Validar los conteos.
7. Conectar Power BI al Data Warehouse.
8. Publicar el reporte en Power BI Service.
9. Entregar IP, usuario, contraseña y URL del reporte por un canal privado.

No se deben publicar credenciales en GitHub.

---

## 14. Notas importantes

- El archivo `.dax` no se ejecuta en SQL Server.
- Los CSV deben existir físicamente en la ruta configurada para poder usar `BULK INSERT`.
- Las credenciales de Azure no deben subirse al repositorio.
- La tabla `ETL_Log` puede aumentar registros si se ejecutan de nuevo procedimientos de validación o carga.
- El inventario no debe sumarse directamente a través del tiempo, porque es una medida semi-aditiva.
- El cumplimiento de metas quedó bajo porque las metas generadas fueron altas frente a las ventas sintéticas. No se modificó este resultado para no alterar el análisis.

```#   P r o y e c t o 3 - B a s e s D a t o s A v a n z a d a s  
 