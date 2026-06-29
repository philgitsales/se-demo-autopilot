# Setup Guide: Identity Resolution in Data Cloud

> **What this does**: Unifies source profiles (Individual + Contact Points) into a single identity graph. Creates unified DMOs that link all records belonging to the same person/account.
> **Status**: FULLY WORKING in phil_master_sdo (2,126 unified profiles)

---

## TL;DR for Agents

**If the org has Individual + ContactPointEmail data mapped**, you need ONE command:

```bash
# Create the IDR ruleset (one-time per org)
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
}' 2>/dev/null
```

The system will:
1. Create the ruleset
2. Auto-run identity resolution
3. Create unified DMOs (UnifiedIndividual__dlm, UnifiedContactPointEmail__dlm, etc.)
4. Create identity link DMOs (IndividualIdentityLink__dlm, etc.)

**To verify:**
```bash
# Check IDR status
sf api request rest "/services/data/v66.0/ssot/identity-resolutions" -o <org> 2>/dev/null

# Query unified profiles
sf api request rest "/services/data/v64.0/ssot/query" -o <org> --method POST --body '{"sql": "SELECT COUNT(*) FROM UnifiedIndividual__dlm"}' 2>/dev/null

# Query identity links
sf api request rest "/services/data/v64.0/ssot/query" -o <org> --method POST --body '{"sql": "SELECT * FROM IndividualIdentityLink__dlm LIMIT 5"}' 2>/dev/null
```

---

## Prerequisites

Before creating an IDR ruleset, these MUST exist:

1. **Individual DMO** (`ssot__Individual__dlm`) — mapped and populated with records
2. **At least one Contact Point DMO** — mapped with `PartyId` relationship to Individual:
   - `ssot__ContactPointEmail__dlm` (most common)
   - `ssot__ContactPointPhone__dlm` (optional, for phone matching)
   - `ssot__ContactPointAddress__dlm` (optional, for address matching)
3. **Data flowing** — DMOs must have actual records (run data streams first)

### How to check prerequisites:
```bash
# Individual has records?
sf api request rest "/services/data/v64.0/ssot/query" -o <org> --method POST --body '{"sql": "SELECT COUNT(*) as cnt FROM ssot__Individual__dlm"}' 2>/dev/null

# ContactPointEmail has records with PartyId?
sf api request rest "/services/data/v64.0/ssot/query" -o <org> --method POST --body '{"sql": "SELECT ssot__PartyId__c, ssot__EmailAddress__c FROM ssot__ContactPointEmail__dlm LIMIT 3"}' 2>/dev/null
```

---

## Step 1: Create Identity Resolution Ruleset

