-- ============================================================
--  m4_consultas_negocio.sql
--  Pre-entrega Módulo 4 — Extrayendo métricas clave con SQL
--  Base de datos: Ventas_Tech_DB
--  Proyecto: RetailPro
-- ============================================================


-- ============================================================
--  CONSULTA 1 — Resumen ejecutivo mensual
--  Total facturado, cantidad de pedidos y ticket promedio
--  agrupados por mes.
-- ============================================================

SELECT
    EXTRACT(MONTH FROM fecha_venta)          AS mes,
    COUNT(*)                                 AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)          AS total_facturado,
    ROUND(
        AVG(cantidad * precio_unitario), 2
    )                                        AS ticket_promedio
FROM ventas
GROUP BY
    EXTRACT(MONTH FROM fecha_venta)
ORDER BY
    mes;


-- ============================================================
--  CONSULTA 2 — Ranking de productos
--  Top 5 de id_producto por total facturado,
--  con unidades vendidas y monto generado.
-- ============================================================

SELECT
    id_producto,
    SUM(cantidad)                   AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY
    id_producto
ORDER BY
    total_facturado DESC
LIMIT 5;


-- ============================================================
--  CONSULTA 3 — Clientes recurrentes
--  Clientes con más de un pedido, mostrando
--  cantidad de pedidos y total gastado.
-- ============================================================

SELECT
    id_cliente,
    COUNT(*)                        AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY
    id_cliente
HAVING
    COUNT(*) > 1
ORDER BY
    cantidad_pedidos DESC;


-- ============================================================
--  CONSULTA 4 — Meses por encima / por debajo del promedio
--  Total facturado por mes con etiqueta comparativa
--  respecto al promedio mensual general.
-- ============================================================

WITH facturacion_mensual AS (
    -- Paso 1: calcular el total facturado por mes
    SELECT
        EXTRACT(MONTH FROM fecha_venta)          AS mes,
        SUM(cantidad * precio_unitario)          AS total_facturado
    FROM ventas
    GROUP BY
        EXTRACT(MONTH FROM fecha_venta)
),
promedio_general AS (
    -- Paso 2: calcular el promedio entre todos los meses
    SELECT AVG(total_facturado) AS promedio_mensual
    FROM facturacion_mensual
)
-- Paso 3: etiquetar cada mes vs. el promedio
SELECT
    fm.mes,
    fm.total_facturado,
    ROUND(pg.promedio_mensual, 2)               AS promedio_mensual,
    CASE
        WHEN fm.total_facturado >= pg.promedio_mensual THEN 'Por encima'
        ELSE                                              'Por debajo'
    END                                         AS desempeno_vs_promedio
FROM facturacion_mensual fm
CROSS JOIN promedio_general pg
ORDER BY
    fm.mes;


-- ============================================================
--  HALLAZGOS DEL ANÁLISIS
--  (basados en los resultados de las consultas anteriores
--   ejecutadas sobre Ventas_Tech_DB)
-- ============================================================

-- HALLAZGO 1:
-- El producto 1 (Laptop Pro 15) concentra aproximadamente el 48%
-- del total facturado del período, siendo el ítem de mayor impacto
-- en la facturación. Su alto precio unitario ($1.200) compensa
-- un volumen de unidades moderado.

-- HALLAZGO 2:
-- Los clientes 1 (María López) y 3 (Ana Gómez) son los únicos
-- clientes recurrentes del período analizado, con 2 pedidos cada uno.
-- El resto realizó una única compra, lo que sugiere una oportunidad
-- de mejora en estrategias de retención y recompra.

-- HALLAZGO 3:
-- La facturación se concentra principalmente en la segunda mitad
-- de marzo 2024, con los días 12 al 15 acumulando el mayor volumen
-- de transacciones. Esto podría indicar un patrón de compra hacia
-- fin de quincena que vale la pena monitorear en meses subsiguientes.

-- ============================================================
--  FIN DEL ARCHIVO
-- ============================================================
