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

# Setup scripts
chmod +x setup/*.sh setup/home/*.sh

setup/macos.sh
setup/vscode.sh
setup/bat.sh

# Doppler (secret management): install + login
setup/home/doppler.sh

