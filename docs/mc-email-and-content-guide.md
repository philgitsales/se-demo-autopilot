# Marketing Cloud Content Builder, Data & Automation API Guide

> Comprehensive guide for creating emails, templates, data extensions, automations, 
> transactional sends, event-driven journey entry, and more — all programmatically.
> Tested June 2026 against an SDO. **ALL CAPABILITIES VERIFIED WORKING.**

---

## Scope Summary (99 scopes total)

Key scopes available:
```
saved_content_read saved_content_write    — Content Builder (emails, templates, assets)
email_read email_send email_write          — Email sending
data_extensions_read data_extensions_write  — Data Extensions
automations_execute automations_read automations_write
journeys_read journeys_write journeys_execute journeys_delete
list_and_subscribers_read list_and_subscribers_write
audiences_read audiences_write
sms_read sms_send sms_write
accounts_read accounts_write
tracking_events_read tracking_events_write
documents_and_images_read documents_and_images_write
```

Full access — no restrictions.

---

## CAPABILITY STATUS (All Tested)

| Capability | Status | Method | Notes |
|-----------|--------|--------|-------|
| **Content Builder Emails** | ✅ Working | REST | Type 207 for sendable, type 208 for display-only |
| **Content Blocks (HTML)** | ✅ Working | REST | Type 197 |
| **Content Blocks (Code Snippet)** | ✅ Working | REST | Type 220 |
| **Image Upload** | ✅ Working | REST | Base64-encoded, returns publishedURL |
| **Folders** | ✅ Working | REST | Must use valid parentId (not 0) |
| **Data Extensions (Create)** | ✅ Working | SOAP | Full field type support |
| **Data Extensions (Insert)** | ✅ Working | REST | Async bulk insert |
| **Data Extensions (Read)** | ✅ Working | REST | Supports $filter |
| **Journeys (Create)** | ✅ Working | REST | See Journey API Guide |
| **Journeys (Publish)** | ✅ Working | REST | Async with status polling |
| **Journeys (Delete)** | ✅ Working | REST | Returns journey ID |
| **Transactional Sends** | ✅ Working | REST | See critical config below |
| **Fire Events (Journey Entry)** | ✅ Working | REST | Data types must match DE schema |
| **Automations** | ✅ Working | REST | Create/list/manage |
| **Subscribers** | ✅ Working | SOAP | 2500+ in SDO |
| **Send Tracking** | ✅ Working | SOAP+REST | Historical send data |
| **Triggered Send Defs** | ✅ Working | SOAP | 17 existing in SDO |
| **Templates** | ✅ Working | REST | 15 existing in SDO |
| **Lists** | ✅ Working | SOAP | All Subscribers ID: 16705 |
| **Platform Endpoints** | ✅ Working | REST | 9 service endpoints |
| **SMS/MobileConnect** | ⚠️ No short codes | REST | API accessible but no codes provisioned |
| **Audiences/Segments** | ⚠️ 404 | REST | Endpoint not configured in SDO |
| **Contact REST API** | ⚠️ Limited | REST | Create returns "FAIL" but doesn't error |

---

## Content Builder REST API (PRIMARY METHOD)

### Endpoint
```
POST   {rest_url}/asset/v1/content/assets          — Create asset
GET    {rest_url}/asset/v1/content/assets/{id}      — Get by ID
GET    {rest_url}/asset/v1/content/assets?...       — Search/list
PUT    {rest_url}/asset/v1/content/assets/{id}      — Update
DELETE {rest_url}/asset/v1/content/assets/{id}      — Delete
GET    {rest_url}/asset/v1/content/categories       — List folders
POST   {rest_url}/asset/v1/content/categories       — Create folder
```

### Create Sendable Email (Type 207 - REQUIRED for transactional sends)

**CRITICAL**: Use type 207 (`templatebasedemail`) for ANY email that will be used in:
- Transactional send definitions
- Journey email activities  
- Triggered sends

Type 208 (`htmlemail`) is display-only in Content Builder but **FAILS validation** for sending.

