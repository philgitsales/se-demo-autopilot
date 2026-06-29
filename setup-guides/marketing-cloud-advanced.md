# Setup Guide: Marketing Cloud Advanced (MC Next / Unified Marketing App)

> **What this does**: Enables native CRM-embedded marketing capabilities — email campaigns,
> journeys, forms, promotions, communication capping, and AI-powered marketing — all within
> the Salesforce core platform (no separate MC login required). Powered by Data Cloud segments.

---

## Overview

```
Data Cloud Segments → MCA Campaigns → Emails / Journeys / Forms / Promotions
                                            ↓
                              Native CRM UI (no MC login needed)
```

Marketing Cloud Advanced (MCA) runs entirely inside Salesforce Core. Unlike traditional MC
(which uses a separate domain + REST API), MCA uses standard Salesforce objects, permission
sets, and the Lightning UI. It's the "next gen" marketing platform built on Data Cloud.

**Source of Truth**: Internal Slack Canvas — "Spring '26 Marketing Cloud Advanced Setup Guide" (F07QUSDQ79T)

---

## Current Org Status (phil_master_sdo)

| Component | Status | Details |
|-----------|--------|---------|
| Data Cloud provisioned | ✅ DONE | 2,126 Individuals, 902 Accounts |
| CRM Connector | ✅ DONE | `SalesforceDotCom_Home` active with synced data |
| ContactPointEmail data | ✅ DONE | 2,126 records (required for IR) |
| Data Cloud perm sets | ✅ ASSIGNED | GenieAdmin, CDPAdmin, Data Cloud User |
| Marketing perm sets | ⚠️ PARTIAL | Has legacy MC perms, but NOT `MarketingCloudAdmin` |
| MCA Licenses | ✅ GRANTED | 22 licenses added 2026-06-29 |
| Agentforce | ✅ RUNNING | 8 agents including Default |
| Marketing App | ✅ EXISTS | `standard__Marketing` |
| MessagingTemplates | ✅ 10 EXIST | Pre-loaded SDO templates |
| **Data Kits** | ❌ NOT INSTALLED | No DataKitDeploymentLog records |
| **Identity Resolution** | ❌ NOT CONFIGURED | No rulesets, no Unified Individual |
| **Data Graph** | ❌ NOT CREATED | No DataGraph records |
| **Consent/Subscriptions** | ❌ NOT CONFIGURED | 0 CommSubscription, 0 DataUsePurpose |
| **Scoring Rules** | ❌ NOT PUBLISHED | No unified profiles to score |
| **Einstein Segment Creation** | ❓ UNKNOWN | Cannot verify via API |
| **Send Time Optimization** | ❓ UNKNOWN | Cannot verify via API |

---

## Setup Steps (in order)

### Step 1: Request MCA Licenses (Slack Workflow — manual) ✅ COMPLETE

**Status**: Done on 2026-06-29. Fulfilled by Ashutosh Pattnaik.

