Turn the user's plain-English description into a structured GitHub issue and create it.

The user invoked this command with: $ARGUMENTS

Follow these steps:

1. Draft a GitHub issue from the description with:
   - **Title**: concise, imperative, max 72 characters
   - **Background**: 2-3 sentences explaining the context and why this matters
   - **Requirements**: bulleted list of what needs to be done
   - **Acceptance Criteria**: checkboxes (`- [ ]`) defining done

2. Show the draft to the user and ask for confirmation before creating.

3. Once confirmed, create the issue:
   ```bash
   gh issue create --title "<title>" --body "<body>"
   ```

4. Report the issue number and URL.

Keep the issue focused and actionable. Do not over-engineer the requirements.
