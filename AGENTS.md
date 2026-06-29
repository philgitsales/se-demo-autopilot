# Agent Reference — SE Demo Autopilot

> **Purpose**: Reference for AI coding agents (Claude Code, Cursor, Codex, etc.) working on this project.

---

## Salesforce Skills Library

This project has **28 Salesforce skills** installed in the `skills/` directory. These are NOT Agentforce actions — they are instruction files and templates that teach AI coding assistants how to build on the Salesforce platform correctly.

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

## Installed Skills (28)

### Data Cloud (9) — Full lifecycle for Data Cloud operations
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

### Agentforce (5) — AI agent building & observability
| Skill | Purpose |
|-------|---------|
| `agentforce-architecture-analyze` | Snapshot & diagram agent architecture (topics, actions, flows) |
| `agentforce-d360-analyze` | Trace/inspect Agentforce sessions via Data Cloud |
| `agentforce-generate` | Build, modify, debug & deploy agents (Agent Script) |
| `agentforce-observe` | Analyze production agent behavior from session traces |
| `agentforce-test` | Write & run structured test suites for agents |

### Platform Core (7) — CRM objects, Apex, data, queries
| Skill | Purpose |
|-------|---------|
| `platform-apex-generate` | Write/refactor Apex (classes, triggers, batch, REST resources) |
| `platform-custom-object-generate` | Create/validate custom object metadata |
| `platform-custom-field-generate` | Create/validate custom field metadata |
| `platform-data-manage` | Bulk import/export, test data generation, cleanup |
| `platform-soql-query` | SOQL/SOSL generation, optimization, analysis |
| `platform-metadata-deploy` | Deploy metadata using sf CLI |
| `platform-metadata-retrieve` | Retrieve metadata from org to local project |

### Integration (2) — Connected Apps, Named Credentials, callouts
| Skill | Purpose |
|-------|---------|
| `integration-connectivity-generate` | Named Credentials, External Services, REST/SOAP patterns |
| `integration-connectivity-connected-app-configure` | OAuth flows, JWT, Connected Apps |

### DevOps & Org Management (3) — Orgs, permissions, diagrams
| Skill | Purpose |
|-------|---------|
| `dx-org-manage` | Create scratch orgs, snapshots, open orgs |
| `dx-org-permission-set-assign` | Assign permission sets to users |
| `external-diagram-mermaid-generate` | Salesforce architecture diagrams in Mermaid |

### Automation (1)
| Skill | Purpose |
|-------|---------|
| `automation-flow-generate` | Generate Flows (Screen, Record-Triggered, Scheduled) |

### Security & Permissions (1)
| Skill | Purpose |
|-------|---------|
| `platform-permission-set-generate` | Generate permission set XML (object, field, app perms) |

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

## Skills NOT Installed (Available from Source)

The full `forcedotcom/sf-skills` repo has 87 skills. We skipped ones not relevant to this project:

- **Commerce B2B** (3) — B2B storefronts, open-source components
- **Design Systems / SLDS** (3) — SLDS compliance, migration
- **Experience Cloud UI Bundles** (10) — React apps on Salesforce
- **OmniStudio / Industries** (8) — FlexCards, OmniScripts, DataPacks
- **Mobile** (3) — Native iOS/Android, offline LWCs
- **DevOps Testing** (4) — DevOps Center test suites & pipelines
- **Code Analyzer** (2) — Static analysis (PMD, ESLint)
- **LWC** (1) — Lightning Web Components with PICKLES scoring
- **Additional Platform** (6) — Tabs, apps, list views, validation rules, pages, sharing rules

To install any of these later:
```bash
gh repo clone forcedotcom/sf-skills /tmp/sf-skills
cp -R /tmp/sf-skills/skills/<skill-name> skills/
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
