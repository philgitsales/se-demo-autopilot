# SE Demo Autopilot

AI-powered demo generation for Salesforce SEs. Describe a use case — get a fully configured demo org, click path, and presentation materials.

## Vision

An SE describes their prospect meeting:
- Industry & company persona
- Product focus (MC, Data Cloud, Agentforce, etc.)
- Use case / scenario

The system then:
1. Seeds realistic data into a pre-provisioned SDO + Marketing Cloud org
2. Configures journeys, campaigns, automations, and content
3. Generates a click-path demo script
4. Produces a slide deck / talk track

**Time saved**: 2-4 hours of manual demo building → minutes.

## Status

> Full roadmap: `docs/roadmap.md`

- **Phase 1 — API Capability Validation**: COMPLETE
- **Phase 2 — End-to-End Demo Generation**: IN PROGRESS

## Project Structure

```
se-demo-autopilot/
├── CLAUDE.md              # Agent behavior rules
├── SKILLS.md              # Data Cloud CLI reference
├── AGENTS.md              # Installed SF skills inventory
├── config/                # Org credentials (gitignored)
├── setup-guides/          # Platform setup playbooks
├── docs/                  # Architecture, API guides, roadmap
├── data-cloud-setup/      # DC status, segments, product docs
├── skills/                # Salesforce agent skills
├── previews/              # Local HTML email previews
├── data-templates/        # (future) Industry data templates
└── scripts/               # (future) Automation scripts
```

## Getting Started

### Prerequisites
- Active Salesforce SDO with Connected App
- Active Marketing Cloud org with Installed Package (Server-to-Server)
- Claude Code with AI Expert Suite
- SF CLI authenticated (`sf org display -o <alias>`)

### Setup
See `setup-guides/README.md` for step-by-step platform configuration.

## Tech Stack
- **Orchestration**: Claude Code Skills
- **Salesforce APIs**: REST, Bulk, Metadata, Tooling, Data Cloud (sf data360)
- **Marketing Cloud APIs**: REST (Auth, Journey Builder, Content Builder, Contacts, Data Extensions)
- **Content Gen**: Claude for copy, Google Slides API (planned)
- **Data**: AI-generated synthetic data per industry
