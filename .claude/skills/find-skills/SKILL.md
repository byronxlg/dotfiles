---
name: find-skills
description: Helps users discover and install agent skills when they ask questions like "how do I do X", "find a skill for X", "is there a skill that can...", or express interest in extending capabilities. This skill should be used when the user is looking for functionality that might exist as an installable skill.
allowed-tools: Bash(gh search *), Bash(gh api *), Bash(gh repo *), Bash(curl *), Bash(mkdir *), Bash(ls *), WebSearch
model: sonnet
---

# Find Skills

This skill searches for ready-made SKILL.md files and installs them locally.

Skills are SKILL.md files placed in `~/.claude/skills/<name>/`. Search uses two paths in parallel: GitHub code search and web search.

## How to find skills

### Step 1: Search both paths in parallel

**GitHub code search:**
```bash
gh search code --filename SKILL.md "<query>" --json repository,path,url --limit 20
```

**Web search:**
```
site:github.com SKILL.md "<query>" claude code skill
```

Combine results across both paths. Deduplicate by `owner/repo + path` — if the same file appears from both searches, keep one entry.

### Step 2: Filter out aggregators and mirrors

Before fetching content, discard obvious junk:
- Repos whose name or description suggests they are aggregators, mirrors, or scrapers (e.g. `skills_feed`, `awesome-claude-skills`, `claude-skill-registry`, `skills-md`)
- Repos that appear multiple times with identical descriptions but different owners - keep only the one with the most stars

Fetch star counts for surviving candidates:
```bash
gh repo view <owner/repo> --json stargazerCount,description,isFork
```

Prefer repos that are not forks. Treat star counts as a rough quality signal: 500+ is a good sign, under 50 is worth noting to the user. Deprioritize but don't discard low-star repos from unknown authors — surface them at the bottom of the list with a note.

### Step 3: Fetch SKILL.md content

For each candidate, compute the raw URL by replacing `github.com` with `raw.githubusercontent.com` and dropping `/blob`:

```
https://github.com/<owner>/<repo>/blob/<sha>/<path>
->
https://raw.githubusercontent.com/<owner>/<repo>/<sha>/<path>
```

The SHA is preserved as-is — do not substitute `main` or any branch name.

Fetch the content and check it is non-empty before proceeding:
```bash
content=$(curl -sfL "<raw-url>")
# abort this candidate if content is empty or curl failed
```

Extract the `description:` field from the YAML frontmatter of non-empty results.

### Step 4: Present options

Show the user a ranked list (higher stars first within each quality tier):
- Skill name (last directory component before SKILL.md)
- Description (from frontmatter)
- Source repo and star count
- GitHub URL

Example:
```
gog (steipete/clawdis, 2.1k stars)
Google Workspace CLI for Gmail, Calendar, Drive, Contacts, Sheets, and Docs.
https://github.com/steipete/clawdis/tree/main/skills/gog
```

### Step 5: Install

If the user wants to install a skill:

1. Determine the skill name from the path (e.g. `skills/gog/SKILL.md` -> `gog`)
2. If there's a naming conflict with an already-installed skill, ask the user to confirm or pick a different name
3. Install:

```bash
mkdir -p ~/.claude/skills/<name>
curl -sfL "<raw-url>" -o ~/.claude/skills/<name>/SKILL.md
```

4. Verify the install succeeded: check the file exists and is non-empty (`ls -la ~/.claude/skills/<name>/SKILL.md`). If empty or missing, report the failure — do not claim success.

## Listing installed skills

To show what's already installed:

```bash
ls ~/.claude/skills/
```

Then read each `SKILL.md` to show the name and description.

## When nothing is found

Say so clearly and offer to create a new skill with the `skill-creator` skill.
