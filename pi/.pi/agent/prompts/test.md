---
description: Write or improve tests for the given code
argument-hint: "<file or function>"
---
Write comprehensive tests for the provided code. If no file is provided, ask the user which file to test.

Guidelines:
- Test both happy paths and edge cases (nulls, empty inputs, boundary values, errors)
- Use the project's existing test framework and conventions
- Keep tests focused: one concept per test case
- Use descriptive test names that explain the behavior being verified
- Mock external dependencies (network, file system, time) when appropriate
- Aim for coverage of critical branches, not just line coverage

Output the test code. If the project already has tests for this code, suggest improvements or additional cases instead of duplicating them.