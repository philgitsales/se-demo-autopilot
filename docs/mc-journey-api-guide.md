# Marketing Cloud Journey Builder API — Lessons & Guide

> Hard-won knowledge from hands-on testing against an SDO (June 2026).
> Use this as your reference when creating journeys programmatically.
> Tested across 4+ production journeys with varying complexity.

---

## Authentication

```bash
curl -X POST "https://{subdomain}.auth.marketingcloudapis.com/v2/token" \
  -H "Content-Type: application/json" \
  -d '{
    "grant_type": "client_credentials",
    "client_id": "{client_id}",
    "client_secret": "{client_secret}"
  }'
```

Returns `access_token` (valid ~20 min). Use in all subsequent calls:
```
Authorization: Bearer {access_token}
```

---

## Endpoints

```
POST   {rest_url}/interaction/v1/interactions              — Create journey
PUT    {rest_url}/interaction/v1/interactions              — Update (include id + version)
GET    {rest_url}/interaction/v1/interactions/key:{key}    — Get by key
GET    {rest_url}/interaction/v1/interactions/{id}         — Get by ID
GET    {rest_url}/interaction/v1/interactions              — List all journeys
DELETE {rest_url}/interaction/v1/interactions/{id}         — Delete by ID
```

Where `{rest_url}` = `https://{subdomain}.rest.marketingcloudapis.com`

---

## Minimum Viable Journey (copy-paste starter)

```json
{
  "key": "unique-journey-key",
  "name": "Journey Display Name",
  "workflowApiVersion": 1.0,
  "version": 1,
  "status": "Draft",
  "definitionType": "Multistep",
  "executionMode": "Production",
  "defaults": {"email": ["sender@example.com", "sender@example.com"]},
  "activities": [
    {
      "key": "email-1",
      "name": "First Email",
      "type": "EMAILV2",
      "outcomes": [{"key": "o1", "next": "wait-1"}],
      "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}
    },
    {
      "key": "wait-1",
      "name": "Wait 2 Days",
      "type": "WAIT",
      "outcomes": [{"key": "o2", "next": "email-2"}],
      "configurationArguments": {"waitDuration": 2, "waitUnit": "DAYS"}
    },
    {
      "key": "email-2",
      "name": "Second Email",
      "type": "EMAILV2",
      "outcomes": [{"key": "o3"}],
      "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}
    }
  ]
}
```

---

## Character Restrictions (CRITICAL)

The API silently validates certain fields for illegal characters. This is the **#1 cause of mysterious failures**.

### Banned characters: `& < > " ' /`

| Field | Restriction | Example that FAILS |
|-------|------------|-------------------|
| Journey `name` | NO `& < > " ' /` | `"A/B Test Journey"` — fails due to `/` |
| Journey `description` | NO `& < > " ' /` | `"Trial-to-paid with A/B testing"` — fails due to `/` |

| Field | Restriction | Notes |
|-------|------------|-------|
| Activity `name` | **Allows all characters** | `"Email with / slash & ampersand"` works fine |
| Goal `name` | **Allows all characters** | `"Goal with / and & chars"` works fine |
| Exit `name` | **Allows all characters** | `"Exit with <special> chars"` works fine |
| Outcome `metaData.label` | **Allows all characters** | Used for branch labels on canvas |

### Safe alternatives:
- Instead of `A/B Test` → use `AB Test` or `Split Test`
- Instead of `Trial-to-Paid` → use `Trial-to-Paid` (hyphens are fine!)
- Instead of `"quoted text"` → just remove quotes
- Instead of `Features & Benefits` → use `Features and Benefits`

---

## What WORKS (Confirmed)

| Feature | How to include | Tested limits |
|---------|---------------|---------------|
| **Journey description** | `"description": "text"` | Keep under ~100 chars, no banned chars |
| **Activity names** | `"name": "Descriptive Name"` | Can include any characters. Shows on canvas. |
| **Goals** | `"goals": [{...}]` | Up to 3 tested. No `description` field. |
| **Exits** | `"exits": [{...}]` | Up to 3 tested. No `description` field. |
| **MULTICRITERIADECISION** | Decision split | 2, 3, and 4-way splits all work |
| **RANDOMSPLIT** | A/B testing split | Works for random path assignment |
| **ENGAGEMENTSPLIT** | Engagement-based split | Splits based on open/click behavior |
| **SMSSYNC** | SMS activity | Works! (earlier failures were char issues) |
| **UPDATECONTACTDATA** | Update contact fields | Works for mid-journey data updates |
| **WAIT** | Time delays | DAYS, HOURS tested (MINUTES should work) |
| **Activity count** | Tested up to 19 | 15 with complex branching, 19 linear |
| **Sequential decisions** | Decision → merge → Decision | Works (tested 2 sequential splits) |
| **Goals + Exits + Splits** | All combined | Works when following char rules |
| **Diverging end paths** | Branches that don't merge | Works — paths can end independently |

