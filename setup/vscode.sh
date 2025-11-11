#!/bin/bash

echo "Running setup: vscode.sh ..."

# Install extensions
code --force \
    --install-extension ms-python.python                            \
    --install-extension charliermarsh.ruff                          \
    --install-extension mikestead.dotenv                            \
    --install-extension esbenp.prettier-vscode                      \
    --install-extension tamasfe.even-better-toml                    \
    --install-extension catppuccin.catppuccin-vsc                   \
    --install-extension vscode-icons-team.vscode-icons


echo "Completed setup: vscode.sh"
