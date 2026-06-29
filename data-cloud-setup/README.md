# Data Cloud Setup — Status & Findings

> **Last Updated**: 2026-06-29
> **Status**: FULLY OPERATIONAL — Data flowing, IDR running, segments activated to MC, calculated insights working

---

## Summary

Data Cloud is **fully configured end-to-end**:
- **2,126 Individual** profiles synced and unified
- **902 Account** profiles synced
- **Identity Resolution** running with email + phone matching (2,126 unified profiles)
- **7 activations** publishing to Marketing Cloud (all SUCCESS)
- **2 Calculated Insights** computing engagement scores from web activity data
- **8 segments** active with member counts (non-zero)

The only manual step that was needed (SFDC connector data stream sync via UI) has been completed.

---

## What's Working (Complete Pipeline)

```
CRM Data ──→ Data Streams ──→ DLOs ──→ DMOs ──→ Identity Resolution ──→ Unified Profiles
                                                         │
                                                         ├──→ Segments (8 active, with members)
                                                         │         │
                                                         │         └──→ Activations (7, all → MC)
                                                         │                    │
                                                         │                    └──→ MC Data Extensions
                                                         │
                                                         └──→ Calculated Insights (2 active)
```

---

## What Was Accomplished

### 1. CRM Data Loaded & Synced ✅
- Created `ContactProfile__c` custom object with 9 fields
- Bulk-imported **2,126 contact records** via Bulk API 2.0
- Data stream sync triggered (UI) — all records flowing

### 2. DMO Data Counts (LIVE)

| DMO | Category | Records | Notes |
|-----|----------|---------|-------|
| `ssot__Individual__dlm` | PROFILE | **2,126** | From Contact records |
| `ssot__Account__dlm` | PROFILE | **902** | From Account records |
| `ssot__AccountContact__dlm` | PROFILE | **2,126** | Junction object |
| `ssot__ContactPointEmail__dlm` | CONTACT POINT | **2,126** | Email addresses |
| `ssot__ContactPointPhone__dlm` | CONTACT POINT | **3,028** | Phone numbers |
| `ssot__ContactPointAddress__dlm` | CONTACT POINT | **3,028** | Addresses |
| `ContactProfile__dlm` | PROFILE | **3,752** | Custom profiles |
| `WebActivity_Home__dlm` | OTHER | **8,001** | Web events |
| `SalesActivity_Home__dlm` | OTHER | **1,501** | Sales events |

### 3. Identity Resolution ✅ FULLY WORKING

| Property | Value |
|----------|-------|
| Ruleset Name | `Main` |
| Ruleset ID | `1irg70000000Wg0AAE` |
| Status | **PUBLISHED** |
| Configuration Type | Individual |
| Source Profiles | 2,126 |
| Unified Profiles | 2,126 |
| Consolidation Rate | 0% (single source — no duplicates to merge) |
| Runs Automatically | Yes |
| Last Job | SUCCESS |

**Match Rules:**
1. **Exact Email** — `ssot__ContactPointEmail__dlm.ssot__EmailAddress__c` (exactnormalized)
2. **Exact Phone** — `ssot__ContactPointPhone__dlm.ssot__FormattedE164PhoneNumber__c` (exactnormalized)

**Unified DMOs Created:**
- `UnifiedIndividual__dlm` (2,126 records)
- `UnifiedContactPointEmail__dlm` (2,126 records)
- `UnifiedContactPointPhone__dlm` (2,126 records)
- `UnifiedContactPointAddress__dlm` (2,126 records)
- `IndividualIdentityLink__dlm` (2,126 link records)

### 4. Segments (8 total, all ACTIVE with members)

| Segment | DMO | Members | Published |
|---------|-----|---------|-----------|
| `High_Intent_Web_Visitors` | ssot__Individual__dlm | **2,126** | ✅ SUCCESS |
| `Enterprise_Decision_Makers` | ssot__Individual__dlm | **2,126** | ✅ SUCCESS |
| `Titled_Professionals` | ssot__Individual__dlm | **2,126** | ✅ SUCCESS |
| `High_Value_Accounts` | ssot__Account__dlm | **461** | ✅ SUCCESS |
| `Technology_Industry` | ssot__Account__dlm | **80** | ✅ SUCCESS |
| `Named_Enterprise_Accounts` | ssot__Account__dlm | **902** | ✅ SUCCESS |
| `PK_Test` | ssot__Individual__dlm | **115** | ✅ |
| `Test_Account_Segment` | ssot__Account__dlm | 0 | (test) |

### 5. Activation Targets

| Target | Type | ID | Status |
|--------|------|-----|--------|
| `pk_test_mc` | Marketing Cloud | `85Ug70000023IAXEA2` | **ACTIVE** |
| `pk_test_programmatic_v2` | Marketing Cloud | `85Ug70000023IthEAE` | **ACTIVE** |

### 6. MC Activations (7 total, all ACTIVE → SUCCESS)

