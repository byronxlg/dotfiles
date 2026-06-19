Development workflow for feature branches, from first commit to post-deploy verification.

## Keeping in sync with main

- **Pull main before starting new work**: `git fetch origin && git merge origin/main` (or `git pull`) in the main checkout before branching.
- **Rebase WIP branch whenever main advances**: from the worktree, `git fetch origin && git rebase origin/main`. Fix conflicts as they arise - small rebases are far cheaper than large ones at PR time.
- **Never merge main into a WIP branch** - always rebase. Merge commits clutter history and complicate bisect.
- **Stale branches become liabilities**: if a branch is more than a few days old without a rebase, do it now before the diff grows.

## Worktrees

The main checkout stays on `main`. All work on other branches happens in a git worktree. This prevents concurrent Claude sessions from colliding and prevents the next session from opening to a surprising checkout state.

- **Main checkout invariant**: never check out a non-main branch (or remote branch, or PR ref) in the main checkout, even briefly, even for inspection. A switched checkout silently surprises the next session that opens here.
- **Inspect another branch without checking out**: use `gh pr view`, `gh pr diff`, `git log <branch>`, `git show <branch>:<path>`. None of these move the working tree.
- **Active work on a non-main branch**: always create a worktree. Includes PR review if you need to run code or apply patches. No exceptions for "tiny" edits.
- **Clean up**: once the branch is merged or abandoned, remove the worktree AND delete the branch (local + remote): `git worktree remove <path>` then `git branch -D <branch>` and `git push origin --delete <branch>`. See Post-merge for the squash-merge caveat.
- **Dev servers live in the active checkout**: start uvicorn / vite in the worktree where you're working, not in the main checkout. Don't pin a dev server to main while doing branched work elsewhere; you'll fight hot-reload or accidentally edit main.
- **Shared state caveat**: worktrees isolate files and branches only. Local databases (Postgres, Neo4j, etc.), dev server ports, and other process-level state are still shared across worktrees. Two sessions running migrations or writing to the same DB will collide regardless of worktree.

## Before opening a PR

- **Run tests locally first**: don't open a PR and wait for CI to find failures you could have caught yourself. Run the same commands CI runs.
- **Lint and format**: run the project's lint and format checks before pushing.
- **Tests**: run the project's test suite before pushing.
- **Infra changes**: run a plan if infra changed - read the output carefully before opening the PR.
- **Exercise the change manually** if it touches behavior: run the affected flow, check the output, confirm it does what you expect. CI checks correctness; you check intent.
- **Test locally before pushing large changes**: any change that touches core logic, shared utilities, data pipelines, or multiple interconnected components must be tested locally end-to-end before opening a PR. "Large" means: cross-cutting refactors, schema or interface changes, anything that could silently break a downstream consumer. Don't rely on CI alone to catch regressions in these cases.

## Asking for a human review of running behavior

When you want me to look at WIP - a UI change, a new flow, anything I'd judge by using it rather than reading the diff - **start it yourself and hand me a URL.** Don't tell me to run the dev server; do it.

- **Start the server in the background** so it survives across turns, then verify it responds before sharing the link (`curl -s -o /dev/null -w "%{http_code}" <url>`).
- **Give me a clickable URL** (e.g. `http://localhost:<port>`), plus a one-line "what to look at" and which paths/screens changed.
- **Pick the right host**: serve in the active checkout/worktree where the change lives, not the main checkout. Match the port to the project's documented dev command (e.g. this project: `cd site && python3 -m http.server 4178`).
- **For changes with multiple states** (themes, empty/loading/error, breakpoints), still capture screenshots as a fallback and point me to them, but the live URL is the primary deliverable.
- **Tell me how to stop it** if it's a long-lived process, and clean it up once I'm done reviewing.

## PR review

- **Get a subagent review before merging**: use the `/code-review` skill to review the branch diff. Take findings seriously - if a finding seems wrong, verify before dismissing.
- **Don't merge immediately after opening**: give the review time to surface issues. A PR that's open for two minutes before merging bypassed the review in spirit.
- **Keep PRs small and focused**: one logical change per PR. A PR that changes three unrelated things is three PRs.

## Post-merge

- **Watch the deploy run**: after merging, check that any triggered CI/CD workflows complete successfully. Confirm the run passed before moving on.
- **Smoketest if applicable**: if the deployment exposes observable behavior (an API endpoint, a running service, a scheduled job), verify it manually after deploy. For infrastructure-only changes, confirm the resource exists and is configured as expected.
- **If deploy fails**: don't merge a fix on top - investigate the failure first. A broken deploy may leave state partially applied; understand what happened before adding more changes.
- **Clean up the worktree and branch** once the branch is merged and the deploy is confirmed:
  - Remove the worktree: `git worktree remove <path>` (add `--force` if only untracked/generated files like `uv.lock` remain).
  - Delete the branch local + remote: `git branch -D <branch>` then `git push origin --delete <branch>`. The remote delete is the irreversible step - confirm the work landed on `main` before running it.
  - **Squash-merge caveat**: a squash-merged branch will NOT show as merged by SHA (`git merge-base --is-ancestor` says "not merged", `git branch --merged` omits it) because the squash created a new commit. Don't trust the ancestor check - confirm the feature's content is on `main` (the merged PR, the files/commits by message) before deleting, then use `git branch -D` (capital D) since `-d` will refuse the "unmerged" branch.
