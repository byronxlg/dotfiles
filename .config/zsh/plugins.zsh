# ZSH Syntax Highlighting
if [[ "$OSTYPE" == "darwin"* ]]; then
    source "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ZSH Auto Suggestions
if [[ "$OSTYPE" == "darwin"* ]]; then
    source "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
else
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Shell Completions
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
[[ -x "$HOME/.local/bin/uv" ]] && eval "$($HOME/.local/bin/uv generate-shell-completion zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh