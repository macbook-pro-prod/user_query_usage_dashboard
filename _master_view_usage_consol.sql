WITH prod_data_center AS (

  SELECT 
    B.query_date,
    A.start_time,
    COALESCE(B.holistics_user_email, A.user_email) AS user_email,
    A.job_type,
    A.statement_type,
    COALESCE(B.total_bytes_billed_leaf, A.total_bytes_billed) AS total_bytes_billed,
    A.labels,
    A.consumption_category,
    A.consumption_source,
    B.interaction_purpose
  FROM `prod-data-center-platform.ds_dwh01_shared.jobs_by_project` A

  LEFT JOIN `prod-data-center-platform.marts.fct_dataops__bq_jobs_attributed` B
    ON A.job_id = B.job_id
    AND DATE(A.start_time) = B.query_date
    AND B.project_id = 'prod-data-center-platform'
    AND B.query_date >= DATE '2026-04-01'
),


prod_sql_scripting AS (

  SELECT 
    B.query_date,
    A.creation_time AS start_time,
    COALESCE(B.holistics_user_email, A.user_email) AS user_email,
    A.job_type,
    A.statement_type,
    COALESCE(B.total_bytes_billed_leaf, A.total_bytes_billed) AS total_bytes_billed,
    A.labels,
    A.consumption_category,
    A.consumption_source,
    B.interaction_purpose
  FROM `prod-shared-dwh01.ds_dwh01_shared.jobs_by_project_prod_sql_scripting` A

  LEFT JOIN `prod-data-center-platform.marts.fct_dataops__bq_jobs_attributed` B
    ON A.job_id = B.job_id
    AND DATE(A.creation_time) = B.query_date
    AND B.project_id = 'prod-sql-scripting'
    AND B.query_date >= DATE '2026-05-01'
),


prod_dw_dshbd AS (

  SELECT 
    B.query_date,
    A.start_time,
    COALESCE(B.holistics_user_email, A.user_email) AS user_email,
    A.job_type,
    A.statement_type,
    COALESCE(B.total_bytes_billed_leaf, A.total_bytes_billed) AS total_bytes_billed,
    A.labels,
    A.consumption_category,
    A.consumption_source,
    B.interaction_purpose
  FROM `prod-dw-dshbd.ds_dwh01_shared.jobs_by_project` A

  LEFT JOIN `prod-data-center-platform.marts.fct_dataops__bq_jobs_attributed` B
    ON A.job_id = B.job_id
    AND DATE(A.start_time) = B.query_date
    AND B.project_id = 'prod-data-dw-dshbd'
    AND B.query_date >= DATE '2026-08-01'
)


-- =========================================================
-- 1. PROD-DATA-CENTER-PLATFORM
-- Holistics attribution applied
-- =========================================================

SELECT 
  start_time,
  user_email,

  CASE
    WHEN ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Service Account'
    WHEN user_email IS NOT NULL
      THEN 'User'
    ELSE 'Unknown'
  END AS principal_type,

  job_type,
  statement_type,

  total_bytes_billed / (1024 * 1024 * 1024 * 1024) 
    AS total_tb_billed,

  ROUND(
    total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    * 37.07859375,
    2
  ) AS estimated_cost_myr,

  'prod-data-center-platform' AS source_project,

  labels,

  consumption_category,

  CASE 
    WHEN consumption_category IS NULL
      THEN 'Other'
    ELSE consumption_category
  END AS consumption_category_2,

  consumption_source,

  CASE
    WHEN consumption_category = 'Visualization'
      AND interaction_purpose = 'AI'
      THEN 'Holistics - AI'

    WHEN consumption_category = 'Visualization'
      AND interaction_purpose IN (
        'Dashboard',
        'Schedule',
        'Dataset Build'
      )
      THEN 'Holistics - Dashboard'

    WHEN consumption_category = 'Visualization'
      AND interaction_purpose IN (
        'Dataset Explore',
        'Model Query',
        'Ad-hoc',
        'Non-Holistics'
      )
      THEN 'Holistics - Explore'

    WHEN consumption_source IS NULL
      THEN 'Other BigQuery'

    ELSE consumption_source
  END AS consumption_source_2

FROM prod_data_center



UNION ALL


-- =========================================================
-- 2. DEV-SHARED-DWH01
-- Existing direct method
-- =========================================================

SELECT 
  start_time,
  user_email,

  CASE
    WHEN ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Service Account'
    WHEN user_email IS NOT NULL
      THEN 'User'
    ELSE 'Unknown'
  END AS principal_type,

  job_type,
  statement_type,

  total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    AS total_tb_billed,

  ROUND(
    total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    * 37.07859375,
    2
  ) AS estimated_cost_myr,

  'dev-shared-dwh01' AS source_project,

  labels,

  consumption_category,

  CASE 
    WHEN consumption_category IS NULL
      THEN 'Other'
    ELSE consumption_category
  END AS consumption_category_2,

  consumption_source,

  CASE 
    WHEN consumption_source IS NULL
      THEN 'Other BigQuery'
    ELSE consumption_source
  END AS consumption_source_2

