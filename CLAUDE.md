# SE Demo Autopilot — Agent Instructions

> **Status**: Active Development (Phase 1 — API Capability Validation COMPLETE)
> **Last Updated**: 2026-06-27

---

## Key Discoveries (READ FIRST)

These are hard-won findings. Do NOT re-discover them by trial and error.

### Data Cloud → Marketing Cloud Activation (fully working)

**Only 1 manual step per org**: Establish the MC Connection via UI (Data Cloud Setup → Marketing → Marketing Cloud Engagement). This creates an OAuth trust chain and a hidden `DataConConfigurationId` (7M4 prefix). Everything else is programmatic.

**Create Activation Target** (sObject API — NOT the SSOT API):
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

**Create Activation** (SSOT API):
```bash
sf api request rest "/services/data/v64.0/ssot/activations" -o phil_master_sdo --method POST --body '{
  "activationTargetName": "pk_test_mc",
  "dataSpaceName": "default",
  "name": "Segment_Name_MC",
  "segmentApiName": "Segment_Developer_Name",
  "refreshType": "FULL_REFRESH",
  "activationTargetSubjectConfig": {"developerName": "ssot__Individual__dlm"},
  "attributesConfig": {"attributes": [{"dataSourceType": "Text", "entityName": "ssot__Individual__dlm", "label": "Individual Id", "name": "ssot__Id__c", "referenceAttributeName": "Id", "source": "DIRECT", "type": "MODEL"}]}
}'
```

**Critical IDs (phil_master_sdo org):**
| ID | Value | What it is |
|----|-------|------------|
| DataConConfigurationId | `7M4g7000001G7EfCAK` | Internal MC config record (created by UI connection setup) |
| DataSpaceId | `0vhg70000002SZhAAM` | "default" data space |
| Activation Target | `pk_test_mc` (85Ug70000023IAXEA2) | Active MC target |
| MC Connection | `1WMg70000002O33GAE` | SSOT connection ID |
| MC Business Unit | `523019897` (MedVet) | Target BU |

**Things that DON'T work** (don't waste time retrying):
- SSOT API for target creation (`/ssot/activation-targets` POST) → "Required Marketing Cloud Connector Details are not present"
- sObject API with MktDataConnection ID (9cg prefix) as DataConConfigurationId → target creates but activations fail
- Any attempt to trigger SalesforceDotCom data stream sync via API → hard platform limitation

**Full details**: `data-cloud-setup/blockers-and-next-steps.md`

---

## What We're Building

**SE Demo Autopilot** is an AI-powered tool where a Salesforce Solutions Engineer (SE) describes a customer use case in plain language, and the system automatically generates everything needed for a live demo in a pre-provisioned Marketing Cloud SDO:

- Journeys (multi-step, with splits, goals, exits)
- Campaigns & Emails (polished, brand-themed, in Content Builder)
- Data Extensions with realistic sample data
- Automations
- Click paths / demo scripts
- Presentation slides

The SE says something like: *"The customer is a healthcare company that wants to onboard new patients with a 4-touch email series, split by insurance type"* — and the system builds the entire demo environment automatically.

---

## Why This Matters

SEs spend 2-4 hours manually building demos in Marketing Cloud for each prospect meeting. This tool reduces that to minutes. It uses pre-provisioned SDO orgs (Salesforce Demo Orgs) that already have the base configuration, and layers demo-specific content on top via API.

---

## What's Been Accomplished

### Phase 1: API Capability Validation ✅ COMPLETE

Every Marketing Cloud API capability needed for demo generation has been tested and documented:

| Capability | Status | Guide |
|-----------|--------|-------|
| Journey Builder (CRUD + Publish) | ✅ | `docs/mc-journey-api-guide.md` |
| Content Builder Emails | ✅ | `docs/mc-email-and-content-guide.md` |
| Content Blocks (reusable) | ✅ | Same as above |
| Image Upload | ✅ | Same as above |
| Data Extensions (CRUD + rows) | ✅ | Same as above |
| Transactional Sends | ✅ | Same as above |
| Event-Driven Journey Entry | ✅ | Same as above |
| Automations | ✅ | Same as above |
| Subscribers/Tracking | ✅ | Same as above |

### What Was Created in the SDO

- 4 demo journeys (various industries/complexity levels)
- 5 Content Builder emails (sendable + display)
- 3 content blocks (header, footer, CTA)
- 2 data extensions with sample data
- 2 automations
- 1 active transactional send definition
- 1 custom folder ("Claude Demo Assets")
- Image upload tested

