---
description: Deep security review of code changes
argument-hint: "[file or diff]"
---
Perform a security-focused review of the provided code.

**Before running `git diff` or reading any files:**
- If no code is provided, **ask the user** whether to run `git diff` or specify which files to review.
- Do **not** auto-run `git diff`, `git show`, or read files without explicit user confirmation.
- This prevents accidental exposure of secrets, credentials, or sensitive changes in the review output.

Focus strictly on security:

1. **Injection** — SQL, command, LDAP, XPath, template, or eval injection; unsanitized user input reaching execution paths
2. **Authentication & Authorization** — missing auth checks, broken access control, insecure session handling, privilege escalation
3. **Data Exposure** — hardcoded secrets, logging sensitive data, insecure serialization, missing encryption at rest/transit
4. **Input Validation** — insufficient validation, path traversal, SSRF, open redirects, file upload risks, unsafe parsing (XML, YAML, JSON)
5. **Dependency & Supply Chain** — vulnerable imports, unsafe dynamic requires, eval of untrusted code
6. **Concurrency** — race conditions leading to auth bypass, TOCTOU, insecure mutable shared state
7. **Crypto** — weak algorithms, static IVs, insufficient entropy, custom crypto, missing TLS verification

Be specific: cite line numbers, function names, and the exact vulnerability class (e.g., CWE-89, OWASP Top 10). Explain the exploit scenario and provide a concrete fix.

Prioritize by severity:
- **Critical** — exploitable without auth, leads to RCE or full data breach
- **High** — exploitable with low-privilege access, clear impact
- **Medium** — requires specific conditions, limited blast radius
- **Low / Info** — defense in depth, hardening opportunities
