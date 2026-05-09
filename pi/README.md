# Pi Configuration

Personal [pi](https://pi.dev) agent configuration, managed with GNU stow.

## Install

```bash
cd ~/dotfiles
stow -vt ~ pi
```

This symlinks `pi/.pi/agent/` to `~/.pi/agent/`.

## What's Included

### Global Agent Instructions

- **`AGENTS.md`** — Core persona and work principles for all projects
  - Identity: **Pippin** (proactive senior engineer)
  - Principles: verify-don't-assume, keep it simple, think forward
  - Escalation rules: when to ask the user vs. decide alone
  - Subagent delegation guide with `pi-subagents`

### Prompts (`~/.pi/agent/prompts/`)

| Prompt | Usage |
|--------|-------|
| `/commit` | Generate conventional commit messages from staged changes |
| `/review` | Review code for bugs, security, performance, maintainability |
| `/explain` | Explain code or concepts with high-level + step-by-step detail |
| `/refactor` | Refactor code for clarity, performance, or structure |
| `/test` | Write or improve tests for given code |

### Skills (`~/.pi/agent/skills/`)

| Skill | Triggers | Purpose |
|-------|----------|---------|
| `learn-codebase` | Starting new/unfamiliar projects | Discover conventions, security sweep |
| `write-todos` | Planning complex work | Write actionable todos for workers |
| `skill-creator` | Creating new skills | Scaffold and validate SKILL.md files |
| `self-improve` | Self-improvement tasks | Meta skill for refining agent behavior |

### Extensions

- **`protected-paths.ts`** — Custom extension for path protection
- **`pi-permission-system/config.json`** — Permission system config (tracked)

### Installed Packages

Managed via `pi install` and listed in `settings.json`:

| Package | What it adds |
|---------|-------------|
| `pi-subagents` | Scout, worker, reviewer, oracle, planner, researcher, context-builder |
| `pi-web-access` | Web search, URL fetching, GitHub content extraction |
| `@gotgenes/pi-permission-system` | Permission gates for destructive operations |
| `@diegopetrucci/pi-extensions` | Utility extensions |
| `@vanillagreen/pi-qol` | Quality-of-life improvements |
| `@tmustier/pi-usage-extension` | Usage tracking |
| `@juicesharp/rpiv-todo` | Todo integration |

### Settings

- **Default model:** `kimi-k2.6` via `opencode-go`
- **Default thinking level:** `medium`
- **Quiet startup:** enabled

## Updating

```bash
# Update pi and all packages
pi update

# Update only packages
pi update --extensions

# Update one package
pi update npm:pi-subagents
```

## Adding New Prompts / Skills

Drop them into the tracked directories here, then `stow -R pi` to restow.

```bash
# New prompt
cat > pi/.pi/agent/prompts/my-prompt.md << 'EOF'
---
description: What this prompt does
---
Prompt instructions here...
EOF

# New skill
mkdir -p pi/.pi/agent/skills/my-skill
cat > pi/.pi/agent/skills/my-skill/SKILL.md << 'EOF'
# My Skill
Use this skill when...
EOF
```

## See Also

- [Pi docs](https://pi.dev)
- [pi-subagents docs](https://github.com/earendil-works/pi-subagents)
- [Agent Skills spec](https://agentskills.io)