**Why manual**: Standard SDOs do NOT come with Marketing Cloud Advanced licenses.
You must request them via a Slack workflow. The agent can draft the message, but the
human must submit it through the workflow form (bot-submitted requests aren't accepted).

### Where to request:

- **Slack Channel**: `#q-branch-xdo-license-extension-requests`
- **Channel ID**: `C0477BVNSB1`
- **Method**: Click the workflow button ("Extensions-Licenses-BT Requests") in the channel

### What to include in the request:

```
Org ID: <YOUR_ORG_ID>
Username: <YOUR_SDO_USERNAME>

License Requested: Marketing Cloud Advanced (MC Next)

Reason: Setting up a Data Cloud + Marketing Cloud Advanced demo environment
to showcase native CRM-embedded marketing capabilities (email, campaigns,
journeys powered by Data Cloud segments).

If the Distributed Marketing and Alerts license is also available to add,
that would be greatly appreciated as well.
```

### Turnaround time:
- Typical: 1-3 business days
- Our experience: Submitted Thursday evening (June 26), fulfilled Sunday morning (June 29)

### Pitfalls:
- **Must use the workflow button** — you can't just type a message in the channel
- **Agent cannot submit** — the workflow form requires interactive browser input
- **Agent CAN draft the message** — copy/paste the text into the workflow form
- After completion, add a check reaction to the original post to mark it as done

### Licenses granted to our org:

| Category | License Keys |
|----------|-------------|
| Core MCA | `UnifiedMarketingAppStandalone`, `UnifiedMarketingAppStandaloneAdvanced`, `UnifiedMarketingAppStandaloneUser`, `MCE_Setup_on_Core`, `MCEngagementJourneysOnCoreAddOn` |
| Channels | `E360EmailAddOn`, `E360PushAddOn`, `E360SMSAddOn`, `E360MobileAppMessagingAddOn`, `E360MAMAddOn` |
| AI/Copilot | `ContentBuilderCopilotAddOn`, `MarketingCloudCopilotAddOn`, `MarketingGenerativePlanningAddOn`, `EinsteinGPTGroundingStructuredDataAddOn`, `TableauEinsteinIncludedAppMultiUserAddOn` |
| Platform | `GenieDataPlatformServicesCard`, `GenieDataStorage`, `MCETAgentActions`, `UMAFormsRecaptchaAddOn` |
| Distributed Marketing | `DistributedMarketingAndAlerts`, `DistributedMarketingConnect` |

---

### Step 2: Assign Marketing Cloud Admin Permission Set (API — programmatic)

**Status**: NOT DONE — this is the first thing to do.

**Why it matters**: MCA UI features won't appear without this. The internal guide lists this as Step 1.

**Skill**: `dx-org-permission-set-assign`

```bash
# Assign MarketingCloudAdmin
sf org assign permset --name MarketingCloudAdmin -o phil_master_sdo --json

# Assign MarketingCloudManager
sf org assign permset --name MarketingCloudManager -o phil_master_sdo --json
```

### Verify:
```bash
sf data query -q "SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE Assignee.Username = 'storm.e3b3a339aa547e@salesforce.com' AND PermissionSet.Label LIKE '%Marketing Cloud%'" -o phil_master_sdo --json 2>/dev/null
```

### Pitfalls:
- Without `MarketingCloudAdmin`, the Basic Settings page may show incomplete or blocked sections
- The existing `SDO_Marketing_Cloud_All_Permissions` is a legacy connector perm set — it's NOT the same as MCA admin

---

### Step 3: Confirm Marketing Cloud Basic Settings (UI — manual)

**Status**: NOT VERIFIED — needs human to check.

**Why manual**: This is a validation page. All sections should show green checkboxes. If not, something upstream is missing.

### What to do:
1. Log into Salesforce
2. Setup → Search "Basic Settings" (or "Marketing Cloud")
3. Click **"Basic Settings"** under Marketing Cloud (NOT under Data Cloud)
4. Confirm all sections have green checkboxes

### Important:
- Use TOP-LEVEL Setup navigation, NOT Data Cloud sub-nav
- If sections are NOT green, the Data Kits step (next) will fail

---

### Step 4: Install Data Kits & Deploy Data Streams (UI — manual, ONE CLICK)

**Status**: NOT DONE — this is the critical manual step.

**Why manual**: The Data Kit installation is a one-click operation on the Basic Settings page. No public API exists to trigger it. The internal guide confirms this is UI-only.

### What to do:
1. Setup → Marketing Cloud → Basic Settings (scroll down)
2. Find the "Install the Marketing Data Kits" section
3. Click **"Update"** button
4. A modal pops — Click **"Update"** again
5. Wait ~20 minutes for deployment to complete
6. Status changes: "Not Deployed" → "In Progress" → "Deployed"

### What this installs (automatically):
- Marketing Setup Objects Data Kit
- Consent Objects Data Kit
- Flows Integration Data Kit
- Email Channel Data Kit
- (Optional: SMS, WhatsApp, Sales Data Kits)

### What this deploys (automatically):
- Marketing-specific data streams into Data Cloud
- Consent-related DMO structures
- Flow integration objects

### How to verify:
```bash
# Check for new data streams
sf data360 data-stream list -o phil_master_sdo 2>/dev/null | grep -i "marketing\|consent\|messaging\|channel\|flow"

# Check DataKitDeploymentLog
sf data query -q "SELECT Id, CreatedDate FROM DataKitDeploymentLog ORDER BY CreatedDate DESC LIMIT 5" -o phil_master_sdo --json 2>/dev/null

# Check installed packages
sf api request rest "/services/data/v64.0/tooling/query?q=SELECT+Id,SubscriberPackageName+FROM+InstalledSubscriberPackage+ORDER+BY+SubscriberPackageName" -o phil_master_sdo 2>/dev/null
```

### Pitfalls:
- If Flow Data Kit errors occur, it does NOT block the demo — click "Retry" (runs only failed kits)
- The "Update" button may say "Install" if this is the first time
- If the button is greyed out or shows "complete prerequisites", check that Step 2 (perm set) and Step 3 (green checkmarks) are done
- Timeout messages during CRM connector install are safe to ignore

---

### Step 5: Create Identity Resolution Rulesets (API — programmatic)

**Status**: NOT DONE

**Why programmatic**: The `sf data360 identity-resolution create` CLI command + our template can handle this. The internal guide does it via UI, but we have a working programmatic path.

**Skill**: `data360-harmonize`

**Prerequisite**: Step 4 complete (Data Kits deployed, consent streams flowing)

### Create Individual Ruleset:
```bash
sf data360 identity-resolution create -o phil_master_sdo -f ir-individual-ruleset.json 2>/dev/null
```

### Individual ruleset definition (Fuzzy Name + Normalized Email):
```json
{
  "label": "MCAI",
  "description": "MCA Individual identity resolution - fuzzy name and normalized email",
  "configurationType": "individual",
  "rulesetId": "MCAI",
  "doesRunAutomatically": false,
  "matchRules": [
    {
      "label": "Fuzzy Name and Normalized Email",
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
      "ruleType": "sourcepriority",
      "shouldIgnoreEmptyValue": true,
      "sources": [],
      "fields": []
    }
  ]
}
```

### Run the ruleset:
```bash
sf data360 identity-resolution run -o phil_master_sdo --name MCAI 2>/dev/null
```

### Verify Unified Individual exists:
```bash
sf data360 query sql -o phil_master_sdo --sql 'SELECT COUNT(*) FROM "UnifiedssotIndividualMCAI__dlm"' 2>/dev/null
```

### Pitfalls:
- IR runs are asynchronous — may take minutes to complete
- The unified table name includes the ruleset ID: `UnifiedssotIndividual<RULESET_ID>__dlm`
- Requires ContactPointEmail data to exist (we have 2,126 records — good)
- If the exact "Fuzzy Name + Normalized Email" match method isn't available via CLI, create with exact email match first, enhance later via UI

---

### Step 6: Create Data Graph (API — programmatic)

**Status**: NOT DONE

**Why programmatic**: `sf data360 data-graph create` CLI exists. However, the full MCA Data Graph needs specific field selections. May need UI enhancement after initial creation.

**Skill**: `data360-harmonize`

**Prerequisite**: Step 5 complete (Unified Individual exists)

### Create Data Graph:
```bash
sf data360 data-graph create -o phil_master_sdo -f data-graph-marketing.json 2>/dev/null
```

### Data Graph definition:
```json
{
  "developerName": "Marketing_Content_Personalization",
  "displayName": "Marketing Content Personalization",
  "description": "Data Graph for MCA merge fields and dynamic content",
  "sourceObject": {
    "name": "UnifiedssotIndividualMCAI__dlm",
    "type": "derived",
    "fields": [
      {"name": "ssot__Id__c"},
      {"name": "ssot__FirstName__c"},
      {"name": "ssot__LastName__c"},
      {"name": "ssot__Salutation__c"},
      {"name": "ssot__BirthDate__c"}
    ],
    "relatedObjects": []
  }
}
```

### Verify:
```bash
sf data360 data-graph get -o phil_master_sdo --name Marketing_Content_Personalization 2>/dev/null
```

### Then enable in Basic Settings (UI):
1. Setup → Reporting and Optimization → Customer Engagement
2. Check "Configure Basic Personalization"
3. Select the Data Graph from dropdown

### Pitfalls:
- Data Graph requires Unified Individual to exist (Step 5 must complete first)
- The graph refresh is ~30 minutes by default (configurable to daily/weekly)
- Full MCA personalization needs the graph linked in Basic Settings (UI step after creation)
- If CLI creation fails, fall back to UI: Setup → Data Graphs → New → Start From Scratch

---

### Step 7: Publish Scoring Rules (UI — manual)

**Status**: NOT DONE

**Why manual**: No known API for publishing scoring rules. Quick UI toggle.

### What to do:
1. Setup → Marketing Cloud → Reporting and Optimization → Customer Engagement
2. Click "Scoring Setup"
3. Select both:
   - Unified Individual Profile
   - Unified Account Profile
4. Click "Publish"

### Prerequisite: Unified profiles must exist (Step 5 done)

---

### Step 8: Install Marketing Performance (UI — manual)

**Status**: NOT DONE

**Why manual**: One-click install button, no API equivalent.

### What to do:
1. Setup → Marketing Cloud → Marketing Features → Marketing Performance
2. Verify prerequisites are completed
3. Click "Install"
4. Wait 3-5 minutes
5. Once installed → Click "Go to Permission Set" → assign to users

### What it creates:
- "Marketing Performance" tab in the Marketing app
- "Performance" tab within campaigns and content
- OOTB reporting dashboards

---

### Step 9: Enable Einstein Features (UI — manual)

**Status**: PARTIALLY DONE (Agentforce exists, but MCA-specific features need enabling)

### 9a: Enable Einstein Generative AI
1. Setup → Einstein Setup
2. Toggle ON: Einstein, Global Language Support, Deploy Prompt Templates
3. Refresh page

### 9b: Create Campaign Creation Agent
1. Setup → Agentforce Agents
2. Click "+ New Agent"
3. "Create from a Template" → Select "Campaign Creation"
4. Verify "Marketing Campaigns" topic added
5. Click "Activate"

**Alternative (programmatic)**: Use `agentforce-generate` skill to create the agent via Agent Script CLI.

### 9c: Enable Einstein Segment Creation
1. Setup → Feature Manager
2. Find "Einstein Segment Creation" → Click "Enable"

### 9d: Enable Send Time Optimization
1. Setup → Search "Send Time"
2. Click "Einstein Send Time Optimization"
3. Click "Enable" (remains "In Progress" for 72 hours)

---

### Step 10: Create Consent Framework (API — programmatic)

**Status**: NOT DONE (0 CommSubscriptions, 0 DataUsePurpose)

**Why programmatic**: All consent objects are fully createable via sObject API.

### Create Communication Subscriptions:
```bash
# Newsletter subscription
sf api request rest "/services/data/v64.0/sobjects/CommSubscription" -o phil_master_sdo --method POST --body '{
  "Name": "Newsletter"
}'

# Product Updates subscription
sf api request rest "/services/data/v64.0/sobjects/CommSubscription" -o phil_master_sdo --method POST --body '{
  "Name": "Product Updates"
}'

# Promotions subscription
sf api request rest "/services/data/v64.0/sobjects/CommSubscription" -o phil_master_sdo --method POST --body '{
  "Name": "Promotions and Offers"
}'
```

### Create Data Use Purposes:
```bash
sf api request rest "/services/data/v64.0/sobjects/DataUsePurpose" -o phil_master_sdo --method POST --body '{
  "Name": "Email Marketing",
  "Description": "Permission to send marketing emails",
  "CanDataSubjectOptOut": true,
  "IsActive": true
}'
```

### Create Communication Subscription Channels:
```bash
# Email channel for Newsletter
sf api request rest "/services/data/v64.0/sobjects/CommSubscriptionChannel" -o phil_master_sdo --method POST --body '{
  "Name": "Newsletter - Email",
  "CommunicationType": "Email",
  "CommSubscriptionId": "<SUBSCRIPTION_ID>"
}'
```

### Verify:
```bash
sf data query -q "SELECT Id, Name FROM CommSubscription" -o phil_master_sdo --json 2>/dev/null
sf data query -q "SELECT Id, Name, IsActive FROM DataUsePurpose" -o phil_master_sdo --json 2>/dev/null
```

---

### Step 11: Create Marketing Flows (API — programmatic)

**Status**: NOT DONE

**Why programmatic**: The `automation-flow-generate` skill has a full 3-step MCP pipeline for generating Flow metadata XML.

**Skill**: `automation-flow-generate`

### What flows to create:
- **Segment-Triggered Flow**: When contacts enter a segment, send email campaign
- **Event-Triggered Flow**: Distributed Marketing message sends
- **Scheduled Flow**: Weekly newsletter send

### Process:
1. Use `automation-flow-generate` skill's 3-step pipeline (fetchGroundedObjectMetadata → flowElementSelection → flowElementGeneration)
2. Deploy generated flow XML via `sf project deploy start`
3. Activate flow

---

### Step 12: Create Agentforce Marketing Campaign Agent (API — programmatic)

**Status**: NOT DONE (no Marketing/Campaign agents exist)

**Why programmatic**: The `agentforce-generate` skill supports full Agent Script lifecycle.

**Skill**: `agentforce-generate`

### Process:
1. Design Agent Spec (Campaign Creation agent with marketing topics)
2. Generate authoring bundle via CLI
3. Write Agent Script
4. Validate and deploy
5. Publish

**Alternative**: If the Campaign Creation template is available (Step 9b), just activate it via UI.

---

## Key IDs (phil_master_sdo org)

```
Org ID:                       00Dg7000006SuqDEAS
Org Alias:                    phil_master_sdo
Username:                     storm.e3b3a339aa547e@salesforce.com
DataSpaceId:                  0vhg70000002SZhAAM

Permission Sets (MCA):
  MarketingCloudAdmin:        0PSg7000003mSxiGAE
  MarketingCloudManager:      0PSg7000003mSxjGAE
  MCETAgentActionsPermSet:    0PSg7000003mT8SGAU

Slack:
  License Request Channel:    #q-branch-xdo-license-extension-requests (C0477BVNSB1)
  License Request Thread TS:  1782523917.412899
  License Granted Date:       2026-06-29

Internal References:
  MCA Setup Guide Canvas:     F07QUSDQ79T
  Help Channel:               #help-sell-mc-next (C06HPPANTRQ)
  CSG Help:                   #help-csg-marketingcloud-next (C06HPDKP6Q7)
```

---

## Available Skills for MCA Setup

| Skill | What it does for MCA |
|-------|---------------------|
| `dx-org-permission-set-assign` | Assign MarketingCloudAdmin/Manager perm sets |
| `data360-harmonize` | Create Identity Resolution rulesets + Data Graphs |
| `automation-flow-generate` | Generate marketing Flow metadata (segment/event/scheduled triggers) |
| `agentforce-generate` | Create Campaign Creation agent via Agent Script |
| `platform-metadata-deploy` | Deploy Flow XML, perm sets, custom metadata |
| `platform-permission-set-generate` | Create new custom permission sets if needed |
| `platform-data-manage` | Insert consent records (CommSubscription, DataUsePurpose) |

---

## Execution Summary

### Manual UI Steps (human does, ~30 min clicking + ~45 min waiting):
1. ~~Request licenses~~ ✅ DONE
2. Confirm Basic Settings page shows green checkmarks (Step 3)
3. Click "Install Marketing Data Kits" → Update (Step 4) — **THE BIG ONE**
4. Publish Scoring Rules (Step 7)
5. Install Marketing Performance (Step 8)
6. Enable Einstein features — Segment Creation, Send Time Optimization (Step 9c, 9d)
7. Link Data Graph in Basic Settings personalization dropdown (after Step 6)

### Programmatic Steps (agent does via CLI/API):
1. Assign MarketingCloudAdmin + MarketingCloudManager perm sets (Step 2)
2. Create Identity Resolution ruleset + run (Step 5)
3. Create Data Graph (Step 6)
4. Create Consent Framework — subscriptions, purposes, channels (Step 10)
5. Create Marketing Flows (Step 11)
6. Create/activate Campaign Agent (Step 12)
7. Verify everything end-to-end

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| MCA objects not found (`NOT_FOUND`) | Licenses not provisioned | Submit license request (Step 1) |
| Permission denied on MCA objects | PSL active but no permission set assigned | Assign MarketingCloudAdmin (Step 2) |
| Basic Settings shows incomplete sections | Missing perm set or Data Cloud not fully provisioned | Check Step 2 + Step 3 |
| Data Kits "Update" button greyed out | Prerequisites not met on Basic Settings | Complete all prior green checkmarks first |
| Data Kit deployment errors on Flow kit | Known intermittent issue | Click "Retry" — it only reruns failed kits |
| Identity Resolution returns empty | ContactPointEmail has no data | Verify `ssot__ContactPointEmail__dlm` has records |
| Data Graph creation fails | No Unified Individual exists | Complete IR (Step 5) first |
| Marketing Performance install greyed out | Data Kits not yet deployed | Wait for Step 4 to complete |
| Einstein Send Time "In Progress" forever | Normal — takes 72 hours to fully activate | Just wait |
| "This data has masking applied" on Data Graph | Known bug with DataKit-deployed graphs | Workaround: clone the graph in UI |

---

## What Cannot Be Automated (and why)

| Step | Why it needs UI | Workaround |
|------|-----------------|------------|
| Install Data Kits (Step 4) | No public API; one-click button on Basic Settings page | None — must click |
| Publish Scoring Rules (Step 7) | No API for scoring rule publish | None — must click |
| Install Marketing Performance (Step 8) | Package install button, no API | None — must click |
| Einstein Feature Manager toggles (Step 9) | Setup toggles with no API exposure | None — must click |
| Link Data Graph in Basic Settings (Step 6 final) | Dropdown selection on setup page | None — must click |

---

## Quick Reference: What To Do Next

```
NEXT SESSION CHECKLIST:
━━━━━━━━━━━━━━━━━━━━━━

AGENT DOES FIRST (programmatic, no waiting):
  □ Assign MarketingCloudAdmin perm set
  □ Assign MarketingCloudManager perm set

HUMAN DOES (UI, with waits):
  □ Check Basic Settings page → all green?
  □ Click "Install Marketing Data Kits" → Update → wait 20 min
  □ Publish Scoring Rules
  □ Install Marketing Performance
  □ Enable Einstein Segment Creation
  □ Enable Send Time Optimization

AGENT DOES AFTER DATA KITS COMPLETE (programmatic):
  □ Create Identity Resolution ruleset (MCAI)
  □ Run Identity Resolution
  □ Verify Unified Individual created
  □ Create Data Graph (Marketing Content Personalization)
  □ Create Consent Framework (subscriptions + purposes)
  □ Create Marketing Flows
  □ Create Campaign Agent

HUMAN DOES LAST (quick UI finish):
  □ Link Data Graph in Basic Settings → Personalization dropdown
  □ Verify Marketing app shows all features
```
