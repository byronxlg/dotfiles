---
name: obsidian
description: Read, search, create, and modify notes in Byron's Obsidian vault by editing the markdown files directly. Use whenever the user mentions Obsidian, "my vault", "my notes", a daily note, a journal entry, a project note, an MOC, or asks to find/save/update anything in their personal knowledge base — even if the word "Obsidian" is not used. Also use when the user asks to set up, wire up, or connect Claude Desktop (or "the desktop app") to the vault — see the "Setting up Claude Desktop" section. Covers vault layout, frontmatter conventions, wikilinks, daily notes, Claude Desktop MCP config, and how to avoid breaking the graph.
---

# Obsidian vault

The user keeps an Obsidian vault on this machine. Interact with it by reading and editing the markdown files directly with Read, Write, Edit, Glob, and Grep — there is no MCP server and no REST API in the loop. This skill exists to give you the layout, conventions, and gotchas so edits look native and don't corrupt the graph.

## Locations

- **Vault root**: `~/repos/obsidian/Byron/`
- **Per-vault config**: `~/repos/obsidian/Byron/.obsidian/`
  - `app.json`, `core-plugins.json`, `community-plugins.json`, `appearance.json`, `graph.json`, `workspace.json`
  - `plugins/` — community plugin directories (check `community-plugins.json` for the current set; it changes)
- **Global Obsidian config**: `~/Library/Application Support/obsidian/`
  - `obsidian.json` — registry of known vaults (ID -> path)
  - The rest is Electron app state (caches, cookies, logs); ignore unless debugging the app itself
- **Vault is a git repo**: `~/repos/obsidian/Byron/.git/` exists and the `obsidian-git` community plugin syncs it. After meaningful edits, mention that a commit is pending — but do not commit unless asked.

When listing or searching the vault, exclude `.obsidian/` and `.git/`. Example:

```bash
fd -tf -e md . ~/repos/obsidian/Byron -E .obsidian -E .git
rg --type md "query" ~/repos/obsidian/Byron -g '!.obsidian' -g '!.git'
```

## Setting up Claude Desktop

When the user asks to wire Claude Desktop up to this vault, configure the filesystem MCP server in Claude Desktop's config so the desktop app can read and write the vault's markdown files. Steps:

1. **Config file**: `~/Library/Application Support/Claude/claude_desktop_config.json`. Create it if missing (parent dir always exists once Claude Desktop has launched at least once).

2. **Read the existing config first** with the Read tool. The file may already have `mcpServers` entries for other servers — preserve them. If the file doesn't exist, treat it as `{}`.

3. **Add an `obsidian-vault` entry** under `mcpServers`. The shape:

   ```json
   {
     "mcpServers": {
       "obsidian-vault": {
         "command": "npx",
         "args": [
           "-y",
           "@modelcontextprotocol/server-filesystem",
           "~/repos/obsidian/Byron"
         ]
       }
     }
   }
   ```

   Use the Edit tool for targeted insertion when other entries exist. If the file is empty or `{}`, use Write with the full structure above. Don't reformat unrelated entries.

   **Path must be absolute when written.** Claude Desktop spawns the MCP server as a subprocess without shell expansion, so `~` is passed as a literal string and the filesystem server fails to find the directory. Resolve `~` to the actual home path (e.g. via `$HOME` at write time) before inserting into the JSON. The example above shows `~` for readability across machines, but the value on disk must be expanded.

4. **Don't add an MCP entry that already exists.** If `obsidian-vault` is already in `mcpServers`, check whether the path still points at `~/repos/obsidian/Byron`. If it matches, report back that it's already wired up. If it differs, ask before overwriting — the user may have moved their vault.

5. **Restart Claude Desktop** so it picks up the new config. The menu-bar close doesn't fully quit it; it has to be Cmd+Q'd. Run:

   ```bash
   osascript -e 'tell application "Claude" to quit'
   sleep 2
   open -a Claude
   ```

   If `osascript` reports the app isn't running, that's fine — just `open -a Claude`.

6. **Tell the user what to expect**: after restart, the filesystem tools (read_file, write_file, edit_file, list_directory, search_files, etc.) appear under Claude Desktop's tools menu, scoped to the vault directory. Suggest they verify by asking Claude Desktop to list a folder in the vault.

### Caveats

- The config file may contain secrets (API tokens for other MCP servers). Don't echo or paste its contents into the conversation casually, and don't commit it. It is not stow-managed.
- Claude Desktop's MCP support requires a recent version (late 2024 or newer). If MCP tools don't appear after restart, check `Claude > Settings > Developer` for an MCP servers panel — its absence means the install is too old.
- Editing the config with `jq` should use `command jq -M` (monochrome, alias-bypassing) and write to a temp file before `mv`-ing into place. Aliases or color-output settings can otherwise inject ANSI escape codes into the redirected output and corrupt the JSON.

