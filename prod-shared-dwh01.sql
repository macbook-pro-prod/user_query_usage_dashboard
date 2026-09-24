-- Add new columns first
ALTER TABLE `prod-shared-dwh01.ds_dwh01_shared.jobs_by_project` 
ADD COLUMN labels ARRAY<STRUCT<key STRING, value STRING>>,
ADD COLUMN consumption_category STRING,
ADD COLUMN consumption_source STRING;

-- Start to backfilling the historical data with the new schema and classification logic

BEGIN TRANSACTION;

-- 1. Delete the historical period that will be rebuilt
DELETE FROM `prod-shared-dwh01.ds_dwh01_shared.jobs_by_project` -- change to certain project to backfilling
WHERE DATE(start_time, 'Asia/Kuala_Lumpur')
  BETWEEN DATE_SUB(CURRENT_DATE('Asia/Kuala_Lumpur'), INTERVAL 175 DAY)
      AND DATE_SUB(CURRENT_DATE('Asia/Kuala_Lumpur'), INTERVAL 1 DAY); -- range of date if needed to change
-- WHERE DATE(start_time, 'Asia/Kuala_Lumpur') = DATE '2026-09-13';


-- 2. Reinsert the same period with the new schema and classification logic
INSERT INTO `prod-shared-dwh01.ds_dwh01_shared.jobs_by_project` -- change to certain project to backfilling
(
  start_time,
  user_email,
  job_type,
  statement_type,
  total_bytes_billed,
  labels,
  consumption_category,
  consumption_source
)

SELECT
  creation_time AS start_time,
  user_email,
  job_type,
  statement_type,
  total_bytes_billed,
  labels,

  -- =========================================================
  -- CONSUMPTION CATEGORY
  -- =========================================================
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'requestor'
        AND l.value = 'looker_studio'
    )
      THEN 'Visualization'

    WHEN user_email = 'holistics-sa@prod-data-center-platform.iam.gserviceaccount.com'
      THEN 'Visualization'

    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'dbt_invocation_id'
    )
      THEN 'Data Processing'

    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'data_source_id'
        AND l.value = 'scheduled_query'
    )
      THEN 'Data Processing'

    WHEN user_email IS NOT NULL
      AND NOT ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Ad Hoc / Manual'
      
    -- Truly unidentified
    ELSE 'Other'
  END AS consumption_category,

  -- =========================================================
  -- CONSUMPTION SOURCE
  -- =========================================================
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'requestor'
        AND l.value = 'looker_studio'
    )
      THEN 'Looker Studio'

    WHEN user_email = 'holistics-sa@prod-data-center-platform.iam.gserviceaccount.com'
      THEN 'Holistics'

    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'dbt_invocation_id'
    )
      THEN 'dbt'

    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'data_source_id'
        AND l.value = 'scheduled_query'
    )
      THEN 'Scheduled Query'

    WHEN user_email IS NOT NULL
      AND NOT ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'User Query'

    ELSE 'Other BigQuery'
  END AS consumption_source

FROM `prod-shared-dwh01.region-asia-southeast1.INFORMATION_SCHEMA.JOBS_BY_PROJECT` -- change to certain project to backfilling

WHERE total_bytes_processed <> 0
  AND state = 'DONE'

  AND DATE(creation_time, 'Asia/Kuala_Lumpur')
    BETWEEN DATE_SUB(CURRENT_DATE('Asia/Kuala_Lumpur'), INTERVAL 175 DAY)
        AND DATE_SUB(CURRENT_DATE('Asia/Kuala_Lumpur'), INTERVAL 1 DAY) -- date need to change if required to
  -- AND DATE(creation_time, 'Asia/Kuala_Lumpur') = DATE '2026-09-13'

  AND job_id NOT IN (
    SELECT parent_job_id
    FROM `prod-shared-dwh01.region-asia-southeast1.INFORMATION_SCHEMA.JOBS_BY_PROJECT` -- change to certain project to backfilling
    WHERE parent_job_id IS NOT NULL
      AND DATE(creation_time, 'Asia/Kuala_Lumpur')
        BETWEEN DATE_SUB(CURRENT_DATE('Asia/Kuala_Lumpur'), INTERVAL 175 DAY)
            AND DATE_SUB(CURRENT_DATE('Asia/Kuala_Lumpur'), INTERVAL 1 DAY) -- range of date if required to make amendment 
      -- AND DATE(creation_time, 'Asia/Kuala_Lumpur') = DATE '2026-09-13'
  );

COMMIT TRANSACTION;
