## Purpose

Preserves the project's Go-template whitespace and quoting rules so chezmoi templates stay render-safe across shell, TOML, and structured files.

## ADDED Requirements

### Requirement: Control-structure trim
When an `if` / `else` / `end` or `range` / `end` occupies a whole line, the template MUST use trim markers so the rendered file does not gain blank control lines.

#### Scenario: Whole-line if
- **WHEN** a template line is only a control action
- **THEN** the rendered output MUST NOT contain that line as empty noise

### Requirement: Quote values that enter shell or JSON
Values interpolated into shell or JSON MUST be quoted with the template `quote` pipeline when they can contain spaces or special characters.

#### Scenario: Path with spaces
- **WHEN** a template writes a filesystem path into a shell command
- **THEN** the path MUST be quoted in the rendered output
