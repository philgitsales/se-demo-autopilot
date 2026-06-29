# SE Demo Autopilot — Skills Reference

> **Purpose**: Consolidated reference for all AI agents working on this project.
> Agents should read this file to understand available Data Cloud & Salesforce capabilities without requiring manual setup each session.
> **Source**: `forcedotcom/sf-skills` (installed to `skills/` directory)

---

## Quick Command Index

### Data Cloud CLI (`sf data360`)

The `sf data360` community plugin provides CLI access to the full Data Cloud lifecycle. Suppress warning noise with `2>/dev/null`.

```bash
# Plugin check
sf data360 man

# Org diagnostics (run FIRST before any mutation work)
node skills/data360-orchestrate/scripts/diagnose-org.mjs -o phil_master_sdo --json
node skills/data360-orchestrate/scripts/diagnose-org.mjs -o phil_master_sdo --phase segment --json
node skills/data360-orchestrate/scripts/diagnose-org.mjs -o phil_master_sdo --phase act --json
```

---

## Phase 1: Connect

**Skill**: `skills/data360-connect/SKILL.md`
**Scope**: Connections, connectors, source discovery, connector metadata

```bash
# List available connector types
sf data360 connection connector-list -o phil_master_sdo 2>/dev/null

# List connections by type (REQUIRED — no global list-all)
sf data360 connection list -o phil_master_sdo --connector-type SalesforceDotCom 2>/dev/null
sf data360 connection list -o phil_master_sdo --connector-type SNOWFLAKE 2>/dev/null

# Inspect specific connection
sf data360 connection get -o phil_master_sdo --name <connection> 2>/dev/null
sf data360 connection objects -o phil_master_sdo --name <connection> 2>/dev/null
sf data360 connection fields -o phil_master_sdo --name <connection> 2>/dev/null

# Test connection
sf data360 connection test -o phil_master_sdo --name <connection> --connector-type <type> 2>/dev/null

# Create from JSON
sf data360 connection create -o phil_master_sdo -f connection.json 2>/dev/null
```

**Gotchas**:
- `connection list` requires `--connector-type` — no global list
- Empty list = enabled but unconfigured, NOT disabled
- Some connectors can be created via API but stream creation still requires UI

---

## Phase 2: Prepare (Ingestion)

**Skill**: `skills/data360-prepare/SKILL.md`
**Scope**: Data streams, DLOs, transforms, Document AI

```bash
# List streams and DLOs
sf data360 data-stream list -o phil_master_sdo 2>/dev/null
sf data360 dlo list -o phil_master_sdo 2>/dev/null

# Get stream details
sf data360 data-stream get -o phil_master_sdo --name <stream> 2>/dev/null

# Run a stream (NOT for SFDC connector — that's UI-only)
sf data360 data-stream run -o phil_master_sdo --name <stream> 2>/dev/null

# Create stream from CRM object
sf data360 data-stream create-from-object -o phil_master_sdo --object Contact --connection SalesforceDotCom_Home 2>/dev/null

# Create from JSON definition
sf data360 data-stream create -o phil_master_sdo -f stream.json 2>/dev/null
```

**Stream categories**:
| Category | Use for | Requirement |
|---|---|---|
| `Profile` | Person/entity records | Primary key |
| `Engagement` | Time-based events | Primary key + event time |
| `Other` | Reference/config data | Primary key |

**Gotchas**:
- SFDC connector streams CANNOT be triggered programmatically (`"Connector type SalesforceDotCom is not allowed to run in non-interactive mode"`)
- DLO field naming differs from CRM (`__c` → `_c` transformations)
- Stream deletion can also delete the associated DLO

---

## Phase 3: Harmonize

**Skill**: `skills/data360-harmonize/SKILL.md`
**Scope**: DMOs, field mappings, relationships, identity resolution, data graphs

```bash
# List DMOs (use --all for full catalog)
sf data360 dmo list --all -o phil_master_sdo 2>/dev/null
sf data360 dmo list -o phil_master_sdo 2>/dev/null

# Describe DMO schema
sf data360 query describe -o phil_master_sdo --table ssot__Individual__dlm 2>/dev/null
sf data360 dmo get -o phil_master_sdo --name ssot__Individual__dlm --json 2>/dev/null

# Inspect mappings
sf data360 dmo mapping-list -o phil_master_sdo --source Contact_Home__dll --target ssot__Individual__dlm 2>/dev/null

# Identity resolution
sf data360 identity-resolution list -o phil_master_sdo 2>/dev/null
sf data360 identity-resolution create -o phil_master_sdo -f ir-ruleset.json 2>/dev/null
sf data360 identity-resolution run -o phil_master_sdo --name Main 2>/dev/null
```

**Gotchas**:
- There is NO `dmo describe` command — use `query describe` or `dmo get --json`
- IR runs are asynchronous — verify results after execution
- Unified DMO names are ruleset-specific
- If `dmo list` works but `identity-resolution list` is gated, it's a phase-specific gap

---

## Phase 4: Segment

**Skill**: `skills/data360-segment/SKILL.md`
**Scope**: Segments, calculated insights, publish, member counts

