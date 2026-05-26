# Informe técnico del proyecto BI

## Empresa minorista colombiana

## 1. Introducción

Este proyecto consistió en diseñar e implementar una solución de Business Intelligence para una empresa minorista colombiana. El objetivo fue construir un flujo completo de datos que permitiera pasar de registros operacionales a información analítica útil para la toma de decisiones.

La solución integra tres bases de datos principales:

```text
BI_OLTP → BI_Staging → BI_DW
```

Posteriormente, el Data Warehouse se conectó con Power BI para construir un dashboard analítico.

Desde mi parte práctica, el proyecto se trabajó como una implementación completa. No se trató solamente de hacer visualizaciones, sino de construir una arquitectura BI con datos, ETL, validaciones, modelo dimensional y medidas DAX.

---

## 2. Caso de negocio

La empresa simulada es una cadena minorista con presencia en diferentes ciudades de Colombia. Vende productos de varias categorías y necesita analizar su operación comercial y logística.

El modelo permite responder preguntas como:

- ¿Cuánto se vendió en total?
- ¿Cuánto costaron las ventas?
- ¿Cuál fue la utilidad bruta?
- ¿Cuál fue el margen bruto?
- ¿Qué categorías venden más?
- ¿Qué tiendas tienen mejor desempeño?
- ¿Qué vendedores generan más ventas?
- ¿Qué canales son más importantes?
- ¿Qué tan lejos están las ventas de las metas?
- ¿Qué productos tienen menor inventario?
- ¿Cuáles son los principales motivos de devolución?
- ¿Cuánto se compra por proveedor?
- ¿Cómo se comportan ventas, costos y utilidad por periodo?

---

## 3. Arquitectura general

La arquitectura del proyecto se divide en cuatro capas:

```text
BI_OLTP → BI_Staging → BI_DW → Power BI
```

## 3.1 Capa operacional: BI_OLTP

La base `BI_OLTP` representa el sistema operacional de la empresa. Allí se almacenan las transacciones y entidades principales del negocio.

Su diseño se hizo de forma normalizada para evitar redundancia y mantener integridad.

## 3.2 Capa intermedia: BI_Staging

La base `BI_Staging` funciona como una zona de preparación. Su propósito es recibir datos desde el OLTP y desde fuentes externas, limpiarlos, validarlos y transformarlos.

Esta capa permite controlar la calidad antes de cargar el Data Warehouse.

## 3.3 Capa analítica: BI_DW

La base `BI_DW` contiene el Data Warehouse con modelo estrella. Esta capa está orientada al análisis, por eso separa dimensiones y hechos.

## 3.4 Capa de visualización: Power BI

Power BI se usa para crear indicadores, gráficos, filtros y matrices OLAP conectadas al Data Warehouse.

---

## 4. Base operacional BI_OLTP

La base `BI_OLTP` incluye las tablas operacionales del negocio:

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

## 4.1 Diseño normalizado

El modelo OLTP se diseñó de forma normalizada. Por ejemplo, las ventas se separan en:

- `Ventas`: encabezado de la factura.
- `DetalleVentas`: productos vendidos dentro de la factura.

Esto permite representar correctamente una venta con múltiples productos.

El mismo criterio se aplicó a compras:

- `Compras`
- `DetalleCompras`

## 4.2 Integridad de datos

Se implementaron:

- claves primarias;
- claves foráneas;
- restricciones `NOT NULL`;
- restricciones `CHECK`;
- valores únicos;
- validaciones de rangos y valores permitidos.

Esto permite que la información transaccional mantenga consistencia.

---

## 5. Datos sintéticos

Se generaron datos sintéticos realistas para Colombia. Se usaron ciudades, departamentos, nombres de clientes, proveedores, tiendas y categorías coherentes con una empresa minorista.

Ciudades utilizadas:

- Medellín
- Bogotá
- Cali
- Barranquilla
- Bucaramanga
- Cartagena
- Pereira
- Manizales
- Villavicencio
- Pasto

Categorías utilizadas:

- Abarrotes
- Bebidas
- Lácteos
- Carnes y Embutidos
- Frutas y Verduras
- Aseo Hogar
- Cuidado Personal
- Panadería
- Mascotas
- Tecnología Hogar

## 5.1 Volúmenes generados

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

## 5.2 Forma de generación

Los datos fueron generados con T-SQL usando lógica basada en conjuntos. Se utilizaron instrucciones como:

- `INSERT INTO ... SELECT`
- `CROSS JOIN`
- `ROW_NUMBER()`
- expresiones calculadas
- valores derivados por módulo

No se usaron ciclos `WHILE` para las cargas masivas.

---

## 6. Fuentes externas CSV

