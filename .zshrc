#!/bin/bash
# compinit: run full audit only once a day; otherwise use the cached dump
autoload -Uz compinit
if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

unsetopt beep

# Remove RPROMPT spacing
ZLE_RPROMPT_INDENT=0

# History
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Zstyle
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==02=01}:${(s.:.)LS_COLORS}")'

# Run all zsh files
for file in $HOME/dotfiles/.config/zsh/*.zsh; do
    source $file
done

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Set colours
export LS_COLORS="$(vivid generate catppuccin-mocha)"


# vscode / starship fix to remove extra venv label
export VIRTUAL_ENV_DISABLE_PROMPT=1

# PATH
PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
PATH="$HOME/.local/bin:$PATH"

# Source zshrc
alias restart-zsh='exec zsh'

# Run local zshrc if it exists
[ -f ~/.local_zshrc.sh ] && source ~/.local_zshrc.sh

# bun completions
[ -s "/Users/byron.smith/.bun/_bun" ] && source "/Users/byron.smith/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
