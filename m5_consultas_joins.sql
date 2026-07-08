-- ============================================================
--  m5_consultas_joins.sql
--  Pre-entrega Módulo 5 — Cruzando tablas para enriquecer
--  el análisis
--  Base de datos: Ventas_Tech_DB
--  Proyecto: RetailPro
-- ============================================================


-- ============================================================
--  CONSULTA 1 — Vista base del proyecto (INNER JOIN)
--  Cruza ventas, clientes, productos y categorias para
--  obtener una fila enriquecida por transacción.
--  Esta consulta es la fuente de datos principal de Power BI.
--
--  Nota: La base Ventas_Tech_DB creada en M3 no incluye la
--  tabla territorios ni la columna canal en ventas. Se deja
--  preparada la estructura para cuando se agreguen dichas
--  columnas en módulos siguientes. Por ahora se utilizan
--  las tablas disponibles: ventas, clientes, productos y
--  categorias.
-- ============================================================

SELECT
    v.id_venta,
    v.fecha_venta                           AS fecha,
    c.nombre                                AS nombre_cliente,
    c.ciudad                                AS ciudad_cliente,
    -- c.segmento                           -- disponible si se agrega en M6
    p.nombre_producto,
    cat.nombre_categoria                    AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario)        AS total_venta
    -- v.canal                              -- disponible si se agrega en M6
FROM ventas v
INNER JOIN clientes  c   ON v.id_cliente  = c.id_cliente
INNER JOIN productos p   ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY
    v.fecha_venta ASC;


-- ============================================================
--  CONSULTA 2 — Clientes sin ventas (LEFT JOIN)
--  Identifica clientes registrados que aún no realizaron
--  ninguna compra. Útil para el área de CRM.
-- ============================================================

SELECT
    c.id_cliente,
    c.nombre                AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY
    c.fecha_registro ASC;


-- ============================================================
--  CONSULTA 3 — Productos sin ventas (LEFT JOIN)
--  Identifica productos del catálogo sin ninguna venta
--  registrada. Útil para el área de producto.
-- ============================================================

SELECT
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria    AS categoria,
    p.precio
FROM productos p
LEFT JOIN ventas    v   ON p.id_producto   = v.id_producto
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL
ORDER BY
    p.id_producto ASC;


-- ============================================================
--  CONSULTA 4 — Consolidado por canal (UNION ALL)
--  Combina ventas Online y Presencial en un único resultado,
--  agrega la columna canal y calcula el total por canal con
--  GROUP BY.
--
--  Nota: la columna canal no existe aún en la tabla ventas
--  de Ventas_Tech_DB (se incorporará en M6). Se simula aquí
--  con una distribución ilustrativa: ventas con id_venta par
--  → Online; impares → Presencial. Reemplazá la condición
--  por v.canal = 'Online' / 'Presencial' cuando la columna
--  esté disponible.
-- ============================================================

-- Paso 1: separar ventas por canal con UNION ALL
WITH ventas_por_canal AS (
    -- Canal Online (IDs pares como ejemplo ilustrativo)
    SELECT
        v.id_venta,
        v.fecha_venta,
        v.id_cliente,
        v.id_producto,
        v.cantidad,
        v.precio_unitario,
        (v.cantidad * v.precio_unitario) AS total_venta,
        'Online'                          AS canal
    FROM ventas v
    WHERE MOD(v.id_venta, 2) = 0

    UNION ALL

    -- Canal Presencial (IDs impares como ejemplo ilustrativo)
    SELECT
        v.id_venta,
        v.fecha_venta,
        v.id_cliente,
        v.id_producto,
        v.cantidad,
        v.precio_unitario,
        (v.cantidad * v.precio_unitario) AS total_venta,
        'Presencial'                      AS canal
    FROM ventas v
    WHERE MOD(v.id_venta, 2) != 0
)
-- Paso 2: calcular totales por canal
SELECT
    canal,
    COUNT(*)                    AS cantidad_pedidos,
    SUM(cantidad)               AS unidades_vendidas,
    SUM(total_venta)            AS total_facturado,
    ROUND(AVG(total_venta), 2)  AS ticket_promedio
FROM ventas_por_canal
GROUP BY
    canal
ORDER BY
    total_facturado DESC;


-- ============================================================
--  HALLAZGOS DEL ANÁLISIS
-- ============================================================

-- HALLAZGO 1:
-- El cruce de ventas con productos y categorías (Consulta 1)
-- revela que la categoría "Computación" domina la facturación
-- total, impulsada principalmente por la Laptop Pro 15 y el
-- Monitor 4K. Esta vista enriquecida será la base directa
-- del dashboard en Power BI.

-- HALLAZGO 2:
-- La Consulta 2 (clientes sin ventas) permitirá al área de CRM
-- identificar clientes inactivos para activar campañas de
-- reactivación. Con los datos actuales de Ventas_Tech_DB todos
-- los clientes registrados tienen al menos una venta, lo que
-- indica una base de datos consistente para el período analizado.

-- HALLAZGO 3:
-- La Consulta 3 (productos sin ventas) es crítica para detectar
-- artículos del catálogo con stock inmovilizado. En la base
-- actual todos los productos tienen movimiento, pero a medida
-- que crezca el catálogo esta consulta será la primera
-- herramienta de alerta de inventario sin rotación.

-- ============================================================
--  FIN DEL ARCHIVO
-- ============================================================
