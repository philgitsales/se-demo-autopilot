# Data Cloud → Marketing Cloud Connector — Lessons & Guide

> Hard-won knowledge from hands-on testing against an SDO (June 2026).
> Use this as your reference when connecting Data Cloud to Marketing Cloud Engagement.
> This enables segments built in Data Cloud to be activated (sent) to Marketing Cloud.

---

## Overview

The **Data Cloud MC Engagement Connector** enables Data Cloud segments to be pushed to Marketing Cloud as audiences for use in journeys, campaigns, and sends. This is different from the classic "Marketing Cloud Connect" (et4ae5 managed package) which syncs CRM data.

| Feature | Classic MC Connect (et4ae5) | Data Cloud MC Engagement |
|---------|---------------------------|--------------------------|
| Purpose | Sync CRM data to MC | Activate DC segments to MC |
| Auth Method | MC user login (username/password) | OAuth client credentials via wizard |
| Setup Location | Setup → Marketing Cloud | Setup → Data Cloud → Salesforce Integrations → Marketing → Marketing Cloud Engagement |
| Required For | Journey Builder CRM entries | Segment activation to MC audiences |

---

## Setup Location

**Setup → Data Cloud → Salesforce Integrations → Marketing → Marketing Cloud Engagement**

URL: `https://{instance}.my.salesforce-setup.com/lightning/setup/MultipleMcSetup/home`

---

## Connection Architecture

The MC Engagement connector uses several Salesforce objects working together:

```
┌────────────────────────────┐
│  Wizard UI                 │
│  (MultipleMcSetup)         │
│  - 4-step configuration    │
│  - Stores auth internally  │
└──────────────┬─────────────┘
               │
               ▼
┌────────────────────────────┐     ┌─────────────────────────┐
│  MktDataConnection         │     │  Named Credential        │
│  (SObject)                 │     │  (SfMcDataCloud)         │
│  - ConnectionState         │     │  - MC REST endpoint      │
│  - DataConnectorType       │     │  - Client credentials    │
│  - IsSentosEnabled         │     └─────────────────────────┘
└──────────────┬─────────────┘
               │
               ▼
┌────────────────────────────┐
│  ActivationTarget          │
│  (SObject)                 │
│  - Links to connection     │
│  - Defines MC target type  │
│  - Created via UI only     │
└────────────────────────────┘
```

---

## Step-by-Step Setup

### Step 1: Create the Connection via Wizard UI

1. Navigate to: Setup → Data Cloud → Salesforce Integrations → Marketing → Marketing Cloud Engagement
2. Click **"New"** to create a new connection
3. Give it a name (e.g., "SE Demo Autopilot MC")
4. Complete the 4-step wizard:
   - **Step 1**: Enter Credentials (click "Manage" → enter MC API client_id/secret)
   - **Step 2**: Data Source Setup (Optional — for ingesting MC data INTO Data Cloud)
   - **Step 3**: Allow Profile Business Unit Mapping Data (Optional)
   - **Step 4**: Select Business Units to Activate (Optional)

### Step 2: Verify Connection State

```bash
sf data query --query "SELECT Id, DeveloperName, MasterLabel, ConnectionState, DataConnectorType, IsSentosEnabled FROM MktDataConnection WHERE DataConnectorType = 'SalesforceMarketingCloud'" --target-org {alias}
```

Expected result: `ConnectionState = ACTIVE`, `IsSentosEnabled = True`

### Step 3: Create Activation Target (UI Only)

Navigate to Data Cloud app → Activation Targets → New → Select Marketing Cloud.

---

## Key SObjects

### MktDataConnection

The main connection record linking Data Cloud to an external system.

