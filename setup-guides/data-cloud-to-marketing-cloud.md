# Setup Guide: Data Cloud → Marketing Cloud Activation

> **What this does**: Publishes Data Cloud segments as Data Extensions in Marketing Cloud.
> Segments become targetable audiences for Journeys, Emails, and Automations.

---

## Overview

```
Data Cloud Segment → Activation → Marketing Cloud Data Extension
                                        ↓
                                  Journey Builder / Email Send
```

Three steps total. Only Step 1 requires a browser.

---

## Prerequisites

- Salesforce org with Data Cloud enabled and provisioned
- Marketing Cloud Business Unit linked to the same Salesforce org
- MC Engagement connector available in Data Cloud Setup (comes with MC license)
- At least one published segment in Data Cloud
- `sf` CLI authenticated to the org (`sf org display -o <alias>`)

---

## Step 1: Establish MC Connection (UI — one-time per org)

**Why manual**: This is an OAuth handshake between Salesforce and Marketing Cloud. The browser-based flow creates an internal trust chain that cannot be replicated via API.

### What to do:

1. Log into the Salesforce org
2. Navigate to: **Setup → Data Cloud → Marketing (expand section) → Marketing Cloud Engagement**
3. Click **"Connect"** or **"New Connection"**
4. Authenticate with Marketing Cloud credentials when prompted
5. Select the Business Unit(s) to activate
6. Map Business Unit(s) to Data Space(s) (use "default" if only one)
7. Complete the wizard — status should show **ACTIVE** with 100% setup

### What this creates behind the scenes:
- `MktDataConnection` record (9cg prefix) — the connection metadata
- `DataConConfigurationId` record (7M4 prefix) — internal config needed for target creation
- `MktDataConnectionParam` — stores the MC org ID
- SSOT Connection (1WM prefix) — with `businessUnitsToDataSpaces` mapping

### How to verify:
```bash
# Connection should show businessUnitsToDataSpaces populated
sf api request rest "/services/data/v64.0/ssot/connections/<CONNECTION_ID>?connectorType=SalesforceMarketingCloud" -o <org> 2>/dev/null
```

### How to find the critical IDs after setup:
```bash
# Get the DataConConfigurationId (7M4 prefix) — REQUIRED for Step 2
sf data query -q "SELECT DataConConfigurationId FROM ActivationTarget WHERE ConnectionType = 'SalesforceMarketingCloud' LIMIT 1" -o <org> --json 2>/dev/null

# If no target exists yet, find it from MktDataConnection context:
# You'll need to create one target via UI first, then query it (chicken-and-egg)
# OR proceed to Step 2 which will work once you have the 7M4 ID

# Get the DataSpaceId
sf data query -q "SELECT Id, DeveloperName FROM DataSpace" -o <org> --json 2>/dev/null
```

---

## Step 2: Create Activation Target (API — programmatic)

**Why this works**: The sObject API allows direct creation of `ActivationTarget` records. The SSOT API (`/ssot/activation-targets`) does NOT work for MC — it rejects the request.

### Command:
```bash
sf api request rest "/services/data/v64.0/sobjects/ActivationTarget" -o <org> --method POST --body '{
  "MasterLabel": "<target_name>",
  "ConnectionType": "SalesforceMarketingCloud",
  "TargetType": "DE",
  "TargetStatus": "ACTIVE",
  "RunStatus": "SUCCESS",
  "DataSpaceId": "<DATA_SPACE_ID>",
  "DataConConfigurationId": "<7M4_CONFIG_ID>"
}'
```

### Required values:

| Field | Description | How to find |
|-------|-------------|-------------|
| `MasterLabel` | Name for this target (your choice) | Pick something descriptive |
| `ConnectionType` | Must be `SalesforceMarketingCloud` | Hardcoded |
| `TargetType` | Must be `DE` (Data Extension) | Hardcoded |
| `TargetStatus` | Must be `ACTIVE` | Hardcoded |
| `RunStatus` | Must be `SUCCESS` | Hardcoded |
| `DataSpaceId` | The Data Space ID (0vh prefix) | Query `DataSpace` sObject |
| `DataConConfigurationId` | The internal config ID (7M4 prefix) | See Step 1 verification |

### Pitfalls:
- **DO NOT use the SSOT API** (`/ssot/activation-targets` POST) — returns `"Required Marketing Cloud Connector Details are not present"`
- **DO NOT use the MktDataConnection ID** (9cg prefix) for `DataConConfigurationId` — creates a broken target where activations fail with `"Could not get activation target"`
- **MUST use the 7M4 prefix ID** — this is the internal config record created during Step 1

