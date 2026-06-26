# SE Demo Autopilot

AI-powered demo generation for Salesforce SEs. Describe a use case — get a fully configured demo org, click path, and presentation materials.

## Vision

An SE fills out a form or talks to Claude, describing:
- Industry & company persona
- Product focus (MC, Data Cloud, Agentforce, etc.)
- Use case / scenario

The system then:
1. Seeds realistic data into a pre-provisioned SDO + Marketing Cloud org
2. Configures journeys, campaigns, automations, and content
3. Generates a click-path demo script
4. Produces a slide deck / talk track

## Project Structure

```
se-demo-autopilot/
├── skills/          # Claude Code skills for orchestration
├── config/          # Org connection configs (auth, endpoints)
├── data-templates/  # Industry-specific synthetic data templates
├── docs/            # Design docs, architecture decisions
├── scripts/         # Utility scripts (org reset, data seed, etc.)
└── README.md
```

## Status

**Phase 0 — Foundation (current)**
- [x] Create GitHub repo
- [ ] Connect to Marketing Cloud SDO (API auth)
- [ ] Connect to Salesforce SDO (API auth)
- [ ] Validate basic API calls (read/write)

**Phase 1 — Core Engine**
- [ ] Data seeding skill (industry-specific contacts, accounts, interactions)
- [ ] Journey Builder automation (create journeys via API)
- [ ] Email/content generation (Content Builder API)
- [ ] Campaign configuration

**Phase 2 — Demo Artifacts**
- [ ] Click-path generation (guided demo script)
- [ ] Slide deck generation (Google Slides API)
- [ ] Demo talk track / script

**Phase 3 — Polish & Scale**
- [ ] Multi-industry template library
- [ ] SE input form / conversational interface
- [ ] One-click reset between demos

## Getting Started

### Prerequisites
- Active Salesforce SDO with Connected App
- Active Marketing Cloud org with Installed Package (Server-to-Server)
- Claude Code with AI Expert Suite

### Setup
See `docs/setup-guide.md` (coming soon)

## Tech Stack
- **Orchestration**: Claude Code Skills
- **Salesforce APIs**: REST, Bulk, Metadata, Tooling
- **Marketing Cloud APIs**: REST (Auth, Journey Builder, Content Builder, Contacts)
- **Content Gen**: Google Slides API, Claude for copy
- **Data**: AI-generated synthetic data per industry
