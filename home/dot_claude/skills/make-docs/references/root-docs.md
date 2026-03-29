# /make-docs Root Documentation Guide

Detailed templates and writing principles for `AGENTS.md` and `README.md`.

---

## AGENTS.md Template

```markdown
# AGENTS.md

## Project Overview

[One-sentence description of the project]

## Development Policy

### Coding Style

[References to formatter/linter settings, language-specific conventions, e.g., Prettier, ESLint]

### Commit Message Convention

[e.g., Conventional Commits. Example: `feat(auth): add JWT validation`]

### Branching Strategy

[e.g., GitHub-flow, Trunk-based development]

### Version Control

[Git / jj (Jujutsu) / etc., specify if non-standard workflows are used]

## Test-Driven Development (TDD) Rules

- Write tests one at a time (avoid writing many upfront).
- Strictly follow the Red → Green → Refactor cycle.
- Manage test cases in `tests/testlist.md`.
- Refer to `docs/test.md` for the overall testing strategy.

## Directory Conventions

→ See `docs/directory.md`

## Environment Variables

→ See the technical specifications in `docs/tech.md`
[Only mention the location and usage of `.env.example` here]

## Important Configuration Files

→ See the configuration section in `docs/tech.md`
[Only list "critical precautions when modifying" for each file here]

## Prohibitions

- [List of actions that are strictly prohibited]
- [Files or directories that should not be manually modified]

## Deployment Procedure

[Step-by-step deployment flow to production/staging environments]

## Troubleshooting

[Commonly encountered issues and their established solutions]
```

**Principles for AGENTS.md:**

- **Extract Concrete Values**: Read actual configuration files (e.g., `tsconfig.json`, `.prettierrc`) to be specific rather than generic.
- **Actionable Rules**: Avoid vague instructions; use rules that an AI or a new developer can follow mechanically.
- **Consistency**: Ensure there are no contradictions with existing project configuration files.
- **Delegation**: Keep this file focused on "Rules and Decisons." Delegate detailed "Specifications" to the `/docs` directory.

---

## README.md Template

````markdown
# Project Name

[One-sentence description of the project]

## Features

- [Key Feature 1]
- [Key Feature 2]
- [Key Feature 3]

## Quick Start

### Prerequisites

[Required tools and their minimum versions, e.g., Node.js >= 20.0.0]

### Installation

```bash
[Installation commands]
```
````

### Environment Variables

[Instructions to copy `.env.example` and set required values]

### Run

```bash
[Command to start the development server]
```

## Architecture

[Brief high-level explanation. Refer to `docs/design.md` for the full architecture.]

## Development

[Mention that development environment setup, test execution, and coding conventions are defined in `AGENTS.md`.]

## Documentation

| Document                                     | Content                        |
| -------------------------------------------- | ------------------------------ |
| [docs/requirements.md](docs/requirements.md) | Requirements & Goals           |
| [docs/design.md](docs/design.md)             | System Design & Architecture   |
| [docs/tech.md](docs/tech.md)                 | Tech Stack & Web Standards     |
| [docs/test.md](docs/test.md)                 | Testing Strategy               |
| [docs/tasks.md](docs/tasks.md)               | Roadmap & Task Management      |
| [docs/directory.md](docs/directory.md)       | Directory Structure            |
| [docs/problems.md](docs/problems.md)         | Known Issues & Risks           |
| [AGENTS.md](AGENTS.md)                       | Development Rules & Guidelines |

## License

[License type, e.g., MIT]

```

**README.md Checkpoints:**

- **5-Minute Rule**: Can a newcomer understand the project's essence within 5 minutes?
- **Copy-Paste Friendly**: Can installation and startup be completed solely by copy-pasting provided commands?
- **Standardization**: Are Environment Variables clearly explained via `.env.example`?
- **Navigation**: Are there clear, functional links to the detailed `/docs`?
```