---

## Activity Types Reference

### EMAILV2 (Email Send)
```json
{
  "key": "unique-key",
  "name": "Display Name for Canvas",
  "type": "EMAILV2",
  "outcomes": [{"key": "outcome-key", "next": "next-activity-key"}],
  "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}
}
```
- Last email in a journey: omit `"next"` from its outcome
- `applicationExtensionKey` is always `"jb-email-activity"`
- Activity name can contain any characters (including `/`, `&`, etc.)

### WAIT (Time Delay)
```json
{
  "key": "wait-key",
  "name": "Wait N Days",
  "type": "WAIT",
  "outcomes": [{"key": "outcome-key", "next": "next-activity-key"}],
  "configurationArguments": {"waitDuration": 2, "waitUnit": "DAYS"}
}
```
- Units: `DAYS`, `HOURS`, `MINUTES`
- Tested durations: 1 hour to 14 days

### MULTICRITERIADECISION (Criteria-Based Split)
```json
{
  "key": "decision-key",
  "name": "Decision Name",
  "type": "MULTICRITERIADECISION",
  "outcomes": [
    {"key": "path-a", "next": "activity-a", "metaData": {"label": "Path A Label"}},
    {"key": "path-b", "next": "activity-b", "metaData": {"label": "Path B Label"}},
    {"key": "path-c", "next": "activity-c", "metaData": {"label": "Path C Label"}}
  ],
  "configurationArguments": {}
}
```
- Supports 2, 3, or 4+ outcome paths
- `configurationArguments` must be present (even if empty `{}`)
- Use for: data-driven routing, engagement scoring, attribute checks

### RANDOMSPLIT (A/B Testing)
```json
{
  "key": "split-key",
  "name": "AB Test - Subject Lines",
  "type": "RANDOMSPLIT",
  "outcomes": [
    {"key": "variant-a", "next": "email-a", "metaData": {"label": "Variant A (50%)"}},
    {"key": "variant-b", "next": "email-b", "metaData": {"label": "Variant B (50%)"}}
  ],
  "configurationArguments": {}
}
```
- Randomly distributes contacts across paths
- Use for: A/B testing content, subject lines, timing, offers

### ENGAGEMENTSPLIT (Engagement-Based Split)
```json
{
  "key": "engage-key",
  "name": "Did They Open?",
  "type": "ENGAGEMENTSPLIT",
  "outcomes": [
    {"key": "opened", "next": "engaged-path", "metaData": {"label": "Opened"}},
    {"key": "not-opened", "next": "passive-path", "metaData": {"label": "Did Not Open"}}
  ],
  "configurationArguments": {}
}
```
- Splits based on engagement with a previous email (open, click)
- Typically placed after a Wait activity following an email

### SMSSYNC (SMS Message)
```json
{
  "key": "sms-key",
  "name": "SMS Reminder",
  "type": "SMSSYNC",
  "outcomes": [{"key": "outcome-key", "next": "next-activity-key"}],
  "configurationArguments": {}
}
```
- Multi-channel capability — combine with email in the same journey
- Note: requires MobileConnect provisioning for actual send

### UPDATECONTACTDATA (Update Contact Field)
```json
{
  "key": "update-key",
  "name": "Update Journey Stage",
  "type": "UPDATECONTACTDATA",
  "outcomes": [{"key": "outcome-key", "next": "next-activity-key"}],
  "configurationArguments": {}
}
```
- Updates a contact attribute mid-journey
- Use for: setting lifecycle stage, marking journey progress, flagging for scoring

---

## Branching Patterns

### Single 2-way split with merge
```
Email → Wait → Decision
                  ├── Path A → Email A ──┐
                  └── Path B → Email B ──┤
                                          ▼
                                    Wait → Final Email
```

