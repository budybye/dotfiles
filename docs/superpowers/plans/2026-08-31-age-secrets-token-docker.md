# Age Secrets, GitHub Tokens, and Docker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove Bitwarden unlock bootstrap, preserve Chezmoi passphrase encryption, keep Mise runtime age secrets separate, and make the Ubuntu xrdp session start reliably.

**Architecture:** Chezmoi remains authoritative for encrypted dotfiles and keeps age passphrase/symmetric encryption. Mise owns direct age-encrypted runtime environment values with a separate raw identity at `~/.config/mise/age.txt`. Docker owns its OS packages, ignores encrypted dotfiles and Linux Chezmoi hooks, and starts XFCE through an idempotent xrdp entrypoint.

**Tech Stack:** Chezmoi templates and scripts, Mise TOML and tasks, Bash, Dockerfile, xrdp/Xorg/XFCE, Markdown/OpenSpec.

**Spec:** `openspec/changes/chezmoi-to-mise-migration/design.md`, `openspec/specs/hybrid/coexistence/spec.md`

## Global Constraints

- `MISE_CONFIG_FILE` is unset in every environment; use `MISE_CONFIG_DIR` only.
- Existing Chezmoi `encrypted_*` files remain Chezmoi-owned.
- Docker never receives or stores age private keys, Bitwarden sessions, or GitHub tokens.
- GitHub Actions uses its existing `GITHUB_TOKEN`; local Mise may use the authenticated `gh` token fallback.
- Bitwarden desktop remains a macOS package; Bitwarden CLI and unlock automation are removed.
- Ubuntu VM uses SDDM for local login; xrdp uses XFCE X11; Docker has no display manager.
- Chezmoi keeps passphrase/symmetric encryption; it does not migrate existing encrypted files to recipient mode.

---

### Task 1: Migrate Chezmoi age configuration

**Files:**
- Modify: `home/.chezmoi.toml.tmpl`
- Modify: `home/.chezmoiignore`
- Modify: `home/dot_profile`
- Modify: `home/private_dot_config/mise/config.toml`
- Modify: `home/private_dot_config/mise.toml`

**Interfaces:**
- Consumes: existing Chezmoi passphrase configuration and manually created Mise identity `~/.config/mise/age.txt`.
- Produces: passphrase-only Chezmoi configuration and separate Mise direct-age key path.

- [ ] **Step 1: Preserve Chezmoi passphrase encryption**

  Keep `encryption = "age"`, `passphrase = true`, and `symmetric = true`. Remove the old `identity` and `recipients` entries because Chezmoi encrypted files use one interactive passphrase.

- [ ] **Step 2: Remove Bitwarden data plumbing**

  Remove Bitwarden data flags and branches that only exist to unlock or template secrets. Public SSH key deployment is a plaintext Chezmoi file derived once from the existing private key.

- [ ] **Step 3: Configure Mise direct age only**

  Keep `age.key_file = "~/.config/mise/age.txt"` in `home/private_dot_config/mise/config.toml`. Remove the Bitwarden tool entry, but retain the `age` tool entry because Chezmoi passphrase/symmetric encryption requires the age binary. Do not add `SOPS_AGE_KEY_FILE` because this repository has no SOPS integration.

- [ ] **Step 4: Preserve all-environment Mise path behavior**

  Keep `unset MISE_CONFIG_FILE MISE_GLOBAL_CONFIG_FILE` in `home/dot_profile` and export `MISE_CONFIG_DIR` from `XDG_CONFIG_HOME`.

- [ ] **Step 5: Verify the rendered configuration shape**

  Run the existing Chezmoi template/config validation for local, Docker, and GitHub Actions environments. Expected: local Chezmoi config retains passphrase/symmetric age; Docker/CI do not process encrypted targets or invoke secret providers.

---

### Task 2: Remove Bitwarden lifecycle and simplify age bootstrap

**Files:**
- Modify: `home/.chezmoiscripts/run_once_before_age.sh.tmpl`
- Delete: `home/.chezmoiscripts/run_once_before_bw.sh.tmpl`
- Modify: `home/dot_aliases`
- Modify: `home/private_dot_config/mise/config.toml`
- Modify: `home/private_dot_config/mise.toml`
- Modify: `home/.chezmoiignore`
- Delete after passphrase verification: `home/key.txt.age`

**Interfaces:**
- Consumes: Chezmoi passphrase configuration and the separate Mise raw identity.
- Produces: no Bitwarden CLI installation/unlock and no automatic Chezmoi key-file decryption.

- [ ] **Step 1: Remove Bitwarden lifecycle**

  Delete the Bitwarden hook, aliases, tool entry, template data branches, and `.env` session generation. Keep the macOS Bitwarden desktop package.

- [ ] **Step 2: Keep only age binary installation**

  Retain an age binary installation path because Chezmoi built-in age does not support passphrase/symmetric encryption. The hook may install age through Mise with brew/apt fallback, but it must not create or decrypt `key.txt`.

- [ ] **Step 3: Remove stale key-file ignore rules**

  Remove references that only protect `key.txt` or `shhh.txt` after the corresponding source files are gone. Keep Docker/remote-container rules that exclude encrypted targets.