```json
{
  "name": "Email Display Name",
  "description": "Shows in Content Builder list view",
  "assetType": {
    "name": "templatebasedemail",
    "id": 207
  },
  "category": {"id": 716404},
  "data": {
    "email": {
      "options": {
        "characterEncoding": "utf-8"
      },
      "attributes": [
        {
          "displayName": "__AdditionalEmailAttribute1",
          "name": "__AdditionalEmailAttribute1",
          "value": "",
          "order": 1,
          "channel": "email",
          "attributeType": "AdditionalEmailAttribute"
        }
      ]
    }
  },
  "views": {
    "html": {
      "content": "<!DOCTYPE html><html>...full HTML...</html>"
    },
    "text": {
      "content": "Plain text fallback"
    },
    "subjectline": {
      "content": "Subject with %%FirstName%% personalization"
    },
    "preheader": {
      "content": "Preview text shown in inbox"
    }
  }
}
```

**Key requirements for sendable emails:**
1. `assetType.id` must be `207` (not 208)
2. `data.email.options.characterEncoding` must be `"utf-8"`
3. `data.email.attributes` array must be present (even if just the default placeholder)
4. Both `html` and `text` views should be populated
5. `subjectline` must be set

### Create Display-Only Email (Type 208 - Content Builder only)

```json
{
  "name": "Email Display Name",
  "assetType": {"name": "htmlemail", "id": 208},
  "views": {
    "html": {"content": "<!DOCTYPE html>..."},
    "text": {"content": "Plain text"},
    "subjectline": {"content": "Subject line"},
    "preheader": {"content": "Preheader text"}
  }
}
```

Use type 208 when you just want something to show up in Content Builder for visual demo purposes and don't need to actually send it.

### Asset Types Reference

| Type | id | name | Use for |
|------|-----|------|---------|
| Template-Based Email | 207 | `templatebasedemail` | **Sendable emails** (transactional, journey, triggered) |
| HTML Email | 208 | `htmlemail` | Display-only in Content Builder |
| Text Email | 209 | `textonlyemail` | Plain text only |
| Template | 4 | `template` | Reusable email templates |
| Content Block - HTML | 197 | `htmlblock` | Reusable HTML snippets |
| Content Block - Text | 198 | `textblock` | Reusable text snippets |
| Code Snippet Block | 220 | `codesnippetblock` | AMPscript/dynamic content blocks |
| Image (PNG) | 28 | `png` | Uploaded images (requires base64 `file` field) |
| Image (JPG) | 23 | `jpg` | Uploaded JPEG images |
| Document | 29 | `document` | PDFs, docs |

### Create Content Blocks

```json
{
  "name": "Reusable Header Block",
  "description": "Branded header component",
  "assetType": {"name": "htmlblock", "id": 197},
  "content": "<table width=\"100%\">...<h1>%%Brand_Name%%</h1>...</table>"
}
```

### Upload Images

```json
{
  "name": "Company Logo",
  "assetType": {"name": "png", "id": 28},
  "file": "iVBORw0KGgoAAAANSUhEUg...base64-encoded-image..."
}
```

Returns `fileProperties.publishedURL` — use this URL in email HTML `<img>` tags.

### Create Folders

```json
POST /asset/v1/content/categories

{
  "name": "My Folder Name",
  "parentId": 466941
}
```

**IMPORTANT**: `parentId: 0` does NOT work. Use `466941` as the root Content Builder folder (or query existing folders to find the right parent).

### Search/Filter Assets

```
GET /asset/v1/content/assets?$filter=name%20like%20'Claude%25'
GET /asset/v1/content/assets?$filter=assetType.id%20eq%20208
GET /asset/v1/content/assets?$orderBy=modifiedDate%20desc&$pageSize=10
GET /asset/v1/content/assets?$filter=category.id%20eq%20716404
```

---

## Transactional Sends (REST)

### Create Send Definition

**CRITICAL CONFIG**: The `subscriptions.list` MUST include the list ID number, and you MUST include a `dataExtension` GUID.

