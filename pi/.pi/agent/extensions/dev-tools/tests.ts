/**
 * Test and task runners for the Python, Go, and Make-based hobby projects.
 *
 * Each runner maps to one known executable. Flags beyond the exposed ones
 * cannot be passed, so tool selection stays reviewable.
 */

import { existsSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { requireSafeArgument, resolveDirectory, runCommand, toolResult, commandExists } from "./runner.ts";

const MAKE_TARGET_PATTERN = /^[A-Za-z0-9][A-Za-z0-9._:%-]*$/;

/**
 * Candidate invocations in preference order, so tests import the project's own
 * dependencies. The first one actually installed on this machine wins.
 */
function pytestInvocation(directory: string): { command: string; args: string[] } | undefined {
	const candidates: { command: string; args: string[] }[] = [];
	if (existsSync(join(directory, "uv.lock"))) candidates.push({ command: "uv", args: ["run", "pytest"] });
	const venvPytest = join(directory, ".venv", "bin", "pytest");
	if (existsSync(venvPytest)) candidates.push({ command: venvPytest, args: [] });
	candidates.push({ command: "pytest", args: [] });
	return candidates.find((candidate) => commandExists(candidate.command));
}

const RunTestsParams = Type.Object({
	runner: Type.Union([Type.Literal("pytest"), Type.Literal("go"), Type.Literal("make")], {
		description: "Which runner to use",
	}),
	directory: Type.Optional(
		Type.String({ description: "Project directory to run in (default: session working directory)" }),
	),
	path: Type.Optional(
		Type.String({ description: "pytest: test file or directory; go: package pattern (default: ./...)" }),
	),
	target: Type.Optional(Type.String({ description: "make: target name (default: the Makefile's first target)" })),
	keyword: Type.Optional(
		Type.String({ description: "pytest: -k expression; go: -run regexp" }),
	),
	verbose: Type.Optional(Type.Boolean({ description: "Ask the runner for per-test output (-v)" })),
});

export function registerTestTools(pi: ExtensionAPI): void {
	pi.registerTool({
		name: "run_tests",
		label: "Run tests",
		description:
			"Run the test suite of a project: pytest (via uv run, a local .venv, or plain pytest), go test, or a make target. Returns the runner's output tail-first so failures are visible. A non-zero exit is reported as an error with the output attached.",
		promptSnippet: "Run pytest, go test, or a make target in a project",
		promptGuidelines: [
			"Use run_tests instead of a shell command; there is no shell tool available.",
			"Dependencies are not installed by this tool. If imports fail, ask the user to sync the environment.",
		],
		parameters: RunTestsParams,
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const directory = resolveDirectory(params.directory, ctx.cwd, "project directory");
			const keyword = params.keyword ? requireSafeArgument(params.keyword, "keyword") : undefined;
			const path = params.path ? requireSafeArgument(params.path, "path") : undefined;
			const verbose = params.verbose ? ["-v"] : [];

			switch (params.runner) {
				case "pytest": {
					const invocation = pytestInvocation(directory);
					if (!invocation) {
						throw new Error(
							`no pytest available for ${directory}: no uv on PATH, no .venv/bin/pytest, and no pytest on PATH. ` +
								"Set up the project environment first (for example `uv sync`) before running its tests.",
						);
					}
					const args = [...invocation.args, ...(path ? [path] : []), ...(keyword ? ["-k", keyword] : []), ...verbose];
					const result = await runCommand(invocation.command, args, { cwd: directory, signal });
					return toolResult(result, { runner: "pytest", directory, command: invocation.command });
				}
				case "go": {
					const args = ["test", path ?? "./...", ...(keyword ? ["-run", keyword] : []), ...verbose];
					const result = await runCommand("go", args, { cwd: directory, signal });
					return toolResult(result, { runner: "go", directory });
				}
				case "make": {
					if (!["Makefile", "makefile", "GNUmakefile"].some((name) => existsSync(join(directory, name)))) {
						throw new Error(`no Makefile in ${directory}`);
					}
					let args: string[] = [];
					if (params.target) {
						const target = requireSafeArgument(params.target, "make target");
						if (!MAKE_TARGET_PATTERN.test(target)) throw new Error(`invalid make target: ${target}`);
						args = [target];
					}
					const result = await runCommand("make", args, { cwd: directory, signal });
					return toolResult(result, { runner: "make", directory, target: params.target ?? null });
				}
			}
		},
	});
}
