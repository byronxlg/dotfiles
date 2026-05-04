#!/bin/bash
# Single line: Model (effort) | dir@branch | tokens | 5h <bar> <pct>% in <reset-eta>

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
red='\033[38;2;243;139;168m'     # #f38ba8
yellow='\033[38;2;249;226;175m'  # #f9e2af
text='\033[38;2;205;214;244m'    # #cdd6f4
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

# Return color escape based on usage percentage
usage_color() {
    local pct=$1
    if [ "$pct" -ge 90 ]; then echo "$red"
    elif [ "$pct" -ge 70 ]; then echo "$peach"
    elif [ "$pct" -ge 50 ]; then echo "$yellow"
    else echo "$green"
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

# Check reasoning effort
settings_path="$HOME/.claude/settings.json"
effort_level="high"
if [ -n "$CLAUDE_CODE_EFFORT_LEVEL" ]; then
    effort_level="$CLAUDE_CODE_EFFORT_LEVEL"
elif [ -f "$settings_path" ]; then
    effort_val=$(jq -r '.effortLevel // empty' "$settings_path" 2>/dev/null)
    [ -n "$effort_val" ] && effort_level="$effort_val"
fi

# Check if Bedrock is enabled
use_bedrock="0"
if [ -n "$CLAUDE_CODE_USE_BEDROCK" ]; then
    use_bedrock="$CLAUDE_CODE_USE_BEDROCK"
elif [ -f "$settings_path" ]; then
    bedrock_val=$(jq -r '.env.CLAUDE_CODE_USE_BEDROCK // "0"' "$settings_path" 2>/dev/null)
    [ -n "$bedrock_val" ] && use_bedrock="$bedrock_val"
fi

# ===== Build single-line output =====
out=""

# Model name with effort
case "$effort_level" in
    low)    effort_str="${dim}low${reset}" ;;
    medium) effort_str="${peach}med${reset}" ;;
    *)      effort_str="${green}high${reset}" ;;
esac
out+=" ${dim}|${reset} "
if [ "$use_bedrock" = "1" ]; then
    out+="${yellow}bedrock${reset} "
fi
out+="${blue}${model_name}${reset} ${dim}(${reset}${effort_str}${dim})${reset}"

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
out+="${peach}${used_tokens}/${total_tokens}${reset}"

# ===== Usage limits (skipped when using Bedrock) =====
if [ "$use_bedrock" != "1" ]; then

# ===== Cross-platform OAuth token resolution =====
# Tries credential sources in order: env var -> macOS Keychain -> Linux creds file -> GNOME Keyring
get_oauth_token() {
    local token=""

    if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
        echo "$CLAUDE_CODE_OAUTH_TOKEN"
        return 0
    fi

    if command -v security >/dev/null 2>&1; then
        local blob
        blob=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
        if [ -n "$blob" ]; then
            token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
            if [ -n "$token" ] && [ "$token" != "null" ]; then
                echo "$token"
                return 0
            fi
        fi
    fi

    local creds_file="${HOME}/.claude/.credentials.json"
    if [ -f "$creds_file" ]; then
        token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds_file" 2>/dev/null)
        if [ -n "$token" ] && [ "$token" != "null" ]; then
            echo "$token"
            return 0
        fi
    fi

    if command -v secret-tool >/dev/null 2>&1; then
        local blob
        blob=$(timeout 2 secret-tool lookup service "Claude Code-credentials" 2>/dev/null)
        if [ -n "$blob" ]; then
            token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
            if [ -n "$token" ] && [ "$token" != "null" ]; then
                echo "$token"
                return 0
            fi
        fi
    fi

    echo ""
}

# ===== Usage limits (cached) =====
cache_file="/tmp/claude/statusline-usage-cache.json"
cache_max_age=60  # seconds between API calls
mkdir -p /tmp/claude

needs_refresh=true
usage_data=""

