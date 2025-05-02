{{ config(materialized='table') }}
WITH customer_orders AS (
  SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(days_to_delivery), 2) AS avg_delivery_days
  FROM {{ ref('redo_full_sales') }}
  WHERE days_to_delivery IS NOT NULL
  GROUP BY customer_id
),
classified_customers AS (
  SELECT
    customer_id,
    total_orders,
    avg_delivery_days,
    CASE
      WHEN avg_delivery_days <= 3 THEN 'fast'
      WHEN avg_delivery_days <= 7 THEN 'medium'
      ELSE 'slow'
    END AS delivery_speed,
    total_orders > 1 AS is_returning_customer
  FROM customer_orders
)
SELECT *
FROM classified_customers
ORDER BY avg_delivery_days