#!/bin/bash
# Single line: user@host | time | Model | dir@branch | tokens | effort | 5h @reset | 7d @reset | extra

set -f  # disable globbing

input=$(cat)

if [ -z "$input" ]; then
    printf "Claude"
    exit 0
fi

# ANSI colors: Catppuccin Mocha palette (https://github.com/catppuccin/catppuccin)
blue='\033[38;2;137;180;250m'    # #89b4fa
mauve='\033[38;2;203;166;247m'   # #cba6f7
peach='\033[38;2;250;179;135m'   # #fab387
green='\033[38;2;166;227;161m'   # #a6e3a1
teal='\033[38;2;148;226;213m'    # #94e2d5
sky='\033[38;2;137;220;235m'     # #89dceb
red='\033[38;2;243;139;168m'     # #f38ba8
subtext='\033[38;2;166;173;200m' # #a6adc8
dim='\033[2m'
reset='\033[0m'

# Format token counts (e.g., 50k / 200k)
format_tokens() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        awk "BEGIN {printf \"%.1fm\", $num / 1000000}"
    elif [ "$num" -ge 1000 ]; then
        awk "BEGIN {printf \"%.0fk\", $num / 1000}"
    else
        printf "%d" "$num"
    fi
}

# ===== Extract data from JSON =====
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# Context window
size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
[ "$size" -eq 0 ] 2>/dev/null && size=200000

# Token usage
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
current=$(( input_tokens + cache_create + cache_read ))

used_tokens=$(format_tokens $current)
total_tokens=$(format_tokens $size)

if [ "$size" -gt 0 ]; then
    pct_used=$(( current * 100 / size ))
else
    pct_used=0
fi

# Check reasoning effort
settings_path="$HOME/.claude/settings.json"
effort_level="high"
if [ -n "$CLAUDE_CODE_EFFORT_LEVEL" ]; then
    effort_level="$CLAUDE_CODE_EFFORT_LEVEL"
elif [ -f "$settings_path" ]; then
    effort_val=$(jq -r '.effortLevel // empty' "$settings_path" 2>/dev/null)
    [ -n "$effort_val" ] && effort_level="$effort_val"
fi

# ===== Build single-line output =====
out=""

# Model name
out+=" ${dim}|${reset} ${blue}${model_name}${reset}"

# Current working directory
cwd=$(echo "$input" | jq -r '.cwd // empty')
if [ -n "$cwd" ]; then
    display_dir="${cwd##*/}"
    git_branch=$(git --git-dir="${cwd}/.git" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
    out+=" ${dim}|${reset} "
    out+="${teal}${display_dir}${reset}"
    if [ -n "$git_branch" ]; then
        out+="${dim}@${reset}${green}${git_branch}${reset}"
        git_stat=$(git --git-dir="${cwd}/.git" --no-optional-locks diff --numstat 2>/dev/null | awk '{a+=$1; d+=$2} END {if (a+d>0) printf "+%d -%d", a, d}')
        [ -n "$git_stat" ] && out+=" ${dim}(${reset}${green}${git_stat%% *}${reset} ${red}${git_stat##* }${reset}${dim})${reset}"
    fi
    worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')
    if [ -n "$worktree_name" ]; then
        out+=" ${dim}[worktree: ${reset}${mauve}${worktree_name}${reset}${dim}]${reset}"
    fi
fi

out+=" ${dim}|${reset} "
out+="${peach}${used_tokens}/${total_tokens}${reset} ${dim}(${reset}${green}${pct_used}%${reset}${dim})${reset}"
out+=" ${dim}|${reset} "
out+="${subtext}effort:${reset} "
case "$effort_level" in
    low)    out+="${dim}low${reset}" ;;
    medium) out+="${peach}med${reset}" ;;
    *)      out+="${green}high${reset}" ;;
esac

# Time at far right
ps1_time=$(date +%H:%M:%S)
out+=" ${dim}|${reset} ${sky}${ps1_time}${reset}"

# Output single line
printf "%b" "$out"

exit 0