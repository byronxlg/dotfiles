# Uninstall
rm ~/.local/bin/claude
rm -rf ~/.local/share/claude

# User-level Claude Code config:
rm -rf ~/.claude
rm -f ~/.claude.json ~/.claude.json.backup

# Claude Desktop preferences:
rm -f ~/Library/Preferences/com.anthropic.claudefordesktop.plist


# Install
# curl -fsSL https://claude.ai/install.sh | bash