CREATE OR REPLACE TABLE dq.data_quality_results AS

SELECT
    'duplicate_request_id' AS check_name,
    COUNT(*) AS failed_records
FROM (
    SELECT request_id
    FROM stage.stg_311_requests
    GROUP BY request_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'missing_request_id' AS check_name,
    COUNT(*) AS failed_records
FROM stage.stg_311_requests
WHERE request_id IS NULL

UNION ALL

SELECT
    'missing_created_timestamp' AS check_name,
    COUNT(*) AS failed_records
FROM stage.stg_311_requests
WHERE created_ts IS NULL

UNION ALL

SELECT
    'closed_before_created' AS check_name,
    COUNT(*) AS failed_records
FROM stage.stg_311_requests
WHERE closed_ts < created_ts

UNION ALL

SELECT
    'missing_agency' AS check_name,
    COUNT(*) AS failed_records
FROM stage.stg_311_requests
WHERE agency IS NULL

UNION ALL

SELECT
    'missing_complaint_type' AS check_name,
    COUNT(*) AS failed_records
FROM stage.stg_311_requests
WHERE complaint_type IS NULL;