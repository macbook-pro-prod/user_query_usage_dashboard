SELECT 
   dataset_name,
   ROUND(SUM(total_gb), 2) AS total_gb,
   ROUND(SUM(estimated_storage_cost_myr), 2) AS estimated_total_cost_myr,
   'prod-shared-dwh01' AS source_project,
FROM `prod-shared-dwh01.ds_dwh01_shared.dataset_table_storage` 
GROUP BY dataset_name

UNION ALL

SELECT 
   dataset_name,
   ROUND(SUM(total_gb), 2) AS total_gb,
   ROUND(SUM(estimated_storage_cost_myr), 2) AS estimated_total_cost_myr,
   'dev-shared-dwh01' AS source_project,
FROM `dev-shared-dwh01.ds_dwh01_shared.dataset_table_storage` 
GROUP BY dataset_name

UNION ALL

SELECT 
   dataset_name,
   ROUND(SUM(total_gb), 2) AS total_gb,
   ROUND(SUM(estimated_storage_cost_myr), 2) AS estimated_total_cost_myr,
   'prod-data-center-platform' AS source_project,
FROM `prod-data-center-platform.ds_dwh01_shared.dataset_table_storage`  
GROUP BY dataset_name

UNION ALL

SELECT 
   dataset_name,
   ROUND(SUM(total_gb), 2) AS total_gb,
   ROUND(SUM(estimated_storage_cost_myr), 2) AS estimated_total_cost_myr,
   'prod-raw-landing' AS source_project,
FROM `prod-raw-landing.ds_dwh01_shared.dataset_table_storage`  
GROUP BY dataset_name

UNION ALL

SELECT 
   dataset_name,
   ROUND(SUM(total_gb), 2) AS total_gb,
   ROUND(SUM(estimated_storage_cost_myr), 2) AS estimated_total_cost_myr,
   'prod-dw-iwdc' AS source_project,
FROM `prod-dw-iwdc.ds_dwh01_shared.dataset_table_storage`  
GROUP BY dataset_name

