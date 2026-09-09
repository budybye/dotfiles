## 1. Baseline and context

- [ ] 1.1 Inventory managed files, Chezmoi attributes, lifecycle scripts, externals, ignored paths, generated state, and installer/bootstrap behavior; verify the inventory against `chezmoi managed`, `chezmoi unmanaged`, `chezmoi ignored`, and the current source tree
- [ ] 1.2 Define normalized OS, distribution, host, feature-boolean, CI, container, and sandbox context data in `home/.chezmoi.toml.tmpl` and `.chezmoidata/`; verify representative renders and resolved values with `chezmoi execute-template` and `chezmoi data`

## 2. File attributes and layout

- [ ] 2.1 Normalize the full native attribute set (`dot_`, `private_`, `encrypted_`, `executable_`, `symlink_`, `readonly_`, `create_`, `modify_`, `remove_`, `empty_`, `exact_`, `once_`, `onchange_`, `before_`, and `after_`) for files that require those behaviors, using `chattr` where useful; verify target paths, permissions, links, and script phases
- [ ] 2.2 Separate generated, cache, host-local, and secret-derived files from ordinary managed content using `.chezmoiignore` and `.chezmoitemplates`; verify shared templates render to each intended target and excluded paths do not appear in `chezmoi managed`

## 3. Lifecycle automation

- [ ] 3.1 Normalize shared, Darwin, and Linux lifecycle script names and phases; verify ordering and rendered script paths with `chezmoi diff --include=scripts`
- [ ] 3.2 Make migrated lifecycle scripts prerequisite-aware, idempotent, and fail-closed; verify all changed shell scripts with `shellcheck` and repeat the relevant apply or dry-run path twice

## 4. Secrets and external resources

- [ ] 4.1 Harden age and Bitwarden template branches for real hosts versus CI, containers, and sandboxes; verify missing-secret behavior fails clearly without installing placeholder credentials
- [ ] 4.2 Pin or verify external resource references in `home/.chezmoiexternal.toml.tmpl`; verify template rendering, refresh metadata, and preservation of an existing resource when refresh fails

## 5. Validation and CI gates

- [ ] 5.1 Strengthen `make check`, `make test`, and `make verify` so template, script, attribute, dependency, and platform failures are visible; verify each target returns the correct status in a dependency-complete and dependency-missing environment
- [ ] 5.2 Add CI-safe validation for supported platform branches and non-interactive secret modes; verify the workflow exercises template rendering, shell syntax, dry-run apply, and Chezmoi verification without requiring host secrets

## 6. Documentation and migration

- [ ] 6.1 Document the supported Chezmoi workflow, context variables, file attributes, lifecycle phases, secret modes, external-resource rules, and validation commands; verify every documented command exists in the repository
- [ ] 6.2 Apply the migrated source to disposable macOS, Linux, and container environments, record target diffs and permissions, and verify rollback by reverting the source revision and reapplying the last known-good state
