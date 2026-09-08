# Secret management: Doppler

All credentials are managed in Doppler. Never store secrets in plaintext files, `.env` files, or committed configs.

## Hierarchy

```
Doppler
├── global (project)
│   └── home (config)
│       └── Admin/root-level keys shared across all machines
│           e.g. OPENAI_API_KEY, CLOUDFLARE_API_TOKEN, GH_TOKEN
│
└── <repo-name> (project, one per repo)
    ├── dev (config)
    │   └── Scoped keys for local development
    └── prd (config)
        └── Scoped keys for production
```

**Global is for personal infrastructure** - keys you use as a human across tools and machines. Code never reads from global directly.

**Project configs are for repos** - one Doppler project per repo, with separate configs per environment. Keys here are scoped, provisioned from global admin keys, and stored only in Doppler.

## Key scoping rules

- **Assume admin scope**: keys in `global/home` like `OPENAI_API_KEY`, `CLOUDFLARE_API_TOKEN`, `GH_TOKEN` are provisioned with broad permissions. Never use them directly in project code or CI/CD.
- **Create scoped keys for projects**: use the admin key once to provision a narrowly-scoped key, then store that in the project's Doppler config.
- **Principle of least privilege**: the project key should have exactly the access the project needs - no more.
- **Why**: if a scoped key leaks, the blast radius is contained. An admin key leak can compromise the entire account.

## On-demand access

Secrets are not auto-loaded into the shell. Fetch them explicitly when needed.

**Run a command with secrets injected:**
```sh
doppler run --project <name> --config <config> -- <command>
```

**Fetch secrets for a project:**
```sh
doppler secrets --project <name> --config <config>
```

**Download as env vars (stdout):**
```sh
doppler secrets download --project <name> --config <config> --no-file --format env
```

**List projects and configs:**
```sh
doppler projects
doppler configs --project <name>
```

## Setup

**New machine**: install Doppler (`brew install dopplerhq/cli/doppler`) and run `doppler login`. Handled by `setup_macos.sh`.

**Headless machines**: set `DOPPLER_TOKEN` to a Doppler service token. The Doppler CLI checks this variable automatically.

## CC_ prefix convention is retired

A `CC_` prefix convention for Claude Code credentials (e.g. `CC_GH_TOKEN`) was briefly introduced and then reverted. Do not use or reference `CC_`-prefixed env vars. Use the Doppler-injected names directly (e.g. `GH_TOKEN`).

## Never revoke, delete, or rotate credentials without explicit instruction

Revoking a credential is irreversible. Do not revoke, delete, or rotate any key - even one that appears superseded or unused - unless explicitly asked. The key may be in use by other tools, sessions, or people outside your visibility.