FROM `dev-shared-dwh01.ds_dwh01_shared.jobs_by_project`



UNION ALL


-- =========================================================
-- 3. PROD-SHARED-DWH01
-- Existing direct method
-- =========================================================

SELECT 
  start_time,
  user_email,

  CASE
    WHEN ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Service Account'
    WHEN user_email IS NOT NULL
      THEN 'User'
    ELSE 'Unknown'
  END AS principal_type,

  job_type,
  statement_type,

  total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    AS total_tb_billed,

  ROUND(
    total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    * 37.07859375,
    2
  ) AS estimated_cost_myr,

  'prod-shared-dwh01' AS source_project,

  labels,

  consumption_category,

  CASE 
    WHEN consumption_category IS NULL
      THEN 'Other'
    ELSE consumption_category
  END AS consumption_category_2,

  consumption_source,

  CASE 
    WHEN consumption_source IS NULL
      THEN 'Other BigQuery'
    ELSE consumption_source
  END AS consumption_source_2

FROM `prod-shared-dwh01.ds_dwh01_shared.jobs_by_project`



UNION ALL


-- =========================================================
-- 4. PROD-SQL-SCRIPTING
-- Holistics attribution applied
-- =========================================================

SELECT 
  start_time,
  user_email,

  CASE
    WHEN ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Service Account'
    WHEN user_email IS NOT NULL
      THEN 'User'
    ELSE 'Unknown'
  END AS principal_type,

  job_type,
  statement_type,

  total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    AS total_tb_billed,

  ROUND(
    total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    * 37.07859375,
    2
  ) AS estimated_cost_myr,

  'prod-sql-scripting' AS source_project,

  labels,

  consumption_category,

  CASE 
    WHEN consumption_category IS NULL
      THEN 'Other'
    ELSE consumption_category
  END AS consumption_category_2,

  consumption_source,

  CASE
    WHEN consumption_category = 'Visualization'
      AND interaction_purpose = 'AI'
      THEN 'Holistics - AI'

    WHEN consumption_category = 'Visualization'
      AND interaction_purpose IN (
        'Dashboard',
        'Schedule',
        'Dataset Build'
      )
      THEN 'Holistics - Dashboard'

    WHEN consumption_category = 'Visualization'
      AND interaction_purpose IN (
        'Dataset Explore',
        'Model Query',
        'Ad-hoc',
        'Non-Holistics'
      )
      THEN 'Holistics - Explore'

    WHEN consumption_source IS NULL
      THEN 'Other BigQuery'

    ELSE consumption_source
  END AS consumption_source_2

FROM prod_sql_scripting



UNION ALL


-- =========================================================
-- 5. PROD-RAW-LANDING
-- Existing direct method
-- =========================================================

SELECT 
  start_time,
  user_email,

  CASE
    WHEN ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Service Account'
    WHEN user_email IS NOT NULL
      THEN 'User'
    ELSE 'Unknown'
  END AS principal_type,

  job_type,
  statement_type,

  total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    AS total_tb_billed,

  ROUND(
    total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    * 37.07859375,
    2
  ) AS estimated_cost_myr,

  'prod-raw-landing' AS source_project,

  labels,

  consumption_category,

  CASE 
    WHEN consumption_category IS NULL
      THEN 'Other'
    ELSE consumption_category
  END AS consumption_category_2,

  consumption_source,

  CASE 
    WHEN consumption_source IS NULL
      THEN 'Other BigQuery'
    ELSE consumption_source
  END AS consumption_source_2

FROM `prod-raw-landing.ds_dwh01_shared.jobs_by_project`



UNION ALL


-- =========================================================
-- 6. PROD-DW-IWDC
-- Existing direct method
-- =========================================================

SELECT 
  start_time,
  user_email,

  CASE
    WHEN ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Service Account'
    WHEN user_email IS NOT NULL
      THEN 'User'
    ELSE 'Unknown'
  END AS principal_type,

  job_type,
  statement_type,

  total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    AS total_tb_billed,

  ROUND(
    total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    * 37.07859375,
    2
  ) AS estimated_cost_myr,

  'prod-dw-iwdc' AS source_project,

  labels,

  consumption_category,

  CASE 
    WHEN consumption_category IS NULL
      THEN 'Other'
    ELSE consumption_category
  END AS consumption_category_2,

  consumption_source,

  CASE 
    WHEN consumption_source IS NULL
      THEN 'Other BigQuery'
    ELSE consumption_source
  END AS consumption_source_2

