# Skill management

Skillfold manages personal skills for Claude Code and Codex. Dotfiles owns
`~/.claude/skillfold.yaml` and `~/.claude/skillfold.lock` through Stow.
Installed files in `~/.claude/skills` and `~/.agents/skills` are generated.

- Personal sources belong in `byronxlg/skills`; edit and push them there.
- Import third-party skills from their upstream GitHub or npm source with
  `skillfold add -g <source>`. Include supporting files by importing the skill directory.
- Update a source pin deliberately with `skillfold update -g <name>`, then run
  `skillfold check -g` and commit and push the task's dotfiles manifest/lock changes.
- Skills inherit `targets: [claude, codex]`; restrict an agent-specific skill with
  a mapping containing `source` and `targets: [claude]` or `targets: [codex]`.
- Reproduce the pinned selection with `skillfold install -g --frozen`.
- Plugin-bundled and Codex system skills remain managed by their installers.
