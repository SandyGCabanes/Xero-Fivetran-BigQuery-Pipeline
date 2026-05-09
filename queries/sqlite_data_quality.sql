-- Data quality report query
SELECT
  invoice_number,
  contact_name,
  invoice_date,
  CASE WHEN item_code IS NULL THEN '⚠ No item code' END AS flag_item,
  CASE WHEN region IS NULL THEN '⚠ No region' END AS flag_region,
  line_amount
FROM invoice_line_items
WHERE account_type = 'REVENUE'
  AND (item_code IS NULL OR region IS NULL)
ORDER BY invoice_date DESC


/**
invoice_number	contact_name	invoice_date	flag_item	flag_region	line_amount
INV-0026	Basket Case	2026-05-05		⚠ No region	470
INV-0026	Basket Case	2026-05-05	⚠ No item code	⚠ No region	444.55
INV-0027	Marine Systems	2026-05-05	⚠ No item code	⚠ No region	396
INV-0028	Bayside Club	2026-05-05		⚠ No region	224
INV-0029	Hamilton Smith Ltd	2026-05-04		⚠ No region	550
INV-0030	Rex Media Group	2026-05-04		⚠ No region	550
INV-0025	Ridgeway University	2026-04-14	⚠ No item code		6187.5
INV-0018	Hamilton Smith Ltd	2026-04-05		⚠ No region	500
INV-0019	Young Bros Transport	2026-04-05		⚠ No region	500
INV-0020	Port & Philip Freight	2026-04-05		⚠ No region	500
INV-0021	Rex Media Group	2026-04-05		⚠ No region	500
INV-0022	DIISR - Small Business Services	2026-04-05		⚠ No region	19.95
INV-0017	City Limousines	2026-03-24		⚠ No region	19.95
INV-0011	Petrie McLoud Watson & Associates	2026-03-19		⚠ No region	1300
INV-0009	Ridgeway University	2026-03-14	⚠ No item code		6187.5
INV-0007	City Agency	2026-03-08	⚠ No item code	⚠ No region	47.8
INV-0005	Hamilton Smith Ltd	2026-03-06		⚠ No region	500
INV-0001	Hamilton Smith Ltd	2026-03-05		⚠ No region	500
INV-0002	Young Bros Transport	2026-03-05		⚠ No region	500
INV-0003	Port & Philip Freight	2026-03-05		⚠ No region	500
INV-0004	Rex Media Group	2026-03-05		⚠ No region	500
**/

