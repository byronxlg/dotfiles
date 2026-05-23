All infrastructure changes must be made through Infrastructure as Code (IaC) triggered via GitHub Actions - never applied directly from a local machine.

- **No local applies**: never run `terraform apply`, `aws` write commands, `kubectl apply`, or equivalent infra-mutating commands directly. Read-only commands (`plan`, `get`, `describe`, `list`) are fine locally.
- **IaC via GitHub Actions**: all infrastructure state changes must be triggered through a GitHub Actions workflow. They don't need to go through a PR, but they must be traceable (visible in the Actions run history) and reversible (the IaC can be reverted and re-applied).
- **Why**: direct local applies leave no audit trail and can't be reproduced or rolled back reliably. GitHub Actions runs are logged, attributed, and tied to a specific commit.
- **Emergency exception**: if a live incident requires an immediate manual fix, document what you did in a follow-up commit that brings IaC back in sync. Never leave manual state drift unrecorded.
