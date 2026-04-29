export BAT_THEME="Catppuccin Mocha"

# fzf: use fd so .env shows but ~/.config/fd/ignore filters out noise dirs
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --no-ignore-vcs'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --no-ignore-vcs'
