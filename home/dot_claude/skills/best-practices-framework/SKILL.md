---
name: best-practices-framework
description: "Holistic framework for evaluating and selecting best practices across frameworks, libraries, development methodologies, system architecture, tooling, and interconnectivity. Provides systematic approaches for cross-domain technology decisions. [Triggers: best practices framework, cross-domain technology evaluation, holistic architecture decisions, technology stack assessment, development practice evaluation]"
---

# Best Practices Framework

A holistic skill for systematically evaluating and implementing best practices across multiple domains of software development, with emphasis on cross-cutting concerns and integration challenges.

## What This Skill Covers

- Framework and library evaluation and selection
- Modern development practices and methodologies
- System architecture and design patterns
- Code organization and project structure
- Peripheral tool research and integration
- Interconnectivity between components and systems

## Quick Reference

| Task | Guide |
|------|-------|
| Framework and library evaluation methodology | Read [references/evaluation.md](references/evaluation.md) |
| System architecture and design patterns | Read [references/architecture.md](references/architecture.md) |
| Development methodologies and practices | Read [references/methodologies.md](references/methodologies.md) |
| Tool integration and interconnectivity | Read [references/tools.md](references/tools.md) |

## When to Use

Use this skill when making cross-domain technology decisions that involve multiple aspects of the development stack:

- Evaluating technology stacks that span frontend, backend, and infrastructure
- Assessing architectural approaches that require integrating multiple frameworks
- Making organizational decisions about development practices across teams
- Planning migrations that affect multiple system components
- Designing systems where tool integration is as critical as technology selection

**Do NOT use** when:

- Your decision is confined to a single domain (use specialized skills like `awesomes` or `repo-research`)
- You need specific implementation details (consult dedicated documentation)
- You're troubleshooting specific bugs or errors
- You already have well-functioning established practices

## Workflow (Summary)

```
0. Define requirements and constraints
     ↓
1. Research relevant frameworks/libraries/methodologies
     ↓
2. Evaluate options against defined criteria
     ↓
3. Design architecture and organization patterns
     ↓
4. Select appropriate tools and integrations
     ↓
5. Create implementation plan with best practices
     ↓
6. Document recommendations and rationale
```

Detailed workflow and evaluation criteria: see [references/evaluation.md](references/evaluation.md).

## Red Flags (watch for these rationalizations)

| Rationalization | Reality |
|----------------|---------|
| "We should use the newest framework/library." | New doesn't always mean better or more suitable for your needs. |
| "Let's stick with what we know." | Familiarity can prevent adoption of better solutions. |
| "One size fits all." | Different contexts require different approaches. |
| "We don't have time to evaluate options." | Poor choices early cost more time later. |
| "Performance isn't important for this project." | Scalability considerations should be addressed early. |

Extended pitfalls: see [references/evaluation.md](references/evaluation.md#common-failures).

## Environment Constraints

This skill requires access to:
- Internet connectivity for research
- Development environments for testing concepts
- Package managers for exploring dependencies
- Documentation resources for various technologies

When constrained (limited connectivity, no development environment), focus on research and documentation phases.

## Related Skills

## Transition Guidance

- **For single-domain technology research** → Use `awesomes` or `repo-research`
- **For API-specific design principles** → Use `api-design-principles`
- **For language/framework-specific optimizations** → Use specialized skills like `frontend-react-best-practices`
- **For this skill** → When decisions span multiple domains and require holistic evaluation