/**
 * Git tools: read-only inspection plus a guarded commit.
 *
 * History rewriting, pushing, config writes, and anything else that is hard to
 * undo are deliberately absent. Only `status`, `diff`, `log`, and `commit` can
 * be expressed, and every argument is built from validated parameters.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { requireSafeArgument, resolveDirectory, runCommand, toolResult } from "./runner.ts";

const RepoParam = { repo: Type.Optional(Type.String({ description: "Repository directory (default: session working directory)" })) };

export function registerGitTools(pi: ExtensionAPI): void {
	pi.registerTool({
		name: "git_status",
		label: "Git status",
		description: "Show the working tree status of a repository (branch, staged, modified, and untracked paths).",
		promptSnippet: "Show working tree status for a repository",
		parameters: Type.Object({ ...RepoParam }),
		annotations: { readOnlyHint: true },
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const result = await runCommand(
				"git",
				["-C", repo, "status", "--short", "--branch", "--untracked-files=normal"],
				{ cwd: repo, signal },
			);
			return toolResult(result, { repo });
		},
	});

	pi.registerTool({
		name: "git_diff",
		label: "Git diff",
		description:
			"Show unstaged changes, or staged changes with staged=true. Optionally summarize with stat=true or narrow to one path.",
		promptSnippet: "Show a repository diff, optionally staged or summarized",
		parameters: Type.Object({
			...RepoParam,
			staged: Type.Optional(Type.Boolean({ description: "Show changes staged for the next commit instead of unstaged ones" })),
			stat: Type.Optional(Type.Boolean({ description: "Show a diffstat summary instead of the full patch" })),
			path: Type.Optional(Type.String({ description: "Limit the diff to one path or pathspec" })),
		}),
		annotations: { readOnlyHint: true },
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const args = ["-C", repo, "diff"];
			if (params.staged) args.push("--cached");
			if (params.stat) args.push("--stat");
			if (params.path) args.push("--", requireSafeArgument(params.path, "path"));
			const result = await runCommand("git", args, { cwd: repo, signal });
			return toolResult(result, { repo, staged: params.staged ?? false });
		},
	});

	pi.registerTool({
		name: "git_log",
		label: "Git log",
		description: "Show recent commits, one line each, optionally limited to a path.",
		promptSnippet: "Show recent commit history",
		parameters: Type.Object({
			...RepoParam,
			count: Type.Optional(Type.Integer({ minimum: 1, maximum: 100, description: "Number of commits to show (default: 20)" })),
			path: Type.Optional(Type.String({ description: "Limit history to one path" })),
		}),
		annotations: { readOnlyHint: true },
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const count = params.count ?? 20;
			const args = ["-C", repo, "log", "--max-count", String(count), "--oneline", "--decorate"];
			if (params.path) args.push("--", requireSafeArgument(params.path, "path"));
			const result = await runCommand("git", args, { cwd: repo, signal });
			return toolResult(result, { repo, count });
		},
	});

	pi.registerTool({
		name: "git_commit",
		label: "Git commit",
		description:
			"Create a commit in a repository. Commits what is already staged unless all=true (stage tracked modifications) or explicit paths are given. Nothing is pushed, and hooks run as configured. Returns the new commit summary.",
		promptSnippet: "Create a git commit from staged changes, -a, or explicit paths",
		promptGuidelines: [
			"Use git_commit only after the user asked for a commit.",
			"Never amend or rewrite history through this tool; it always creates a new commit.",
		],
		parameters: Type.Object({
			...RepoParam,
			message: Type.String({ description: "Commit message. Repeat text with newlines for a subject plus body." }),
			all: Type.Optional(Type.Boolean({ description: "Add -a to stage modifications of tracked files before committing" })),
			paths: Type.Optional(
				Type.Array(Type.String(), { description: "Commit only these paths (passed after --)" }),
			),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			// A commit message may span lines, so it only needs the flag guard, not
			// the newline guard that `requireSafeArgument` applies to paths.
			const message = params.message.replace(/\r\n/g, "\n").trim();
			if (!message) throw new Error("commit message must not be empty");
			if (message.startsWith("-")) throw new Error('commit message must not start with "-"');
			const paths = (params.paths ?? []).map((path) => requireSafeArgument(path, "path"));

			const args = ["-C", repo, "commit", "-m", message];
			if (params.all) args.push("-a");
			if (paths.length > 0) args.push("--", ...paths);

			const result = await runCommand("git", args, { cwd: repo, signal });
			if (!result.ok) return toolResult(result, { repo, committed: false });

			const summary = await runCommand(
				"git",
				["-C", repo, "show", "--stat", "--summary", "--format=%h%n%s", "HEAD"],
				{ cwd: repo, signal },
			);
			return toolResult(
				{
					...result,
					text: summary.ok ? `${result.text}\n\n--- HEAD ---\n${summary.text}` : result.text,
				},
				{ repo, committed: true, sha: summary.ok ? summary.text.split("\n")[0]?.trim() : undefined },
			);
		},
	});
}