### 3-way split (risk tiers, segments)
```
Email → Wait → Decision
                  ├── High → Urgent Email ──┐
                  ├── Medium → Moderate Email ┤
                  └── Low → Gentle Email ────┤
                                              ▼
                                        Wait → Follow-up
```

### Sequential decisions (funnel narrowing)
```
Email → Wait → Decision 1
                  ├── Opened → Social Proof ──┐
                  └── Ignored → Urgency ──────┤
                                               ▼
                                         Wait → Decision 2
                                                  ├── Clicked → Discount
                                                  └── No Click → Last Chance
```

### A/B test into criteria split
```
Email → Wait → Random Split (A/B)
                  ├── Video Tutorial ──┐
                  └── Written Guide ───┤
                                        ▼
                                  Wait → Usage Decision (4-way)
                                          ├── Power User → Upsell
                                          ├── Moderate → Feature Spotlight
                                          ├── Inactive → Re-engage
                                          └── Churn Risk → Personal Outreach
```

### Diverging paths (no merge)
Branches don't have to merge. Each can end independently:
```
Decision
  ├── Path A → Email → END
  └── Path B → Email → END
```

### Merge pattern code
```json
{"key": "email-path-a", "outcomes": [{"key": "o5a", "next": "wait-final"}]},
{"key": "email-path-b", "outcomes": [{"key": "o5b", "next": "wait-final"}]},
{"key": "wait-final", "type": "WAIT", "outcomes": [{"key": "o6", "next": "email-final"}]}
```

---

## Goals & Exits

Add at the journey level (NOT inside activities):

```json
{
  "goals": [
    {"name": "Goal Name Here", "metaData": {"isExitCriteria": false}}
  ],
  "exits": [
    {"name": "Exit Condition Name", "metaData": {"isExitCriteria": true}}
  ]
}
```

