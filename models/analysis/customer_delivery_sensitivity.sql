{{ config(materialized='table') }}

WITH base_data AS (
  SELECT
    customer_unique_id,
    order_id,
    days_to_delivery
  FROM {{ ref('redo_full_sales') }},
  UNNEST(order_items) AS order_items
  WHERE days_to_delivery IS NOT NULL
),

customer_order_counts AS (
  SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS total_orders
  FROM base_data
  GROUP BY customer_unique_id
),

threshold_data AS (
  SELECT
    APPROX_QUANTILES(total_orders, 100)[OFFSET(5)] AS order_count_threshold
  FROM customer_order_counts
),

filtered_customers AS (
  SELECT c.customer_unique_id
  FROM customer_order_counts c
  JOIN threshold_data t
    ON c.total_orders > t.order_count_threshold
),

filtered_orders AS (
  SELECT b.*
  FROM base_data b
  JOIN filtered_customers f
    ON b.customer_unique_id = f.customer_unique_id
),

delivery_quartiles AS (
  SELECT
    APPROX_QUANTILES(days_to_delivery, 4) AS quartiles
  FROM filtered_orders
),

classified_deliveries AS (
  SELECT
    f.customer_unique_id,
    f.days_to_delivery,
    CASE
      WHEN f.days_to_delivery <= q.quartiles[OFFSET(1)] THEN 'fast'
      WHEN f.days_to_delivery <= q.quartiles[OFFSET(2)] THEN 'medium'
      ELSE 'slow'
    END AS delivery_speed
  FROM filtered_orders f, delivery_quartiles q
),

customer_speed_distribution AS (
  SELECT
    customer_unique_id,
    COUNTIF(delivery_speed = 'fast') AS fast_count,
    COUNTIF(delivery_speed = 'medium') AS medium_count,
    COUNTIF(delivery_speed = 'slow') AS slow_count,
    COUNT(*) AS total_orders
  FROM classified_deliveries
  GROUP BY customer_unique_id
),

delivery_scores AS (
  SELECT
    customer_unique_id,
    total_orders,
    fast_count,
    medium_count,
    slow_count,
    ROUND(
      (fast_count * 3 + medium_count * 2 + slow_count * 1) / total_orders,
      2
    ) AS avg_delivery_score
  FROM customer_speed_distribution
)

SELECT *
FROM delivery_scores
ORDER BY total_orders DESC