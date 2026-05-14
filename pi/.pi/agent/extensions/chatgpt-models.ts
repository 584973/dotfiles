/**
 * ChatGPT/Codex Usage Extension
 *
 * Command:
 *   /usage  Show ChatGPT/Codex subscription usage remaining
 */

import { spawn } from "node:child_process";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

type RateLimitWindow = {
  usedPercent: number;
  windowDurationMins: number | null;
  resetsAt: number | null;
};

type CreditsSnapshot = {
  hasCredits: boolean;
  unlimited: boolean;
  balance: string | null;
};

type RateLimitSnapshot = {
  limitId: string | null;
  limitName: string | null;
  primary: RateLimitWindow | null;
  secondary: RateLimitWindow | null;
  credits: CreditsSnapshot | null;
  planType: string | null;
  rateLimitReachedType: string | null;
};

type CodexRateLimitsResponse = {
  rateLimits: RateLimitSnapshot;
  rateLimitsByLimitId: Record<string, RateLimitSnapshot | undefined> | null;
};

function formatTime(epochSeconds: number | null | undefined) {
  if (!epochSeconds) return "unknown";
  const date = new Date(epochSeconds * 1000);
  if (Number.isNaN(date.getTime())) return "unknown";
  return date.toLocaleString();
}

function formatDurationUntil(epochSeconds: number | null | undefined) {
  if (!epochSeconds) return "unknown";
  const seconds = Math.max(0, Math.round(epochSeconds - Date.now() / 1000));
  const days = Math.floor(seconds / 86_400);
  const hours = Math.floor((seconds % 86_400) / 3_600);
  const minutes = Math.floor((seconds % 3_600) / 60);

  if (days > 0) return `${days}d ${hours}h`;
  if (hours > 0) return `${hours}h ${minutes}m`;
  return `${minutes}m`;
}

function formatStatusName(status: string | undefined | null) {
  return (status ?? "unknown").replace(/_/g, " ");
}

async function fetchCodexRateLimits(signal?: AbortSignal) {
  return new Promise<CodexRateLimitsResponse>((resolve, reject) => {
    const child = spawn("codex", ["app-server"], {
      stdio: ["pipe", "pipe", "pipe"],
    });

    let output = "";
    let stderr = "";
    let settled = false;

    const timeout = setTimeout(() => {
      finish(new Error("Timed out waiting for codex app-server"));
    }, 15_000);

    const onAbort = () => finish(new Error("Cancelled"));

    const cleanup = () => {
      clearTimeout(timeout);
      signal?.removeEventListener("abort", onAbort);
      if (!child.killed) child.kill();
    };

    const finish = (error: Error | undefined, result?: CodexRateLimitsResponse) => {
      if (settled) return;
      settled = true;
      cleanup();
      if (error) reject(error);
      else resolve(result!);
    };

    signal?.addEventListener("abort", onAbort, { once: true });

    child.on("error", (error) => {
      finish(new Error(`Unable to start codex app-server: ${error.message}`));
    });

    child.stderr.on("data", (chunk) => {
      stderr += chunk.toString();
    });

    child.stdout.on("data", (chunk) => {
      output += chunk.toString();
      const lines = output.split("\n");
      output = lines.pop() ?? "";

      for (const line of lines) {
        if (!line.trim()) continue;

        let message: { id?: number; result?: CodexRateLimitsResponse; error?: { message?: string } };
        try {
          message = JSON.parse(line);
        } catch {
          continue;
        }

        if (message.id !== 2) continue;

        if (message.error) {
          finish(new Error(message.error.message ?? "codex app-server returned an error"));
          return;
        }

        if (message.result) {
          finish(undefined, message.result);
          return;
        }
      }
    });

    child.on("exit", (code) => {
      if (!settled) {
        finish(
          new Error(
            `codex app-server exited before returning usage data${code == null ? "" : ` (code ${code})`}${
              stderr.trim() ? `: ${stderr.trim()}` : ""
            }`,
          ),
        );
      }
    });

    child.stdin.write(
      `${JSON.stringify({
        id: 1,
        method: "initialize",
        params: {
          clientInfo: { name: "pi-usage", title: null, version: "1" },
          capabilities: { experimentalApi: true },
        },
      })}\n`,
    );
    child.stdin.write(`${JSON.stringify({ id: 2, method: "account/rateLimits/read" })}\n`);
  });
}

function formatRateLimitWindow(label: string, window: RateLimitWindow | null) {
  if (!window) return `${label}: unavailable`;

  const used = Math.max(0, Math.min(100, window.usedPercent));
  const remaining = Math.max(0, 100 - used);
  const reset = window.resetsAt
    ? `, resets in ${formatDurationUntil(window.resetsAt)} at ${formatTime(window.resetsAt)}`
    : "";

  return `${label}: ${remaining.toFixed(0)}% left (${used.toFixed(0)}% used${reset})`;
}

function usageReport(response: CodexRateLimitsResponse) {
  const limits = response.rateLimitsByLimitId?.codex ?? response.rateLimits;
  const lines = [
    "ChatGPT/Codex subscription usage",
    "OpenAI reports subscription usage as limit percentages, not remaining token counts.",
    `Plan: ${limits.planType ?? "unknown"}`,
    formatRateLimitWindow("5h limit", limits.primary),
    formatRateLimitWindow("Weekly limit", limits.secondary),
  ];

  if (limits.rateLimitReachedType) {
    lines.push(`Limit reached: ${formatStatusName(limits.rateLimitReachedType)}`);
  }

  if (limits.credits) {
    if (limits.credits.unlimited) {
      lines.push("Credits: unlimited");
    } else if (limits.credits.hasCredits) {
      lines.push(`Credits: ${limits.credits.balance ?? "unknown"}`);
    } else {
      lines.push("Credits: none");
    }
  }

  return lines.join("\n");
}

function sendReport(pi: ExtensionAPI, content: string) {
  pi.sendMessage({
    customType: "chatgpt-usage",
    content,
    display: true,
  });
}

export default function (pi: ExtensionAPI) {
  async function handleUsageCommand(_args: string, ctx: ExtensionCommandContext) {
    await ctx.waitForIdle();

    try {
      const rateLimits = await fetchCodexRateLimits(ctx.signal);
      sendReport(pi, usageReport(rateLimits));
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      sendReport(
        pi,
        `ChatGPT/Codex subscription usage\nUnable to fetch usage limits: ${message}\n\nMake sure the Codex CLI is installed and authenticated with \`codex login\`.`,
      );
    }
  }

  pi.registerCommand("usage", {
    description: "Show ChatGPT/Codex subscription usage remaining",
    handler: handleUsageCommand,
  });
}
