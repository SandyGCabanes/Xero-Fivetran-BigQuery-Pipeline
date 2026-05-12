# Xero - Fivetran - BigQuery - Data Studio End-to-End Pipeline
### Small Business Data Pipeline | Sandy G. Cabanes

> Infrastructure cost: $0  
> $12,375 in miscategorized revenue identified.<br>
> 62% data quality gap revealed.  
> Built entirely on free-tier tools.<br>
> Replicates extraction from accounting software (Xero), using ELT tool Fivetran, querying loaded gold table in BigQuery, local sqlite query for downloaded table, and Data Studio in GCP for the dashboard


## Executive Summary: 

This repo documents a working ELT pipeline built on free-tier tools,
connecting Xero accounting data to Google BigQuery via Fivetran.
The pipeline runs automatically, requires no ongoing maintenance for
routine operations, and costs $0/month at typical small business
data volumes.

The first sync took 50 seconds. The first audit query found a 62%
data quality gap and $12,375 in revenue that was unclassified in
any service-level report — invisible in Xero's UI, visible
immediately in SQL.

**What this repo contains:**
- Pipeline architecture and build documentation
- Revenue analysis across three dimensions (client, service, region)
- Data quality audit with business recommendations
- SQL query library with output CSVs
- Looker Studio dashboard directly connected to BigQuery


