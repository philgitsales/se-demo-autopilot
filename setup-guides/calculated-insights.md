# Setup Guide: Calculated Insights in Data Cloud

> **What this does**: Creates aggregated metrics from DMO data using SQL expressions. Think of them as materialized views that compute counts, sums, averages across your data model.
> **Status**: FULLY WORKING in phil_master_sdo (2 active insights)

---

## TL;DR for Agents

```bash
# Create a calculated insight (on-demand, no schedule)
sf api request rest "/services/data/v66.0/ssot/calculated-insights" -o <org> --method POST --body '{
  "apiName": "My_Insight_Name",
  "displayName": "My Insight Display Name",
  "description": "What this calculates",
  "definitionType": "CALCULATED_METRIC",
  "expression": "SELECT dmo.field AS dimension__c, COUNT(dmo.other_field) AS measure__c FROM some_dmo__dlm dmo GROUP BY dmo.field",
  "publishScheduleInterval": "0"
}' 2>/dev/null

# Run it (note: __cio suffix auto-appended to apiName)
sf data360 calculated-insight run -o <org> --name My_Insight_Name__cio

# Query results
sf api request rest "/services/data/v64.0/ssot/query" -o <org> --method POST --body '{"sql": "SELECT * FROM My_Insight_Name__cio LIMIT 10"}' 2>/dev/null
```

---

## Prerequisites

- At least one DMO with data to aggregate
- Valid SQL expression referencing DMO tables

---

## Step 1: Create Calculated Insight

### API: POST `/services/data/v66.0/ssot/calculated-insights`

```bash
sf api request rest "/services/data/v66.0/ssot/calculated-insights" -o <org> --method POST --body '{
  "apiName": "Web_Engagement_Score",
  "displayName": "Web Engagement Score",
  "description": "Counts web activities per contact to calculate engagement level",
  "definitionType": "CALCULATED_METRIC",
  "expression": "SELECT WebActivity_Home__dlm.RelatedContact_c_c__c AS contact_id__c, COUNT(WebActivity_Home__dlm.Id_c__c) AS visit_count__c, SUM(WebActivity_Home__dlm.TimeOnPage_c_c__c) AS total_time__c FROM WebActivity_Home__dlm GROUP BY WebActivity_Home__dlm.RelatedContact_c_c__c",
  "publishScheduleInterval": "0"
}' 2>/dev/null
```

### Field Reference:

| Field | Required | Description |
|-------|----------|-------------|
| `apiName` | Yes | Developer name (system appends `__cio`) |
| `displayName` | Yes | Human-readable name |
| `description` | No | Description text |
| `definitionType` | Yes | Always `"CALCULATED_METRIC"` |
| `expression` | Yes | SQL query against DMO tables |
| `publishScheduleInterval` | Yes | `"0"` = on-demand, `"6"` = every 6 hours, `"24"` = daily |

### Expression Rules:
- Standard SQL `SELECT ... FROM ... WHERE ... GROUP BY ...`
- Column aliases MUST end in `__c` (e.g., `AS visit_count__c`, NOT `AS visit_count`)
- References DMO table names (e.g., `WebActivity_Home__dlm`)
- JOINs are supported (unlike segment SQL)
- Aggregate functions: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`
- GROUP BY required for any aggregation
- WHERE clause for filtering

---

## Step 2: Run the Insight

```bash
# Note: API name has __cio suffix appended automatically
sf data360 calculated-insight run -o <org> --name Web_Engagement_Score__cio
# Output: "Action completed successfully."
```

The run is asynchronous — it may take 1-5 minutes to materialize results.

---

## Step 3: Query Results

```bash
# Check if results are available
sf api request rest "/services/data/v64.0/ssot/query" -o <org> --method POST --body '{"sql": "SELECT * FROM Web_Engagement_Score__cio LIMIT 10"}' 2>/dev/null

# Count results
sf api request rest "/services/data/v64.0/ssot/query" -o <org> --method POST --body '{"sql": "SELECT COUNT(*) FROM Web_Engagement_Score__cio"}' 2>/dev/null
```

---

## Step 4: Check Status

```bash
# List all CIs
sf api request rest "/services/data/v66.0/ssot/calculated-insights" -o <org> 2>/dev/null

