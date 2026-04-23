---
name: empirical-prompt-tuning
description: "A methodology for iteratively refining agent-facing prompts (skills, slash commands, task prompts, CLAUDE.md sections, code-generation prompts) by dispatching a fresh agent with no authoring context and scoring runs on two axes - the executor's self-report and instructor-side metrics - until improvements plateau. Use this immediately after authoring or substantially revising a prompt, or when diagnosing why an agent's behavior falls short and the cause may lie in instruction ambiguity. Works across any harness (Claude Code Task tool, separate sessions, direct API calls, other LLM platforms). [Triggers: empirical prompt tuning, prompt evaluation, prompt tuning, skill evaluation, harden prompt, evaluate skill, prompt iteration, tune prompt, fresh agent evaluation, blank slate review]"
---

# Empirical Prompt Tuning

A prompt's quality is opaque to its author. The clearer the author believes it is, the more another reader tends to stumble on it. The core of this skill: **dispatch a fresh agent, run the prompt for real, evaluate on two axes, and iterate until improvement plateaus.** Do not stop before the plateau.

## What Counts as a "Fresh Agent"

Any executor with **no authoring context** and **no memory of prior iterations** of this prompt:

- A subagent spawned via Claude Code's Task tool
- A separate Claude Code session (started fresh)
- A direct Anthropic/OpenAI API call with empty conversation history
- A new OpenCode / Cursor / other-harness session
- Any other LLM (Pi, Gemini, etc.) given the same contract
- In principle, even a human reader following the contract

The implementation does not matter. **What matters is the absence of authoring bias.** Self re-reading does not qualify.

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

## Red Flags (watch for these rationalizations)

| Rationalization | Reality |
|---|---|
| "Re-reading it myself produces the same effect." | You cannot objectively view text you just wrote. Always dispatch a fresh agent. |
| "One scenario is enough." | One scenario overfits. At least 2, preferably 3. |
| "Zero ambiguities came up once, so we're done." | May be coincidence. Confirm with two consecutive clears. |
| "Let's fix multiple ambiguities in one pass." | You lose attribution. One theme per iteration. |
| "Metrics look good, so ignore qualitative feedback." | Faster can also mean too thin. Qualitative signals are primary. |
| "Reuse the same fresh agent across iterations." | It has learned from the previous iteration. Dispatch anew every time. |

Extended pitfalls: see [references/methodology.md](references/methodology.md#common-failures).

## Environment Constraints (Summary)

When no fresh agent is obtainable (you are already running inside a subagent with no dispatch privileges, Task tool is disabled, no API access, etc.), **do not apply this skill**. Fall back to asking the user to open a separate session, or report "empirical evaluation skipped: no fresh agent available". Never substitute self re-reading. Full protocol and structural-audit mode: see [references/methodology.md](references/methodology.md#environment-constraints).

## Related

- `superpowers:writing-skills` — TDD approach for authoring skills (structurally the same loop)
- `retrospective-codify` — fixes lessons after the task; this skill runs *during* prompt development
- `superpowers:dispatching-parallel-agents` — conventions for running multiple scenarios in parallel
