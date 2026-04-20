#!/bin/bash

echo "Running setup: macos.sh ..."

# Instantly hide/reveal the dock
defaults write com.apple.Dock autohide-delay -float 0 && killall Dock
defaults write com.apple.dock autohide-time-modifier -float 0 && killall Dock

echo "Completed setup: macos.sh"
