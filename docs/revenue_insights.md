# Revenue Insights Report
**Prepared by:** Sandy G. Cabanes  
**Date:** May 6, 2026  
**For:** [Client Name]  
**Period covered:** March – May 2026  
**Source:** Xero invoice data → BigQuery pipeline

---

## How to Read This Report

Each insight below follows this structure:

- **What we see** — the number from the data
- **Problem** — what this means for the business
- **Solution** — what to do about it
- **Picture of Success** — what good looks like

---

## Insight 1: One Client Makes Up a Third of Your Revenue

**What we see**
Ridgeway University generated $12,375 — 33% of total revenue
in this period. The next closest client (Truxton Property
Management) generated $5,906.

| Rank | Client | Revenue | % of Total |
|------|--------|---------|------------|
| 1 | Ridgeway University | $12,375 | 33% |
| 2 | Truxton Property Management | $5,906 | 16% |
| 3 | Hoyt Productions | $5,500 | 15% |
| 4 | SMART Agency | $4,500 | 12% |
| 5 | PC Complete | $4,024 | 11% |
| Others (25 clients) | | $5,138 | 14% |

**Problem**
If Ridgeway University reduces scope, pauses, or leaves,
you lose one third of your revenue overnight. The top 3 clients
alone account for 59% of revenue — meaning 26 other clients
generate only 41% combined. The business is more dependent on
a handful of relationships than the client count suggests.

**Solution**
Two parallel actions:

1. Protect the relationship — ensure Ridgeway University has
   a formal engagement review scheduled. Understand their
   next project needs before the current one ends.

2. Grow the mid-tier — clients ranked 6-10 (Net Connect,
   Rex Media Group, Boom FM, Carlton Functions, Bank West)
   each generated $1,200-$1,600. These are candidates for
   upsell or expanded scope before chasing new clients.

**Picture of Success**
Top client accounts for less than 20% of monthly revenue.
Mid-tier clients (rank 6-15) collectively match or exceed
the top client's contribution.

---

## Insight 2: Half Your Clients Generate Very Little Revenue

**What we see**
15 of 29 clients (52%) generated under $1,000 in this period.
The bottom 10 clients combined generated $2,990 — less than
Ridgeway University's single largest invoice.

| Segment | Clients | Revenue | Avg per Client |
|---------|---------|---------|----------------|
| Top tier (>$4,000) | 4 | $28,281 | $7,070 |
| Mid tier ($1,000-$4,000) | 10 | $13,676 | $1,368 |
| Low tier (<$1,000) | 15 | $5,542 | $369 |

**Problem**
Low-tier clients likely require similar administrative effort
(quotes, invoices, follow-ups, support) as higher-value clients
but return far less per hour of relationship management. Without
tracking time spent per client, it is impossible to know which
of these relationships are profitable.

**Solution**
1. Review the 15 low-tier clients and classify each as:
   - **Growth potential** — small now but with expansion opportunity
   - **Convenience** — low effort, low value, acceptable to keep
   - **Review** — high effort, low value, worth a conversation
     about scope or minimum engagement fees

2. Consider a minimum monthly engagement threshold for new
   clients going forward (e.g. $500/month minimum retainer).

**Picture of Success**
Average revenue per client increases. Number of clients stays
the same or grows, but bottom-tier share of total clients
drops below 30%.

---

## Insight 3: Recurring Revenue Is Stronger Than It Looks

**What we see**
Monthly IT support (Support-M) generated $5,600 across
11 line items — appearing in both March and April for
the same group of clients at consistent amounts.

```
Recurring (Support-M)    : $5,600  predictable every month
Project-based (CRM-PROJ) : $12,375 one-off, may not repeat
Training (Train-MS)      : $2,700  periodic, not guaranteed
```

**Problem**
The CRM project inflates this period's revenue significantly.
If Ridgeway University does not renew or extend, next month's
revenue could drop by $6,187 — back to the recurring base only.
Planning and hiring decisions made on current revenue totals
may not hold next month.

**Solution**
Track recurring vs. non-recurring revenue separately every month:

