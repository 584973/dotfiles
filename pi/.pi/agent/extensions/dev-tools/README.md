# dev-tools

Narrow, allowlisted replacements for general shell access. The built-in `bash`
tool is disabled in `~/.pi/agent/settings.json`, so everyday workflows get a
dedicated tool instead of a shell.

## Tools

| Tool         | Does                                                                                     |
| ------------ | ---------------------------------------------------------------------------------------- |
| `mvn_build`  | Maven lifecycle goals on a `pom.xml` project: `clean`, `validate`, `compile`, `test`, `package`, `verify`, `install`, `dependency:tree`; optional `-pl` module selection with `-am`, `-o`, `-DskipTests` |
| `git_status` | `git status --short --branch --untracked-files=normal`                                   |
| `git_diff`   | `git diff`, optionally `--cached`, `--stat`, or limited to one path                      |
| `git_log`    | `git log --oneline --decorate --max-count N`, optionally limited to one path             |
| `git_commit` | `git commit -m` with optional `-a` or explicit paths; reports the new commit             |
| `git_stage`  | stage explicit files or directories for the next commit                                   |
| `git_push`   | `git push` of one branch, adding `-u` when it has no upstream. Refuses the repository's default branch unless `allowDefault: true`. Force, delete, and refspec pushes are not expressible |
| `git_branch` | list branches (`git branch -vv`), switch, or create and switch (`git switch -c [from]`)    |
| `git_fetch`  | `git fetch [remote | --all] [--prune]`                                                    |
| `git_pull`   | `git pull --ff-only`, so divergence refuses instead of creating a merge commit            |
| `gh_pr_create` | `gh pr create` with title, multi-line body, base, draft, reviewers                      |
| `gh_pr_view` | one PR: title, state, refs, mergeability, review decision, size, body                     |
| `gh_pr_list` | `gh pr list --state open|closed|merged|all --limit N`                                     |
| `gh_pr_checks` | CI results grouped by `bucket`; pending and failing checks are returned as data, not as a tool error |
| `gh_pr_comment` | post a comment on a PR                                                                  |
| `gh_pr_review` | submit `approve`, `request-changes`, or `comment`                                        |
| `gh_pr_merge` | `squash`, `merge`, or `rebase`, optionally deleting the branch                             |
| `gh_pr_close` | close a PR, optionally with a comment                                                     |
| `run_tests`  | `pytest` (via `uv run`, `.venv/bin/pytest`, or plain `pytest`), `go test ./...`, or a `make` target |

All `gh_*` tools run with the repository directory as their working directory, so gh
resolves the repository from the git remote rather than from a slug the model supplies.

## Design rules

- Commands run through `runCommand()` in `runner.ts` with an argv array, never a
  shell. Pipes, redirections, globs, and `$(...)` are not expressible.
- Parameters are closed enums (`mvn_build.goals`, `run_tests.runner`) or
  pattern-checked strings (`requireSafeArgument` rejects a leading `-` and
  embedded newlines). No free-form flags are accepted anywhere.
- Writes that are hard to undo are absent on purpose: no `push`, `reset`,
  `clean`, `--amend`, dependency installation, or git config changes.
- Output is tail-truncated to pi's limits (2000 lines / 50KB). While a run is
  truncated or failed, the complete log stays at the path reported in
  `details.logPath`; a fully successful, untruncated run deletes its log.
- A non-zero exit is returned as `isError: true` with the output attached, so
  build failures reach the model instead of raising.
- `gh_pr_checks` is the one exception: gh exits non-zero for failing or pending
  checks as well as for real errors, so a successful JSON response is reported as
  data and only an unparseable response becomes an error.

## Blocked by the permission policy

`pi-permission-system/config.json` denies `ctx_execute`, `ctx_execute_file`, and
`ctx_batch_execute` from the context-mode package. Those three run arbitrary
shell or code as the real user, which would make removing the `bash` tool
cosmetic. The knowledge-base tools (`ctx_search`, `ctx_index`, `ctx_stats`, ...)
stay allowed. A denied tool is still listed to the model but every call is
rejected at the gate.

## Adding a family

Add `something.ts` beside this file exporting `registerSomethingTools(pi: ExtensionAPI)`,
follow the rules above, and call it from `index.ts`. Register each new tool name
in `../pi-permission-system/config.json` (`"<tool>": "allow"`) so it does not
prompt on every call.
