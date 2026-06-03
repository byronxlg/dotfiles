---
name: obsidian
description: Read, search, create, and modify notes in Byron's Obsidian vaults by editing the markdown files directly. Use whenever the user mentions Obsidian, "my vault", "my notes", a daily note, a journal entry, a project note, an MOC, or asks to find/save/update anything in a knowledge base - even if the word "Obsidian" is not used. There is a global vault at ~/repos/obsidian/, but Byron uses multiple vaults and this skill is not limited to one. Covers the content-quality rules for note writing, frontmatter conventions, wikilinks, daily notes, the read/write policy, and how to avoid breaking the graph.
---

# Obsidian vaults

Byron keeps notes in Obsidian. Interact with a vault by reading and editing its markdown files directly with Read, Write, Edit, Glob, and Grep. There is no MCP server and no REST API in the loop - even if a vault has the `obsidian-local-rest-api` plugin installed, direct file editing is the method this skill uses because it is robust and does not depend on the app running.

This skill gives you the universal Obsidian mechanics and the user's content-quality rules. Anything that is true of only one vault (its folder layout, naming style, which plugins are installed, which domains it covers) you discover from that vault, not from this skill.

## Vaults

There is a global vault at `~/repos/obsidian/`, used by default when no other vault is in play. This skill is not limited to it - Byron uses multiple vaults, and some live inside project repos. A vault root is any directory containing a `.obsidian/` folder. When it is unclear which vault a request means, ask.

When listing or searching a vault, exclude `.obsidian/` and `.git/`:

```bash
fd -tf -e md . <vault-root> -E .obsidian -E .git
rg --type md "query" <vault-root> -g '!.obsidian' -g '!.git'
```

Most vaults are git repos and use the `obsidian-git` community plugin to auto-commit and sync. After meaningful edits, mention that a commit is pending, but do not commit unless asked.

## Content-quality rules

These apply to every note you write or edit, in every vault. The notes are a knowledge base, not a chat log - they must stay trustworthy when reread months later with no memory of this session.

- **Facts only, no commentary.** Record what is true, decided, or observed. Do not add encouragement, praise, editorializing, or filler ("this is a great approach", "interesting to note that..."). Neutral voice throughout.
- **No unvalidated claims.** Do not assert something as fact unless you have verified it. If you have not confirmed it, it does not go in the note as a statement of fact - it goes in as a TODO (see below) or is clearly marked as an inference.
- **Mark inferences as inferences.** When you write something you reasoned to rather than observed, say so ("likely", "appears to", "inferred from X") so a future reader can tell conclusions from evidence.
- **Cite the source when a claim has one.** Link the note, file, PR, URL, or command output the fact came from, so it can be re-checked. A claim with no traceable source is a candidate for a TODO instead.
- **Use TODO items for anything needing further investigation.** Unknowns, unverified hunches, follow-ups, and open questions become checkbox tasks, not prose assertions:

  ```markdown
  - [ ] TODO: confirm whether the retry logic actually backs off - read scheduler.py
  - [ ] TODO: open question - does the global vault path differ on the work laptop?
  ```

  Obsidian's native task search and the Tasks plugin both pick up `- [ ]` checkboxes, so they stay findable across the vault.
- **No fabrication.** Never invent file paths, dates, names, values, or links to fill a gap. If you do not know, write a TODO.

This skill's own prose follows these rules, and the global no-emoji / no-em-dash conventions.

## Read/write policy

A vault is used in one of two ways depending on where you are working. Apply the matching policy.

### Flow 1: In-vault session (cwd is inside a vault)

The user is here to curate the vault. Read anywhere; write wherever the user directs. No allowlist or confirmation gate - confirmation is friction when the user is explicitly working on the vault. The `obsidian-git` auto-commit history is the rollback layer if anything goes wrong.

### Flow 2: Out-of-vault session (cwd is a project repo, working on the project)

The vault is a context store and, by suggestion only, a destination for durable outcomes. These sessions are read-mostly; the user owns when and where to write. This applies whether the relevant vault is the global one or a vault embedded in the repo.

- **Read proactively**: the project note for the repo in the global vault, notes it links to, and any note relevant to the request.
- **Suggest-write only**: when a session produces a durable outcome (a decision, a pending TODO, a status change, a finding), suggest an update. Format: *"I'd add a `## Pending` section to `<path>` saying X - want me to?"* Write only after the user agrees.
- **Never write unsolicited** anywhere in a vault during a Flow 2 session. If a write feels warranted, suggest it; the user decides.

For both flows: never write to `.obsidian/`. Plugin and workspace state is easy to corrupt and not worth the risk.

## Discover the vault's conventions

Folder layout, naming style, installed plugins, and which domains a vault covers are per-vault facts. Discover them rather than assuming this skill's examples apply:

