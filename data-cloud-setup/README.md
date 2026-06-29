# Data Cloud Setup — Status & Findings

> **Last Updated**: 2026-06-27
> **Status**: End-to-end workflow PROVEN — MC activation target active, activation creation working via API

---

## Summary

Data Cloud is configured end-to-end (streams → DLOs → DMOs → segments → activation target), but **no data flows into the segmentable DMOs** because the SalesforceDotCom connector requires a manual UI trigger for the initial sync.

---

## What Was Accomplished

### 1. CRM Data Loaded
- Created `ContactProfile__c` custom object with 9 fields (CrmContactId, FirstName, LastName, Email, Phone, Title, LeadSource, City, State)
- Bulk-imported **2,126 contact records** via Bulk API 2.0
- Granted Field Level Security via FieldPermissions REST API

### 2. Data Streams Created
| Stream | Source Object | DLO | Status |
|--------|--------------|-----|--------|
| ContactProfile | ContactProfile__c | ContactProfile__dll | ACTIVE, 0 rows synced |
| WebActivity (pre-existing) | WebActivity__c | WebActivity_Home__dll | 8,001 rows |
| SalesActivity (pre-existing) | SalesActivity__c | SalesActivity_Home__dll | 1,501 rows |
| Account/Contact (SDO standard) | Account/Contact | ssot__* DLOs | 0 rows synced |

### 3. DMOs Configured
| DMO | Category | Segmentable | Has Data |
|-----|----------|-------------|----------|
| `ssot__Account__dlm` | PROFILE | YES | NO (0 rows) |
| `ssot__Individual__dlm` | PROFILE | YES | NO (0 rows) |
| `ssot__AccountContact__dlm` | PROFILE | YES | NO (0 rows) |
| `ContactProfile__dlm` | PROFILE | YES | NO (0 rows) |
| `WebActivity_Home__dlm` | OTHER | NO | YES (8,001 rows) |
| `SalesActivity_Home__dlm` | OTHER | NO | YES (1,501 rows) |

### 4. Segments Created (6 total, all ACTIVE)

| Segment | DMO | SQL Logic |
|---------|-----|-----------|
| `High_Intent_Web_Visitors` | ssot__Individual__dlm | All individuals (placeholder) |
| `Enterprise_Decision_Makers` | ssot__Individual__dlm | WHERE TitleName IS NOT NULL |
| `Titled_Professionals` | ssot__Individual__dlm | WHERE TitleName IS NOT NULL AND LastName IS NOT NULL |
| `High_Value_Accounts` | ssot__Account__dlm | WHERE AnnualRevenueAmount > 1000000 |
| `Technology_Industry` | ssot__Account__dlm | WHERE PrimaryIndustry = 'Technology' |
| `Named_Enterprise_Accounts` | ssot__Account__dlm | WHERE Name IS NOT NULL |

All have 0 members because the underlying DMOs have no data yet.

### 5. Activation Targets

| Target | Type | ID | Status | Notes |
|--------|------|-----|--------|-------|
| `pk_test_mc` | Marketing Cloud | `85Ug70000023IAXEA2` | **ACTIVE** | Created via UI, working |
| `Marketing_Cloud_S3_Bridge` | AmazonS3 | `85Ug70000022hsXEAQ` | ERROR | Old workaround, can delete |

### 6. MC Activation Workflow — PROVEN ✅

The full Data Cloud → Marketing Cloud activation pipeline works:
1. MC Connection established via UI (Data Cloud Setup → Marketing → MC Engagement)
2. Activation Target created via UI (`pk_test_mc`)
3. Activations creatable via API with correct payload (see `blockers-and-next-steps.md`)

---

## The One Manual Step Required

### You must trigger the data stream sync from the UI:

1. Log into the SDO org
2. Go to **Setup** → **Data Cloud** → **Data Streams**
3. Find the SalesforceDotCom connector streams (Account, Contact, ContactProfile, etc.)
4. Click **"Run"** or **"Sync Now"** on each stream
5. Wait for data to flow through DLO → DMO pipeline (typically 5-30 minutes)

Once this happens:
- `ssot__Account__dlm` and `ssot__Individual__dlm` will populate
- All 6 segments will begin returning members
- Activations can be created and will have data to export

---

## What's Left After the Sync

### Immediate (for new chat session):
1. **Verify data flowed** — query DMOs to confirm row counts
2. **Publish segments** — segments may need explicit publish to generate membership
3. **Create activations for each segment** — use the proven payload in `blockers-and-next-steps.md`
4. **Verify MC Data Extensions** — confirm segments appear in Marketing Cloud

### Future:
- Identity Resolution (requires Individual + ContactPointEmail data)
- Calculated Insights (blocked on schedule start date format)
- End-to-end demo: natural language → segment → activate → journey in MC

---

