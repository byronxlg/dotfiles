#!/usr/bin/env bash
# Tmux preset: claude agent control center.
# Lives at ~/.tmux-claude.sh. Run from anywhere; session is global, not per-repo.

SESSION_NAME="claude"

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

echo "Creating new session '$SESSION_NAME'..."

# Window 1: agents view
tmux new-session -d -s "$SESSION_NAME" -n agents
tmux send-keys -t "$SESSION_NAME:agents" "claude agents" C-m

# Window 2: repos shell
tmux new-window -t "$SESSION_NAME" -n repos -c "$HOME/repos"

tmux select-window -t "$SESSION_NAME:agents"
tmux attach-session -t "$SESSION_NAME"
