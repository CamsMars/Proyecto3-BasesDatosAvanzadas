# Bitácora de decisiones, problemas y mejoras

## 1. Propósito de esta bitácora

Este documento resume las principales decisiones tomadas durante el desarrollo práctico del proyecto BI. También registra problemas que aparecieron, cómo se resolvieron y qué aprendizajes dejaron.

La intención es mostrar que el proyecto no fue solamente una ejecución lineal de scripts, sino un proceso de revisión, corrección y mejora.

---

## 2. Decisión 1: separar el proyecto en tres bases

## Situación

El proyecto requería una arquitectura BI completa. Por eso se decidió separar el trabajo en:

```text
BI_OLTP → BI_Staging → BI_DW
```

## Decisión

Se creó una base operacional, una zona intermedia y un Data Warehouse.

## Justificación

Esta separación permite diferenciar la operación, la preparación de datos y el análisis.

## Resultado

El proyecto quedó más ordenado y se pudo explicar mejor el flujo de datos.

---

## 3. Decisión 2: mantener el término Staging

## Situación

En algún momento surgió la duda de si la palabra “Staging” era demasiado técnica.

## Decisión

Se mantuvo `BI_Staging`.

## Justificación

Aunque podría traducirse como zona intermedia o zona de preparación, Staging es el término técnico más utilizado en proyectos BI.

Además, el proyecto pedía una base de datos de Staging, por lo que mantener el nombre ayudaba a que la estructura fuera reconocible.

## Resultado

Se usó `BI_Staging`, pero en la documentación se explica como “zona intermedia de preparación de datos”.

---

## 4. Decisión 3: generar datos sintéticos con lógica por conjuntos

## Situación

Se necesitaban muchos registros: ventas, líneas de venta, inventario, compras, devoluciones y metas.

## Decisión

Se generaron datos usando `INSERT INTO ... SELECT`, `CROSS JOIN`, `ROW_NUMBER()` y expresiones calculadas.

## Justificación

Este enfoque es más eficiente que usar ciclos `WHILE` para cargas masivas.

## Resultado

Se generaron volúmenes suficientes para el proyecto:

- 50.000 ventas;
- 150.000 líneas de venta;
- 730.000 registros de inventario;
- 1.000 devoluciones;
- 2.400 metas comerciales.

---

## 5. Decisión 4: usar datos realistas para Colombia

## Situación

El proyecto debía representar una empresa minorista colombiana.

## Decisión

Se usaron ciudades, departamentos, regiones, nombres y proveedores coherentes con Colombia.

## Justificación

Esto hace que el proyecto sea más creíble y más cercano al contexto del caso.

## Resultado

Se incluyeron ciudades como Medellín, Bogotá, Cali, Barranquilla, Bucaramanga, Cartagena, Pereira, Manizales, Villavicencio y Pasto.

---

## 6. Problema 1: FactDevoluciones cargó 983 registros en vez de 1.000

## Situación

Al validar las tablas de hechos, `FactDevoluciones` tenía 983 registros, aunque en Staging existían 1.000 devoluciones.

## Diagnóstico

Se encontró que algunas devoluciones tenían fechas posteriores al rango inicial de `DimFecha`.

La dimensión fecha estaba cargada hasta:

```text
2024-12-31
```

Pero algunas devoluciones quedaron en enero de 2025 porque se generaban varios días después de ventas realizadas al final de 2024.

## Decisión

No se forzaron ni eliminaron registros. Se completó `DimFecha` con las fechas faltantes de devoluciones.

## Justificación

La devolución es válida. El problema no era la devolución, sino que la dimensión fecha no cubría todo el rango necesario.

## Resultado

Después de completar `DimFecha`, `FactDevoluciones` quedó con los 1.000 registros esperados.

## Aprendizaje

En un Data Warehouse, la dimensión fecha debe cubrir todas las fechas usadas por los hechos, incluso si algunas fechas aparecen por efectos del negocio, como devoluciones posteriores a la venta.

---

## 7. Problema 2: las metas quedaron muy altas frente a las ventas

## Situación

En Power BI, el cumplimiento de metas quedó bajo. El porcentaje de cumplimiento era cercano al 12%.

## Análisis

El bajo cumplimiento no era un error técnico. Ocurría porque las metas generadas eran altas frente al total de ventas sintéticas.

