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
  consumption_source,
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
  consumption_source,
FROM prod-shared-dwh01.ds_dwh01_shared.jobs_by_project

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
  'prod-data-center-platform' AS source_project,
  labels,
  consumption_category,
  consumption_source,
FROM prod-data-center-platform.ds_dwh01_shared.jobs_by_project


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
  consumption_source,
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
  consumption_source
FROM  prod-raw-landing.ds_dwh01_shared.jobs_by_project -- check for the source of the prod-raw-landing project.


 