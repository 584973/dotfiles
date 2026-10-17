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
| `run_tests`  | `pytest` (via `uv run`, `.venv/bin/pytest`, or plain `pytest`), `go test ./...`, or a `make` target |

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

## Adding a family

Add `something.ts` beside this file exporting `registerSomethingTools(pi: ExtensionAPI)`,
follow the rules above, and call it from `index.ts`. Register each new tool name
in `../pi-permission-system/config.json` (`"<tool>": "allow"`) so it does not
prompt on every call.
