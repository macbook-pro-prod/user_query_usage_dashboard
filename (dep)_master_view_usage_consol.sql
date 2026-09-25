WITH prod_data_center AS (

  SELECT 
    B.query_date,
    A.start_time,
    COALESCE(B.holistics_user_email, A.user_email) AS user_email,
    A.job_type,
    A.statement_type,
    -- A.total_bytes_billed,
    COALESCE(B.total_bytes_billed_leaf, A.total_bytes_billed) AS total_bytes_billed,
    A.labels,
    A.consumption_category,
    A.consumption_source,
    B.interaction_purpose
  FROM prod-data-center-platform.ds_dwh01_shared.jobs_by_project A
  RIGHT JOIN `prod-data-center-platform.marts.fct_dataops__bq_jobs_attributed` B 
  ON A.job_id = B.job_id
  AND DATE(A.start_time) = B.query_date
  WHERE B.project_id = 'prod-data-center-platform'
  AND A.consumption_source = 'Holistics' 
  AND B.query_date >= DATE '2026-04-01'
)


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
  (total_bytes_billed) / (1024 * 1024 * 1024 * 1024) AS total_tb_billed,
  ROUND((total_bytes_billed) / (1024 * 1024 * 1024 * 1024) * 37.07859375,2)  AS estimated_cost_myr, --37.07859375 MYR per 1 tebibyte
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

FROM prod_data_center --prod-data-center-platform.ds_dwh01_shared.jobs_by_project


UNION ALL

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
  (total_bytes_billed) / (1024 * 1024 * 1024 * 1024) AS total_tb_billed,
  ROUND((total_bytes_billed) / (1024 * 1024 * 1024 * 1024) * 37.07859375,2)  AS estimated_cost_myr, --37.07859375 MYR per 1 tebibyte
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
  END AS consumption_source_2,
FROM dev-shared-dwh01.ds_dwh01_shared.jobs_by_project

UNION ALL

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
  (total_bytes_billed) / (1024 * 1024 * 1024 * 1024) AS total_tb_billed,
  ROUND((total_bytes_billed) / (1024 * 1024 * 1024 * 1024) * 37.07859375,2)  AS estimated_cost_myr, --37.07859375 MYR per 1 tebibyte
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
  END AS consumption_source_2,
FROM prod-shared-dwh01.ds_dwh01_shared.jobs_by_project

UNION ALL


SELECT 
  creation_time AS start_time,
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
  (total_bytes_billed) / (1024 * 1024 * 1024 * 1024) AS total_tb_billed,
  ROUND((total_bytes_billed) / (1024 * 1024 * 1024 * 1024) * 37.07859375,2)  AS estimated_cost_myr, --37.07859375 MYR per 1 tebibyte
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
    WHEN consumption_source IS NULL
      THEN 'Other BigQuery'
    ELSE consumption_source
  END AS consumption_source_2,
FROM  prod-shared-dwh01.ds_dwh01_shared.jobs_by_project_prod_sql_scripting

UNION ALL

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
  (total_bytes_billed) / (1024 * 1024 * 1024 * 1024) AS total_tb_billed,
  ROUND((total_bytes_billed) / (1024 * 1024 * 1024 * 1024) * 37.07859375,2)  AS estimated_cost_myr, --37.07859375 MYR per 1 tebibyte
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
  END AS consumption_source_2,
FROM  prod-raw-landing.ds_dwh01_shared.jobs_by_project -- check for the source of the prod-raw-landing project.


UNION ALL

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
  (total_bytes_billed) / (1024 * 1024 * 1024 * 1024) AS total_tb_billed,
  ROUND((total_bytes_billed) / (1024 * 1024 * 1024 * 1024) * 37.07859375,2)  AS estimated_cost_myr, --37.07859375 MYR per 1 tebibyte
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
  END AS consumption_source_2,
FROM  prod-dw-iwdc.ds_dwh01_shared.jobs_by_project -- check for the source of the prod-raw-landing project.


 