```
Monthly recurring revenue (MRR)  = Support-M contracts
Project revenue                  = CRM, training, one-offs
```

Use MRR as the floor for operational planning (salaries, rent,
fixed costs). Use project revenue as growth and investment capacity.

**Picture of Success**
MRR covers at least 70% of monthly fixed operating costs.
Project revenue funds growth. The business does not depend on
landing a new project each month to break even.

---

## Insight 4: CRM Projects Are Your Highest-Value Service

**What we see**
After correcting for data quality issues, the revenue
by service picture is:

| Service | Revenue | Notes |
|---------|---------|-------|
| CRM Project Management | $12,375 | One client, two invoices |
| Monthly IT Support | $5,600 | Five clients, recurring |
| MS Office Training | $2,700 | One client, periodic |
| Development | $2,420 | Two clients |
| Branding/PM | $1,925 | Mixed clients |
| Other | $12,582 | Mostly unclassified — see data quality report |

**Problem**
CRM projects generate the highest revenue per engagement
but are treated as ad hoc work rather than a defined service.
There is no standard pricing, no packaged offering, and no
marketing of this service to other clients. Five clients in
the mid-tier (Truxton, SMART Agency, PC Complete, Net Connect,
City Limousines) could plausibly benefit from CRM project work
but may not know it is something you offer.

**Solution**
1. Define CRM project management as a formal service with
   a clear scope, deliverables, and price range
2. Create a one-page service description for existing clients
3. In HubSpot or your CRM, tag clients who have expressed
   interest in systems or process improvement — these are
   your warmest CRM project leads

**Picture of Success**
At least two CRM projects running per quarter across different
clients. CRM project revenue is no longer dependent on a
single client relationship.

---

## Insight 5: Regional Revenue Is Concentrated but Unclear

**What we see**
After applying the account_type = REVENUE filter:

| Region | Revenue | Clients |
|--------|---------|---------|
| South | $13,225 | 3 |
| Unassigned | $8,522 | 11 |
| Eastside | $2,800 | 3 |
| North | $1,625 | 2 |

**Problem**
South region produces the most revenue but from only 3 clients —
meaning it is geographically concentrated in the same way the
client list is concentrated by client. More critically, 11 clients
worth $8,522 have no region assigned at all, so the true regional
picture is unknown. South could be significantly larger or smaller
once unassigned clients are tagged correctly.

No reliable answer exists to: *"Should we focus sales effort
on South, or expand into underserved regions?"*

**Solution**
1. Fix region tagging as described in the data quality report
   (set Region as required in Xero Tracking Categories)
2. Once unassigned clients are tagged, re-run this report
3. Cross-reference region with service type — are CRM projects
   concentrated in South? Is training only happening in Eastside?
   These patterns drive where to focus business development.

**Picture of Success**
Less than 5% of revenue is Unassigned in the regional report.
A clear map of revenue by region exists and is updated monthly.
Sales and delivery decisions reference regional data.

---

## Summary: What the Data Is Saying

```
The business has strong relationships but fragile revenue
concentration. One client (Ridgeway) and one service type
(CRM projects) dominate. The recurring support base is solid
but currently insufficient to cover operations on its own.
The biggest growth lever is not finding new clients —
it is deepening relationships with the 10 mid-tier clients
who already trust the business and have room to spend more.
```

---

## What This Report Cannot Yet Tell Us

These questions require additional data sources:

| Question | What Is Needed |
|----------|----------------|
| Which clients are most profitable? | Time tracking data |
| Which region has the most growth potential? | Sales pipeline (HubSpot) |
| Are invoice payment terms being met? | Payment date analysis |
| Is revenue trending up or down? | 6-12 months of history |
| Which service has the best margin? | Cost data from Xero bills |

A follow-up pipeline connecting HubSpot CRM data to this
financial data would answer the first two questions directly.

---
*Prepared by Sandy G. Cabanes | sandygcabanes.github.io*  
*Pipeline: Xero → Fivetran → BigQuery | Analysis: SQLite / DB Browser*
