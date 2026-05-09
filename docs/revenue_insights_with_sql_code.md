## Revenue Insights With SQL Code

All analysis filtered to `account_type = 'REVENUE'` only,
excluding pass-through expenses, hardware, and rent
that were billed through invoices.

### Finding 1 — Revenue Is Heavily Concentrated

```sql
SELECT contact_name,
       COUNT(DISTINCT invoice_id) AS invoice_count,
       SUM(line_amount)           AS total_revenue
FROM xero__invoice_line_items
WHERE account_type = 'REVENUE'
GROUP BY contact_name
ORDER BY total_revenue DESC
```

| Client | Revenue | % of Total |
|--------|---------|------------|
| Ridgeway University | $12,375 | 33% |
| Truxton Property Management | $5,906 | 16% |
| Hoyt Productions | $5,500 | 15% |
| SMART Agency | $4,500 | 12% |
| PC Complete | $4,024 | 11% |
| 25 other clients | $5,138 | 14% |

**What this means:** The top 3 clients generate 59% of revenue.
If Ridgeway University does not renew, one third of revenue
disappears. The 25 clients at the bottom collectively generate
less than the single largest client.

**What to do:** Protect top relationships actively. Focus growth
efforts on mid-tier clients (rank 6-15) who already trust the
business before acquiring new clients.

---

### Finding 2 — CRM Projects Are the Highest-Value Service

```sql
SELECT
  COALESCE(item_code, 'Unclassified') AS service_code,
  CASE WHEN item_code IS NULL
       THEN SUBSTR(line_item_description, 1,
            INSTR(line_item_description || CHAR(10), CHAR(10)) - 1)
       ELSE item_code END             AS service_label,
  COUNT(*)                            AS line_items,
  SUM(line_amount)                    AS total_revenue
FROM xero__invoice_line_items
WHERE account_type = 'REVENUE'
GROUP BY service_code, service_label
ORDER BY total_revenue DESC
```

| Service | Revenue | Type |
|---------|---------|------|
| CRM Project Management | $12,375 | Project |
| Monthly IT Support | $5,600 | Recurring |
| MS Office Training | $2,700 | Periodic |
| Development | $2,420 | Project |
| Branding / PM | $1,925 | Project |

**What this means:** CRM projects generate the highest revenue
per engagement but are treated as ad hoc work — no standard
pricing, no packaged service, no active marketing to other clients.
Five mid-tier clients could plausibly need CRM work but may not
know it is available.

**What to do:** Define CRM project management as a formal service.
The recurring support base ($5,600/month) is more strategically
stable — use it as the operational floor while growing project revenue.

---

### Finding 3 — Regional Revenue Is Unclear

```sql
SELECT
  COALESCE(region, 'Unassigned') AS region,
  SUM(line_amount)               AS total_revenue,
  COUNT(DISTINCT contact_name)   AS customers
FROM xero__invoice_line_items
WHERE account_type = 'REVENUE'
GROUP BY region
ORDER BY total_revenue DESC
```

| Region | Revenue | Clients |
|--------|---------|---------|
| South | $13,225 | 3 |
| Unassigned | $8,522 | 11 |
| Eastside | $2,800 | 3 |
| North | $1,625 | 2 |

**What this means:** South appears to be the strongest region
but only has 3 clients. 11 clients worth $8,522 have no region
assigned — the true regional picture is unknown until tagging
is fixed. Sales territory decisions cannot be made reliably
on this data.
