# Data Cloud → Marketing Cloud Activation — Complete Workflow

> **Last Updated**: 2026-06-27
> **Status**: FULLY WORKING — all 3 steps proven end-to-end

---

## The 3-Step Workflow

```
┌──────────────────────────────────────────────────┐
│  Step 1: MC Connection (UI, one-time per org)    │  Requires browser OAuth
│  Step 2: Activation Target (API, per org)        │  sObject API — fully programmatic!
│  Step 3: Create Activations (API, per segment)   │  SSOT API — fully programmatic!
└──────────────────────────────────────────────────┘
```

### Step 1: Establish MC Connection ✅ DONE

**Where**: Data Cloud Setup → Marketing → Marketing Cloud Engagement
**What it does**: Links your Salesforce org to a Marketing Cloud Business Unit via OAuth
**Status**: "SE Demo Autopilot MC" connector is **ACTIVE** with 100% setup complete

Key facts:
- This is NOT the same as MC Connect (et4ae5 package) — that's for CRM↔MC record sync
- The connection creates a `MktDataConnection` record (9cg prefix) and an SSOT connection (1WM prefix)
- Business Units mapped: MedVet (523019897) to Data Space "default"
- Connection ID: `1WMg70000002O33GAE`

### Step 2: Create Activation Target ✅ DONE — AND CAN BE DONE PROGRAMMATICALLY!

**Where**: sObject API (`POST /sobjects/ActivationTarget`)
**What it does**: Creates the destination "slot" that segments publish to
**Status**: `pk_test_mc` target is **ACTIVE** (ID: `85Ug70000023IAXEA2`)

**DISCOVERY (2026-06-27)**: The target CAN be created programmatically via the sObject API! The SSOT REST API (`/ssot/activation-targets`) still fails, but direct sObject insert works IF you provide the correct `DataConConfigurationId`.

**Working sObject creation payload:**
```bash
sf api request rest "/services/data/v64.0/sobjects/ActivationTarget" -o phil_master_sdo --method POST --body '{
  "MasterLabel": "my_mc_target",
  "ConnectionType": "SalesforceMarketingCloud",
  "TargetType": "DE",
  "TargetStatus": "ACTIVE",
  "RunStatus": "SUCCESS",
  "DataSpaceId": "0vhg70000002SZhAAM",
  "DataConConfigurationId": "7M4g7000001G7EfCAK"
}'
```

**Key insight**: The `DataConConfigurationId` (7M4 prefix) is created during the MC Connection setup (Step 1). It's NOT the same as the MktDataConnection record (9cg prefix). Using the 9cg ID creates a target that looks valid but fails on activation. The 7M4 ID is what makes it work.

**What still requires UI (Step 1 only)**:
- The MC Connection + its internal 7M4 configuration record
- This creates the OAuth trust chain and Business Unit mapping
- Once this exists, targets AND activations are both fully programmatic

**What does NOT require UI**:
- Activation Target creation (via sObject API with correct DataConConfigurationId)
- Activation creation (via SSOT API with correct payload)

### Step 3: Create Activations via API ✅ PROVEN WORKING

**Where**: `POST /services/data/v64.0/ssot/activations` or `sf data360 activation create`
**What it does**: Links a specific published segment to the MC target, publishing members as a Data Extension
**Status**: FULLY WORKING — repeatable for any segment

---

## Working Activation Payload

```json
{
  "activationTargetName": "pk_test_mc",
  "dataSpaceName": "default",
  "name": "My_Activation_Name",
  "segmentApiName": "Segment_Developer_Name",
  "refreshType": "FULL_REFRESH",
  "activationTargetSubjectConfig": {
    "developerName": "ssot__Individual__dlm"
  },
  "attributesConfig": {
    "attributes": [
      {
        "dataSourceType": "Text",
        "entityName": "ssot__Individual__dlm",
        "label": "Individual Id",
        "name": "ssot__Id__c",
        "referenceAttributeName": "Id",
        "source": "DIRECT",
        "type": "MODEL"
      }
    ]
  }
}
```

### Required Fields Explained

| Field | Purpose | Value |
|-------|---------|-------|
| `activationTargetName` | References the UI-created target | `pk_test_mc` |
| `dataSpaceName` | Which Data Space | `default` |
| `name` | Unique activation developer name | Your choice (no special chars) |
| `segmentApiName` | Which segment to activate | Must exist and be published |
| `refreshType` | `FULL_REFRESH` or `INCREMENTAL` | Start with FULL_REFRESH |
| `activationTargetSubjectConfig` | The DMO being activated | `ssot__Individual__dlm` for people, `ssot__Account__dlm` for accounts |
| `attributesConfig` | At minimum, the primary key attribute | See payload above |

### Optional: Include Email Addresses

Add `contactPointsConfig` to include email in the published DE:

```json
"contactPointsConfig": {
  "contactPoints": [
    {
      "contactPointEntityName": "ssot__ContactPointEmail__dlm",
      "type": "EMAIL",
      "queryPathConfig": {
        "configs": [
          {
            "queryPath": [
              {"fieldName": "ssot__Id__c", "objectName": "ssot__Individual__dlm"},
              {"fieldName": "ssot__PartyId__c", "objectName": "ssot__ContactPointEmail__dlm"}
            ]
          }
        ]
      },
      "fieldConfig": {
        "contactPointFields": [
          {"label": "Email Address", "name": "ssot__EmailAddress__c", "referenceAttributeName": "EmailAddress"}
        ]
      },
      "sourceConfig": {
        "contactPointSources": [
          {"dataSourceId": "Any", "dataSourcePreference": "ANY", "dataSourcePriority": 1, "name": "Any"}
        ]
      }
    }
  ]
}
```

### For Account-Based Segments