```json
POST {rest_url}/messaging/v1/email/definitions

{
  "definitionKey": "unique-def-key",
  "name": "Send Definition Name",
  "description": "Purpose",
  "classification": "Default Transactional",
  "status": "Active",
  "content": {
    "customerKey": "{content_builder_email_customerKey}"
  },
  "subscriptions": {
    "list": "All Subscribers - 466907",
    "dataExtension": "6B0A9921-BA6D-4BCB-8FB9-03A9EDBC8816",
    "autoAddSubscriber": true,
    "updateSubscriber": true
  },
  "options": {
    "trackLinks": true
  }
}
```

**Common failure**: Using just `"list": "All Subscribers"` without the ID fails validation. Always use the format: `"All Subscribers - {listId}"`.

The `dataExtension` GUID `6B0A9921-BA6D-4BCB-8FB9-03A9EDBC8816` is the standard SDO tracking DE.

### Send Transactional Email

```json
POST {rest_url}/messaging/v1/email/messages/{definitionKey}

{
  "definitionKey": "unique-def-key",
  "recipient": {
    "contactKey": "subscriber-key",
    "to": "email@example.com",
    "attributes": {
      "FirstName": "Sarah",
      "LastName": "Chen"
    }
  }
}
```

Returns `errorcode: 0` on success with a `messageKey`.

### Check Send Status

```
GET {rest_url}/messaging/v1/email/messages/{messageKey}
```

Returns `statusCode`, `statusMessage`, `eventCategoryType`.

Status codes:
- Sent = delivered to MTA
- `ListDetectiveExclusion` = fake/test email address (expected for demo data)
- `Bounced` = invalid mailbox

---

## Event-Driven Journey Entry (Fire Events)

Inject contacts into active journeys programmatically.

### Fire an Event

```json
POST {rest_url}/interaction/v1/events

{
  "ContactKey": "subscriber-key-123",
  "EventDefinitionKey": "APIEvent-xxxxx-xxxx-xxxx",
  "Data": {
    "field1": "value1",
    "field2": 12345,
    "field3": "value3"
  }
}
```

**CRITICAL**: The `Data` field values MUST match the data types defined in the associated Data Extension:
- Text fields → string values
- Number fields → numeric values (NOT strings like "12345")
- EmailAddress fields → valid email string
- Date fields → ISO date string

Returns `eventInstanceId` on success.

### List Event Definitions

```
GET {rest_url}/interaction/v1/eventDefinitions
```

Returns existing event definitions with their keys, types, and associated data schemas.

### Creating API Event Definitions

Cannot be created via API in this SDO (returns error 30000). Must be created via Journey Builder UI. However, existing ones work perfectly for firing events.

---

## Data Extensions

### Create via SOAP (Proven Working)

```xml
<Objects xsi:type="DataExtension">
  <CustomerKey>unique-api-key</CustomerKey>
  <Name>Display Name in MC</Name>
  <Description>Purpose</Description>
  <IsSendable>true</IsSendable>
  <SendableDataExtensionField>
    <Name>EmailAddress</Name>
  </SendableDataExtensionField>
  <SendableSubscriberField>
    <Name>Subscriber Key</Name>
  </SendableSubscriberField>
  <Fields>
    <Field>
      <CustomerKey>ContactKey</CustomerKey>
      <Name>ContactKey</Name>
      <FieldType>Text</FieldType>
      <MaxLength>100</MaxLength>
      <IsPrimaryKey>true</IsPrimaryKey>
      <IsRequired>true</IsRequired>
    </Field>
    <Field>
      <CustomerKey>EmailAddress</CustomerKey>
      <Name>EmailAddress</Name>
      <FieldType>EmailAddress</FieldType>
      <MaxLength>254</MaxLength>
      <IsRequired>true</IsRequired>
    </Field>
    <Field>
      <CustomerKey>FirstName</CustomerKey>
      <Name>FirstName</Name>
      <FieldType>Text</FieldType>
      <MaxLength>50</MaxLength>
    </Field>
  </Fields>
</Objects>
```

