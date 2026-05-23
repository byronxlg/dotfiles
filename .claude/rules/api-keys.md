API keys in the environment are typically admin or root-level credentials. Treat them as such.

- **Assume admin scope**: keys like `OPENAI_API_KEY`, `CLOUDFLARE_API_TOKEN`, `GH_TOKEN`, and similar are provisioned with broad permissions. Do not use them directly in project code or CI/CD.
- **Create scoped keys for projects**: when a project needs API access, use the admin key to provision a new, narrowly-scoped key (limited to the required endpoints, resources, or permissions) and store that in the project's own secret management.
- **Never embed env keys in code or configs**: do not copy a key from the environment into a project's `.env`, `settings.json`, or any committed or shared file. Always issue a fresh, purpose-limited key.
- **Scope by principle of least privilege**: the project key should have exactly the access the project needs - no more. A key used only to read S3 objects should not have write permissions.
- **Why**: if a scoped key leaks, the blast radius is contained. An admin key leak can compromise the entire account or organization.
