/**
 * Git tools: read-only inspection plus a guarded commit.
 *
 * History rewriting, pushing, config writes, and anything else that is hard to
 * undo are deliberately absent. Only `status`, `diff`, `log`, and `commit` can
 * be expressed, and every argument is built from validated parameters.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import {
	requireBranchName,
	requireRemoteName,
	requireSafeArgument,
	requireText,
	resolveDirectory,
	runCapture,
	runCommand,
	toolResult,
} from "./runner.ts";

const RepoParam = { repo: Type.Optional(Type.String({ description: "Repository directory (default: session working directory)" })) };

/** Branch name for the current HEAD, with a clear message for detached HEAD. */
async function currentBranch(repo: string, signal?: AbortSignal): Promise<string> {
	const capture = await runCapture("git", ["-C", repo, "symbolic-ref", "--short", "-q", "HEAD"], { cwd: repo, signal });
	if (!capture.ok || !capture.stdout) {
		throw new Error(`cannot determine the current branch in ${repo} (detached HEAD, or not a git repository)`);
	}
	return capture.stdout;
}

/** The branch's configured upstream, or undefined when it has none. */
async function upstreamOf(repo: string, branch: string, signal?: AbortSignal): Promise<string | undefined> {
	const capture = await runCapture(
		"git",
		["-C", repo, "for-each-ref", "--format=%(upstream:short)", `refs/heads/${branch}`],
		{ cwd: repo, signal },
	);
	return capture.ok && capture.stdout ? capture.stdout : undefined;
}

/**
 * The repository's default branch. Prefers origin/HEAD, which is a local ref, so
 * this never hits the network; falls back to the conventional names.
 */