FROM `prod-dw-iwdc.ds_dwh01_shared.jobs_by_project`



UNION ALL


-- =========================================================
-- 7. PROD-DW-DSHBD
-- Holistics attribution applied
-- =========================================================

SELECT 
  start_time,
  user_email,

  CASE
    WHEN ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Service Account'
    WHEN user_email IS NOT NULL
      THEN 'User'
    ELSE 'Unknown'
  END AS principal_type,

  job_type,
  statement_type,

  total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    AS total_tb_billed,

  ROUND(
    total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    * 37.07859375,
    2
  ) AS estimated_cost_myr,

  'prod-dw-dshbd' AS source_project,

  labels,

  consumption_category,

  CASE 
    WHEN consumption_category IS NULL
      THEN 'Other'
    ELSE consumption_category
  END AS consumption_category_2,

  consumption_source,

  CASE
    WHEN consumption_category = 'Visualization'
      AND interaction_purpose = 'AI'
      THEN 'Holistics - AI'

    WHEN consumption_category = 'Visualization'
      AND interaction_purpose IN (
        'Dashboard',
        'Schedule',
        'Dataset Build'
      )
      THEN 'Holistics - Dashboard'

    WHEN consumption_category = 'Visualization'
      AND interaction_purpose IN (
        'Dataset Explore',
        'Model Query',
        'Ad-hoc',
        'Non-Holistics'
      )
      THEN 'Holistics - Explore'

    WHEN consumption_source IS NULL
      THEN 'Other BigQuery'

    ELSE consumption_source
  END AS consumption_source_2

FROM prod_dw_dshbd



UNION ALL


-- =========================================================
-- 8. PROD-DW-RMN
-- Existing direct method
-- No Holistics attribution
-- =========================================================

SELECT 
  start_time,
  user_email,

  CASE
    WHEN ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Service Account'
    WHEN user_email IS NOT NULL
      THEN 'User'
    ELSE 'Unknown'
  END AS principal_type,

  job_type,
  statement_type,

  total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    AS total_tb_billed,

  ROUND(
    total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    * 37.07859375,
    2
  ) AS estimated_cost_myr,

  'prod-dw-rmn' AS source_project,

  labels,

  consumption_category,

  CASE 
    WHEN consumption_category IS NULL
      THEN 'Other'
    ELSE consumption_category
  END AS consumption_category_2,

  consumption_source,

  CASE 
    WHEN consumption_source IS NULL
      THEN 'Other BigQuery'
    ELSE consumption_source
  END AS consumption_source_2

FROM `prod-dw-rmn.ds_dwh01_shared.jobs_by_project`


UNION ALL


-- =========================================================
-- 9. PROD-DW-ID
-- Existing direct method
-- No Holistics attribution
-- =========================================================

SELECT 
  start_time,
  user_email,

  CASE
    WHEN ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Service Account'
    WHEN user_email IS NOT NULL
      THEN 'User'
    ELSE 'Unknown'
  END AS principal_type,

  job_type,
  statement_type,

  total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    AS total_tb_billed,

  ROUND(
    total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    * 37.07859375,
    2
  ) AS estimated_cost_myr,

  'prod-dw-id' AS source_project,

  labels,

  consumption_category,

  CASE 
    WHEN consumption_category IS NULL
      THEN 'Other'
    ELSE consumption_category
  END AS consumption_category_2,

  consumption_source,

  CASE 
    WHEN consumption_source IS NULL
      THEN 'Other BigQuery'
    ELSE consumption_source
  END AS consumption_source_2

FROM `prod-dw-id.ds_dwh01_shared.jobs_by_project`



UNION ALL


-- =========================================================
-- 10. PROD-DW-TH
-- Existing direct method
-- No Holistics attribution
-- =========================================================

SELECT 
  start_time,
  user_email,

  CASE
    WHEN ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Service Account'
    WHEN user_email IS NOT NULL
      THEN 'User'
    ELSE 'Unknown'
  END AS principal_type,

  job_type,
  statement_type,

  total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    AS total_tb_billed,

  ROUND(
    total_bytes_billed / (1024 * 1024 * 1024 * 1024)
    * 37.07859375,
    2
  ) AS estimated_cost_myr,

  'prod-dw-th' AS source_project,

  labels,

  consumption_category,

  CASE 
    WHEN consumption_category IS NULL
      THEN 'Other'
    ELSE consumption_category
  END AS consumption_category_2,

  consumption_source,

  CASE 
    WHEN consumption_source IS NULL
      THEN 'Other BigQuery'
    ELSE consumption_source
  END AS consumption_source_2

FROM `prod-dw-th.ds_dwh01_shared.jobs_by_project`;