# Get Started

## MacOS Setup

-   Install Brew Libraries
-   MacOS Settings

```bash
chmod +x ./setup_macos.sh && ./setup_macos.sh
```

## WSL Setup

```bash
bash setup/wsl.sh
```

Version pins for tools not in apt (`LAZYGIT_VERSION`, `YAZI_VERSION`, etc.) are at the top of `setup/wsl.sh` - update them before running on a new machine.

## Terminal Setup (MacOS)

-   [iTerm2](https://iterm2.com/)
-   [Nerd Font](https://www.nerdfonts.com/font-downloads)
-   [Color Scheme](https://github.com/catppuccin/iterm)

## Claude Code env vars

Secrets for Claude Code (Anthropic API key, AWS Bedrock creds, etc.) live in `~/.zshenv.local`, gitignored and outside this repo. `~/.zshenv` (stowed from `.zshenv`) sources it on every shell start, so Claude Code and any other tools launched from that shell inherit the vars.

Bootstrap on a new machine:

```sh
touch ~/.zshenv.local
chmod 600 ~/.zshenv.local
$EDITOR ~/.zshenv.local   # fill in real values
exec zsh                  # pick up the new vars
```

