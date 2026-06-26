# Architecture

## System Overview

```
┌────────────────────────────────┐
│  SE Input                      │
│  (form / conversation / skill) │
└──────────────┬─────────────────┘
               │
               ▼
┌────────────────────────────────┐
│  Claude Orchestrator Skill     │
│  - Parses use case             │
│  - Plans demo config           │
│  - Coordinates API calls       │
└──────────────┬─────────────────┘
               │
       ┌───────┼───────┐
       ▼       ▼       ▼
┌──────────┐ ┌──────────┐ ┌──────────────┐
│ SF SDO   │ │ MC Org   │ │ Content Gen  │
│          │ │          │ │              │
│ - Data   │ │ - Journeys│ │ - Slides    │
│ - Config │ │ - Emails  │ │ - Click path│
│ - Flows  │ │ - Segments│ │ - Script    │
└──────────┘ └──────────┘ └──────────────┘
```

## Authentication

### Salesforce SDO
- **Method**: OAuth 2.0 Client Credentials Flow
- **Setup**: Connected App with `api`, `refresh_token` scopes
- **Storage**: Client ID + Secret in local env file (`.env`, gitignored)

### Marketing Cloud
- **Method**: Server-to-Server OAuth (Installed Package)
- **Setup**: Installed Package → API Integration → Server-to-Server
- **Scopes needed**: Email, Journeys, Contacts, Data Extensions, Content Builder
- **Storage**: Client ID + Secret + Subdomain in local env file

## API Endpoints Used

### Salesforce
| Purpose | API | Endpoint |
|---------|-----|----------|
| Auth | OAuth 2.0 | `/services/oauth2/token` |
| CRUD data | REST API | `/services/data/vXX.0/sobjects/` |
| Bulk data | Bulk API 2.0 | `/services/data/vXX.0/jobs/ingest` |
| Metadata | Metadata API | `/services/Soap/m/XX.0` |
| Tooling | Tooling API | `/services/data/vXX.0/tooling/` |

### Marketing Cloud
| Purpose | API | Endpoint |
|---------|-----|----------|
| Auth | OAuth 2.0 | `{subdomain}.auth.marketingcloudapis.com/v2/token` |
| Journeys | Journey Builder | `{subdomain}.rest.marketingcloudapis.com/interaction/v1/` |
| Email | Content Builder | `{subdomain}.rest.marketingcloudapis.com/asset/v1/` |
| Contacts | Contact Builder | `{subdomain}.rest.marketingcloudapis.com/contacts/v1/` |
| Data | Data Extensions | `{subdomain}.rest.marketingcloudapis.com/data/v1/` |
