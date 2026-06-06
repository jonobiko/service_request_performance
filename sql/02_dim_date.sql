CREATE OR REPLACE TABLE mart.dim_date AS
WITH date_spine AS (
    SELECT
        CAST(calendar_date AS DATE) AS calendar_date
    FROM generate_series(
        DATE '2024-01-01',
        DATE '2030-12-31',
        INTERVAL 1 DAY
    ) AS t(calendar_date)
)

SELECT
    CAST(STRFTIME(calendar_date, '%Y%m%d') AS INTEGER) AS date_key,
    calendar_date,
    EXTRACT(YEAR FROM calendar_date) AS calendar_year,
    EXTRACT(QUARTER FROM calendar_date) AS calendar_quarter,
    EXTRACT(MONTH FROM calendar_date) AS calendar_month_number,
    STRFTIME(calendar_date, '%B') AS calendar_month_name,
    STRFTIME(calendar_date, '%Y-%m') AS year_month,
    EXTRACT(DAY FROM calendar_date) AS day_of_month,
    STRFTIME(calendar_date, '%w') AS day_of_week_number,
    STRFTIME(calendar_date, '%A') AS day_of_week_name

FROM date_spine;