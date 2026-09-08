# Credential discovery

Before concluding that an external service is unavailable or using browser access, check installed CLIs and Doppler. Doppler is the preferred source for service credentials on machines where it is installed and authenticated.

- Use `command -v doppler`, then list projects and configurations. Inspect secret names with `--only-names`; never print secret values.
- Read the notes attached to relevant secrets before choosing or using them. Notes can explain the account, environment, permissions, endpoints, and usage constraints; do not infer these from the secret name alone.
- Prefer the project matching the organization or repository. North Wind Capital credentials are in project `northwindcapital`, config `admin`, including `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ZONE_ID`.
- Pass credentials through process environments or in-memory API clients. Never place them in command arguments, logs, repository files, or chat.
- Prefer authenticated service APIs or CLIs over browser automation.
- Credential availability does not override `infra-writes.md`: infrastructure changes must run as versioned code through GitHub Actions. Local read-only discovery is allowed.
