# Roadmap & Status

> **Last Updated**: 2026-06-30

---

## Current Status: Phase 2 — End-to-End Skill Building

Phase 1 (API Capability Validation) is complete. All Marketing Cloud APIs and Data Cloud → MC activation flows are proven and documented.

---

## Phase 1: API Capability Validation — COMPLETE

Every Marketing Cloud API capability needed for demo generation has been tested and documented:

| Capability | Status | Guide |
|-----------|--------|-------|
| Journey Builder (CRUD + Publish) | Done | `docs/mc-journey-api-guide.md` |
| Content Builder Emails | Done | `docs/mc-email-and-content-guide.md` |
| Content Blocks (reusable) | Done | Same as above |
| Image Upload | Done | Same as above |
| Data Extensions (CRUD + rows) | Done | Same as above |
| Transactional Sends | Done | Same as above |
| Event-Driven Journey Entry | Done | Same as above |
| Automations | Done | Same as above |
| Subscribers/Tracking | Done | Same as above |
| Data Cloud Segments | Done | `setup-guides/data-cloud.md` |
| DC → MC Activation | Done | `setup-guides/data-cloud-to-marketing-cloud.md` |
| Identity Resolution | Done | `setup-guides/identity-resolution.md` |
| Calculated Insights | Done | `setup-guides/calculated-insights.md` |

### What Was Created in the SDO (Phase 1 artifacts)

- 4 demo journeys (various industries/complexity levels)
- 5 Content Builder emails (sendable + display)
- 3 content blocks (header, footer, CTA)
- 2 data extensions with sample data
- 2 automations
- 1 active transactional send definition
- 1 custom folder ("Claude Demo Assets")
- Image upload tested
- 6 Data Cloud segments (active, published)
- MC activation target + activations (working end-to-end)

---

## Phase 2: End-to-End Demo Generation — IN PROGRESS

### Immediate Next Steps

1. **Connect Salesforce CRM SDO** — Fill in `SF_*` credentials in `.env`, test Sales Cloud API access
2. **Build first end-to-end skill** — Take a use case description → generate journey + emails + data automatically
3. **Industry templates** — Pre-built configurations for common verticals (FinServ, Healthcare, Retail, Tech)
4. **Click path generation** — Automated demo scripts showing what to click in the UI

---

## Phase 3: Polish & Scale — PLANNED

- Natural language → complete demo environment in < 2 minutes
- Multiple SDO support (different customers get different orgs)
- Slide generation from created demo content
- Demo reset/cleanup automation
- Integration with SE calendar (auto-prep before meetings)
- Multi-industry template library