| Field | Type | Notes |
|-------|------|-------|
| Id | ID | Record ID (prefix: 9cg) |
| DeveloperName | String | API name |
| MasterLabel | String | Display name |
| ConnectionState | Picklist | `ACTIVE` / `INACTIVE` |
| DataConnectorType | Picklist | `SalesforceMarketingCloud` for MC |
| SyncStatus | Picklist | `NONE` / sync states |
| ConnectionMethod | Picklist | `Ingress` |
| IsSentosEnabled | Boolean | **Must be True** for segment activation |
| IsActivityEnabled | Boolean | For activity data ingestion |
| AccessType | Picklist | `Shared` / etc. |
| BaseConnectionId | Reference | Parent connection if applicable |
| ExternalRecordIdentifier | String | Read-only, system-generated UUID |

**Writable fields via API**: `ConnectionState`, `IsSentosEnabled`, `IsActivityEnabled`, `AccessType`, `MasterLabel`, `DeveloperName`

### MktDataConnectionCred

Stores credential parameters for connections.

| Field | Type | Notes |
|-------|------|-------|
| DeveloperName | String | e.g., `{ConnName}_accessKey` |
| MasterLabel | String | Same as DeveloperName |
| MktDataConnectionId | Reference | Parent connection |
| CredentialName | String | Credential type identifier |
| Value | Encrypted | Credential value |

**CRITICAL**: The `SalesforceMarketingCloud` connector type **rejects ALL MktDataConnectionCred records**. Every credential name tested returns: "X connection credential is not supported for SalesforceMarketingCloud connector type". MC credentials are stored via the wizard's internal mechanism (likely Named Credentials).

### MktDataConnectionParam

Stores non-credential parameters (like S3 bucket names for AWS connectors).

| Field | Type | Notes |
|-------|------|-------|
| DeveloperName | String | e.g., `{ConnName}_bucketName` |
| MktDataConnectionId | Reference | Parent connection |
| ParamName | String | Parameter identifier |
| Value | Textarea | Parameter value |

**CRITICAL**: Also rejects params for `SalesforceMarketingCloud` type. The MC connector does NOT use MktDataConnectionParam records.

### ActivationTarget

Defines where segments can be sent.

| Field | Type | Notes |
|-------|------|-------|
| MasterLabel | String | Display name |
| DataConConfigurationId | Reference | Link to MktDataConnection |
| ConnectionType | Picklist | `SalesforceMarketingCloud`, `AmazonS3`, etc. |
| TargetType | Picklist | `DE` (Data Extension), `MCMA` (MC Marketing Audience) |
| TargetStatus | Picklist | `ACTIVE`, `INACTIVE`, `PROCESSING`, `ERROR` |
| RunStatus | Picklist | `PUBLISHING`, `SUCCESS`, `ERROR` |
| OutputFormat | Picklist | `JSON`, `PARQUET`, `CSV` |
| DataSpaceId | Reference | Data space association |
| PlatformName | String | Platform identifier |

**Cannot be created via DML/SOQL** — returns `INSUFFICIENT_ACCESS`. Must be created through the Data Cloud UI.

---

## API Operations

### Activate Connection via API

```bash
# Set connection to ACTIVE
sf data update record --sobject MktDataConnection \
  --record-id {connectionId} \
  --values "ConnectionState=ACTIVE" \
  --target-org {alias}

# Enable segment activation (IsSentosEnabled = "Send To Segment")
sf data update record --sobject MktDataConnection \
  --record-id {connectionId} \
  --values "IsSentosEnabled=true" \
  --target-org {alias}
```

### Query Segments (Data Cloud API)

```bash
sf api request rest "/services/data/v67.0/ssot/segments" --target-org {alias}
```

Returns:
```json
{
  "batchSize": 20,
  "offset": 0,
  "segments": [...],
  "totalSize": 0
}
```

### Query Activation Targets (Data Cloud API)

```bash
sf api request rest "/services/data/v67.0/ssot/activation-targets" --target-org {alias}
```

### Create Activation Target (Data Cloud API — partial)

```bash
sf api request rest "/services/data/v67.0/ssot/activation-targets" \
  --method POST \
  --body '{"name":"Target Name","platformType":"SalesforceMarketingCloud","connector":{"name":"Connection Name"}}' \
  --target-org {alias}
```

