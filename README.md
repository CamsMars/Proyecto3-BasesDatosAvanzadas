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

- Ventas.
- Costos.
- Utilidad bruta.
- Margen bruto.
- Inventario.
- Compras.
- Devoluciones.
- Cumplimiento de metas.
- Desempeño de tiendas.
- Desempeño de vendedores.
- Ventas por canal.
- Comportamiento por categoría de producto.
- Análisis OLAP por jerarquías.

---

## 3. Arquitectura implementada

La solución está dividida en cuatro capas:

```text
1. BI_OLTP
2. BI_Staging
3. BI_DW
4. Power BI
```

### 3.1 BI_OLTP

`BI_OLTP` representa la base operacional de la empresa. Allí se simulan las operaciones diarias: ventas, compras, clientes, productos, tiendas, vendedores, inventario, devoluciones y metas.

Esta base está normalizada y contiene claves primarias, claves foráneas, restricciones `CHECK`, campos `NOT NULL` y validaciones básicas de integridad.

### 3.2 BI_Staging

`BI_Staging` es la zona intermedia de preparación de datos. En esta etapa los datos se copian desde el OLTP y se preparan antes de llegar al Data Warehouse.

En esta base se realizan procesos como:

- Limpieza de datos.
- Estandarización de ciudades y departamentos.
- Asignación de regiones.
- Validación de códigos inexistentes.
- Detección de duplicados.
- Cálculo de campos derivados.
- Marcación de registros válidos o inválidos.
- Integración de archivos CSV externos.

### 3.3 BI_DW

`BI_DW` es el Data Warehouse. Se diseñó con un modelo estrella para facilitar el análisis en Power BI.

Contiene dimensiones y tablas de hechos. Las dimensiones describen el contexto de los datos y las tablas de hechos almacenan las métricas principales.

### 3.4 Power BI

Power BI se conectó al Data Warehouse `BI_DW` para construir un dashboard con cinco páginas:

1. Resumen Ejecutivo.
2. Análisis de Ventas.
3. Inventario.
4. Metas y Operación.
5. Rentabilidad y OLAP.

---

## 4. Estructura del repositorio

```text
PROYECTO3_BDA/

SQL/
   1_resetear_base_de_datos.sql
   2_creacion_oltp.sql
   3_cargar_datos_oltp.sql
   4_creacion_staging.sql
   5_procedimientos_staging.sql
   6_creacion_datawarehouse.sql
   7_etl_dimensiones.sql
   8_etl_hechos.sql
   9_etl_validacion.sql
   10_consultas_evidencias.sql
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
   13_azure_bases_creadas.png
   14_azure_conteos_dw.png
   15_azure_fuentes_externas.png
   16_azure_vm.png

Fuentes_externas/
   metas_mensuales.csv
   ajustes_inventario.csv

README.md
```

---

## 5. Scripts SQL

Los scripts se encuentran en la carpeta `SQL`.

### 5.1 Orden de ejecución

Los scripts deben ejecutarse en el siguiente orden:

```text
1. 1_resetear_base_de_datos.sql
2. 2_creacion_oltp.sql
3. 3_cargar_datos_oltp.sql
4. 4_creacion_staging.sql
5. 5_procedimientos_staging.sql
6. 6_creacion_datawarehouse.sql
7. 7_etl_dimensiones.sql
8. 8_etl_hechos.sql
9. 9_etl_validacion.sql
10. 10_consultas_evidencias.sql
11. 12_fuentes_externas.sql
```

El archivo `11_medidas_dax_powerbi.dax` no se ejecuta en SQL Server. Ese archivo contiene las medidas DAX que se deben crear dentro de Power BI.

---

## 6. Descripción de los scripts

### 6.1 `1_resetear_base_de_datos.sql`

Elimina y vuelve a crear las tres bases principales:

- `BI_OLTP`
- `BI_Staging`
- `BI_DW`

Este script se usa cuando se quiere ejecutar el proyecto desde cero.

### 6.2 `2_creacion_oltp.sql`

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

### 6.3 `3_cargar_datos_oltp.sql`

Carga datos sintéticos en la base `BI_OLTP`.

Los datos fueron generados con instrucciones basadas en conjuntos, principalmente usando `INSERT INTO ... SELECT` y `CROSS JOIN`, evitando ciclos `WHILE`.

