---
description: Write or improve tests for the given code
argument-hint: "<file or function>"
---
Write tests for the following: $@

If nothing is specified above, ask the user what code they would like tests for.

Guidelines:
- Test both happy paths and edge cases (nulls, empty inputs, boundary values, errors)
- Use the project's existing test framework and conventions
- Keep tests focused: one concept per test case
- Use descriptive test names that explain the behavior being verified
- Mock external dependencies (network, file system, time) when appropriate
- Aim for coverage of critical branches, not just line coverage

Inspect the existing tests first. Unless the user explicitly asks for a proposal only, add or improve tests in the repository and run the narrowest relevant test command. Do not duplicate coverage that already exists; report the changed files and validation result.