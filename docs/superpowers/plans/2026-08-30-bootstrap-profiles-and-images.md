# Bootstrap Profiles and Image Flavors Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make local, CI, Ubuntu VM, and Docker bootstrap behavior explicit while preserving full macOS cask/MAS validation and separating future CLI-only images.

**Architecture:** The workstation config remains the full local profile. `ci.toml` and `docker.toml` are independent package profiles selected with `MISE_CONFIG_FILE`; CI and Docker profiles contain only their required package sets. Local macOS keeps the full Darwin hook, while GitHub Actions runs each macOS manager as a separate workflow step.

**Tech Stack:** Mise bootstrap 2026.8.14, Chezmoi 2.72.0, Bash, GitHub Actions, Docker Buildx, `devcontainers/ci@v0.3`.

**Spec:** `openspec/changes/chezmoi-to-mise-migration/specs/` and `openspec/changes/chezmoi-to-mise-migration/design.md`.

## Global Constraints

- macOS CI runs brew, brew-cask, and mas; cask/MAS failures continue and appear in the job summary.
- Ubuntu VM treats the complete apt profile as required and exits non-zero on apt failure.
- CI and Docker profiles contain Linux CLI packages only; GUI, xrdp, PipeWire, SDDM, and system services are excluded.
- Local macOS runs the full Darwin bootstrap through `make init`.
- GitHub Actions sets `MISE_CONFIG_FILE=~/.config/mise/ci.toml`; Docker sets `/home/ubuntu/.config/mise/docker.toml` before `make init`.
- Mac CI timeout is 60 minutes; Docker image build timeout is 180 minutes.
- Current `slim` flavor is renamed to `full`; `dev` remains a separate devcontainer build and tag.
- `latest` and semver tags temporarily point to `full`; a later change repurposes `slim` for CLI-only after multi-architecture smoke tests.
- `full` and `dev` use no registry cache; cache policy for future CLI-only slim is a separate change.

---

### Task 1: Add independent Mise package profiles

**Files:**
- Create: `home/private_dot_config/mise/ci.toml`
- Create: `home/private_dot_config/mise/docker.toml`
- Modify: `home/private_dot_config/mise.toml` only when removing profile-specific declarations

**Interfaces:**
- `ci.toml` is selected through `MISE_CONFIG_FILE=~/.config/mise/ci.toml`.
- `docker.toml` is selected through `MISE_CONFIG_FILE=/home/ubuntu/.config/mise/docker.toml`.
- Each file owns a complete `[bootstrap.packages]` table and contains no `[tools]` table.

- [ ] Step 1: Copy the current Linux CLI package entries into both profiles with `os = "linux"`; omit XFCE, xrdp, PipeWire, SDDM, and all GUI applications.
- [ ] Step 2: Copy current macOS formula, cask, and MAS entries into `ci.toml` with `os = "macos"`; keep `windows-app` out because its pkg installer choices are unsupported by Mise.
- [ ] Step 3: Keep `home/private_dot_config/mise.toml` as the full local workstation profile, including macOS GUI defaults, MPD LaunchAgent, full apt workstation packages, and existing macOS casks/MAS.
- [ ] Step 4: Verify `mise config ls` parses all three files and `mise bootstrap packages status` reports no unsupported manager for each selected OS profile.

### Task 2: Separate local and GitHub Actions Darwin bootstrap

**Files:**
- Modify: `home/.chezmoiscripts/darwin/run_onchange_after_bootstrap.sh`
- Modify: `.github/workflows/test.yaml`

**Interfaces:**
- Local execution keeps `mise bootstrap -y` in the Darwin hook.
- GitHub Actions skips the Darwin hook's package/bootstrap invocation.
- The `darwin` workflow job runs `make init` first, then manager-specific Mise commands.

- [ ] Step 1: Guard only the Darwin hook's `mise bootstrap -y` call with `if [ "${GITHUB_ACTIONS:-}" != "true" ]; then ... fi`; keep Homebrew and prerequisite setup unchanged for local hosts.
- [ ] Step 2: Add `MISE_CONFIG_FILE: ~/.config/mise/ci.toml` to the macOS test job environment.
- [ ] Step 3: Set the Darwin job `timeout-minutes: 60`.
- [ ] Step 4: Add sequential steps after `make init`: required `brew` package apply, optional `brew-cask` package apply with `continue-on-error: true`, optional `mas` package apply with `continue-on-error: true`, macOS defaults apply, and launchd-agents apply.
- [ ] Step 5: Add one final step that writes failed optional manager names to `$GITHUB_STEP_SUMMARY` using step outcomes; required steps remain fail-fast.

