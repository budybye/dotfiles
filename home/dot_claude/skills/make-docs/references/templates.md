# /make-docs Template Collection

Detailed templates for the seven files under `docs/`, auto-scan commands, and consistency check criteria.

## Important Instructions

When using these templates:
1. ALWAYS customize them with project-specific information
2. NEVER leave placeholder text like `[Version]` or `[Feature Name]`
3. ENSURE technical details are consistent across all files
4. VERIFY that commands in README.md actually work

---

## Auto-scan Commands

Execute these when a project directory is specified to gather context from the existing codebase.

⚠️ IMPORTANT: Run these commands in the project root directory.

```bash
# Directory structure (excluding build artifacts and dependencies)
find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/.next/*' -not -path '*/build/*' -not -path '*/target/*' | head -100

# Existing documentation (may inform style and content)
cat README.md AGENTS.md 2>/dev/null

# Package definitions (identify tech stack)
cat package.json 2>/dev/null || cat Cargo.toml 2>/dev/null || cat pyproject.toml 2>/dev/null || cat composer.json 2>/dev/null || cat Gemfile 2>/dev/null

# Infrastructure and config (deployment, environment)
cat wrangler.toml docker-compose.yml Dockerfile 2>/dev/null
ls *.config.* .env.example .env.local 2>/dev/null

# Existing docs (avoid duplication)
ls docs/ 2>/dev/null && cat docs/*.md 2>/dev/null | head -500
```

After running these commands:
1. Analyze the results to understand the project structure
2. Identify gaps in information that require user input
3. Formulate exactly 2-3 targeted questions to fill those gaps

---

## docs/requirements.md Template

```markdown
# Requirements Definition

## Project Overview

[2–3 sentences on the purpose, background, and the problem being solved]

## Functional Requirements

### Must Have

- [ ] [Feature Name]: [Description]

### Should Have

- [ ] [Feature Name]: [Description]

### Could Have

- [ ] [Feature Name]: [Description]

## Non-Functional Requirements

### Performance

[Response time targets, throughput requirements]

### Security

[Authentication/Authorization methods, data protection requirements]

### Scalability

[Expected user count, projected data growth]

### Availability

[SLA targets, acceptable downtime during failures]

## Constraints

[Technical constraints, budget, timeline, regulations, dependencies]

## Glossary

| Term   | Definition   |
| ------ | ------------ |
| [Term] | [Definition] |
```

---

## docs/design.md Template

```markdown
# Design Specifications

## Architecture Overview

[Visual representation of the overall structure using Mermaid or text]

### Principles & Web Standards

- **Standard-First Architecture**: Prioritize Web standard APIs (e.g., native `fetch`, Web Crypto) to reduce vendor lock-in and polyfill overhead.
- **Stateless Design**: Prefer stateless communication patterns where possible.
- **Portability**: Design components to be portable across standard runtimes (Node.js, Deno, Bun, Cloudflare Workers).

## Module Structure

[Responsibilities and dependencies of each module]

### [Module Name]

- **Responsibility**: [What it does]
- **Dependencies**: [Which modules it depends on]
- **Public Interface**: [Exposed APIs/Functions]

## Data Model

[Key data structures, schemas, or ER diagrams]

## API Design

| Method | Path     | Description | Auth Required | Standards Used         |
| ------ | -------- | ----------- | ------------- | ---------------------- |
| GET    | /api/xxx | [Desc]      | Yes/No        | e.g. JSON, CORS, fetch |

## State Management

[State storage methods and transition diagrams]

## Architecture Decision Records (ADR)

### ADR-001: Use Native Web Standards

- **Status**: [Accepted/Proposed]
- **Context**: [Problem description]
- **Decision**: Adopt native Web APIs (fetch, Web Crypto, TextEncoder) as the default.
- **Rationale**: To leverage platform performance, reduce bundle size, and ensure long-term compatibility.
- **Consequences**: Minimal dependencies, faster cold starts in serverless environments.
```

---

## docs/tech.md Template

