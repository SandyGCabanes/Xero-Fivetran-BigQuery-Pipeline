# Xero → Fivetran → BigQuery Pipeline
## Technical Brief for Decision Makers
**Prepared by:** Sandy G. Cabanes  
**Date:** May 6, 2026

---

## What Was Built

A three-layer data pipeline that automatically moves your Xero
accounting data into a cloud data warehouse, where it can be
queried, analyzed, and connected to any reporting tool.

```
LAYER 1 — Ingestion
Xero (source) ──► Fivetran ──► BigQuery

LAYER 2 — Transformation (automatic)
BigQuery raw tables ──► dbt models ──► clean reporting tables

LAYER 3 — Analysis
BigQuery reporting tables ──► SQL / Tableau / Looker Studio
```

The pipeline runs on a schedule. Once set up, it requires
no manual intervention for routine syncs.

---

## How Complex Is This to Set Up?

**Initial setup: moderate complexity, one-time effort.**

The setup involves four systems that need to talk to each other.
Each has its own authentication and permissions model.

```
SYSTEM          SETUP TASK                        DIFFICULTY
──────────────────────────────────────────────────────────────
Google Cloud    Create billing-enabled project     Low
                Configure IAM service account      Medium
                Grant BigQuery roles               Medium

Fivetran        Create account                     Low
                Configure BigQuery destination     Low
                Connect Xero as source             Medium
                Select tables to sync              Low

Xero            Register developer app             Medium
                Configure OAuth 2.0 scopes         Medium
                Authorize Fivetran connection       Low

BigQuery        Verify datasets landed             Low
                Validate reporting layer           Low
──────────────────────────────────────────────────────────────
```

**After setup: low complexity.**

The pipeline runs automatically. Fivetran handles:
- Scheduled syncs (daily by default, up to every 5 minutes
  on paid plans)
- API rate limit management
- Schema changes in Xero (new fields are added automatically)
- Sync failure alerts via email
- Retry logic on failed syncs

You do not need to manage any of this day-to-day.

---

## What Are the Moving Parts?

```
                    ┌─────────────────────────────────┐
                    │           FIVETRAN              │
                    │                                 │
  ┌──────────┐      │  ┌─────────┐    ┌───────────┐   │      ┌──────────────┐
  │   XERO   │─────►│  │Connector│───►│Destination│   │─────►│  BIGQUERY    │
  │          │ OAuth│  │  (Xero) │    │  (BQ)     │   │      │              │
  │ Invoices │      │  └─────────┘    └───────────┘   │      │ xero/        │
  │ Contacts │      │                                 │      │ xero_staging/│
  │ Payments │      │  Syncs on schedule              │      │ xero_reports/│
  │ Accounts │      │  Monitors for failures          │      │              │
  └──────────┘      │  Manages schema changes         │      └──────┬───────┘
                    └─────────────────────────────────┘             │
                                                                    │
                    ┌───────────────────────────────────────────────┘
                    │
                    ▼
          ┌──────────────────┐    ┌──────────────────┐
          │  TABLEAU /       │    │  CUSTOM SQL /    │
          │  LOOKER STUDIO   │    │  DATA EXPORTS    │
          └──────────────────┘    └──────────────────┘
```

**Three datasets in BigQuery:**

| Dataset | Contents | Updated by |
|---------|----------|------------|
| `xero` | Raw tables direct from Xero API (34 tables) | Fivetran |
| `xero_staging` | Cleaned, standardized columns (18 tables) | dbt via Fivetran |
| `xero_reports` | Analytics-ready joined tables | dbt via Fivetran |

---

## What Does It Cost?

### Scenario: Typical MSE using Xero actively

Assumptions: ~200 invoices/month, ~500 contacts,
~300 bank transactions, daily sync frequency.

