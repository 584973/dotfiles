/**
 * Protected Paths Extension
 *
 * Hard-blocks read, write, edit, grep, and bash operations that target
 * sensitive credential files. This prevents accidental token exposure through
 * direct file reads or shell commands like `cat ~/.npmrc`.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // Exact filenames or directory names to block
  const exactNames = new Set([
    ".env",
    ".envrc",
    ".netrc",
    ".npmrc",
    ".yarnrc",
    ".pnpmrc",
    ".pypirc",
    ".pgpass",
    ".my.cnf",
    "auth.json",
    "credentials",
    "secrets",
    "token",
    "id_rsa",
    "id_ed25519",
    "id_ecdsa",
    "id_dsa",
    ".ssh",
    ".gnupg",
    ".aws",
    ".docker",
    ".git",
    "settings.xml",
  ]);

  const protectedPathPatterns = [
    /(^|\/)\.config\/gh\/hosts\.ya?ml$/i,
    /(^|\/)\.cargo\/credentials(\.toml)?$/i,
    /(^|\/)\.gem\/credentials$/i,
    /(^|\/)\.kube\/config$/i,
  ];

  const sensitiveNpmConfigCommands = [
    /(^|[;&|\n])\s*npm\s+(config|c)\s+(ls|list)(\s|$)/i,
    /(^|[;&|\n])\s*npm\s+(config|c)\s+get\s+.*(_auth|authToken|token)/i,
    /(^|[;&|\n])\s*npm\s+get\s+.*(_auth|authToken|token)/i,
  ];

  // Extensions to block (e.g. file.key, file.pem)
  const blockedExtensions = new Set([
    ".key",
    ".pem",
    ".crt",
    ".p12",
    ".pfx",
    ".cer",
    ".der",
  ]);

  function isProtectedPath(path: string): boolean {
    const normalizedPath = path.replace(/\\/g, "/");
    const segments = normalizedPath.split("/");

    if (protectedPathPatterns.some((pattern) => pattern.test(normalizedPath))) {
      return true;
    }

    return segments.some((seg) => {
      const lowerSeg = seg.toLowerCase();

      // Exact name match
      if (exactNames.has(lowerSeg)) return true;

      // .env.* variants (.env.local, .env.production, etc.)
      if (lowerSeg.startsWith(".env.")) return true;

      // Blocked extension suffix
      for (const ext of blockedExtensions) {
        if (lowerSeg.endsWith(ext)) return true;
      }

      return false;
    });
  }

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName === "bash") {
      const command = (event.input.command as string) ?? "";
      const referencesProtectedPath = command
        .split(/[\s'"`]+/)
        .some((part) => isProtectedPath(part));
      const readsSensitiveNpmConfig = sensitiveNpmConfigCommands.some((pattern) =>
        pattern.test(command),
      );

      if (referencesProtectedPath || readsSensitiveNpmConfig) {
        if (ctx.hasUI) {
          ctx.ui.notify("Blocked bash command targeting protected credentials", "warning");
        }
        return {
          block: true,
          reason: "Command targets protected credential material.",
        };
      }

      return undefined;
    }

    if (
      event.toolName !== "read" &&
      event.toolName !== "write" &&
      event.toolName !== "edit" &&
      event.toolName !== "grep"
    ) {
      return undefined;
    }

    const path = (event.input.path as string) ?? "";

    if (path && isProtectedPath(path)) {
      if (ctx.hasUI) {
        ctx.ui.notify(
          `Blocked ${event.toolName} on protected path: ${path}`,
          "warning",
        );
      }
      return {
        block: true,
        reason: `Path "${path}" is protected (sensitive credentials).`,
      };
    }

    return undefined;
  });
}
