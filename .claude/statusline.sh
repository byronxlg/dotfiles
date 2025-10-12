#!/bin/bash
# Read JSON input once
input=$(cat)

# Helper functions for common extractions
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

# Use the helpers
MODEL=$(get_model_name)
DIR=$(get_current_dir)
PROJECT=$(get_project_dir)
VERSION=$(get_version)
COST_USD=$(get_cost)
COST_NZD=$(echo "$COST_USD * 1.7" | bc)
DURATION=$(get_duration)
ADDED=$(get_lines_added)
REMOVED=$(get_lines_removed)
echo "[$MODEL] 📁 ${DIR##*/} ($PROJECT) - $COST_NZD NZD | $DURATION ms | +$ADDED -$REMOVED"