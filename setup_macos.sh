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
	koekeishiya/formulae/yabai # yabai --start-service / yabai --restart-service
	koekeishiya/formulae/skhd  # skhd --start-service / skhd --restart-service


    # Neovim and dependencies
	'nvim'
	'lua'
	'luarocks'

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

# Start services
# yabai --start-service
# skhd --start-service

# Setup scripts
chmod +x setup/*

setup/macos.sh
setup/vscode.sh

