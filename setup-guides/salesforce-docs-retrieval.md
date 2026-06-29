# Setup Guide: Salesforce Documentation Retrieval

> **What this does**: Pulls official Salesforce documentation from help.salesforce.com, developer.salesforce.com, and other SF-owned sites using a headless browser (Playwright).
> Normal web fetch (curl, WebFetch, etc.) returns EMPTY SHELLS on these sites because they use client-side JavaScript rendering.

---

## TL;DR for Agents

**DO NOT use WebFetch, curl, or any standard HTTP tool on Salesforce docs.** They will return garbage (empty shells, "CSS Error", navigation chrome only).

**USE THIS INSTEAD:**
```bash
# For help.salesforce.com (ALWAYS use --stealth)
python3 skills/platform-docs-get/scripts/extract_help_salesforce.py \
  --url "<FULL_URL>" --stealth --pretty

# For developer.salesforce.com or any other SF doc site
python3 skills/platform-docs-get/scripts/extract_salesforce_doc.py \
  --url "<FULL_URL>" --stealth --pretty
```

**Parse the JSON output:**
```bash
python3 skills/platform-docs-get/scripts/extract_help_salesforce.py \
  --url "<URL>" --stealth --pretty 2>&1 | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print('OK:', d['ok']); print(d.get('text',''))"
```

---

## CRITICAL: How to Find the Correct Article ID

This is the #1 pitfall. Salesforce Help article IDs are NOT guessable and change over time.

### The Problem

Salesforce reorganized their docs in late 2025 (Data Cloud → Data 360 rebrand). This means:
- **OLD (BROKEN)**: `sf.c360_a_activate_segment_marketing_cloud.htm` → 404
- **NEW (WORKING)**: `data.c360_a_mcdf_core.htm` → actual content

You CANNOT guess article IDs. Even small variations (`activate` vs `activations` vs `activation`) will 404.

### The Solution: Navigate From Known-Good Pages

**Step 1**: Start from a KNOWN WORKING page (see the index below).

**Step 2**: Extract child links from that page:
```bash
python3 skills/platform-docs-get/scripts/extract_help_salesforce.py \
  --url "https://help.salesforce.com/s/articleView?id=data.c360_a_solutions.htm&language=en_US&type=5" \
  --stealth --pretty 2>&1 | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
for l in d.get('contentLinks',[]):
    if 'articleView' in l:
        print(l)
"
```

**Step 3**: Follow the most relevant link until you find your target article.

### Known-Good Entry Points (verified 2026-06-29)

Use these as starting points to navigate to any topic:

| Topic | URL | What links from here |
|-------|-----|---------------------|
| **Data 360 Main** | `data.c360_a_data_cloud.htm` | Segments, connections, AI, releases, resources |
| **Cross-Product Solutions** | `data.c360_a_solutions.htm` | ALL integration guides (MCE, Service, Sales, omnichannel) |
| **DC → MCE Data Foundation** | `data.c360_a_mcdf_guide.htm` | 14 articles on activation to MC Engagement |
| **Omnichannel Journeys** | `data.c360_a_omni_home.htm` | 16 articles on multi-channel DC → MCE activation |
| **Activation Filtering** | `data.c360_a_activation_filtering_main.htm` | Contact point & membership filtering |
| **Segments** | `data.c360_a_segments.htm` | Segment creation, types, publishing |
| **MC Engagement Overview** | `sf.mc_overview_marketing_cloud.htm` | MC product areas, setup, channels |
| **Connect SF Data to DC** | `data.c360_a_connect_data_task_steps.htm` | Data streams, bundles, mapping |

**Full URL format**: `https://help.salesforce.com/s/articleView?id=<ARTICLE_ID>&language=en_US&type=5`

### Article ID Prefix Patterns

| Prefix | Product Area |
|--------|-------------|
| `data.c360_a_*` | Data Cloud / Data 360 |
| `sf.mc_*` | Marketing Cloud Engagement |
| `mktg.*` | Marketing Cloud Next |
| `ind.*` | Industries (Financial Services, Health, etc.) |

---

## How to Verify a Page Loaded Successfully

Check the JSON output:
- `"ok": true` → content was extracted successfully
- `"ok": false` + `"likelyShell": true` → page didn't render (try `--stealth`, or article ID is wrong)
- `"We looked high and low but couldn't find that page"` in text → **article ID is WRONG (404)**

**If you get a 404:**
1. DO NOT keep guessing article IDs
2. Go to a known-good entry point (table above)
3. Navigate by following links from there

---

## Common Workflows

### Find docs on a specific feature you don't know the article ID for

