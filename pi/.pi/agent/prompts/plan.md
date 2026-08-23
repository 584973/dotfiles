---
description: Create an evidence-based implementation plan without editing files
argument-hint: "<task or goal>"
---
Create a plan for: $@

If no task is specified, ask what should be planned.

Before planning, inspect the repository instructions and the relevant source, tests, configuration, and recent changes. Do not edit files, install dependencies, commit, or run destructive commands.

Keep the plan concrete and scoped:

1. **Goal** — restate the requested outcome and explicit non-goals
2. **Current state** — cite the relevant files, functions, commands, and constraints
3. **Design** — explain the smallest approach that fits existing patterns
4. **Implementation steps** — order the steps and name every file to create or modify
5. **Risks and decisions** — identify compatibility, security, migration, and testing concerns
6. **Verification** — list exact checks, tests, and expected outcomes

Call out ambiguities that require a user decision instead of silently choosing a behavior. Prefer one actionable plan over a menu of speculative alternatives.