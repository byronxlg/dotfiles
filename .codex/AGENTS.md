# Shared personal instructions

Before starting work, read `~/.claude/CLAUDE.md` if present and every Markdown file under `~/.claude/rules/`. These are shared personal instructions for both Claude Code and Codex. Read only installed rules; do not load rules from other machines under `~/dotfiles/hosts/`.

Codex instructions and shared skills are also managed in `~/dotfiles/` via GNU Stow. Edit their repository sources and run `stow . --no-folding` after changes.

When working in a repository that only has Claude instructions, read applicable `CLAUDE.md` files from the repository root down to the working directory. Prefer `AGENTS.md` where both exist at the same level.

## Shared skill compatibility

- Shared skills live in `~/.agents/skills/` and link to their sources in `~/.claude/skills/`.
- In shared skill examples, `/skill-name` means invoke the corresponding Codex skill with `$skill-name`; `$ARGUMENTS` means the user's request and conversation context, not a literal shell variable.
- Map Claude tool names to available Codex tools by capability. Claude `allowed-tools` metadata does not configure Codex permissions. Never assume a tool or connector exists just because a shared skill mentions it.
- Use Codex's installed document, spreadsheet, presentation, PDF, and skill-creator skills for those tasks. Claude-specific versions are not linked.
