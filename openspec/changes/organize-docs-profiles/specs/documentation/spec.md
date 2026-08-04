## Purpose

Defines where project documentation lives after the wiki dump is retired, and forbids republishing tool catalogs that already exist as skills or package source-of-truth files.

## ADDED Requirements

### Requirement: OpenSpec is the documentation home
Project requirements and surviving operational rules MUST live under `openspec/specs/<capability>/`. Human and agent entry files at the repo root MAY remain. After a capability's content has been migrated, the matching file under `docs/` MUST be deleted.

#### Scenario: Post-migration docs tree
- **WHEN** migration of all listed capabilities is complete
- **THEN** `docs/` including `docs/architecture/` MUST NOT exist
- **AND** README and AGENTS.md MUST point at `openspec/` instead of `docs/`

### Requirement: Skills not catalogs
Markdown MUST NOT restate installable tool lists that already live in `packages.yaml`, mise, or aqua. How-to for a tool MUST be provided by loading the matching skill, not by a new catalog page.

#### Scenario: Tool question
- **WHEN** an agent needs to explain or change a managed tool
- **THEN** it MUST use the picked skill and the package source-of-truth files
- **AND** it MUST NOT add a new `docs/` tool list
