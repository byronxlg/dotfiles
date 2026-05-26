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

# Switch Claude to AWS Bedrock
# Usage: claude-use-aws [bearer-token]
claude-use-aws() {
  local env_file="$HOME/.zshenv.local"
  export CLAUDE_CODE_USE_BEDROCK=1
  export AWS_REGION=us-east-1
  export AWS_PROFILE=default
  export ANTHROPIC_MODEL=global.anthropic.claude-sonnet-4-6
  export ANTHROPIC_DEFAULT_SONNET_MODEL=global.anthropic.claude-sonnet-4-6
  export ANTHROPIC_DEFAULT_HAIKU_MODEL=global.anthropic.claude-haiku-4-5-20251001-v1:0
  export ANTHROPIC_DEFAULT_OPUS_MODEL=global.anthropic.claude-opus-4-6-v1
  export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
  sed -i '' '/^export CLAUDE_CODE_USE_BEDROCK=/d
/^export AWS_REGION=/d
/^export AWS_PROFILE=/d
/^export ANTHROPIC_MODEL=/d
/^export ANTHROPIC_DEFAULT_SONNET_MODEL=/d
/^export ANTHROPIC_DEFAULT_HAIKU_MODEL=/d
/^export ANTHROPIC_DEFAULT_OPUS_MODEL=/d
/^export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=/d
/^export AWS_BEARER_TOKEN_BEDROCK=/d' "$env_file"
  cat >> "$env_file" <<'EOF'
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export AWS_PROFILE=default
export ANTHROPIC_MODEL=global.anthropic.claude-sonnet-4-6
export ANTHROPIC_DEFAULT_SONNET_MODEL=global.anthropic.claude-sonnet-4-6
export ANTHROPIC_DEFAULT_HAIKU_MODEL=global.anthropic.claude-haiku-4-5-20251001-v1:0
export ANTHROPIC_DEFAULT_OPUS_MODEL=global.anthropic.claude-opus-4-6-v1
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
EOF
  if [[ -n "$1" ]]; then
    export AWS_BEARER_TOKEN_BEDROCK="$1"
    echo "export AWS_BEARER_TOKEN_BEDROCK='$1'" >> "$env_file"
  fi
  echo "Claude: AWS Bedrock"
}

# Switch Claude to Anthropic API
claude-use-anthropic() {
  local env_file="$HOME/.zshenv.local"
  unset CLAUDE_CODE_USE_BEDROCK AWS_REGION AWS_PROFILE \
        ANTHROPIC_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL \
        ANTHROPIC_DEFAULT_HAIKU_MODEL ANTHROPIC_DEFAULT_OPUS_MODEL \
        CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS AWS_BEARER_TOKEN_BEDROCK
  sed -i '' '/^export CLAUDE_CODE_USE_BEDROCK=/d
/^export AWS_REGION=/d
/^export AWS_PROFILE=/d
/^export ANTHROPIC_MODEL=/d
/^export ANTHROPIC_DEFAULT_SONNET_MODEL=/d
/^export ANTHROPIC_DEFAULT_HAIKU_MODEL=/d
/^export ANTHROPIC_DEFAULT_OPUS_MODEL=/d
/^export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=/d
/^export AWS_BEARER_TOKEN_BEDROCK=/d' "$env_file"
  echo "Claude: Anthropic API"
}

# bun completions
[ -s "/Users/byron.smith/.bun/_bun" ] && source "/Users/byron.smith/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