---

## Technical Architecture

### Connection Details

Credentials are in `config/.env` (gitignored, NEVER commit):
- MC subdomain: `mcmn8m8yvnsgn6fnl3jft2xmc6s4`
- OAuth 2.0 Client Credentials flow
- Token valid ~20 minutes
- 99 API scopes (full access)

### API Endpoints
```
Auth:  https://{subdomain}.auth.marketingcloudapis.com/v2/token
REST:  https://{subdomain}.rest.marketingcloudapis.com/
SOAP:  https://{subdomain}.soap.marketingcloudapis.com/Service.asmx
```

### Critical Technical Learnings (Read These First!)

1. **Journey names/descriptions**: Cannot contain `& < > " ' /` — causes silent error 30000
2. **Activity descriptions**: OMIT entirely from journey activities, goals, exits — causes error 30000
3. **Sendable emails MUST be type 207** (`templatebasedemail`), NOT type 208 (`htmlemail`). Type 208 appears in Content Builder but fails send validation.
4. **Sendable emails need `data.email` block**: With `characterEncoding: "utf-8"` and the `attributes` array
5. **Send definitions need exact list format**: `"All Subscribers - 466907"` (not just "All Subscribers")
6. **Send definitions need DE GUID**: `"dataExtension": "6B0A9921-BA6D-4BCB-8FB9-03A9EDBC8816"`
7. **Folders**: Use parentId `466941` (not 0) for root Content Builder
8. **Event fire data types**: Must exactly match DE field types (numbers as numbers, not strings)
9. **Journey updates (PUT)**: Fragile — prefer delete + recreate for drafts
10. **Data Extensions**: Create via SOAP, insert/read rows via REST

### SDO Key IDs
```
All Subscribers List (for send defs): 466907
Root Content Builder Folder: 466941
Claude Demo Assets Folder: 716404
Tracking DE GUID: 6B0A9921-BA6D-4BCB-8FB9-03A9EDBC8816
```

---

## Project Structure

```
se-demo-autopilot/
├── CLAUDE.md              ← You are here (agent instructions)
├── SKILLS.md              ← Data Cloud & SF skills reference (READ THIS for sf data360 work)
├── README.md              ← Project overview
├── .gitignore             ← Excludes .env, secrets, keys
├── config/
│   └── .env               ← MC credentials (NEVER commit)
├── setup-guides/          ← STEP-BY-STEP PLATFORM SETUP (READ THESE for new orgs)
│   ├── README.md          ← Index of all configured platforms
│   ├── data-cloud-to-marketing-cloud.md ← DC→MC activation (3 steps)
│   └── marketing-cloud-api.md          ← MC REST API auth + usage
├── docs/
│   ├── architecture.md    ← System architecture overview
│   ├── mc-journey-api-guide.md     ← Journey Builder API (comprehensive)
│   └── mc-email-and-content-guide.md ← Everything else (emails, DEs, sends, events)
├── data-cloud-setup/
│   ├── README.md          ← Data Cloud status & findings
│   ├── segments-created.json       ← 6 active segment definitions with IDs
│   ├── activation-target-created.json ← S3 Bridge target details
│   └── blockers-and-next-steps.md  ← Detailed debugging history & advanced reference
├── skills/                ← Salesforce agent skills (from forcedotcom/sf-skills)
│   ├── data360-orchestrate/       ← Cross-phase orchestrator + diagnostic scripts + templates
│   ├── data360-connect/           ← Connections & connectors
│   ├── data360-prepare/           ← Data streams & DLOs
│   ├── data360-harmonize/         ← DMOs, mappings, identity resolution
│   ├── data360-segment/           ← Segments & calculated insights
│   ├── data360-activate/          ← Activations & activation targets
│   ├── data360-query/             ← SQL, search indexes, vector search
│   ├── data360-schema-get/        ← Schema introspection
│   ├── data360-code-extension-generate/ ← Code extensions
│   ├── agentforce-d360-analyze/   ← Agentforce Data Cloud analysis
│   ├── agentforce-generate/       ← Agentforce generation
│   └── automation-flow-generate/  ← Flow automation
├── previews/
│   ├── welcome-email.html           ← Local HTML preview
│   └── product-education-email.html ← Local HTML preview
├── data-templates/        ← (future) Sample data templates by industry
└── scripts/               ← (future) Automation scripts
```

---

## What's Next (Phase 2+)

