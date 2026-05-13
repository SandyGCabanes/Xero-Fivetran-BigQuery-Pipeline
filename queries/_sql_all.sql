-- Full sql codes

-- -------------------
-- Section 1: Bronze
-- -------------------


-- -------------------------------------------------
-- Batch 1 of 3
-- Create staging bronze table in case of duplicates
-- -------------------------------------------------
CREATE OR REPLACE TABLE workspace.default.traffic_bronze_stg AS
WITH parsed_documents AS (
  SELECT
    path,
    ai_parse_document(
      content,
      map(
        'version', '2.0',
        'descriptionElementTypes', '*'
        -- ,'imageOutputPath', '<UC Volume path>'
      )
    ) as parsed
  FROM (
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT-2012.pdf', format => 'binaryFile')
    UNION ALL
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT-2013.pdf', format => 'binaryFile')
    UNION ALL
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT-2014.pdf', format => 'binaryFile')
    UNION ALL
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT-2015 .pdf', format => 'binaryFile')
    UNION ALL
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT-2016.pdf', format => 'binaryFile')
  )
)
SELECT path, 
REGEXP_EXTRACT(path, '(\\d{4})', 1)::INT AS survey_year,
parsed
FROM parsed_documents;

SELECT *
FROM workspace.default.traffic_bronze_stg;


-- -------------------------
-- Batch 2 insert into table
-- -------------------------
INSERT INTO workspace.default.traffic_bronze_stg
WITH parsed_documents AS (
  SELECT
    path,
    ai_parse_document(
      content,
      map(
        'version', '2.0',
        'descriptionElementTypes', '*'
        -- ,'imageOutputPath', '<UC Volume path>'
      )
    ) as parsed
  FROM (
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT-2017.pdf', format => 'binaryFile')
    UNION ALL
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT-2018.pdf', format => 'binaryFile')
    UNION ALL
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT_2019.pdf', format => 'binaryFile')
    UNION ALL
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT_2020.pdf', format => 'binaryFile')
    UNION ALL
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT_2021.pdf', format => 'binaryFile')
  )
)

SELECT
    path,
    REGEXP_EXTRACT(path, '(\\d{4})', 1)::INT AS survey_year,
    parsed
FROM parsed_documents;


SELECT *
FROM workspace.default.traffic_bronze_stg;

-- Duplicates from previous were included

-- Create deduplicated bronze as traffic_bronze (partial)
CREATE OR REPLACE TABLE workspace.default.traffic_bronze AS
SELECT path, survey_year, parsed
FROM (SELECT *,
ROW_NUMBER() OVER (PARTITION BY survey_year ORDER BY path) AS rownum
FROM workspace.default.traffic_bronze_stg)
WHERE rownum = 1;

SELECT *
FROM workspace.default.traffic_bronze;


-- -------------------------
-- Batch 3 insert into table
-- -------------------------
INSERT INTO workspace.default.traffic_bronze_stg
WITH parsed_documents AS (
  SELECT
    path,
    ai_parse_document(
      content,
      map(
        'version', '2.0',
        'descriptionElementTypes', '*'
        -- ,'imageOutputPath', '<UC Volume path>'
      )
    ) as parsed
  FROM (
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT_2022.pdf', format => 'binaryFile')
    UNION ALL
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT_2023.pdf', format => 'binaryFile')
    UNION ALL
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT_2024.pdf', format => 'binaryFile')
    UNION ALL
    SELECT path, content FROM read_files('/Volumes/workspace/default/mmda/AADT_2025.pdf', format => 'binaryFile')
  )
)

SELECT
    path,
    REGEXP_EXTRACT(path, '(\\d{4})', 1)::INT AS survey_year,
    parsed
FROM parsed_documents;


SELECT *
FROM workspace.default.traffic_bronze_stg;

-- Create deduplicated bronze as traffic_bronze
CREATE OR REPLACE TABLE workspace.default.traffic_bronze AS
SELECT path, survey_year, parsed
FROM (SELECT *,
ROW_NUMBER() OVER (PARTITION BY survey_year ORDER BY path) AS rownum
FROM workspace.default.traffic_bronze_stg)
WHERE rownum = 1;

SELECT *
FROM workspace.default.traffic_bronze;


-- -----------------------
-- Drop traffic_bronze_stg
-- -----------------------
DROP TABLE IF EXISTS workspace.default.traffic_bronze_stg;

-- ------------------------
-- Section 2: HTML tables
-- ------------------------

-- Extract only the tables in the pdfs
-- WHERE el.value:type::STRING = 'table';

CREATE OR REPLACE TABLE traffic_html_tables AS
SELECT
    path,
    survey_year,
    el.value:id::INT           AS element_id,
    el.value:content::STRING   AS table_html