El proyecto también incluye dos fuentes externas:

- `metas_mensuales.csv`
- `ajustes_inventario.csv`

Estas fuentes se encuentran en la carpeta:

```text
05_Fuentes_Externas/
```

## 6.1 Metas mensuales

El archivo `metas_mensuales.csv` representa metas comerciales enviadas por sedes o por el área comercial.

Contiene:

- año;
- mes;
- tienda;
- categoría;
- valor meta;
- fuente.

## 6.2 Ajustes de inventario

El archivo `ajustes_inventario.csv` representa ajustes manuales de inventario.

Contiene información como:

- fecha de ajuste;
- tienda;
- producto;
- tipo de ajuste;
- cantidad ajustada;
- motivo;
- usuario responsable.

## 6.3 Carga mediante BULK INSERT

Para cargar los CSV en SQL Server fue necesario crear tablas destino en `BI_Staging`.

Las tablas son:

- `ext_MetasMensualesCSV`
- `ext_AjustesInventarioCSV`

Luego se usó `BULK INSERT` para cargar los archivos reales.

Este punto fue importante porque SQL Server no interpreta un CSV directamente como tabla. Primero debe existir una tabla con la estructura esperada y luego se carga el archivo.

---

## 7. Zona Staging

La base `BI_Staging` contiene las tablas intermedias:

- `stg_Clientes`
- `stg_Productos`
- `stg_Ventas`
- `stg_Inventario`
- `stg_Metas`
- `stg_Devoluciones`
- `stg_Compras`

## 7.1 Propósito de Staging

Staging permite preparar los datos antes de llevarlos al Data Warehouse.

En esta etapa se aplicaron transformaciones como:

- limpieza de nulos;
- conversión de fechas;
- estandarización de ciudades;
- estandarización de departamentos;
- asignación de regiones;
- validación de claves inexistentes;
- detección de duplicados;
- cálculo de campos derivados.

## 7.2 Campos de control

Cada tabla Staging contiene campos de control:

- `EsValido`
- `MensajeValidacion`
- `FechaCargaStaging`

Estos campos permiten identificar si un registro puede cargarse al DW o si debe ser revisado.

## 7.3 Ejemplos de transformaciones

En `stg_Clientes` se estandarizan ciudades y departamentos, y se asigna la región.

En `stg_Productos` se calcula:

```text
MargenUnitario = PrecioVenta - CostoUnitario
```

En `stg_Ventas` se calcula:

```text
CostoTotal = Cantidad * CostoUnitario
UtilidadBruta = ValorVenta - CostoTotal
```

---

## 8. Data Warehouse BI_DW

El Data Warehouse se diseñó como modelo estrella.

Este diseño facilita el análisis porque separa:

- dimensiones: contexto descriptivo;
- hechos: métricas cuantitativas.

## 8.1 Dimensiones

| Dimensión | Propósito |
|---|---|
| DimFecha | Analizar por año, trimestre, mes, semana, día y fin de semana |
| DimCliente | Analizar por cliente, segmento y ubicación |
| DimProducto | Analizar por producto, categoría y proveedor |
| DimTienda | Analizar por tienda, ciudad, departamento y región |
| DimVendedor | Analizar desempeño por vendedor |
| DimProveedor | Analizar compras por proveedor |
| DimCanalVenta | Analizar ventas por canal |
| DimPromocion | Preparar el modelo para futuras promociones |
| DimGeografia | Consolidar ciudad, departamento y región |

## 8.2 Tablas de hechos

| Tabla | Propósito |
|---|---|
| FactVentas | Analizar ventas y utilidad por línea de venta |
| FactInventarioDiario | Analizar stock, entradas y salidas por día |
| FactMetasComerciales | Analizar cumplimiento de metas |
| FactDevoluciones | Analizar devoluciones y motivos |
| FactCompras | Analizar compras por proveedor y producto |

---

## 9. Granularidad

## 9.1 FactVentas

La granularidad de `FactVentas` es una línea de venta.

Cada fila representa un producto vendido dentro de una factura, asociado a:

- fecha;
- cliente;
- producto;
- tienda;
- vendedor;
- canal;
- promoción.

Esta decisión permite analizar ventas por producto y categoría sin perder detalle.

## 9.2 FactInventarioDiario

La granularidad es producto, tienda y día.

Cada fila representa el inventario de un producto específico en una tienda específica para una fecha específica.

## 9.3 FactMetasComerciales

La granularidad es meta mensual por tienda y categoría.

Esto permite comparar ventas reales contra metas de forma mensual y por unidad de negocio.

## 9.4 FactDevoluciones

La granularidad es una devolución asociada a una línea de venta.

