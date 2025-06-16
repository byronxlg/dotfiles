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
	'lua'
	'luarocks'

	# Development
	docker
	docker-compose
	postgresql@14
	python@3.12

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

# Instantly hide/ reveal the dock
defaults write com.apple.Dock autohide-delay -float 0 && killall Dock
defaults write com.apple.dock autohide-time-modifier -float 0 && killall Dock

# Untested
# defaults write -g NSScrollViewRubberbanding -int 0
# defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
# defaults write -g NSScrollAnimationEnabled -bool false
# defaults write -g NSWindowResizeTime -float 0.001
# defaults write -g QLPanelAnimationDuration -float 0
# defaults write -g NSScrollViewRubberbanding -bool false
# defaults write -g NSDocumentRevisionsWindowTransformAnimation -bool false
# defaults write -g NSToolbarFullScreenAnimationDuration -float 0
# defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0
# defaults write com.apple.dock autohide-time-modifier -float 0
# defaults write com.apple.dock autohide-delay -float 0
# defaults write com.apple.dock expose-animation-duration -float 0
# defaults write com.apple.dock springboard-show-duration -float 0
# defaults write com.apple.dock springboard-hide-duration -float 0
# defaults write com.apple.dock springboard-page-duration -float 0
# defaults write com.apple.finder DisableAllAnimations -bool true
# defaults write com.apple.Mail DisableSendAnimations -bool true
# defaults write com.apple.Mail DisableReplyAnimations -bool true
# defaults write NSGlobalDomain NSWindowResizeTime .001
# defaults write com.apple.dock expose-animation-duration -int 0; killall Dock
# defaults write com.apple.dock expose-animation-duration -float 0.1; killall Dock