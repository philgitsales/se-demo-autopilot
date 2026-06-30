# Agent Reference — SE Demo Autopilot

> **Purpose**: Reference for AI coding agents (Claude Code, Cursor, Codex, etc.) working on this project.

---

## IMPORTANT: Documentation Retrieval

**Before searching the web for Salesforce docs, USE THIS SKILL:**

### `platform-docs-get` (skills/platform-docs-get/SKILL.md)

This skill retrieves official Salesforce documentation from JS-heavy sites that normal fetch cannot handle (help.salesforce.com, developer.salesforce.com, architect.salesforce.com, etc.). It uses **Playwright** (headless browser) to render pages and extract real content.

**When to use**: Any time you need official Salesforce product documentation, API references, Help articles, setup guides, or SLDS docs. Normal WebFetch WILL FAIL on these sites — they use client-side JS rendering.

**How to use**:
```bash
# General Salesforce doc (any official domain)
python3 skills/platform-docs-get/scripts/extract_salesforce_doc.py "https://help.salesforce.com/s/articleView?id=sf.c360_a_activate_segment_marketing_cloud.htm&type=5"

# Specifically for help.salesforce.com articles
python3 skills/platform-docs-get/scripts/extract_help_salesforce.py "https://help.salesforce.com/s/articleView?id=sf.c360_a_activate_segment_marketing_cloud.htm&type=5"
```

**Dependencies**: `playwright`, `playwright-stealth` (already installed), Chromium (already installed via `playwright install chromium`)

---

## Salesforce Skills Library

This project has **ALL 87 Salesforce skills** installed in the `skills/` directory (from `forcedotcom/sf-skills`). These are NOT Agentforce actions — they are instruction files and templates that teach AI coding assistants how to build on the Salesforce platform correctly.

