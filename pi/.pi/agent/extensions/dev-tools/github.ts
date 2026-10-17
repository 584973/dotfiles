/**
 * GitHub pull request tools, wrapping the `gh` CLI.
 *
 * Every call runs with the repository directory as the working directory, so gh
 * resolves the repository from the git remote instead of from a slug the model
 * supplies. Read-only tools are separated from publishing ones (comment, review,
 * merge, close) so the permission policy can gate them independently.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import {
	requireBranchName,
	requireHandle,
	requireText,
	resolveDirectory,
	runCapture,
	runCommand,
	textResult,
	toolResult,
} from "./runner.ts";

const RepoParam = {
	repo: Type.Optional(Type.String({ description: "Repository directory (default: session working directory)" })),
};

const NumberParam = {
	number: Type.Optional(
		Type.Integer({ minimum: 1, description: "Pull request number (default: the PR for the current branch)" }),
	),
};

const PR_LIST_FIELDS = "number,title,state,isDraft,headRefName,baseRefName,url";
const PR_VIEW_FIELDS =
	"number,title,state,isDraft,url,baseRefName,headRefName,mergeable,mergeStateStatus,reviewDecision,additions,deletions,changedFiles,body";

interface PrListEntry {
	number: number;
	title: string;
	state: string;
	isDraft?: boolean;
	headRefName?: string;
	baseRefName?: string;
	url?: string;
}

interface PrView extends PrListEntry {
	mergeable?: string;
	mergeStateStatus?: string;
	reviewDecision?: string;
	additions?: number;
	deletions?: number;
	changedFiles?: number;
	body?: string;
}

interface CheckEntry {
	name: string;
	state: string;
	bucket?: string;
	link?: string;
	event?: string;
}

function parseJson<T>(text: string): T | undefined {
	try {
		return JSON.parse(text) as T;
	} catch {
		return undefined;
	}
}

function formatPrList(items: PrListEntry[]): string {
	if (items.length === 0) return "(no pull requests)";
	return items
		.map((pr) => {
			const flags = [pr.state, pr.isDraft ? "draft" : undefined].filter(Boolean).join(", ");
			const refs = pr.headRefName ? ` (${pr.headRefName} -> ${pr.baseRefName ?? "?"})` : "";
			return `#${pr.number} [${flags}] ${pr.title}${refs}\n   ${pr.url ?? ""}`;
		})
		.join("\n");
}

function formatPrView(pr: PrView): string {
	const header = [
		`#${pr.number} [${pr.state}${pr.isDraft ? ", draft" : ""}] ${pr.title}`,
		pr.url ?? "",
		`${pr.headRefName ?? "?"} -> ${pr.baseRefName ?? "?"} | ${pr.mergeable ?? "?"} / ${pr.mergeStateStatus ?? "?"} | review: ${pr.reviewDecision || "none"}`,
		`+${pr.additions ?? 0} -${pr.deletions ?? 0}, ${pr.changedFiles ?? 0} files`,
	]
		.filter(Boolean)
		.join("\n");
	const body = pr.body?.trim();
	return body ? `${header}\n\n--- body ---\n${body}` : header;
}

function formatChecks(checks: CheckEntry[]): string {
	if (checks.length === 0) return "(no checks)";
	const counts = new Map<string, number>();
	for (const check of checks) {
		const key = check.bucket ?? check.state.toLowerCase();
		counts.set(key, (counts.get(key) ?? 0) + 1);
	}
	const summary = [...counts.entries()].map(([key, count]) => `${key}: ${count}`).join(", ");
	const lines = checks.map((check) => `[${check.bucket ?? check.state}] ${check.name}${check.link ? ` ${check.link}` : ""}`);
	return `${summary}\n${lines.join("\n")}`;
}

/** Shared shape for the read-only tools: run gh, then format its JSON. */
async function ghJson<T>(
	repo: string,
	args: string[],
	signal: AbortSignal | undefined,
): Promise<{ ok: boolean; parsed?: T; stdout: string; stderr: string; exitCode: number }> {
	const capture = await runCapture("gh", args, { cwd: repo, signal });
	return {
		ok: capture.ok,
		parsed: parseJson<T>(capture.stdout),
		stdout: capture.stdout,
		stderr: capture.stderr,
		exitCode: capture.exitCode,
	};
}

