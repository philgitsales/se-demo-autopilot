# Setup Guide: Data Cloud (Salesforce CRM → Unified Profiles → Segments)

> **What this does**: Ingests CRM data into Data Cloud, harmonizes it into unified profiles,
> and creates targetable segments. These segments can then be activated to Marketing Cloud
> (see `data-cloud-to-marketing-cloud.md`) or other destinations.

---

## Overview

```
CRM Objects → Data Streams → DLOs → DMO Mappings → Unified DMOs → Segments
     (1)          (2)         (3)        (4)            (5)          (6)
```

The pipeline has 6 phases. Most are programmatic, but data stream sync requires one UI click.

---

## Prerequisites

- Salesforce org with Data Cloud enabled and provisioned
- `sf` CLI authenticated to the org (`sf org display -o <alias>`)
- `sf data360` community plugin installed (`sf data360 man` to verify)
- CRM data to ingest (Accounts, Contacts, or custom objects with records)

### Verify readiness:
```bash
# Plugin installed?
sf data360 man

# Org accessible?
sf org display -o <org_alias>

# Data Cloud provisioned? (run full diagnostic)
node skills/data360-orchestrate/scripts/diagnose-org.mjs -o <org_alias> --json
```

---

## Step 1: Load CRM Source Data (API — programmatic)

**What**: Ensure your CRM has data to ingest. Data Cloud pulls FROM CRM objects.

### Option A: Use existing standard objects (Account, Contact, Lead, Opportunity)
If the SDO already has records in standard objects, skip to Step 2.

### Option B: Create a custom object with sample data

```bash
# Create the custom object (example: ContactProfile__c)
sf api request rest "/services/data/v64.0/tooling/sobjects/CustomObject" -o <org> --method POST --body '{
  "FullName": "ContactProfile__c",
  "Label": "Contact Profile",
  "PluralLabel": "Contact Profiles",
  "DeploymentStatus": "Deployed",
  "SharingModel": "ReadWrite",
  "NameField": {"type": "AutoNumber", "label": "Profile ID"}
}'

# Create fields (repeat for each field)
sf api request rest "/services/data/v64.0/tooling/sobjects/CustomField" -o <org> --method POST --body '{
  "FullName": "ContactProfile__c.Email__c",
  "Metadata": {"type": "Email", "label": "Email", "required": false}
}'

# Bulk load data (CSV → Bulk API 2.0)
sf data import bulk -o <org> -f data.csv -s ContactProfile__c
```

### Option C: Use Bulk API 2.0 directly
```bash
# Create job
sf api request rest "/services/data/v64.0/jobs/ingest" -o <org> --method POST --body '{
  "object": "ContactProfile__c",
  "operation": "insert",
  "contentType": "CSV"
}'

# Upload CSV data to the job
# Close job to process
```

### Grant Field Level Security (if custom object):
```bash
# Find the admin profile's permission set ID
sf data query -q "SELECT Id FROM PermissionSet WHERE Profile.Name = 'System Administrator' AND IsOwnedByProfile = true" -o <org> --json

# Grant FLS for each field
sf api request rest "/services/data/v64.0/sobjects/FieldPermissions" -o <org> --method POST --body '{
  "ParentId": "<PERMISSION_SET_ID>",
  "SobjectType": "ContactProfile__c",
  "Field": "ContactProfile__c.Email__c",
  "PermissionsRead": true,
  "PermissionsEdit": true
}'
```

### How to verify:
```bash
sf data query -q "SELECT COUNT() FROM ContactProfile__c" -o <org> --json
```

---

## Step 2: Create Data Streams (API — programmatic)

**What**: Data streams pull data from CRM objects into Data Lake Objects (DLOs).

### From existing CRM object:
```bash
sf data360 data-stream create-from-object -o <org> --object ContactProfile__c --connection SalesforceDotCom_Home 2>/dev/null
```

### From JSON definition (more control):
```bash
sf data360 data-stream create -o <org> -f stream-definition.json 2>/dev/null
```

