SELECT
  COALESCE(LOWER(string_field_0), 'unknown') AS product_category_name,
  COALESCE(LOWER(string_field_1), 'unknown') AS product_category_name_english,
  CASE
    WHEN COALESCE(LOWER(string_field_1), 'unknown') != 'unknown'
    THEN TRUE
    ELSE FALSE
  END AS has_english_translation
FROM {{ source('AD_Redo', 'redo_product_category_translation') }}