**Known issue**: Returns `"Required Marketing Cloud Connector Details are not present"` even with valid connection name. The MC connector details are stored internally by the wizard and aren't exposed via the API. **Use the Data Cloud UI to create activation targets.**

### Query Data Spaces

```bash
sf api request rest "/services/data/v67.0/ssot/data-spaces" --target-org {alias}
```

---

## Supporting Metadata (Deployed via Metadata API)

These were deployed to support the connection but may not be strictly required if the wizard handles auth internally:

### AuthProvider (MC_Data_Cloud)

```xml
<AuthProvider xmlns="http://soap.sforce.com/2006/04/metadata">
    <friendlyName>Marketing Cloud Data Cloud</friendlyName>
    <providerType>OpenIdConnect</providerType>
    <consumerKey>{mc_client_id}</consumerKey>
    <consumerSecret>{mc_client_secret}</consumerSecret>
    <authorizeUrl>https://{subdomain}.auth.marketingcloudapis.com/v2/authorize</authorizeUrl>
    <tokenUrl>https://{subdomain}.auth.marketingcloudapis.com/v2/token</tokenUrl>
    <defaultScopes>email</defaultScopes>
    <sendAccessTokenInHeader>true</sendAccessTokenInHeader>
    <executionUser>{org_admin_email}</executionUser>
</AuthProvider>
```

### Named Credential (SfMcDataCloud)

```xml
<NamedCredential xmlns="http://soap.sforce.com/2006/04/metadata">
    <allowMergeFieldsInBody>true</allowMergeFieldsInBody>
    <allowMergeFieldsInHeader>true</allowMergeFieldsInHeader>
    <calloutStatus>Enabled</calloutStatus>
    <endpoint>https://{subdomain}.rest.marketingcloudapis.com</endpoint>
    <generateAuthorizationHeader>true</generateAuthorizationHeader>
    <label>Salesforce Marketing Cloud Data Cloud</label>
    <principalType>NamedUser</principalType>
    <protocol>Password</protocol>
    <username>{mc_client_id}</username>
    <password>{mc_client_secret}</password>
</NamedCredential>
```

### External Credential (SfMcDataCloud)

```xml
<ExternalCredential xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Salesforce Marketing Cloud Data Cloud</label>
    <authenticationProtocol>Oauth</authenticationProtocol>
    <externalCredentialParameters>
        <authProvider>MC_Data_Cloud</authProvider>
        <parameterName>MC_Data_Cloud</parameterName>
        <parameterType>AuthProvider</parameterType>
    </externalCredentialParameters>
    <externalCredentialParameters>
        <parameterName>MC_Named_Principal</parameterName>
        <parameterType>NamedPrincipal</parameterType>
        <sequenceNumber>1</sequenceNumber>
    </externalCredentialParameters>
</ExternalCredential>
```

---

## Common Errors & Gotchas

### 1. MktDataConnectionCred rejects ALL credential names for MC
**Error**: `"X connection credential is not supported for SalesforceMarketingCloud connector type"`
**Tested names that ALL fail**: namedCredential, clientId, accessKey, username, password, secret, key, credential, connection, subdomain, endpoint, baseUrl, instanceUrl, tssd, mid, accountId, authToken, oauthToken, accessToken, token, apiKey, externalCredential, namedCredentialId
**Solution**: Don't try to create credential records for MC connections. Use the wizard UI.

### 2. ActivationTarget creation via DML fails
**Error**: `"insufficient access rights on cross-reference id"`
**Cause**: ActivationTarget creation is restricted to the Data Cloud internal service
**Solution**: Create activation targets through the Data Cloud UI only

### 3. SSOT API activation-targets POST needs wizard-stored details
**Error**: `"Required Marketing Cloud Connector Details are not present"`
**Cause**: The wizard stores MC auth details in an internal format not accessible via API
**Solution**: Use the Data Cloud UI to create activation targets after wizard completion

