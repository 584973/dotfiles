---
description: Review code changes and return a ship/no-ship verdict
argument-hint: "[file or diff]"
---
Review the following code: $@

If no code is provided, run `git diff` first to identify the current changes. Read the relevant repository instruction files, surrounding implementation, and nearby tests before reaching a verdict.

Review only issues introduced by the change or directly required for its correctness. Do not turn the review into an unrelated refactor or style sweep.

Check:

1. **Correctness** — logic errors, edge cases, null handling, state transitions, races, and incorrect assumptions
2. **Security** — injection, authorization gaps, path traversal, unsafe parsing, secret exposure, and insecure defaults
3. **Compatibility** — broken public APIs, migrations, platform behavior, configuration changes, and error contracts
4. **Performance** — unnecessary work, blocking hot paths, unbounded memory, N+1 operations, and missing limits
5. **Tests** — coverage for changed behavior, important failure paths, and regressions
6. **Maintainability** — unnecessary complexity, coupling, duplication, and divergence from local patterns

For every finding, include:
- priority: **P0** (release blocker), **P1** (high-impact bug), **P2** (should fix), or **P3** (minor)
- confidence: high, medium, or low
- file and line/function
- concrete failure or exploit scenario
- smallest reasonable fix

Run the narrowest relevant tests, type checks, or linters when practical. If verification cannot be run, explain why.

Return exactly this structure:

## Verdict
**SHIP**, **SHIP WITH FOLLOW-UP**, or **DO NOT SHIP** — one-sentence reason.

## Findings
| Priority | Confidence | Location | Finding | Suggested fix |
|---|---|---|---|---|
| P1 | high | `path:line` | ... | ... |

If there are no findings, say `No blocking findings.` rather than inventing issues.

## Verification
- `command` — result

## Residual risk
Mention only concrete risks that remain after the checks.