# Setup Guide: Data Cloud → Marketing Cloud Activation

> **What this does**: Publishes Data Cloud segments as Data Extensions in Marketing Cloud.
> Segments become targetable audiences for Journeys, Emails, and Automations.

---

## TL;DR for Agents

**If the org is already set up** (Steps 1-3 done), you only need two commands:

```bash
# Create an activation for a segment (one-time per segment)
sf api request rest "/services/data/v64.0/ssot/activations" -o <org> --method POST --body '{
  "activationTargetName": "<TARGET_NAME_FROM_STEP_2>",
  "dataSpaceName": "default",
  "name": "<UNIQUE_NAME>_MC",
  "segmentApiName": "<SEGMENT_DEVELOPER_NAME>",
  "refreshType": "FULL_REFRESH",
  "activationTargetSubjectConfig": {"developerName": "ssot__Individual__dlm"},
  "attributesConfig": {"attributes": [{"dataSourceType": "Text", "entityName": "ssot__Individual__dlm", "label": "Individual Id", "name": "ssot__Id__c", "referenceAttributeName": "Id", "source": "DIRECT", "type": "MODEL"}]}
}' 2>/dev/null

# Trigger the segment publish (this pushes data to MC)
sf data360 segment publish -o <org> --name <SEGMENT_DEVELOPER_NAME> 2>/dev/null
```

Wait 2-8 minutes. A Data Extension with the segment members appears in MC's Shared Data Extensions.

**To discover values you need:**
```bash
# Find your activation target name
sf api request rest "/services/data/v64.0/ssot/activation-targets" -o <org> 2>/dev/null

# Find available segments (need the developerName + segmentOnApiName)
sf api request rest "/services/data/v64.0/ssot/segments" -o <org> 2>/dev/null
```

---

## Overview

```
Data Cloud Segment → Activation → Publish → Marketing Cloud Data Extension
                                                    ↓
                                              Journey Builder / Email Send
```

Four steps total. Only Step 1 requires a browser. Steps 2-4 are fully programmatic.

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

## Step 4: Publish Segment & Push to MC (API — repeatable)

**This is the step most agents will run.** Steps 1-3 are one-time setup. Step 4 is what you do every time you want a segment to appear as a Data Extension in Marketing Cloud.

### Why this is needed

Creating an activation (Step 3) wires up the connection, but data only flows when the segment **publishes**. If the segment's `publishInterval` is `NO_REFRESH`, you must trigger it manually via API.

### Command — Trigger Segment Publish:
```bash
sf data360 segment publish -o <org> --name <SEGMENT_DEVELOPER_NAME> 2>/dev/null
```

### Example:
```bash
sf data360 segment publish -o phil_master_sdo --name High_Intent_Web_Visitors 2>/dev/null
# Output: "Segment publish started."
```

### What happens next (automatic):
1. Segment evaluates its SQL against the DMOs (~1-5 minutes)
2. Members are materialized into the segment membership table
3. The activation detects the publish and pushes members to MC as a Data Extension
4. The DE appears in Marketing Cloud's Shared Data Extensions folder

### How to verify — Data Cloud side:
```bash
# Check publish status (should go from PUBLISHING → SUCCESS)
sf api request rest "/services/data/v64.0/ssot/segments/<SEGMENT_DEVELOPER_NAME>" -o <org> 2>/dev/null

# Check activation picked up the publish
sf api request rest "/services/data/v64.0/ssot/activations" -o <org> 2>/dev/null
# Look for: lastPublishStatus = SUCCESS, lastPublishDate is populated
```