### How to verify:
```bash
# Should appear in the list with status ACTIVE
sf api request rest "/services/data/v64.0/ssot/activation-targets" -o <org> 2>/dev/null
```

---

## Step 3: Create Activations (API — repeatable per segment)

**This is the repeatable step** — run it for each segment you want to publish to MC.

### Command:
```bash
sf api request rest "/services/data/v64.0/ssot/activations" -o <org> --method POST --body '{
  "activationTargetName": "<TARGET_MASTER_LABEL>",
  "dataSpaceName": "default",
  "name": "<UNIQUE_ACTIVATION_NAME>",
  "segmentApiName": "<SEGMENT_DEVELOPER_NAME>",
  "refreshType": "FULL_REFRESH",
  "activationTargetSubjectConfig": {
    "developerName": "<DMO_DEVELOPER_NAME>"
  },
  "attributesConfig": {
    "attributes": [
      {
        "dataSourceType": "Text",
        "entityName": "<DMO_DEVELOPER_NAME>",
        "label": "Individual Id",
        "name": "ssot__Id__c",
        "referenceAttributeName": "Id",
        "source": "DIRECT",
        "type": "MODEL"
      }
    ]
  }
}'
```

### Required values:

| Field | Description | Common values |
|-------|-------------|---------------|
| `activationTargetName` | MasterLabel from Step 2 | The name you chose |
| `name` | Unique developer name for this activation | No special characters |
| `segmentApiName` | Segment's developer name | Query `/ssot/segments` |
| `activationTargetSubjectConfig.developerName` | The DMO the segment is built on | `ssot__Individual__dlm` (people) or `ssot__Account__dlm` (accounts) |
| `attributesConfig` | At minimum the primary key | See example above |
| `refreshType` | `FULL_REFRESH` or `INCREMENTAL` | Start with FULL_REFRESH |

### Optional: Include email addresses
Add `contactPointsConfig` to include email in the published Data Extension:
```json
"contactPointsConfig": {
  "contactPoints": [{
    "contactPointEntityName": "ssot__ContactPointEmail__dlm",
    "type": "EMAIL",
    "queryPathConfig": {
      "configs": [{
        "queryPath": [
          {"fieldName": "ssot__Id__c", "objectName": "ssot__Individual__dlm"},
          {"fieldName": "ssot__PartyId__c", "objectName": "ssot__ContactPointEmail__dlm"}
        ]
      }]
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
  }]
}
```

### How to verify:
```bash
# Activation should appear with status PROCESSING or SUCCESS
sf api request rest "/services/data/v64.0/ssot/activations" -o <org> 2>/dev/null

# Get full detail of a specific activation
sf api request rest "/services/data/v64.0/ssot/activations/<ACTIVATION_DEVELOPER_NAME>" -o <org> 2>/dev/null
```

---

## Key IDs (phil_master_sdo org)

```
Org Alias:                    phil_master_sdo
DataConConfigurationId:       7M4g7000001G7EfCAK
DataSpaceId:                  0vhg70000002SZhAAM
Activation Target Name:       pk_test_mc
Activation Target ID:         85Ug70000023IAXEA2
MC Connection (SSOT):         1WMg70000002O33GAE
MC Business Unit (MedVet):    523019897
MktDataConnection ID:         9cgg70000004NHNAA2  (DO NOT use for DataConConfigurationId!)
Individual DMO:               ssot__Individual__dlm
Account DMO:                  ssot__Account__dlm
```

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `"Required Marketing Cloud Connector Details are not present"` | Using SSOT API for target creation | Use sObject API instead (Step 2) |
| `"Could not get activation target for targetId: ..."` | Target created with wrong DataConConfigurationId (9cg instead of 7M4) | Delete target, recreate with 7M4 ID |
| `"Subject Config cannot be empty"` | Missing `activationTargetSubjectConfig` in activation payload | Add it with the DMO developerName |
| `"Primary Attribute of activateOnEntity is Missing"` | Missing `attributesConfig` | Add at least the primary key attribute |
| `"Error occurred while fetching activation target"` | Target is broken (missing internal config) | Delete and recreate with correct 7M4 ID |
| `businessUnitsToDataSpaces` is empty | MC Connection OAuth not completed | Redo Step 1 in UI |

---

## What Cannot Be Automated (and why)

| Step | Why it needs UI |
|------|-----------------|
| MC Connection OAuth (Step 1) | Browser-based OAuth2 redirect flow between SF and MC. Creates internal trust chain that API cannot replicate. |
| SalesforceDotCom data stream sync | Platform limitation: `"Connector type SalesforceDotCom is not allowed to run in non-interactive mode"` |
