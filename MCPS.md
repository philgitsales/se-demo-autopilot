# MCP Connections — SE Demo Autopilot

> **Purpose**: Reference for all connected MCP (Model Context Protocol) servers in this environment.
> Agents should read this file to understand what tools are available and when to use each one.

---

## Overview

MCPs extend the agent's capabilities beyond file editing and bash commands. Each MCP server provides a set of specialized tools accessible during a session.

---

## Connected MCPs

### `mcp-adaptor` — Salesforce Org Access

**What it does**: Direct access to the connected Salesforce org — query data, read service definitions, browse files and directories, search docs.

**Key tools**:
| Tool | Use for |
|------|---------|
| `query` | Run SOQL/queries against the org |
| `query_construction` | Help building queries |
| `validate_search_query` | Validate a search query before running |
| `search` | Search across org data |
| `doc_search` | Search Salesforce documentation |
| `get_service_definition` | Get metadata/service definitions |
| `list_service_instances` | List available service instances |
| `get_activities` / `get_activities_by_id` | Retrieve activity records |
| `list_directory` / `read_file` | Browse org file structures |

**When to use**: Anytime you need to inspect org state, query records, or look up metadata without using the SF CLI.

---

### `browser` — Browser Automation

**What it does**: Full browser control — navigate to URLs, click elements, type text, take screenshots, read accessibility trees.

**Key tools**:
| Tool | Use for |
|------|---------|
| `browser_navigate` | Go to a URL |
| `browser_click` | Click an element |
| `browser_type` | Type into fields |
| `browser_screenshot` | Capture the current page |
| `browser_a11y_tree` | Read the page's accessibility tree (structured content) |
| `browser_list_tabs` | See open tabs |
| `browser_wait` | Wait for page state changes |
| `ui_annotate` / `ui_clear` | Annotate UI elements for reference |

**When to use**: 
- Salesforce Setup UI steps that can't be done via API/CLI (e.g., Data Stream sync, MC activation target creation)
- Verifying UI state after API operations
- Capturing screenshots for documentation/demos
- Navigating JS-heavy sites that WebFetch can't render

---

### `codesearch` — Code Search

**What it does**: Search source code across repositories — find symbols, trace history, view diffs and blame.

**Key tools**:
| Tool | Use for |
|------|---------|
| `search` | Find code by keyword/pattern |
| `blob` | Read file contents at a revision |
| `tree` | List directory contents |
| `blame` | See who changed what |
| `history` | View file/repo history |
| `commit` | Inspect a specific commit |
| `diff` | Compare changes |
| `list_hosts` | See available code hosts |

**When to use**: Researching how Salesforce platform code works, finding examples of API usage, tracing internal implementations.

---

### `columbo` — Error/Gack Investigation

**What it does**: Search, fetch, and analyze Salesforce gacks (internal errors) and stack traces.

**Key tools**:
| Tool | Use for |
|------|---------|
| `search_gacks` | Find gacks by criteria |
| `fetch_gack_details` | Get full details on a specific gack |
| `fetch_gacks_by_stacktrace` | Find related gacks |
| `fetch_bulk_gacks_by_stacktrace_ids` | Bulk fetch |
| `get_latest_accessible_gack` | Most recent gack you can see |
| `fetch_kodama_analysis` | Get AI-generated analysis of a gack |
| `parse_delphi_stack_trace` | Parse stack traces |
| `debug_delphi_request` / `debug_environment` | Debug tooling |
| `get_auth_status` / `refresh_auth` / `export_auth_env` | Auth management |

**When to use**: When Salesforce operations fail with cryptic errors and you need to understand what went wrong internally (especially Data Cloud or MC connector issues).

---

### `github` — GitHub

**What it does**: Interact with GitHub — view PRs, issues, checks.

**Key tools**:
| Tool | Use for |
|------|---------|
| `list_recent_viewer_prs` | See your recent PRs |

**When to use**: Checking PR status, reviewing changes, managing this project's repo.

**Note**: For most GitHub operations, the `gh` CLI via Bash is more capable.

---

### `gmail` — Gmail

**What it does**: Search and read Gmail messages.

**Key tools**:
| Tool | Use for |
|------|---------|
| `gmail_search` | Search emails by query |
| `gmail_get` | Read a specific email |