## Alternativa considerada

Se consideró crear una meta ajustada para que el cumplimiento se viera más razonable visualmente.

## Decisión final

No se ajustaron las metas.

## Justificación

Modificar las metas para que el dashboard se viera mejor habría sido manipular el análisis.

En BI, los resultados no deben maquillarse. Si existe una brecha, se debe mostrar y explicar.

## Resultado

Se mantuvieron las metas originales y se interpretó el bajo cumplimiento como una brecha comercial del escenario generado.

## Aprendizaje

Un dashboard no siempre tiene que mostrar indicadores positivos. También debe evidenciar problemas, brechas y oportunidades de mejora.

---

## 8. Problema 3: visualizaciones de inventario muy parecidas

## Situación

En la página de Inventario, los gráficos de inventario promedio por tienda y por categoría se veían muy parecidos.

## Diagnóstico

Se validó en SQL Server que los promedios eran casi iguales. El problema no era Power BI, sino la forma homogénea en que se generaron los datos sintéticos de inventario.

## Decisión

No se modificaron artificialmente los datos. Se cambiaron las visualizaciones para mostrar métricas diferentes.

## Ajustes realizados

Se usaron métricas como:

- stock mínimo;
- entradas totales;
- salidas totales;
- rotación de inventario en unidades;
- productos con menor inventario.

## Resultado

La página de inventario quedó más útil, porque dejó de repetir la misma lectura y empezó a mostrar diferentes dimensiones del análisis operativo.

## Aprendizaje

Cuando los datos sintéticos son homogéneos, no siempre hay que cambiarlos. A veces es mejor ajustar la pregunta analítica o la visualización.

---

## 9. Problema 4: rotación de inventario poco coherente

## Situación

La primera medida de rotación de inventario generaba valores demasiado altos.

## Diagnóstico

La medida dividía costo total en pesos entre inventario promedio en unidades. Esto mezclaba unidades monetarias con unidades físicas.

## Decisión

Se creó una medida más coherente:

```text
Rotación de Inventario Unidades = Unidades Vendidas / Inventario Promedio
```

## Justificación

Esta medida compara unidades vendidas contra unidades promedio en inventario.

## Resultado

La rotación quedó más defendible desde el punto de vista conceptual.

## Aprendizaje

Las medidas DAX no solo deben funcionar técnicamente. También deben tener sentido de negocio.

---

## 10. Problema 5: carga de archivos CSV

## Situación

Al principio existía la duda de si bastaba con tener los archivos CSV en la carpeta del repositorio.

## Diagnóstico

SQL Server no consulta automáticamente archivos CSV como si fueran tablas. Para usarlos, se necesita crear una tabla destino y luego cargar el archivo.

## Decisión

Se creó el script:

```text
12_fuentes_externas_bulk_insert.sql
```

Este script crea tablas auxiliares y carga los archivos mediante `BULK INSERT`.

## Tablas creadas

- `ext_MetasMensualesCSV`
- `ext_AjustesInventarioCSV`

## Resultado

Las fuentes externas quedaron integradas en `BI_Staging`.

## Aprendizaje

En proyectos BI, una fuente externa debe integrarse al flujo de datos. No basta con guardar el archivo; debe existir una forma reproducible de cargarlo.

---

## 11. Decisión 5: organizar el repositorio por carpetas

## Situación

El proyecto tenía muchos scripts, evidencias, CSV, documentación y archivo Power BI.

## Decisión

Se organizó el repositorio en carpetas:

```text
01_SQL
02_PowerBI
03_Documentacion
04_Evidencias
05_Fuentes_Externas
```

## Justificación

Esta estructura permite que el profesor o cualquier persona revise el proyecto de forma ordenada.

## Resultado

El proyecto quedó más fácil de ejecutar, revisar y sustentar.

---

## 12. Decisión 6: crear cinco páginas en Power BI

## Situación

El proyecto requería dashboard ejecutivo, ventas, inventario, rentabilidad, metas y OLAP.

## Decisión

Se construyeron cinco páginas:

1. Resumen Ejecutivo
2. Análisis de Ventas
3. Inventario
4. Metas y Operación
5. Rentabilidad y OLAP

## Justificación

