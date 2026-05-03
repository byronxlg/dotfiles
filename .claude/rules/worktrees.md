The main checkout stays on `main`. All work on other branches happens in a git worktree. This prevents concurrent Claude sessions from colliding and prevents the next session from opening to a surprising checkout state.

- **Main checkout invariant**: never check out a non-main branch (or remote branch, or PR ref) in the main checkout, even briefly, even for inspection. A switched checkout silently surprises the next session that opens here.
- **Inspect another branch without checking out**: use `gh pr view`, `gh pr diff`, `git log <branch>`, `git show <branch>:<path>`. None of these move the working tree.
- **Active work on a non-main branch**: always create a worktree. Includes PR review if you need to run code or apply patches. No exceptions for "tiny" edits.
- **Where**: `<repo>.worktrees/<branch>` next to the main checkout (e.g. `~/repos/slalom_mind.worktrees/feat-foo`).
- **Create**: `git worktree add ../<repo>.worktrees/<branch> -b <branch>` from inside the main checkout.
- **Clean up**: `git worktree remove <path>` once the branch is merged or abandoned.
- **Dev servers live in the active checkout**: start uvicorn / vite in the worktree where you're working, not in the main checkout. Don't pin a dev server to main while doing branched work elsewhere; you'll fight hot-reload or accidentally edit main.
- **Shared state caveat**: worktrees isolate files and branches only. Local databases (Postgres, Neo4j, etc.), dev server ports, and other process-level state are still shared across worktrees. Two sessions running migrations or writing to the same DB will collide regardless of worktree.
