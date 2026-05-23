#!/bin/bash
packages=(
  # Zsh
	'zsh-autosuggestions'
	'zsh-syntax-highlighting'
	'starship'
	'bat'
	'stow'
	'ruff'
	'tree'
	'fzf'
	'fd'
	'tmux'
	'watch'
	'lsd'
	'vivid'
	'yazi'
	'zoxide'

	# MacOS
	iterm2

	# Neovim
	'neovim'
	'tree-sitter-cli'
	'lua-language-server'
	'stylua'

	# Development
	docker
	docker-compose
	postgresql@14
	python@3.14
	uv
	# node

    # Other
	'wget'
	'lazygit'
	'jq'
	'ripgrep'
	'grep'
)

# Install with Homebrew
for package in "${packages[@]}"; do
    brew install "$package"
done

# Casks
brew install --cask ghostty

# Doppler (secret management)
brew install dopplerhq/cli/doppler

# Doppler login - required for ~/.zshenv.local to load secrets
# On headless machines, set DOPPLER_TOKEN instead of running this
echo "Logging into Doppler (skip with Ctrl-C on headless machines)..."
doppler login

# Setup scripts
chmod +x setup/*

setup/macos.sh
setup/vscode.sh
setup/bat.sh