**When to use**: Finding Salesforce notification emails, MC send confirmations, approval requests, or any context shared via email.

---

### `google` — Google Workspace

**What it does**: Access Google Docs, Calendar, and Tasks.

**Key tools**:
| Tool | Use for |
|------|---------|
| `docs_get` | Read a Google Doc |
| `docs_search` | Search across Docs |
| `docs_create` | Create a new Doc |
| `docs_comments` | Read doc comments |
| `docs_revisions` | View revision history |
| `calendar_list` | List calendars |
| `calendar_events` | Get calendar events |
| `tasks_list_tasklists` | List task lists |
| `tasks_list` | List tasks in a list |
| `tasks_get` | Get specific task |
| `meeting_notes_search` | Search meeting notes |

**When to use**: Reading shared demo planning docs, checking meeting context, finding design decisions captured in Google Docs.

---

### `search` — Web Search

**What it does**: General web search (like Google).

**Key tools**:
| Tool | Use for |
|------|---------|
| `search` | Run a web search query |

**When to use**: Finding community solutions, Stack Exchange answers, third-party documentation. **NOT for official Salesforce docs** (use `platform-docs-get` skill instead — Salesforce sites return empty shells to normal fetchers).

---

### `slack` — Slack

**What it does**: Full Slack access — read/send messages, search channels, manage threads, read canvases.

**Key tools**:
| Tool | Use for |
|------|---------|
| `slack_search_public_and_private` | Search all accessible messages |
| `slack_search_public` | Search public channels only |
| `slack_read_channel` | Read recent messages in a channel |
| `slack_read_thread` | Read a specific thread |
| `slack_send_message` | Send a message |
| `slack_send_message_draft` | Draft a message (doesn't send) |
| `slack_schedule_message` | Schedule a future message |
| `slack_search_channels` | Find channels by name |
| `slack_search_users` | Find users |
| `slack_read_user_profile` | Read someone's profile |
| `slack_list_channel_members` | See who's in a channel |
| `slack_read_canvas` / `slack_create_canvas` / `slack_update_canvas` | Canvas operations |
| `slack_read_file` | Read uploaded files |
| `slack_add_reaction` / `slack_get_reactions` | Emoji reactions |
| `slack_mark_read` | Mark channel as read |
| `slack_search_emojis` | Find custom emojis |
| `slack_create_conversation` | Start a new DM/group |

**Auth status**: ⚠️ **Requires authentication** — must be authorized via connector settings before use.

**Key channels for this project**:
- `#help-sell-mc-next` — Marketing Cloud Next help
- `#help-csg-marketingcloud-next` — CSG MC Next support

**When to use**: Searching for known issues, asking for help when docs fail, finding tribal knowledge about MC/DC gotchas.

---

### `aisuite` — Python Sandbox

**What it does**: Execute Python code in a sandboxed environment with access to call other MCP tools via `mcp.call()`.

**Key tools**:
| Tool | Use for |
|------|---------|
| `python` | Run arbitrary Python code |

**When to use**: Data transformations, CSV processing, complex calculations, chaining multiple tool calls programmatically, anything that benefits from a scripting environment.

---

## MCP vs. Other Tools — When to Use What

| Need | Use |
|------|-----|
| Query Salesforce org data | `mcp-adaptor` → `query` |
| Run SF CLI commands | Bash → `sf` commands |
| Read official SF docs | Bash → `platform-docs-get` scripts (NOT WebFetch) |
| Manipulate files in this repo | Read/Write/Edit tools |
| Automate Salesforce UI | `browser` MCP |
| Search the web | `search` MCP or `WebFetch` |
| Search Slack for tribal knowledge | `slack` MCP (requires auth) |
| Investigate SF internal errors | `columbo` MCP |
| Find code examples | `codesearch` MCP |
| Run Python for data processing | `aisuite` MCP |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Slack tools return auth errors | User needs to authorize via connector settings |
| `mcp-adaptor` query fails | Check org alias is correct (`phil_master_sdo`) |
| `browser` page is blank | Some SF pages need login — check session state |
| `codesearch` returns nothing | Try different search terms; check `list_hosts` for available repos |
| Tool returns `InputValidationError` | Schema not loaded — call `ToolSearch` with `select:<tool_name>` first |
