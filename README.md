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


## Codex

Run `stow . --no-folding` to install the Codex configuration alongside Claude Code.

- `AGENTS.md` links to this repository's `CLAUDE.md` and is excluded from Stow.
- `.codex/AGENTS.md` loads the shared personal rules from `~/.claude/rules/`, including host rules only when that host package is installed. It also reads applicable project `CLAUDE.md` files where there is no `AGENTS.md`.
- `.agents/skills/` links portable Claude skills into Codex's user skill directory. Edit the Claude sources to update both tools; add a matching link when adding a shared skill.
- `$issue` adapts Claude's `/issue` command; `$project-idea-validator` adapts the idea-validation agent into a skill. These two are separate Codex files.
- Claude's `docx`, `xlsx`, `pptx`, `pdf`, `doc-coauthoring`, and `skill-creator` skills are omitted in favor of the installed Codex equivalents.

Claude settings, permission lists, models, authentication, plugins, statusline, and hooks are not copied into Codex configuration. Existing Codex settings stay local and unchanged. The Claude hooks are not enabled in the current Claude settings either.

Restart Codex to load the global instructions and discover the skills. This layout uses the default `~/.codex` home. See the official [AGENTS.md documentation](https://learn.chatgpt.com/docs/agent-configuration/agents-md) and [skill discovery documentation](https://learn.chatgpt.com/docs/build-skills).
