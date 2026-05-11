-- sqlite service_code fix
SELECT
  -- 1. Coalesce works the same in SQLite
  COALESCE(item_code, 'Unclassified') AS service_code,
  
  -- 2. Replacement for REGEXP_EXTRACT to get the first line
  CASE 
    WHEN item_code IS NULL THEN 
      CASE 
        WHEN INSTR(line_item_description, CHAR(10)) > 0 
        THEN SUBSTR(line_item_description, 1, INSTR(line_item_description, CHAR(10)) - 1)
        ELSE line_item_description 
      END
    ELSE item_code 
  END AS service_label,
  
  -- 3. Aggregations remain identical
  COUNT(*) AS line_items,
  SUM(line_amount) AS total_revenue
 FROM xero_invoice_line_items
WHERE account_type = 'REVENUE'
GROUP BY service_code, service_label
ORDER BY total_revenue DESC;