Esto permite saber qué producto fue devuelto, en qué tienda, por qué motivo y por qué valor.

## 9.5 FactCompras

La granularidad es una línea de compra.

Cada fila representa un producto comprado a un proveedor para una tienda y fecha específica.

---

## 10. Medidas aditivas, semi-aditivas y no aditivas

## 10.1 Medidas aditivas

Son medidas que se pueden sumar en todas las dimensiones.

Ejemplos:

- Total Ventas
- Total Costo
- Utilidad Bruta
- Total Compras
- Total Devoluciones
- Unidades Vendidas
- Unidades Compradas

## 10.2 Medidas semi-aditivas

El inventario es el principal ejemplo.

`StockFinal` puede analizarse por producto o tienda en una misma fecha, pero no debe sumarse a través del tiempo.

Por eso se usaron medidas como:

- Inventario Promedio
- Stock Mínimo
- Entradas Totales
- Salidas Totales

## 10.3 Medidas no aditivas

Son porcentajes o razones que no se deben sumar directamente.

Ejemplos:

- Margen Bruto %
- Cumplimiento Meta %
- Crecimiento Ventas %
- Participación % por Categoría
- Tasa Devolución %

Estas medidas deben recalcularse a partir de sus componentes.

---

## 11. Problemas de resumibilidad

El principal problema de resumibilidad se presentó con inventario.

Si se suma `StockFinal` por todos los días, el resultado no representa inventario real. Es una suma artificial de valores diarios.

También puede ocurrir con los porcentajes. Por ejemplo, el margen bruto no se debe sumar entre categorías, sino calcular como:

```text
Utilidad Bruta / Total Ventas
```

Esto mismo aplica al cumplimiento de metas.

---

## 12. Jerarquías dimensionales

El modelo permite trabajar varias jerarquías.

## 12.1 Tiempo

```text
Año → Trimestre → Mes → Día
```

## 12.2 Geografía

```text
Región → Departamento → Ciudad → Tienda
```

## 12.3 Producto

```text
Categoría → Producto
```

## 12.4 Comercial

```text
Tienda → Vendedor
```

Estas jerarquías permiten hacer análisis tipo drill-down y roll-up en Power BI.

---

## 13. SCD tipo 2

Aunque el proyecto usa una versión simplificada de las dimensiones, hay algunas que podrían manejar Slowly Changing Dimensions tipo 2.

## 13.1 DimCliente

Un cliente puede cambiar de segmento. Por ejemplo, pasar de Bronce a Plata u Oro.

## 13.2 DimProducto

Un producto puede cambiar de categoría, proveedor o precio.

## 13.3 DimTienda

Una tienda puede cambiar de dirección o región.

## 13.4 DimVendedor

Un vendedor puede cambiar de tienda.

En una versión más avanzada, estas dimensiones podrían conservar historial usando fecha de inicio, fecha de fin y registro vigente.

---

## 14. Diferencia entre OLTP y OLAP

| Aspecto | OLTP | OLAP / DW |
|---|---|---|
| Propósito | Registrar transacciones | Analizar información |
| Diseño | Normalizado | Dimensional |
| Usuario | Operación diaria | Análisis y gerencia |
| Consulta típica | Detalle de una venta | Ventas por mes o categoría |
| Optimización | Escritura y consistencia | Lectura y agregación |

En este proyecto, `BI_OLTP` funciona como sistema operacional y `BI_DW` como modelo analítico.

---

## 15. ETL y ETL_Log

Los procesos ETL se implementaron con procedimientos almacenados en T-SQL.

El flujo general es:

```text
1. Cargar datos de OLTP a Staging.
2. Transformar y validar datos.
3. Cargar dimensiones.
4. Cargar hechos.
5. Registrar ejecución en ETL_Log.
6. Validar calidad de datos.
```

La tabla `ETL_Log` registra:

- proceso;
- fecha de inicio;
- fecha de fin;
- estado;
- registros leídos;
- registros cargados;
- registros rechazados;
- mensaje de error.

Esto permite tener trazabilidad.

---

## 16. Power BI

El dashboard de Power BI tiene cinco páginas.

## 16.1 Resumen Ejecutivo

Muestra indicadores generales:

- Total Ventas
- Utilidad Bruta
- Margen Bruto %
- Cumplimiento Meta %
- Ticket Promedio

También muestra ventas por mes, ventas por categoría y top tiendas.

## 16.2 Análisis de Ventas

Permite analizar ventas por:

- vendedor;
- canal;
- segmento de cliente;
- categoría;
- tienda;
- región.

## 16.3 Inventario

Muestra:

- inventario promedio;
- entradas;
- salidas;
- stock mínimo;
- productos con menor inventario;
- rotación de inventario en unidades.

