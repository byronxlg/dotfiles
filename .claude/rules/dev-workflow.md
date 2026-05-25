Development workflow for feature branches, from first commit to post-deploy verification.

## Keeping in sync with main

- **Pull main before starting new work**: `git fetch origin && git merge origin/main` (or `git pull`) in the main checkout before branching.
- **Rebase WIP branch whenever main advances**: from the worktree, `git fetch origin && git rebase origin/main`. Fix conflicts as they arise - small rebases are far cheaper than large ones at PR time.
- **Never merge main into a WIP branch** - always rebase. Merge commits clutter history and complicate bisect.
- **Stale branches become liabilities**: if a branch is more than a few days old without a rebase, do it now before the diff grows.

## Worktrees

See `worktrees.md` for the full policy. Summary: all non-main work happens in a worktree at `<repo>.worktrees/<branch>`. Never check out a feature branch in the main checkout.

## Before opening a PR

- **Run tests locally first**: don't open a PR and wait for CI to find failures you could have caught yourself. Run the same commands CI runs.
- **Lint and format**: `uv run ruff check . && uv run ruff format --check .`
- **Tests**: `uv run pytest`
- **Terraform**: `terraform plan` if infra changed - read the plan output carefully before opening the PR.
- **Exercise the change manually** if it touches behavior: run the affected flow, check the output, confirm it does what you expect. CI checks correctness; you check intent.
- **Test locally before pushing large changes**: any change that touches core logic, shared utilities, data pipelines, or multiple interconnected components must be tested locally end-to-end before opening a PR. "Large" means: cross-cutting refactors, schema or interface changes, anything that could silently break a downstream consumer. Don't rely on CI alone to catch regressions in these cases.

## PR review

- **Get a subagent review before merging**: use the `/code-review` skill to review the branch diff. Take findings seriously - if a finding seems wrong, verify before dismissing.
- **Don't merge immediately after opening**: give the review time to surface issues. A PR that's open for two minutes before merging bypassed the review in spirit.
- **Keep PRs small and focused**: one logical change per PR. A PR that changes three unrelated things is three PRs.

## Post-merge

- **Watch the deploy run**: after merging, check that any triggered CI/CD workflows complete successfully. For this repo, merges to main that touch `infra/**` trigger `terraform-apply.yml` - open the Actions tab or run `gh run list --branch main --limit 3` and confirm the run passed.
- **Smoketest if applicable**: if the deployment exposes observable behavior (an API endpoint, a running service, a scheduled job), verify it manually after deploy. For infrastructure-only changes (S3, DynamoDB, IAM), confirm the resource exists and is configured as expected: `aws s3 ls s3://pdw-data` or equivalent.
- **If deploy fails**: don't merge a fix on top - investigate the failure first. A broken deploy may leave state partially applied; understand what happened before adding more changes.
- **Clean up the worktree** once the branch is merged and the deploy is confirmed: `git worktree remove <path>`.