### Stream definition template:
```json
{
  "name": "ContactProfile",
  "label": "Contact Profile",
  "datasource": "SalesforceDotCom_Home",
  "datastreamType": "CONNECTORSFRAMEWORK",
  "connectorInfo": {
    "connectorType": "SalesforceDotCom",
    "connectorDetails": {
      "name": "SalesforceDotCom_Home",
      "sourceObject": "ContactProfile__c"
    }
  },
  "dataLakeObjectInfo": {
    "label": "Contact Profile",
    "name": "ContactProfile__dll",
    "category": "Profile",
    "dataspaceInfo": [{"name": "Default"}],
    "dataLakeFieldInputRepresentations": [
      {"name": "Id", "label": "Record ID", "dataType": "Text", "isPrimaryKey": true},
      {"name": "Email_c", "label": "Email", "dataType": "Text", "isPrimaryKey": false},
      {"name": "FirstName_c", "label": "First Name", "dataType": "Text", "isPrimaryKey": false},
      {"name": "LastName_c", "label": "Last Name", "dataType": "Text", "isPrimaryKey": false}
    ]
  },
  "sourceFields": [
    {"name": "Id", "dataType": "Text"},
    {"name": "Email__c", "dataType": "Text"},
    {"name": "FirstName__c", "dataType": "Text"},
    {"name": "LastName__c", "dataType": "Text"}
  ],
  "mappings": [],
  "refreshConfig": {
    "isAccelerationEnabled": true,
    "refreshMode": "UPSERT",
    "frequency": {"frequencyType": "HOURLY"}
  }
}
```

### Stream categories:
| Category | Use for | Requirement |
|----------|---------|-------------|
| `Profile` | Person/entity records (Contacts, Accounts) | Primary key |
| `Engagement` | Time-based events (clicks, purchases) | Primary key + event time |
| `Other` | Reference/config data | Primary key |

### How to verify:
```bash
sf data360 data-stream list -o <org> 2>/dev/null
```

### Pitfalls:
- DLO field names transform `__c` → `_c` (double underscore becomes single)
- Stream creation succeeds but data won't flow until Step 3 (manual sync)
- The `SalesforceDotCom_Home` connection name is standard in SDOs — verify with `sf data360 connection list -o <org> --connector-type SalesforceDotCom 2>/dev/null`

---

## Step 3: Trigger Data Stream Sync (UI — manual, one-time)

**Why manual**: The SalesforceDotCom connector CANNOT be triggered programmatically.
```
"Connector type SalesforceDotCom is not allowed to run in non-interactive mode"
```
This was tested with: `sf data360 data-stream run`, REST API POST, Apex callout, setting refresh frequency — ALL fail.

### What to do:

1. Log into the Salesforce org
2. Navigate to: **Setup → Data Cloud → Data Streams**
3. Find each SalesforceDotCom connector stream
4. Click **"Run"** or **"Sync Now"** on each stream
5. Wait 5-30 minutes for data to flow through DLO → DMO pipeline

### How to verify:
```bash
# Check DLO row counts
sf data360 query sql -o <org> --sql 'SELECT COUNT(*) FROM "ContactProfile__dll"' 2>/dev/null

# Check if DMOs have data
sf data360 query sql -o <org> --sql 'SELECT COUNT(*) FROM "ssot__Individual__dlm"' 2>/dev/null
sf data360 query sql -o <org> --sql 'SELECT COUNT(*) FROM "ssot__Account__dlm"' 2>/dev/null
```

### Pitfalls:
- After creating a new stream, you MUST go to the UI and run it — it won't auto-sync
- SDO standard streams (Account, Contact, Lead) may already have been synced during org provisioning
- If counts are 0 after 30+ minutes, check the stream status in the UI for errors

---

## Step 4: Configure DMO Mappings (usually pre-configured in SDOs)

**What**: Maps DLO fields to standard Data Model Objects (DMOs). In most SDOs, the standard mappings (Contact → Individual, Account → Account) are already configured.

### Check existing mappings:
```bash
sf data360 dmo list -o <org> 2>/dev/null
sf data360 dmo mapping-list -o <org> --source Contact_Home__dll --target ssot__Individual__dlm 2>/dev/null
```

### If you need to create custom mappings:
```bash
sf data360 dmo mapping-create -o <org> -f mapping.json 2>/dev/null
```

### Standard DMO mapping (Contact → Individual):
| CRM Field | DLO Field | DMO Field |
|-----------|-----------|-----------|
| Id | Id | ssot__ExternalRecordId__c |
| FirstName | FirstName | ssot__FirstName__c |
| LastName | LastName | ssot__LastName__c |
| Email | Email | (goes to ContactPointEmail DMO) |
| Title | Title | ssot__TitleName__c |

### How to verify:
```bash
# After sync completes, query the DMO directly
sf data360 query sql -o <org> --sql 'SELECT * FROM "ssot__Individual__dlm" LIMIT 5' 2>/dev/null
```

### Pitfalls:
- Not all DLO fields map to DMO fields — some need custom field creation on the DMO
- SDOs typically have standard mappings pre-built; check before creating duplicates
- Custom DMOs (e.g., ContactProfile__dlm) exist but may not be segmentable even if marked as such

---

