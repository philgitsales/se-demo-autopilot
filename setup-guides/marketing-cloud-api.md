# Setup Guide: Marketing Cloud REST API Access

> **What this does**: Enables programmatic creation of Journeys, Emails, Data Extensions, Automations, and Content in Marketing Cloud.

---

## Overview

```
Agent → MC REST API → Content Builder (emails, blocks, images)
                    → Journey Builder (journeys, activities)
                    → Data Extensions (DEs, rows)
                    → Automations
                    → Transactional Sends
```

Fully programmatic. No manual steps required (credentials are pre-configured).

---

## Prerequisites

- Marketing Cloud Business Unit with API access enabled
- Installed Package with Server-to-Server integration (Client Credentials flow)
- API scopes granted (this org has 99 — full access)
- Credentials stored in `config/.env`

---

## Step 1: Get Credentials (one-time)

In Marketing Cloud:
1. **Setup → Apps → Installed Packages**
2. Create or use existing package with "Server-to-Server" component
3. Note the `Client ID` and `Client Secret`
4. Note the subdomain from the package detail page

Store in `config/.env`:
```
MC_CLIENT_ID=<client_id>
MC_CLIENT_SECRET=<client_secret>
MC_SUBDOMAIN=<subdomain>
```

---

## Step 2: Authenticate (programmatic — token valid ~20 min)

```bash
TOKEN=$(curl -s -X POST "https://<SUBDOMAIN>.auth.marketingcloudapis.com/v2/token" \
  -H "Content-Type: application/json" \
  -d '{
    "grant_type": "client_credentials",
    "client_id": "'"$(grep MC_CLIENT_ID config/.env | cut -d= -f2)"'",
    "client_secret": "'"$(grep MC_CLIENT_SECRET config/.env | cut -d= -f2)"'"
  }' | python3 -c "import json,sys; print(json.load(sys.stdin)['access_token'])")
```

### Verify:
```bash
curl -s "https://<SUBDOMAIN>.rest.marketingcloudapis.com/platform/v1/endpoints" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Step 3: Use the APIs (programmatic — repeatable)

### API Endpoints
```
Auth:  https://<SUBDOMAIN>.auth.marketingcloudapis.com/v2/token
REST:  https://<SUBDOMAIN>.rest.marketingcloudapis.com/
SOAP:  https://<SUBDOMAIN>.soap.marketingcloudapis.com/Service.asmx
```

### What you can create:

| Asset | API | Guide |
|-------|-----|-------|
| Journeys | REST `/interaction/v1/interactions` | `docs/mc-journey-api-guide.md` |
| Emails | REST `/asset/v1/content/assets` | `docs/mc-email-and-content-guide.md` |
| Content Blocks | REST `/asset/v1/content/assets` | Same as above |
| Data Extensions | SOAP `DataExtension` object | Same as above |
| DE Rows | REST `/data/v1/async/dataextensions/...` | Same as above |
| Automations | REST `/automation/v1/automations` | Same as above |
| Transactional Sends | REST `/messaging/v1/email/definitions` | Same as above |
| Image Uploads | REST `/asset/v1/content/assets` | Same as above |

---

## Example: Key IDs (reference org)

> ⚠️ **These are examples from a reference org.** Your org will have different values.
> Use the "Discovering Key IDs" section above to find yours.

```
MC Subdomain:                 mcmn8m8yvnsgn6fnl3jft2xmc6s4
All Subscribers List:         466907
Root Content Builder Folder:  466941
Claude Demo Assets Folder:    716404
Tracking DE GUID:             6B0A9921-BA6D-4BCB-8FB9-03A9EDBC8816
```

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| Silent error 30000 on journey creation | Name/description contains `& < > " ' /` | Remove special characters |
| Error 30000 on journey activities | Activity has a `description` field set | OMIT description from activities, goals, exits |
| Email not sendable | Created as type 208 (htmlemail) | Must be type 207 (templatebasedemail) with `data.email` block |
| Send definition fails | Wrong list format or missing DE GUID | Use `"All Subscribers - <LIST_ID>"` format and include `dataExtension` GUID (see "Discovering Key IDs" below) |
| Folder creation fails | Using parentId 0 | Use the root Content Builder folder ID (see "Discovering Key IDs" below) |
| Event fire type mismatch | Numbers sent as strings | Match exact DE field types (numbers as numbers) |

---

## Discovering Key IDs (per org)

Every MC org has its own IDs. Run these to find yours:

```bash
# Get All Subscribers list ID
# (SOAP Retrieve on List object, filter by ListName = "All Subscribers")
# The ID appears in the response as <ID>XXXXXX</ID>

# Get root Content Builder folder ID
curl -s "https://<SUBDOMAIN>.rest.marketingcloudapis.com/asset/v1/content/categories?$filter=parentId%20eq%200" \
  -H "Authorization: Bearer $TOKEN"
# Look for the folder with name "Content Builder" — its ID is your root folder

# Get a Data Extension's GUID (needed for send definitions)
# Use SOAP Retrieve on DataExtension, filter by Name
```

### Example values (from a reference org — YOUR org will differ):
```
All Subscribers List ID:      466907    (format in send defs: "All Subscribers - 466907")
Root Content Builder Folder:  466941    (use as parentId when creating folders/assets)
Custom Assets Folder:         716404    (created by agent, use for demo content)
Tracking DE GUID:             6B0A9921-BA6D-4BCB-8FB9-03A9EDBC8816
```

---

## What Cannot Be Automated

Nothing! The MC REST API is fully self-service once credentials exist.
The only "manual" step is the initial Installed Package creation in MC Setup, but that's a one-time admin task typically done during SDO provisioning.
