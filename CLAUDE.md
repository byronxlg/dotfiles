## Dotfiles

This repo is managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory (`.config`, `.claude`, etc.) maps to `$HOME`.

### Stow usage

Always use `--no-folding` to create individual symlinks instead of symlinking entire directories:

```sh
stow . --no-folding
```

This prevents stow from replacing a real directory in `$HOME` with a symlink to the dotfiles directory, which would cause non-dotfile contents to appear in the repo.

### Host-specific files

Files that should be versioned but only active on one machine live under `hosts/<hostname>/` (excluded from the base stow via `.stow-local-ignore`). Stow the matching host package in addition to the base on that machine:

```sh
stow . --no-folding
stow -d hosts -t "$HOME" --no-folding "$(hostname)"
```

The host package mirrors the same `$HOME` layout for machine-specific configuration. The second invocation needs `-d hosts -t "$HOME"` because stow forbids slashes in a package name and otherwise defaults the target to the repo root. Other machines run only `stow .`, so those files are never symlinked there.

### Skills and rules

Skillfold manages installed skills, `~/.claude/rules/`, and the managed block in
`~/.codex/AGENTS.md`. These outputs are excluded from Stow. Personal sources live
in `byronxlg/skills`; edit and push them there. Dotfiles owns the manifest and
lockfile in `.config/skillfold/` through Stow.

Host-specific rules use exact `hosts` selectors in the manifest, not host Stow
packages. Read only installed instructions, not rule sources for other machines.
After source changes, run `skillfold update -g <name>`; after manifest changes,
run `skillfold install -g`. After pulling pins, run `skillfold install -g --frozen`.
Finish with `skillfold check -g`, and commit and push the task's dotfiles changes.
