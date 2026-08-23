---
description: Triage bugs, failures, and review findings into actionable priorities
argument-hint: "<issue, failure, or findings>"
---
Triage the following: $@

If no issue, failure, or findings are provided, inspect the current git status and recent test/build output only if available; otherwise ask for the input to triage.

For each item, distinguish observed evidence from hypotheses. Read the relevant source and tests when a repository path, stack trace, or command is available. Do not edit files or apply fixes during triage.

Classify each item:

- **P0** — data loss, active security exposure, release-blocking outage, or unusable core workflow
- **P1** — high-impact regression or common workflow failure with no reasonable workaround
- **P2** — real defect with a workaround, limited scope, or moderate impact
- **P3** — minor edge case, polish, or low-risk technical debt

Return:

## Triage summary
| Priority | Item | Evidence | Likely cause | Next action |
|---|---|---|---|---|
| P1 | ... | ... | confirmed / hypothesis | ... |

## Immediate blockers
List only items that should interrupt current work.

## Follow-up queue
List lower-priority work in recommended order, including the smallest useful reproduction or verification for each item.

Do not inflate severity because an item is inconvenient, and do not call a hypothesis confirmed without repository or command evidence.