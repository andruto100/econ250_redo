SELECT
  1
FROM (
  SELECT
    (SELECT SUM(total_orders) FROM {{ ref('redo_full_sales') }}) AS full_orders,
    (SELECT SUM(total_orders) FROM {{ ref('customer_delivery_sensitivity') }}) AS sensitivity_orders
)
WHERE full_orders != sensitivity_orders