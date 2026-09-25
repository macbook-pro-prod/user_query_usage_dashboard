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



billing_jobs_by_project
jobs_by_project

dev-shared-dwh01.ds_dwh01_shared.dataset_table_storage
billing_dataset_table_storage

List of Projects [] - have table_storage: 
1. dev-shared-dwh01 [✅]
2. prod-data-center-platform [✅]
3. prod-dw-dshbd [✅]
4. prod-dw-id [✅]
5. prod-dw-iwdc [✅]
6. prod-dw-rmn [✅]
7. prod-dw-th [✅]
8. prod-raw-landing [✅]
9. prod-shared-dwh01 [✅]
10. prod-sql-scripting [] -- got not table inside


-- author: mac
-- The scheduled query will dynamically generate one query for every dataset.

DECLARE sql_query STRING;

-- Step 1: Generate the dynamic SQL
SET sql_query = (
  SELECT STRING_AGG(
    FORMAT("""
    SELECT 
        '%s' AS dataset_name,
        ROUND(SUM(size_bytes) / (1024 * 1024 * 1024), 2) AS total_gb,
        ROUND(SUM(size_bytes) / (1024 * 1024 * 1024) * 0.043945, 2) AS estimated_storage_cost_myr
    FROM `prod-dw-rmn.%s.__TABLES__`""", schema_name, schema_name), 
    ' UNION ALL '
  )
  FROM `region-asia-southeast1.INFORMATION_SCHEMA.SCHEMATA`
);

-- Step 2: Store results in a physical table
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE TABLE `prod-dw-rmn.ds_dwh01_shared.dataset_table_storage` AS 
  %s
""", sql_query); -- modify the project name and where it will be stored
