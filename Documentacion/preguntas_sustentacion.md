# Preguntas de sustentación y respuestas

## 1. ¿Cuál es el objetivo principal del proyecto?

El objetivo principal fue construir una solución completa de Business Intelligence para una empresa minorista colombiana.

La solución permite transformar datos transaccionales en información analítica mediante una arquitectura compuesta por OLTP, Staging, Data Warehouse y Power BI.

---

## 2. ¿Qué problema de negocio resuelve?

Permite analizar ventas, inventario, compras, devoluciones, rentabilidad y cumplimiento de metas.

También ayuda a responder preguntas gerenciales como qué tiendas venden más, qué categorías son más rentables, qué productos tienen menor inventario o qué tan lejos está la empresa de cumplir sus metas.

---

## 3. ¿Por qué se usaron tres bases de datos?

Porque cada base cumple una función diferente.

`BI_OLTP` representa la operación diaria.

`BI_Staging` prepara y valida los datos.

`BI_DW` contiene el modelo analítico para Power BI.

Esta separación hace que la solución sea más organizada y más parecida a una arquitectura BI real.

---

## 4. ¿Qué es BI_OLTP?

Es la base operacional. Allí se almacenan las transacciones y entidades del negocio, como clientes, productos, ventas, compras, inventario, devoluciones y metas.

Su diseño es normalizado porque está pensado para registrar operaciones.

---

## 5. ¿Qué es BI_Staging?

Es la zona intermedia de preparación de datos.

Sirve para copiar, limpiar, transformar y validar los datos antes de llevarlos al Data Warehouse.

---

## 6. ¿Qué es BI_DW?

Es el Data Warehouse. Allí se encuentra el modelo dimensional con dimensiones y hechos.

Está diseñado para análisis, no para registro transaccional.

---

## 7. ¿Por qué no se cargan los datos directamente del OLTP al DW?

Porque se perdería control sobre la calidad de los datos.

Staging permite detectar errores, limpiar campos, validar claves, calcular campos derivados y rechazar registros inválidos antes de afectar el modelo final.

---

## 8. ¿Qué diferencia hay entre OLTP y OLAP?

OLTP se enfoca en registrar transacciones.

OLAP se enfoca en analizar información.

El OLTP es normalizado y operacional. El OLAP usa dimensiones, hechos y agregaciones.

---

## 9. ¿Por qué el OLTP está normalizado?

Porque un sistema transaccional debe evitar duplicidad y mantener integridad.

Por ejemplo, los datos del cliente no se repiten en cada venta; se guardan una vez en `Clientes` y se relacionan con `Ventas`.

---

## 10. ¿Por qué se separó Ventas y DetalleVentas?

Porque una venta puede tener varios productos.

`Ventas` guarda la información general de la factura.

`DetalleVentas` guarda cada producto vendido.

Esto permite analizar ventas por producto y categoría.

---

## 11. ¿Por qué se usó modelo estrella en el DW?

Porque el modelo estrella facilita el análisis en Power BI.

Las tablas de hechos contienen métricas y las dimensiones contienen atributos descriptivos.

Esto permite analizar ventas por fecha, producto, cliente, tienda, vendedor, canal y región.

---

## 12. ¿Cuáles son las dimensiones del modelo?

Las dimensiones son:

- DimFecha
- DimCliente
- DimProducto
- DimTienda
- DimVendedor
- DimProveedor
- DimCanalVenta
- DimPromocion
- DimGeografia

---

## 13. ¿Cuáles son las tablas de hechos?

Las tablas de hechos son:

- FactVentas
- FactInventarioDiario
- FactMetasComerciales
- FactDevoluciones
- FactCompras

---

## 14. ¿Cuál es la granularidad de FactVentas?

La granularidad es línea de venta.

Cada fila representa un producto vendido dentro de una factura, asociado a fecha, cliente, producto, tienda, vendedor y canal.

---

## 15. ¿Por qué FactVentas no se dejó solo a nivel de factura?

Porque se perdería el detalle por producto.

Si una factura tiene tres productos, necesitamos tres líneas para saber qué se vendió exactamente.

---

## 16. ¿Cuál es la granularidad de FactInventarioDiario?

La granularidad es producto, tienda y día.

Cada fila representa el inventario diario de un producto en una tienda específica.

---

## 17. ¿Cuál es la granularidad de FactMetasComerciales?

La granularidad es meta mensual por tienda y categoría.

Esto permite comparar ventas reales contra metas por periodo, tienda y categoría.

---

## 18. ¿Cuál es la granularidad de FactDevoluciones?

La granularidad es una devolución asociada a una línea de venta.

Esto permite analizar qué producto fue devuelto, en qué tienda, por qué motivo y por qué valor.

---

## 19. ¿Cuál es la granularidad de FactCompras?

La granularidad es línea de compra.

