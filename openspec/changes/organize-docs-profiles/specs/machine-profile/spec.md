## Purpose

Splits machine setup by hostname so Ubuntu desktop software is not forced onto minimal hosts, using the numeric hostname scheme already present on this fleet.

## ADDED Requirements

### Requirement: Hostname selects the profile
Chezmoi MUST choose a machine profile from `.chezmoi.hostname`. Known current host: `101` is this macOS machine. Profile values MUST include at least `desktop` and `minimal` for Ubuntu hosts.

#### Scenario: Unknown hostname
- **WHEN** apply runs on a hostname that is not in the profile table
- **THEN** the apply MUST fail closed or take an explicit safe default documented in the table
- **AND** it MUST NOT silently install the full desktop GUI set

### Requirement: Minimal Ubuntu skips GUI packages
A hostname mapped to `minimal` MUST receive `linux.cli` packages and MUST NOT install `linux.gui` packages or run Linux GUI bootstrap scripts. A hostname mapped to `desktop` MUST receive both `linux.cli` and `linux.gui`.

#### Scenario: Minimal host apply
- **WHEN** hostname maps to `minimal`
- **THEN** xfce / xrdp / display-manager packages MUST NOT be installed by this repo
- **AND** `home/.chezmoiscripts/linux/` GUI hooks MUST NOT run

### Requirement: Profile table is data, not prose
The hostname → profile map MUST live in chezmoi data, not only in markdown. Ubuntu desktop and minimal hostnames MAY be added to that table without changing this requirement.

#### Scenario: Adding a Ubuntu host
- **WHEN** a new Ubuntu hostname is assigned `desktop` or `minimal` in chezmoi data
- **THEN** the next apply on that host MUST follow the matching package set
