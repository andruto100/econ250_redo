select
  customer_id,
  customer_unique_id,
  COALESCE(
    CASE
      WHEN REGEXP_CONTAINS(CAST(customer_zip_code_prefix AS STRING), r'^\d{5}$')
      THEN CAST(customer_zip_code_prefix AS STRING)
      ELSE '00000'
    END,
    '00000'
  ) AS customer_zip_code,
  COALESCE(LOWER(customer_city), 'unknown') AS customer_city,
  COALESCE(UPPER(customer_state), 'unknown') AS customer_state,
  CONCAT(customer_city, '-', customer_state) AS city_state

from {{ source('AD_Redo', 'redo_customers') }}