# Overrides for Plugins
alias cat='bat'
alias vi='nvim'
alias ls='lsd'


# Frequently used commands
alias type='type -a'
alias md='mkdir -p'
alias agr='alias | grep'
alias cls='clear'
alias cx='chmod +x'

alias l='ls -l'
alias la='ls -a'
alias lsa='ls -la'
alias lt='ls --tree'

alias jqc='jq --color-output'

# TMUX project launcher
alias tmux-project='bash ~/.tmux-session.sh'

# Claude code commands
alias claudd='claude --dangerously-skip-permissions'


claude-toggle-aws() {
  local settings="$HOME/.claude/settings.json"
  local current
  current=$(jq -r '.env.CLAUDE_CODE_USE_BEDROCK // "0"' "$settings")

  if [[ "$current" == "1" ]]; then
    jq 'del(.awsAuthRefresh)
      | del(.env.CLAUDE_CODE_USE_BEDROCK, .env.AWS_REGION, .env.AWS_PROFILE,
            .env.ANTHROPIC_MODEL, .env.ANTHROPIC_DEFAULT_SONNET_MODEL,
            .env.ANTHROPIC_DEFAULT_HAIKU_MODEL, .env.ANTHROPIC_DEFAULT_OPUS_MODEL,
            .env.CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS)' \
      "$settings" > "${settings}.tmp" && mv "${settings}.tmp" "$settings"
    echo "Claude: Anthropic API"
  else
    jq '.awsAuthRefresh = "aws-azure-login"
      | .env.CLAUDE_CODE_USE_BEDROCK = "1"
      | .env.AWS_REGION = "us-east-1"
      | .env.AWS_PROFILE = "default"
      | .env.ANTHROPIC_MODEL = "global.anthropic.claude-sonnet-4-6"
      | .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "global.anthropic.claude-sonnet-4-6"
      | .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "global.anthropic.claude-haiku-4-5-20251001-v1:0"
      | .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "global.anthropic.claude-opus-4-7"
      | .env.CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1"' \
      "$settings" > "${settings}.tmp" && mv "${settings}.tmp" "$settings"
    echo "Claude: AWS Bedrock"
  fi
}
