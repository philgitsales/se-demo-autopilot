# Salesforce CLI — Connect to Your SDO

> **Purpose**: Get the Salesforce CLI (`sf`) installed and authenticated to your SDO org so you can run API commands from the terminal.
> **Time**: ~5 minutes
> **Manual Steps**: 2 (install + browser login)

---

## Overview

The Salesforce CLI is how this project talks to Data Cloud and the CRM APIs. Once authenticated, your refresh token persists indefinitely (until revoked), so this is a one-time setup per org.

---

## Prerequisites

- A Salesforce SDO org (or any org you have admin access to)
- Node.js installed (v18+) — needed for the CLI
- A web browser for the OAuth login flow

---

## Step 1: Install the Salesforce CLI

Pick one:

```bash
# Option A: npm (works everywhere)
npm install -g @salesforce/cli

# Option B: Homebrew (macOS)
brew install sf
```

Verify it installed:

```bash
sf --version
# Should output something like: @salesforce/cli/2.x.x ...
```

---

## Step 2: Authenticate to Your SDO Org

This opens a browser where you log in with your Salesforce credentials:

```bash
sf org login web --alias my_sdo --instance-url https://login.salesforce.com
```

**What happens:**
1. Browser opens to Salesforce login
2. You enter your SDO username/password
3. You authorize the "Salesforce CLI" connected app
4. Browser shows a success message — you can close it
5. Terminal confirms: `Successfully authorized <username> with org ID 00D...`

> **Tip**: Use `--instance-url https://test.salesforce.com` if authenticating to a sandbox.

---

## Step 3: Verify the Connection

```bash
# List all authenticated orgs
sf org list

# Test an API call against your org
sf api request rest "/services/data/" -o my_sdo
```

You should see a JSON array of available API versions.

---

## Step 4 (Optional): Set as Default Org

If you don't want to pass `-o my_sdo` on every command:

```bash
sf config set target-org my_sdo
```

---

## How This Project Uses It

All SF CLI commands in this project use the `-o` flag to target a specific org:

```bash
sf api request rest "/services/data/v64.0/ssot/segments" -o phil_master_sdo
```

The alias `phil_master_sdo` was created during the `sf org login web` step above.

---

## Where Credentials Are Stored

The CLI stores auth tokens in your home directory:

```
~/.sf/        # Primary config & auth state
~/.sfdx/      # Legacy path (still referenced for some auth)
```

**No Salesforce org credentials are stored in this repo.** The auth lives entirely on your local machine.

---

## Key IDs (phil_master_sdo)

| Item | Value | Notes |
|------|-------|-------|
| Org Alias | `phil_master_sdo` | Used with `-o` flag |
| Instance URL | (check with `sf org display -o phil_master_sdo`) | Your org's My Domain URL |
| Username | (check with `sf org display -o phil_master_sdo`) | Your SDO login |

---

## Other Auth Methods (for CI / Automation)

| Method | Command | Use Case |
|--------|---------|----------|
| JWT Bearer | `sf org login jwt --client-id <key> --jwt-key-file server.key --username <user>` | CI/CD pipelines (no browser) |
| Access Token | `sf org login access-token --instance-url <url>` | If you already have a token |
| SFDX Auth URL | `sf org login sfdx-url --sfdx-url-file authUrl.txt` | Sharing auth between machines |

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| `sf: command not found` | CLI not installed or not in PATH | Run `npm install -g @salesforce/cli` again |
| Browser doesn't open | Headless environment / WSL | Use `sf org login device` for device code flow |
| "Invalid grant" after a while | Refresh token revoked (org policy, password change, admin revoke) | Re-run `sf org login web --alias my_sdo` |
| Wrong org | Alias mismatch | Check `sf org list` for your aliases |
| `ECONNREFUSED` on API calls | Instance URL wrong or org is down | Check `sf org display -o my_sdo` for the correct URL |
| `ERROR: No authorization found` | Never authenticated or token file deleted | Re-run `sf org login web` |

---

## Quick Reference

```bash
# See all connected orgs
sf org list

# See details for a specific org
sf org display -o my_sdo

# Open the org in a browser
sf org open -o my_sdo

# Log out / remove an org connection
sf org logout -o my_sdo

# Make a REST API call
sf api request rest "/services/data/v64.0/sobjects" -o my_sdo

# Make a SOQL query
sf data query --query "SELECT Id, Name FROM Account LIMIT 5" -o my_sdo
```
