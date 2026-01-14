# Overrides for Plugins
alias cat='bat'
alias vi='nvim'
alias vim='nvim'

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

alias jq='jq --color-output'

# TMUX project launcher
alias tmux-project='[[ -f .tmux-session.sh ]] && bash .tmux-session.sh || echo "No .tmux-session.sh found"'

s1# Claude code commands
alias claude='claude --dangerously-skip-permissions'
alias cl='claude'
alias cq='claude --print'
alias cc='claude --continue'
alias cr='claude --resume'