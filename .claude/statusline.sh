#!/bin/bash

# Functions
round() {
    # round 3.1416 2 -> 3.14
    # round 3.1416 3 -> 3.142
    printf "%.${2}f" "${1}"
}

float_divide() {
    # float_divide 5 2 -> 2.5
    echo "scale=2; $1 / $2" | bc
}

# Read JSON input once
input=$(cat)

# Helper functions for common extractions
get_model_id() { echo "$input" | jq -r '.model.id'; }
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

# Use the helpers
MODEL_ID=$(get_model_id)
MODEL_NAME=$(get_model_name)
DIR=$(get_current_dir)
PROJECT=$(get_project_dir)
VERSION=$(get_version)
COST_USD=$(get_cost)
DURATION_MS=$(get_duration)
DURATION_SECONDS=$(float_divide "$DURATION_MS" 1000)
ADDED=$(get_lines_added)
REMOVED=$(get_lines_removed)
echo "$MODEL_NAME - $(round "$COST_USD" 2) USD | $DURATION_SECONDS s | +$ADDED -$REMOVED"