# Get specific CI detail
sf api request rest "/services/data/v66.0/ssot/calculated-insights/Web_Engagement_Score__cio" -o <org> 2>/dev/null
```

Look for:
- `calculatedInsightStatus`: `ACTIVE` = healthy
- `lastRunStatus`: `SUCCESS` / `PROCESSING` / `PENDING`
- `lastRunDateTime`: when it last ran

---

## Example Insights

### Web Engagement Score (per contact)
```sql
SELECT WebActivity_Home__dlm.RelatedContact_c_c__c AS contact_id__c,
       COUNT(WebActivity_Home__dlm.Id_c__c) AS visit_count__c,
       SUM(WebActivity_Home__dlm.TimeOnPage_c_c__c) AS total_time__c
FROM WebActivity_Home__dlm
GROUP BY WebActivity_Home__dlm.RelatedContact_c_c__c
```

### High Intent Page Visits (filtered by URL)
```sql
SELECT WebActivity_Home__dlm.RelatedContact_c_c__c AS contact_id__c,
       COUNT(WebActivity_Home__dlm.Id_c__c) AS high_intent_visits__c
FROM WebActivity_Home__dlm
WHERE WebActivity_Home__dlm.PageVisited_c_c__c IN (
  'https://www.example.com/pricing',
  'https://www.example.com/demo',
  'https://www.example.com/contact'
)
GROUP BY WebActivity_Home__dlm.RelatedContact_c_c__c
```

### Account Revenue by Industry
```sql
SELECT ssot__Account__dlm.ssot__PrimaryIndustry__c AS industry__c,
       COUNT(ssot__Account__dlm.ssot__Id__c) AS account_count__c,
       SUM(ssot__Account__dlm.ssot__AnnualRevenueAmount__c) AS total_revenue__c
FROM ssot__Account__dlm
GROUP BY ssot__Account__dlm.ssot__PrimaryIndustry__c
```

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Schedule start date is required` | Using `publishScheduleInterval` > 0 without a start date | Use `"0"` for on-demand (schedule start date field name is unknown) |
| `Unrecognized field "publishScheduleStartDate"` | Tried various field names for schedule start | Use `"0"` to skip scheduling entirely, then run manually |
| `Calculated Insight api name must end in __cio` | CLI `run` command requires the suffix | Append `__cio` to the name: `--name My_Name__cio` |
| Empty results after run | CI still processing | Wait 1-5 minutes and query again |
| `REQUIRED_FIELD_MISSING: publishScheduleInterval` | Omitted the schedule interval | Always include `"publishScheduleInterval": "0"` |

---

## Known Limitations

1. **Scheduled CIs cannot be created via API** — the schedule start date field name is undocumented/broken across all API versions tested (v64-v66). Workaround: use `"0"` for on-demand and trigger manually with `sf data360 calculated-insight run`.

2. **Results are not real-time** — CIs materialize on run. For streaming metrics, use Streaming Calculated Insights (different feature, not yet tested).

3. **Column aliases must end in `__c`** — the system expects this suffix for all output columns.

---

## Quick Reference

```bash
# List all CIs
sf api request rest "/services/data/v66.0/ssot/calculated-insights" -o <org> 2>/dev/null

# Create (on-demand)
sf api request rest "/services/data/v66.0/ssot/calculated-insights" -o <org> --method POST --body '{...}'

# Run
sf data360 calculated-insight run -o <org> --name <NAME>__cio

# Delete
sf api request rest "/services/data/v66.0/ssot/calculated-insights/<NAME>__cio" -o <org> --method DELETE 2>/dev/null

# Query results
sf api request rest "/services/data/v64.0/ssot/query" -o <org> --method POST --body '{"sql": "SELECT * FROM <NAME>__cio LIMIT 10"}'
```

---

## Key IDs (phil_master_sdo)

```
Web_Engagement_Score__cio    — Visit count + time on page per contact
High_Intent_Page_Visits__cio — Pricing/demo/contact page visits per contact
```
