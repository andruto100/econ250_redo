{{ config(materialized='table') }}

SELECT
  order_items.seller_id,
  customer_state,
  ROUND(AVG(days_to_delivery), 2) AS avg_delivery_days,
  COUNT(DISTINCT order_id) AS total_orders
FROM {{ ref('redo_full_sales') }},
UNNEST(order_items) AS order_items
WHERE days_to_delivery IS NOT NULL
GROUP BY order_items.seller_id, customer_state
HAVING COUNT(DISTINCT order_id) >= 10
ORDER BY avg_delivery_days ASC
LIMIT 10