```markdown
# Technical Specifications

## Technical Stack

| Category       | Technology | Version   | Notes/Standards                |
| -------------- | ---------- | --------- | ------------------------------ |
| Language       | [Language] | [Version] |                                |
| Framework      | [FW Name]  | [Version] |                                |
| Runtime        | [Runtime]  | [Version] | e.g., Node.js, Bun, Cloudflare |
| Database       | [DB Name]  | [Version] |                                |
| Infrastructure | [Platform] | -         |                                |

### Adopted Web Standards

- **Communication**: Native `fetch` API for all network requests.
- **Cryptography**: Web Crypto API (`SubtleCrypto`) for hashing, encryption, and signatures.
- **Storage**: Prefer standard-compliant storage (e.g., Cache API, IndexedDB) where available.
- **Encoding**: `TextEncoder` and `TextDecoder` for character encoding.
- **Streams**: Web Streams API for efficient data processing.

## Development Environment

### Required Tools

[List of tools and version requirements]

### Setup Procedure

[Step-by-step instructions with commands]

### Environment Variables

| Variable   | Required | Description | How to Obtain |
| ---------- | -------- | ----------- | ------------- |
| [VAR_NAME] | Yes/No   | [Purpose]   | [Source]      |

## Infrastructure Configuration

[Deployment targets, CI/CD, monitoring]

## External Service Integration

| Service        | Purpose | SDK/API          | Standard Used        |
| -------------- | ------- | ---------------- | -------------------- |
| [Service Name] | [Usage] | [Library/Direct] | e.g., REST via fetch |

## Important Configuration Files

### [File Name] (e.g., wrangler.toml)

[Explanation of key configuration items]
```

---

## docs/test.md Template

```markdown
# Testing Policy

## Testing Strategy

[Strategy for each layer of the test pyramid: Unit, Integration, E2E]

## Testing Environment

- Framework: [e.g., Vitest / Jest / pytest]
- Mocking: [Mocking policy and libraries, e.g., MSW for fetch mocking]
- Test DB: [Handling of test databases]

## Test Categories

### Unit Tests

[Scope and policy]

### Integration Tests

[Scope and policy]

### E2E Tests

[Scope and policy]

## Coverage Goals

[Numerical targets and measurement methods]

## Test Execution in CI/CD

[Triggers and blocking conditions]
```

**Note**: Specific test cases are managed in `tests/testlist.md` (by the `/testcase` skill). This file focuses on policy and strategy.

---

## docs/tasks.md Template

```markdown
# Task Management

## Milestones

| Phase        | Goal   | Deadline | Status                                |
| ------------ | ------ | -------- | ------------------------------------- |
| [Phase Name] | [Goal] | [Date]   | Not Started / In Progress / Completed |

## Current Focus

[Current tasks, blockers]

## Backlog

### High Priority

- [ ] [Task]

### Medium Priority

- [ ] [Task]

### Low Priority

- [ ] [Task]

## Completed

- [x] [Task] (YYYY-MM-DD)
```

---

## docs/directory.md Template

```markdown
# Directory Structure

## Overall Structure

[Tree-like structure diagram. Include major directories only; exclude node_modules, etc.]

## Directory Responsibilities

| Path     | Role          |
| -------- | ------------- |
| `src/`   | [Description] |
| `tests/` | [Description] |

## File Naming Conventions

[Case conventions, extension rules]

## Guidelines for Adding New Files

[Rules on what goes where]
```

---

## docs/problems.md Template

```markdown
# Issues & Concerns

## Unresolved Technical Issues

| ID    | Issue   | Impact       | Action Plan | Assignee |
| ----- | ------- | ------------ | ----------- | -------- |
| P-001 | [Issue] | High/Med/Low | [Plan]      | [Name]   |

## Known Bugs & Limitations

[Known problems and workarounds]

## Technical Debt

| Debt   | Impact   | Repayment Plan |
| ------ | -------- | -------------- |
| [Debt] | [Impact] | [Plan]         |

## Risk Registry

| Risk   | Probability  | Impact       | Mitigation |
| ------ | ------------ | ------------ | ---------- |
| [Risk] | High/Med/Low | High/Med/Low | [Plan]     |

## Under Investigation

- [ ] [Investigation Topic]
```

---

## Consistency Check Details

Specific points to verify in Phase 5:

| Check Item            | Source of Truth                   | Reference Side         |
| --------------------- | --------------------------------- | ---------------------- |
| Technical Stack       | docs/tech.md                      | README.md, AGENTS.md   |
| Environment Variables | docs/tech.md                      | README.md, AGENTS.md   |
| Directory Structure   | docs/directory.md (+ actual dirs) | AGENTS.md              |
| Testing Policy        | docs/test.md                      | TDD Rules in AGENTS.md |
| Tasks ↔ Problems      | docs/tasks.md ↔ docs/problems.md  | Mutual references      |

If duplicates are found, keep the details in the source of truth and replace the reference side with "→ See [Source of Truth]".
