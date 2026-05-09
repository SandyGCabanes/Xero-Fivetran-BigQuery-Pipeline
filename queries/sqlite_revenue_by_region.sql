-- Revenue by region

SELECT
  COALESCE(region, 'Unassigned') AS region,
  SUM(line_amount) AS total_revenue,
  COUNT(DISTINCT contact_name) AS customers
FROM invoice_line_items
WHERE account_type = 'REVENUE'
GROUP BY region
ORDER BY total_revenue DESC;

/**
region	total_revenue	customers
South	13225.0	3
Unassigned	8522.25	11
Eastside	2800	3
North	1625	2
**/