### Immediate Next Steps
1. **Connect Salesforce CRM SDO** — Fill in `SF_*` credentials in `.env`, test Sales Cloud API access
2. **Build first end-to-end skill** — Take a use case description → generate journey + emails + data automatically
3. **Industry templates** — Pre-built configurations for common verticals (FinServ, Healthcare, Retail, Tech)
4. **Click path generation** — Automated demo scripts showing what to click in the UI

### Future Vision
- Natural language → complete demo environment in < 2 minutes
- Multiple SDO support (different customers get different orgs)
- Slide generation from the created demo content
- Demo reset/cleanup automation
- Integration with SE calendar (auto-prep before meetings)

---

## How to Authenticate (Quick Start)

```bash
# Get a token (valid ~20 min)
TOKEN=$(curl -s -X POST "https://mcmn8m8yvnsgn6fnl3jft2xmc6s4.auth.marketingcloudapis.com/v2/token" \
  -H "Content-Type: application/json" \
  -d '{
    "grant_type": "client_credentials",
    "client_id": "'"$(grep MC_CLIENT_ID config/.env | cut -d= -f2)"'",
    "client_secret": "'"$(grep MC_CLIENT_SECRET config/.env | cut -d= -f2)"'"
  }' | python3 -c "import json,sys; print(json.load(sys.stdin)['access_token'])")

# Test it
curl -s "https://mcmn8m8yvnsgn6fnl3jft2xmc6s4.rest.marketingcloudapis.com/platform/v1/endpoints" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Rules for Agents Working on This Project

### THE MOST IMPORTANT RULE:

**UPDATE `setup-guides/` WITH EVERY DISCOVERY.** This project is a living system. When you fix something, discover a pitfall, find a workaround, or prove a new API pattern — update the relevant setup guide IMMEDIATELY. The goal is that someone else can take this repo, follow the guides, and get everything working without hitting the same walls we did. If a guide doesn't exist for what you're working on, CREATE ONE following the format in `setup-guides/README.md`. These guides are the product — the code is secondary.

---

### ⚡ CRITICAL: Salesforce Documentation Retrieval

**DO NOT use WebFetch or curl on Salesforce Help/Developer docs — they return empty shells.**

Use the `platform-docs-get` skill instead:
```bash
# For help.salesforce.com (ALWAYS use --stealth)
python3 skills/platform-docs-get/scripts/extract_help_salesforce.py --url "<URL>" --stealth --pretty

# For developer.salesforce.com or other SF doc sites
python3 skills/platform-docs-get/scripts/extract_salesforce_doc.py --url "<URL>" --stealth --pretty
```

**⚠️ Article IDs are NOT guessable and change over time.** Do NOT try random IDs.
Navigate from known-good pages instead. **READ `setup-guides/salesforce-docs-retrieval.md`** — it has:
- Known-good entry point URLs to start from
- The navigation workflow to find any article
- Article ID prefix patterns (`data.c360_a_*`, `sf.mc_*`, `mktg.*`)
- A complete verified index of DC → MCE activation docs
- Troubleshooting for common failures

---

1. **NEVER commit or expose credentials** — They're in `config/.env` which is gitignored
2. **Read `setup-guides/` first** before starting work on any platform — they contain proven workflows and pitfalls
3. **Read `SKILLS.md`** for Data Cloud CLI commands, templates, and phase-by-phase reference — it has everything you need for `sf data360` operations
4. **Read `AGENTS.md`** for the full inventory of all 87 installed Salesforce skills and how to use them
5. **Test against the SDO freely** — it's a demo org, nothing is production
6. **Journey names**: No `& < > " ' /` characters
7. **Emails for sending**: Always type 207 with full `data.email` block
8. **When something fails**: Check the setup guides' troubleshooting tables first
9. **When you discover something new**: Update the relevant setup guide (or create one). Add it to the troubleshooting table, the pitfalls section, or the key IDs. Do NOT leave knowledge only in chat history.
10. **Keep demo content professional** — Use realistic brand names (NTO, Cumulus Financial, etc.)
11. **For Data Cloud work**: Use `sf data360` CLI commands documented in `SKILLS.md`. Run the org diagnostic first: `node skills/data360-orchestrate/scripts/diagnose-org.mjs -o phil_master_sdo --json`
12. **Skill deep-dives**: Individual skill SKILL.md files in `skills/` have detailed workflows, gotchas, and output formats
13. **For Salesforce documentation**: Use `platform-docs-get` skill — normal web fetch fails on SF docs. See rule above.
14. **COMMIT AND PUSH at the end of every session** — Do not leave work as local-only untracked files. Commit meaningful progress and push to origin/main before the session ends.
