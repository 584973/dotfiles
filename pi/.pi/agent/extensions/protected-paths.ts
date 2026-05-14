/**
 * Protected Paths Extension
 *
 * Hard-blocks read, write, and edit tool operations on sensitive credential
 * files. Does NOT intercept bash commands — the permission system handles
 * those with ask gates instead.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // Exact filenames or directory names to block
  const exactNames = new Set([
    ".env",
    ".envrc",
    ".netrc",
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

  pi.on("tool_call", async (event, ctx) => {
    if (
      event.toolName !== "read" &&
      event.toolName !== "write" &&
      event.toolName !== "edit"
    ) {
      return undefined;
    }

    const path = (event.input.path as string) ?? "";
    const segments = path.split(/[\\/]/);

    const isProtected = segments.some((seg) => {
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

    if (isProtected) {
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
