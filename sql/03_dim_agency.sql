CREATE OR REPLACE TABLE mart.dim_agency AS
SELECT DISTINCT
    MD5(
        COALESCE(agency, 'UNKNOWN') || '|' ||
        COALESCE(agency_name, 'UNKNOWN')
    ) AS agency_key,

    COALESCE(agency, 'Unknown') AS agency,
    COALESCE(agency_name, 'Unknown') AS agency_name

FROM stage.stg_311_requests;