FROM traffic_bronze,
LATERAL VARIANT_EXPLODE(parsed:document:elements) AS el
WHERE el.value:type::STRING = 'table';


SELECT *
FROM traffic_html_tables;


-- ------------------------
-- Section 3: Silver tables
-- ------------------------

-- As of May 2026, we need to follow the documentation sample
-- for ai_extract() function


CREATE OR REPLACE TABLE traffic_silver AS
WITH extracted AS (
    SELECT
        path,
        survey_year,
        element_id,
        ai_extract(
            table_html,
            '{
                "rows": {
                    "type": "array",
                    "description": "All data rows from this HTML traffic volume table, excluding any TOTAL summary row",
                    "items": {
                        "type": "object",
                        "properties": {
                            "code":     {"type": "string", "description": "Road code e.g. C:1 R:6. Empty string if blank."},
                            "road_name":{"type": "string", "description": "Road name e.g. EDSA, RECTO, ROXAS BLVD."},
                            "car":      {"type": "string", "description": "CAR vehicle count, empty string if absent"},
                            "puj":      {"type": "string", "description": "PUJ vehicle count, empty string if absent"},
                            "uv":       {"type": "string", "description": "UV vehicle count, empty string if column absent"},
                            "taxi":     {"type": "string", "description": "TAXI vehicle count, empty string if column absent"},
                            "pub":      {"type": "string", "description": "PUB or BUS vehicle count, empty string if absent"},
                            "truck":    {"type": "string", "description": "TRUCK vehicle count, empty string if absent"},
                            "trailer":  {"type": "string", "description": "TRAILER vehicle count, empty string if absent"},
                            "mc":       {"type": "string", "description": "MC motorcycle count, empty string if absent"},
                            "tricycle": {"type": "string", "description": "TRICYCLE or TRI count, empty string if absent"},
                            "total":    {"type": "string", "description": "TOTAL vehicle count, empty string if absent"}
                        }
                    }
                }
            }',
            map('version', '2.0')
        ):response.rows AS extracted_rows
    FROM traffic_html_tables
),
exploded AS (
    SELECT
        path,
        survey_year,
        element_id,
        road_row.value:code::STRING      AS road_code_raw,
        road_row.value:road_name::STRING AS road_name,
        road_row.value:car::STRING       AS car,
        road_row.value:puj::STRING       AS puj,
        road_row.value:uv::STRING        AS uv,
        road_row.value:taxi::STRING      AS taxi,
        road_row.value:pub::STRING       AS pub,
        road_row.value:truck::STRING     AS truck,
        road_row.value:trailer::STRING   AS trailer,
        road_row.value:mc::STRING        AS mc,
        road_row.value:tricycle::STRING  AS tricycle,
        road_row.value:total::STRING     AS total
    FROM extracted,
    LATERAL VARIANT_EXPLODE(extracted_rows) AS road_row
    WHERE road_row.value:road_name::STRING IS NOT NULL
      AND road_row.value:road_name::STRING != ''
      AND UPPER(road_row.value:road_name::STRING) != 'TOTAL'
)
SELECT
    ROW_NUMBER() OVER (PARTITION BY path ORDER BY road_name) AS row_seq,
    path,
    survey_year,
    element_id,
    -- Apply domain knowledge corrections for known misassigned or uncoded roads
    CASE road_name
        WHEN 'PRES. QUIRINO AVE.'  THEN 'C:2'
        WHEN 'PRES. QUIRINO'       THEN 'C:2'
        WHEN 'AURORA BLVD.'        THEN 'R:6'
        WHEN 'COMMONWEALTH AVE.'   THEN 'R:7'
        WHEN 'MARCOS HIGHWAY'      THEN 'Uncoded'
        WHEN 'MARCOS HWY.'         THEN 'Uncoded'
        WHEN 'MCARTHUR HIGHWAY'    THEN 'Uncoded'
        WHEN 'MCARTHUR HWY.'       THEN 'Uncoded'
        ELSE road_code_raw
    END AS road_code,
    road_name,
    car, puj, uv, taxi, pub, truck, trailer, mc, tricycle, total
FROM exploded;

-- ----------------------
-- STANDARDIZE ROAD NAMES
-- ----------------------
SELECT 
  row_seq,
  path,
  survey_year,
  element_id,
  road_code,
  car,
  puj,
  uv,
  taxi,
  pub,
  truck,
  trailer,
  mc,
  tricycle,
  total,
  CASE
    WHEN road_name LIKE '%EDSA%' THEN 'EDSA'
    WHEN road_name LIKE '%KATIPUNAN%' THEN 'KATIPUNAN'
    WHEN road_name LIKE '%MARCOS%' THEN 'MARCOS HIGHWAY'
    WHEN road_name LIKE '%MCARTHUR%' THEN 'MCARTHUR'
    WHEN road_name LIKE '%PRES. QUIRINO%' THEN 'PRES. QUIRINO AVE.'
    ELSE road_name
  END AS road_name