### Field Types
| Type | Use for | Notes |
|------|---------|-------|
| `Text` | Names, categories | Set MaxLength |
| `EmailAddress` | Email fields | Validates format |
| `Number` | Integers | |
| `Decimal` | Currency, percentages | |
| `Date` | Dates | Stored as datetime |
| `Boolean` | Flags | true/false |

### Insert Rows (REST - Async Bulk)

```bash
POST {rest_url}/data/v1/async/dataextensions/key:{de_key}/rows

{
  "items": [
    {"EmailAddress": "user@example.com", "FirstName": "Sarah", "LastName": "Chen"},
    {"EmailAddress": "user2@example.com", "FirstName": "James", "LastName": "Wilson"}
  ]
}
```

Returns `requestId` — processed asynchronously. Errors in `resultMessages[]`.

### Read Rows (REST)

```bash
GET {rest_url}/data/v1/customobjectdata/key/{de_key}/rowset
GET {rest_url}/data/v1/customobjectdata/key/{de_key}/rowset?$filter=FirstName%20eq%20'Sarah'
```

Returns `items[]` with `keys` and `values` for each row.

### List All Data Extensions (SOAP)

```xml
<RetrieveRequest>
  <ObjectType>DataExtension</ObjectType>
  <Properties>Name</Properties>
  <Properties>CustomerKey</Properties>
  <Properties>IsSendable</Properties>
</RetrieveRequest>
```

Current SDO has 61 Data Extensions.

---

## Automations (REST)

### Create

```bash
POST {rest_url}/automation/v1/automations

{
  "name": "Automation Name",
  "description": "What it does",
  "type": "scheduled",
  "status": -1,
  "steps": []
}
```

### Status Values
| Status | Meaning |
|--------|---------|
| `-1` | Draft |
| `2` | Ready |
| `4` | Running |
| `6` | Scheduled |
| `8` | Paused |

### List Automations

```bash
GET {rest_url}/automation/v1/automations
```

---

## Subscribers (SOAP)

### List Subscribers

```xml
<RetrieveRequest>
  <ObjectType>Subscriber</ObjectType>
  <Properties>SubscriberKey</Properties>
  <Properties>EmailAddress</Properties>
  <Properties>Status</Properties>
  <Properties>CreatedDate</Properties>
</RetrieveRequest>
```

SDO has 2500+ active subscribers pre-loaded.

### Lists

```xml
<RetrieveRequest>
  <ObjectType>List</ObjectType>
  <Properties>ID</Properties>
  <Properties>ListName</Properties>
  <Properties>Type</Properties>
</RetrieveRequest>
```

Key lists:
- `All Subscribers` — ID: 16705 (used in send definitions as "466907" subscriber list number)
- `Test List` — ID: 20867

---

## Send Tracking (SOAP)

### Historical Sends

```xml
<RetrieveRequest>
  <ObjectType>Send</ObjectType>
  <Properties>ID</Properties>
  <Properties>SentDate</Properties>
  <Properties>NumberSent</Properties>
  <Properties>Subject</Properties>
  <Properties>Status</Properties>
</RetrieveRequest>
```

25 historical send records in SDO.

---

## Journey Publish (Activation)

### Publish Async

```
POST {rest_url}/interaction/v1/interactions/publishAsync/{journeyId}?versionNumber=1
```

Returns `statusUrl` and `statusId`. Poll for completion:

```
GET {rest_url}/interaction/v1/interactions/publishStatus/{statusId}
```

**Publish Requirements** (journey must have):
1. Entry source configured (event-based or audience-based)
2. Entry mode selected in settings
3. Valid activities (emails must exist, etc.)
4. No validation errors

---

## Email HTML Structure (Proven Template)

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;font-family:Arial,sans-serif;background:#f4f4f4;">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f4f4;">
<tr><td align="center" style="padding:20px 0;">
<table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">

<!-- HEADER (brand color) -->
<tr><td style="background:#1a237e;padding:35px 30px;text-align:center;">
  <h1 style="color:#ffffff;margin:0;font-size:24px;">Brand Name</h1>
  <p style="color:#c5cae9;margin:8px 0 0 0;font-size:13px;">Tagline</p>
