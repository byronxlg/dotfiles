#!/bin/bash
# Run from the dotfiles root: bash setup/wsl.sh
set -euo pipefail

LAZYGIT_VERSION="0.44.1"
YAZI_VERSION="25.3.2"
LUA_LS_VERSION="3.13.6"
STYLUA_VERSION="2.0.2"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── APT packages ─────────────────────────────────────────────────────────────
APT_PACKAGES=(
    # Shell
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    stow

    # File tools
    bat
    fd-find
    fzf
    tree
    ripgrep
    wget
    unzip

    # Terminal multiplexer
    tmux

    # ls replacement + colour generation for LS_COLORS
    lsd
    vivid

    # Directory jumper
    zoxide

    # JSON
    jq

    # Neovim (0.9.x from apt; for newer add the neovim-ppa/unstable PPA)
    neovim

    # Node (for tree-sitter-cli)
    nodejs
    npm

    # PostgreSQL client
    postgresql-client

    # Doppler prereqs
    apt-transport-https
    ca-certificates
    gnupg
)

echo "Updating apt..."
sudo apt-get update -q || echo "Warning: apt-get update had errors (third-party repos may be unavailable, continuing...)"

echo "Installing apt packages..."
sudo apt-get install -y "${APT_PACKAGES[@]}"

# ─── Canonical name symlinks ──────────────────────────────────────────────────
# Ubuntu renames some binaries to avoid conflicts with other packages.
mkdir -p "$HOME/.local/bin"

# fd-find installs as fdfind
if [[ ! -e "$HOME/.local/bin/fd" ]]; then
    echo "Creating ~/.local/bin/fd -> /usr/bin/fdfind symlink..."
    ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
fi

# bat installs as batcat
if [[ ! -e "$HOME/.local/bin/bat" ]]; then
    echo "Creating ~/.local/bin/bat -> /usr/bin/batcat symlink..."
    ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
fi

# ─── Starship ─────────────────────────────────────────────────────────────────
if ! command -v starship &>/dev/null; then
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# ─── uv ───────────────────────────────────────────────────────────────────────
if ! command -v uv &>/dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# ─── ruff ─────────────────────────────────────────────────────────────────────
if ! command -v ruff &>/dev/null; then
    echo "Installing ruff via uv..."
    "$HOME/.local/bin/uv" tool install ruff
fi

# ─── lazygit ──────────────────────────────────────────────────────────────────
if ! command -v lazygit &>/dev/null; then
    echo "Installing lazygit ${LAZYGIT_VERSION}..."
    tmp=$(mktemp -d)
    curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
        | tar -xz -C "$tmp"
    sudo install "$tmp/lazygit" /usr/local/bin/lazygit
    rm -rf "$tmp"
fi

# ─── yazi ─────────────────────────────────────────────────────────────────────
if ! command -v yazi &>/dev/null; then
    echo "Installing yazi ${YAZI_VERSION}..."
    tmp=$(mktemp -d)
    curl -sL "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip" \
        -o "$tmp/yazi.zip"
    unzip -q "$tmp/yazi.zip" -d "$tmp"
    sudo install "$tmp/yazi-x86_64-unknown-linux-gnu/yazi" /usr/local/bin/yazi
    rm -rf "$tmp"
fi

# ─── tree-sitter CLI ──────────────────────────────────────────────────────────
if ! command -v tree-sitter &>/dev/null; then
    echo "Installing tree-sitter-cli..."
    sudo npm install -g tree-sitter-cli
fi

# ─── lua-language-server ──────────────────────────────────────────────────────
if ! command -v lua-language-server &>/dev/null; then
    echo "Installing lua-language-server ${LUA_LS_VERSION}..."
    tmp=$(mktemp -d)
    curl -sL "https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}/lua-language-server-${LUA_LS_VERSION}-linux-x64.tar.gz" \
        | tar -xz -C "$tmp"
    sudo mkdir -p /opt/lua-language-server
    sudo cp -r "$tmp/." /opt/lua-language-server/
    sudo ln -sf /opt/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server
    rm -rf "$tmp"
fi

# ─── stylua ───────────────────────────────────────────────────────────────────
if ! command -v stylua &>/dev/null; then
    echo "Installing stylua ${STYLUA_VERSION}..."
    tmp=$(mktemp -d)
    curl -sL "https://github.com/JohnnyMorganz/StyLua/releases/download/v${STYLUA_VERSION}/stylua-linux-x86_64.zip" \
        -o "$tmp/stylua.zip"
    unzip -q "$tmp/stylua.zip" -d "$tmp"
    sudo install "$tmp/stylua" /usr/local/bin/stylua
    rm -rf "$tmp"
fi

# ─── Post-install setup ───────────────────────────────────────────────────────
chmod +x "$SCRIPT_DIR"/*.sh "$SCRIPT_DIR"/home/*.sh
"$SCRIPT_DIR/bat.sh"
"$SCRIPT_DIR/vscode.sh"

# ─── Doppler ──────────────────────────────────────────────────────────────────
# Install + login (skip login with Ctrl-C on headless machines)
"$SCRIPT_DIR/home/doppler.sh"
