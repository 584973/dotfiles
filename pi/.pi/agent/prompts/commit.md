---
description: Generate a conventional commit message from staged changes
---
Write a concise conventional commit message for the currently staged changes (`git diff --cached`). If there are no staged changes, report that and stop.

Rules:
- Use the format: `type(scope): description` or `type: description`
- Keep the subject line under 72 characters
- Use the imperative mood ("add" not "added")
- If there are multiple logical changes, suggest a primary message and note the rest in the body
- Include a body only if it adds meaningful context (wrap at 72 chars)
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

Output only the commit message text, ready to paste into `git commit -m "..."`.