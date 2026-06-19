#!/bin/bash
# Doppler setup for the home (global) config.
# Installs the Doppler CLI and logs in so ~/.zshenv.local can load secrets.
# On headless machines, skip login and set DOPPLER_TOKEN instead.
set -euo pipefail

# ─── Install ──────────────────────────────────────────────────────────────────
if ! command -v doppler &>/dev/null; then
    echo "Installing Doppler..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install dopplerhq/cli/doppler
    else
        curl -sLf --retry 3 --tlsv1.2 --proto "=https" \
            'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' \
            | sudo gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg
        echo "deb [sign-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" \
            | sudo tee /etc/apt/sources.list.d/doppler-cli.list
        sudo apt-get update -q || echo "Warning: apt-get update had errors (continuing...)"
        sudo apt-get install -y doppler
    fi
fi

# ─── Login ────────────────────────────────────────────────────────────────────
# Required for ~/.zshenv.local to load secrets. On headless machines, set
# DOPPLER_TOKEN to a service token instead of running this.
echo "Logging into Doppler (skip with Ctrl-C on headless machines)..."
doppler login
