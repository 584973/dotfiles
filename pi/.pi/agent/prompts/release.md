---
description: Check release readiness and prepare a safe release plan
argument-hint: "[version]"
---
Prepare a release assessment for: $@

If no version is provided, determine the next likely semver bump from the repository history and ask for confirmation before making release changes.

Inspect the repository's release instructions, working-tree state, recent commits, tags, package versions, changelogs, and release automation. Do not commit, tag, push, publish, modify dependency locks, or change versions during the assessment.

Check:

1. The working tree is clean or clearly list unrelated changes
2. The requested version is valid and consistent across package metadata
3. User-facing changes are represented in changelogs or release notes
4. Required tests, linters, type checks, and builds are known and passing
5. Release scripts and CI prerequisites are available
6. The version does not already exist as a tag or published release

Return:

## Release assessment
- Version:
- Readiness: READY / BLOCKED / NEEDS CONFIRMATION
- Summary:

## Checks
| Check | Result | Evidence |
|---|---|---|
| ... | pass / fail / unknown | ... |

## Proposed actions
Number the exact files and commands that would be changed or run after approval. Separate safe verification from irreversible actions.

## Approval needed
Clearly state whether confirmation is needed before version changes, commits, tags, pushes, or publishing.