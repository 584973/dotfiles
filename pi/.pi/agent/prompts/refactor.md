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

Before changing anything, briefly explain the plan. Then show the refactored code with minimal diff-style comments (e.g., `// extracted helper`) where the change is non-obvious.