# Xero → Fivetran → BigQuery
### Small Business Data Pipeline | Sandy G. Cabanes

> Infrastructure cost: $0  
> $12,375 in miscategorized revenue identified. 27% data quality gap confirmed.  
> Built entirely on free-tier tools.
> Replicates extraction from accounting software (Xero), using ELT tool Fivetran, querying loaded gold table in BigQuery, and local sqlite query for downloaded table.

---

## Table of Contents

1. [Problem](#1-problem)
2. [Solution](#2-solution)
3. [Findings](#3-findings)
4. [Applicability](#4-applicability)
5. [How It Works](#5-how-it-works)
6. [Revenue Analysis](#6-revenue-analysis)
7. [Data Quality Findings](#7-data-quality-findings)
8. [Cost and Maintenance](#8-cost-and-maintenance)
9. [Open Questions](#9-open-questions)
10. [Relevant Documents](#10-relevant-documents)


---

## 1. Problem

Xero is designed for accounting. It handles invoicing, reconciliation, and financial reporting well. What it is not designed for is open-ended analysis across all your records at once. 

Questions that matter to a growing business — which clients drive the most revenue, which services are most profitable, whether regional performance is improving — require data from across multiple invoices, clients, and time periods simultaneously.

The standard workaround is manual: export CSVs from Xero, consolidate in a spreadsheet, and rebuild the analysis each reporting period. The process is time-consuming, and error-prone.

There is a second, less visible problem: Xero does not flag its own data quality gaps. Missing service codes and unassigned region tags appear as blank fields in individual invoices — easy to miss in the UI, impossible to quantify without querying across all records at once. By the time a business notices, months of revenue have been misclassified.

---

## 2. Solution

A data pipeline that moves Xero accounting data into Google BigQuery automatically, applies a transformation layer using dbt, and produces analytics-ready tables that can be queried across all invoices, clients, and time periods simultaneously.

Once configured, the pipeline runs on a schedule with no manual intervention. New invoices appear in BigQuery automatically. Analysis is a SQL query against a live dataset, not a monthly spreadsheet exercise.

**Infrastructure cost at typical small business data volumes: $0/month.**

### Tech Stack

| Layer | Tool | Cost |
|-------|------|------|
| Source | Xero | Trial |
| Ingestion | Fivetran (Free plan) | $0 |
| Destination | Google BigQuery | $0 |
| Transformation | dbt via Fivetran Quickstart | $0 |
| Local analysis | SQLite + DB Browser | $0 |

**Why Fivetran over alternatives:** Several tools connect Xero to BigQuery — Airbyte, Stitch, CData, and PyAirbyte among them. Fivetran was selected because the free tier covers typical small business data volumes, the dbt transformation layer is included at no extra cost, and the setup is fully managed with no server required. At higher data volumes or with multiple sources, Airbyte self-hosted is the lower-cost path.

**A note on orchestration tools:** Apache Airflow and Luigi can orchestrate data ingestion through custom-coded workflows, but require you to build and maintain the source-system connectivity yourself — handling API pagination, rate limits, schema changes, and OAuth token refresh. Fivetran handles all of this out of the box. At this scale, a separate orchestration layer adds engineering overhead without adding capability.

→ [Full technical architecture and build steps](docs/pipeline_technical_brief.md)

---

## 3. Findings

Two categories of findings emerged from the first sync.

### Revenue Concentration

The top 3 clients generate 59% of total revenue. This concentration is invisible in Xero's standard reports — it only becomes visible when revenue is aggregated across all invoices simultaneously.

| Client | Revenue | % of Total |
|--------|---------|------------|
| Ridgeway University | $12,375 | 33% |
| Truxton Property Management | $5,906 | 16% |
| Hoyt Productions | $5,500 | 15% |
| SMART Agency | $4,500 | 12% |
| PC Complete | $4,024 | 11% |
| 25 other clients | $5,138 | 14% |

Loss of the largest single client eliminates one-third of revenue. The bottom 25 clients collectively generate less than the top client alone.

### Data Quality Gaps

27% of revenue line items have at least one missing field — either no service code, no region tag, or both. This includes $12,375 attributed to the largest client, which appears as "Unclassified" in any service-level report.

These gaps were not visible in Xero's UI without opening individual invoices. A single query across the warehouse surfaced all of them in seconds.

**Revenue impact of fixing the gaps:**

| | Before Fixes | After Fixes |
|--|-------------|-------------|
| Unclassified revenue | $21,468 (57%) | ~$1,150 (3%) |
| CRM Projects visible in reports | $0 | $12,375 |
| Unassigned regional revenue | $8,522 | ~$1,000 |

→ [Full revenue analysis with SQL queries](docs/revenue_insights.md)  
→ [Full data quality findings and action checklist](docs/data_quality_findings.md)

**Schema and dbt**

The full schema — all tables, columns, and foreign key relationships across all Xero organization types — is documented in the [Fivetran Xero ERD.]( https://fivetran.com/connector-erd/xero) Tables that did not sync in this deployment reflect org-type and OAuth scope constraints, not gaps in the connector itself.

* Gold layer produced by: fivetran/dbt_xero (open source)
* Package version: 0.9.0
* Model produced: xero__invoice_line_items
* Reason other models skipped: journal and journal_line
tables unavailable due to Xero Demo Company Global API scope change (post April 29, 2026)

---

## 4. Applicability

This pipeline applies to any business running on Xero — or similar cloud accounting software — where monthly reporting still depends on manual CSV exports, spreadsheet consolidation, or built-in reports that cannot answer cross-invoice questions.

The specific problems it addresses:

- Revenue is being miscategorized or left unclassified because invoices are entered manually rather than from a product catalogue
- Regional or segment performance cannot be reported reliably because tracking fields are inconsistently applied
- Cross-client, cross-period analysis requires staff time every month instead of a query

The pipeline manages its own schedule and runs automatically after setup. Maintenance requires intermediate SQL — no dedicated data engineering resource needed. All infrastructure lives in the client's own accounts with no vendor lock-in.

The same pattern — source system to Fivetran to BigQuery — applies beyond accounting data. CRM systems, support ticket platforms, and any operational tool with an API can follow the same architecture. 

This is not a substitute for tools like Zapier or Make.com, which automate individual actions between apps. This pipeline is designed for analytical queries across historical data — revenue trends, client mix, service performance — not for real-time workflow automation.

---

## 5. How It Works

The pipeline connects Xero, Fivetran, and BigQuery through a one-time setup of approximately half a day. After setup, no ongoing management is required for routine operations.

Three datasets land in BigQuery automatically:

```
xero            Raw data from Xero API (34 tables)
xero_staging    Cleaned and standardized (18 tables)
xero_reports    Analytics-ready reporting model (1 table)
```

The reporting table — `xero__invoice_line_items` — joins invoice headers, line items, chart of accounts, contact names, and region tracking into a single queryable surface.

**Known constraint:** Xero moved to granular OAuth scopes after April 29, 2026. Apps created after this date cannot access journal endpoints. General ledger, P&L, and balance sheet models were therefore unavailable for this build. This is a Xero platform change, not a configuration error. Invoice-based analysis — which covers revenue, data quality, and client analytics — was unaffected.

→ [Full build steps, IAM configuration, and OAuth setup](docs/pipeline_technical_brief.md)

---

## 6. Revenue Analysis

All analysis filtered to `account_type = 'REVENUE'`, excluding pass-through expenses, hardware, and rent billed through invoices.

### Finding 1 — Revenue Is Heavily Concentrated in Three Clients

The top 3 clients generate 59% of revenue. This is a structural risk — not a performance finding — and is only visible through cross-invoice aggregation.

**Action:** Protect top-tier relationships proactively. Direct growth efforts toward mid-tier clients (ranks 6–15) before pursuing new client acquisition.

### Finding 2 — CRM Projects Are the Highest-Value Service Line

CRM project management generates $12,375 — the highest revenue of any service — but is treated as ad hoc work with no standard pricing and no active promotion to existing clients.

**Action:** Formalize CRM project management as a named service. Use the recurring support base ($5,600/month) as the operational floor while growing project revenue.

### Finding 3 — Regional Revenue Picture Is Incomplete

11 clients worth $8,522 have no region assigned. Territory and resourcing decisions are unreliable until tagging is corrected.

**Action:** Set Region as required in Xero Tracking Categories. Apply default regions to recurring invoice templates.

→ [Full SQL queries and output tables](docs/revenue_insights.md)

---

## 7. Data Quality Findings

A single audit query across all 77 revenue line items surfaced the following:

### Issue 1 — Largest Client Has No Service Code
**Severity: HIGH | Financial impact: $12,375**

Ridgeway University was invoiced manually across two invoices with no item code selected. $12,375 is invisible to any catalogue-based service report.

**Action:** Create item code `CRM-PROJ`. Apply retroactively to INV-0009 and INV-0025.  
**Measure of success:** No unclassified revenue above $1,000.

### Issue 2 — Recurring Support Invoices Missing Region
**Severity: HIGH | Affected records: 17 line items**

Five recurring clients have no region assigned across both March and April — a systematic template gap, not a one-off error.

**Action:** Set Region as required in Tracking Categories. Update recurring invoice template with default region per client.  
**Measure of success:** Unassigned regional revenue below 5% within 90 days.

### Issue 3 — Two Small Invoices Unclassified
**Severity: LOW | Financial impact: $841**

**Action:** Create item codes `CONSULT` and `MKTG-MAT`. Apply going forward.

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

→ [Full audit with affected invoice numbers](docs/data_quality_findings.md)

---

## 8. Cost and Maintenance

### Infrastructure Cost

Fivetran's free tier supports up to 500,000 MAR or monthly active rows — well above typical small business data volumes. BigQuery's free tier covers storage under 10GB and queries under 1TB/month. Total infrastructure cost at this scale is $0/month. Costs scale with data volume and number of connected sources.

---

## 9. Open Questions

These questions are answerable with additional connectors following the same pipeline pattern.

| Question | Data Source Required |
|----------|----------------------|
| Which clients are most profitable? | Time tracking (Harvest, Toggl) |
| Which deals converted to revenue? | CRM data (HubSpot, Zoho, Pipedrive) |
| What is cash flow next month? | Historical data + forecasting layer |
| Which service has the best margin? | Xero bills/expenses pipeline |
| How does performance compare to industry? | External benchmark data |


---

## 10. Relevant Documents

| Document | Contents |
|----------|----------|
| [Pipeline Technical Brief](docs/pipeline_technical_brief.md) | Architecture, IAM setup, OAuth, build steps, constraints |
| [Revenue Insights](docs/revenue_insights.md) | Full analysis with SQL queries and output tables |
| [Data Quality Findings](docs/data_quality_findings.md) | Full audit, affected records, action checklist |

### Query Library

| Query | File |
|-------|------|
| Revenue by customer | [queries/revenue_by_customer.sql](queries/revenue_by_customer.sql) |
| Revenue by service type | [queries/revenue_by_service.sql](queries/revenue_by_service.sql) |
| Revenue by region | [queries/revenue_by_region.sql](queries/revenue_by_region.sql) |
| Data quality audit | [queries/data_quality_flags.sql](queries/data_quality_flags.sql) |

### Raw Query Outputs

| Output | File |
|--------|------|
| Revenue by customer | [outputs/revenue_by_customer.csv](outputs/revenue_by_customer.csv) |
| Revenue by service | [outputs/revenue_by_service.csv](outputs/revenue_by_service.csv) |

---

**Sandy G. Cabanes**  
Freelance Data Analyst and Pipeline Developer | Philippines

Specializes in data pipelines and analytical reporting for medium-scale enterprises — from raw source data through to business insights that inform real decisions. Works with open-source and free-tier tools to keep infrastructure costs low without sacrificing quality or reliability.

- GitHub: [SandyGCabanes](https://github.com/SandyGCabanes)
- LinkedIn: [linkedin.com/in/sandygcabanes](https://linkedin.com/in/sandygcabanes)

---

*Pipeline built: May 6, 2026*  
*Stack: Xero → Fivetran (Free) → BigQuery (GCP) → dbt → SQLite*  

