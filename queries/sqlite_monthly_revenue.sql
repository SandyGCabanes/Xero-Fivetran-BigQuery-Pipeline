-- Monthly breakdown

SELECT
  STRFTIME('%Y-%m', invoice_date) AS month,
  SUM(line_amount)                AS monthly_support_revenue
FROM xero_invoice_line_items
WHERE account_type = 'REVENUE'
  AND item_code = 'Support-M'
GROUP BY month
ORDER BY month;

/**
month	monthly_support_revenue
2026-03	2500
2026-04	2000
2026-05	1100
**/
