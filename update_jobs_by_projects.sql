UPDATE `prod-dw-dshbd.ds_dwh01_shared.jobs_by_project` -- update project
SET
  consumption_category = 'Visualization',
  consumption_source = 'Conversational Analytics'
WHERE EXISTS (
  SELECT 1
  FROM UNNEST(labels) AS l
  WHERE l.key = 'ca-bq-job'
    AND l.value = 'true'
);




jobs_by_project