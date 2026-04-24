# Methodology — Detailed Workflow

## Iteration 0 — Static coherence check (no dispatch)

- Read what the frontmatter `description` advertises (triggers, use cases)
- Read what the body actually covers
- If they diverge, reconcile them (edit description or body) **before** iteration 1
- Example: description says "navigation / form filling / data extraction" but the body is only a `npx playwright test` CLI reference. Detect this first.
- Skipping this causes the fresh agent to silently "re-interpret" the body against the description. Accuracy appears high even when the skill does not meet real requirements (false positive).

## Step 1 — Baseline preparation

Fix the target prompt and prepare two things:

- **Evaluation scenarios**: 2–3 of them (1 median + 1–2 edge). Realistic situations where the target prompt is actually used. No toy examples.
- **Requirement checklist**: for each scenario, 3–7 items the deliverable must satisfy. Accuracy % = items met / total items. **Fix the list before running**; do not adjust after seeing results.
- The checklist must include **at least one** item tagged `[critical]`. Without it, the success judgment is vacuous. Do not add or remove `[critical]` tags after running.

## Step 2 — Bias-free reading

Have a "blank-slate" executor read the instructions. **Dispatch a fresh agent.** Any of the following works:

- Claude Code Task tool (`Agent` / `Task`)
- A separate Claude Code session started fresh
- A direct API call (Anthropic, OpenAI, etc.) with empty history
- A different harness (OpenCode, Cursor) in a new session
- Any other LLM invocation with no prior exposure to this prompt

Do not substitute self re-reading — objectively viewing text you just wrote is structurally impossible. To run multiple scenarios in parallel, dispatch multiple fresh agents concurrently.

## Step 3 — Execution

Hand the fresh agent a prompt that conforms to the Fresh Agent Prompt Contract (see [templates.md](templates.md)) along with the scenario. The executor produces the deliverable and finishes with a self-report.

## Step 4 — Two-sided evaluation

From what the fresh agent returns, record:

**Executor self-report** (extracted from the agent's report):
- Ambiguities
- Discretionary fills
- Places where template application broke down

**Instructor-side metrics** (judgment rules defined here once; other sections refer back):
- **Success/Failure**: success (○) only if **every** `[critical]` item is met. Even one × or partial → failure (×). Binary ○ / × only.
- **Accuracy**: ○ = full point, × = 0, partial = 0.5; sum / total items, as percentage.
- **Step count**: tool call count from the execution environment. In Claude Code, read `tool_uses` from the Task tool's usage metadata verbatim. In direct API calls, count tool-use blocks in the response. Include all tool types (Read, Grep, etc.); exclude none.
- **Duration**: end-to-end wall-clock time. In Claude Code, `duration_ms` from usage metadata. In API calls, measure from request dispatch to final response.
- **Retry count**: how many times the fresh agent redid the same decision. Extract from the self-report; the instructor side cannot measure this directly.
- **On failure, append one line to the "Ambiguities" field of the presentation format naming which `[critical]` item was dropped** (for root-cause tracing).

## Step 5 — Apply a delta

Add the minimum edit to the prompt that addresses the ambiguity. **One theme per iteration**. A cluster of related edits is fine; unrelated edits go to the next iteration.

- **Before editing, state explicitly which item in the requirement checklist / judgment text the edit satisfies.** Edits inferred from axis names rarely land (see [metrics.md](metrics.md#correction-propagation-patterns)).

## Step 6 — Re-evaluate

Dispatch a **new** fresh agent and repeat steps 2–5. **Never reuse an agent from a previous iteration** — it has learned from the prior run. In Claude Code this means a new Task invocation; in API calls this means a new conversation with empty history. Increase parallelism only if improvement stalls.

## Step 7 — Stopping criteria

**Converged (stop)** when for **two consecutive iterations** all of the following hold:
- New ambiguities: 0
- Accuracy gain vs. previous: ≤ +3 points (e.g. 5% → 8%, saturation)
- Step-count change vs. previous: within ±10%
- Duration change vs. previous: within ±15%
- **Overfitting check**: at convergence, add one hold-out scenario not used before. If accuracy drops 15 points or more from the recent average, it is overfitting — return to baseline-scenario design and add edges.

**Diverged (question the design)**: if after **3+ iterations** new ambiguities are not decreasing → the prompt's design itself is likely wrong. Stop patching; rewrite the structure.

**Resource cutoff**: stop when the importance of the prompt no longer justifies the improvement cost (ship it at 80%).

For high-stakes prompts, require **three** consecutive clears instead of two.

## Environment Constraints

When no fresh agent can be obtained (you are already running inside a subagent with no dispatch privileges, the Task tool is disabled, there is no API access, etc.), **do not apply this skill**.

- **Fallback 1**: ask the user to open a separate session (Claude Code, OpenCode, browser chat) and run the evaluation there.
- **Fallback 2**: give up on evaluation and explicitly report "empirical evaluation skipped: no fresh agent available" to the user.
- **Forbidden**: substituting self re-reading. Bias contaminates the result; trust nothing it returns.

### Structural-audit mode

If you only need to check **descriptive coherence and clarity** rather than empirical behavior, carve it out explicitly as "structural-audit mode". Mark the fresh agent's request with *"This run is structural-audit mode: check textual coherence only, do not execute."* The agent then returns a static review without hitting the skip logic above. Structural audit is a supplement, not a replacement (it cannot count toward consecutive-clear convergence).

## Common Failures

- **Scenarios too easy / too hard**: either extreme produces no signal. Place one at the realistic median and one at the edge.
- **Looking only at metrics**: chasing time alone strips important explanation and the prompt becomes brittle.
- **Too many changes per iteration**: you lose attribution. One edit, one iteration.
- **Tuning scenarios to match the edit**: silently making scenarios easier so ambiguities appear resolved. This inverts the exercise.

## Extended Red Flags

| Rationalization | Reality |
|---|---|
| "Let's split every minor related edit into its own iteration." | The opposite trap. "One theme" means one *semantic* unit; 2–3 related micro-edits belong together. Over-splitting explodes iteration count. |
| "It would be faster to rewrite it from scratch." | Correct only after 3+ iterations without ambiguity reduction. Before that, it is an escape. |
| "Model specification is optional — the default works fine." | Default model resolution often fails with cryptic API errors; explicit `model` (and `skill: false` if needed) is required for reliable pi-subagents dispatch. |
