# ZSH Syntax Highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ZSH Auto Suggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Shell Completions
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(uv generate-shell-completion zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh