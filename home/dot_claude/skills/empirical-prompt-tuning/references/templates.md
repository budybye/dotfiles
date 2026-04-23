# Templates — Fresh Agent Prompt Contract and Presentation Format

## Fresh Agent Prompt Contract

The prompt handed to the fresh agent must follow this structure. It is the input contract for two-sided evaluation and is harness-agnostic: the same template works whether you dispatch via Task tool, API call, or a separate session.

```
You are an executor reading <target prompt name> as a blank slate.
You have no prior exposure to this prompt; treat it as newly encountered.

## Target Prompt
<paste the full target prompt, or specify a path for the executor to Read>

## Scenario
<one paragraph describing the situation>

## Requirement Checklist (items the deliverable must satisfy)
1. [critical] <item required for the minimum bar>
2. <ordinary item>
3. <ordinary item>
...
(Judgment rules are defined once in methodology.md §4 "Step 4 — Two-sided evaluation"; refer back there. [critical] must appear on at least one item.)

## Task
1. Execute the scenario following the target prompt and produce the deliverable.
2. On completion, respond with the report structure below.

## Report Structure
- Deliverable: <the artifact or run summary>
- Requirement status: for each item, ○ / × / partial (with reason)
- Ambiguities: places in the target prompt where you got stuck or the wording was open to interpretation (bullets)
- Discretionary fills: decisions you made yourself because the instructions did not specify (bullets)
- Retries: how many times you redid the same decision and why
```

After the fresh agent returns, the caller extracts the self-report, and then pulls step count / duration from the execution environment's metadata (Task tool usage, API response, session log — whichever applies) to populate the evaluation-axis table.

## Presentation Format (per iteration)

For each iteration, record and present to the user in the following form:

```
## Iteration N

### Changes (delta from previous)
- <one-line description of the edit>

### Results (by scenario)
| Scenario | Success/Failure | Accuracy | Steps | Duration | Retries |
|---|---|---|---|---|---|
| A | ○ | 90% | 4 | 20s | 0 |
| B | × | 60% | 9 | 41s | 2 |

### Ambiguities (new this iteration)
- <Scenario B>: [critical] item N was × — <one-line reason it dropped>   # on failure, always include
- <Scenario B>: <other observation, one line>
- <Scenario A>: (none new)

### Discretionary fills (new this iteration)
- <Scenario B>: <what was filled in>

### Next edit
- <one-line minimal edit>

(Convergence: X consecutive clears / Y iterations until stop condition)
```

## Filling guidance

- **Do not leave any axis blank.** If retries were 0, write "0", not "—".
- **"None new"** is an explicit signal — use it when ambiguities/fills do not introduce anything novel vs. previous iterations.
- **Keep "Next edit" to one line** to enforce the one-theme-per-iteration constraint.
- In environments without a tool-use protocol (e.g., Pi, plain chat UI), the Steps column may be omitted or replaced with turn count. Document the substitution once at the top of the iteration log.
