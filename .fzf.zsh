# Setup fzf - shell integration (key bindings + completion).
# Portable across machines: prefer `fzf --zsh` (fzf >= 0.48), else source the
# example scripts from whichever location this platform ships them in.
if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    for _fzf_dir in \
      "$(brew --prefix 2>/dev/null)/opt/fzf/shell" \
      /usr/share/doc/fzf/examples \
      /usr/share/fzf \
      /opt/homebrew/opt/fzf/shell; do
      [[ -r "$_fzf_dir/key-bindings.zsh" ]] && source "$_fzf_dir/key-bindings.zsh"
      [[ -r "$_fzf_dir/completion.zsh" ]] && source "$_fzf_dir/completion.zsh"
    done
    unset _fzf_dir
  fi
fi

export FZF_CTRL_T_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'

export FZF_DEFAULT_OPTS="
  --border sharp
  --prompt '∷ ' 
  --pointer ▶ 
  --marker ✓
  --layout=reverse
  --info=inline
  --height=70%
  --multi
  --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
  --bind 'ctrl-p:toggle-preview'
  --bind 'ctrl-a:select-all'
  --bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
"

export FZF_CTRL_T_OPTS="
  --bind 'ctrl-e:execute(echo {+} | xargs -o vi)'
  --bind 'ctrl-v:execute(code {+})'
  --color header:italic
  --header 'CTRL + Y to copy, CTRL + E to edit in vim, CTRL + V to open in VSCode'
"

export FZF_CTRL_R_OPTS="
  --preview-window=:hidden
  --header 'CTRL + Y to copy'
  --color header:italic
"