/**
 * Shared process runner for the dev-tools extension.
 *
 * Commands run through `spawn()` with an explicit argv array, so no shell is
 * involved: quoting, pipes, redirections, globs, and command substitution cannot
 * be expressed at all. Every tool built on this runner validates its own
 * parameters before building that argv.
 */

import { spawn } from "node:child_process";
import { accessSync, constants, createWriteStream, existsSync } from "node:fs";
import { unlink } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { join, resolve } from "node:path";
import {
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	formatSize,
	truncateTail,
} from "@earendil-works/pi-coding-agent";

const DEFAULT_TIMEOUT_MS = 20 * 60 * 1000;
/** In-memory tail kept for the model. The complete stream goes to the log file. */
const TAIL_LIMIT_CHARS = 4 * 1024 * 1024;

export interface ExecResult {
	/** Shell-free rendering of what ran, with unusual arguments quoted for display. */
	command: string;
	cwd: string;
	exitCode: number;
	ok: boolean;
	/** Tail-truncated combined stdout/stderr plus any truncation notes. */
	text: string;
	/** Present only while the full log is still on disk (truncated or failed runs). */
	logPath?: string;
	durationMs: number;
	timedOut: boolean;
}

export interface ExecOptions {
	cwd: string;
	signal?: AbortSignal;
	timeoutMs?: number;
}

export function formatCommand(command: string, args: string[]): string {
	return [command, ...args]
		.map((part) => (/^[A-Za-z0-9_@%+=:,./-]+$/.test(part) ? part : JSON.stringify(part)))
		.join(" ");
}

export async function runCommand(
	command: string,
	args: string[],
	options: ExecOptions,
): Promise<ExecResult> {
	if (!existsSync(options.cwd)) {
		throw new Error(`working directory does not exist: ${options.cwd}`);
	}

	const timeoutMs = options.timeoutMs ?? DEFAULT_TIMEOUT_MS;
	const startedAt = Date.now();
	const logPath = join(tmpdir(), `pi-dev-${command.replace(/[^A-Za-z0-9]/g, "_")}-${Date.now()}.log`);
	const log = createWriteStream(logPath);
	let tail = "";
	let droppedChars = 0;
	let timedOut = false;
	let spawnError: Error | undefined;
	let exitCode = -1;

	const append = (chunk: Buffer) => {
		log.write(chunk);
		tail += chunk.toString("utf8");
		if (tail.length > TAIL_LIMIT_CHARS) {
			droppedChars += tail.length - TAIL_LIMIT_CHARS;
			tail = tail.slice(-TAIL_LIMIT_CHARS);
		}
	};

	const child = spawn(command, args, {
		cwd: options.cwd,
		stdio: ["ignore", "pipe", "pipe"],
		env: process.env,
	});
	child.stdout?.on("data", append);
	child.stderr?.on("data", append);

	const onAbort = () => child.kill("SIGTERM");
	options.signal?.addEventListener("abort", onAbort, { once: true });

	const timer = setTimeout(() => {
		timedOut = true;
		child.kill("SIGTERM");
		// Escalate for tooling that forks children and ignores SIGTERM (surefire JVMs).
		setTimeout(() => child.kill("SIGKILL"), 10_000).unref();
	}, timeoutMs);
	timer.unref();

	await new Promise<void>((settle) => {
		child.on("error", (error) => {
			spawnError = error;
			settle();
		});
		child.on("close", (code) => {
			exitCode = code ?? -1;
			settle();
		});
	});

	clearTimeout(timer);
	options.signal?.removeEventListener("abort", onAbort);
	await new Promise<void>((settle) => log.end(settle));

	if (spawnError) {
		await unlink(logPath).catch(() => {});
		throw new Error(`could not start \`${command}\`: ${spawnError.message}`);
	}

	const truncation = truncateTail(tail);
	const truncated = truncation.truncated || droppedChars > 0;
	const ok = exitCode === 0 && !timedOut;

	const notes: string[] = [];
	if (timedOut) notes.push(`killed after ${Math.round(timeoutMs / 60_000)} min timeout`);
	if (droppedChars > 0) notes.push(`${formatSize(droppedChars)} of earlier output dropped from the in-memory view`);
	if (truncation.truncated) {
		notes.push(`showing the last ${DEFAULT_MAX_LINES} lines / ${formatSize(DEFAULT_MAX_BYTES)}`);
	}

	let text = truncation.content.trimEnd();
	if (notes.length > 0) notes.push(`full log: ${logPath}`);
	if (!text) text = "(no output)";
	if (notes.length > 0) text = `${notes.map((note) => `[${note}]`).join("\n")}\n${text}`;

	// Successful, complete output is already in `text`, so the log is dead weight.
	if (!truncated && ok) {
		await unlink(logPath).catch(() => {});
		return {
			command: formatCommand(command, args),
			cwd: options.cwd,
			exitCode,
			ok,
			text,
			durationMs: Date.now() - startedAt,
			timedOut,
		};
	}

	return {
		command: formatCommand(command, args),
		cwd: options.cwd,
		exitCode,
		ok,
		text,
		logPath,
		durationMs: Date.now() - startedAt,
		timedOut,
	};
}

/** Builds a pi tool result; a non-zero exit becomes a failed result that still carries output. */
export function toolResult(result: ExecResult, details: Record<string, unknown> = {}) {
	const seconds = Math.round(result.durationMs / 1000);
	return {
		content: [
			{
				type: "text" as const,
				text: [`$ ${result.command}`, `cwd: ${result.cwd}`, `exit: ${result.exitCode} (${seconds}s)`, "", result.text].join(
					"\n",
				),
			},
		],
		details: {
			...details,
			command: result.command,
			cwd: result.cwd,
			exitCode: result.exitCode,
			timedOut: result.timedOut,
			logPath: result.logPath,
		},
		isError: !result.ok,
	};
}

export function expandHome(input: string): string {
	const trimmed = input.trim();
	if (trimmed === "~") return homedir();
	if (trimmed.startsWith("~/")) return join(homedir(), trimmed.slice(2));
	return trimmed;
}

/** Whether an executable can actually be started, used to fail with a usable message. */
export function commandExists(command: string): boolean {
	const isExecutable = (path: string) => {
		try {
			accessSync(path, constants.X_OK);
			return true;
		} catch {
			return false;
		}
	};
	if (command.includes("/")) return isExecutable(command);
	return (process.env.PATH ?? "")
		.split(":")
		.filter(Boolean)
		.some((dir) => isExecutable(join(dir, command)));
}

/** Resolves a user-supplied directory against the session cwd and requires it to exist. */
export function resolveDirectory(input: string | undefined, fallback: string, label: string): string {
	const raw = input?.trim();
	const directory = raw ? resolve(fallback, expandHome(raw)) : resolve(fallback);
	if (!existsSync(directory)) throw new Error(`${label} does not exist: ${directory}`);
	return directory;
}

/** Rejects arguments that a CLI would read as a flag, plus embedded newlines. */
export function requireSafeArgument(value: string, label: string): string {
	const trimmed = value.trim();
	if (!trimmed) throw new Error(`${label} must not be empty`);
	if (trimmed.startsWith("-")) throw new Error(`${label} must not start with "-": ${trimmed}`);
	if (/[\r\n]/.test(value)) throw new Error(`${label} must not contain newlines`);
	return trimmed;
}
