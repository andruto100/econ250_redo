{{
  config(
    materialized='table',
    alias='redo_sales_full',
    partition_by={
      "field": "order_purchase_at",
      "data_type": "timestamp",
      "granularity": "day"
    },
    cluster_by=['order_id', 'customer_id']
  )
}}

SELECT
  o.order_id,
  o.customer_id,
  c.customer_unique_id,
  c.customer_zip_code,
  c.customer_city,
  c.customer_state,
  o.order_status,
  o.order_purchase_at,
  o.order_delivered_customer_at,
  o.order_approved_at,
  ARRAY_AGG(
    STRUCT(
      oi.product_id,
      oi.seller_id,
      p.product_category_name,
      t.product_category_name_english,
      oi.price,
      oi.freight_value
    )
  ) AS order_items,
  ARRAY_AGG(
    STRUCT(
      pay.payment_type,
      pay.payment_installments,
      pay.payment_value
    )
  ) AS payments,
  o.days_to_delivery,
  p.volumetric_weight_kg,
  CASE
    WHEN COUNT(oi.order_item_id) > 1 THEN TRUE
    ELSE FALSE
  END AS is_multi_item
FROM {{ ref('stg_redo_orders') }} o
LEFT JOIN {{ ref('stg_redo_customers') }} c
  ON o.customer_id = c.customer_id
LEFT JOIN {{ ref('stg_redo_order_items') }} oi
  ON o.order_id = oi.order_id
LEFT JOIN {{ ref('stg_redo_products') }} p
  ON oi.product_id = p.product_id
LEFT JOIN {{ ref('stg_redo_product_category_translation') }} t
  ON p.product_category_name = t.product_category_name
LEFT JOIN {{ ref('stg_redo_order_payments') }} pay
  ON o.order_id = pay.order_id
GROUP BY
  o.order_id,
  o.customer_id,
  c.customer_unique_id,
  c.customer_zip_code,
  c.customer_city,
  c.customer_state,
  p.volumetric_weight_kg,
  o.order_status,
  o.order_purchase_at,
  o.order_delivered_customer_at,
  o.days_to_delivery,
  o.order_approved_at,
  pay.payment_type,
  pay.payment_installments,
  pay.payment_value