Environment variables prefixed with `CC_` in `~/.zshenv.local` are credentials set specifically for Claude Code to access external services and accounts. They are not personal CLI credentials - they exist solely to give Claude Code capabilities.

## Convention

- `CC_OPENAI_API_KEY` - OpenAI account for Claude to call GPT models
- `CC_GH_TOKEN` - GitHub token for Claude to interact with repos and PRs
- `CC_AWS_ACCESS_KEY_ID` / `CC_AWS_SECRET_ACCESS_KEY` - AWS credentials for Claude
- `CC_CLOUDFLARE_API_TOKEN` - Cloudflare account for Claude
- `CC_MOLTBOOK_API_KEY`, `CC_OBSIDIAN_LOCAL_API_KEY`, `CC_POLYMARKET_*`, `CC_AKAHU_*` - service-specific credentials

The file also exports `CLAUDE_CODE_OAUTH_TOKEN` (without prefix) because the Claude Code CLI itself requires that exact canonical name to authenticate.

## Translating to canonical names

Many SDKs and CLIs expect the standard env var names (`OPENAI_API_KEY`, `GH_TOKEN`, `AWS_ACCESS_KEY_ID`, etc.). When running a command or script that needs a canonical name, translate explicitly in the command:

```sh
OPENAI_API_KEY=$CC_OPENAI_API_KEY python my_script.py
GH_TOKEN=$CC_GH_TOKEN gh pr list
AWS_ACCESS_KEY_ID=$CC_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$CC_AWS_SECRET_ACCESS_KEY aws s3 ls
```

Do not add a blanket re-export of canonical names to `.zshenv.local` - that defeats the purpose of the prefix and would expose these credentials to all shell processes, not just Claude Code.