Cada fila representa un producto comprado a un proveedor para una tienda y fecha específica.

---

## 20. ¿Qué son claves sustitutas?

Son claves internas del Data Warehouse.

Por ejemplo, `ClienteKey` es la clave sustituta en `DimCliente`.

También se conserva `ClienteID_OLTP` para mantener trazabilidad con la base original.

---

## 21. ¿Por qué usar claves sustitutas?

Porque independizan el Data Warehouse del sistema operacional.

También permiten manejar cambios históricos en versiones más avanzadas del modelo.

---

## 22. ¿Qué medidas son aditivas?

Son medidas que se pueden sumar en todas las dimensiones.

Ejemplos:

- Total Ventas
- Total Costo
- Utilidad Bruta
- Total Compras
- Total Devoluciones
- Unidades Vendidas

---

## 23. ¿Qué medidas son semi-aditivas?

El inventario es semi-aditivo.

Se puede sumar por producto o tienda en una fecha específica, pero no se debe sumar a través del tiempo.

---

## 24. ¿Por qué el inventario no se debe sumar a través del tiempo?

Porque el inventario es una fotografía de un momento.

Si se suma el stock final de todos los días, el resultado es artificial y no representa inventario real.

---

## 25. ¿Qué medidas se usaron para inventario?

Se usaron:

- Inventario Promedio
- Stock Mínimo
- Entradas Totales
- Salidas Totales
- Rotación de Inventario Unidades

---

## 26. ¿Por qué se cambió la rotación de inventario?

Porque inicialmente se estaba dividiendo costo en pesos entre inventario en unidades.

Eso mezclaba unidades monetarias y unidades físicas.

La medida final fue:

```text
Unidades Vendidas / Inventario Promedio
```

Esta medida es más coherente para el modelo.

---

## 27. ¿Qué medidas son no aditivas?

Son porcentajes o razones que no deben sumarse.

Ejemplos:

- Margen Bruto %
- Cumplimiento Meta %
- Crecimiento Ventas %
- Participación % por Categoría
- Tasa Devolución %

---

## 28. ¿Qué problema de resumibilidad se identificó?

El principal problema fue inventario.

Sumar `StockFinal` en el tiempo genera una cifra equivocada.

También ocurre con porcentajes, porque no deben sumarse directamente.

---

## 29. ¿Qué jerarquías tiene el modelo?

Tiempo:

```text
Año → Trimestre → Mes → Día
```

Geografía:

```text
Región → Departamento → Ciudad → Tienda
```

Producto:

```text
Categoría → Producto
```

Comercial:

```text
Tienda → Vendedor
```

---

## 30. ¿Qué operaciones OLAP permite el modelo?

Permite:

- drill-down;
- roll-up;
- slice;
- dice.

Por ejemplo, se puede bajar de año a trimestre y mes, o filtrar por región, canal y categoría.

---

## 31. ¿Qué dimensiones podrían usar SCD tipo 2?

Podrían usar SCD tipo 2:

- DimCliente
- DimProducto
- DimTienda
- DimVendedor

Por ejemplo, un cliente puede cambiar de segmento o un vendedor puede cambiar de tienda.

---

## 32. ¿Por qué se creó DimPromocion?

Se creó para dejar el modelo preparado para crecer.

Aunque en esta versión casi todo está como “Sin promoción”, en una versión futura se podrían agregar campañas, descuentos o promociones.

---

## 33. ¿Qué pasó con FactDevoluciones?

Inicialmente cargó 983 registros en vez de 1.000.

La causa fue que algunas devoluciones quedaron en enero de 2025 porque se generaban días después de ventas de finales de 2024.

Como `DimFecha` solo llegaba hasta 2024-12-31, esas devoluciones no encontraban fecha.

La solución fue agregar a `DimFecha` las fechas faltantes de devoluciones.

---

## 34. ¿Por qué el cumplimiento de metas quedó bajo?

Porque las metas generadas fueron altas frente a las ventas sintéticas.

Esto no significa que el modelo esté mal. Significa que, en el escenario generado, las metas son ambiciosas frente al nivel de ventas.

---

## 35. ¿Por qué no se ajustaron las metas?

Porque habría sido manipular el análisis.

En BI no se deben cambiar los datos solo para que el tablero se vea mejor.

Se decidió mantener las metas originales y explicar la brecha comercial.

---

## 36. ¿Cómo se interpreta la brecha meta?

La brecha meta es la diferencia entre ventas reales y metas comerciales.

Si es negativa, significa que las ventas estuvieron por debajo del objetivo.

---

## 37. ¿Por qué algunos gráficos de inventario se veían similares?

Porque los datos sintéticos de inventario se generaron con distribución homogénea entre tiendas y categorías.

En vez de alterar los datos, se cambiaron las visualizaciones para mostrar métricas diferentes.

---

## 38. ¿Qué fuentes externas se integraron?

