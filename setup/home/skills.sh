#!/bin/bash
# Install Skillfold from npm and reproduce the user-level skill selection.
set -euo pipefail

SKILLFOLD_VERSION="2.5.0"
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if ! command -v node >/dev/null || ! node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 20 ? 0 : 1)'; then
    echo "Skillfold requires Node.js 20 or later. Install Node, then rerun this script." >&2
    exit 1
fi

npm install -g "skillfold@${SKILLFOLD_VERSION}"
cd "$DOTFILES_ROOT"
stow . --no-folding
if [[ -d "hosts/$(hostname)" ]]; then
    stow -d hosts -t "$HOME" --no-folding "$(hostname)"
fi

# A token is optional for public sources, but avoids GitHub's low anonymous limit.
if command -v doppler >/dev/null; then
    doppler run --project global --config home -- skillfold install -g --frozen
else
    skillfold install -g --frozen
fi
skillfold check -g
