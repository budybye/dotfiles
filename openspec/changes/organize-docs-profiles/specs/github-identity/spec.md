## Purpose

Defines GitHub account use on this machine: `budybye` is the default identity and `boborder` is an explicit switch target. `dayjobdoor` is unused.

## ADDED Requirements

### Requirement: Default account is budybye
Git author identity and `gh` default user MUST be `budybye` unless the operator has switched. Source-managed `gh` host config MUST NOT set the default user to `boborder` or `dayjobdoor`.

#### Scenario: Fresh shell
- **WHEN** the operator has not switched accounts
- **THEN** `gh` MUST treat `budybye` as the active user
- **AND** git commits MUST use the `budybye` identity configured for that machine

### Requirement: boborder is switchable
The operator MUST be able to move GitHub CLI activity to `boborder` with `gh auth switch` and back to `budybye` the same way. This change MUST NOT add path-based `includeIf` switching.

#### Scenario: Switch to boborder
- **WHEN** the operator runs `gh auth switch --user boborder`
- **THEN** subsequent `gh` commands MUST use `boborder`
- **AND** `dayjobdoor` MUST NOT be required or documented as a supported account

### Requirement: Unused accounts stay out of the contract
`dayjobdoor` MUST NOT be part of the supported account set. Existing local logins MAY remain on disk but MUST NOT be configured, documented, or defaulted by this repository.

#### Scenario: Documented accounts
- **WHEN** a reader lists supported GitHub accounts
- **THEN** the list MUST be `budybye` (default) and `boborder` (switch)
- **AND** the list MUST NOT include `dayjobdoor`