## Step 5: Identity Resolution (API — programmatic, optional)

**What**: Merges duplicate records into unified profiles. Required for accurate segment counts.

### Check if IR is configured:
```bash
sf data360 identity-resolution list -o <org> 2>/dev/null
```

### Create an IR ruleset:
```bash
sf data360 identity-resolution create -o <org> -f ir-ruleset.json 2>/dev/null
```

### IR ruleset template (match on email):
```json
{
  "label": "Main",
  "description": "Match on email address",
  "configurationType": "individual",
  "rulesetId": "main",
  "doesRunAutomatically": false,
  "matchRules": [
    {
      "label": "Exact Email",
      "criteria": [
        {
          "entityName": "ssot__ContactPointEmail__dlm",
          "fieldName": "ssot__EmailAddress__c",
          "matchMethodType": "exactnormalized",
          "caseSensitiveMatch": false,
          "shouldMatchOnBlank": false
        }
      ]
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
}
```

### Run IR:
```bash
sf data360 identity-resolution run -o <org> --name Main 2>/dev/null
```

### How to verify:
```bash
# Check unified profile count
sf data360 query sql -o <org> --sql 'SELECT COUNT(*) FROM "UnifiedssotIndividualMain__dlm"' 2>/dev/null
```

### Pitfalls:
- IR requires ContactPointEmail data to exist (needs Contact.Email mapped to ssot__ContactPointEmail__dlm)
- IR runs are asynchronous — wait and re-check
- If no email data exists yet, skip this step; segments still work on non-unified DMOs

---

## Step 6: Create Segments (API — programmatic)

**What**: Defines audiences based on DMO data. Segments are what get activated to downstream platforms.

### Create a segment:
```bash
sf data360 segment create -o <org> -f segment.json --api-version 64.0 2>/dev/null
```

### Segment definition template:
```json
{
  "displayName": "High Value Accounts",
  "developerName": "High_Value_Accounts",
  "segmentType": "Dbt",
  "includeDbt": {
    "models": {
      "models": [
        {
          "name": "HighValueAccounts",
          "sql": "SELECT a.ssot__Id__c, a.KQ_Id__c FROM ssot__Account__dlm a WHERE a.ssot__AnnualRevenueAmount__c > 1000000"
        }
      ]
    }
  }
}
```

### Publish the segment:
```bash
sf data360 segment publish -o <org> --name High_Value_Accounts 2>/dev/null
```

### Check member count:
```bash
sf data360 segment count -o <org> --name High_Value_Accounts 2>/dev/null
```

### How to verify:
```bash
sf data360 segment list -o <org> 2>/dev/null
sf api request rest "/services/data/v64.0/ssot/segments" -o <org> 2>/dev/null
```

### Critical rules for segment SQL:
- **MUST include the Key Qualifier field** (`KQ_Id__c`) in SELECT alongside the primary key (`ssot__Id__c`)
- **Only PROFILE category DMOs** that are `isSegmentable: true` can be segmented
- **NO JOINs** — segment SQL can only reference the single `segmentOn` DMO
- **NO subqueries** referencing other DMOs
- **Only standard DMOs work** (`ssot__Account__dlm`, `ssot__Individual__dlm`) — custom DMOs return "Object not found"
- **Column names must match materialized columns**, not the full DMO schema. Discover with:
  ```bash
  sf data360 query sql -o <org> --sql 'SELECT * FROM "ssot__Individual__dlm" LIMIT 1' 2>/dev/null
  ```
- **Must use `--api-version 64.0`** — segment creation fails on some versions without this

### Pitfalls:
- Segments will show 0 members if the underlying DMO has no data (Step 3 not done)
- Publishing is often asynchronous — wait and re-check count
- `segment members` returns opaque IDs; use SQL joins for human-readable details

---

## DMO Column Reference (materialized fields only)

These are the ACTUAL queryable columns. Not all defined DMO fields are materialized.

### ssot__Individual__dlm (21 columns):
```
ssot__Id__c, KQ_Id__c, KQ_PrimaryAccountId__c, ssot__BirthDate__c,
ssot__CreatedDate__c, ssot__DataSourceId__c, ssot__DataSourceObjectId__c,
ssot__DeathDate__c, ssot__ExternalRecordId__c, ssot__ExternalSourceId__c,
ssot__FirstName__c, ssot__GenderId__c, ssot__GenderIdentity__c,
ssot__LastModifiedDate__c, ssot__LastName__c, ssot__PersonName__c,
ssot__PhotoURL__c, ssot__PrimaryAccountId__c, ssot__Pronoun__c,
ssot__Salutation__c, ssot__TitleName__c
```