La última página combina rentabilidad y exploración OLAP. Esto permite cubrir ambos requerimientos sin crear páginas innecesarias.

## Resultado

El dashboard quedó completo y organizado.

---

## 13. Decisión 7: mantener resultados aunque no fueran “bonitos”

## Situación

Algunos resultados no se veían tan ideales, especialmente el cumplimiento de metas.

## Decisión

Se decidió no modificar los datos solo para mejorar la apariencia del dashboard.

## Justificación

El objetivo de BI no es embellecer resultados, sino mostrar información útil y honesta.

## Resultado

Se conservaron las metas originales y se documentó la interpretación de la brecha.

---

## 14. Decisión 8: usar evidencias solo de resultados importantes

## Situación

Había muchas consultas SQL, pero no era práctico tomar captura de todas.

## Decisión

Se tomaron evidencias de los puntos clave:

- bases creadas;
- conteos OLTP;
- conteos Staging;
- conteos DW;
- ETL_Log;
- validación de calidad;
- fuentes externas;
- modelo Power BI;
- páginas del dashboard.

## Justificación

Las evidencias deben demostrar funcionamiento, no documentar cada línea de código.

## Resultado

La carpeta de evidencias quedó clara y suficiente.

---

## 15. Decisión 9: documentar uso de IA con transparencia

## Situación

Se usó IA durante el desarrollo del proyecto como apoyo técnico y de documentación.

## Decisión

Se incluyó una sección de ética y uso de IA en el informe.

## Justificación

Es importante declarar cómo se usó la herramienta y qué decisiones fueron tomadas por el equipo.

## Resultado

La documentación explica que la IA apoyó en generación inicial, revisión y organización, pero que el equipo ejecutó, validó, corrigió e interpretó los resultados.

---

## 16. Decisión: replicar el proyecto en Azure

## Situación

Después de completar la implementación local, se replicó el proyecto en una máquina virtual de Azure para cumplir con el componente de despliegue en nube.

## Decisión

Se creó una VM con Windows Server, se instaló SQL Server Developer y SQL Server Management Studio, se descargó el repositorio desde GitHub y se ejecutaron los scripts SQL en el mismo orden definido para el proyecto.

## Justificación

La VM permite que el profesor pueda revisar el proyecto en un ambiente de servidor, sin depender únicamente de la ejecución local.

## Resultado

Las bases `BI_OLTP`, `BI_Staging` y `BI_DW` quedaron creadas en la VM. También se cargaron las fuentes externas CSV y se validaron los conteos finales.

## Aprendizaje

El despliegue en Azure permitió entender que una solución BI no solo debe funcionar localmente, sino que también debe poder replicarse en un entorno de nube.

---

## 17. Estado final de la parte práctica

Al finalizar la parte práctica, se logró:

- crear las tres bases de datos;
- cargar datos sintéticos;
- integrar fuentes externas CSV;
- construir la zona Staging;
- construir el Data Warehouse;
- crear procedimientos ETL;
- registrar logs;
- validar calidad;
- conectar Power BI;
- crear medidas DAX;
- construir cinco páginas de dashboard;
- generar evidencias;
- organizar documentación.

---

## 18. Mejoras posibles

En una versión futura se podría:

1. Implementar SCD tipo 2.
2. Integrar los CSV directamente al flujo principal de metas e inventario.
3. Agregar promociones reales.
4. Mejorar la variabilidad de datos sintéticos de inventario.
5. Agregar costos logísticos.
6. Automatizar la actualización en Power BI Service.
7. Desplegar todo completamente en Azure.
8. Crear procesos de carga incremental.
9. Agregar control de errores más detallado.
10. Crear vistas semánticas para facilitar el consumo desde Power BI.

---

## 19. Reflexión final

Este proyecto permitió entender que una solución BI no es solo crear un tablero. Requiere pensar en arquitectura, calidad de datos, granularidad, medidas, relaciones, procesos ETL y visualización.

También permitió ver que los errores que aparecen durante el desarrollo son parte del proceso. El caso de las devoluciones, la rotación de inventario y las metas comerciales ayudó a mejorar el modelo y a entender mejor las decisiones detrás de una solución BI.

La parte más importante fue no limitarse a que el código ejecutara, sino validar si los resultados tenían sentido.
```