FROM workspace.default.traffic_silver;


-- -----------------
-- Verify
-- -----------------
SELECT *
FROM traffic_silver;

-- ------------------
-- Section 4: Gold
-- ------------------

-- We turn all the texts into integers
CREATE OR REPLACE TABLE fr_ed_traffic_gold AS
SELECT
    path,
    survey_year,
    element_id,
    row_seq,
    LAST_VALUE(NULLIF(road_code, ''), TRUE) IGNORE NULLS
        OVER (PARTITION BY path ORDER BY row_seq) AS road_code,
    road_name,
    TRY_CAST(REPLACE(car,      ',', '') AS INT) AS car,
    TRY_CAST(REPLACE(puj,      ',', '') AS INT) AS puj,
    TRY_CAST(REPLACE(uv,       ',', '') AS INT) AS uv,
    TRY_CAST(REPLACE(taxi,     ',', '') AS INT) AS taxi,
    TRY_CAST(REPLACE(pub,      ',', '') AS INT) AS pub,
    TRY_CAST(REPLACE(truck,    ',', '') AS INT) AS truck,
    TRY_CAST(REPLACE(trailer,  ',', '') AS INT) AS trailer,
    TRY_CAST(REPLACE(mc,       ',', '') AS INT) AS mc,
    TRY_CAST(REPLACE(tricycle, ',', '') AS INT) AS tricycle,
    TRY_CAST(REPLACE(total,    ',', '') AS INT) AS total,
    CURRENT_TIMESTAMP()                         AS processed_at
FROM traffic_silver
ORDER BY survey_year, row_seq;

SELECT *
FROM fr_ed_traffic_gold;

-- ---------------------
-- Section 5: Validation
-- ---------------------
-- Now we validate the math vs. the extracted data
CREATE OR REPLACE TABLE validation_gold AS
SELECT
    survey_year,
    road_code,
    road_name,
    car + puj + uv + taxi + pub + truck + trailer + mc + tricycle AS computed_total,
    total                                                          AS reported_total,
    total - (car + puj + uv + taxi + pub + truck + trailer + mc + tricycle) AS discrepancy
FROM fr_ed_traffic_gold
WHERE total IS NOT NULL
ORDER BY ABS(total - (car + puj + uv + taxi + pub + truck + trailer + mc + tricycle)) DESC;

SELECT *
FROM validation_gold;

-- ----------
-- inspect
-- ----------
SELECT * FROM  validation_gold
WHERE discrepancy IS NOT NULL
AND discrepancy <> 0;

/**
-- Findings
-- 1. ACTION: Replace these in traffic gold 
-- -- 2025; PRES. QURINO AVE. car value 79284 -> 79264
-- 2. NO ACTION: 2025, TAFT AVE. total likely human error
-- 3. NO ACTION: 2022 EDSA total likely human error
-- 4. NO ACTION: 2022 QUEZON AVE. total likely human error
**/

-- OCR misread correction: source PDF shows 79,264 not 79,284
UPDATE fr_ed_traffic_gold
SET car = 79264,
    processed_at = CURRENT_TIMESTAMP()
WHERE survey_year = 2025
  AND road_name = 'PRES. QUIRINO AVE.';
  
-- ------------------------------------------
-- Section 6: Total Row Validation (Optional)
-- ------------------------------------------

-- -----------------------
-- Extract the 'Total' row
-- -----------------------

-- Not extracted in bronze to reduce complexity
-- No need since SQL Sum(car) etc will be used in metric views anyway
-- Extracted here separately

