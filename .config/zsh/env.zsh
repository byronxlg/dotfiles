export BAT_THEME="Catppuccin Mocha"

# SSH does not forward COLORTERM, so Rich/Textual TUIs fall back to 256 colors
if [[ -n "$SSH_CONNECTION" && -z "$COLORTERM" ]]; then
    export COLORTERM=truecolor
fi

# Headless SSH sessions can arrive with no locale; keep UTF-8 box drawing
[[ -z "$LANG" ]] && export LANG=en_NZ.UTF-8

# fzf: use fd so .env shows but ~/.config/fd/ignore filters out noise dirs
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --no-ignore-vcs'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --no-ignore-vcs'
