## Purpose

Moves the C4 model into OpenSpec so context, containers, components, deployment, and dynamic flows stay one capability instead of a second docs tree.

## ADDED Requirements

### Requirement: Required C4 views
The architecture capability MUST keep these files next to `spec.md`, using the original names:

- `c4-context.md`
- `c4-containers.md`
- `c4-components-source.md`
- `c4-deployment.md`
- `c4-dynamic-apply.md`
- `c4-dynamic-bootstrap.md`
- `c4-dynamic-ci.md`

Each file MUST contain a Mermaid C4 diagram for that view. `spec.md` MUST state the reading order.

#### Scenario: Architecture lookup
- **WHEN** a reader needs the system context
- **THEN** `openspec/specs/architecture/c4-context.md` MUST exist and contain the context diagram
- **AND** `docs/architecture/` MUST NOT remain as a second copy after migration

### Requirement: Diagrams stay current with apply targets
C4 deployment and dynamic-CI views MUST describe chezmoi apply, bootstrap, and the test → tag → GHCR / IPFS pipeline. They MUST NOT point at deleted `docs/*.md` paths.

#### Scenario: After docs deletion
- **WHEN** `docs/` has been removed
- **THEN** architecture files MUST link only to `openspec/` specs or repo-root entry files
