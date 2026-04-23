---
name: awesomes
description: "Library and framework research skill for discovering, evaluating, and combining technologies. Searches curated lists, implements examples, and outputs reference files for efficient development and design. Use when researching tech stacks, finding libraries, or designing system architectures. [Triggers: awesome lists, technology research, library discovery, framework comparison, tech stack design, architecture planning]"
---

# Awesome Lists Research

A systematic approach to researching libraries, frameworks, and technology ecosystems using curated "awesome" lists as starting points. This skill helps discover, evaluate, and combine technologies efficiently.

## What This Skill Covers

- Searching curated awesome lists for relevant technologies
- Evaluating libraries and frameworks based on criteria
- Implementing minimal examples to validate choices
- Creating reference files for future use
- Designing technology combinations and architectures

## Quick Reference

| Task | Guide |
|------|-------|
| Research methodology and evaluation criteria | Read [references/methodology.md](references/methodology.md) |
| Implementation examples and templates | Read [references/examples.md](references/examples.md) |
| Reference file organization and formats | Read [references/format.md](references/format.md) |

## When to Use

- Researching new libraries or frameworks for a project
- Comparing technology options for a specific use case
- Designing system architectures with multiple components
- Creating technology radars or stack documentation
- Validating technology choices with minimal implementations

Do **not** use:

- For simple dependency lookups (use package managers instead)
- When you already know the exact library/framework needed
- For deep dives into a single technology (use dedicated documentation)

## Workflow (Summary)

```
0. Define research scope and criteria
     ↓
1. Search relevant awesome lists and curate candidates
     ↓
2. Evaluate candidates against defined criteria
     ↓
3. Implement minimal examples for top candidates
     ↓
4. Create reference files and documentation
     ↓
5. Recommend technology combination/architecture
     ↓
6. Validate with empirical testing if needed
```

Detailed workflow and evaluation criteria: see [references/methodology.md](references/methodology.md).

## Red Flags (watch for these rationalizations)

| Rationalization | Reality |
|----------------|---------|
| "Just pick the most popular option." | Popularity doesn't guarantee fit for your specific use case. |
| "One example is enough to evaluate." | One example overfits. Multiple scenarios reveal strengths/weaknesses. |
| "We don't need to test this combination." | Untested combinations often fail in practice. |
| "Documentation quality doesn't matter." | Poor documentation increases long-term maintenance costs. |
| "We can fix issues later." | Early mismatches are expensive to correct. |

Extended pitfalls: see [references/methodology.md](references/methodology.md#common-failures).

## Environment Constraints

This skill requires access to:
- Internet connectivity for searching awesome lists
- Package managers for installing libraries
- Development environments for implementing examples
- File system access for creating reference files

When constrained (limited connectivity, no development environment), adapt by focusing on research and documentation phases only.

## Related Skills

- `repo-research` — GitHub repository investigation and code reading
- `find-skills` — Discovering and installing agent skills
- `empirical-prompt-tuning` — Iteratively refining prompts through fresh agent evaluation