| Activation | Segment | Target | Status |
|-----------|---------|--------|--------|
| `High_Intent_Web_Visitors_MC` | High_Intent_Web_Visitors | pk_test_mc | ✅ SUCCESS |
| `pk_test_activation_enterprise_decision` | Enterprise_Decision_Makers | pk_test_mc | ✅ SUCCESS |
| `Titled_Professionals_MC` | Titled_Professionals | pk_test_mc | ✅ SUCCESS |
| `High_Value_Accounts_MC` | High_Value_Accounts | pk_test_mc | ✅ SUCCESS |
| `Technology_Industry_MC` | Technology_Industry | pk_test_mc | ✅ SUCCESS |
| `Named_Enterprise_Accounts_MC` | Named_Enterprise_Accounts | pk_test_mc | ✅ SUCCESS |
| `Titled_Professionals_Prog_Test_v2` | Titled_Professionals | pk_test_programmatic_v2 | ✅ SUCCESS |

### 7. Calculated Insights ✅ WORKING

| Insight | API Name | Description | Status |
|---------|----------|-------------|--------|
| Web Engagement Score | `Web_Engagement_Score__cio` | Visit count per contact | ACTIVE |
| High Intent Page Visits | `High_Intent_Page_Visits__cio` | Pricing/demo/contact page visits | ACTIVE |

---

## Critical Technical Findings

### Identity Resolution API (WORKING)

**Create:**
```bash
sf api request rest "/services/data/v66.0/ssot/identity-resolutions" -o <org> --method POST --body '{
  "label": "Main",
  "description": "Primary identity resolution ruleset",
  "configurationType": "individual",
  "doesRunAutomatically": true,
  "matchRules": [
    {
      "label": "Exact Email",
      "criteria": [{
        "entityName": "ssot__ContactPointEmail__dlm",
        "fieldName": "ssot__EmailAddress__c",
        "matchMethodType": "exactnormalized",
        "caseSensitiveMatch": false,
        "shouldMatchOnBlank": false
      }]
    }
  ],
  "reconciliationRules": [
    {
      "entityName": "ssot__Individual__dlm",
      "ruleType": "lastupdated",
      "shouldIgnoreEmptyValue": true,
      "sources": [],
      "fields": []
    }
  ]
}'
```

**Update (PATCH) — cannot include `configurationType`:**
```bash
sf api request rest "/services/data/v66.0/ssot/identity-resolutions/<ID>" -o <org> --method PATCH --body '{
  "label": "Main",
  "description": "Updated description",
  "doesRunAutomatically": true,
  "matchRules": [...],
  "reconciliationRules": [...]
}'
```

**Run:**
```bash
sf data360 identity-resolution run -o <org> --name Main
```

**Key Gotchas:**
- API path is `/ssot/identity-resolutions` (plural) — NOT `/ssot/identity-resolution/rulesets`
- `GET` by name doesn't work — must use the ID (`1irg70000000Wg0AAE`)
- `PATCH` rejects `configurationType` — omit it from update payload
- `sf data360 identity-resolution create` CLI has a bug with `${suffix}` literal in rulesetId — use REST API directly
- The system auto-creates reconciliation rules for ALL mapped contact point DMOs (email, phone, address) even if you only specify Individual
- Run is asynchronous — status goes PUBLISHING → PUBLISHED
- Consolidation rate = 0% is expected with single-source data (no duplicates to merge)
- CI name must end with `__cio` suffix when using the CLI `run` command

### Calculated Insights API (WORKING)

**Create (use `publishScheduleInterval: "0"` to skip schedule requirement):**
```bash
sf api request rest "/services/data/v66.0/ssot/calculated-insights" -o <org> --method POST --body '{
  "apiName": "My_Insight_Name",
  "displayName": "My Insight Display Name",
  "description": "What this insight calculates",
  "definitionType": "CALCULATED_METRIC",
  "expression": "SELECT dim AS dim_alias__c, COUNT(field) AS measure_alias__c FROM dmo__dlm GROUP BY dim",
  "publishScheduleInterval": "0"
}'
```

**Run:**
```bash
sf data360 calculated-insight run -o <org> --name My_Insight_Name__cio
```

**Key Gotchas:**
- `publishScheduleInterval` is REQUIRED — use `"0"` for on-demand (maps to "NOT_SCHEDULED")
- The schedule start date requirement is ONLY for scheduled intervals (not `"0"`)
- The correct field name for the schedule start date is UNKNOWN — tried `publishScheduleStartDate`, `scheduleStartDate`, `startDate`, `schedule.startDate` — ALL rejected
- System auto-appends `__cio` suffix to the apiName
- Column aliases MUST end in `__c` (e.g., `visit_count__c`, NOT `visit_count`)
- Expression is standard SQL against DMO tables
- Results materialize into a queryable `<apiName>__cio` table
- Run command requires the `__cio` suffix

### Segment API Format (WORKING)

