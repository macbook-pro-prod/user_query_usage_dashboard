DECLARE sql_query STRING;

-- Step 1: Generate the dynamic SQL
SET sql_query = (
  SELECT STRING_AGG(
    FORMAT("""
    SELECT
        CURRENT_DATE('Asia/Kuala_Lumpur') AS snapshot_date,
        '%s' AS dataset_name,
        ROUND(SUM(size_bytes) / (1024 * 1024 * 1024), 2) AS total_gb,
        ROUND(SUM(size_bytes) / (1024 * 1024 * 1024) * 0.043945, 2) AS estimated_storage_cost_myr
    FROM `prod-shared-dwh01.%s.__TABLES__`
    """, schema_name, schema_name),
    ' UNION ALL '
  )
  FROM `region-asia-southeast1.INFORMATION_SCHEMA.SCHEMATA`
);

-- Step 2: Remove today's snapshot if it already exists
DELETE FROM `prod-shared-dwh01.ds_dwh01_shared.dataset_table_storage`
WHERE snapshot_date = CURRENT_DATE('Asia/Kuala_Lumpur');

-- Step 3: Insert today's latest snapshot
EXECUTE IMMEDIATE FORMAT("""
  INSERT INTO `prod-shared-dwh01.ds_dwh01_shared.dataset_table_storage`
  %s
""", sql_query);