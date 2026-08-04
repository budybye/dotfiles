## Context

See `proposal.md` for motivation. The repository already uses a Chezmoi source tree, a templated `home/.chezmoi.toml.tmpl`, `.chezmoidata/packages.yaml`, platform-specific `.chezmoiscripts` directories, encrypted files, and `.chezmoiexternal.toml.tmpl`. `Makefile` already exposes `apply`, `check`, `test`, `doctor`, and `verify`, but several checks are best-effort and current platform decisions mix OS detection with usernames and environment flags.

The reference `twpayne/dotfiles` repository uses feature booleans such as `ephemeral`, `work`, `headless`, and `personal`, derives a normalized OS identifier, and keeps the installer as a small `chezmoi init --apply --source=...` wrapper. The official Chezmoi source and documentation define the complete attribute model, `.chezmoitemplates`, templated `.chezmoiignore`, `chezmoi data`, `chezmoi ignored`, and `chattr`.

The design must preserve the existing `home/` layout, keep macOS/Linux/Windows support, avoid new runtime dependencies, and avoid exposing age or Bitwarden secrets during CI, container, or sandbox runs.

## Goals / Non-Goals

**Goals:**

- Make platform and environment selection deterministic and centralized.
- Make managed file attributes and lifecycle ordering auditable from source names and script names.
- Make external resources and secret-dependent rendering fail clearly without destroying a usable target state.
- Turn existing Make targets into a predictable preview, validation, and apply workflow.
- Migrate incrementally so each group of files remains reviewable and reversible.

**Non-Goals:**

- Replace Chezmoi with another dotfile manager.
- Rewrite every configuration file for style consistency.
- Enable automatic Git commits, pushes, or destructive cleanup during `chezmoi apply`.
- Add a new package manager or secret-management service.
- Make optional GUI applications available on every supported platform.

## Decisions

### Centralize context, keep file layout stable

Keep `home/.chezmoi.toml.tmpl` as the source for derived context such as OS, Linux distribution, normalized OS identifier, host environment, feature booleans, and secret availability. Store reusable package and feature data in `.chezmoidata/`. Use `.chezmoitemplates` for shared content rendered into multiple target paths, and use file-local templates only for values that cannot be shared cleanly.

Use `.chezmoi.os` and `.chezmoi.osRelease` as the primary platform signals. Use `.chezmoi.hostname` only for deliberate host-level differences. Keep username, container, CI, and sandbox checks as explicit environment overlays rather than using usernames as the main OS discriminator. Expose the resulting context through `chezmoi data`; prompt for host-only choices only in interactive runs.

**Alternative rejected:** duplicating complete configuration trees per platform. It reduces template branching but creates drift and makes shared changes expensive.

### Treat Chezmoi filename attributes as the permission and lifecycle contract

Audit managed files and encode target behavior in source attributes, including `dot_`, `private_`, `encrypted_`, `executable_`, `symlink_`, `readonly_`, `create_`, `modify_`, `remove_`, `empty_`, `exact_`, `once_`, `onchange_`, `before_`, and `after_`. Use `chattr` for safe attribute changes instead of manual renames followed by unverified permission edits. Preserve Chezmoi's documented prefix order for each target type.

**Alternative rejected:** a separate permissions or lifecycle manifest. It duplicates Chezmoi's native model and can drift from the managed file.

### Keep lifecycle scripts phase-specific and idempotent

Use existing `home/.chezmoiscripts/darwin/`, `linux/`, and shared script locations. Use `run_once_`, `run_onchange_`, `run_before_`, and `run_after_` naming only when the execution contract requires that phase. Each script checks prerequisites, is safe to repeat, and exits nonzero on real failure.

Package installation and bootstrap remain separate from configuration rendering. Generated or host-local state is excluded from normal source management.

**Alternative rejected:** one monolithic bootstrap script. It obscures ordering, increases blast radius, and makes retries unsafe.

### Keep secrets and external resources declarative but fail closed

Retain age and Bitwarden as the existing secret mechanisms. Template branches may disable secret access in CI, containers, and sandboxes, but a real host that requires a secret must report the missing prerequisite instead of silently writing placeholder credentials.

Keep external downloads in `.chezmoiexternal.toml.tmpl`, with refresh periods and exact or pinned references where supported. Validate URLs and archive paths before application and preserve the previous target resource when refresh fails.

**Alternative rejected:** downloading resources from lifecycle scripts. That hides dependencies, complicates idempotence, and bypasses Chezmoi's refresh behavior.

### Make preview and validation explicit gates

Use `chezmoi data` to inspect resolved context, `chezmoi diff` for review, `chezmoi ignored` and `chezmoi managed` for source selection checks, `chezmoi apply --dry-run` for target-side preview, `chezmoi execute-template` for template smoke checks, and `chezmoi verify` for managed-state verification. Keep `make check`, `make test`, and `make verify` as the human and CI entry points, but make failures visible rather than converting all failures into skipped success.

Validation covers rendered templates, shared template expansion, shell syntax via the repository's existing shellcheck installation, Chezmoi attributes, platform filtering, and required command availability. Real secret retrieval remains an explicit host-only check rather than a CI prerequisite.

**Alternative rejected:** relying on `chezmoi apply` alone. It detects problems late and can mix template, permission, external-resource, and script failures in one operation.

## Risks / Trade-offs

- [Platform branches become more explicit] → Add representative dry-run checks for macOS, Linux, and container/CI contexts before migration is complete.
- [Stricter validation exposes existing drift] → Migrate in small groups and fix the first reported source/target mismatch before continuing.
- [External downloads can fail or change upstream] → Pin versions or exact archive references, retain refresh periods, and preserve the previous usable resource on failure.
- [Secret-dependent templates cannot run everywhere] → Keep explicit non-interactive modes and report which prerequisite is missing.
- [Changing lifecycle timing can affect bootstrap order] → Rename one script group at a time and verify with `chezmoi apply --dry-run` plus a disposable host/container.
- [A larger validation gate slows local iteration] → Keep fast syntax/template checks separate from network-dependent external-resource checks.

## Migration Plan

1. Inventory current templates, attributes, scripts, externals, ignored files, and generated paths.
2. Record current target behavior with `chezmoi data`, `chezmoi diff`, `chezmoi managed`, `chezmoi ignored`, and permission checks on a representative macOS host and Linux environment.
3. Normalize context, feature booleans, `.chezmoitemplates`, and platform selection without changing rendered output.
4. Audit and rename file attributes with `chattr` where appropriate, then validate permissions and secret handling.
5. Normalize lifecycle script phases and idempotence one script group at a time.
6. Pin or verify external resources and separate generated state from managed source.
7. Strengthen `make check`, `make test`, and `make verify`; run them in local and CI-safe modes.
8. Apply the migration to disposable environments before applying to a primary host.

Rollback is a source-controlled revert followed by `chezmoi apply` from the last known-good revision. Do not delete target files as part of rollback unless the diff explicitly shows that removal and has been reviewed.