```bash
# 1. Start from the cross-product solutions index (the best TOC)
python3 skills/platform-docs-get/scripts/extract_help_salesforce.py \
  --url "https://help.salesforce.com/s/articleView?id=data.c360_a_solutions.htm&language=en_US&type=5" \
  --stealth --pretty 2>&1 | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d.get('text','')[:5000])
print('---LINKS---')
for l in d.get('contentLinks',[]):
    if 'articleView' in l and 'data.' in l:
        print(l)
"

# 2. Find the relevant link in the output, then fetch that page
# 3. Repeat until you reach the specific article
```

### Pull a developer docs API reference

```bash
# Developer docs use a different script and don't always need --stealth
python3 skills/platform-docs-get/scripts/extract_salesforce_doc.py \
  --url "https://developer.salesforce.com/docs/atlas.en-us.c360a_api.meta/c360a_api/c360a_api_get_started.htm" \
  --pretty 2>&1 | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('text','')[:5000])"
```

### Bulk-extract an entire guide (all child articles)

```bash
# 1. Get the parent page and extract all child links
LINKS=$(python3 skills/platform-docs-get/scripts/extract_help_salesforce.py \
  --url "https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_guide.htm&language=en_US&type=5" \
  --stealth --pretty 2>&1 | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
for l in d.get('contentLinks',[]):
    if 'articleView' in l and 'data.c360' in l:
        print(l)
")

# 2. Loop through each link
for url in $LINKS; do
  echo "=== $url ==="
  python3 skills/platform-docs-get/scripts/extract_help_salesforce.py \
    --url "$url" --stealth --pretty 2>&1 | \
    python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('title','FAILED')); print(d.get('text','')[:500]); print()"
done
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `"ok": false`, `"likelyShell": true` | Page JS didn't execute or article doesn't exist | Add `--stealth` flag. If still fails, article ID is wrong — navigate from known page. |
| `"We looked high and low"` | Article ID is a 404 | ID is wrong. Navigate from a known-good entry point. |
| `BrowserType.launch: Executable doesn't exist` | Playwright Chromium not installed in the right path | Run: `PLAYWRIGHT_BROWSERS_PATH=~/.claude/.fetching-salesforce-docs-runtime/ms-playwright ~/.claude/.fetching-salesforce-docs-runtime/venv/bin/playwright install chromium` |
| `ModuleNotFoundError: No module named 'playwright'` | Venv not set up | Run: `python3 -m venv ~/.claude/.fetching-salesforce-docs-runtime/venv && ~/.claude/.fetching-salesforce-docs-runtime/venv/bin/pip install playwright playwright-stealth` |
| Content looks truncated | Large pages may be clipped | Check `rawText` field in JSON for full content |
| `"ok": true` but text is navigation/chrome only | Extraction picked up wrong elements | Check the `contentBlocks` and `sections` arrays for actual content |

---

## Setup (Already Done — Reference Only)

If starting fresh or on a new machine:

```bash
# 1. Create isolated runtime
mkdir -p ~/.claude/.fetching-salesforce-docs-runtime
python3 -m venv ~/.claude/.fetching-salesforce-docs-runtime/venv

# 2. Install dependencies
~/.claude/.fetching-salesforce-docs-runtime/venv/bin/pip install playwright playwright-stealth

# 3. Install Chromium browser
PLAYWRIGHT_BROWSERS_PATH=~/.claude/.fetching-salesforce-docs-runtime/ms-playwright \
  ~/.claude/.fetching-salesforce-docs-runtime/venv/bin/playwright install chromium

# 4. Verify
python3 skills/platform-docs-get/scripts/extract_help_salesforce.py \
  --url "https://help.salesforce.com/s/articleView?id=sf.mc_overview_marketing_cloud.htm&type=5" \
  --stealth --pretty 2>&1 | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print('OK:', d['ok'], '| Title:', d.get('title',''))"
# Expected: OK: True | Title: Marketing Cloud Engagement | Salesforce Help
```

---

## Data Cloud Activation → MCE: Complete Article Index

These are the exact working URLs for ALL activation-related documentation (verified 2026-06-29):

### Data Foundation Guide (Primary — Use This First)
```
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_guide.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_terms.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_right_for_org.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_solution.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_req.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_core.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_link.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_usedata.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_cumulus.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_cumulus_req.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_cumulus_act.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_cumulus_att.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_cumulus_link.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_cumulus_uses.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_mcdf_best_practices.htm&language=en_US&type=5
```

### Omnichannel Journey Guide
```
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_home.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_best_practices.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_terms.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_model.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_workflow.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_stage.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_match.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_reconciliation.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_ci.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_audience.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_segment.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_activate.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_journey_settings.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_relationships.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_configure.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_journey.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_omni_consent.htm&language=en_US&type=5
```

### Activation Filtering & Attributes
```
https://help.salesforce.com/s/articleView?id=data.c360_a_activation_filtering_main.htm&language=en_US&type=5
https://help.salesforce.com/s/articleView?id=data.c360_a_related_attributes.htm&language=en_US&type=5
```
