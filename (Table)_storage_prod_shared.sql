
DECLARE sql_query STRING;

-- Step 1: Generate the dynamic SQL
SET sql_query = (
  SELECT STRING_AGG(
    FORMAT("""
    SELECT 
        '%s' AS dataset_name,
        ROUND(SUM(size_bytes) / (1024 * 1024 * 1024), 2) AS total_gb,
        ROUND(SUM(size_bytes) / (1024 * 1024 * 1024) * 0.043945, 2) AS estimated_storage_cost_myr
    FROM `prod-shared-dwh01.%s.__TABLES__`""", schema_name, schema_name), 
    ' UNION ALL '
  )
  FROM `region-asia-southeast1.INFORMATION_SCHEMA.SCHEMATA`
);

-- Step 2: Store results in a physical table
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE TABLE `prod-shared-dwh01.ds_dwh01_shared.dataset_table_storage` AS 
  %s
""", sql_query); -- modify the project name and where it will be stored