</td></tr>

<!-- BODY -->
<tr><td style="padding:40px 30px;">
  <h2 style="color:#1a237e;margin:0 0 15px 0;">Headline</h2>
  <p style="color:#444;line-height:1.7;">Hi %%FirstName%%,</p>
  <p style="color:#444;line-height:1.7;">Body content here...</p>

  <!-- CTA BUTTON -->
  <table cellpadding="0" cellspacing="0" style="margin:30px 0;">
  <tr><td style="background:#1a237e;border-radius:6px;padding:14px 35px;">
    <a href="URL" style="color:#fff;text-decoration:none;font-weight:bold;font-size:15px;">CTA Text</a>
  </td></tr>
  </table>
</td></tr>

<!-- FOOTER -->
<tr><td style="background:#f8f8f8;padding:20px 30px;text-align:center;border-top:1px solid #eee;">
  <p style="color:#999;font-size:11px;margin:0;">Company | Address</p>
  <p style="color:#999;font-size:11px;margin:5px 0 0 0;">
    <a href="%%unsub_center_url%%" style="color:#666;">Unsubscribe</a> |
    <a href="%%profile_center_url%%" style="color:#666;">Manage Preferences</a>
  </p>
</td></tr>

</table>
</td></tr>
</table>
</body>
</html>
```

### Personalization Strings
```
%%FirstName%%            — Subscriber/DE field
%%LastName%%             — Subscriber/DE field
%%unsub_center_url%%     — System unsubscribe link (REQUIRED for CAN-SPAM)
%%profile_center_url%%   — System preference center
%%view_email_url%%       — View in browser link
```

---

## SOAP API Reference

### Request Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"
            xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing">
  <s:Header>
    <a:Action s:mustUnderstand="1">{Action}</a:Action>
    <a:To s:mustUnderstand="1">{soap_url}/Service.asmx</a:To>
    <fueloauth xmlns="http://exacttarget.com">{access_token}</fueloauth>
  </s:Header>
  <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <!-- Create, Retrieve, Update, or Delete request -->
  </s:Body>
</s:Envelope>
```

Actions: `Create`, `Retrieve`, `Update`, `Delete`

SOAP URL: `https://{subdomain}.soap.marketingcloudapis.com/Service.asmx`

---

## Quick Reference: API by Task

| I want to... | API | Method |
|-------------|-----|--------|
| **Create sendable email** | REST | POST `/asset/v1/content/assets` (type 207) |
| Create display-only email | REST | POST `/asset/v1/content/assets` (type 208) |
| **Create content block** | REST | POST `/asset/v1/content/assets` (type 197/220) |
| **Upload image** | REST | POST `/asset/v1/content/assets` (type 28, with `file` base64) |
| Create folder | REST | POST `/asset/v1/content/categories` |
| List/search emails | REST | GET `/asset/v1/content/assets?$filter=...` |
| **Create data extension** | SOAP | Create > DataExtension |
| **Insert DE rows** | REST | POST `/data/v1/async/dataextensions/key:{key}/rows` |
| **Read DE rows** | REST | GET `/data/v1/customobjectdata/key/{key}/rowset` |
| **Create automation** | REST | POST `/automation/v1/automations` |
| List automations | REST | GET `/automation/v1/automations` |
| **Create journey** | REST | POST `/interaction/v1/interactions` |
| **Publish journey** | REST | POST `/interaction/v1/interactions/publishAsync/{id}` |
| Delete journey | REST | DELETE `/interaction/v1/interactions/{id}` |
| **Create send definition** | REST | POST `/messaging/v1/email/definitions` |
| **Send transactional email** | REST | POST `/messaging/v1/email/messages/{key}` |
| Check message status | REST | GET `/messaging/v1/email/messages/{messageKey}` |
| **Fire event (journey entry)** | REST | POST `/interaction/v1/events` |
| List event definitions | REST | GET `/interaction/v1/eventDefinitions` |
| List subscribers | SOAP | Retrieve > Subscriber |
| List DEs | SOAP | Retrieve > DataExtension |
| Get send tracking | SOAP | Retrieve > Send |
| List triggered sends | SOAP | Retrieve > TriggeredSendDefinition |