if [ -f "$cache_file" ]; then
    cache_mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)
    now=$(date +%s)
    cache_age=$(( now - cache_mtime ))
    if [ "$cache_age" -lt "$cache_max_age" ]; then
        needs_refresh=false
        usage_data=$(cat "$cache_file" 2>/dev/null)
    fi
fi

if $needs_refresh; then
    token=$(get_oauth_token)
    if [ -n "$token" ] && [ "$token" != "null" ]; then
        response=$(curl -s --max-time 10 \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "User-Agent: claude-code/2.1.126" \
            "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
        if [ -n "$response" ] && echo "$response" | jq . >/dev/null 2>&1; then
            if ! echo "$response" | jq -e '.error' >/dev/null 2>&1; then
                usage_data="$response"
                echo "$response" > "$cache_file"
            fi
        fi
    fi
    if [ -z "$usage_data" ] && [ -f "$cache_file" ]; then
        usage_data=$(cat "$cache_file" 2>/dev/null)
    fi
fi

# Cross-platform ISO 8601 to epoch seconds
iso_to_epoch() {
    local iso_str="$1"
    local epoch
    epoch=$(date -d "${iso_str}" +%s 2>/dev/null)
    if [ -n "$epoch" ]; then
        echo "$epoch"
        return 0
    fi

    local stripped="${iso_str%%.*}"
    stripped="${stripped%%Z}"
    stripped="${stripped%%+*}"
    stripped="${stripped%%-[0-9][0-9]:[0-9][0-9]}"

    if [[ "$iso_str" == *"Z"* ]] || [[ "$iso_str" == *"+00:00"* ]] || [[ "$iso_str" == *"-00:00"* ]]; then
        epoch=$(env TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
    else
        epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
    fi

    [ -n "$epoch" ] && echo "$epoch"
}

# Format seconds duration as "1h23m", "45m", or "30s"
format_duration() {
    local total=$1
    [ "$total" -lt 0 ] && total=0
    if [ "$total" -lt 60 ]; then
        printf "%ds" "$total"
    elif [ "$total" -lt 3600 ]; then
        printf "%dm" $(( total / 60 ))
    else
        local h=$(( total / 3600 ))
        local m=$(( (total % 3600) / 60 ))
        if [ "$m" -eq 0 ]; then
            printf "%dh" "$h"
        else
            printf "%dh%dm" "$h" "$m"
        fi
    fi
}

# Build a 10-cell progress bar; filled cells use $color, empty cells are dim
make_bar() {
    local pct=$1
    local color=$2
    local cells=10
    local filled=$(( pct * cells / 100 ))
    [ "$filled" -gt "$cells" ] && filled=$cells
    [ "$filled" -lt 0 ] && filled=0
    local empty=$(( cells - filled ))
    local bar="${color}"
    local i
    for ((i=0; i<filled; i++)); do bar+="▓"; done
    bar+="${reset}${dim}"
    for ((i=0; i<empty; i++)); do bar+="░"; done
    bar+="${reset}"
    printf "%s" "$bar"
}

sep=" ${dim}|${reset} "

if [ -n "$usage_data" ] && echo "$usage_data" | jq -e . >/dev/null 2>&1; then
    five_hour_pct=$(echo "$usage_data" | jq -r '.five_hour.utilization // 0' | awk '{printf "%.0f", $1}')
    five_hour_reset_iso=$(echo "$usage_data" | jq -r '.five_hour.resets_at // empty')
    five_hour_color=$(usage_color "$five_hour_pct")
    five_hour_bar=$(make_bar "$five_hour_pct" "$five_hour_color")

    out+="${sep}${text}5h${reset} ${five_hour_bar} ${five_hour_color}${five_hour_pct}%${reset}"

    reset_epoch=$(iso_to_epoch "$five_hour_reset_iso")
    if [ -n "$reset_epoch" ]; then
        seconds_until=$(( reset_epoch - $(date +%s) ))
        out+=" ${dim}in $(format_duration "$seconds_until")${reset}"
    fi
fi

fi  # end: not bedrock

# Output single line
printf "%b" "$out"

exit 0
