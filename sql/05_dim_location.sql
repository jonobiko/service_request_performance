CREATE OR REPLACE TABLE mart.dim_location AS
SELECT DISTINCT
    MD5(
        COALESCE(borough, 'UNKNOWN') || '|' ||
        COALESCE(incident_zip, 'UNKNOWN')
    ) AS location_key,

    COALESCE(borough, 'Unknown') AS borough,
    COALESCE(incident_zip, 'Unknown') AS incident_zip

FROM stage.stg_311_requests;