async function defaultBranch(repo: string, signal?: AbortSignal): Promise<string | undefined> {
	const head = await runCapture("git", ["-C", repo, "symbolic-ref", "--short", "-q", "refs/remotes/origin/HEAD"], {
		cwd: repo,
		signal,
	});
	if (head.ok && head.stdout.startsWith("origin/")) return head.stdout.slice("origin/".length);

	const locals = await runCapture("git", ["-C", repo, "for-each-ref", "--format=%(refname:short)", "refs/heads"], {
		cwd: repo,
		signal,
	});
	const names = locals.stdout.split("\n").filter(Boolean);
	return ["main", "master"].find((candidate) => names.includes(candidate));
}

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
			const message = requireText(params.message, "commit message");
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

	pi.registerTool({
		name: "git_stage",
		label: "Git stage",
		description:
			"Stage explicit paths for the next commit. Files and directories are both accepted, and nothing outside the given paths is staged. Staging everything is not offered on purpose.",
		promptSnippet: "Stage specific paths for the next commit",
		promptGuidelines: [
			"Stage only the paths that belong to the requested change rather than sweeping in unrelated edits.",
		],
		parameters: Type.Object({
			...RepoParam,
			paths: Type.Array(Type.String(), { description: "Files or directories to stage" }),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			if (!params.paths?.length) throw new Error("git_stage needs at least one path");
			const paths = params.paths.map((path) => requireSafeArgument(path, "path"));

			const result = await runCommand("git", ["-C", repo, "add", "--", ...paths], { cwd: repo, signal });
			if (!result.ok) return toolResult(result, { repo, staged: [] });

			// `git add` is silent, so report what the index now holds.
			const status = await runCommand("git", ["-C", repo, "status", "--short"], { cwd: repo, signal });
			return toolResult(
				{ ...result, text: `${result.text}\n\n--- status ---\n${status.text}` },
				{ repo, staged: paths },
			);
		},
	});

	pi.registerTool({
		name: "git_push",
		label: "Git push",
		description:
			"Push a branch to a remote. Force pushes, deletions, and refspecs are not expressible: the tool always pushes a single branch by name. Pushing the repository's default branch (main) is refused unless allowDefault=true is set explicitly.",
		promptSnippet: "Push the current branch to a remote",
		promptGuidelines: [
			"Push the working branch and open a pull request rather than pushing to main directly.",
		],
		parameters: Type.Object({
			...RepoParam,
			branch: Type.Optional(Type.String({ description: "Branch to push (default: the current branch)" })),
			remote: Type.Optional(Type.String({ description: 'Remote name (default: "origin")' })),
			setUpstream: Type.Optional(
				Type.Boolean({ description: "Add --set-upstream. Defaults to true when the branch has no upstream yet." }),
			),
			allowDefault: Type.Optional(
				Type.Boolean({ description: "Required to push the repository's default branch directly" }),
			),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const remote = params.remote ? requireRemoteName(params.remote) : "origin";
			const branch = params.branch ? requireBranchName(params.branch, "branch") : await currentBranch(repo, signal);
			const base = await defaultBranch(repo, signal);

			if (base && branch === base && !params.allowDefault) {
				throw new Error(
					`refusing to push the default branch (${branch}) directly: open a pull request, or pass allowDefault=true if that is really intended`,
				);
			}

			const upstream = await upstreamOf(repo, branch, signal);
			const args = ["-C", repo, "push"];
			if (!upstream && params.setUpstream !== false) args.push("--set-upstream");
			args.push(remote, branch);

			const result = await runCommand("git", args, { cwd: repo, signal });
			return toolResult(result, { repo, remote, branch, defaultBranch: base ?? null, setUpstream: !upstream });
		},
	});

	pi.registerTool({
		name: "git_branch",
		label: "Git branch",
		description:
			"List local branches with their upstreams, switch to an existing branch, or create one (and switch to it) from an optional starting ref. Deleting and renaming branches are not offered.",
		promptSnippet: "List, create, or switch local branches",
		promptGuidelines: [
			"Create a branch with git_branch before committing work that should become a pull request.",
		],
		parameters: Type.Object({
			...RepoParam,
			name: Type.Optional(Type.String({ description: "Branch to switch to. Omit to list local branches." })),
			create: Type.Optional(Type.Boolean({ description: "Create the branch (git switch -c) instead of switching to it" })),
			from: Type.Optional(Type.String({ description: "Starting ref when creating, e.g. main" })),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");

			if (!params.name) {
				if (params.create || params.from) {
					throw new Error("git_branch needs a name to create a branch");
				}
				const result = await runCommand("git", ["-C", repo, "branch", "-vv", "--color=never"], { cwd: repo, signal });
				return toolResult(result, { repo, listed: true });
			}

			const name = requireBranchName(params.name, "branch name");
			const args = ["-C", repo, "switch"];
			if (params.create) args.push("-c", name);
			else args.push(name);
			if (params.from) args.push(requireBranchName(params.from, "starting ref"));

			const result = await runCommand("git", args, { cwd: repo, signal });
			return toolResult(result, { repo, branch: name, created: params.create ?? false, from: params.from ?? null });
		},
	});

	pi.registerTool({
		name: "git_fetch",
		label: "Git fetch",
		description: "Fetch from a remote, updating remote-tracking refs. Changes nothing in the working tree or local branches.",
		promptSnippet: "Fetch remote refs",
		parameters: Type.Object({
			...RepoParam,
			remote: Type.Optional(Type.String({ description: 'Remote to fetch (default: "origin")' })),
			prune: Type.Optional(Type.Boolean({ description: "Add --prune to delete stale remote-tracking refs" })),
			all: Type.Optional(Type.Boolean({ description: "Add --all to fetch every remote" })),
		}),
		annotations: { readOnlyHint: true },
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const args = ["-C", repo, "fetch"];
			if (params.all) args.push("--all");
			else args.push(params.remote ? requireRemoteName(params.remote) : "origin");
			if (params.prune) args.push("--prune");

			const result = await runCommand("git", args, { cwd: repo, signal });
			return toolResult(result, { repo, prune: params.prune ?? false, all: params.all ?? false });
		},
	});

	pi.registerTool({
		name: "git_pull",
		label: "Git pull",
		description:
			"Fast-forward the current branch. Uses --ff-only, so it refuses and changes nothing when local and remote histories have diverged instead of creating a merge commit.",
		promptSnippet: "Fast-forward the current branch from its upstream",
		parameters: Type.Object({
			...RepoParam,
			remote: Type.Optional(Type.String({ description: "Remote name, e.g. origin" })),
			branch: Type.Optional(Type.String({ description: "Remote branch to pull, e.g. main" })),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			if (params.branch && !params.remote) throw new Error("git_pull needs both remote and branch, or neither");

			const args = ["-C", repo, "pull", "--ff-only"];
			if (params.remote && params.branch) {
				args.push(requireRemoteName(params.remote), requireBranchName(params.branch, "branch"));
			}

			const result = await runCommand("git", args, { cwd: repo, signal });
			return toolResult(result, { repo, remote: params.remote ?? "upstream", branch: params.branch ?? "current" });
		},
	});
}