### 6.4 `4_creacion_staging.sql`

Crea las tablas de la zona intermedia `BI_Staging`.

Estas tablas reciben datos del OLTP y contienen campos de control como:

- `EsValido`
- `MensajeValidacion`
- `FechaCargaStaging`

### 6.5 `5_procedimientos_staging.sql`

Crea procedimientos almacenados para cargar datos desde `BI_OLTP` hacia `BI_Staging`.

También realiza transformaciones como:

- Limpieza de nulos.
- Estandarización.
- Validación.
- Cálculo de campos derivados.

### 6.6 `6_creacion_datawarehouse.sql`

Crea el Data Warehouse `BI_DW` con modelo estrella.

Incluye dimensiones, hechos y la tabla de auditoría `ETL_Log`.

### 6.7 `7_etl_dimensiones.sql`

Crea y ejecuta los procedimientos para cargar dimensiones:

- `CargarDimFecha`
- `CargarDimCliente`
- `CargarDimProveedor`
- `CargarDimProducto`
- `CargarDimTienda`
- `CargarDimVendedor`
- `CargarDimCanalVenta`
- `CargarDimGeografia`

### 6.8 `8_etl_hechos.sql`

Crea y ejecuta los procedimientos para cargar tablas de hechos:

- `CargarFactVentas`
- `CargarFactInventarioDiario`
- `CargarFactMetasComerciales`
- `CargarFactDevoluciones`
- `CargarFactCompras`

También incluye una corrección para completar `DimFecha` con fechas faltantes de devoluciones.

### 6.9 `9_etl_validacion.sql`

Crea procedimientos generales de ejecución y validación del ETL.

Incluye procesos como:

- Ejecución completa del flujo ETL.
- Validación de calidad de datos.
- Comparación de conteos entre Staging y Data Warehouse.
- Registro de resultados en `ETL_Log`.

### 6.10 `10_consultas_evidencias.sql`

Contiene consultas para generar evidencias del proyecto:

- Bases creadas.
- Conteos OLTP.
- Conteos Staging.
- Conteos DW.
- ETL_Log.
- Validaciones.
- Análisis de ventas, inventario y devoluciones.

### 6.11 `11_medidas_dax_powerbi.dax`

Contiene las medidas DAX utilizadas en Power BI.

Este archivo no se ejecuta en SQL Server. Las medidas deben crearse desde Power BI Desktop, en la opción de nueva medida.

### 6.12 `12_fuentes_externas.sql`

Carga los archivos CSV externos hacia tablas auxiliares en `BI_Staging` mediante `BULK INSERT`.

Los archivos usados son:

- `metas_mensuales.csv`
- `ajustes_inventario.csv`

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
Fuentes_externas/metas_mensuales.csv
Fuentes_externas/ajustes_inventario.csv
```

### 8.1 `metas_mensuales.csv`

Este archivo representa metas comerciales por:

- Año.
- Mes.
- Tienda.
- Categoría.
- Valor meta.

La idea es simular información que podría venir desde un archivo externo manejado por el área comercial.

### 8.2 `ajustes_inventario.csv`

Este archivo representa ajustes manuales de inventario, como:

- Entradas.
- Salidas.
- Mermas.
- Productos vencidos.
- Diferencias de conteo.
- Correcciones de recepción.

### 8.3 Carga de CSV en SQL Server

Los archivos se cargan mediante el script:

```text
SQL/12_fuentes_externas.sql
```

Antes de ejecutarlo, los archivos deben estar disponibles en la ruta local del servidor SQL:

```text
C:\BI_Proyecto\05_Fuentes_Externas\
```

Si se usa otra ruta, se debe modificar la variable `@RutaBase` dentro del script.

Aunque en GitHub los archivos están en la carpeta `Fuentes_externas`, SQL Server necesita que los CSV existan físicamente en una ruta local del servidor donde se ejecuta `BULK INSERT`.

---

## 9. Modelo dimensional

### 9.1 Dimensiones

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

### 9.2 Tablas de hechos

El Data Warehouse contiene las siguientes tablas de hechos:

- `FactVentas`
- `FactInventarioDiario`
- `FactMetasComerciales`
- `FactDevoluciones`
- `FactCompras`

### 9.3 Granularidad

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
PowerBI/Proyecto_Retail_Colombia.pbix
```