## 16.4 Metas y Operación

Permite comparar ventas reales contra metas comerciales. También muestra devoluciones y compras.

## 16.5 Rentabilidad y OLAP

Permite analizar ventas, costos, utilidad y margen. También incluye una matriz OLAP con jerarquías de tiempo, región, tienda y categoría.

---

## 17. Medidas DAX

Se implementaron medidas como:

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

## 18. Decisión sobre metas comerciales

En el dashboard, el cumplimiento de metas quedó bajo.

Esto ocurrió porque las metas generadas fueron altas frente a las ventas sintéticas. En algún momento se consideró crear una meta ajustada para que el indicador se viera más razonable, pero se decidió no hacerlo porque habría alterado el análisis.

La decisión final fue mantener las metas originales y explicar la brecha como parte del escenario del negocio.

Desde una perspectiva de BI, esto es importante porque los tableros no deben maquillar resultados. Si existe una brecha, debe mostrarse y analizarse.

---

## 19. Decisión sobre inventario

Durante el desarrollo, varias gráficas de inventario se veían muy parecidas. Esto se debía a que los datos sintéticos de inventario tenían una distribución homogénea entre tiendas y categorías.

En lugar de alterar los datos artificialmente, se cambió el enfoque visual. Se usaron métricas como:

- stock mínimo;
- entradas vs salidas;
- productos con menor inventario;
- rotación por unidades.

También se corrigió la medida de rotación. Inicialmente se estaba dividiendo costo en pesos entre inventario en unidades, lo cual no era conceptualmente correcto. La medida final fue:

```text
Unidades Vendidas / Inventario Promedio
```

---

## 20. Corrección en devoluciones

Durante la carga del DW, `FactDevoluciones` cargó inicialmente 983 registros en lugar de 1.000.

La causa fue que algunas devoluciones quedaron en enero de 2025, porque se generaban varios días después de ventas de finales de 2024.

Como `DimFecha` inicialmente llegaba hasta `2024-12-31`, esas devoluciones no encontraban una fecha correspondiente.

La solución fue completar `DimFecha` con las fechas faltantes de devoluciones antes de cargar `FactDevoluciones`.

Después de esta corrección, `FactDevoluciones` quedó con los 1.000 registros esperados.

---

## 21. Ética y uso de IA

Durante el proyecto se usó IA como herramienta de apoyo para organizar ideas, generar borradores de scripts, proponer medidas DAX, revisar errores y estructurar documentación.

Sin embargo, el proyecto no consistió en aceptar automáticamente lo que generaba la IA. Fue necesario ejecutar scripts, revisar resultados, corregir errores, validar conteos, ajustar visualizaciones y tomar decisiones propias.

Algunas decisiones tomadas durante el desarrollo fueron:

- mantener las metas originales aunque el cumplimiento fuera bajo;
- corregir la medida de rotación de inventario;
- cambiar visualizaciones repetitivas;
- integrar CSV reales mediante `BULK INSERT`;
- corregir la carga de devoluciones;
- organizar evidencias;
- estructurar el repositorio.

Una estimación razonable es que la IA apoyó entre 55% y 65% de la generación inicial y organización del material. El resto correspondió a implementación, pruebas, corrección, validación, interpretación y toma de decisiones.

---

## 22. Retos principales

Los principales retos fueron:

1. Mantener coherencia entre OLTP, Staging y DW.
2. Generar datos sintéticos con volumen suficiente.
3. Validar claves y relaciones.
4. Corregir el problema de devoluciones con fechas posteriores.
5. Entender la naturaleza semi-aditiva del inventario.
6. Evitar manipular las metas para mejorar indicadores.
7. Integrar fuentes externas reales.
8. Crear visualizaciones claras en Power BI.
9. Organizar el repositorio para que fuera entendible y reproducible.

---

## 23. Conclusiones

El proyecto permitió construir una solución BI completa, desde datos operacionales hasta visualizaciones en Power BI.

La separación entre OLTP, Staging y DW ayudó a organizar el flujo de datos. El modelo estrella permitió analizar la información desde varias dimensiones. Las medidas DAX permitieron construir indicadores comerciales, financieros y operativos.

Una de las conclusiones más importantes es que en BI no basta con mostrar números. Es necesario entender la granularidad, la naturaleza de las métricas, los problemas de resumibilidad y la forma correcta de interpretar los resultados.

También fue importante mantener coherencia ética: no se modificaron las metas para que el cumplimiento se viera mejor, sino que se explicó la brecha como parte del análisis.

En general, el proyecto muestra cómo una arquitectura BI puede convertir datos transaccionales en información útil para la toma de decisiones.
```
