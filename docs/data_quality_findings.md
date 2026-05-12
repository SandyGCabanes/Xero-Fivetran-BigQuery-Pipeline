# Xero Invoice Data Quality Report
**Prepared by:** Sandy G. Cabanes  
**Date:** May 6, 2026  
**For:** [Client Name]  
**Period covered:** March – May 2026  
**Source:** Xero Demo Company (Global) — 34 revenue line items
(account_type = 'REVENUE' filter applied)

---

## Work Done

We connected your Xero account to a data warehouse and ran an audit
across all 34 revenue invoice line items from the past two months.
We checked two things for every line item:

1. Does it have a **service code** (so we know what was sold)?
2. Does it have a **region** (so we know where the sale came from)?

---

## Findings

**21 out of 34 revenue line items have at least one field missing.**

Broken down:

| Issue | Line Items |
|-------|-----------|
| Missing service code only | 2 |
| Missing region only | 16 |
| Missing both service code and region | 3 |
| **Total flagged** | **21** |
| Total revenue line items | 34 |

---

## Issue 1: Largest Client Has No Service Code

### Problem
Ridgeway University was invoiced across two invoices with no
service code selected on either. The line item descriptions
were typed manually instead of selecting from the product catalogue.

### Affected Records

| Invoice | Date | Amount |
|---------|------|--------|
| INV-0009 | 2026-03-14 | $6,187.50 |
| INV-0025 | 2026-04-14 | $6,187.50 |

This means their revenue appears as blank in any service-level
report. You cannot tell how much of your revenue comes from
CRM projects, and you have no baseline for quoting similar
work in future.

### Solution
Create service code `CRM-PROJ` in Xero under Products & Services.
Update INV-0009 and INV-0025 retroactively.

### Suggested KPIs
Both Ridgeway invoices appear under `CRM-PROJ` in the
service revenue report — not blank.

---

## Issue 2: 16 Revenue Line Items Have No Region Tag

### Problem
16 revenue line items across multiple service types have no
region assigned. The breakdown by service code:

| Service Code | Invoices | Clients |
|-------------|----------|---------|
| Support-M | INV-0001, 0002, 0003, 0004, 0005, 0018, 0019, 0020, 0021, 0029, 0030 | Hamilton Smith Ltd, Young Bros Transport, Port & Philip Freight, Rex Media Group |
| DevH | INV-0026 | Basket Case |
| DevD | INV-0011 | Petrie McLoud Watson & Associates |
| GB1-White | INV-0028 | Bayside Club |
| BOOK | INV-0017, INV-0022 | City Limousines, DIISR - Small Business Services |
| Hamilton Smith Ltd | INV-0005 | Hamilton Smith Ltd |

**Support-M is the most systematic gap.** The same clients
appear untagged in both March and April, confirming this is
a recurring template issue — not a one-off error.

### Solution
1. In Xero, go to Settings → Invoice Settings → Tracking Categories
   and make Region a required field. This prevents future invoices
   from being saved without a region.

2. Update recurring Support-M invoice templates to pre-fill
   the region for each client.

3. Retroactively tag all 16 flagged line items with the
   correct region.

### Suggested KPIs
Regional revenue report shows less than 5% of revenue
line items as Unassigned.

---

## Issue 3: Three Line Items Missing Both Fields

### Problem
Three line items have neither a service code nor a region:

| Invoice | Client | Amount |
|---------|--------|--------|
| INV-0026 | Basket Case | $444.55 |
| INV-0027 | Marine Systems | $396.00 |
| INV-0007 | City Agency | $47.80 |

Note: INV-0026 has two line items on the same invoice.
One line has service code `DevH` (missing region only).
The second line has neither field — and cannot be
forward-filled from the first line because the service
descriptions differ.

These three line items cannot be resolved automatically.
They require manual review in Xero.

### Solution
Review each invoice in Xero and assign the correct
service code and region. Suggested new codes:
- `CONSULT` — for ad hoc meetings and consulting time
- `MKTG-MAT` — for marketing materials

### Suggested KPIs
No line items with both fields missing in the next
monthly audit.

---

## Business Questions 

| Question | Can you answer it today? |
|----------|--------------------------|
| How much revenue comes from CRM projects? | No — 2 line items uncoded |
| Which region generates the most revenue? | No — 16 line items have no region |
| Is my service mix changing over time? | Partially |

---

## Action Checklist

- [ ] Create service code `CRM-PROJ` in Xero Products & Services
- [ ] Update INV-0009 and INV-0025 with `CRM-PROJ`
- [ ] Set Region as required in Xero Tracking Categories
- [ ] Update recurring Support-M invoice templates with default regions
- [ ] Retroactively tag all 16 flagged line items with correct regions
- [ ] Review INV-0026, INV-0027, INV-0007 — assign service code and region
- [ ] Confirm next monthly audit shows less than 5% unclassified

---

## Recommended Monitoring Query

Run this monthly to track improvement:

```sql
SELECT
  COUNT(*) AS total_revenue_lines,
  SUM(CASE WHEN item_code IS NULL THEN 1 ELSE 0 END) AS missing_item_code,
  SUM(CASE WHEN region IS NULL    THEN 1 ELSE 0 END) AS missing_region,
  ROUND(100.0 * SUM(CASE WHEN item_code IS NULL
        THEN 1 ELSE 0 END) / COUNT(*), 1)            AS pct_missing_item,
  ROUND(100.0 * SUM(CASE WHEN region IS NULL
        THEN 1 ELSE 0 END) / COUNT(*), 1)            AS pct_missing_region
FROM xero_invoice_line_items
WHERE account_type = 'REVENUE'
```

Target: both percentages trend toward 0% over 90 days.

---

## How This Report Was Produced

Your Xero Demo Company data was connected to a data warehouse
using an automated pipeline. All revenue invoice line items were
loaded into a single table and checked for missing fields in one
query — across all invoices at once. This cross-invoice audit
is not possible inside Xero's UI.

The full query and raw data are saved and can be re-run at any time.

---
*Prepared by Sandy G. Cabanes | sandygcabanes.github.io*  
*Pipeline: Xero Demo Company → Fivetran → BigQuery | Analysis: SQLite / DB Browser*
