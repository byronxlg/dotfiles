---
name: issue
description: Turn a plain-English request into a structured GitHub issue, review the draft with the user, and create it after confirmation.
---

Turn the user's plain-English description into a structured GitHub issue and create it.

Use the user's request and conversation context as the issue description.

Follow these steps:

1. Draft a GitHub issue from the description with:
   - **Title**: concise, imperative, max 72 characters
   - **Background**: 2-3 sentences explaining the context and why this matters
   - **Requirements**: bulleted list of what needs to be done
   - **Acceptance Criteria**: checkboxes (`- [ ]`) defining done

2. Show the draft to the user and ask for confirmation before creating.

3. Once confirmed, write the exact issue body to a temporary file and create the issue:
   ```bash
   gh issue create --title "<title>" --body-file <draft-file>
   ```

4. Report the issue number and URL.

Keep the issue focused and actionable. Do not over-engineer the requirements.
