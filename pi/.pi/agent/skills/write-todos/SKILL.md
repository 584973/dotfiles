---
name: write-todos
description: Write clear, actionable todos that workers can execute without losing architectural intent. Use when "create todos", "write todos", "break into tasks", "plan todos", "make todos", or creating work items from a plan. Ensures each todo has unambiguous expected outcomes, concrete examples, and explicit constraints so workers don't drift from the design.
---

# Write Todos

Write todos that a worker agent can execute without access to the planning conversation. Every todo must be **self-contained** — a worker reading only the todo and the plan artifact must produce the correct result.

## Why This Matters

Workers implement exactly what's described. If a todo contains a code sketch using plain classes, the worker builds plain classes — even if the plan says "use functional code for everything." Architectural intent that only lives in the plan's prose gets lost. Every constraint must be **in the todo body itself**.

## Todo Structure

Every todo body follows this structure:

```markdown
**Plan:** `plans/YYYY-MM-DD-<name>.md`

## What
[One paragraph: what this todo produces and why it matters]

## Constraints
- [Explicit architectural constraints that MUST be followed]
- [Libraries/patterns to use — or explicitly NOT use]
- [Reference existing code patterns: "Follow the pattern in src/foo.ts"]

## Files
- `src/path/to/file.ts` — [what this file does]
- `src/path/to/other.ts` — [what this file does]

## Expected Outcome
[Concrete description of what the finished code looks like]

### Example
[Short code snippet showing the expected shape — imports, key patterns, structure]

## Acceptance Criteria
- [ ] [Specific, verifiable criterion]
- [ ] [Another criterion]
- [ ] [Build/lint/test passes]
```

## Rules

### 1. Constraints Are Explicit, Not Implied

If the plan says "use Effect v4 for all services," every service todo must repeat that:

| Bad (implicit) | Good (explicit) |
|---|---|
| "Build the EventBus service" | "Build the EventBus as an Effect v4 service. Import from `effect`. Use `Effect.gen`, `Layer`, and `Context.Tag` — not plain classes." |
| "Add WebSocket support" | "Add WebSocket support using the `ws` package. Do NOT use `socket.io`." |
| "Create the component" | "Create the component using React 19 + Tailwind v4 utility classes. No CSS modules, no styled-components." |

### 2. Examples Show The Real Shape

Include a short code snippet showing the expected import style, patterns, and structure. This is the single most effective way to prevent drift.

```markdown
### Example

The service should look like this (not a plain class):

\```typescript
import { Effect, Context, Layer } from "effect"

class EventBus extends Context.Tag("EventBus")<EventBus, {
  readonly subscribe: (topic: string) => Effect.Effect<Subscription>
  readonly publish: (event: PiEvent) => Effect.Effect<void>
}>() {}

const EventBusLive = Layer.effect(EventBus, Effect.gen(function* () {
  // ... implementation using Effect primitives
}))
\```
```

Without examples, workers default to the most common pattern they know — which is usually plain TypeScript classes.

### 3. Anti-Patterns Are Named

If there's a wrong way that looks right, call it out:

```markdown
## Constraints
- Use Effect v4 services with `Context.Tag` and `Layer`
- **Do NOT** use plain classes with manual observer patterns (no `new EventBus()`, no `Set<() => void>` listener tracking)
- **Do NOT** use `useSyncExternalStore` with hand-rolled subscribe — use Effect's reactive primitives
```

### 4. Each Todo Is Self-Contained

A worker reads: (1) the todo body, (2) the plan artifact, (3) existing code. That's it. They don't read other todos. So:

- Reference the plan path in every todo
- List all files to create or modify
- Note which existing files to read for context
- Include any conventions discovered during planning

### 5. Todos Are Sequenced

Number todos and note dependencies:

```markdown
**Title:** "Todo 3: Build EventNode state machine"
**Body includes:** "Depends on Todo 2 (types in `src/core/types.ts`). Read that file first."
```

### 6. Size Is Right

Each todo should be **one focused unit of work** — a worker can complete it in one session and make one commit. If a todo has more than 3 files to create, consider splitting it.

### 7. Acceptance Criteria Are Verifiable

Every criterion should be checkable by running a command or reading the output:

| Bad (vague) | Good (verifiable) |
|---|---|
| "Code is clean" | "`vp check` passes with no errors" |
| "Works correctly" | "Running `node -e 'import { EventBus } from \"./src/services/EventBus\"'` succeeds" |
| "Tests pass" | "`vp test src/core/EventNode.test.ts` passes" |
| "Follows conventions" | "All imports use `effect` package, no plain class instantiation" |

## Checklist Before Creating Todos

Before calling `todo(action: "create")`, verify:

- [ ] Every architectural decision from the plan appears as an explicit constraint in at least one todo
- [ ] Every todo has a code example showing expected shape (imports, patterns, structure)
- [ ] No todo relies on context only available in the planning conversation
- [ ] Anti-patterns are named in relevant todos ("do NOT use X")
- [ ] Todos are numbered and dependencies noted
- [ ] Acceptance criteria are verifiable commands, not subjective judgments
