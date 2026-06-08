## Service Request Performance Dashboard

### Project Overview
This project analyzes public service request operations using NYC 311 data as a proxy for enterprise case-management 
workflows. The dashboard provides leadership visibility into request intake, completion volume, backlog, cycle time, 
SLA performance, aging inventory, and operational trends across agencies and request types.

### Business Problem
Operations management needs a way to monitor service request performance on volume, completion rates, backlog, cycle 
time, aging, and SLA adherence.

Raw service data is too detailed for executive reporting, so to support decision-making, the data must be cleaned, 
modeled, validated, and converted into KPIs.

This project addresses the following business questions:  
- How many service requests are created over time?
- How many requests are completed?
- What is the current open backlog?
- How long does it take to complete requests?
- Which agencies, request types, or locations drive the highest volume?
- Which requests are aging or at risk?
- Are there data quality issues that could impact reporting accuracy?

### Data Source & Project Architecture
**Dataset**: 311 Service Requests January 2025 to May 2026  
**Source**: NYC Open Data

The extract script pulls specific fields from the public API, including request ID, 
created date, closed date, agency, etc.

The raw data is not stored in this repo. The project includes code to extract 
and rebuild the local dataset.

The pipeline follows this structure:  
&emsp;NYC Open Data API  
&emsp;&emsp;&emsp;&emsp;↓  
&emsp;Python extraction  
&emsp;&emsp;&emsp;&emsp;↓  
&emsp;DuckDB local warehouse  
&emsp;&emsp;&emsp;&emsp;↓  
&emsp;SQL staging  
&emsp;&emsp;&emsp;&emsp;↓  
&emsp;SQL fact and dimension tables  
&emsp;&emsp;&emsp;&emsp;↓  
&emsp;Data quality checks  
&emsp;&emsp;&emsp;&emsp;↓  
&emsp;Power BI dashboard

### KPI Definitions
| KPI                | Definition                                                  |
|--------------------|-------------------------------------------------------------|
| Request Intake     | Count of service requests created during the period         |
| Completed Requests | Count of requests with a closed timestamp                   |
| Open Backlog       | Count of requests that remain open                          |
| Average Cycle Time | Average number of days between created date and closed date |
| SLA Compliance     | Percentage of eligible requests completed by due date       |
| Aging              | Open Requests group by backlog age                          |
| Completion Rate    | Completed requests divided by created requests              |

### Data Quality Checks
The project includes validation checks to monitor data reliability.

Current checks include the following:

| Check                                     | Result     | Notes                                                          |
|-------------------------------------------|------------|----------------------------------------------------------------|
| Duplicate request IDs                     | Passed     | No duplicate request IDs identified                            |
| Missing request IDs                       | Passed     | All modeled records contained a request ID                     |
| Missing created timestamps                | Passed     | 	All modeled records contained a created timestamp             |
| Missing agency values                     | Passed     | All modeled records contained an agency value                  |
| Missing complaint type values             | Passed     | 	All modeled records contained a complaint type                |
| Closed timestamp before created timestamp | **Failed** | 	1,110 records had a closed date earlier than the created date |

The invalid date records were retained in the raw and staging layers for transparency and were captured in 
the data quality layer. These records were excluded from cycle time and SLA calculations to 
prevent negative or misleading operational performance metrics.

This issue appears to be a source data issue rather than a transformation error, since the validation 
compares the original created and closed timestamps after standard type conversion.

### Findings & Key Takeaways
This project demonstrates how raw operational data can be converted into a structured BI reporting 
model. The final output provides insights into service request volume, completion performance, 
backlog risk, and cycle time.

The project also shows how a lightweight local analytics stack can be used to simulate 
an enterprise BI workflow.

Results for 311 Service Requests submitted between Jan 2025 and May 2026:  
- Total service requests analyzed: 5.3 million
- Demand is concentrated with NYPD and HPD together accounting for approximately 68% of requests.
- High volume does not mean high cycle time. NYPD has the highest volume of requests 
at 2.4M, but an average cycle time of only 0.1 days. Average cycle time across all departments: 7.6 days.
- Open backlog is aging. 151k of 163k open requests are aged >15 days, and 63k are aged >180 days.
Expanding the date range to include more historical data may show even more aged backlog.
- Request types are concentrated on the top 10 request types which represent approximately 
3.1M requests or roughly 58% of total intake.
- Data quality exceptions were minimal and isolated. All data quality checks passed 
except for records where the closed date occurred before the created date. These records were flagged and 
excluded from the metrics to prevent misleading information.


<img width="1836" height="1059" alt="Service Request Performance" src="https://github.com/user-attachments/assets/2b87f2bb-ec8b-46e9-b665-82d2105dc721" />

### Potential Future Enhancements
- Expand date range to include additional historical data
- Add anomaly detection for unusual request spikes
- Add automated data quality failure notifications

### Disclaimer
_This project uses public NYC Open Data as a proxy for enterprise service request and 
operations analytics. It is intended for portfolio and demonstration purposes only. 
No proprietary, confidential, employer-owned, or client data is included._