- **Layout and domains**: `ls` / `fd` the vault root. Place new notes under an existing folder that fits; do not scatter loose notes in the root.
- **Naming style**: look at sibling notes in the target folder and match what is there. Title Case with spaces is common, but it is not universal - some folders use kebab-case, PascalCase, or ISO dates. Match the neighbours, do not impose a single rule.
- **Installed plugins**: read `.obsidian/community-plugins.json` for the current set (it changes). Conventions like folder-notes and attachment handling below only apply if the relevant plugin or setting is present.
- **Attachment setting**: `.obsidian/app.json` -> `attachmentFolderPath` tells you where pasted files land.

## Universal Obsidian mechanics

These hold for any vault.

### Frontmatter

YAML frontmatter at the top, between `---` fences:

```yaml
---
created: 2026-05-01
tags: [project, agents]
status: active
aliases: [Project Index]
---
```

- `tags`: kebab-case or single words. Inline form (`tags: [a, b]`) is the common standard; block form (one per line) is for long lists. `moc` marks a map-of-content index note.
- `created`: ISO date (`2026-05-01`). Bases recognises it as a date type for sorting and filtering.
- `aliases`: inline `[x, y]` for short lists.
- Custom fields are fine - Obsidian Properties surfaces them automatically.
- When adding frontmatter to a note that lacks it, place it as the very first lines with no blank line before the opening `---`.
- **Frontmatter is the source of truth.** Do not restate frontmatter fields in a body table - the Properties UI renders them above the body and Bases queries them. A table that mirrors frontmatter is duplicate maintenance and will drift.

**Quote long integers and hex values as strings.** YAML parses unquoted `0xa96e...` as a number (yielding `0` for non-numeric hex) and unquoted huge integers (uint256-sized IDs) silently lose precision. Wrap blockchain identifiers, transaction hashes, and large numeric IDs in single quotes:

```yaml
token_id: '19929255357735608968567113701441639433303309211596766910631472055037903553483'
tx_hash: '0x323922c1...'
```

Plain numbers within Python's int range, decimals, and short strings do not need quoting.

### Wikilinks

Internal links use Obsidian wikilink syntax, not standard markdown links:

- `[[Note Name]]` - link to `Note Name.md` anywhere in the vault
- `[[Note Name|display text]]` - link with custom display text
- `[[Note Name#Heading]]` - link to a heading
- `[[Note Name#^block-id]]` - link to a block reference

Vaults typically use **shortest-path** resolution - `[[About Me]]` resolves to `About Me/About Me.md` if that filename is unique. Do not write the folder unless the filename is ambiguous. When renaming a note outside the app, search for and update all wikilinks pointing at the old name (the Obsidian UI does this automatically; manual edits do not).

### Tags

Inline tags use `#tag` form. Frontmatter `tags:` is preferred for canonical categorization; inline `#tag` for ad-hoc context inside prose.

### Body shape

After the frontmatter, an H1 matching the filename, then prose and sections:

```markdown
# Note Title

One-paragraph statement of what this note covers.

## Section

Section content.
```

### Renaming on a case-insensitive filesystem

macOS APFS is case-insensitive by default, so `git mv foo Foo` (any case-only rename) fails with `Invalid argument`. Two-step through a temp name:

```bash
git mv foo foo_tmp && git mv foo_tmp Foo
```

Same for plain `mv`. Verify with `ls` afterwards - the OS may silently no-op if it thinks the names already match.

## Conventions that depend on plugins

Apply these only if the vault has the relevant plugin (check `community-plugins.json`).

### Folder notes (folder-notes plugin)

A note named the same as its containing folder, placed inside it, becomes the folder note: clicking the folder opens that note. Pattern: `Foo/Foo.md`. When creating an overview/index for a folder, follow this pattern rather than a sibling `Foo.md` outside the folder or a generic `Overview.md` inside it.

A folder note grouping tagged entries should NOT carry the per-item tag itself, so base/dataview filters on that tag do not pick up the folder note. When a folder holds many similarly-shaped notes, let the folder note document the frontmatter schema in prose, embed a Bases view over the entries, and serve as the click-to-open index - one canonical source for the shape.

### Attachments

If `app.json` sets `attachmentFolderPath` (commonly `./_attachments`), pasted or dropped files land in `<note's folder>/_attachments/`. Use that one folder name across the vault for all referenced digital files - images, PDFs, GPX/KML, audio. Wikilink with shortest-path: `![[file.jpg]]` resolves as long as the filename is unique. Folders named `Assets/` may instead hold *notes about physical things the user owns* - check before treating one as an attachment dump.

### Bases (Bases core plugin)