```bash
# List segments and CIs
sf data360 segment list -o phil_master_sdo 2>/dev/null
sf data360 calculated-insight list -o phil_master_sdo 2>/dev/null

# Create segment from JSON
sf data360 segment create -o phil_master_sdo -f segment.json --api-version 64.0 2>/dev/null

# Publish segment
sf data360 segment publish -o phil_master_sdo --name My_Segment 2>/dev/null

# Check member count
sf data360 segment count -o phil_master_sdo --name My_Segment 2>/dev/null

# Run calculated insight
sf data360 calculated-insight create -o phil_master_sdo -f ci.json 2>/dev/null
sf data360 calculated-insight run -o phil_master_sdo --name Lifetime_Value 2>/dev/null

# Verify with SQL
sf data360 query sql -o phil_master_sdo --sql 'SELECT COUNT(*) FROM "UnifiedssotIndividualMain__dlm"' 2>/dev/null
```

**Gotchas**:
- Segment creation may REQUIRE `--api-version 64.0`
- `segment members` returns opaque IDs — use SQL joins for readable details
- Publish/run steps are often asynchronous even when the command returns quickly
- Data Cloud segment SQL is NOT SOQL

---

## Phase 5: Act (Activate)

**Skill**: `skills/data360-activate/SKILL.md`
**Scope**: Activations, activation targets, data actions

```bash
# List available platforms
sf data360 activation platforms -o phil_master_sdo 2>/dev/null

# List targets and activations
sf data360 activation-target list -o phil_master_sdo 2>/dev/null
sf data360 activation list -o phil_master_sdo 2>/dev/null

# Create target from JSON
sf data360 activation-target create -o phil_master_sdo -f target.json 2>/dev/null

# Create activation from JSON
sf data360 activation create -o phil_master_sdo -f activation.json 2>/dev/null

# Verify activation data
sf data360 activation data -o phil_master_sdo --name <activation> 2>/dev/null

# Data actions
sf data360 data-action-target list -o phil_master_sdo 2>/dev/null
sf data360 data-action-target create -o phil_master_sdo -f target.json 2>/dev/null
sf data360 data-action create -o phil_master_sdo -f action.json 2>/dev/null
```

**Gotchas**:
- Verify upstream segment is published and healthy BEFORE creating activations
- Create the destination BEFORE the activation
- `CdpActivationTarget` or `CdpActivationExternalPlatform` = feature gated for org/user
- Read-only inspection first when destination setup is unclear
- **MC activation target MUST be created via UI** (Data Cloud Setup → Marketing → MC Engagement) — API-created targets are broken
- **Activation payload requires `activationTargetSubjectConfig`** with `developerName` pointing to the DMO (e.g., `ssot__Individual__dlm`)
- **`attributesConfig` is mandatory** — at minimum the primary key attribute
- See `data-cloud-setup/blockers-and-next-steps.md` for the complete proven MC activation payload

---

## Phase 6: Retrieve (Query)

**Skill**: `skills/data360-query/SKILL.md`
**Scope**: SQL queries, async queries, vector search, search indexes, metadata

```bash
# Quick count
sf data360 query sql -o phil_master_sdo --sql 'SELECT COUNT(*) FROM "ssot__Individual__dlm"' 2>/dev/null

# Paginated results
sf data360 query sqlv2 -o phil_master_sdo --sql 'SELECT * FROM "ssot__Individual__dlm"' 2>/dev/null

# Async for large results
sf data360 query async-create -o phil_master_sdo --sql 'SELECT * FROM "ssot__Individual__dlm"' 2>/dev/null

# Describe table schema
sf data360 query describe -o phil_master_sdo --table ssot__Individual__dlm 2>/dev/null

# Search indexes
sf data360 search-index list -o phil_master_sdo 2>/dev/null

# Vector/hybrid search
sf data360 query vector -o phil_master_sdo --index <index> --query "search text" --limit 5 2>/dev/null
sf data360 query hybrid -o phil_master_sdo --index <index> --query "search text" --limit 5 2>/dev/null
```

**Gotchas**:
- Data Cloud SQL is NOT SOQL — different syntax
- Table names should be double-quoted in SQL
- Use `sqlv2` for medium result sets, async for large
- `query describe` is NOT a universal tenant probe — only use with known table names

---

## JSON Templates (Ready to Use)

All templates are in `skills/data360-orchestrate/assets/definitions/`:

### Segment
```json
{
  "displayName": "High Value Customers",
  "developerName": "High_Value_Customers",
  "description": "Example segment built from a unified DMO",
  "segmentType": "Dbt",
  "includeDbt": {
    "models": {
      "models": [
        {
          "name": "UnifiedCustomers",
          "sql": "SELECT ui.ssot__Id__c FROM UnifiedssotIndividualMain__dlm ui JOIN ssot__SalesOrder__dlm so ON ui.ssot__Id__c = so.ssot__IndividualId__c GROUP BY ui.ssot__Id__c HAVING SUM(so.ssot__TotalAmount__c) > 1000"
        }
      ]
    }
  }
}
```

