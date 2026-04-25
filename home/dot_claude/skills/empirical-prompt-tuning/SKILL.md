---
name: empirical-prompt-tuning
description: "A methodology for iteratively refining agent-facing prompts (skills, slash commands, task prompts, CLAUDE.md sections, code-generation prompts) by dispatching a fresh agent with no authoring context and scoring runs on two axes - the executor's self-report and instructor-side metrics - until improvements plateau. Use this immediately after authoring or substantially revising a prompt, or when diagnosing why an agent's behavior falls short and the cause may lie in instruction ambiguity. Works across any harness (Claude Code Task tool, separate sessions, direct API calls, other LLM platforms). [Triggers: empirical prompt tuning, prompt evaluation, prompt tuning, skill evaluation, harden prompt, evaluate skill, prompt iteration, tune prompt, fresh agent evaluation, blank slate review]"
---

# Empirical Prompt Tuning

A prompt's quality is opaque to its author. The clearer the author believes it is, the more another reader tends to stumble on it. The core of this skill: **dispatch a fresh agent, run the prompt for real, evaluate on two axes, and iterate until improvement plateaus.** Do not stop before the plateau.

## What Counts as a "Fresh Agent"

Any executor with **no authoring context** and **no memory of prior iterations** of this prompt.

The implementation does not matter. **What matters is the absence of authoring bias.** Self re-reading does not qualify.

### pi-subagents (Recommended: PI/Claude Code environments)

The most reliable method. `context: "fresh"` completely clears the parent session's memory.

```typescript
// Run a single agent with fresh context
subagent({
	agent: "assistant",
	task: "Your test prompt here",
	context: "fresh", // ← Required: do not inherit parent context
	model: "gpt-oss-120b", // ← Required: Explicitly specify model (avoid default resolution issues)
	skill: false, // ← Recommended: Disable skill inheritance to prevent context pollution
	clarify: false, // Skip TUI confirmation (for automated testing)
});

// Parallel execution (test multiple scenarios simultaneously)
subagent({
	tasks: [
		{
			agent: "assistant",
			task: "Scenario A: ...",
			context: "fresh",
			model: "gpt-oss-120b",
			skill: false,
		},
		{
			agent: "assistant",
			task: "Scenario B: ...",
			context: "fresh",
			model: "gpt-oss-120b",
			skill: false,
		},
	],
});
```

### Claude Code Task Tool

Alternative when PI/subagent environment is unavailable.

```json
{
	"agent": "worker",
	"task": "Your test prompt here",
	"context": "fresh"
}
```

### Open in Separate Session

Start a completely independent session in a new terminal/window:

```bash
# New Claude Code session
claude

# Or PI
pi
```

### Direct API Call

Call the API programmatically with empty history:

```bash
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4",
    "max_tokens": 4096,
    "system": "Your prompt here",
    "messages": []
  }'
```

### Important: These Do NOT Count as Fresh Agents

❌ `context: "fork"` — Inherits parent history (for branched review)
❌ Continuing in the same session — Memory persists
❌ Self re-reading text — Suffers from author bias

## Quick Reference

| Task                                                              | Guide                                                       |
| ----------------------------------------------------------------- | ----------------------------------------------------------- |
| Workflow, stopping criteria, environment limits                   | Read [references/methodology.md](references/methodology.md) |
| Evaluation axes, `tool_uses` interpretation, propagation patterns | Read [references/metrics.md](references/metrics.md)         |
| Fresh agent prompt contract, iteration report format              | Read [references/templates.md](references/templates.md)     |

## When to Use

- Immediately after creating or substantially revising a skill, slash command, or task prompt
- When an agent is not behaving as expected and you suspect instruction ambiguity
- When hardening a high-stakes prompt (a frequently-used skill, the core prompt of an automation)

Do **not** use:

- For one-off throwaway prompts (evaluation cost is not worth it)
- When the goal is reflecting the author's subjective preferences rather than improving success rate

## Workflow (Summary)

```
0. Static coherence check (description ↔ body) — no dispatch needed
     ↓
1. Baseline: define 2–3 scenarios + requirement checklist (fix before running)
     ↓
2. Dispatch a FRESH AGENT — never self re-read, never reuse a prior agent
     ↓
3. Execute under the Fresh Agent Prompt Contract (references/templates.md)
     ↓
4. Two-sided evaluation: self-report + instructor-side metrics
     ↓
5. Apply ONE themed delta, verbalizing which checklist item it satisfies
     ↓
6. Re-evaluate with a NEW fresh agent (never reuse)
     ↓
7. Stop when 2 consecutive iterations show 0 new ambiguities + metrics plateau
```

Step-by-step detail and stopping thresholds: see [references/methodology.md](references/methodology.md).

## Red Flags (Watch for These Rationalizations)

| Rationalization                                      | Reality                                                                         |
| ---------------------------------------------------- | ------------------------------------------------------------------------------- |
| "Re-reading it myself produces the same effect."     | You cannot objectively view text you just wrote. Always dispatch a fresh agent. |
| "One scenario is enough."                            | One scenario overfits. At least 2, preferably 3.                                |
| "Zero ambiguities came up once, so we're done."      | May be coincidence. Confirm with two consecutive clears.                        |
| "Let's fix multiple ambiguities in one pass."        | You lose attribution. One theme per iteration.                                  |
| "Metrics look good, so ignore qualitative feedback." | Faster can also mean too thin. Qualitative signals are primary.                 |
| "Reuse the same fresh agent across iterations."      | It has learned from the previous iteration. Dispatch anew every time.           |

Extended pitfalls: see [references/methodology.md](references/methodology.md#common-failures).

## Environment Constraints (Summary)

### When Fresh Agent Is Unavailable

Do **not** apply this skill in the following cases:

- Already inside a subagent with no dispatch privileges
- `subagent` tool is disabled (PI not installed/not logged in)
- Claude Code Task tool is disabled
- No API key, or rate limit reached
- Cannot specify `context: "fresh"`
- Cannot obtain fresh agent through any method (see Troubleshooting above)

### Fallback

When fresh agent is unavailable:

1. **Ask the user to open a separate session** — manually launch `claude` or `pi` fresh
2. **Report and skip** — "empirical evaluation skipped: no fresh agent available"
3. **Never substitute with self re-reading** — To prevent author bias

### Notes for pi-subagents

- `context: "fork"` does not make a fresh agent (inherits parent history)
- **Always specify `context: "fresh"`**
- **Always specify `model` explicitly** — Default model resolution may fail with "No API key found" errors even when the same model works with explicit specification
- **Use `skill: false` when appropriate** — Skill inheritance can cause unexpected context pollution (e.g., auto-reading unrelated files from cwd)
- PI login required (API key or OAuth)

### Troubleshooting pi-subagents

| Symptom                                | Cause                              | Solution                                                             |
| -------------------------------------- | ---------------------------------- | -------------------------------------------------------------------- |
| "No API key found for openai-codex"    | Default model resolution failure   | Explicitly specify `model: "gpt-oss-120b"` (or your preferred model) |
| Agent reads wrong files (e.g., cli.js) | Skill inheritance or cwd pollution | Add `skill: false` to disable skill inheritance                      |

See [references/methodology.md](references/methodology.md#environment-constraints) for details.

## Related

- `superpowers:writing-skills` — TDD approach for authoring skills (structurally the same loop)
- `retrospective-codify` — fixes lessons after the task; this skill runs _during_ prompt development
- `superpowers:dispatching-parallel-agents` — conventions for running multiple scenarios in parallel