Bases renders structured collections of notes that share a shape, preferred over hand-maintained tables. Each entry is a note with frontmatter properties; the view aggregates them. Render via an embedded ` ```base ` code block, or a sibling `.base` file embedded with `![[Foo.base]]`.

Minimum drop-in shape for a folder of leaf notes sharing a tag:

````markdown
```base
filters:
  and:
    - file.hasTag("<entry-tag>")
properties:
  created:
    displayName: Created
views:
  - type: table
    name: Notes
    order:
      - file.name
      - created
```
````

Syntax gotchas (learned the hard way):

- **Custom frontmatter properties are bare names** in `order`, `properties`, and filters - `brand`, not `note.brand`. The `note.` prefix is only valid in formulas. Built-in file properties keep `file.` (`file.name`, `file.mtime`, `file.inFolder("X")`, `file.hasTag("X")`).
- **View-level `filters` need an `and:`/`or:`/`not:` wrapper**, like the top-level `filters`. A bare list errors with `"filters" may only have one of an "and", "or", or "not" keys`.
- **Filter on tag, not folder**, when the folder also contains a folder note - otherwise the folder note appears in its own list.
- **Booleans** use unquoted `true`/`false`; filter as `field == true`.
- Opening a `.base` file directly in Obsidian renders the Bases UI and gives the clearest schema-error messages.

## Common tasks

### Find a note

```bash
fd -tf -e md "fragment" <vault-root> -E .obsidian
```

For ambiguous references ("the agents one"), grep titles and frontmatter:

```bash
rg --type md -l "^# .*[Aa]gents" <vault-root> -g '!.obsidian'
```

### Search note contents

```bash
rg --type md '\[\[Polymarket(\||\]|#)' <vault-root> -g '!.obsidian'
```

The trailing alternation matches `[[Polymarket]]`, `[[Polymarket|...`, and `[[Polymarket#...` without false-positiving on notes that merely start with "Polymarket".

### Create a note

1. Pick the right folder by listing the vault. If none fits and the user has not specified, ask.
2. Filename matches the H1 to display. Match the naming style of sibling notes. Avoid `:`, `/`, `\`, `?`, `*`, `<`, `>`, `|`, `#`, `[`, `]`, `^` - reserved or wikilink-confusing.
3. Start with frontmatter (at least `tags:`), then `# Title`, then content - obeying the content-quality rules.
4. If the note belongs in an existing MOC, offer to add a row; do not do it silently.

### Edit a note

Prefer Edit over Write for existing notes - it preserves the rest of the file. When updating frontmatter, do not reformat unrelated fields, match the vault's tag/alias form, and preserve trailing newlines and section spacing.

A markdown formatter may run on the vault and re-pad tables or canonicalize spacing on save. Do not hand-align markdown tables - the formatter will. Whitespace-only diffs coming back as notifications are the formatter, not a content change.

### Daily and dated notes

Daily-note conventions are per-vault. The Daily Notes core plugin may be enabled but unconfigured, and a vault may instead keep domain-scoped dated notes (e.g. a health log) rather than one canonical daily note. When the user asks for "today's daily note", clarify which one if ambiguous, and get today's date from the conversation's `currentDate` context, not the shell `date` - the user may be working as of a different date.

### MOCs (maps-of-content)

Notes tagged `moc` are index notes. Pick the children-index pattern by content shape:

- **Embedded base over a shared tag** - preferred when children are leaf notes sharing a per-item tag and growing over time. New entries auto-appear.
- **Hand-maintained markdown table** - when each row needs context not in frontmatter. Append a row when adding a note.
- **Hand-maintained wikilink list** - when the children are 1-3 sub-MOCs (a navigation index, not a dataset).

## Proactive project lookup

At the start of substantive work in a project repo, check the global vault for a project note before doing other work. Convention: `~/repos/obsidian/Projects/<repo-name>.md`, where `<repo-name>` is the cwd basename. Read it directly; a not-found error is the negative signal, handle it silently.

If the read succeeds, use the contents (decisions, conventions, pending TODOs, links) as context for the first substantive request. If it does not exist, continue without it - do not surface the absence unless asked, and do not create a note unsolicited. Skip this lookup entirely when the cwd is itself a vault root (the normal in-vault flow covers that). Strict path match only; do not fuzzy-search across folders.

## Things not to do

- **Do not edit anything in `.obsidian/`** unless explicitly asked. Plugin state, workspace layout, and graph settings live there and corrupt easily.
- **Do not rewrite wikilinks as standard `[text](path.md)` links.** It breaks the graph and backlinks.
- **Do not reformat YAML frontmatter** (inline -> block, reordering keys) on unrelated edits. The Properties UI is sensitive to shape.
- **Do not commit a vault** without being asked. The user has obsidian-git and may have work in progress.
- **Do not create notes in the vault root** unless they are daily notes or the user wants top-level placement.
- **Do not write commentary, praise, or unverified claims into a note.** Facts and TODOs only - see the content-quality rules.