**Rules:**
- `goals[].metaData.isExitCriteria` = `false` (goals track progress, they don't eject)
- `exits[].metaData.isExitCriteria` = `true` (exits DO eject contacts from the journey)
- Do NOT add a `description` field to either — it causes error 30000
- Goal and exit `name` fields CAN contain special characters
- Tested up to 3 goals + 3 exits in one journey
- These show up in the Journey Builder UI sidebar

---

## What BREAKS

### Error 30000: "Cannot Save journey due to an error"
Generic error with NO detail. Known triggers:

| Cause | Fix |
|-------|-----|
| `description` field on activities | Remove — use `name` only |
| `description` field on goals/exits | Remove entirely |
| Banned chars in journey `name` | Remove `& < > " ' /` |
| Banned chars in journey `description` | Remove `& < > " ' /` |

### Error 10006: "Validation Errors Occurred!"
This one actually gives detail in `validationErrors[]`:
```json
{
  "message": "Validation Errors Occurred!",
  "errorcode": 10006,
  "validationErrors": [
    {"message": "Interaction Description contains illegal characters...", "errorcode": 121072}
  ]
}
```
- This error includes helpful sub-messages — read them!
- Triggered by clear validation rules (character checks, etc.)

### Error 30000: "Another user recently modified this journey"
- Happens on PUT if version is stale
- Fix: Delete and recreate (faster and more reliable for drafts)

---

## Updating Journeys (PUT)

Updating is fragile. Recommended approach:

1. **Prefer delete + recreate** — for draft journeys this is fast and reliable
2. If you must update: GET the journey first to get current `version`, modify the response body, PUT it back
3. **Version conflict** still happens even with correct version — there seems to be an internal propagation delay

---

## Deletion

```bash
curl -X DELETE "{rest_url}/interaction/v1/interactions/{journey_id}" \
  -H "Authorization: Bearer {token}"
```

- Works on Draft journeys immediately
- Published/running journeys must be stopped first
- Returns the journey ID string on success (e.g., `"fc6b51dd-5da7-481f-b07c-638bdf53c3fc"`)

---

## Journey Activation (Publishing)

To move a journey from Draft to Running:

```bash
POST {rest_url}/interaction/v1/interactions/publishAsync/{journeyId}?versionNumber=1
```

Returns:
```json
{
  "statusUrl": "/interaction/v1/interactions/publishStatus/{statusId}",
  "statusId": "f2194ef1-bb98-434a-a339-99710100a643"
}
```

Poll for status:
```bash
GET {rest_url}/interaction/v1/interactions/publishStatus/{statusId}
```

**Publish Requirements:**
1. Journey must have an entry source configured (Event-based or Audience-based)
2. Entry mode must be selected in settings
3. All referenced emails/assets must exist
4. No validation errors in activities

**For demos**: Creating journeys as Draft is usually sufficient — it shows the full journey canvas in the UI. Only publish if you need to demo contact injection via Fire Event API.

---

## Event-Driven Journey Entry

To inject contacts into a published journey via API:

```json
POST {rest_url}/interaction/v1/events

{
  "ContactKey": "subscriber-key-123",
  "EventDefinitionKey": "APIEvent-xxxxx-xxxx-xxxx",
  "Data": {
    "email": "user@example.com",
    "first_name": "Sarah",
    "numeric_field": 12345
  }
}
```

**CRITICAL**: Data field values must exactly match the types defined in the associated DE:
- Text → string
- Number → actual number (not "12345")
- EmailAddress → valid email string
- Date → ISO format

Returns `eventInstanceId` on success.

List available event definitions:
```
GET {rest_url}/interaction/v1/eventDefinitions
```

---

## Debugging Failures

When creation fails:

1. **Check journey name + description for banned chars** (`& < > " ' /`)
2. **Remove all `description` fields** from activities, goals, and exits
3. **Start minimal** — 2-3 activities, no goals/exits/splits
4. **Add features one at a time** — goals, then exits, then splits
5. **Verify activity keys are unique** — duplicate keys = silent failure
6. **Check outcome.next references** — every `next` must match an existing activity `key`
7. **Ensure no orphaned activities** — every activity should be reachable from the chain
8. **Check for error 10006** — if you get it, read `validationErrors[]` for the actual reason

---

## Proven Working Templates

### Template 1: Financial Services Onboarding (with decision split)

```json
{
  "key": "onboarding-journey-v1",
  "name": "New Client Onboarding",
  "description": "Financial services onboarding with engagement-based branching",
  "workflowApiVersion": 1.0,
  "version": 1,
  "status": "Draft",
  "definitionType": "Multistep",
  "executionMode": "Production",
  "defaults": {"email": ["sender@domain.com", "sender@domain.com"]},
  "goals": [
    {"name": "Email Engagement Goal", "metaData": {"isExitCriteria": false}},
    {"name": "Product Adoption", "metaData": {"isExitCriteria": false}}
  ],
  "exits": [
    {"name": "Unsubscribe Exit", "metaData": {"isExitCriteria": true}},
    {"name": "Advisor Booked Exit", "metaData": {"isExitCriteria": true}}
  ],
  "activities": [
    {"key": "email-welcome", "name": "Welcome - Account Activation", "type": "EMAILV2", "outcomes": [{"key": "o1", "next": "wait-onboard"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-onboard", "name": "Wait 2 Days", "type": "WAIT", "outcomes": [{"key": "o2", "next": "email-education"}], "configurationArguments": {"waitDuration": 2, "waitUnit": "DAYS"}},
    {"key": "email-education", "name": "Product Education - Portfolio Tools", "type": "EMAILV2", "outcomes": [{"key": "o3", "next": "wait-engage"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-engage", "name": "Wait 3 Days", "type": "WAIT", "outcomes": [{"key": "o4", "next": "decision-engagement"}], "configurationArguments": {"waitDuration": 3, "waitUnit": "DAYS"}},
    {"key": "decision-engagement", "name": "Engagement Check", "type": "MULTICRITERIADECISION", "outcomes": [{"key": "path-engaged", "next": "email-crosssell", "metaData": {"label": "Engaged (Opened/Clicked)"}}, {"key": "path-passive", "next": "email-reengage", "metaData": {"label": "Not Engaged"}}], "configurationArguments": {}},
    {"key": "email-crosssell", "name": "Premium Cross-Sell (Engaged Path)", "type": "EMAILV2", "outcomes": [{"key": "o5a", "next": "wait-final"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "email-reengage", "name": "Re-engagement Nudge (Passive Path)", "type": "EMAILV2", "outcomes": [{"key": "o5b", "next": "wait-final"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-final", "name": "Wait 5 Days", "type": "WAIT", "outcomes": [{"key": "o6", "next": "email-advisor"}], "configurationArguments": {"waitDuration": 5, "waitUnit": "DAYS"}},
    {"key": "email-advisor", "name": "Personal Advisor Introduction", "type": "EMAILV2", "outcomes": [{"key": "o7"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}}
  ]
}
```

### Template 2: Cart Abandonment (HOURS waits + sequential decisions)

```json
{
  "key": "cart-abandon-v1",
  "name": "Cart Abandonment Recovery",
  "description": "E-commerce cart recovery with urgency escalation",
  "workflowApiVersion": 1.0,
  "version": 1,
  "status": "Draft",
  "definitionType": "Multistep",
  "executionMode": "Production",
  "defaults": {"email": ["noreply@domain.com", "noreply@domain.com"]},
  "goals": [
    {"name": "Purchase Completed", "metaData": {"isExitCriteria": false}},
    {"name": "Cart Recovery Rate", "metaData": {"isExitCriteria": false}}
  ],
  "exits": [
    {"name": "Purchased Exit", "metaData": {"isExitCriteria": true}},
    {"name": "Unsubscribe Exit", "metaData": {"isExitCriteria": true}}
  ],
  "activities": [
    {"key": "email-reminder", "name": "Cart Reminder (1hr)", "type": "EMAILV2", "outcomes": [{"key": "o1", "next": "wait-short"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-short", "name": "Wait 4 Hours", "type": "WAIT", "outcomes": [{"key": "o2", "next": "decision-opened"}], "configurationArguments": {"waitDuration": 4, "waitUnit": "HOURS"}},
    {"key": "decision-opened", "name": "Opened Reminder?", "type": "MULTICRITERIADECISION", "outcomes": [{"key": "path-opened", "next": "email-social-proof", "metaData": {"label": "Opened"}}, {"key": "path-ignored", "next": "email-urgency", "metaData": {"label": "Did Not Open"}}], "configurationArguments": {}},
    {"key": "email-social-proof", "name": "Social Proof - Others Bought This", "type": "EMAILV2", "outcomes": [{"key": "o3a", "next": "wait-day"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "email-urgency", "name": "Urgency - Items Selling Fast", "type": "EMAILV2", "outcomes": [{"key": "o3b", "next": "wait-day"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-day", "name": "Wait 1 Day", "type": "WAIT", "outcomes": [{"key": "o4", "next": "decision-clicked"}], "configurationArguments": {"waitDuration": 1, "waitUnit": "DAYS"}},
    {"key": "decision-clicked", "name": "Clicked Any Link?", "type": "MULTICRITERIADECISION", "outcomes": [{"key": "path-clicked", "next": "email-discount", "metaData": {"label": "Clicked - High Intent"}}, {"key": "path-noclk", "next": "email-last-chance", "metaData": {"label": "No Click - Low Intent"}}], "configurationArguments": {}},
    {"key": "email-discount", "name": "Exclusive 10% Discount Offer", "type": "EMAILV2", "outcomes": [{"key": "o5a"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "email-last-chance", "name": "Last Chance - Cart Expires Soon", "type": "EMAILV2", "outcomes": [{"key": "o5b"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}}
  ]
}
```

### Template 3: Healthcare Wellness (3-way split + long chain)

```json
{
  "key": "wellness-program-v1",
  "name": "Patient Wellness Program",
  "description": "Healthcare preventive care journey with risk-tier routing",
  "workflowApiVersion": 1.0,
  "version": 1,
  "status": "Draft",
  "definitionType": "Multistep",
  "executionMode": "Production",
  "defaults": {"email": ["wellness@domain.com", "wellness@domain.com"]},
  "goals": [
    {"name": "Annual Checkup Booked", "metaData": {"isExitCriteria": false}},
    {"name": "Wellness Score Improved", "metaData": {"isExitCriteria": false}},
    {"name": "Screening Completed", "metaData": {"isExitCriteria": false}}
  ],
  "exits": [
    {"name": "Opt-Out Exit", "metaData": {"isExitCriteria": true}},
    {"name": "Care Plan Activated", "metaData": {"isExitCriteria": true}}
  ],
  "activities": [
    {"key": "email-welcome", "name": "Welcome to Wellness Program", "type": "EMAILV2", "outcomes": [{"key": "o1", "next": "wait-assess"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-assess", "name": "Wait 3 Days", "type": "WAIT", "outcomes": [{"key": "o2", "next": "email-assessment"}], "configurationArguments": {"waitDuration": 3, "waitUnit": "DAYS"}},
    {"key": "email-assessment", "name": "Health Risk Assessment Invite", "type": "EMAILV2", "outcomes": [{"key": "o3", "next": "wait-risk"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-risk", "name": "Wait 5 Days", "type": "WAIT", "outcomes": [{"key": "o4", "next": "decision-risk"}], "configurationArguments": {"waitDuration": 5, "waitUnit": "DAYS"}},
    {"key": "decision-risk", "name": "Risk Tier Assignment", "type": "MULTICRITERIADECISION", "outcomes": [{"key": "path-high", "next": "email-high", "metaData": {"label": "High Risk"}}, {"key": "path-med", "next": "email-med", "metaData": {"label": "Medium Risk"}}, {"key": "path-low", "next": "email-low", "metaData": {"label": "Low Risk"}}], "configurationArguments": {}},
    {"key": "email-high", "name": "Urgent - Schedule Specialist Visit", "type": "EMAILV2", "outcomes": [{"key": "o5a", "next": "wait-followup"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "email-med", "name": "Recommended Screenings", "type": "EMAILV2", "outcomes": [{"key": "o5b", "next": "wait-followup"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "email-low", "name": "Wellness Tips and Prevention", "type": "EMAILV2", "outcomes": [{"key": "o5c", "next": "wait-followup"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-followup", "name": "Wait 7 Days", "type": "WAIT", "outcomes": [{"key": "o6", "next": "email-checkup"}], "configurationArguments": {"waitDuration": 7, "waitUnit": "DAYS"}},
    {"key": "email-checkup", "name": "Book Your Annual Checkup", "type": "EMAILV2", "outcomes": [{"key": "o7", "next": "wait-reminder"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-reminder", "name": "Wait 14 Days", "type": "WAIT", "outcomes": [{"key": "o8", "next": "email-final"}], "configurationArguments": {"waitDuration": 14, "waitUnit": "DAYS"}},
    {"key": "email-final", "name": "Final Reminder - Dont Miss Your Checkup", "type": "EMAILV2", "outcomes": [{"key": "o9"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}}
  ]
}
```

### Template 4: SaaS Trial Conversion (RANDOMSPLIT + 4-way decision)

```json
{
  "key": "saas-trial-v1",
  "name": "SaaS Trial-to-Paid Conversion",
  "description": "B2B trial nurture with split testing and usage-based routing",
  "workflowApiVersion": 1.0,
  "version": 1,
  "status": "Draft",
  "definitionType": "Multistep",
  "executionMode": "Production",
  "defaults": {"email": ["success@domain.com", "success@domain.com"]},
  "goals": [
    {"name": "Trial Converted to Paid", "metaData": {"isExitCriteria": false}}
  ],
  "exits": [
    {"name": "Converted to Paid", "metaData": {"isExitCriteria": true}},
    {"name": "Trial Expired", "metaData": {"isExitCriteria": true}},
    {"name": "Unsubscribe", "metaData": {"isExitCriteria": true}}
  ],
  "activities": [
    {"key": "email-trial-start", "name": "Trial Started - Getting Started", "type": "EMAILV2", "outcomes": [{"key": "o1", "next": "wait-1d"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-1d", "name": "Wait 1 Day", "type": "WAIT", "outcomes": [{"key": "o2", "next": "split-ab"}], "configurationArguments": {"waitDuration": 1, "waitUnit": "DAYS"}},
    {"key": "split-ab", "name": "AB Test Onboarding Style", "type": "RANDOMSPLIT", "outcomes": [{"key": "path-video", "next": "email-video", "metaData": {"label": "Video 50pct"}}, {"key": "path-text", "next": "email-text", "metaData": {"label": "Written 50pct"}}], "configurationArguments": {}},
    {"key": "email-video", "name": "Video Tutorial Series", "type": "EMAILV2", "outcomes": [{"key": "o3a", "next": "wait-usage"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "email-text", "name": "Step-by-Step Written Guide", "type": "EMAILV2", "outcomes": [{"key": "o3b", "next": "wait-usage"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-usage", "name": "Wait 2 Days", "type": "WAIT", "outcomes": [{"key": "o4", "next": "decision-usage"}], "configurationArguments": {"waitDuration": 2, "waitUnit": "DAYS"}},
    {"key": "decision-usage", "name": "Product Usage Level", "type": "MULTICRITERIADECISION", "outcomes": [{"key": "path-power", "next": "email-power", "metaData": {"label": "Power User"}}, {"key": "path-moderate", "next": "email-moderate", "metaData": {"label": "Moderate"}}, {"key": "path-inactive", "next": "email-inactive", "metaData": {"label": "Inactive"}}, {"key": "path-churn", "next": "email-churn", "metaData": {"label": "Churn Risk"}}], "configurationArguments": {}},
    {"key": "email-power", "name": "Advanced Features Plus Team Plan", "type": "EMAILV2", "outcomes": [{"key": "o5a", "next": "wait-convert"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "email-moderate", "name": "Feature Spotlight", "type": "EMAILV2", "outcomes": [{"key": "o5b", "next": "wait-convert"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "email-inactive", "name": "We Miss You - Quick Win", "type": "EMAILV2", "outcomes": [{"key": "o5c", "next": "wait-convert"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "email-churn", "name": "Success Manager Outreach", "type": "EMAILV2", "outcomes": [{"key": "o5d", "next": "wait-convert"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-convert", "name": "Wait 5 Days", "type": "WAIT", "outcomes": [{"key": "o6", "next": "email-trial-ending"}], "configurationArguments": {"waitDuration": 5, "waitUnit": "DAYS"}},
    {"key": "email-trial-ending", "name": "Trial Ends in 3 Days - Upgrade", "type": "EMAILV2", "outcomes": [{"key": "o7", "next": "wait-last"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}},
    {"key": "wait-last", "name": "Wait 2 Days", "type": "WAIT", "outcomes": [{"key": "o8", "next": "email-last-day"}], "configurationArguments": {"waitDuration": 2, "waitUnit": "DAYS"}},
    {"key": "email-last-day", "name": "Last Day - Special Offer", "type": "EMAILV2", "outcomes": [{"key": "o9"}], "configurationArguments": {"applicationExtensionKey": "jb-email-activity"}}
  ]
}
```

---

## Scope Requirements

The installed package needs these scopes for journey operations:
- `journeys_read`
- `journeys_write`

**Not needed** for journey creation (but useful for full demo setup):
- `email_read` / `email_write` — for triggered sends
- `saved_content_read` / `saved_content_write` — for Content Builder (may not be available on all SDOs)
- `list_and_subscribers_read` / `list_and_subscribers_write` — for audiences

---

## Quick Reference: Journey Design Patterns by Industry

| Industry | Typical Pattern | Key Activities |
|----------|----------------|---------------|
| **Financial Services** | Onboarding → Education → Cross-sell → Advisor | EMAILV2, WAIT (2-5 days), MULTICRITERIADECISION |
| **E-commerce** | Trigger → Urgency escalation → Discount | EMAILV2, WAIT (hours), sequential decisions |
| **Healthcare** | Welcome → Assessment → Risk routing → Follow-up | EMAILV2, WAIT (3-14 days), 3-way MULTICRITERIADECISION |
| **SaaS/B2B** | Trial start → A/B onboard → Usage split → Conversion push | RANDOMSPLIT, 4-way MULTICRITERIADECISION, EMAILV2 |
| **Retail** | Browse abandon → Recommendations → Loyalty | ENGAGEMENTSPLIT, EMAILV2, SMSSYNC |

---

## Tips for "Looking Real"

When an SE wants the journey to look production-quality in the UI:

1. **Use descriptive activity names** — these appear on the canvas nodes
2. **Use realistic wait durations** — hours for transactional, 1-3 days for onboarding, 5-14 for nurture
3. **Include goals** — shows the journey has measurable outcomes
4. **Include exits** — shows proper lifecycle management (unsubscribes, conversions)
5. **Add decision splits** — makes the canvas visually interesting with branching paths
6. **Mix split types** — RANDOMSPLIT for A/B tests, MULTICRITERIADECISION for data routing
7. **Use semantic activity keys** — `email-welcome`, `wait-engage`, `decision-risk` (helps debugging)
8. **Keep journey description short but meaningful** — appears in the journey list view
9. **Merge branches where appropriate** — shows intentional journey design
10. **Use 3-4 way splits sparingly** — one complex split is more impressive than many simple ones

---

## Known Limitations

- **No true loops** — can't send a contact back to a previous activity
- **No conditional waits** — wait duration is fixed, can't wait "until event"
- **Description field is fragile** — banned chars with unhelpful errors
- **PUT updates unreliable** — delete + recreate is the safer pattern
- **List endpoint doesn't return activity details** — must GET individual journeys for full data
- **Activity descriptions not supported** — only `name` shows on canvas (descriptions silently cause errors)