El dashboard contiene cinco páginas.

### 10.1 Resumen Ejecutivo

Incluye KPIs principales:

- Total Ventas
- Utilidad Bruta
- Margen Bruto %
- Cumplimiento Meta %
- Ticket Promedio

También incluye análisis de ventas por mes, categoría y tienda.

### 10.2 Análisis de Ventas

Permite analizar ventas por:

- Vendedor.
- Canal.
- Segmento.
- Categoría.
- Tienda.
- Región.

### 10.3 Inventario

Analiza:

- Inventario promedio.
- Entradas.
- Salidas.
- Stock mínimo.
- Productos con menor inventario.
- Rotación de inventario en unidades.

### 10.4 Metas y Operación

Compara ventas reales contra metas comerciales y analiza:

- Brecha de metas.
- Cumplimiento por tienda.
- Devoluciones.
- Compras por proveedor.

### 10.5 Rentabilidad y OLAP

Analiza:

- Ventas.
- Costos.
- Utilidad bruta.
- Margen bruto.
- Ventas por categoría.
- Utilidad por tienda.
- Matriz OLAP con jerarquías de tiempo, región, tienda y categoría.

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

La carpeta `Evidencias` contiene capturas que demuestran el funcionamiento del proyecto en ambiente local y en Azure.

Evidencias SQL locales:

- `1_bases_creadas.png`
- `2_conteos_oltp.png`
- `3_conteos_staging.png`
- `4_conteos_dw.png`
- `5_etl_log.png`
- `6_validacion_calidad.png`
- `6_2_validacion_calidad.png`
- `7_fuentes_externas.png`

Evidencias Power BI:

- `8_resumen_ejecutivo.png`
- `9_analisis_ventas.png`
- `10_inventario.png`
- `11_metas_operacion.png`
- `12_rentabilidad_olap.png`

Evidencias Azure:

- `13_azure_bases_creadas.png`
- `14_azure_conteos_dw.png`
- `15_azure_fuentes_externas.png`
- `16_azure_vm.png`

Las evidencias de Azure muestran que el proyecto fue replicado en una máquina virtual, que las bases `BI_OLTP`, `BI_Staging` y `BI_DW` fueron creadas correctamente, que las tablas de hechos principales contienen los registros esperados y que las fuentes externas CSV fueron cargadas en SQL Server.

---

## 13. Documentación

La carpeta `Documentacion` contiene:

- `informe_tecnico.md`
- `preguntas_sustentacion.md`
- `decisiones_y_mejoras.md`
- `diccionario_datos.xlsx`
- `diagrama_modelo_dimensional.png`

### 13.1 `informe_tecnico.md`

Explica la arquitectura, el diseño de bases, la granularidad, las medidas, el ETL, el modelo dimensional, Power BI y las conclusiones del proyecto.

### 13.2 `preguntas_sustentacion.md`

Contiene preguntas y respuestas posibles para la sustentación del proyecto.

### 13.3 `decisiones_y_mejoras.md`

Registra decisiones tomadas durante el desarrollo, problemas encontrados, correcciones y mejoras aplicadas.

### 13.4 `diccionario_datos.xlsx`

Contiene el diccionario de datos generado a partir de las estructuras de SQL Server.

### 13.5 `diagrama_modelo_dimensional.png`

Contiene la imagen del modelo dimensional construido en Power BI.

---

## 14. Azure

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

La información de acceso a la VM, incluyendo IP pública, usuario y contraseña, se entrega por un canal privado por seguridad.

---

## 15. Notas importantes

- El archivo `.dax` no se ejecuta en SQL Server.
- Los CSV deben existir físicamente en la ruta configurada para poder usar `BULK INSERT`.
- Las credenciales de Azure no están en el repositorio.
- La tabla `ETL_Log` puede aumentar registros si se ejecutan de nuevo procedimientos de validación o carga.
- El inventario no debe sumarse directamente a través del tiempo, porque es una medida semi-aditiva.
- El cumplimiento de metas quedó bajo porque las metas generadas fueron altas frente a las ventas sintéticas. No se modificó este resultado para no alterar el análisis.
