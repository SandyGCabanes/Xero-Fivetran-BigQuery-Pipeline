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
 FROM invoice_line_items
WHERE account_type = 'REVENUE'
GROUP BY service_code, service_label
ORDER BY total_revenue DESC;

  
  /**
service_code	service_label	line_items	total_revenue
Unclassified	Onsite project management for CRM Project 3 days/week	2	12375.0
Support-M	Support-M	11	5600
Train-MS	Train-MS	6	2700
DevD	DevD	2	1950
PMBr	PMBr	5	1400
PMDD	PMDD	1	525
DevH	DevH	1	470
Unclassified	Project team meeting to discuss dev changes required to your online gift basket ordering system	1	444.55
Unclassified	Marketing guides	1	396
GB1-White	GB1-White	1	224
Unclassified	Copies of 'Fish out of Water' text for your Branding Team	1	47.8
BOOK	BOOK	2	39.9


**/