### How to verify — Marketing Cloud side:
```bash
# Authenticate to MC
source config/.env
TOKEN=$(curl -s -X POST "https://${MC_SUBDOMAIN}.auth.marketingcloudapis.com/v2/token" \
  -H "Content-Type: application/json" \
  -d "{\"grant_type\":\"client_credentials\",\"client_id\":\"$MC_CLIENT_ID\",\"client_secret\":\"$MC_CLIENT_SECRET\"}" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['access_token'])")

# Search for the DE by segment name
curl -s "https://${MC_SUBDOMAIN}.soap.marketingcloudapis.com/Service.asmx" \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
  <s:Header>
    <a:Action s:mustUnderstand="1">Retrieve</a:Action>
    <a:To s:mustUnderstand="1">https://'"${MC_SUBDOMAIN}"'.soap.marketingcloudapis.com/Service.asmx</a:To>
    <fueloauth xmlns="http://exacttarget.com">'"$TOKEN"'</fueloauth>
  </s:Header>
  <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">
      <RetrieveRequest>
        <ObjectType>DataExtension</ObjectType>
        <Properties>Name</Properties>
        <Properties>CustomerKey</Properties>
        <Properties>CreatedDate</Properties>
        <Filter xsi:type="SimpleFilterPart">
          <Property>Name</Property>
          <SimpleOperator>like</SimpleOperator>
          <Value>SEGMENT_DISPLAY_NAME_HERE</Value>
        </Filter>
      </RetrieveRequest>
    </RetrieveRequestMsg>
  </s:Body>
</s:Envelope>'
```

### MC Data Extension naming pattern:

Data Cloud names the DE in Marketing Cloud using this pattern:
```
{Segment Display Name}_{Activation Name (truncated)}_{SegmentId}_{ActivationId}_{Subject Initial}
```

Example:
```
Enterprise Decision Makers_pk_test_activati_1sgg70000006MSTAA2_85Rg70000002VyzEAE_I
```

Where:
- `I` = Individual (segment on `ssot__Individual__dlm`)
- `A` = Account (segment on `ssot__Account__dlm`)

The DE lands in Marketing Cloud's **Shared Data Extensions** area (not a Content Builder folder).

### Timing:
| Phase | Duration |
|-------|----------|
| Segment publish (SQL evaluation) | 1-5 minutes |
| Activation push to MC | 1-3 minutes after publish completes |
| DE visible in MC | Immediately after push |
| **Total end-to-end** | **2-8 minutes** |

### One-liner — Full end-to-end (create activation + publish):
```bash
# 1. Create the activation (if not already done)
sf api request rest "/services/data/v64.0/ssot/activations" -o <org> --method POST --body '{
  "activationTargetName": "<TARGET_NAME>",
  "dataSpaceName": "default",
  "name": "My_Segment_Name_MC",
  "segmentApiName": "My_Segment_Developer_Name",
  "refreshType": "FULL_REFRESH",
  "activationTargetSubjectConfig": {"developerName": "ssot__Individual__dlm"},
  "attributesConfig": {"attributes": [{"dataSourceType": "Text", "entityName": "ssot__Individual__dlm", "label": "Individual Id", "name": "ssot__Id__c", "referenceAttributeName": "Id", "source": "DIRECT", "type": "MODEL"}]}
}' 2>/dev/null

# 2. Trigger the publish
sf data360 segment publish -o <org> --name My_Segment_Developer_Name 2>/dev/null
```

### Pitfalls:
- Segment must be in `ACTIVE` status before you can publish it
- If `lastSegmentMemberCount` is 0, the DMOs have no data — you need to run data streams first (UI-only for SFDC connector)
- Publish with `FULL_REFRESH` replaces all rows; `INCREMENTAL` adds/updates only changes
- Multiple activations can reference the same segment — each creates its own DE
- **DE materialization lag**: After the activation shows SUCCESS, the Data Extension in MC can take **2-8+ hours** to appear. The folder is created immediately, but the DE itself is delayed by MC's async processing queue.
- **contactPointsConfig (Email) via API**: The SSOT API silently strips `contactPointsConfig` when creating activations — you pass it but the GET response shows `contactPoints: []`. To include email in the DE, **create the activation via Data Cloud UI instead**. UI-created activations DO get email (EmailAddress field + IsSendable=true).

### MC Data Extension Details (when it arrives):
- **CustomerKey format**: `{SegmentId}_{ActivationId}` (e.g., `1sgg70000006MQrAAM_85Rg70000002YK9EAM`)
- **Fields (UI-created with email)**: Id, SubscriberKey, EmailAddress
- **Fields (API-created without email)**: Id only (just the Individual ssot__Id__c)
- **IsSendable**: `true` (for UI-created activations with email)
- **Folder**: Created inside the activation's named folder under Data Cloud parent folder (716415)

---

## Example: Key IDs (reference org)

> ⚠️ **These are examples from a reference org.** Your org will have different values.
> Use the discovery commands in Steps 1-2 to find yours.

