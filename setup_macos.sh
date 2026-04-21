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
	'zoxide'

	# MacOS
	iterm2

	# Neovim
	'neovim'
	'tree-sitter-cli'

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
	'rg'
	'grep'
)

# Install with Homebrew
for package in "${packages[@]}"; do
    brew install "$package"
done

# Casks
brew install --cask ghostty

# Setup scripts
chmod +x setup/*

setup/macos.sh
setup/vscode.sh

