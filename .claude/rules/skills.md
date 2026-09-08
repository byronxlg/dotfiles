# Skill management

Skillfold manages personal skills for Claude Code and Codex. Dotfiles owns
`~/.config/skillfold/skillfold.yaml` and `~/.config/skillfold/skillfold.lock` through Stow.
Installed files in `~/.claude/skills` and `~/.agents/skills` are generated.

When a task changes Skillfold-managed skills, apply the changes yourself before
finishing; do not leave installation as a manual step for Byron. `add`, `remove`,
and `update` already install their changes. After editing the manifest directly,
run `skillfold install -g`; after pulling a changed manifest/lockfile, run
`skillfold install -g --frozen`. Finish with `skillfold check -g` and commit and
push the task's dotfiles changes. Run this as part of skill changes, not on every
agent startup.

- Personal sources belong in `byronxlg/skills`; edit and push them there.
- Import third-party skills from their upstream GitHub or npm source with
  `skillfold add -g <source>`. Include supporting files by importing the skill directory.
- Update a source pin deliberately with `skillfold update -g <name>`, then run
  `skillfold check -g` and commit and push the task's dotfiles manifest/lock changes.
- Skills inherit `targets: [claude, codex]`; restrict an agent-specific skill with
  a mapping containing `source` and `targets: [claude]` or `targets: [codex]`.
- Reproduce the pinned selection with `skillfold install -g --frozen`.
- Plugin-bundled and Codex system skills remain managed by their installers.