CREATE OR REPLACE TABLE traffic_total_row_extract AS
WITH extracted AS (
    SELECT
        path,
        survey_year,
        ai_extract(
            table_html,
            '{
                "total_row": {
                    "type": "object",
                    "description": "Only the TOTAL summary row at the bottom of the table",
                    "properties": {
                        "car":      {"type": "string"},
                        "puj":      {"type": "string"},
                        "uv":       {"type": "string"},
                        "taxi":     {"type": "string"},
                        "pub":      {"type": "string"},
                        "truck":    {"type": "string"},
                        "trailer":  {"type": "string"},
                        "mc":       {"type": "string"},
                        "tricycle": {"type": "string"},
                        "total":    {"type": "string"}
                    }
                }
            }',
            map('version', '2.0')
        ):response.total_row AS total_row
    FROM traffic_html_tables
)
SELECT
    path,
    survey_year,
    TRY_CAST(REPLACE(total_row:car::STRING,      ',', '') AS INT) AS total_car,
    TRY_CAST(REPLACE(total_row:puj::STRING,      ',', '') AS INT) AS total_puj,
    TRY_CAST(REPLACE(total_row:uv::STRING,       ',', '') AS INT) AS total_uv,
    TRY_CAST(REPLACE(total_row:taxi::STRING,     ',', '') AS INT) AS total_taxi,
    TRY_CAST(REPLACE(total_row:pub::STRING,      ',', '') AS INT) AS total_pub,
    TRY_CAST(REPLACE(total_row:truck::STRING,    ',', '') AS INT) AS total_truck,
    TRY_CAST(REPLACE(total_row:trailer::STRING,  ',', '') AS INT) AS total_trailer,
    TRY_CAST(REPLACE(total_row:mc::STRING,       ',', '') AS INT) AS total_mc,
    TRY_CAST(REPLACE(total_row:tricycle::STRING, ',', '') AS INT) AS total_tricycle,
    TRY_CAST(REPLACE(total_row:total::STRING,    ',', '') AS INT) AS grand_total
FROM extracted;

-- --------------------------------------
-- Check the 'Total' row vs. calculations
-- --------------------------------------

CREATE OR REPLACE TABLE traffic_totals_check AS
SELECT
    g.survey_year,
    SUM(g.car)       AS gold_car,       t.total_car,       SUM(g.car)       - t.total_car       AS car_diff,
    SUM(g.puj)       AS gold_puj,       t.total_puj,       SUM(g.puj)       - t.total_puj       AS puj_diff,
    SUM(g.uv)        AS gold_uv,        t.total_uv,        SUM(g.uv)        - t.total_uv        AS uv_diff,
    SUM(g.taxi)      AS gold_taxi,      t.total_taxi,      SUM(g.taxi)      - t.total_taxi      AS taxi_diff,
    SUM(g.pub)       AS gold_pub,       t.total_pub,       SUM(g.pub)       - t.total_pub       AS pub_diff,
    SUM(g.truck)     AS gold_truck,     t.total_truck,     SUM(g.truck)     - t.total_truck     AS truck_diff,
    SUM(g.trailer)   AS gold_trailer,   t.total_trailer,   SUM(g.trailer)   - t.total_trailer   AS trailer_diff,
    SUM(g.mc)        AS gold_mc,        t.total_mc,        SUM(g.mc)        - t.total_mc        AS mc_diff,
    SUM(g.tricycle)  AS gold_tricycle,  t.total_tricycle,  SUM(g.tricycle)  - t.total_tricycle  AS tricycle_diff,
    SUM(g.total)     AS gold_total,     t.grand_total,     SUM(g.total)     - t.grand_total     AS total_diff
FROM fr_ed_traffic_gold g
JOIN traffic_total_row_extract t
    ON g.survey_year = t.survey_year
GROUP BY
    g.survey_year,
    t.total_car, t.total_puj, t.total_uv, t.total_taxi, t.total_pub,
    t.total_truck, t.total_trailer, t.total_mc, t.total_tricycle, t.grand_total
ORDER BY g.survey_year;


SELECT *
FROM traffic_totals_check;

/**
-- -------------
-- Verdict
-- -------------
-- The single 1000 discrepancy verified as human error.
-- 2025 tricycle in pdf is 36632, 1000 higher than actual sum.
-- No need to edit extracted tables.  SUM(tri) can be calculated separately.
-- All other rows are correct.
**/


-- ------------------
-- Section 7: Metrics
-- ------------------

-- Create metrics for the dashboard

CREATE OR REPLACE TABLE workspace.default.traffic_metrics AS
SELECT 
  survey_year AS year,
  road_name,
  SUM(total) AS total_volume,
  SUM(car) AS car_volume,
  SUM(mc) AS motorcycle_volume,
  SUM(puj) + SUM(pub) + SUM(taxi) + SUM(uv) +SUM(tricycle) AS puj_pub_taxi_uv_tri,
  SUM(truck) + SUM(trailer) AS truck_volume,
  SUM(mc) * 100.0 / SUM(total) AS motorcycle_share
FROM workspace.default.fr_ed_traffic_gold
GROUP BY survey_year, road_name
ORDER BY survey_year, road_name;


-- Top 10 roads


SELECT
  road_name,
  SUM(total) AS total_volume
FROM
  workspace.default.fr_ed_traffic_gold
WHERE
  survey_year = 2025
GROUP BY
  road_name
ORDER BY
  total_volume DESC
LIMIT 10;

