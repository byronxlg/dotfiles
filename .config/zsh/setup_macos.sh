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

	# MacOS
	iterm2
	koekeishiya/formulae/yabai # yabai --start-service / yabai --restart-service
	koekeishiya/formulae/skhd  # skhd --start-service / skhd --restart-service


    # Neovim and dependencies
	'lua'
	'luarocks'

    # Other
	'wget'
	'lazygit'
	'jq'
	'grep'
)

# Install with Homebrew
for package in "${packages[@]}"; do
    brew install $package
done