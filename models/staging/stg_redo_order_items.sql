SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date AS shipping_limit_at,
    COALESCE(price, 0) AS price,
    COALESCE(freight_value, 0) AS freight_value,
    COALESCE(price, 0) + COALESCE(freight_value, 0) AS total_item_cost,
FROM {{ source('AD_Redo', 'redo_order_items') }}