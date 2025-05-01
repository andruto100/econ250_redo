SELECT
  order_id,
  payment_sequential,
  COALESCE(LOWER(payment_type), 'unknown') AS payment_type,
  COALESCE(payment_installments, 0) AS payment_installments,
  COALESCE(payment_value, 0) AS payment_value,
  CASE WHEN COALESCE(payment_installments, 0) > 1 THEN TRUE ELSE FALSE END AS is_installment_payment
FROM {{ source('AD_Redo', 'redo_order_payments') }}