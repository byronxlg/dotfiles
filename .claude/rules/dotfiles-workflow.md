Non-private Claude Code config (rules, skills, agents, hooks, statusline) and other dotfiles (`.config/`, `.vscode/`, `.zshrc`, `.tmux.conf`) are symlinked from `~/dotfiles` via GNU Stow.

- Edit these files in `~/dotfiles/`, not directly in `$HOME`
- Run `stow . --no-folding` from `~/dotfiles` after changes
- Never touch `~/.claude/settings.json` - it contains secrets and is not managed by stow
