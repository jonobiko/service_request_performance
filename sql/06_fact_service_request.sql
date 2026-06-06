CREATE OR REPLACE TABLE mart.fact_service_request AS
SELECT
    s.request_id,

    CAST(STRFTIME(s.created_ts, '%Y%m%d') AS INTEGER) AS created_date_key,

    CASE
        WHEN s.closed_ts IS NOT NULL
            THEN CAST(STRFTIME(s.closed_ts, '%Y%m%d') AS INTEGER)
        ELSE NULL
    END AS closed_date_key,

    MD5(
        COALESCE(s.agency, 'UNKNOWN') || '|' ||
        COALESCE(s.agency_name, 'UNKNOWN')
    ) AS agency_key,

    MD5(
        COALESCE(s.complaint_type, 'UNKNOWN') || '|' ||
        COALESCE(s.descriptor, 'UNKNOWN')
    ) AS request_type_key,

    MD5(
        COALESCE(s.borough, 'UNKNOWN') || '|' ||
        COALESCE(s.incident_zip, 'UNKNOWN')
    ) AS location_key,

    s.created_ts,
    s.closed_ts,
    s.due_ts,
    s.status,

    CASE
        WHEN s.closed_ts IS NOT NULL THEN 1
        ELSE 0
    END AS is_closed,

    CASE
        WHEN s.closed_ts IS NULL THEN 1
        ELSE 0
    END AS is_open,

    CASE
        WHEN s.closed_ts IS NOT NULL
            THEN DATE_DIFF('hour', s.created_ts, s.closed_ts) / 24.0
        ELSE NULL
    END AS cycle_time_days,

    CASE
        WHEN s.closed_ts IS NULL
            THEN DATE_DIFF('day', s.created_ts, CURRENT_DATE)
        ELSE NULL
    END AS backlog_age_days,

    CASE
        WHEN s.due_ts IS NULL OR s.closed_ts IS NULL THEN NULL
        WHEN s.closed_ts <= s.due_ts THEN 1
        ELSE 0
    END AS is_sla_met,

    CASE
        WHEN s.closed_ts IS NOT NULL THEN 'Closed'
        WHEN DATE_DIFF('day', s.created_ts, CURRENT_DATE) <= 2 THEN '0-2 Days'
        WHEN DATE_DIFF('day', s.created_ts, CURRENT_DATE) BETWEEN 3 AND 7 THEN '3-7 Days'
        WHEN DATE_DIFF('day', s.created_ts, CURRENT_DATE) BETWEEN 8 AND 14 THEN '8-14 Days'
        ELSE '15+ Days'
    END AS aging_bucket

FROM stage.stg_311_requests s;