- [ ] **Step 4: Verify passphrase encryption before cleanup**

  On a machine with the current passphrase, run `chezmoi decrypt` for every encrypted source entry and confirm `chezmoi diff` is clean. Only then delete `home/key.txt.age` and the old key-file path.

- [ ] **Step 5: Keep Mise runtime age separate**

  Keep `age.key_file = "~/.config/mise/age.txt"` for Mise direct-age values. This raw identity is unrelated to Chezmoi's passphrase and is never copied into Docker or CI.

---

### Task 3: Fix Docker xrdp session bootstrap

**Files:**
- Modify: `.devcontainer/entrypoint.sh`
- Modify: `home/dot_profile`
- Modify: `.devcontainer/Dockerfile`
- Modify: `home/.chezmoiignore`

**Interfaces:**
- Consumes: existing Ubuntu base `ubuntu` user and XFCE/xrdp packages.
- Produces: idempotent user setup and `.xsession` using the no-systemd XFCE path.

- [ ] **Step 1: Fix login-profile shell failure**

  Replace invalid `export store-dir="${XDG_DATA_HOME}/pnpm-store"` with `export npm_config_store_dir="${XDG_DATA_HOME}/pnpm-store"` or remove it. The current invalid variable name causes `dash` to exit with `bad variable name` while xrdp sources `.profile`.

- [ ] **Step 2: Make entrypoint user creation idempotent**

  Check `getent group` before `addgroup` and `id` before `useradd`. Existing `ubuntu` users must not produce fatal setup errors. Continue setting the requested password and sudo membership.

- [ ] **Step 3: Keep the shared no-systemd `.xsession` implementation**

  In no-systemd containers, write pipewire processes when available and finish with `exec dbus-run-session -- xfce4-session`; the systemd branch keeps plain `xfce4-session`.

- [ ] **Step 4: Keep Docker free of display-manager setup**

  Do not install or start SDDM in the Docker image. Keep xrdp services in the entrypoint and XFCE as the session manager.

- [ ] **Step 5: Verify the actual container path**

  Rebuild and start the Ubuntu image, connect over RDP, and confirm the session remains open with XFCE. Expected log sequence: successful login, Xorg display working, `xfce4-session` remains running; no immediate window-manager exit.

---

### Task 4: Update security and migration documentation

**Files:**
- Modify: `docs/security.md`
- Modify: `docs/design.md`
- Modify: `docs/directory.md`
- Modify: `docs/README.md`
- Modify: `openspec/changes/chezmoi-to-mise-migration/design.md`
- Modify: `openspec/changes/chezmoi-to-mise-migration/proposal.md`
- Modify: `openspec/changes/chezmoi-to-mise-migration/tasks.md`
- Modify: `openspec/specs/hybrid/coexistence/spec.md`

**Interfaces:**
- Consumes: final ownership decisions from Tasks 1–3.
- Produces: documentation with no references to removed Bitwarden unlock or legacy key bootstrap.

- [ ] **Step 1: Rewrite secret ownership tables**

  Record Chezmoi recipient-encrypted files, Mise direct-age runtime values, shared key path, manual key creation, and Docker ignore boundaries.

- [ ] **Step 2: Remove stale Bitwarden/legacy age instructions**

  Delete instructions for `bw unlock`, `BW_SESSION`, `shhh.txt`, `key.txt.age` bootstrap, and external age archive downloads. Keep Bitwarden desktop as an optional macOS application.

- [ ] **Step 3: Record GitHub token behavior**

  Document Mise token priority: CI `GITHUB_TOKEN`, local `gh` credential fallback, no committed token file, no profile export, and no BuildKit secret for normal public installs.

- [ ] **Step 4: Record Docker/xrdp behavior**

  Document Dockerfile-owned OS packages, no display manager, XFCE X11 xrdp session, and the distinction between runtime `environment` and Docker build-time environment.

---

### Task 5: Verify repository contracts

**Files:**
- Inspect: all modified files from Tasks 1–4
- Test: existing Makefile verification targets and Chezmoi/Mise validation commands

**Interfaces:**
- Consumes: completed migration and documentation changes.
- Produces: evidence that templates, scripts, package ownership, and Docker behavior agree.

- [ ] **Step 1: Validate shell syntax**

  Run `bash -n` for every modified shell script and `sh -n` for generated POSIX session scripts where available.

- [ ] **Step 2: Validate Chezmoi templates without secrets**

  Render or inspect Docker and GitHub Actions configurations. Expected: no Bitwarden function invocation, no age external GitHub API call, no private key requirement in Docker/CI.

- [ ] **Step 3: Validate Mise configuration**

  Run Mise config/status validation with `MISE_CONFIG_FILE` unset. Expected: standard config discovery works through `MISE_CONFIG_DIR`, no duplicate age/Bitwarden binary ownership, and GitHub token fallback remains external.

- [ ] **Step 4: Validate Docker build and RDP smoke path**

  Build the image, start xrdp, connect with the Ubuntu user, and verify a persistent XFCE session. Capture only non-secret logs.

- [ ] **Step 5: Validate documentation/spec consistency**

  Run OpenSpec validation and the repository’s existing verification target. Confirm no stale references remain to removed lifecycle files or obsolete ownership rules.