**Source**: [github.com/forcedotcom/sf-skills](https://github.com/forcedotcom/sf-skills)

### To discover all available skills (87 total)

```bash
gh repo clone forcedotcom/sf-skills /tmp/sf-skills
ls /tmp/sf-skills/skills/
```

Each skill is a directory containing:
- `SKILL.md` — structured instructions (commands, workflows, gotchas, output formats)
- `assets/` or `references/` — templates, schemas, guides (when applicable)
- `scripts/` — diagnostic or helper scripts (when applicable)

---

## Installed Skills (87) — Full Inventory Below

See the **"All 87 Skills"** section further down for the complete categorized list.

---

## How to Use Skills

Skills are reference material. When working on a task, read the relevant `SKILL.md` for:
- The correct commands and their exact flags
- Working JSON/XML templates
- Known gotchas and platform limitations
- The right order of operations
- Diagnostic steps to run first

Example:
```bash
# Before doing any Data Cloud segment work, read:
cat skills/data360-segment/SKILL.md

# Before creating activations:
cat skills/data360-activate/SKILL.md

# Use templates from:
ls skills/data360-orchestrate/assets/definitions/
```

---

## All 87 Skills — Full Inventory

All skills from `forcedotcom/sf-skills` are installed. Grouped by category:

### Data Cloud (9)
| Skill | Purpose |
|-------|---------|
| `data360-orchestrate` | Cross-phase pipeline orchestrator, diagnostics, data spaces |
| `data360-connect` | Source connections & connectors |
| `data360-prepare` | Data streams, DLOs, ingestion, transforms |
| `data360-harmonize` | DMOs, mappings, identity resolution, data graphs |
| `data360-segment` | Segments, calculated insights, publish workflows |
| `data360-activate` | Activations, activation targets, data actions |
| `data360-query` | Data Cloud SQL, vector search, search indexes |
| `data360-schema-get` | DLO/DMO schema introspection via REST |
| `data360-code-extension-generate` | Custom Python transformations for Data Cloud |

### Agentforce (5)
| Skill | Purpose |
|-------|---------|
| `agentforce-architecture-analyze` | Snapshot & diagram agent architecture |
| `agentforce-d360-analyze` | Trace/inspect Agentforce sessions via Data Cloud |
| `agentforce-generate` | Build, modify, debug & deploy agents |
| `agentforce-observe` | Analyze production agent behavior from session traces |
| `agentforce-test` | Write & run structured test suites for agents |

### Platform Core (15)
| Skill | Purpose |
|-------|---------|
| `platform-apex-generate` | Write/refactor Apex classes, triggers, batch, REST |
| `platform-apex-logs-debug` | Debug Apex logs |
| `platform-apex-test-generate` | Generate Apex tests |
| `platform-apex-test-run` | Run Apex tests |
| `platform-custom-application-generate` | Create custom Lightning applications |
| `platform-custom-field-generate` | Create/validate custom field metadata |
| `platform-custom-lightning-type-generate` | Custom lightning types |
| `platform-custom-object-generate` | Create/validate custom object metadata |
| `platform-custom-tab-generate` | Create custom tabs |
| `platform-data-manage` | Bulk import/export, test data generation |
| `platform-docs-get` | **⭐ Official Salesforce documentation retrieval (Playwright)** |
| `platform-flexipage-generate` | Generate FlexiPages |
| `platform-lightning-app-coordinate` | Coordinate Lightning apps |
| `platform-list-view-generate` | Generate list views |
| `platform-metadata-api-context-get` | Get metadata API context |
| `platform-metadata-deploy` | Deploy metadata using sf CLI |
| `platform-metadata-retrieve` | Retrieve metadata from org |
| `platform-permission-set-generate` | Generate permission set XML |
| `platform-sharing-rules-generate` | Generate sharing rules |
| `platform-soql-query` | SOQL/SOSL generation & optimization |
| `platform-tracing-agentforce-configure` | Agentforce tracing |
| `platform-tracing-configure` | Platform tracing/debug logs |
| `platform-trust-archive-manage` | Trust archive management |
| `platform-validation-rule-generate` | Generate validation rules |

### Experience Cloud (11)
| Skill | Purpose |
|-------|---------|
| `experience-cms-brand-apply` | Apply CMS branding |
| `experience-content-media-search` | Search CMS content & media |
| `experience-lwc-generate` | Generate LWCs for Experience Cloud |
| `experience-ui-bundle-agentforce-client-generate` | Agentforce client UI bundles |
| `experience-ui-bundle-app-coordinate` | Coordinate app UI bundles |
| `experience-ui-bundle-custom-app-generate` | Custom app UI generation |
| `experience-ui-bundle-deploy` | Deploy UI bundles |
| `experience-ui-bundle-features-generate` | Features UI generation |
| `experience-ui-bundle-file-upload-generate` | File upload UI generation |
| `experience-ui-bundle-frontend-generate` | Frontend generation |
| `experience-ui-bundle-metadata-generate` | Metadata UI generation |
| `experience-ui-bundle-salesforce-data-access` | Data access patterns |
| `experience-ui-bundle-site-generate` | Site generation |

### OmniStudio / Industries (8)
| Skill | Purpose |
|-------|---------|
| `omnistudio-callable-apex-generate` | Callable Apex for OmniStudio |
| `omnistudio-datamapper-generate` | DataMapper generation |
| `omnistudio-datapacks-deploy` | DataPack deployment |
| `omnistudio-dependencies-analyze` | Dependency analysis |
| `omnistudio-epc-catalog-generate` | EPC catalog generation |
| `omnistudio-flexcard-generate` | FlexCard generation |
| `omnistudio-integration-procedure-generate` | Integration Procedure generation |
| `omnistudio-omniscript-generate` | OmniScript generation |

### Commerce B2B (3)
| Skill | Purpose |
|-------|---------|
| `commerce-b2b-open-code-components-integrate` | Integrate open code components |
| `commerce-b2b-open-code-components-replace` | Replace components with open code |
| `commerce-b2b-store-create` | Create B2B stores |

### Design Systems / SLDS (3)
| Skill | Purpose |
|-------|---------|
| `design-systems-slds-apply` | Apply SLDS styling |
| `design-systems-slds-validate` | Validate SLDS compliance |
| `design-systems-slds2-migrate` | Migrate to SLDS2 |

### Integration (4)
| Skill | Purpose |
|-------|---------|
| `integration-connectivity-connected-app-configure` | OAuth flows, JWT, Connected Apps |
| `integration-connectivity-generate` | Named Credentials, External Services |
| `integration-eventing-cdc-configure` | Change Data Capture configuration |
| `integration-eventing-subscription-configure` | Platform Event subscriptions |

### DevOps & Org Management (7)
| Skill | Purpose |
|-------|---------|
| `dx-app-analytics-query` | AppExchange analytics queries |
| `dx-code-analyzer-configure` | Configure static analysis |
| `dx-code-analyzer-run` | Run code analysis |
| `dx-devops-test-failures-analyze` | Analyze test failures |
| `dx-devops-test-pipeline-configure` | Configure test pipelines |
| `dx-devops-test-suite-assignments-configure` | Test suite assignments |
| `dx-devops-test-suite-run` | Run test suites |
| `dx-org-manage` | Create scratch orgs, snapshots, open orgs |
| `dx-org-permission-set-assign` | Assign permission sets |
| `dx-org-switch` | Switch between orgs |

### Mobile (3)
| Skill | Purpose |
|-------|---------|
| `mobile-apps-create` | Create mobile apps |
| `mobile-platform-native-capabilities-integrate` | Native mobile capabilities |
| `mobile-platform-offline-validate` | Offline LWC validation |

### Automation (1)
| Skill | Purpose |
|-------|---------|
| `automation-flow-generate` | Generate Flows (Screen, Record-Triggered, Scheduled) |

### Diagrams (2)
| Skill | Purpose |
|-------|---------|
| `external-diagram-mermaid-generate` | Mermaid architecture diagrams |
| `external-diagram-visual-generate` | Visual diagram generation |

### Platform Agent Exchange (1)
| Skill | Purpose |
|-------|---------|
| `platform-agentexchange-partner-offers-configure` | Partner offer configuration |
| `platform-agentsetup-categories-fetch` | Fetch agent setup categories |

---

## To update skills (pull latest from source):
```bash
gh repo clone forcedotcom/sf-skills /tmp/sf-skills
cp -R /tmp/sf-skills/skills/* skills/
```

---

## Key Files for Agents

| File | What it contains |
|------|-----------------|
| `CLAUDE.md` | Project instructions, MC API details, rules |
| `SKILLS.md` | Consolidated Data Cloud CLI commands & templates |
| `AGENTS.md` | This file — skill inventory & how to use them |
| `data-cloud-setup/README.md` | Data Cloud status, findings, IDs |
| `data-cloud-setup/blockers-and-next-steps.md` | Pickup guide for each session |
| `docs/mc-journey-api-guide.md` | Marketing Cloud Journey Builder API |
| `docs/mc-email-and-content-guide.md` | MC emails, DEs, sends, events, automations |