### Activation (MC — proven working)
```json
{
  "activationTargetName": "pk_test_mc",
  "dataSpaceName": "default",
  "name": "Segment_Name_MC",
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

### Activation Target
```json
{
  "developerName": "CRM_Target",
  "displayName": "CRM Target",
  "description": "Example activation target definition for a downstream destination"
}
```

### Data Stream
```json
{
  "name": "Customer_Stream",
  "label": "Customer Stream",
  "datasource": "SalesforceDotCom_Home",
  "datastreamType": "CONNECTORSFRAMEWORK",
  "connectorInfo": {
    "connectorType": "SalesforceDotCom",
    "connectorDetails": {
      "name": "SalesforceDotCom_Home",
      "sourceObject": "Custom_Object__c"
    }
  },
  "dataLakeObjectInfo": {
    "label": "Customer",
    "name": "Customer__dll",
    "category": "Profile",
    "dataspaceInfo": [{ "name": "Default" }],
    "dataLakeFieldInputRepresentations": [
      { "name": "Id", "label": "Record ID", "dataType": "Text", "isPrimaryKey": true },
      { "name": "External_Id_c", "label": "External ID", "dataType": "Text", "isPrimaryKey": false }
    ]
  },
  "sourceFields": [
    { "name": "Id", "dataType": "Text" },
    { "name": "External_Id__c", "dataType": "Text" }
  ],
  "mappings": [],
  "refreshConfig": {
    "isAccelerationEnabled": true,
    "refreshMode": "UPSERT",
    "frequency": { "frequencyType": "HOURLY" }
  }
}
```

### Identity Resolution Ruleset
```json
{
  "label": "Main",
  "description": "Generic identity resolution ruleset",
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

---

## Orchestrator (Cross-Phase)

**Skill**: `skills/data360-orchestrate/SKILL.md`
**Use when**: Multi-phase pipeline, cross-phase troubleshooting, data spaces, data kits

```bash
# Full org diagnosis
node skills/data360-orchestrate/scripts/diagnose-org.mjs -o phil_master_sdo --json

# Phase-specific diagnosis
node skills/data360-orchestrate/scripts/diagnose-org.mjs -o phil_master_sdo --phase connect --json
node skills/data360-orchestrate/scripts/diagnose-org.mjs -o phil_master_sdo --phase prepare --json
node skills/data360-orchestrate/scripts/diagnose-org.mjs -o phil_master_sdo --phase harmonize --json
node skills/data360-orchestrate/scripts/diagnose-org.mjs -o phil_master_sdo --phase segment --json
node skills/data360-orchestrate/scripts/diagnose-org.mjs -o phil_master_sdo --phase act --json
node skills/data360-orchestrate/scripts/diagnose-org.mjs -o phil_master_sdo --phase retrieve --json

# Data spaces
sf data360 data-space list -o phil_master_sdo 2>/dev/null

# Health check (advisory only — checks search-index endpoint only)
sf data360 doctor -o phil_master_sdo 2>/dev/null
```

**Pipeline flow**: Connect → Prepare → Harmonize → Segment → Act → Retrieve

---

## Plugin Installation (if not already installed)

```bash
# Option 1: Bootstrap script
bash skills/data360-orchestrate/scripts/bootstrap-plugin.sh

# Option 2: Manual
git clone https://github.com/Jaganpro/sf-cli-plugin-data360.git
cd sf-cli-plugin-data360
yarn install
npx tsc
sf plugins link .

# Verify
sf data360 man
```

---

## This Project's Org Details

```
Org Alias: phil_master_sdo
Data Space: default
```

See `data-cloud-setup/README.md` for full IDs, segment definitions, and activation target details.
See `CLAUDE.md` for Marketing Cloud API details and connection info.
See `docs/mc-journey-api-guide.md` and `docs/mc-email-and-content-guide.md` for MC API specifics.

---

## Skill File Locations (for deep reference)

| Skill | Path |
|-------|------|
| Orchestrate | `skills/data360-orchestrate/SKILL.md` |
| Connect | `skills/data360-connect/SKILL.md` |
| Prepare | `skills/data360-prepare/SKILL.md` |
| Harmonize | `skills/data360-harmonize/SKILL.md` |
| Segment | `skills/data360-segment/SKILL.md` |
| Activate | `skills/data360-activate/SKILL.md` |
| Query | `skills/data360-query/SKILL.md` |
| Schema Get | `skills/data360-schema-get/SKILL.md` |
| Code Extension | `skills/data360-code-extension-generate/SKILL.md` |
| Agentforce D360 | `skills/agentforce-d360-analyze/SKILL.md` |
| Agentforce Gen | `skills/agentforce-generate/SKILL.md` |
| Flow Automation | `skills/automation-flow-generate/SKILL.md` |
| Templates Dir | `skills/data360-orchestrate/assets/definitions/` |
| Diagnostics | `skills/data360-orchestrate/scripts/diagnose-org.mjs` |
| Feature Guide | `skills/data360-orchestrate/references/feature-readiness.md` |
| Plugin Setup | `skills/data360-orchestrate/references/plugin-setup.md` |
