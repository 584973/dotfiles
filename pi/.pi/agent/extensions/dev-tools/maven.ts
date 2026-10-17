/**
 * Maven build tool. The goal list is a closed enum, so the model can select a
 * lifecycle phase but cannot invent flags such as `-Dmaven.repo.local=...` or
 * plugin goals that execute arbitrary code.
 */

import { existsSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { requireSafeArgument, resolveDirectory, runCommand, toolResult } from "./runner.ts";

const MAVEN_GOALS = [
	"clean",
	"validate",
	"compile",
	"test",
	"package",
	"verify",
	"install",
	"dependency:tree",
] as const;

const MODULE_PATTERN = /^[A-Za-z0-9._-]+$/;

const MavenParams = Type.Object({
	project: Type.Optional(
		Type.String({ description: "Maven project directory containing pom.xml (default: session working directory)" }),
	),
	goals: Type.Optional(
		Type.Array(
			Type.String({
				enum: [...MAVEN_GOALS],
				description:
					'Lifecycle goal: clean, validate, compile, test, package, verify, install, or dependency:tree',
			}),
			{
				description: 'Goals to run in order, e.g. ["clean","install"] or ["test"] (default: ["clean","install"])',
			},
		),
	),
	modules: Type.Optional(
		Type.Array(Type.String(), {
			description: 'Artifact ids or relative paths for -pl, e.g. ["api","core"] (default: whole reactor)',
		}),
	),
	alsoMake: Type.Optional(
		Type.Boolean({ description: "Add -am so the selected modules' dependencies are built too" }),
	),
	offline: Type.Optional(Type.Boolean({ description: "Add -o to run without contacting remote repositories" })),
	skipTests: Type.Optional(Type.Boolean({ description: "Add -DskipTests to compile tests but not run them" })),
});

export function registerMavenTools(pi: ExtensionAPI): void {
	pi.registerTool({
		name: "mvn_build",
		label: "Maven build",
		description:
			"Run Apache Maven against a project's pom.xml. Goals are limited to clean, validate, compile, test, package, verify, install, and dependency:tree; other flags and plugin goals are not accepted. Build output is returned tail-first, so failures show their stack traces. A non-zero exit is reported as an error with the full Maven output.",
		promptSnippet: "Run Maven lifecycle goals (clean, install, test, verify, ...) on a pom.xml project",
		promptGuidelines: [
			"Use mvn_build for Maven goals; there is no shell tool available.",
			"Prefer goals [\"clean\",\"install\"] to verify a change end to end, or [\"test\"] for a faster loop.",
			"If a build needs a flag this tool does not expose, ask the user instead of looking for another command runner.",
		],
		parameters: MavenParams,
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const project = resolveDirectory(params.project, ctx.cwd, "Maven project directory");
			if (!existsSync(join(project, "pom.xml"))) {
				throw new Error(`no pom.xml in ${project}`);
			}

			const goals = params.goals?.length ? params.goals : ["clean", "install"];
			for (const goal of goals) {
				if (!(MAVEN_GOALS as readonly string[]).includes(goal)) {
					throw new Error(`unsupported Maven goal: ${goal}`);
				}
			}

			const modules = (params.modules ?? []).map((module) => requireSafeArgument(module, "module"));
			for (const module of modules) {
				if (!MODULE_PATTERN.test(module)) throw new Error(`invalid -pl module selector: ${module}`);
			}

			// -B and -ntp keep logs non-interactive and free of transfer progress noise.
			const args = ["-B", "-ntp", ...goals];
			if (modules.length > 0) args.push("-pl", modules.join(","));
			if (params.alsoMake) args.push("-am");
			if (params.offline) args.push("-o");
			if (params.skipTests) args.push("-DskipTests");

			const result = await runCommand("mvn", args, { cwd: project, signal });
			return toolResult(result, { project, goals, modules, alsoMake: params.alsoMake ?? false });
		},
	});
}
