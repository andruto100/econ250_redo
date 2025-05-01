SELECT
  seller_id,
  COALESCE(
    CASE
      WHEN seller_zip_code_prefix IS NOT NULL
      AND REGEXP_CONTAINS(CAST(seller_zip_code_prefix AS STRING), r'^\d{5}$')
      THEN CAST(seller_zip_code_prefix AS STRING)
      WHEN seller_zip_code_prefix IS NOT NULL
      AND REGEXP_CONTAINS(CAST(seller_zip_code_prefix AS STRING), r'^\d{4}$')
      THEN LPAD(CAST(seller_zip_code_prefix AS STRING), 5, '0')
      ELSE '00000'
    END,
    '00000'
  ) AS seller_zip_code,
  COALESCE(LOWER(seller_city), 'unknown') AS seller_city,
  COALESCE(LOWER(seller_state), 'unknown') AS seller_state,
  CONCAT(
    COALESCE(LOWER(seller_city), 'unknown'),
    '-',
    COALESCE(LOWER(seller_state), 'unknown')
  ) AS city_state
FROM {{ source('AD_Redo', 'redo_sellers') }}