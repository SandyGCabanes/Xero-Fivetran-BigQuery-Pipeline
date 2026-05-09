-- SQLite revenue by customer
SELECT
  contact_name,
  COUNT(DISTINCT invoice_id) AS invoice_count,
  SUM(line_amount) AS total_revenue
FROM invoice_line_items
WHERE account_type = 'REVENUE'
GROUP BY contact_name
ORDER BY total_revenue DESC;

/**
contact_name	invoice_count	total_revenue
Ridgeway University	2	12375.0
Hamilton Smith Ltd	4	2050
Rex Media Group	3	1550
Boom FM	2	1500
Petrie McLoud Watson & Associates	1	1300
Bank West	1	1200
City Limousines	4	1119.95
Young Bros Transport	2	1000
Port & Philip Freight	2	1000
DIISR - Small Business Services	2	994.95
Basket Case	1	914.55
City Agency	1	547.8
Marine Systems	1	396
Bayside Club	1	224
**/