### 4. ExternalRecordIdentifier is read-only
**Error**: `"Unable to create/update fields: ExternalRecordIdentifier"`
**Cause**: System-generated field, cannot be set manually
**Solution**: Let the system assign it

### 5. Named Credential with OAuth 2.0 Auth Provider shows "Pending"
**Cause**: OpenIdConnect Auth Provider requires interactive authorization flow
**Solution**: Either complete the OAuth authorization in the browser, or switch to Password protocol with client_id as username and client_secret as password

### 6. Data Cloud app not accessible via standard URLs
**Error**: "The app you're trying to view is invalid or inaccessible"
**Cause**: Data Cloud uses a special app context
**Solution**: Use the App Launcher → search "Data Cloud" to access it

### 7. Classic MC Connect (et4ae5) is NOT what you need for segments
**Symptom**: Navigating to et4ae5 config pages, seeing MC login (username/password) form
**Cause**: et4ae5 is the traditional CRM sync connector, not the Data Cloud connector
**Solution**: Use Setup → Data Cloud → Salesforce Integrations → Marketing → Marketing Cloud Engagement

---

## SDO-Specific IDs

| Resource | ID/Value |
|----------|----------|
| MC Connection (API-created) | `9cgg70000004NHNAA2` |
| MC Connection DeveloperName | `SE_Demo_MC_Connect` |
| Wizard Connection Name | `SE Demo Autopilot MC` |
| MC Account/MID | `523019897` |
| MC Account User | Phil Kopp |
| Named Credential ID | `0XAg7000000OUplGAG` |
| Named Credential Name | `SfMcDataCloud` |
| External Credential ID | `0ptg7000000GTm1AAG` |
| Auth Provider ID | `0SOg7000000ZqRxGAK` |
| Auth Provider DeveloperName | `MC_Data_Cloud` |
| Default Data Space ID | `0vhg70000002SZhAAM` |
| SDO Instance URL | `https://storm-e3b3a339aa547e.my.salesforce.com` |
| SDO Username | `storm.e3b3a339aa547e@salesforce.com` |
| SF CLI Alias | `phil_master_sdo` |

---

## What's Working (as of June 26, 2026)

- [x] MC Engagement wizard connection created and **Active**
- [x] MktDataConnection record is ACTIVE with IsSentosEnabled=True
- [x] Named Credential deployed with MC client credentials
- [x] External Credential + Auth Provider deployed
- [x] Wizard Step 1 "Enter Credentials" completed successfully
- [ ] Activation Target creation (requires Data Cloud UI)
- [ ] Segment creation (requires Data Cloud UI or data model setup)
- [ ] End-to-end segment → MC activation test

---

## Next Steps

1. **Open Data Cloud app** (App Launcher → "Data Cloud")
2. **Create an Activation Target** for Marketing Cloud (Activation Targets → New → Marketing Cloud)
3. **Create a test segment** (requires at least one data model object with individuals)
4. **Activate the segment** to the MC target
5. **Verify in MC** that the audience/DE appeared

---

## Useful SF CLI Commands

```bash
# Check MC connection status
sf data query --query "SELECT Id, MasterLabel, ConnectionState, IsSentosEnabled FROM MktDataConnection WHERE DataConnectorType = 'SalesforceMarketingCloud'" --target-org phil_master_sdo

# List all Data Cloud connections
sf data query --query "SELECT Id, MasterLabel, ConnectionState, DataConnectorType FROM MktDataConnection" --target-org phil_master_sdo

# Check activation targets
sf data query --query "SELECT Id, MasterLabel, ConnectionType, TargetType, TargetStatus FROM ActivationTarget" --target-org phil_master_sdo

# Query segments via SSOT API
sf api request rest "/services/data/v67.0/ssot/segments" --target-org phil_master_sdo

# Query data spaces
sf api request rest "/services/data/v67.0/ssot/data-spaces" --target-org phil_master_sdo

# Check audit trail for connection changes
sf data query --query "SELECT Action, Display, CreatedDate FROM SetupAuditTrail WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT 20" --target-org phil_master_sdo
```