Change `activationTargetSubjectConfig.developerName` to `ssot__Account__dlm` and update `attributesConfig` entity/field references accordingly.

---

## Discovering the DataConConfigurationId on a New Org

After the MC Connection (Step 1) is established via UI, you need to find the 7M4-prefix `DataConConfigurationId` for programmatic target creation. Two approaches:

### Option A: Query an existing ActivationTarget (if one exists)
```bash
sf data query -q "SELECT DataConConfigurationId FROM ActivationTarget WHERE ConnectionType = 'SalesforceMarketingCloud' LIMIT 1" -o <org> --json 2>/dev/null
```

### Option B: Look at MktDataConnection + ActivationTarget relationship
The 7M4 record is created as part of the MC Engagement connector setup. It's NOT the MktDataConnection itself (9cg prefix). Currently the only reliable way to get it is from an existing target or by creating one via UI first and querying it.

### For this org (phil_master_sdo):
```
DataConConfigurationId: 7M4g7000001G7EfCAK
DataSpaceId:            0vhg70000002SZhAAM
```

---

## Quick Reference Commands

```bash
# List existing activations
sf api request rest "/services/data/v64.0/ssot/activations" -o phil_master_sdo

# Get activation detail (shows full config including subject/attributes)
sf api request rest "/services/data/v64.0/ssot/activations/My_Activation_Name" -o phil_master_sdo

# Create activation from file
sf data360 activation create -o phil_master_sdo -f activation.json 2>/dev/null

# Or via raw REST
sf api request rest "/services/data/v64.0/ssot/activations" -o phil_master_sdo --method POST --body '<json>'

# List activation targets
sf api request rest "/services/data/v64.0/ssot/activation-targets" -o phil_master_sdo

# Verify MC connection health
sf api request rest "/services/data/v64.0/ssot/connections/1WMg70000002O33GAE?connectorType=SalesforceMarketingCloud" -o phil_master_sdo

# List segments (to get segmentApiName values)
sf api request rest "/services/data/v64.0/ssot/segments" -o phil_master_sdo
```

---

## Key IDs

```
MC Activation Target Name:    pk_test_mc
MC Activation Target ID:      85Ug70000023IAXEA2
MC Connection ID (SSOT):      1WMg70000002O33GAE
MC Business Unit (MedVet):    523019897
Data Space:                   default
Individual DMO:               ssot__Individual__dlm
Account DMO:                  ssot__Account__dlm
Contact Point Email DMO:      ssot__ContactPointEmail__dlm
Contact Point Email Entity:   0gjg7000000Ith7AAC
Individual Entity ID:         0gjg7000000Itl1AAC
```

---

## What We Learned (Gotchas for Future Sessions)

### Field Name Discovery
The activation API's required field is `activationTargetSubjectConfig` (not `subjectConfig`, `subjects`, or any of the ~30 other names tried). The breakthrough came from creating an activation through the UI, then querying `/ssot/activations/{name}` to reverse-engineer the exact field structure.

### MC Target Creation: sObject API Works, SSOT API Does Not
- **SSOT API** (`POST /ssot/activation-targets`): Fails with `"Required Marketing Cloud Connector Details are not present"` — the connector block doesn't accept MC-specific fields.
- **sObject API** (`POST /sobjects/ActivationTarget`): WORKS if you provide the correct `DataConConfigurationId` (7M4 prefix, NOT the 9cg MktDataConnection ID).
- Using the wrong DataConConfigurationId (9cg MktDataConnection) creates a target that looks valid but activations against it fail with `"Could not get activation target"`.
- The `AudienceHistoryDmoName`/`AudienceLatestDmoName` fields are read-only and get auto-populated when the first activation is created — they don't need to be set during target creation.

### MC Connect != MC Engagement Connector
- **MC Connect** (et4ae5 package): Syncs CRM records to/from Marketing Cloud. NOT for Data Cloud.
- **MC Engagement Connector**: The Data Cloud native connection for publishing segments to MC as Data Extensions. This is what we use.

### Wrong Setup URLs
These do NOT work for finding the MC Engagement connector setup:
- `/lightning/setup/CdpActivationTarget/home` — page not found
- `/lightning/setup/MarketingCloudConnect/home` — page not found (also wrong concept)

The correct path is: **Data Cloud Setup → Marketing (expand the section) → Marketing Cloud Engagement**

### Connection Status Verification
```bash
# This should show businessUnitsToDataSpaces is NOT empty:
sf api request rest "/services/data/v64.0/ssot/connections/1WMg70000002O33GAE?connectorType=SalesforceMarketingCloud" -o phil_master_sdo
```

Expected: `"businessUnitsToDataSpaces": [{"businessUnitName": "sfmc_523019897", "dataSpaceName": "default"}]`

---

## Remaining Manual Steps

### Data Stream Sync (for segment membership)
The SalesforceDotCom connector cannot be triggered programmatically:
```
"Connector type SalesforceDotCom is not allowed to run in non-interactive mode"
```

To populate DMOs with data (so segments have members to activate):
1. Log into SDO org
2. Setup → Data Cloud → Data Streams
3. Click "Run" on each SalesforceDotCom stream
4. Wait 5-30 minutes for data to flow through

### If Activation Target Gets Deleted
Recreate it programmatically via sObject API (see Step 2 above). You do NOT need the UI — as long as the MC Connection (Step 1) still exists and you have the `DataConConfigurationId` (7M4g7000001G7EfCAK).

---

## Cleanup

The old S3 bridge target (`85Ug70000022hsXEAQ`) is in ERROR state and can be deleted:
```bash
sf api request rest "/services/data/v64.0/ssot/activation-targets/85Ug70000022hsXEAQ" -o phil_master_sdo --method DELETE
```
