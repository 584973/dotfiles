---
description: Review code for bugs, security issues, and style problems
argument-hint: "[file or diff]"
---
Review the following code: $@

If no code is provided, run `git diff` first to see current changes. Focus on:

1. **Bugs & Logic Errors** — off-by-one errors, null dereferences, race conditions, incorrect assumptions
2. **Security** — injection vulnerabilities, unsafe deserialization, missing auth checks, secrets exposure
3. **Performance** — unnecessary allocations, N+1 queries, blocking calls in hot paths
4. **Maintainability** — unclear naming, missing tests, tight coupling, duplicated logic
5. **Idioms** — language/framework best practices, modern patterns where applicable

Be specific: cite line numbers or function names, explain why something is problematic, and suggest concrete fixes. Prioritize issues by severity (critical / warning / nitpick).