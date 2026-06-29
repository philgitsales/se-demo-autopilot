# Product Documentation — Official Salesforce Reference

> **Pulled**: 2026-06-29
> **Source**: help.salesforce.com (extracted via `platform-docs-get` skill with `--stealth`)
> **Purpose**: Reference docs for configuring Data Cloud (Identity Resolution, DMOs, Segments, Activations)

---

## How These Were Extracted

```bash
python3 skills/platform-docs-get/scripts/extract_help_salesforce.py \
  --url "<URL>" --stealth --pretty
```

See `setup-guides/salesforce-docs-retrieval.md` for the full retrieval workflow and known-good entry points.

---

## Index by Topic

### Identity Resolution (Priority 1 — NOT configured in our org)

| File | What It Covers |
|------|---------------|
| `identity-resolution-overview.md` | How IDR works, unified profile key ring concept |
| `identity-resolution-terminology.md` | Key terms: rulesets, unified objects, source profiles |
| `identity-resolution-rulesets.md` | What rulesets are, how they contain match + reconciliation rules |
| `identity-resolution-create-ruleset.md` | **Step-by-step creation** — primary DMO selection, editions required |
| `identity-resolution-data-modeling-requirements.md` | What DMOs/fields MUST exist before IDR can work |
| `identity-resolution-match-rules.md` | How match rules work, criteria structure |
| `identity-resolution-match-type-comparison.md` | Exact vs Fuzzy vs Normalized — when to use which |
| `identity-resolution-reconciliation-rules.md` | How to select winning values for unified fields |
| `identity-resolution-summary.md` | Resolution summary dashboard, how to read results |
| `match-rules-configure.md` | Detailed steps to add/configure match rules |
| `match-rules-criteria.md` | Match criteria field selection and operators |
| `match-rules-fuzzy-normalized.md` | **Deep dive on fuzzy/normalized matching** — transformation rules |
| `match-rules-advanced-settings.md` | Advanced match settings (thresholds, weighting) |
| `match-rule-terminology.md` | Terms specific to match rules |
| `required-data-mappings-for-idr.md` | **Critical** — what mappings/relationships must exist |
| `cim-individual-and-contact-points.md` | CIM model: Individual, ContactPointEmail/Phone/Address |
| `unified-profile-activation.md` | How to activate unified profiles to targets |

### Data Model & Harmonization (Priority 2)

| File | What It Covers |
|------|---------------|
| `data-model-objects-overview.md` | DMO concepts, categories, segmentability |
| `dmo-relationships.md` | One-to-one, many-to-one relationships between DMOs |
| `data-mapping.md` | DLO → DMO field mapping process |
| `data-streams-overview.md` | Data stream types, management, sync |
| `create-crm-data-stream.md` | Step-by-step CRM data stream creation |
| `data-spaces.md` | Data space partitioning concepts |

### Calculated Insights (Priority 3)

| File | What It Covers |
|------|---------------|
| `calculated-insights-overview.md` | What insights are, types (streaming, batch, SQL) |
| `insights-overview.md` | Broader insights feature overview |
| `omnichannel-calculated-insights.md` | CI in the context of omnichannel journeys |

### Segments & Activation (Priority 4)

| File | What It Covers |
|------|---------------|
| `segments-overview.md` | Segment types, creation, publishing |
| `omnichannel-segments.md` | Segmentation for omnichannel use cases |
| `activation-and-targets.md` | Activation process, target types |
| `omnichannel-activate.md` | Activation in omnichannel context |
| `mc-data-foundation-core.md` | DC → Marketing Cloud data foundation setup |

### Omnichannel Journey Guide (end-to-end reference)

| File | What It Covers |
|------|---------------|
| `omnichannel-data-model.md` | Required data model for omnichannel |
| `omnichannel-data-prep-stage.md` | Data preparation stages |
| `omnichannel-match-rules.md` | Match rules for omnichannel |
| `omnichannel-reconciliation.md` | Reconciliation for omnichannel |

### API & Ingestion

| File | What It Covers |
|------|---------------|
| `api-ingestion-get-started.md` | Ingestion API setup, auth, limits |

---

## Reading Order for IDR Setup

If you're setting up Identity Resolution from scratch, read in this order:

1. `identity-resolution-overview.md` — understand the concept
2. `identity-resolution-terminology.md` — learn the vocabulary
3. `identity-resolution-data-modeling-requirements.md` — check prerequisites
4. `required-data-mappings-for-idr.md` — ensure mappings are correct
5. `cim-individual-and-contact-points.md` — understand the data model
6. `identity-resolution-create-ruleset.md` — create the ruleset
7. `match-rules-configure.md` — add match rules
8. `match-rules-fuzzy-normalized.md` — choose match methods
9. `identity-resolution-reconciliation-rules.md` — add reconciliation
10. `identity-resolution-summary.md` — verify results
