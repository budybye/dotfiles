---
name: planning
description: "A skill for creating implementation plans - analyze requirements, survey codebase, propose approaches, and outline steps. Produces structured plans with context, approach, steps, and risks. Use when asked to plan features, fixes, or refactorings. [Triggers: /planning, create plan, implementation plan, design plan, how to implement, plan feature, plan fix]"
allowed-tools: Read, Grep, Glob
---

# /planning — Implementation Planning Skill

Create structured implementation plans before writing code. Analyze requirements, survey the codebase, propose approaches, and outline concrete steps.

## Quick Reference

| Task                                    | Guide                                                  |
| --------------------------------------- | ------------------------------------------------------ |
| Planning workflow and phases            | Read [references/methodology.md](references/methodology.md) |
| Plan structure and required sections    | Read [references/format.md](references/format.md)      |
| Example plans (various technologies)    | Read [references/examples.md](references/examples.md)  |

---

## Workflow

```txt
Phase 1: Requirements Analysis
  ↓
Phase 2: Codebase Survey
  ↓
Phase 3: Approach Design & Tradeoff Analysis
  ↓
Phase 4: Step-by-Step Plan Creation
  ↓
Phase 5: Risk Assessment & Review
```

### Phase 1

Extract and clarify requirements from the user request. Identify scope boundaries and success criteria.

### Phase 2

Survey relevant parts of the codebase using Read/Grep/Glob. Understand existing architecture and locate impact areas.

### Phase 3

Design 2-3 possible implementation approaches. Evaluate tradeoffs considering complexity, risk, and maintainability.

### Phase 4

Select the recommended approach and break it down into concrete, actionable steps with file targets.

### Phase 5

Identify potential risks and gotchas. Review the plan for completeness and clarity.

---

## Agent Guidelines

- **No code execution**: Plans are for review only. Never write actual code unless explicitly requested.
- **Structured output**: Follow the format in `references/format.md` consistently.
- **Concrete steps**: Each step must be actionable with specific file targets (e.g., `src/components/Button.jsx`, `config/database.yml`).
- **Risk awareness**: Always include potential issues and mitigation strategies.
- **Codebase awareness**: Reference specific files discovered during survey to inform steps.
- **Scope discipline**: Stay within the stated scope; don't expand without user confirmation.

## Plan Structure

All plans must include these sections:

1. **Context** - Background and problem statement
2. **Approach** - Recommended solution and rationale
3. **Steps** - Concrete implementation steps with specific file targets
4. **Risks** - Potential issues and mitigations

See `references/format.md` for detailed section requirements.