---
name: improve-pi-skills
description: Continuous Pi skill improvement workflow. Use when asked to "improve pi", "self-improve pi", "auto-create skills", "update skills", "Hermes harness", or when a repeated workflow, user correction, or skill miss suggests a reusable Pi skill. Creates or updates skills, prompts, and AGENTS.md with safeguards.
---

# Improve Pi Skills

Turn evidence from the current work into durable Pi improvements without drifting into speculative automation.

## Step 1: Gather Evidence

Use only evidence already available in the session unless more context is necessary.

Look for:
- Repeated workflows that would benefit from a reusable skill
- User corrections that should change future behavior
- Missing, stale, or poorly triggered skills
- Prompt templates that would make a manual workflow repeatable
- Broad behavior rules that belong in `AGENTS.md`
- Tiny user preferences that belong in persistent memory instead of files, when a memory tool is available

Do not read credential-bearing files. Do not generalize one project-specific quirk into global Pi behavior without user approval.

## Step 2: Classify the Improvement

Choose the smallest durable improvement that fits the evidence.

| Evidence | Improvement | Destination |
|---|---|---|
| A repeatable multi-step workflow | New skill | `~/.pi/agent/skills/` or tracked `pi/.pi/agent/skills/` |
| Existing skill missed a trigger or gave bad guidance | Skill update | Existing skill's `SKILL.md` |
| User wants a manual slash command | Prompt template | `~/.pi/agent/prompts/` or tracked `pi/.pi/agent/prompts/` |
| Broad agent behavior should always apply | Instruction update | `AGENTS.md` |
| Small preference or correction | Optional memory | Persistent memory, only when a memory tool is available |
| Weak or one-off signal | No-op | Explain why no file change is warranted |

Prefer skills for reusable workflows. Prefer `AGENTS.md` only for broad behavior that should affect most sessions.

## Step 3: Apply the Safety Gate

Apply the improvement immediately only when all are true:
- The user explicitly asked to improve Pi, create or update skills, or enable Hermes-style improvement
- The change is local, reversible, and limited to Pi configuration or optional memory
- The evidence is concrete, not speculative
- No secrets, credentials, auth config, or private machine details are read or copied
- The change does not loosen permissions, add background execution, install dependencies, or alter destructive behavior
- Validation can be run afterward

Ask for approval before changing anything that affects security, permissions, dependencies, external services, project-specific global policy, deletion, or broad automation. If uncertain, ask.

## Step 4: Implement the Change

For a new skill:
1. Load and follow the `skill-creator` skill.
2. Keep the skill focused on one repeatable capability.
3. Put all trigger information in the frontmatter description.
4. Include safeguards and verification steps in the body.

For an existing skill update:
1. Read the existing `SKILL.md` before editing.
2. Preserve the skill's purpose, frontmatter shape, and local style.
3. Make the smallest targeted edit that fixes the observed problem.
4. Do not add broad trigger phrases unless the evidence supports them.

For memory:
1. Treat memory as optional. If no memory tool is available, skip memory storage and use skills, prompts, or `AGENTS.md` only when warranted.
2. Store only small non-secret preferences or corrections.
3. Do not make the self-improvement workflow depend on memory.

For an `AGENTS.md` or prompt template update:
1. Match the surrounding tone and structure.
2. Keep instructions short, actionable, and non-duplicative.
3. Avoid embedding project-specific details in global instructions.

## Step 5: Validate

Run the relevant checks from the repository root when available:

```bash
validator=pi/.pi/agent/skills/skill-creator
skill=improve-pi-skills
uv run "$validator"/"scripts"/quick_validate.py "pi/.pi/agent/skills/$skill" || \
  python3 "$validator"/"scripts"/quick_validate.py "pi/.pi/agent/skills/$skill"
git diff --check -- pi/.pi/agent/AGENTS.md pi/.pi/agent/skills pi/.pi/agent/prompts
stow -nvt ~ pi
```

Validate every created or edited skill. If a command cannot run, report the exact reason and what remains unverified.

## Step 6: Report the Improvement

Finish with a concise summary:

```markdown
## Pi Improvements

| Change | File | Why | Verified |
|---|---|---|---|
| Created skill X | path/to/SKILL.md | Repeated workflow Y | quick_validate, diff check |

Run `/reload` or restart Pi to load new skills and prompts.
```

Mention any approval decisions, skipped improvements, or manual follow-up needed.
