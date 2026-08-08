---
description: Refactor code to improve clarity, performance, or structure
argument-hint: "<file or function> [goal]"
---
Refactor the following: $@

If nothing is specified above, ask the user what code they would like refactored.

If a goal is specified (e.g., "reduce nesting", "improve performance", "make testable"), prioritize that.

General principles:
- Prefer clarity over cleverness
- Extract helper functions for repeated logic
- Use meaningful names that reveal intent
- Reduce nesting via early returns or guard clauses
- Remove dead code, unused imports, and obsolete comments
- Keep public APIs stable unless breakage is explicitly requested

Inspect the relevant code and briefly state the plan. Unless the user explicitly asks for a proposal only, edit the repository, run the relevant tests or checks, and summarize the changed files and validation. Add code comments only when the resulting behavior is otherwise non-obvious.