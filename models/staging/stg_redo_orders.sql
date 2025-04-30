select
    order_id,
    customer_id,
    COALESCE(LOWER(order_status), 'unknown') AS order_status,
    order_purchase_timestamp AS order_purchase_at,
    order_approved_at,
    order_delivered_carrier_date AS order_delivered_carrier_at,
    order_delivered_customer_date AS order_delivered_customer_at,
    order_estimated_delivery_date AS order_estimated_delivery_at,
    DATETIME_DIFF(
    order_delivered_customer_date,
    order_purchase_timestamp,
    DAY
  ) AS days_to_delivery,
    CASE WHEN order_status = 'shipped' THEN TRUE ELSE FALSE END AS is_shipped,
    CASE WHEN order_status = 'delivered' THEN TRUE ELSE FALSE END AS is_delivered

from {{ source('AD_Redo', 'redo_orders') }}