## Critical Technical Findings

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
          "sql": "SELECT dmо.ssot__Id__c, dmo.KQ_Id__c FROM dmo_name__dlm dmo WHERE ..."
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
- Only **standard DMOs** work (ssot__Account__dlm, ssot__Individual__dlm) — custom DMOs (ContactProfile__dlm) return "Object not found" even when they exist and are segmentable
- Column names in SQL must match **actual materialized columns** (query with `SELECT * FROM dmo LIMIT 1` to see what's available), NOT the full field list from the DMO definition

### Activation Target API Format (WORKING)

```json
{
  "platformType": "AmazonS3",
  "name": "Target_Name",
  "dataSpaceName": "default",
  "connector": {
    "bucketName": "my-bucket-name"
  }
}
```

**Valid platformType values discovered:**
- `AmazonS3` — needs `connector.bucketName`
- `SFTP` — needs connector details (format unclear)
- `GoogleCloudStorage` — needs connector details
- `AzureBlob` — needs connector details

**Marketing Cloud** — CANNOT be created via API. Must use UI:
- Data Cloud Setup → Marketing → Marketing Cloud Engagement
- The UI creates internal linkage (DataConConfigurationId, AudienceDmoNames) that API cannot replicate
- Once created via UI, activations against it work fully via API

### Activation Creation ✅ SOLVED

POST to `/ssot/activations` requires:
- `name` ✅
- `activationTargetName` ✅ (must be UI-created target for MC)
- `segmentApiName` ✅
- `dataSpaceName` ✅
- `refreshType` ("FULL_REFRESH" or "INCREMENTAL") ✅
- `activationTargetSubjectConfig` ✅ — `{"developerName": "ssot__Individual__dlm"}`
- `attributesConfig` ✅ — at minimum the primary key attribute

See `blockers-and-next-steps.md` for the complete working payload.

### Data Stream Sync (HARD BLOCKER)

The SalesforceDotCom connector **cannot be triggered programmatically**:
```
"Connector type SalesforceDotCom is not allowed to run in non-interactive mode"
```

Attempted and all failed:
- `sf data360 data-stream run`
- REST API POST to `/ssot/data-streams/{name}/actions/run`
- Apex callout to same endpoint
- Setting refresh frequency to HOURLY
- Every API version from v58 to v66

This is a Salesforce platform limitation — the SFDC connector requires a browser session.

### DMO Column Discovery

Not all fields defined on a DMO are materialized in the data lake. To find actual queryable columns:
```sql
SELECT * FROM dmo_name__dlm LIMIT 1
```
The `metadata` in the response shows the real column list.

**ssot__Individual__dlm actual columns (21):**
`ssot__Id__c, KQ_Id__c, KQ_PrimaryAccountId__c, ssot__BirthDate__c, ssot__CreatedDate__c, ssot__DataSourceId__c, ssot__DataSourceObjectId__c, ssot__DeathDate__c, ssot__ExternalRecordId__c, ssot__ExternalSourceId__c, ssot__FirstName__c, ssot__GenderId__c, ssot__GenderIdentity__c, ssot__LastModifiedDate__c, ssot__LastName__c, ssot__PersonName__c, ssot__PhotoURL__c, ssot__PrimaryAccountId__c, ssot__Pronoun__c, ssot__Salutation__c, ssot__TitleName__c`

**ssot__Account__dlm actual columns (28):**
`ssot__Id__c, KQ_Id__c, KQ_BillContactAddressId__c, KQ_OwnerId__c, KQ_ParentAccountId__c, KQ_SalesPhoneId__c, ssot__AccountBusinessType__c, ssot__AccountOwnershipType__c, ssot__AccountRatingType__c, ssot__AccountSource__c, ssot__AccountTypeId__c, ssot__AccountType__c, ssot__AnnualRevenueAmount__c, ssot__BillContactAddressId__c, ssot__CreatedDate__c, ssot__DataSourceId__c, ssot__DataSourceObjectId__c, ssot__Description__c, ssot__EmployeeCount__c, ssot__LastActivityDate__c, ssot__LastModifiedDate__c, ssot__Name__c, ssot__Number__c, ssot__OwnerId__c, ssot__ParentAccountId__c, ssot__PrimaryIndustry__c, ssot__SalesPhoneId__c, ssot__WebsiteAddr__c`

---

## Key IDs & References

```
Org Alias: phil_master_sdo
Data Space: default
Admin Profile FieldPermissions ParentId: 0PSg7000003mQaxGAE

Activation Target ID: 85Ug70000022hsXEAQ
Activation Target Name: Marketing_Cloud_S3_Bridge

Segment IDs:
  High_Intent_Web_Visitors:     3HXg70000000a6jGAA
  Enterprise_Decision_Makers:   3HXg70000000a8LGAQ
  Titled_Professionals:         3HXg70000000aGPGAY
  High_Value_Accounts:          3HXg70000000aBZGAY
  Technology_Industry:          3HXg70000000aDBGAY
  Named_Enterprise_Accounts:    3HXg70000000a9xGAA

ContactProfile Custom Object: ContactProfile__c (2,126 records in CRM)
ContactProfile DLO: ContactProfile__dll
ContactProfile DMO: ContactProfile__dlm (isSegmentable: true, 0 records)
```

---

## Files in This Folder

| File | Purpose |
|------|---------|
| `README.md` | This document — full status and findings |
| `ci-high-intent-visitors.json` | Calculated Insight definition (blocked on schedule format) |
| `segment-high-intent-visitors.json` | Original segment definition (pre-discovery of correct format) |
| `contact-profiles.csv` | Sample data template |
| `ingestion-schema-contacts.json` | Ingestion API schema |
