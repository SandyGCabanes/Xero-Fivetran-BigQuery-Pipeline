## Data Quality Findings

A data quality audit query was run across all 77 revenue line items
to flag missing service codes and region tags:

```sql
SELECT
  invoice_number,
  contact_name,
  invoice_date,
  CASE WHEN item_code IS NULL THEN '⚠ No item code' END AS flag_item,
  CASE WHEN region IS NULL    THEN '⚠ No region'    END AS flag_region,
  line_amount
FROM xero__invoice_line_items
WHERE account_type = 'REVENUE'
  AND (item_code IS NULL OR region IS NULL)
ORDER BY invoice_date DESC
```

**Result: 21 of 77 revenue lines (27%) have at least one missing field.**

---

### Issue 1 — Largest Client Has No Service Code
**Severity: HIGH | Impact: $12,375**

Ridgeway University — 33% of total revenue — was invoiced across
two invoices with no item code. The line item description was typed
manually instead of selecting from the product catalogue.

This means $12,375 appears as "Unclassified" in any service
revenue report. The biggest revenue stream is invisible to
catalogue-based analysis.

**Fix:** Create item code `CRM-PROJ` in Xero Products & Services.
Update INV-0009 and INV-0025 retroactively.

**Picture of Success:** CRM project revenue appears as a named
service in all reports, not as blank.

---

### Issue 2 — Recurring Support Invoices Missing Region
**Severity: HIGH | Impact: 17 line items across March and April**

Every monthly IT support invoice for five recurring clients
has no region assigned — in both March and April. This is a
systematic gap in the invoice template, not a one-off error.

The same clients appear untagged month after month:
Hamilton Smith Ltd, Young Bros Transport, Port & Philip Freight,
Rex Media Group, DIISR - Small Business Services.

**Fix:**
1. Set Region as required in Xero Tracking Categories
2. Update recurring support invoice template with default
   region per client

**Picture of Success:** Regional revenue report shows less than
5% of revenue as Unassigned.

---

### Issue 3 — Two Small Invoices Uncoded
**Severity: LOW | Impact: $841**

Two line items have no item code and no catalogue equivalent:
a project team meeting (Basket Case, $444.55) and marketing
guides (Marine Systems, $396).

**Fix:** Create item codes `CONSULT` and `MKTG-MAT`.
Apply to these two invoices and use going forward.

---

### Revenue Impact of Fixes

| | Before Fixes | After Fixes |
|--|-------------|-------------|
| Unclassified revenue | $21,468 (57%) | ~$1,150 (3%) |
| CRM Projects visible | $0 | $12,375 |
| Unassigned regional revenue | $8,522 | ~$1,000 |

---

### Recommended Weekly Monitoring Query

```sql
SELECT
  COUNT(*) AS total_revenue_lines,
  SUM(CASE WHEN item_code IS NULL THEN 1 ELSE 0 END) AS missing_item_code,
  SUM(CASE WHEN region IS NULL    THEN 1 ELSE 0 END) AS missing_region,
  ROUND(100.0 * SUM(CASE WHEN item_code IS NULL
        THEN 1 ELSE 0 END) / COUNT(*), 1)            AS pct_missing_item,
  ROUND(100.0 * SUM(CASE WHEN region IS NULL
        THEN 1 ELSE 0 END) / COUNT(*), 1)            AS pct_missing_region
FROM xero__invoice_line_items
WHERE account_type = 'REVENUE'
```

Target: both percentages trend toward 0% over 90 days.