Se integraron dos CSV:

- `metas_mensuales.csv`
- `ajustes_inventario.csv`

---

## 39. ¿Por qué se integraron fuentes externas?

Porque en un escenario real muchas áreas entregan información en Excel o CSV.

Además, el proyecto requería integrar fuentes externas al flujo BI.

---

## 40. ¿Por qué fue necesario crear tablas para los CSV?

Porque SQL Server no consulta un CSV directamente como una tabla.

Primero se debe crear una tabla destino y luego cargar el archivo mediante `BULK INSERT`.

---

## 41. ¿Qué contiene la página Resumen Ejecutivo?

Contiene:

- Total Ventas
- Utilidad Bruta
- Margen Bruto %
- Cumplimiento Meta %
- Ticket Promedio
- Ventas por mes
- Ventas por categoría
- Top tiendas

---

## 42. ¿Qué contiene la página Análisis de Ventas?

Contiene análisis por:

- vendedor;
- canal;
- segmento;
- categoría;
- tienda;
- región.

---

## 43. ¿Qué contiene la página Inventario?

Contiene:

- inventario promedio;
- entradas;
- salidas;
- stock mínimo;
- tabla de productos con menor inventario;
- rotación en unidades.

---

## 44. ¿Qué contiene la página Metas y Operación?

Contiene:

- total meta;
- cumplimiento meta;
- brecha meta;
- total devoluciones;
- total compras;
- ventas reales vs metas;
- cumplimiento por tienda;
- devoluciones por motivo;
- compras por proveedor.

---

## 45. ¿Qué contiene la página Rentabilidad y OLAP?

Contiene:

- ventas;
- costos;
- utilidad bruta;
- margen bruto;
- ventas por categoría;
- utilidad por tienda;
- matriz OLAP.

---

## 46. ¿Para qué sirve ETL_Log?

Sirve para registrar la ejecución de procesos ETL.

Permite saber qué proceso corrió, cuándo inició, cuándo terminó, cuántos registros leyó, cuántos cargó, cuántos rechazó y si hubo errores.

---

## 47. ¿Qué validaciones de calidad se hicieron?

Se validaron:

- registros inválidos en Staging;
- duplicados;
- claves inexistentes;
- diferencias entre Staging y DW;
- conteos finales por tabla;
- logs de ETL.

---

## 48. ¿Cómo se usó IA en el proyecto?

Se usó IA como apoyo para generar ideas, estructurar scripts, revisar errores, crear medidas DAX y organizar documentación.

Pero fue necesario ejecutar, validar, corregir y tomar decisiones propias.

---

## 49. ¿Qué decisiones fueron tomadas por el equipo?

Se tomaron decisiones como:

- mantener las metas originales;
- no manipular el cumplimiento;
- corregir la rotación de inventario;
- completar fechas faltantes para devoluciones;
- cambiar visualizaciones repetitivas;
- cargar CSV reales;
- organizar evidencias.

---

## 50. ¿Qué porcentaje del proyecto tuvo apoyo de IA?

Una estimación razonable es entre 55% y 65% en generación inicial, organización y apoyo técnico.

El resto correspondió a ejecución, pruebas, validación, corrección, interpretación y montaje en Power BI.

---

## 51. ¿Qué fue lo más difícil?

Lo más difícil fue mantener coherencia entre todas las capas: OLTP, Staging, DW y Power BI.

También fue retador entender cuándo una métrica no se debía sumar directamente, como en el caso de inventario.

---

## 52. ¿Qué mejorarían en una versión futura?

Se podría mejorar:

- implementar SCD tipo 2;
- integrar los CSV al flujo ETL principal;
- agregar promociones reales;
- agregar costos logísticos;
- aumentar la variabilidad de datos sintéticos;
- automatizar la actualización en Power BI Service;
- desplegar completamente en Azure.

---

## 53. ¿Cómo se desplegó el proyecto en Azure?

Se creó una máquina virtual con Windows Server, se instaló SQL Server Developer y SQL Server Management Studio, se descargó el repositorio desde GitHub y se ejecutaron los scripts SQL en orden. Luego se validó que las bases `BI_OLTP`, `BI_Staging` y `BI_DW` quedaran creadas correctamente.

---

## 54. ¿Por qué se usó una máquina virtual y no Azure SQL Database?

Se usó una máquina virtual porque el proyecto ya estaba construido para SQL Server completo, con scripts T-SQL, `BULK INSERT` y archivos CSV en rutas locales. Una VM permite replicar el ambiente de SQL Server de forma más parecida al entorno local.

---

## 55. ¿Qué se entrega del despliegue en Azure?

Se entregan evidencias de ejecución, la IP pública de la VM, el usuario, la contraseña por canal privado y la indicación de que dentro de la VM el servidor SQL se consulta como `localhost` usando Windows Authentication.