### ssot__Account__dlm (28 columns):
```
ssot__Id__c, KQ_Id__c, KQ_BillContactAddressId__c, KQ_OwnerId__c,
KQ_ParentAccountId__c, KQ_SalesPhoneId__c, ssot__AccountBusinessType__c,
ssot__AccountOwnershipType__c, ssot__AccountRatingType__c, ssot__AccountSource__c,
ssot__AccountTypeId__c, ssot__AccountType__c, ssot__AnnualRevenueAmount__c,
ssot__BillContactAddressId__c, ssot__CreatedDate__c, ssot__DataSourceId__c,
ssot__DataSourceObjectId__c, ssot__Description__c, ssot__EmployeeCount__c,
ssot__LastActivityDate__c, ssot__LastModifiedDate__c, ssot__Name__c,
ssot__Number__c, ssot__OwnerId__c, ssot__ParentAccountId__c,
ssot__PrimaryIndustry__c, ssot__SalesPhoneId__c, ssot__WebsiteAddr__c
```

### To discover columns on any DMO:
```bash
sf data360 query sql -o <org> --sql 'SELECT * FROM "<dmo_name>" LIMIT 1' 2>/dev/null
# The metadata in the response shows the real column list
```

---

## Discovering Key IDs (per org)

Every org has its own Data Cloud IDs. Run these to find yours:

```bash
# Data Space ID
sf data query -q "SELECT Id, DeveloperName FROM DataSpace" -o <org> --json 2>/dev/null

# CRM Connection name (usually "SalesforceDotCom_Home" in SDOs)
sf data360 connection list -o <org> --connector-type SalesforceDotCom 2>/dev/null

# Admin Permission Set ID (for FLS grants)
sf data query -q "SELECT Id FROM PermissionSet WHERE Profile.Name = 'System Administrator' AND IsOwnedByProfile = true" -o <org> --json 2>/dev/null

# Existing segments
sf api request rest "/services/data/v64.0/ssot/segments" -o <org> 2>/dev/null
```

### Example values (from a reference org — YOUR org will differ):
```
Org Alias:                    phil_master_sdo
Data Space:                   default
DataSpaceId:                  0vhg70000002SZhAAM
Admin FieldPermissions Parent: 0PSg7000003mQaxGAE
CRM Connection Name:          SalesforceDotCom_Home
```

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `"Connector type SalesforceDotCom is not allowed to run in non-interactive mode"` | Trying to sync SFDC streams programmatically | Must use UI (Step 3) |
| `"Object not found"` in segment SQL | Using a custom DMO or wrong table name | Use only standard DMOs (`ssot__Account__dlm`, `ssot__Individual__dlm`) |
| Segment has 0 members | DMO has no data | Complete Step 3 (UI sync) |
| `"Couldn't find CDP tenant ID"` | Query-plane not ready or Data Cloud not provisioned | Run org diagnostic, wait, or check provisioning |
| Stream creation succeeds but DLO has 0 rows | Stream was never synced | Go to UI and click Run |
| `--api-version` errors on segment create | Wrong or missing API version | Always use `--api-version 64.0` |
| IR run fails | No ContactPointEmail data exists | Ensure Contact.Email is mapped to ssot__ContactPointEmail__dlm and synced |

---

## What Cannot Be Automated (and why)

| Step | Why it needs UI |
|------|-----------------|
| Data stream sync (Step 3) | Platform limitation: SalesforceDotCom connector blocks non-interactive mode. Every API approach fails. |
| Data Cloud provisioning | Org-level enablement done during SDO creation. |
| Initial DMO mapping setup | Usually pre-configured in SDOs. If missing, may require UI for complex multi-object mappings. |

---

## Quick Reference: Full Pipeline Commands

```bash
# 1. Check what exists
sf data360 data-stream list -o <org> 2>/dev/null
sf data360 dmo list -o <org> 2>/dev/null
sf data360 segment list -o <org> 2>/dev/null

# 2. Create stream from CRM object
sf data360 data-stream create-from-object -o <org> --object Account --connection SalesforceDotCom_Home 2>/dev/null

# 3. [MANUAL] Go to UI → Data Streams → Run

# 4. Verify data flowed
sf data360 query sql -o <org> --sql 'SELECT COUNT(*) FROM "ssot__Individual__dlm"' 2>/dev/null

# 5. Create segment
sf data360 segment create -o <org> -f segment.json --api-version 64.0 2>/dev/null
sf data360 segment publish -o <org> --name My_Segment 2>/dev/null

# 6. Check count
sf data360 segment count -o <org> --name My_Segment 2>/dev/null
```