### API: POST `/services/data/v66.0/ssot/identity-resolutions`

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
    },
    {
      "label": "Exact Phone",
      "criteria": [{
        "entityName": "ssot__ContactPointPhone__dlm",
        "fieldName": "ssot__FormattedE164PhoneNumber__c",
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
}' 2>/dev/null
```

### Field Reference:

| Field | Required | Description |
|-------|----------|-------------|
| `label` | Yes | Display name (e.g., "Main") |
| `description` | No | Description text |
| `configurationType` | Yes (POST only) | `"individual"` for person matching, `"account"` for company matching |
| `doesRunAutomatically` | No | `true` = runs after data ingestion; `false` = manual only |
| `matchRules` | Yes | Array of match rule objects |
| `reconciliationRules` | Yes | Array of reconciliation rule objects |

### Match Rule Criteria:

| Field | Description | Values |
|-------|-------------|--------|
| `entityName` | Contact Point DMO to match on | `ssot__ContactPointEmail__dlm`, `ssot__ContactPointPhone__dlm` |
| `fieldName` | Field within that DMO | `ssot__EmailAddress__c`, `ssot__FormattedE164PhoneNumber__c` |
| `matchMethodType` | How to compare values | `exact`, `exactnormalized`, `fuzzy`, `normalized` |
| `caseSensitiveMatch` | Case matters? | `true`/`false` |
| `shouldMatchOnBlank` | Match when field is empty? | `true`/`false` (always use `false`) |

### Match Method Types:

| Type | What it does | Best for |
|------|-------------|----------|
| `exact` | Exact character-for-character match | IDs, codes |
| `exactnormalized` | Exact after normalization (lowercase, trim whitespace) | Email, phone |
| `fuzzy` | Tolerates typos/variations (Levenshtein-like) | Names with misspellings |
| `normalized` | Applies transformation rules before matching | Names, addresses |

### Reconciliation Rule Types:

| Type | What it does |
|------|-------------|
| `lastupdated` | Most recently modified record wins |
| `mostenriched` | Record with most non-null fields wins |
| `source` | Specific source always wins (use `sources` array) |
| `field` | Per-field rules (use `fields` array) |

---

## Step 2: Update Ruleset (Add/Change Match Rules)

### API: PATCH `/services/data/v66.0/ssot/identity-resolutions/<ID>`

```bash
sf api request rest "/services/data/v66.0/ssot/identity-resolutions/<RULESET_ID>" -o <org> --method PATCH --body '{
  "label": "Main",
  "description": "Updated description",
  "doesRunAutomatically": true,
  "matchRules": [
    {
      "label": "Exact Email",
      "criteria": [...]
    },
    {
      "label": "New Rule",
      "criteria": [...]
    }
  ],
  "reconciliationRules": [...]
}' 2>/dev/null
```

**Critical: Do NOT include `configurationType` in PATCH — it throws `Unrecognized field` error.**

---

## Step 3: Run Identity Resolution Manually

```bash
sf data360 identity-resolution run -o <org> --name Main
# Output: "Identity resolution job started."
```

The job is asynchronous. Check status:
```bash
sf api request rest "/services/data/v66.0/ssot/identity-resolutions/<ID>" -o <org> 2>/dev/null
# Look for: lastJobStatus = "SUCCESS" or "IN_PROGRESS"
```

---

## Step 4: Verify Results

### Check unified profile count:
```bash
sf api request rest "/services/data/v64.0/ssot/query" -o <org> --method POST --body '{"sql": "SELECT COUNT(*) FROM UnifiedIndividual__dlm"}' 2>/dev/null
```

### Check identity links (source → unified mapping):
```bash
sf api request rest "/services/data/v64.0/ssot/query" -o <org> --method POST --body '{"sql": "SELECT SourceRecordId__c, UnifiedRecordId__c, ssot__DataSourceId__c FROM IndividualIdentityLink__dlm LIMIT 5"}' 2>/dev/null
```

### Check consolidated records (same UnifiedRecordId = same person):
```bash
sf api request rest "/services/data/v64.0/ssot/query" -o <org> --method POST --body '{"sql": "SELECT UnifiedRecordId__c, COUNT(*) as source_count FROM IndividualIdentityLink__dlm GROUP BY UnifiedRecordId__c HAVING COUNT(*) > 1 LIMIT 10"}' 2>/dev/null
```

If `source_count > 1` for any UnifiedRecordId, that means IDR successfully merged multiple source records.

---

## Understanding the Output

### Unified DMOs (auto-created by IDR):

| DMO | Purpose |
|-----|---------|
| `UnifiedIndividual__dlm` | Unified person profiles (one per unique person) |
| `UnifiedContactPointEmail__dlm` | Unified email addresses |
| `UnifiedContactPointPhone__dlm` | Unified phone numbers |
| `UnifiedContactPointAddress__dlm` | Unified addresses |

### Identity Link DMOs (source → unified mapping):

| DMO | Purpose |
|-----|---------|
| `IndividualIdentityLink__dlm` | Maps source Individual records → UnifiedRecordId |
| `ContactPointEmailIdentityLink__dlm` | Maps source emails → unified email |
| `ContactPointPhoneIdentityLink__dlm` | Maps source phones → unified phone |
| `ContactPointAddressIdentityLink__dlm` | Maps source addresses → unified address |

### Key Fields in Identity Links:
- `SourceRecordId__c` — Original CRM record ID (e.g., Contact ID)
- `UnifiedRecordId__c` — Synthetic unified profile ID (hash)
- `ssot__DataSourceId__c` — Which source (e.g., "Salesforce_Home")
- `ssot__DataSourceObjectId__c` — Source object type (e.g., "Contact")

---

## Common Scenarios

### Single Source (our case)
- All records come from one CRM → consolidation rate = 0%
- Every source record gets its own unique UnifiedRecordId
- IDR still creates the unified graph (useful for activation with contact points)

### Multi-Source (typical real-world)
- Records from CRM + Marketing + Web → consolidation rate > 0%
- Same person across sources shares one UnifiedRecordId
- Email/phone matches link records together

### Adding a Second Source (to demonstrate consolidation):
```bash
# Ingest API data with overlapping emails → IDR will match and consolidate
# The consolidation rate will increase from 0%
```

---

## Quick Reference Commands

```bash
# List all IDR rulesets
sf api request rest "/services/data/v66.0/ssot/identity-resolutions" -o <org> 2>/dev/null

# Get specific ruleset by ID
sf api request rest "/services/data/v66.0/ssot/identity-resolutions/<ID>" -o <org> 2>/dev/null

# Run IDR
sf data360 identity-resolution run -o <org> --name Main

# Delete IDR ruleset
sf api request rest "/services/data/v66.0/ssot/identity-resolutions/<ID>" -o <org> --method DELETE 2>/dev/null

# List via CLI
sf data360 identity-resolution list -o <org> 2>/dev/null
```

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Ruleset ID '${suffix}' is already in use` | CLI bug with `sf data360 identity-resolution create` | Use REST API directly instead of CLI |
| `Identity Resolution not found: Main` | GET by name doesn't work | Use GET by ID (the `1irg...` ID from the list response) |
| `Unrecognized field "configurationType"` | Including `configurationType` in PATCH | Remove it — only valid for POST (create) |
| `METHOD_NOT_ALLOWED` on PUT | Tried PUT instead of PATCH | Use PATCH for updates |
| `0 unified profiles` after run | No data in Individual or Contact Point DMOs | Run data streams first (UI for SFDC connector) |
| `0% consolidation rate` | All records from single source | Expected — add second source to see consolidation |

---

## Key IDs (phil_master_sdo)

```
IDR Ruleset ID:        1irg70000000Wg0AAE
IDR Ruleset Name:      Main
IDR Status:            PUBLISHED
Match Rules:           2 (Exact Email, Exact Phone)
Source Profiles:       2,126
Unified Profiles:      2,126
```