## Vault conventions

Top-level folders group notes by domain. Prefer placing new notes under an existing folder if one fits; don't scatter loose notes in the vault root. Discover the current layout with `ls` / `fd` rather than relying on this skill — it changes often.

### Naming

File and folder names use **Title Case with spaces** (e.g. `About Me.md`, `Me Today Magnesium 875.md`). Not kebab-case, not snake_case. Match this for any new files or folders.

### Renaming on a case-insensitive filesystem

macOS's default APFS is case-insensitive, so `git mv foo Foo` (or any case-only rename) fails with `Invalid argument`. Two-step through a temp name:

```bash
git mv foo foo_tmp && git mv foo_tmp Foo
```

Same applies to `mv`. Verify with `ls` afterwards because the OS may silently no-op if it thinks the names match.

### Folder Notes (community plugin)

The user runs the Folder Notes plugin. Convention: a note named the same as its containing folder, placed **inside** the folder, becomes the folder note — clicking the folder in the file explorer opens that note. Pattern: `Foo/Foo.md`.

When creating an overview/index for a folder, follow this pattern rather than a sibling `Foo.md` outside the folder, or a generic `Overview.md` inside it. Folder notes should NOT carry the per-item tag used by their entries (e.g. a folder note grouping `supplement`-tagged entries should not be tagged `supplement`), so that base/dataview filters using that tag don't pick up the folder note itself.

## Note conventions

Notes follow a consistent shape. Match it when creating or editing.

### Frontmatter

YAML frontmatter at the top, between `---` fences. Common fields seen in this vault:

```yaml
---
tags:
  - project
  - agents
status: active
aliases:
  - Project Index
tech:
  - Bash
  - Markdown
repo: ~/repos/skills
---
```

- `tags`: list, kebab-case or single words. `moc` marks a map-of-content (index note).
- `status`: `active`, `archive`, `complete` — used on project notes.
- `aliases`: alternate names that resolve as wikilink targets.
- Custom fields like `tech`, `repo`, etc. are fine — Obsidian Properties surfaces them automatically. Use list form for multi-value fields (one item per `-` line), not inline arrays.

When adding frontmatter to a note that lacks it, place it as the very first lines of the file with no blank line before the opening `---`.

### Body

After the frontmatter, an H1 matching the filename, then prose and sections:

```markdown
# Skills

Collection of Claude Code skills offering two main frameworks.

## Agent Team

Multi-agent coordination with defined roles ...
```

### Wikilinks

Internal links use Obsidian wikilink syntax, not standard markdown links:

- `[[Note Name]]` — link to `Note Name.md` anywhere in the vault
- `[[Note Name|display text]]` — link with custom display text
- `[[Note Name#Heading]]` — link to a specific heading
- `[[Note Name#^block-id]]` — link to a block reference

The vault uses **shortest-path** link resolution — `[[Skills]]` resolves to `Projects/Skills.md` because that filename is unique. Don't write the folder unless the filename is ambiguous. When renaming a note, search for and update all wikilinks pointing at the old name (Obsidian's UI does this automatically; you have to do it manually when editing files outside the app).

### Tags

Inline tags use `#tag` form (e.g. `#agents`, `#claude-code`). Frontmatter `tags:` is preferred for canonical categorization; inline tags for ad-hoc context inside prose.

## Common tasks

### Find a note

```bash
fd -tf -e md "fragment" ~/repos/obsidian/Byron -E .obsidian
```

If the user names a note ambiguously ("the agents one"), grep titles and frontmatter:

```bash
rg --type md -l "^# .*[Aa]gents" ~/repos/obsidian/Byron -g '!.obsidian'
```

### Search note contents

Use `rg` with `--type md` and the standard exclusions. For wikilink references to a specific note:

```bash
rg --type md '\[\[Skills(\||\]|#)' ~/repos/obsidian/Byron -g '!.obsidian'
```

The trailing alternation matches `[[Skills]]`, `[[Skills|...`, and `[[Skills#...`, so it doesn't false-positive on notes that start with "Skills".

### Create a note

1. Pick the right folder. If none fits and the user hasn't specified, ask.
2. Filename matches the H1 the user wants displayed. Spaces are fine; Obsidian handles them. Avoid `:`, `/`, `\`, `?`, `*`, `<`, `>`, `|`, `#`, `[`, `]`, `^` in filenames — they are reserved or confuse wikilinks.
3. Start with frontmatter (at least `tags:`), then `# Title`, then content.
4. After creating, if the note belongs in an existing MOC (e.g. a project note belongs in `Projects/Projects.md`), offer to add a row to the MOC's table — don't do it silently.

### Edit a note

Prefer Edit over Write for existing notes — preserves the rest of the file untouched. When updating frontmatter:
- Don't reformat unrelated fields.
- Keep list-form for multi-value fields.
- Preserve trailing newlines and section spacing.

