# Metrics — Evaluation Axes and Interpretation

## Evaluation Axes

| Axis | Source | Meaning |
|---|---|---|
| Success/Failure | Did the fresh agent deliver the intended artifact? (binary) | Minimum bar |
| Accuracy | What percentage of requirements did the deliverable meet? | Degree of partial success |
| Step count | Tool calls / decision steps the agent used | Indicator of wasted instructions |
| Duration | End-to-end wall-clock time | Proxy for cognitive load |
| Retry count | Same decision redone | Signal of instruction ambiguity |
| Ambiguities (self-report) | Agent's bullet list | Qualitative material for improvement |
| Discretionary fills (self-report) | Decisions the instructions did not specify | Surfaces implicit requirements |

**Weighting**: Qualitative signals (ambiguities, discretionary fills) are primary; quantitative metrics (time, step count) are supporting. **Chasing time savings alone makes prompts brittle.**

### Cross-environment notes

`tool_uses` / `duration_ms` labels come from Claude Code's Task tool metadata. In other environments substitute the analogue:

- Direct Anthropic API: count tool-use blocks in the response; measure request→response wall time.
- OpenCode: inspect session metadata.
- Pi / other LLMs without a tool-use protocol: step count is less meaningful; rely more heavily on qualitative axes.

## Qualitative reading of step count

Accuracy alone hides structural flaws. Use step count as a **relative value across scenarios** to expose structural issues:

- If one scenario's step count is **3–5× or more** of the others, the skill is **index-style (decision-tree) and low on self-containment**. The executor is being forced into `references/` descent.
- Typical pattern: step count is 1–3 in all scenarios except one at 15+ → that scenario lacks a recipe inside SKILL.md and the executor is wandering through references.
- Fix: in iteration 2, add a "minimal complete example inline" and guidance for "when to read references" near the top of SKILL.md. Step count drops sharply.

**Even at 100% accuracy, skew in step count is grounds for triggering iteration 2.** "Stop at 100% accuracy" routinely misses structural defects.

## Correction Propagation Patterns

Edit → effect is not linear. Three pre-estimate patterns occur:

### Conservative drift (estimate > actual)
You aimed one edit at multiple axes, but only one axis moved.
**Lesson**: multi-axis shots usually miss.

### Upside drift (estimate < actual)
One structural piece of information (e.g., *command + config + expected output* as a set) satisfied the judgment text of several axes at once.
**Lesson**: information combinations are structurally multi-axis.

### Null drift (estimate > 0, actual = 0)
An edit inferred from an axis name did not land on any judgment text.
**Lesson**: axis names and judgment text are different things.

### Stabilizing estimates

**Before applying a delta, ask the fresh agent to verbalize which judgment-text line the edit satisfies.** If you do not tie edits to threshold-level wording, estimates will not tighten.

The same applies when introducing a new axis: concretize each score's criteria at threshold-level wording (e.g., *"all explicit"*, *"complete minimal running configuration"*), so the fresh agent can rate reliably.
