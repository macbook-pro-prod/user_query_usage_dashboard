-- scheduled queries

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

    -- Conversational Analytics
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'ca-bq-job'
        AND l.value = 'true'
    )
      THEN 'Visualization'

    -- Looker Studio
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'requestor'
        AND l.value = 'looker_studio'
    )
      THEN 'Visualization'

    -- Holistics
    WHEN user_email = 'holistics-sa@prod-data-center-platform.iam.gserviceaccount.com'
      THEN 'Visualization'

    -- dbt
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'dbt_invocation_id'
    )
      THEN 'Data Processing'

    -- Scheduled Query
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'data_source_id'
        AND l.value = 'scheduled_query'
    )
      THEN 'Data Processing'

    -- Manual / Ad Hoc Query
    WHEN user_email IS NOT NULL
      AND NOT ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'Ad Hoc / Manual'

    ELSE 'Other'

  END AS consumption_category,


  -- Consumption Source
  CASE

    -- Conversational Analytics
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'ca-bq-job'
        AND l.value = 'true'
    )
      THEN 'Conversational Analytics'

    -- Looker Studio
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'requestor'
        AND l.value = 'looker_studio'
    )
      THEN 'Looker Studio'

    -- Holistics
    WHEN user_email = 'holistics-sa@prod-data-center-platform.iam.gserviceaccount.com'
      THEN 'Holistics'

    -- dbt
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'dbt_invocation_id'
    )
      THEN 'dbt'

    -- Scheduled Query
    WHEN EXISTS (
      SELECT 1
      FROM UNNEST(labels) AS l
      WHERE l.key = 'data_source_id'
        AND l.value = 'scheduled_query'
    )
      THEN 'Scheduled Query'

    -- Manual user query
    WHEN user_email IS NOT NULL
      AND NOT ENDS_WITH(user_email, 'gserviceaccount.com')
      THEN 'User Query'

    ELSE 'Other BigQuery'

  END AS consumption_source


FROM `prod-dw-dshbd.region-asia-southeast1.INFORMATION_SCHEMA.JOBS_BY_PROJECT`

WHERE total_bytes_processed <> 0
  AND state = 'DONE'

  -- Only capture yesterday's usage
  AND DATE(creation_time, 'Asia/Kuala_Lumpur')
      = DATE_SUB(
          CURRENT_DATE('Asia/Kuala_Lumpur'),
          INTERVAL 1 DAY
        )

  -- Exclude parent/script jobs to avoid double counting
  AND job_id NOT IN (
    SELECT parent_job_id
    FROM `prod-dw-dshbd.region-asia-southeast1.INFORMATION_SCHEMA.JOBS_BY_PROJECT`

    WHERE parent_job_id IS NOT NULL

      AND DATE(creation_time, 'Asia/Kuala_Lumpur')
          = DATE_SUB(
              CURRENT_DATE('Asia/Kuala_Lumpur'),
              INTERVAL 1 DAY
            )
  );


-- author: mac