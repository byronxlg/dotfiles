#!/bin/bash
# PostToolUse hook: runs ruff check --fix and ruff format on any edited Python file.
# uv resolves the nearest pyproject.toml, so this works across projects.

f=$(jq -r '.tool_input.file_path')
[[ "$f" == *.py ]] || exit 0
dir=$(dirname "$f")
uv run --directory "$dir" ruff check --fix "$f" 2>/dev/null || true
uv run --directory "$dir" ruff format "$f" 2>/dev/null || true
