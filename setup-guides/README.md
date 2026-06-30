# Setup Guides — Platform Configuration Playbooks

> **Purpose**: Step-by-step guides for connecting each platform to the SE Demo Autopilot system.
> Each guide is written so that someone with a fresh SDO org can follow it end-to-end.

---

## Getting Started

| Guide | Status | Description |
|-------|--------|-------------|
| [salesforce-cli-setup.md](salesforce-cli-setup.md) | ✅ Fully working | Install SF CLI + authenticate to your SDO org |

## Configured Platforms

| Platform | Guide | Status | Manual Steps |
|----------|-------|--------|--------------|
| Data Cloud | [data-cloud.md](data-cloud.md) | ✅ Fully working | 1 (data stream sync) |
| Identity Resolution | [identity-resolution.md](identity-resolution.md) | ✅ Fully working | 0 (fully programmatic) |
| Calculated Insights | [calculated-insights.md](calculated-insights.md) | ✅ Fully working | 0 (fully programmatic) |
| Data Cloud → Marketing Cloud | [data-cloud-to-marketing-cloud.md](data-cloud-to-marketing-cloud.md) | ✅ Fully working | 1 (MC Connection OAuth) |
| Marketing Cloud REST API | [marketing-cloud-api.md](marketing-cloud-api.md) | ✅ Fully working | 0 (API credentials only) |
| Marketing Cloud Advanced | [marketing-cloud-advanced.md](marketing-cloud-advanced.md) | 🟡 Licenses active, configuring | 1 (license request via Slack) — all other steps automated via CLI + browser |

## Agent Tooling

| Tool | Guide | Status | Notes |
|------|-------|--------|-------|
| **Salesforce Docs Retrieval** | [salesforce-docs-retrieval.md](salesforce-docs-retrieval.md) | ✅ Fully working | READ THIS before fetching any SF documentation — article IDs are NOT guessable |

## Pending Platforms

| Platform | Guide | Status |
|----------|-------|--------|
| *(next platform)* | TBD | Not started |

---

## Guide Format

Every guide follows this structure:

1. **Overview** — What this integration does and why
2. **Prerequisites** — What must exist before you start
3. **Programmatic Steps** — What the agent does (with exact commands)
4. **Manual Steps** — What the human clicks (with exact UI paths + screenshots if possible)
5. **Verification** — How to confirm it worked
6. **Key IDs** — Org-specific values needed for API calls
7. **Troubleshooting** — Common errors and what they mean

---

## Philosophy

- Document the **happy path** clearly — what to do when everything works
- Document the **pitfalls** separately — what fails and why, so no one wastes hours rediscovering them
- Distinguish **one-time setup** (per org) from **repeatable operations** (per demo)
- Every manual step should explain WHY it can't be automated (yet)
