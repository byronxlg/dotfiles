Claude Code config (`settings.json`, rules, skills, agents, hooks, statusline) and other dotfiles (`.config/`, `.vscode/`, `.zshrc`, `.zshenv`, `.tmux.conf`) are symlinked from `~/dotfiles` via GNU Stow.

- Edit these files in `~/dotfiles/`, not directly in `$HOME`
- Run `stow . --no-folding` from `~/dotfiles` after changes
- Claude Code secrets (API keys, Bedrock creds, etc.) live in `~/.zshenv.local`, gitignored and outside this repo. `~/.claude/settings.json` itself is stow-managed and free of secrets.