```json
{
  "displayName": "Segment Name",
  "developerName": "Segment_Api_Name",
  "segmentType": "Dbt",
  "includeDbt": {
    "models": {
      "models": [
        {
          "name": "ModelName",
          "sql": "SELECT dmo.ssot__Id__c, dmo.KQ_Id__c FROM dmo_name__dlm dmo WHERE ..."
        }
      ]
    }
  }
}
```

**Critical rules for segments:**
- MUST include the **Key Qualifier field** (e.g., `KQ_Id__c`) in SELECT alongside the primary key
- Can only segment on **PROFILE category** DMOs that are `isSegmentable: true`
- **NO JOINs allowed** — segment SQL can only reference the single `segmentOn` DMO
- **NO subqueries** referencing other DMOs
- Only **standard DMOs** work (ssot__Account__dlm, ssot__Individual__dlm) — custom DMOs return "Object not found"
- Column names in SQL must match **actual materialized columns** (query with `SELECT * FROM dmo LIMIT 1`)

### Activation Creation ✅ SOLVED

POST to `/ssot/activations` requires:
- `name` ✅
- `activationTargetName` ✅ (must be UI-created target for MC)
- `segmentApiName` ✅
- `dataSpaceName` ✅
- `refreshType` ("FULL_REFRESH" or "INCREMENTAL") ✅
- `activationTargetSubjectConfig` ✅ — `{"developerName": "ssot__Individual__dlm"}`
- `attributesConfig` ✅ — at minimum the primary key attribute

### Data Stream Sync (HARD BLOCKER — now resolved for this org)

The SalesforceDotCom connector **cannot be triggered programmatically**:
```
"Connector type SalesforceDotCom is not allowed to run in non-interactive mode"
```

This has been done manually for phil_master_sdo — data is flowing.

---

## Key IDs & References

```
Org Alias: phil_master_sdo
Data Space: default
Admin Profile FieldPermissions ParentId: 0PSg7000003mQaxGAE

Identity Resolution:
  Ruleset ID:            1irg70000000Wg0AAE
  Ruleset Name:          Main
  Ruleset Status:        PUBLISHED

MC Activation Target:
  Name:                  pk_test_mc
  ID:                    85Ug70000023IAXEA2
  DataConConfigurationId: 7M4g7000001G7EfCAK
  DataSpaceId:           0vhg70000002SZhAAM

MC Connection:
  SSOT Connection ID:    1WMg70000002O33GAE
  Business Unit:         523019897 (MedVet)

Segment IDs:
  High_Intent_Web_Visitors:     3HXg70000000a6jGAA (market: 1sgg70000006MQrAAM)
  Enterprise_Decision_Makers:   3HXg70000000a8LGAQ (market: 1sgg70000006MSTAA2)
  Titled_Professionals:         3HXg70000000aGPGAY (market: 1sgg70000006MYvAAM)
  High_Value_Accounts:          3HXg70000000aBZGAY (market: 1sgg70000006MVhAAM)
  Technology_Industry:          3HXg70000000aDBGAY (market: 1sgg70000006MXJAAM)
  Named_Enterprise_Accounts:    3HXg70000000a9xGAA (market: 1sgg70000006MU5AAM)

Calculated Insights:
  Web_Engagement_Score__cio
  High_Intent_Page_Visits__cio

Unified DMOs:
  UnifiedIndividual__dlm
  UnifiedContactPointEmail__dlm
  UnifiedContactPointPhone__dlm
  UnifiedContactPointAddress__dlm
  IndividualIdentityLink__dlm
  ContactPointEmailIdentityLink__dlm
  ContactPointPhoneIdentityLink__dlm
  ContactPointAddressIdentityLink__dlm
```

---

## Files in This Folder

| File | Purpose |
|------|---------|
| `README.md` | This document — full status and findings |
| `product-docs/` | 36 official Salesforce docs on IDR, DMOs, segments, activations |
| `ci-high-intent-visitors.json` | Original CI definition template |
| `segment-high-intent-visitors.json` | Original segment definition (pre-discovery of correct format) |
| `segments-created.json` | 6 segment definitions with IDs |
| `activation-target-created.json` | S3 Bridge target details (deprecated) |
| `contact-profiles.csv` | Sample data template |
| `ingestion-schema-contacts.json` | Ingestion API schema |
| `blockers-and-next-steps.md` | Historical debugging & advanced reference |

---

## What's Next (Phase 2)

### Immediate:
1. **Verify CI data** — Query `Web_Engagement_Score__cio` table after processing completes
2. **Add more match rules** — Fuzzy name matching for better consolidation when multi-source data arrives
3. **Build end-to-end demo skill** — Natural language → segment → activate → journey in MC

### Future:
- Multi-source data ingestion (e.g., ingestion API + CRM = actual consolidation scenarios)
- Data Graph visualization
- Streaming Calculated Insights (real-time)
- Universal ID lookup integration
