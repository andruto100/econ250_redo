SELECT
  product_id,
  COALESCE(product_category_name, 'unknown') AS product_category_name,
  COALESCE(product_name_lenght, 0) AS product_name_length,
  COALESCE(product_description_lenght, 0) AS product_description_length,
  COALESCE(product_photos_qty, 0) AS product_photos_qty,
  COALESCE(product_weight_g, 0) AS product_weight_g,
  COALESCE(product_length_cm, 0) AS product_length_cm,
  COALESCE(product_height_cm, 0) AS product_height_cm,
  COALESCE(product_width_cm, 0) AS product_width_cm,
  (COALESCE(product_length_cm, 0) * COALESCE(product_width_cm, 0) * COALESCE(product_height_cm, 0)) / 5000 AS volumetric_weight_kg
FROM {{ source('AD_Redo', 'redo_products') }}
WHERE
  COALESCE(product_name_lenght, 0) > 0
  AND COALESCE(product_description_lenght, 0) > 0
  AND COALESCE(product_photos_qty, 0) > 0
  AND COALESCE(product_weight_g, 0) > 0
  AND COALESCE(product_length_cm, 0) > 0
  AND COALESCE(product_height_cm, 0) > 0
  AND COALESCE(product_width_cm, 0) > 0