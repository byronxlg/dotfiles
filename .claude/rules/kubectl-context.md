Always pass `--context` (or `--kube-context` for `helm`) explicitly on cluster-targeting commands. Never rely on `current-context` in `~/.kube/config`.

- **Why**: `~/.kube/config` is shared across all shells and processes. Sibling sessions, direnv hooks, or `aws eks update-kubeconfig` runs in another project can rewrite `current-context` mid-session. Without `--context`, `kubectl` silently retargets to whatever cluster won the last write — which has caused real false-alarm incidents (e.g. believing a production install was wiped because the query landed on the wrong cluster).
- **kubectl**: `kubectl --context <name> <subcommand>`.
- **helm**: `helm --kube-context <name> <subcommand>`.
- **Discovering the right context name**: `kubectl config get-contexts -o name` lists them. EKS contexts are typically `arn:aws:eks:<region>:<account>:cluster/<name>`; kind contexts are `kind-<name>`. If multiple plausible matches exist, ask the user which one to target rather than guessing.
- **Debugging only**: `kubectl config current-context` and `kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'` are fine for diagnosing a context mismatch, but never substitute for passing `--context` on the actual operation.
- **Project CLAUDE.md may pin a specific context name**: prefer that over inference.