### Task 3: Rename current image flavors without changing build ownership

**Files:**
- Modify: `.github/workflows/push.yaml`
- Modify: `docs/README.md` and `docs/platform-matrix.md`

**Interfaces:**
- `full` uses the current direct `docker/build-push-action` path and `.devcontainer/Dockerfile`.
- `dev` uses `devcontainers/ci@v0.3` and `.devcontainer/Dockerfile`.
- `full` and `dev` publish architecture tags and multi-architecture manifest tags.

- [ ] Step 1: Rename matrix flavor `slim` to `full` in the build and merge jobs.
- [ ] Step 2: Change all `slim` conditionals, digest artifact names, and manifest conditions to `full`.
- [ ] Step 3: Remove registry `cache-from` and `cache-to` from the renamed `full` build; keep the existing no-cache `dev` path.
- [ ] Step 4: Change the full image's metadata tags so `latest` and semver tags are attached to `full` during the transition.
- [ ] Step 5: Keep `dev` as an independent multi-architecture image and preserve its existing architecture tags.
- [ ] Step 6: Verify YAML parses and every old flavor reference is either intentionally migrated to `full` or retained as the documented temporary `slim` compatibility tag.

### Task 4: Document future CLI-only slim image

**Files:**
- Modify: `docs/bootstrap.md`
- Modify: `docs/platform-matrix.md`
- Modify: `openspec/changes/chezmoi-to-mise-migration/design.md`

**Interfaces:**
- This task documents, but does not implement, the follow-up CLI-only image change.
- Follow-up image source: `.devcontainer/Dockerfile.cli`.
- Follow-up tags: `linux-amd64-slim` and `linux-arm64-slim`.

- [ ] Step 1: Document the gate: build both architectures, pull each image, start each image, and run the basic CLI smoke command before repurposing `slim`.
- [ ] Step 2: Document the transition: temporarily preserve `slim` as the full alias, publish CLI-only images under architecture tags, then repurpose `slim` and move `latest`/semver to the CLI-only manifest in a separate change.
- [ ] Step 3: Document that `full` and `dev` remain available after the future `slim` transition.

### Task 5: Document environment and failure contracts

**Files:**
- Modify: `docs/bootstrap.md`
- Modify: `docs/platform-matrix.md`
- Modify: `docs/context.md`
- Modify: `docs/README.md`
- Modify: `openspec/changes/chezmoi-to-mise-migration/tasks.md`

- [ ] Step 1: Document local `make init`, Mac CI workflow orchestration, Ubuntu VM full apt, CI CLI profile, and Docker CLI profile.
- [ ] Step 2: Document required versus warning operations: apt/full defaults/launchd fail-fast; cask/MAS and Ubuntu GUI installers warn and continue where applicable.
- [ ] Step 3: Document `MISE_CONFIG_FILE` values and the fact that profile files contain packages only; `mise/config.toml` remains the tools source.
- [ ] Step 4: Document `disk8 ejected` as normal cask DMG cleanup output; actual cask failures are identified by the manager step outcome.
- [ ] Step 5: Update OpenSpec tasks to reflect completed profile, workflow, and image flavor decisions without adding implementation details to the behavior specs.

### Task 6: Verify the complete change

**Files:**
- Test: shell syntax, workflow YAML, Mise profile parsing, dry-run manager selection

- [ ] Step 1: Run `bash -n` and `shellcheck` on modified shell scripts.
- [ ] Step 2: Run `mise config ls` against each profile.
- [ ] Step 3: Run dry-run package status for the workstation profile and verify Mac cask/MAS remain present.
- [ ] Step 4: Run a workflow YAML parser or `actionlint` on `.github/workflows/test.yaml` and `.github/workflows/push.yaml`.
- [ ] Step 5: Run `openspec validate --specs` and `openspec validate chezmoi-to-mise-migration --strict`.
- [ ] Step 6: Confirm no secrets or package credentials are emitted in workflow summaries.
