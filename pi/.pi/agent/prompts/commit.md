---
description: Generate a commit message from staged changes
---
Write a concise commit message for the currently staged changes (`git diff --cached`). If there are no staged changes, report that and stop.

Rules:
- Follow explicit commit conventions in the repository's instruction files.
- If none exist, use `type(scope): description` or `type: description` with one of: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
- Keep the subject line under 72 characters and use imperative mood ("add" not "added").
- If there are multiple logical changes, use a primary message and note the rest in the body.
- Include a body only when it adds meaningful context; wrap it at 72 characters.

Output only the commit message text, ready to paste into `git commit -m "..."`.