### Daily notes

The Daily Notes core plugin is enabled but not configured, so it uses defaults:
- Location: vault root (no folder specified)
- Format: `YYYY-MM-DD.md`
- Template: none

If the user asks to create or open today's daily note, the path is `~/repos/obsidian/Byron/<YYYY-MM-DD>.md`. Get today's date from the conversation's `currentDate` context, not from `date` on the shell, since the user may have stated a different working date.

### MOCs (maps-of-content)

Notes tagged `moc` are index notes — usually a header per category and a markdown table of `[[Note]] | description | status` rows. `Projects/Projects.md` is the canonical example. When adding a note that belongs in an MOC, append a row in the appropriate section rather than creating a new MOC.

### Bases (database views)

The Bases core plugin is the preferred way to render structured collections of notes that share a shape, over hand-maintained markdown tables. Each entry is its own note with frontmatter properties; the Bases view aggregates them.

Two ways to render a base:

- **Embedded `base` code block** in any markdown file.
- **Sibling `.base` file** embedded via `![[Foo.base]]`. Use as a fallback if a code block won't render in the user's Obsidian version, or when the same view is reused on multiple pages.

Working code-block example:

````markdown
```base
filters:
  and:
    - file.hasTag("supplement")
properties:
  brand:
    displayName: Brand
  compound:
    displayName: Compound
  daily_dose:
    displayName: Daily dose
  currently_doing:
    displayName: Doing
views:
  - type: table
    name: All
    order:
      - file.name
      - brand
      - compound
      - daily_dose
      - currently_doing
  - type: table
    name: Currently doing
    filters:
      and:
        - currently_doing == true
    order:
      - file.name
      - brand
      - compound
      - daily_dose
```
````

Syntax gotchas (all learned the hard way):

- **Custom frontmatter properties are bare names** in `order`, `properties`, and filter expressions — `brand`, not `note.brand`. The `note.` prefix is only valid in formulas. Built-in file properties keep their `file.` prefix (`file.name`, `file.mtime`, `file.inFolder("X")`, `file.hasTag("X")`).
- **View-level `filters` need an `and:`/`or:`/`not:` wrapper**, just like top-level `filters`. A bare list under view `filters:` errors with `"filters" may only have one of an "and", "or", or "not" keys`.
- **Filter on tag, not folder**, when the folder also contains a folder note. Otherwise the folder note appears in its own list. `file.hasTag("entry-tag")` works as long as the folder note doesn't carry that same tag.
- **Booleans** in frontmatter use unquoted `true`/`false`; filter as `currently_doing == true`.
- A `.base` file's name and path show in the file explorer like any note. Opening it directly in Obsidian renders the Bases UI and is the easiest way to debug schema errors — error messages there are clearer than anything in markdown preview.

### Attachments

Configured via `app.json` → `attachmentFolderPath: "./attachments"` (i.e. "In subfolder under current folder", subfolder name `attachments`). Pasting/dropping an image into a note creates `<note's folder>/attachments/<file>`.

When adding an attachment manually (e.g. via `curl`), put it in the `attachments/` subfolder next to the note that references it. Wikilink with shortest-path: `![[file.jpg]]` resolves correctly as long as the filename is unique in the vault.

## Plugins worth knowing about

Core plugins enabled (besides the obvious editor ones):
- **Templates** — template files would live wherever the user has configured (no config yet, so unused).
- **Bookmarks** — stored in `.obsidian/bookmarks.json` if used.
- **Bases** — actively used. See the "Bases" section under common tasks for syntax that actually works in this vault.
- **Sync** — Obsidian's first-party sync. Toggle is on but the user also runs git via `obsidian-git`, so don't assume Sync is the source of truth.

Community plugins (check `community-plugins.json` for the current list; entries here are the ones with conventions worth knowing):
- **obsidian-git** — auto-commits and pulls. The vault is a real git repo; `cd ~/repos/obsidian/Byron && git status` works. Don't run destructive git commands here without asking.
- **folder-notes** — enables the folder-note convention described under "Vault conventions". If this plugin gets uninstalled, the `Foo/Foo.md` files still work as plain notes; they just lose the click-folder-to-open behavior.

## Things not to do

- **Don't edit anything in `.obsidian/`** unless the user explicitly asks. Plugin state, workspace layout, and graph settings live there and are easy to corrupt.
- **Don't rewrite wikilinks as standard `[text](path.md)` links.** It breaks Obsidian's graph and backlinks.
- **Don't reformat YAML frontmatter** (e.g. inline -> block, reordering keys) on unrelated edits. The Properties UI is sensitive to shape.
- **Don't commit the vault** without being asked. The user has obsidian-git for that and may have uncommitted work in progress.
- **Don't create notes in the vault root** unless they're daily notes or the user specifically wants top-level placement.
