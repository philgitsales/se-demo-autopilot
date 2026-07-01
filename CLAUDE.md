# SE Demo Autopilot — Agent Instructions

> AI-powered demo generation for Salesforce SEs. Describe a use case → get a fully built demo org.

---

## Environment

| Component | Detail |
|---|---|
| SDO | Phil's Master SDO |
| Org Alias | `phil_master_sdo` |
| Data Space | `default` |
| MC Business Unit | `523019897` (MedVet) |
| MC Activation Target | `pk_test_mc` (ID: `85Ug70000023IAXEA2`) |
| Identity Resolution | Ruleset `Main` — PUBLISHED, 2,126 unified profiles |
| Data Cloud Status | Fully operational (see `data-cloud-setup/README.md`) |

### Connected MCPs

These are the MCP servers available in this environment:

| MCP | What it does | Auth status |
|---|---|---|
| `mcp-adaptor` | Salesforce org queries, service definitions, file/directory access | Active |
| `browser` | Browser automation (navigate, click, type, screenshot) | Active |
| `codesearch` | Search code across repos (blame, blob, diff, history) | Active |
| `columbo` | Gack/error investigation and stack trace analysis | Active |
| `github` | GitHub PRs, issues, checks | Active |
| `gmail` | Gmail search and read | Active |
| `google` | Google Workspace (Docs, Calendar, Tasks) | Active |
| `search` | Web search | Active |
| `slack` | Slack messaging, channel search, threads | ⚠️ Requires auth |
| `aisuite` | Python sandbox with tool access | Active |

**Note:** Slack MCP requires authentication before use. If Slack tools fail, the user needs to authorize via their connector settings.

---

## Rules

**When uncertain or something fails — follow this escalation. Do NOT guess or trial-and-error.**

1. Check `setup-guides/` and `docs/` for existing project documentation
2. Use `platform-docs-get` for official Salesforce docs (DO NOT use WebFetch/curl on SF docs — they return empty shells):
   ```bash
   python3 skills/platform-docs-get/scripts/extract_help_salesforce.py --url "<URL>" --stealth --pretty
   python3 skills/platform-docs-get/scripts/extract_salesforce_doc.py --url "<URL>" --stealth --pretty
   ```
   Article IDs are NOT guessable — read `setup-guides/salesforce-docs-retrieval.md` for navigation.
3. If docs don't answer it — search Slack (`slack_search_public_and_private`). Key channels: `#help-sell-mc-next`, `#help-csg-marketingcloud-next`
4. If both fail — **ASK THE HUMAN**. Tell them what you tried. Wait.

**Always:**
- NEVER commit credentials (`config/.env` is gitignored)
- Read `setup-guides/` before starting work on any platform
- Update `setup-guides/` with every discovery — these guides are the product
- When something fails, check setup-guides' troubleshooting tables first
- Keep demo content professional (use NTO, Cumulus Financial, etc.)
- For Data Cloud work, read `SKILLS.md` first
- Before delivering output, re-read the relevant rules/guides and verify compliance
- After completing a step, feature, or discovery: update the workstream file and prompt the user to authorize a commit + push

---

## Active Workstreams

Check `docs/workstreams/` to see what's in progress. Each file tracks one workstream (which guide, which step, what's done). **Read the relevant workstream file before starting work.**

Update the workstream file when you make progress.

---

## Reference

| What you need | Where it lives |
|---|---|
| Active work (current step) | `docs/workstreams/` |
| Roadmap & status | `docs/roadmap.md` |
| System architecture | `docs/architecture.md` |
| Journey Builder API | `docs/mc-journey-api-guide.md` |
| Emails, DEs, sends, automations | `docs/mc-email-and-content-guide.md` |
| DC → MC activation | `setup-guides/data-cloud-to-marketing-cloud.md` |
| MC API auth & key IDs | `setup-guides/marketing-cloud-api.md` |
| All platform setup guides | `setup-guides/README.md` |
| Data Cloud CLI commands | `SKILLS.md` |
| All installed SF skills | `AGENTS.md` |
| Connected MCP servers | `MCPS.md` |
| Org credentials | `config/.env` (NEVER commit) |

```
se-demo-autopilot/
├── CLAUDE.md              ← You are here
├── SKILLS.md              ← Data Cloud CLI reference
├── AGENTS.md              ← Installed SF skills inventory
├── MCPS.md               ← Connected MCP servers & when to use them
├── config/.env            ← Credentials (gitignored)
├── setup-guides/          ← Platform setup playbooks
├── docs/                  ← Architecture, API guides, roadmap, workstreams
├── data-cloud-setup/      ← DC status & segments
├── skills/                ← Salesforce agent skills
├── previews/              ← HTML email previews
├── data-templates/        ← (future) Industry data templates
└── scripts/               ← (future) Automation scripts
```
