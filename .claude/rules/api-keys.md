API keys in the environment are typically admin or root-level credentials. Treat them as such.

- **Assume admin scope**: keys like `OPENAI_API_KEY`, `CLOUDFLARE_API_TOKEN`, `GH_TOKEN`, and similar are provisioned with broad permissions. Do not use them directly in project code or CI/CD.
- **Create scoped keys for projects**: when a project needs API access, use the admin key to provision a new, narrowly-scoped key (limited to the required endpoints, resources, or permissions) and store that in the project's own Doppler config.
- **Never embed env keys in code or configs**: do not copy a key from the environment into a project's `.env`, `settings.json`, or any committed or shared file. Always issue a fresh, purpose-limited key.
- **Scope by principle of least privilege**: the project key should have exactly the access the project needs - no more. A key used only to read S3 objects should not have write permissions.
- **Why**: if a scoped key leaks, the blast radius is contained. An admin key leak can compromise the entire account or organization.

## Secret management: Doppler

All credentials are managed in Doppler. Never store secrets in plaintext files or environment files.

**Global admin keys** live in the `global` project, `home` config.

`~/.zshenv.local` loads secrets at shell start via `doppler secrets download --project global --config home`.

**Project keys** go in their own Doppler project, one project per repo. Use the admin key to provision a scoped key, then store it in the project's Doppler config - not in `.env` files.

**New machine setup**: install Doppler (`brew install dopplerhq/cli/doppler`) and run `doppler login`. This is handled by `setup_macos.sh`.

**Headless machines**: set `DOPPLER_TOKEN` to a Doppler service token instead of running `doppler login`. The `~/.zshenv.local` script will pick it up automatically since the Doppler CLI checks this variable.

## Never revoke, delete, or rotate credentials without explicit instruction

Revoking an API key in an external system is **irreversible**. Do not revoke, delete, or rotate any credential - even one that appears superseded or unused - unless the user explicitly asks. The admin key may be used by other tools, other sessions, or other people. You cannot know its full scope of use.