**Stack:** Xero Demo Company → Fivetran (Free) dbt → BigQuery → SQlite → Data Studio <br>
**Built:** May 6, 2026 | **Infrastructure cost:** $0 <br>
[Jump to 80 second walkthrough gif](assets/walkthrough_xero_bigquery_fivetran.gif)

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
10. [Relevant Documents List](#10-relevant-documents-list)


---

## 1. Problem

Xero is designed for accounting. It handles invoicing, reconciliation, and financial reporting well. What it is not designed for is open-ended analysis across all your records at once. 

Questions that matter to a growing business — which clients drive the most revenue, which services are most profitable, whether regional performance is improving — require data from across multiple invoices, clients, and time periods simultaneously.

The standard workaround is manual: export CSVs from Xero, consolidate in a spreadsheet, and rebuild the analysis each reporting period. The process is time-consuming, and error-prone.

There is a second, less visible problem: Xero does not flag its own data quality gaps. Missing service codes and unassigned region tags appear as blank fields in individual invoices — easy to miss in the UI, impossible to quantify without querying across all records at once. By the time a business notices, months of revenue have been misclassified.

[Back to Table of Contents](#table-of-contents)

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

[Back to Table of Contents](#table-of-contents)

---

## 3. Findings

Two categories of findings emerged from the first sync.

### Revenue Concentration

| Client | Revenue | % of Revenue |
|--------|---------|--------------|
| Ridgeway University | $12,375 | 47.3% |
| Hamilton Smith Ltd | $2,050 | 7.8% |
| Rex Media Group | $1,550 | 5.9% |
| Boom FM | $1,500 | 5.7% |
| Petrie McLoud Watson & Associates | $1,300 | 5.0% |
| Bank West | $1,200 | 4.6% |
| City Limousines | $1,120 | 4.3% |
| 7 other clients | $5,077 | 19.4% |


Loss of the largest single client eliminates almost half of revenue. The rest of the clients collectively generate less than the top client alone.

### Data Quality Gaps

62% of line items have at least one missing field — either no service code, no region tag, or both. This includes $12,375 attributed to the largest client, which appears as "Unclassified" in any service-level report.

→ [Full revenue analysis with SQL queries](docs/revenue_insights_with_sql_code.md)  
→ [Full data quality findings and action checklist](docs/data_quality_findings.md)

[Back to Table of Contents](#table-of-contents)

---

## 4. Applicability

This pipeline applies to any business running on Xero — or similar cloud accounting software — where monthly reporting still depends on manual CSV exports, spreadsheet consolidation, or built-in reports that cannot answer cross-invoice questions.

The specific problems it will solve:

- Categorizing revenue correctly
- Ability to segment revenue by region or service id
- Cross-client, cross-period analysis 

The pipeline manages its own schedule and runs automatically after setup. 
This pipeline is designed for analytical queries across historical data — revenue trends, client mix, service performance — not for real-time workflow automation.

[Back to Table of Contents](#table-of-contents)

---

## 5. How It Works

The pipeline connects Xero, Fivetran, and BigQuery through a one-time setup. After setup, no ongoing management is required for routine operations.  [Click here for Fivetran's github repo on its xero dbt transformations.](https://github.com/fivetran/dbt_xero)

Three datasets land in BigQuery automatically:

```
xero            Raw data from Xero API (34 tables)
xero_staging    Cleaned and standardized (18 tables)
xero_reports    Analytics-ready reporting model (1 table)
```

The reporting table — `xero__invoice_line_items` — joins invoice headers, line items, chart of accounts, contact names, and region tracking into a single queryable surface.

**Known constraint:** Xero moved to granular OAuth scopes after April 29, 2026. Apps created after this date cannot access journal endpoints. General ledger, P&L, and balance sheet models were therefore unavailable for this build. This is a Xero platform change, not a configuration error. Invoice-based analysis — which covers revenue, data quality, and client analytics — was unaffected.

**Schema and dbt**

The full schema — all tables, columns, and foreign key relationships across all Xero organization types — is documented in the [Fivetran Xero ERD.]( https://fivetran.com/connector-erd/xero) Tables that did not sync in this deployment reflect org-type and OAuth scope constraints, not gaps in the connector itself.

* Gold layer produced by: fivetran/dbt_xero (open source)
* Package version: 0.9.0
* Model produced: xero__invoice_line_items
* Reason other models skipped: journal and journal_line
tables unavailable due to Xero Demo Company Global API scope change (post April 29, 2026)


[Full build steps, IAM configuration, and OAuth setup](docs/pipeline_technical_brief.md)

[Process Walkthrough 80 second gif](https://github.com/SandyGCabanes/Xero-Fivetran-BigQuery-Pipeline/blob/main/assets/walkthrough_xero_bigquery_fivetran.gif)

[Back to Table of Contents](#table-of-contents)

---

## 6. Revenue Analysis

### Finding 1 — Revenue Is Heavily Concentrated in Three Clients

**Action:** Protect top-tier relationships proactively. Direct growth efforts toward mid-tier clients (ranks 6–15) before pursuing new client acquisition.

### Finding 2 — CRM Projects Are the Highest-Value Service Line

**Action:** Formalize CRM project management as a named service. Use the recurring support base ($5,600/month) as the operational floor while growing project revenue.

[Back to Table of Contents](#table-of-contents)

---

## 7. Data Quality Findings

A single audit query across all 34 revenue line items surfaced the following:

**Issue 1** — Largest Client Has No Service Code (Financial impact: $12,375<br>
**Action:** Create item code `CRM-PROJ`. Apply retroactively to INV-0009 and INV-0025.  
**Suggested KPI** No unclassified revenue above $1,000.

**Issue 2** — Recurring Support Invoices Missing Region(Affected records: 17 line items)<br>
**Action:** Set Region as required in Tracking Categories. Update recurring invoice template with default region per client.  
**Suggested KPI:** Unassigned regional revenue below 5% within 90 days.

**Issue 3** — Two Small Invoices Unclassified (Financial impact: $841)<br>
**Action:** Create item codes `CONSULT` and `MKTG-MAT`. Apply going forward.

**Recommended Weekly Monitoring Query for KPIs** <br>
Tracking Missing Item Code, Missing Region


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

[Back to Table of Contents](#table-of-contents)

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

[Back to Table of Contents](#table-of-contents)

---

## 10. Relevant Documents List

| Document | Contents |
|----------|----------|
| [Pipeline Technical Brief](docs/pipeline_technical_brief.md) | Architecture, IAM setup, OAuth, build steps, constraints |
| [Revenue Insights](docs/revenue_insights_with_sql_code.md) | Full analysis with SQL queries and output tables |
| [Data Quality Findings](docs/data_quality_findings.md) | Full audit, affected records, action checklist |

### Query Library (Includes query outputs as /**/ in sql file)

| Query | File |
|-------|------|
| Revenue by customer | [queries/revenue_by_customer.sql](queries/sqlite_revenue_by_customer.sql) |
| Revenue by service type | [queries/revenue_by_service.sql](queries/sqlite_service_code_fix.sql) |
| Revenue by region | [queries/revenue_by_region.sql](queries/sqlite_revenue_by_region.sql) |
| Data quality audit | [queries/data_quality_flags.sql](queries/sqlite_data_quality.sql) |

[**Data Studio Dashboard Directly Connected to Big Query**](assets/Dashboard_Xero_Demo_Company_(BQ_connection).pdf)

> *Note: Google renamed Looker Studio back to Data Studio 
in April 2026. Both names refer to the same product. 
This repo uses the current name: Data Studio.*

---

**Sandy G. Cabanes**  
Freelance Data Analyst and Pipeline Developer | Philippines

- GitHub: [SandyGCabanes](https://github.com/SandyGCabanes)
- LinkedIn: [linkedin.com/in/sandygcabanes](https://linkedin.com/in/sandygcabanes)


