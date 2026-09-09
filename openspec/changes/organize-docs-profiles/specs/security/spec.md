## Purpose

Locks the secret-handling rules for age, Bitwarden, SSH keys, and GitHub CLI credentials so tokens never land in the source tree.

## ADDED Requirements

### Requirement: Secrets stay encrypted or out of git
Age-managed secrets MUST remain encrypted in source. Bitwarden lookups MAY fill templates at apply time. Plain tokens MUST NOT be committed. `gh` MUST use the OS keyring, not `--insecure-storage`, for normal machines.

#### Scenario: hosts.yml in source
- **WHEN** `home/private_dot_config/gh/hosts.yml` is present in the source tree
- **THEN** it MUST NOT contain OAuth or PAT material
- **AND** it MUST NOT name an unused account as the default user

### Requirement: Age enabled only on trusted hosts
Age and Bitwarden MUST be enabled for trusted personal usernames and MUST be disabled in CI, Codespaces, Docker, and sandbox identities.

#### Scenario: GitHub Actions apply
- **WHEN** chezmoi runs with `GITHUB_ACTIONS=true`
- **THEN** age and Bitwarden MUST stay disabled
- **AND** encrypted files MUST NOT be required to decrypt
