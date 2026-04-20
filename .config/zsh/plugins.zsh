HOMEBREW_PREFIX=${HOMEBREW_PREFIX:-/opt/homebrew}

# ZSH Syntax Highlighting
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ZSH Auto Suggestions
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Shell Completions
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(uv generate-shell-completion zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh