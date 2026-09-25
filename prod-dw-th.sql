--author: mac
-- scheduled query


SELECT
  creation_time AS start_time,
  user_email,
  job_id,
  job_type,
  statement_type,
  total_bytes_billed,
  labels,

  -- Consumption Category
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'ca-bq-job'
        AND l.value = 'true'
    )
      THEN 'Visualization'

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

    ELSE 'Other'
  END AS consumption_category,

  -- Consumption Source
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'ca-bq-job'
        AND l.value = 'true'
    )
      THEN 'Conversational Analytics'

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

FROM `prod-dw-th.region-asia-southeast1.INFORMATION_SCHEMA.JOBS_BY_PROJECT` AS j

WHERE total_bytes_processed <> 0
  AND state = 'DONE'

  -- Previous completed day only
  AND DATE(creation_time, 'Asia/Kuala_Lumpur')
      = DATE_SUB(CURRENT_DATE('Asia/Kuala_Lumpur'), INTERVAL 1 DAY)

  -- Exclude parent/script jobs to avoid double counting
  AND NOT EXISTS (
    SELECT 1
    FROM `prod-dw-th.region-asia-southeast1.INFORMATION_SCHEMA.JOBS_BY_PROJECT` AS child
    WHERE child.parent_job_id = j.job_id
      AND DATE(child.creation_time, 'Asia/Kuala_Lumpur')
          = DATE_SUB(CURRENT_DATE('Asia/Kuala_Lumpur'), INTERVAL 1 DAY)
  );