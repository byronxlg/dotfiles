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
- Skillfold installs the declared shared skills into `~/.claude/skills/` and `~/.agents/skills/`. The manifest preserves the Claude-only document skills and Codex-only issue/idea skills.
- Plugin-bundled skills and Codex system skills remain managed by their installers.

## Skills

[Skillfold](https://github.com/byronxlg/skillfold) is installed from npm by both
machine setup scripts. To install it and reproduce the locked skill selection:

```sh
bash setup/home/skills.sh
```

Requires Node.js 20+ and a writable npm global prefix. The script runs the normal
`npm install -g skillfold@2.5.0` and `skillfold install -g --frozen` commands.
Doppler supplies GitHub authentication when available; public sources also work
without a token, subject to GitHub's anonymous rate limit.

Stow links `.config/skillfold/skillfold.yaml` and `.config/skillfold/skillfold.lock`
into `~/.config/skillfold/`. This one config selects 30 distinct skills: 28 for
Claude and 23 for Codex. Skillfold owns the installed skill directories.

Skillfold 2.5.0 uses this independent config location by default and supports
`XDG_CONFIG_HOME`. To migrate an existing standalone config from `~/.claude`,
run `skillfold migrate -g`, then `skillfold check -g`. This dotfiles setup uses
the default `~/.config/skillfold/` location.

```sh
skillfold list -g
skillfold check -g
skillfold add -g github:owner/repo/path/to/skill
skillfold update -g <name>
```

Personal and adapted sources live in [byronxlg/skills](https://github.com/byronxlg/skills).
Edit and push sources there, then run `skillfold update -g <name>`. Third-party
sources come directly from upstream. The lockfile records the exact GitHub
revisions and content hashes. Commit and push manifest and lockfile changes in
this repo. Do not edit generated copies under `~/.claude/skills` or `~/.agents/skills`.

Use `targets` on a skill mapping to restrict its agents. For example:

```yaml
targets: [claude, codex]
skills:
  obsidian: github:byronxlg/skills/skills/obsidian
  docx:
    source: github:anthropics/skills/skills/docx
    targets: [claude]
```

On an existing machine, remove the old Stow-owned skill links before installing.
Back up any local edits first. Skillfold refuses to overwrite unmanaged skills
unless their content already matches or `--force` is explicitly supplied.

## Agent settings

Claude settings, permission lists, models, authentication, plugins, statusline, and hooks are not copied into Codex configuration. Existing Codex settings stay local and unchanged. The Claude hooks are not enabled in the current Claude settings either.

Restart Codex to load the global instructions and discover the skills. This layout uses the default `~/.codex` home. See the official [AGENTS.md documentation](https://learn.chatgpt.com/docs/agent-configuration/agents-md) and [skill discovery documentation](https://learn.chatgpt.com/docs/build-skills).