```
FIVETRAN
────────────────────────────────────────────────
Estimated MAR/month    :  ~2,000 - 5,000 rows
Free plan limit        :  500,000 MAR/month
Plan required          :  Free ($0/month)
Connection minimum fee :  $0 on Free plan

Note: Fivetran Free plan covers most MSEs comfortably.
A paid plan ($120/month+) is only needed if you
connect 2+ high-volume sources simultaneously
or require sub-hourly sync frequency.

GOOGLE BIGQUERY
────────────────────────────────────────────────
Storage                :  ~$0  (well under 10GB free tier)
Query compute          :  ~$0  (well under 1TB/month free tier)
Estimated monthly cost :  $0

TOTAL INFRASTRUCTURE COST
────────────────────────────────────────────────
Typical MSE            :  $0/month
High-volume MSE        :  $5 - $50/month
(multiple sources, high transaction volume)
```

### Cost comparison: pipeline vs. manual reporting

```
WITHOUT PIPELINE:
  Staff time to export, clean, and consolidate
  Xero reports monthly             :  4 - 8 hours/month
  At $25-50/hour staff cost        :  $100 - $400/month
  Error rate on manual process     :  high
  Cross-invoice analysis           :  not possible

WITH PIPELINE:
  Infrastructure                   :  $0/month
  Sync runs automatically          :  0 hours/month
  Error rate                       :  near zero
  Cross-invoice analysis           :  immediate
```

---


## What Happens If Fivetran Changes Its Pricing?

Fivetran's pricing has changed twice in 2025-2026. Here is
the risk mitigation:

**Option 1 — Stay on Free plan**
At typical MSE volumes, the Free plan is unlikely to be
discontinued. Fivetran uses it as a market entry product.
Risk: low.

**Option 2 — Switch to Airbyte (open source alternative)**
Airbyte is a free, self-hosted alternative to Fivetran
with a Xero connector. It requires a server to run on
(e.g. a $10/month VPS) but eliminates Fivetran dependency.


**Option 3 — Custom Python pipeline**
A Python script using Xero's API can replicate the ingestion
layer for the specific tables you use. More maintenance
required but zero third-party dependency.

The BigQuery destination and dbt transformation layer
remain the same regardless of which ingestion tool is used.
Switching ingestion tools does not require rebuilding
the warehouse or reports.

---

## What You Own After This Engagement

```
INFRASTRUCTURE (yours, in your accounts):
  ✓  Google Cloud project with BigQuery datasets
  ✓  Fivetran account with configured connector
  ✓  Xero developer app with OAuth credentials
  ✓  Three-layer dataset: raw, staging, reporting

DOCUMENTATION (yours, transferable):
  ✓  Pipeline setup guide (step-by-step, with screenshots)
  ✓  Data quality findings report
  ✓  Revenue insights report
  ✓  SQL query library (revenue by client, service, region)
  ✓  Data quality audit query
  ✓  This technical brief

ACCESS (your team can use immediately):
  ✓  BigQuery console — any analyst can query directly
  ✓  Looker Studio — free, connects to BigQuery in minutes
  ✓  Fivetran dashboard — monitor sync health
```


---

## Minimum Requirements to Run This

If you have an internal IT person or analyst, they can
maintain this with the following:

```
SKILL REQUIRED          LEVEL
────────────────────────────────────────────
Basic SQL               Intermediate
Google Cloud Console    Beginner
Fivetran dashboard      Beginner (UI-driven)
Xero admin access       Beginner
```

Ongoing maintenance does not require a data engineer.
A business analyst comfortable with SQL can handle
day-to-day queries and monthly reporting.

---

## Questions This Pipeline Cannot Answer Yet

Honest limitations of the current setup:

| Question | Gap | What Is Needed |
|----------|-----|----------------|
| Which clients are most profitable? | No time tracking | Harvest, Toggl, or manual timesheet data |
| Which deals converted to revenue? | No CRM data | HubSpot, Zoho, or Pipedrive connector, — setup follows same pipeline pattern|
| What is my cash flow next month? | No forecasting model | Historical data + forecasting layer |
| How do I compare to industry? | No benchmarks | External data source |
| What do my costs look like? | Bills not analyzed yet | Xero bills/expenses pipeline |

Each of these is solvable with an additional data source
or a transformation layer on top of what already exists.

---
*Prepared by Sandy G. Cabanes | sandygcabanes.github.io*  
*Pipeline: Xero → Fivetran → BigQuery | Built: May 6, 2026*  
*Stack: Fivetran Free → BigQuery (GCP) → dbt Quickstart → SQLite / DB Browser*
