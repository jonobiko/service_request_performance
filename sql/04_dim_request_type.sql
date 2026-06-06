CREATE OR REPLACE TABLE mart.dim_request_type AS
SELECT DISTINCT
    MD5(
        COALESCE(complaint_type, 'UNKNOWN') || '|' ||
        COALESCE(descriptor, 'UNKNOWN')
    ) AS request_type_key,

    COALESCE(complaint_type, 'Unknown') AS complaint_type,
    COALESCE(descriptor, 'Unknown') AS descriptor

FROM stage.stg_311_requests;