```
Org Alias:                    phil_master_sdo
DataConConfigurationId:       7M4g7000001G7EfCAK      (7M4 prefix — find via Step 1 verification)
DataSpaceId:                  0vhg70000002SZhAAM      (0vh prefix — query DataSpace sObject)
Activation Target Name:       pk_test_mc              (your choice from Step 2)
Activation Target ID:         85Ug70000023IAXEA2      (returned from Step 2 creation)
MC Connection (SSOT):         1WMg70000002O33GAE      (1WM prefix — query ssot connections)
MC Business Unit (MedVet):    523019897               (selected during Step 1 UI wizard)
MktDataConnection ID:         9cgg70000004NHNAA2      (⚠️ DO NOT use for DataConConfigurationId!)
Individual DMO:               ssot__Individual__dlm   (standard — same in all orgs)
Account DMO:                  ssot__Account__dlm      (standard — same in all orgs)
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
| `"Unrecognized field \"queryPath\""` | contactPointsConfig format doesn't match API creation schema | Use UI to create activations with email |
| `"Unrecognized field \"fieldConfig\""` | Same as above — read-only fields in GET response | Use UI for email-enabled activations |
| Activation SUCCESS but no DE in MC | Normal latency — MC processes asynchronously | Wait 2-8 hours; check folder was created as interim indicator |
| Email dimension shows "Not Available" in UI | ContactPointEmail relationship metadata not resolved | Data exists but activation UI can't display it — recreate activation via UI |
| contactPointsConfig silently returns empty | API strips email config during POST | Only UI-created activations include email in the DE |

---

## Discovering Segments in Any Org

Before activating, find what segments exist and whether they have members:

```bash
# List all segments (shows developerName, displayName, memberCount, segmentOnApiName)
sf api request rest "/services/data/v64.0/ssot/segments" -o <org> 2>/dev/null

# Check a specific segment's status and member count
sf api request rest "/services/data/v64.0/ssot/segments/<SEGMENT_DEVELOPER_NAME>" -o <org> 2>/dev/null
```

**Key fields to look for:**
- `segmentStatus` — must be `ACTIVE` to publish
- `lastSegmentMemberCount` — if 0, data streams haven't synced yet (run them from UI first)
- `segmentOnApiName` — tells you which DMO to use in the activation payload:
  - `ssot__Individual__dlm` → people segments
  - `ssot__Account__dlm` → account segments

```bash
# List existing activations (to see what's already wired up)
sf api request rest "/services/data/v64.0/ssot/activations" -o <org> 2>/dev/null
```

---

## What Cannot Be Automated (and why)

| Step | Why it needs UI |
|------|-----------------|
| MC Connection OAuth (Step 1) | Browser-based OAuth2 redirect flow between SF and MC. Creates internal trust chain that API cannot replicate. |
| SalesforceDotCom data stream sync | Platform limitation: `"Connector type SalesforceDotCom is not allowed to run in non-interactive mode"` |
| Adding Email to activation contactPointsConfig | API silently strips contactPointsConfig — only UI-created activations include EmailAddress field in the DE |

---

## Proven End-to-End Results (2026-06-30)

### What works:
1. **Create Segment → Create Activation → Publish → DE lands in MC** ✅
2. **Activation audience table populated** (4,252 rows for 213-member segment — includes duplicates from audience materialization)
3. **DE is IsSendable=true** when created via UI with email
4. **Real email data flows** (e.g., `paul.harris6@luminaillcge.com`)
5. **Full refresh cycle**: ~5-8 minutes from publish to activation SUCCESS on DC side
6. **MC lag**: DE appears 2-8+ hours after DC activation shows SUCCESS

### Timing expectations:
| Stage | Duration |
|-------|----------|
| Segment publish (SQL eval) | 3-5 minutes |
| Activation detects publish | 1-2 minutes |
| Activation PUBLISHING phase | 3-5 minutes |
| Activation shows SUCCESS | After PUBLISHING |
| MC folder created | Within minutes of SUCCESS |
| **MC DE materializes** | **2-8+ hours after SUCCESS** |

### What doesn't work via API:
- `contactPointsConfig` with email → silently stripped (use UI)
- `queryPath` field in contactPointsConfig → "Unrecognized field"
- `fieldConfig` in contactPointsConfig → "Unrecognized field"
- Only `"type": "EMAIL"` is accepted, but the email config is ignored
