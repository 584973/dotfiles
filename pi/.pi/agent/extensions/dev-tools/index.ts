/**
 * dev-tools — narrow, allowlisted operations that replace general shell access.
 *
 * The built-in `bash` tool is disabled in this configuration, so the workflows
 * that used to go through it now have dedicated tools: Maven goals, git
 * inspection and commit, and the Python/Go/Make test runners.
 *
 * Design rules for this extension:
 *   - Every command runs through `runCommand()` with an argv array, never a shell.
 *   - Parameters are closed enums or pattern-checked strings; free-form flags are
 *     not accepted anywhere, so the model cannot ask for `-Dexec…`, `--force`, or
 *     a path that a CLI would read as an option.
 *   - Anything that writes outside the project (push, reset, clean, install of
 *     dependencies, config writes) is left out on purpose.
 *
 * To add a command family, add a `register*Tools(pi)` module beside this file that
 * follows the same rules and call it below.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { registerGithubTools } from "./github.ts";
import { registerGitTools } from "./git.ts";
import { registerMavenTools } from "./maven.ts";
import { registerTestTools } from "./tests.ts";

export default function devToolsExtension(pi: ExtensionAPI): void {
	registerMavenTools(pi);
	registerGitTools(pi);
	registerGithubTools(pi);
	registerTestTools(pi);
}