export function registerGithubTools(pi: ExtensionAPI): void {
	pi.registerTool({
		name: "gh_pr_create",
		label: "Create pull request",
		description:
			"Create a pull request for the current branch with `gh pr create`. The body is required and accepts multi-line markdown. Nothing is merged or pushed by this tool.",
		promptSnippet: "Open a pull request for the current branch",
		promptGuidelines: [
			"Before gh_pr_create, commit the work and push the branch with git_push.",
			"Write the PR body so it states what changed, how to apply it, and how it was verified.",
			"Title in this repository follows `(scope) short imperative summary`, e.g. `(pi) add push and pull request tools`.",
		],
		parameters: Type.Object({
			...RepoParam,
			title: Type.String({ description: "PR title" }),
			body: Type.String({ description: "PR body as markdown; newlines are preserved" }),
			base: Type.Optional(Type.String({ description: "Base branch (default: the repository default branch)" })),
			draft: Type.Optional(Type.Boolean({ description: "Mark the pull request as a draft" })),
			reviewers: Type.Optional(Type.Array(Type.String(), { description: "Reviewer logins or org/team handles" })),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const title = requireText(params.title, "PR title");
			const body = requireText(params.body, "PR body");

			const args = ["pr", "create", "--title", title, "--body", body];
			if (params.base) args.push("--base", requireBranchName(params.base, "base branch"));
			if (params.draft) args.push("--draft");
			for (const reviewer of params.reviewers ?? []) args.push("--reviewer", requireHandle(reviewer, "reviewer"));

			const result = await runCommand("gh", args, { cwd: repo, signal });
			return toolResult(result, { repo, base: params.base ?? "default", draft: params.draft ?? false });
		},
	});

	pi.registerTool({
		name: "gh_pr_view",
		label: "View pull request",
		description:
			"Show one pull request: title, state, refs, mergeability, review decision, size, and body. Defaults to the PR for the current branch.",
		promptSnippet: "View a pull request description and status",
		parameters: Type.Object({ ...RepoParam, ...NumberParam }),
		annotations: { readOnlyHint: true },
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const args = ["pr", "view", ...(params.number ? [String(params.number)] : []), "--json", PR_VIEW_FIELDS];
			const result = await ghJson<PrView>(repo, args, signal);
			if (!result.parsed) {
				return textResult(result.stderr || result.stdout || "gh pr view returned no data", { repo }, !result.ok);
			}
			return textResult(formatPrView(result.parsed), { repo, number: result.parsed.number });
		},
	});

	pi.registerTool({
		name: "gh_pr_list",
		label: "List pull requests",
		description: "List pull requests for the repository, filtered by state.",
		promptSnippet: "List open or closed pull requests",
		parameters: Type.Object({
			...RepoParam,
			state: Type.Optional(
				Type.Union([Type.Literal("open"), Type.Literal("closed"), Type.Literal("merged"), Type.Literal("all")], {
					description: 'Which pull requests to list (default: "open")',
				}),
			),
			limit: Type.Optional(Type.Integer({ minimum: 1, maximum: 50, description: "Maximum results (default: 20)" })),
		}),
		annotations: { readOnlyHint: true },
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const args = [
				"pr",
				"list",
				"--state",
				params.state ?? "open",
				"--limit",
				String(params.limit ?? 20),
				"--json",
				PR_LIST_FIELDS,
			];
			const result = await ghJson<PrListEntry[]>(repo, args, signal);
			if (!result.parsed) {
				return textResult(result.stderr || result.stdout || "gh pr list returned no data", { repo }, !result.ok);
			}
			return textResult(formatPrList(result.parsed), { repo, count: result.parsed.length });
		},
	});

	pi.registerTool({
		name: "gh_pr_checks",
		label: "Pull request checks",
		description:
			"Show CI check results for a pull request, grouped by pass/fail/pending/skipping. Pending or failing checks are reported as data, not as a tool error.",
		promptSnippet: "Show CI check results for a pull request",
		parameters: Type.Object({
			...RepoParam,
			...NumberParam,
			requiredOnly: Type.Optional(Type.Boolean({ description: "Only show checks that are required to merge" })),
		}),
		annotations: { readOnlyHint: true },
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const args = [
				"pr",
				"checks",
				...(params.number ? [String(params.number)] : []),
				...(params.requiredOnly ? ["--required"] : []),
				"--json",
				"name,state,bucket,link,event",
			];
			const result = await ghJson<CheckEntry[]>(repo, args, signal);
			if (!result.parsed) {
				// gh exits non-zero both for failing checks and for real errors; only
				// the latter reaches here, because failing checks still print JSON.
				return textResult(result.stderr || result.stdout || "gh pr checks returned no data", { repo }, true);
			}
			return textResult(formatChecks(result.parsed), { repo, count: result.parsed.length });
		},
	});

	pi.registerTool({
		name: "gh_pr_comment",
		label: "Comment on pull request",
		description: "Post a plain comment on a pull request. This publishes text under your account.",
		promptSnippet: "Post a comment on a pull request",
		parameters: Type.Object({
			...RepoParam,
			...NumberParam,
			body: Type.String({ description: "Comment body as markdown" }),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const args = [
				"pr",
				"comment",
				...(params.number ? [String(params.number)] : []),
				"--body",
				requireText(params.body, "comment body"),
			];
			const result = await runCommand("gh", args, { cwd: repo, signal });
			return toolResult(result, { repo, number: params.number ?? null });
		},
	});

	pi.registerTool({
		name: "gh_pr_review",
		label: "Review pull request",
		description:
			"Submit an approve, request-changes, or comment review on a pull request. Approving and requesting changes affect the PR's review state.",
		promptSnippet: "Approve, request changes on, or comment on a pull request review",
		parameters: Type.Object({
			...RepoParam,
			...NumberParam,
			action: Type.Union(
				[Type.Literal("approve"), Type.Literal("request-changes"), Type.Literal("comment")],
				{ description: "Review action to submit" },
			),
			body: Type.Optional(Type.String({ description: "Review body. Required for request-changes and comment." })),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const flag = { approve: "--approve", "request-changes": "--request-changes", comment: "--comment" }[
				params.action
			];
			const args = ["pr", "review", ...(params.number ? [String(params.number)] : []), flag];
			if (params.body) args.push("--body", requireText(params.body, "review body"));
			else if (params.action !== "approve") throw new Error(`gh_pr_review needs a body to ${params.action}`);

			const result = await runCommand("gh", args, { cwd: repo, signal });
			return toolResult(result, { repo, action: params.action, number: params.number ?? null });
		},
	});

	pi.registerTool({
		name: "gh_pr_merge",
		label: "Merge pull request",
		description:
			"Merge a pull request with the chosen method. This changes remote history and cannot be undone through this tool, so it is the most consequential tool here.",
		promptSnippet: "Squash, merge, or rebase a pull request",
		promptGuidelines: ["Confirm with the user before merging unless they already asked for that exact merge."],
		parameters: Type.Object({
			...RepoParam,
			...NumberParam,
			method: Type.Union([Type.Literal("squash"), Type.Literal("merge"), Type.Literal("rebase")], {
				description: "Merge method",
			}),
			deleteBranch: Type.Optional(Type.Boolean({ description: "Delete the local and remote branch after merging" })),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const flag = { squash: "--squash", merge: "--merge", rebase: "--rebase" }[params.method];
			const args = [
				"pr",
				"merge",
				...(params.number ? [String(params.number)] : []),
				flag,
				...(params.deleteBranch ? ["--delete-branch"] : []),
			];
			const result = await runCommand("gh", args, { cwd: repo, signal });
			return toolResult(result, { repo, method: params.method, number: params.number ?? null });
		},
	});

	pi.registerTool({
		name: "gh_pr_close",
		label: "Close pull request",
		description: "Close a pull request without merging, optionally leaving a comment.",
		promptSnippet: "Close a pull request",
		parameters: Type.Object({
			...RepoParam,
			...NumberParam,
			comment: Type.Optional(Type.String({ description: "Comment to leave when closing" })),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const repo = resolveDirectory(params.repo, ctx.cwd, "repository directory");
			const args = [
				"pr",
				"close",
				...(params.number ? [String(params.number)] : []),
				...(params.comment ? ["--comment", requireText(params.comment, "closing comment")] : []),
			];
			const result = await runCommand("gh", args, { cwd: repo, signal });
			return toolResult(result, { repo, number: params.number ?? null });
		},
	});
}
