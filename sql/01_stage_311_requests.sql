CREATE OR REPLACE TABLE stage.stg_311_requests AS
SELECT
    unique_key AS request_id,
    TRY_CAST(NULLIF(created_date, '') AS TIMESTAMP) AS created_ts,
    TRY_CAST(NULLIF(closed_date, '') AS TIMESTAMP) AS closed_ts,
    TRY_CAST(NULLIF(due_date, '') AS TIMESTAMP) AS due_ts,

    NULLIF(TRIM(agency), '') AS agency,
    NULLIF(TRIM(agency_name), '') AS agency_name,
    NULLIF(TRIM(complaint_type), '') AS complaint_type,
    NULLIF(TRIM(descriptor), '') AS descriptor,
    NULLIF(TRIM(status), '') AS status,
    NULLIF(TRIM(resolution_description), '') AS resolution_description,
    NULLIF(TRIM(borough), '') AS borough,
    NULLIF(TRIM(incident_zip), '') AS incident_zip,

    TRY_CAST(NULLIF(latitude, '') AS DOUBLE) AS latitude,
    TRY_CAST(NULLIF(longitude, '') AS DOUBLE) AS longitude

FROM raw.raw_311_service_requests;