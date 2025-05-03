{{ config(materialized='table') }}

WITH base_data AS (
  SELECT
    customer_id,
    order_id,
    order_items.product_category_name AS product_category
  FROM {{ ref('redo_full_sales') }},
  UNNEST(order_items) AS order_items
),

customer_category_orders AS (
  SELECT
    customer_id,
    product_category,
    COUNT(order_id) AS num_orders
  FROM base_data
  GROUP BY customer_id, product_category
),

category_repeat_flags AS (
  SELECT
    customer_id,
    product_category,
    IF(num_orders >= 2, 1, 0) AS is_repeat
  FROM customer_category_orders
),

repeat_stats AS (
  SELECT
    product_category,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(is_repeat) AS repeat_customers,
    SUM(is_repeat) / COUNT(DISTINCT customer_id) AS repeat_rate
  FROM category_repeat_flags
  GROUP BY 1
)

SELECT *
FROM repeat_stats
ORDER BY repeat_rate DESC