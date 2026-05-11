-- SQLite revenue by customer and percents
SELECT
  contact_name,
  COUNT(DISTINCT invoice_id) AS invoice_count,
  SUM(line_amount)           AS total_revenue,
  ROUND(
    SUM(line_amount) * 100.0 / (
      SELECT SUM(line_amount)
      FROM xero_invoice_line_items
      WHERE account_type = 'REVENUE'
    ), 2
  )                          AS pct
FROM xero_invoice_line_items
WHERE account_type = 'REVENUE'
GROUP BY contact_name
ORDER BY total_revenue DESC;

/**
contact_name		invoice_count	total_revenue	pct
Ridgeway University	2		12375.0		47.28
Hamilton Smith Ltd	4		2050		7.83
Rex Media Group		3		1550		5.92
Boom FM			2		1500		5.73
Petrie McLoud Watson & Associates	1	1300	4.97
Bank West		1		1200		4.59
City Limousines		4		1119.95		4.28
Young Bros Transport	2		1000		3.82
Port & Philip Freight	2		1000		3.82
DIISR - Small Business Services	2	994.95		3.8
Basket Case		1		914.55		3.49
City Agency		1		547.8		2.09
Marine Systems		1		396		1.51
Bayside Club		1		224		0.86

**/