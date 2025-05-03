SELECT *
FROM {{ ref('repeat_purchase_product_category') }}
WHERE repeat_rate < 0 OR repeat_rate > 1