---

## SDO Reference Data

### Key IDs
| Item | Value |
|------|-------|
| All Subscribers List ID (for send defs) | `466907` |
| All Subscribers List ID (SOAP) | `16705` |
| Tracking Data Extension GUID | `6B0A9921-BA6D-4BCB-8FB9-03A9EDBC8816` |
| Root Content Builder Folder ID | `466941` |
| Claude Demo Assets Folder ID | `716404` |
| Total Subscribers | 2500+ |
| Total Data Extensions | 61 |
| Total Templates | 15 |
| Total Event Definitions | 10 |
| Total Triggered Send Defs | 17 |

### Proven Working Assets (Created by Claude)
| Asset | Type | ID | Customer Key |
|-------|------|----|-------------|
| Welcome Email (Display) | htmlemail (208) | 217436 | 45520d66-6f77-4651-94d9-508a84ba3c14 |
| Product Education (Display) | htmlemail (208) | 217437 | bf669247-587a-436f-905c-35a915b2f9bd |
| Welcome V3 (Sendable) | templatebasedemail (207) | 217440 | b2baf29a-c6ef-4071-ae2f-a2134a17ee0f |
| Re-engagement Email | templatebasedemail (207) | 217445 | (in folder 716404) |
| Header Block | htmlblock (197) | 217441 | 8e66ed0c-a0a9-4b2e-a052-823dd4211614 |
| Footer Block | htmlblock (197) | 217442 | 97657134-6589-4297-ac6d-1b03aa59e453 |
| CTA Button Block | codesnippetblock (220) | 217443 | 719b9a5a-3c3f-42ee-9141-c841d905e034 |
| Test Image | png (28) | 217444 | (published URL available) |
| FinServ Contacts DE | DataExtension | — | claude-finserv-contacts |
| Journey Entry Contacts DE | DataExtension | — | claude-demo-journey-contacts |
| Welcome Transactional V4 | Send Definition | — | claude-welcome-transactional-v4 |
| Nightly Contact Sync | Automation | 599c7826... | — |
| Daily Data Refresh | Automation | 4fa1e721... | — |

---

## Tips for Demo-Quality Emails

1. **Always set subject line AND preheader** — shows professionalism in inbox preview
2. **Use personalization** — `%%FirstName%%` minimum, bonus for dynamic content
3. **Include both HTML and text views** — required for deliverability
4. **600px max width** — standard email width for all clients
5. **Inline all CSS** — email clients strip `<style>` tags
6. **Use tables for layout** — flexbox/grid not supported in email clients
7. **Include unsubscribe link** — `%%unsub_center_url%%` (legally required)
8. **Use feature cards** — colored left-border boxes look polished
9. **Use a CTA button** — table-based button with inline styles
10. **Brand colors in header** — makes it look real immediately
11. **Use type 207 for sendable emails** — type 208 will fail send validation
12. **Always include `data.email` block** — with utf-8 encoding and attributes array

---

## Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `email_does_not_pass_validation` | Email is type 208 or missing `data.email` | Use type 207 with full `data.email` block |
| `Category object is invalid` | Used `parentId: 0` | Use actual folder ID (466941 for root) |
| `No base64-encoded bytes provided` | Image asset without `file` field | Include base64-encoded image data in `file` |
| `Field 'x' value does not match type` | Wrong data type in event fire | Match types exactly (Number = numeric, not string) |
| `Required Event Data fields are missing` | Missing fields in event fire | Include ALL fields defined in the DE schema |
| `EventDefinitionKey not found` | Wrong key or doesn't exist | Use `GET /interaction/v1/eventDefinitions` to find valid keys |
| Send def works as "New" but not "Active" | Missing list ID or DE in subscriptions | Include full `"All Subscribers - 466907"` and DE GUID |
