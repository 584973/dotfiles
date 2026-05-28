---
name: self-improve
description: Manual end-of-session retrospective that identifies improvements to agent config, skills, tests, docs, and code. Use when explicitly asked to "self-improve", "reflect on session", "what can we improve", "session retrospective", or "end of session review". Proposes and executes approved improvements.
---

# Self-Improve

Reflect on the current session when explicitly requested, identify concrete improvements, present them for approval, then execute approved changes.

## Step 1: Gather Context

Use what's already in the conversation — tool outputs, errors, subagent summaries, dev server logs, test results. You're in the session, so you have the context.

Only use a session-reading skill if one is available and you need to review a subagent's session that isn't summarized in the current conversation. Otherwise, rely on the current conversation and summarized subagent output.

## Step 2: Analyze Improvement Areas

Examine each area below. Skip areas with no findings — only report what's actionable.

| Area | What to Look For |
|------|-----------------|
| **Agent config** | Could AGENTS.md instructions be clearer? Did the agent misunderstand something that better wording would prevent? |
| **Subagent behavior** | Did subagents struggle, go off-scope, or need repeated correction? Would better task descriptions or agent definitions help? |
| **Agent definitions** | Check `~/.pi/agent/agents/*.md` — are model choices, skills, or system prompts optimal for what was observed? |
| **Tests** | Were bugs found that tests should catch? Are existing tests stale or missing coverage for touched code? |
| **Documentation** | Are READMEs, inline docs, or references out of date after changes made this session? |
| **Scripts** | Did any scripts fail, produce wrong output, or need manual workarounds? |
| **Extensions & MCP** | Were MCP servers or extensions used that could be better configured? Were tools missing that would have helped? |
| **Skills** | Did any skill produce suboptimal results? Are trigger descriptions accurate? Would a new skill help? |
| **Code quality** | Did the session reveal patterns worth refactoring, error handling gaps, or repeated boilerplate? |
| **Workflow** | Were there unnecessary back-and-forth cycles, wasted API calls, or inefficient tool usage patterns? |

## Step 3: Determine Scope

For each finding, classify its scope:

| Scope | Where It Lives | Example |
|-------|---------------|---------|
| **Global** | `~/.pi/agent/` (AGENTS.md, skills, agents) | "Subagent worker should always run tests before committing" |
| **Project** | Project's `.claude/`, CLAUDE.md, or codebase | "Add integration test for the auth endpoint we just fixed" |

## Step 4: Present Suggestions

Present findings as a numbered table. Do NOT start working yet — wait for user approval.

Format each suggestion as:

```
## Improvement Suggestions

| # | Area | Scope | Suggestion | Reason | Changes |
|---|------|-------|------------|--------|---------|
| 1 | Tests | Project | Add test for X | Bug was found manually that a test would catch | Create `tests/test_x.py` |
| 2 | Agent config | Global | Clarify Y in AGENTS.md | Subagent misunderstood task scope twice | Edit AGENTS.md section Z |
| ... | | | | | |
```

After the table, ask:

> Which of these should I work on? (all / numbers / none)

## Step 5: Create Todos and Execute

For each approved suggestion:

1. Track the approved work:
   - If a todo tool is available, create a todo with title, tags, and full context.
   - If no todo tool is available, maintain a short checklist in the response.

2. Work through each approved item:
   - Make the changes
   - Verify the change works (run tests, validate config, etc.)
   - Commit using the `commit` skill if the user asked for a commit
   - Mark the item done in the todo tool or response checklist

3. After completing all items, print a summary:

```
## Completed Improvements

| # | Todo | What Changed | Verified |
|---|------|-------------|----------|
| 1 | TODO-xxxx | Added test_x.py — passes ✓ | ✓ |
| 2 | TODO-yyyy | Updated AGENTS.md worker section | ✓ |
```
