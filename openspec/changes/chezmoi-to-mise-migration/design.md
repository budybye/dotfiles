## Plan at a glance

| Phase | What | Outcome |
|-------|------|---------|
| **0** | `install.sh` installs mise via curl; remove duplicate mise installers | Single bootstrap entry before first `chezmoi apply` |
| **1** | OS packages + curl app installers → mise; retire overlapping Chezmoi install scripts | `mise.toml` + `[tasks]` own ① Install |
| **2** | macOS UI defaults dedup | `[bootstrap.macos.*]` replaces `defaults.sh` UI writes |
| **3** | Optional: Docker/tube tasks; evaluate `[dotfiles]`; runtime secrets via mise `[env]` | Chezmoi stays for file encryption + templates |
| **4** | Context/feature flags + cross-platform matrix docs; slim `.chezmoiignore` | mac/linux/win behave predictably; docs match hybrid ownership |
| **5** | Dotfiles audit + security review (baseline + post-migration) | Inventory, secret posture, script risk documented |

**Steady-state tool split**

| Tool | Owns |
|------|------|
| **mise** | Tool versions, OS packages, macOS UI defaults, curl app installers, direct age-encrypted runtime environment values, GitHub token resolution |
| **chezmoi** | Templated dotfiles, passphrase/symmetric encrypted files, SSH configuration, VS Code extensions, agent skills, snap/Windows, platform scripts, external resources |

**Steady-state `packages.yaml`:** Chezmoi-owned extensions, agent skills, snap, and Windows entries only.

**New machine (target):** install Mise → create Mise runtime age identity when needed → `chezmoi apply` with interactive passphrase → `mise bootstrap packages apply` → `mise install` → GUI-specific setup.

---

## Execution priority & ordering

Phases are **sequential by default**. Tasks within a phase may run in parallel only when they touch disjoint files and share no verification dependency.

### Priority ladder

| Priority | Phase / workstream | When | Blocker for |
|----------|-------------------|------|-------------|
| **P0 — critical path** | Phase 0 (`install.sh` mise curl) | **First** | All mise bootstrap work |
| **P1 — high** | Phase 1 parity (packages, CLI/GUI split, curl tasks, script guards) | After P0 | Retiring chezmoi install scripts |
| **P1 — high** | Phase 1 docs skeleton (`bootstrap.md` stub) | Parallel with P1 code | None (can start early) |
| **P2 — medium** | Phase 2 macOS defaults dedup | After P1 package parity | Retiring `defaults.sh` |
| **P2 — medium** | Makefile → mise tasks (§6.3–6.5) | After P0; best after P1 flow stable | CI `make init` parity |
| **P3 — lower** | Phase 3 Docker / optional `[dotfiles]` / runtime secrets | After P1 stable on linux + mac | None |
| **P3 — lower** | Phase 4 context refactor + doc expansion | After P1 slimming + coordinate `maximize-chezmoi-features` 1.2 | `.chezmoiignore` rewrite |
| **P4 — assurance** | Phase 5 audit baseline (§10) | **Before** large script retirements (§5) | Informed guard/retire decisions |
| **P4 — assurance** | Phase 5 security review (§11) | After audit baseline; **repeat** after P1+P4 | Merge confidence |
| **P5 — hygiene** | jj / vcs tasks (§9.8), optional CLI Dockerfile | Anytime after P1 | None |

### Dependency graph (simplified)

```text
P0 install.sh
 └─► P1 parity + CLI/GUI split + curl tasks
      ├─► P2 macOS defaults
      ├─► P1.5 audit baseline (recommended before §5 retire)
      ├─► P5 script retire (§5) — only after parity + audit sign-off
      ├─► Makefile/mise tasks (§6)
      └─► P3 Docker (optional)
P1 complete + maximize-chezmoi 1.2
 └─► P4 context + docs matrix
P1 + P4
 └─► P5 security review (post-migration pass)
```

### Parallel workstreams (safe to overlap)

| Stream A | Stream B | Constraint |
|----------|----------|------------|
| Phase 0 code | `docs/bootstrap.md` skeleton | Doc must be updated when P0 lands |
| Phase 1 `mise.toml` edits | Parity table (task 1.1) | Table must be committed before §5.3 delete |
| `maximize-chezmoi-features` 1.2 | Phase 4 planning | Merge context model once; avoid duplicate `host_profiles` designs |
| Audit inventory (§10.1) | Phase 1 inventory (§1.1) | Reuse same parity/inventory artifact |

### What not to reorder

1. **Do not** retire chezmoi install scripts (§5) before CLI/GUI split (§2.0) and parity table (§1.1).
2. **Do not** slim `packages.yaml` (§5.3) before templates stop referencing removed keys.
3. **Do not** rewrite `.chezmoiignore` for `features.*` before `host_profiles.yaml` exists (coordinate phase 4 with `maximize-chezmoi-features`).
4. **Do not** enable mise runtime secrets (phase 3) before documenting chezmoi vs mise age key separation (security §11).

---

## Impact scope

### By phase (blast radius)

| Phase | Primary files | Systems affected | Risk | Rollback |
|-------|---------------|------------------|------|----------|
| **0** | `install.sh`, `before_*`, `packages.yaml` curl | All new machines | **Medium** — wrong PATH breaks first apply | Revert `install.sh`; restore script installers |
| **1** | `mise.toml`, `packages.yaml`, `.chezmoiscripts/*`, `.mise.toml` | macOS + Linux bootstrap | **High** — package drift, CI headless pulls GUI | Restore YAML + script guards; `mise bootstrap` status |
| **2** | `mise.toml` `[bootstrap.macos.*]`, `defaults.sh` | macOS UI only | **Low–Medium** — duplicate or missing defaults | Re-enable `defaults.sh` |
| **3** | `run_once_after_docker.sh`, `.devcontainer/*`, Makefile docker | Linux docker hosts, devcontainer | **Medium** — broken container build | Revert Dockerfile/Makefile; keep chezmoi docker script |
| **4** | `.chezmoi.toml.tmpl`, `.chezmoiignore`, `host_profiles.yaml`, `docs/*` | All platforms' template output | **High** — wrong secrets on CI/container | Git revert; `chezmoi data` fixture diff |
| **5** | `docs/audit*.md`, `docs/security.md`, CI gates | Documentation + validation only | **Low** if audit-first; findings may drive code fixes | N/A (docs); code fixes per finding |

### By concern (steady-state ownership)

| Concern | Touch during migration | Leave untouched |
|---------|------------------------|-----------------|
| Encrypted dotfiles (`encrypted_*`) | Verify passphrase decrypt; remove legacy key wrapper | Chezmoi passphrase/symmetric encryption |
| Bitwarden CLI/unlock | Remove hook, aliases, data branches, and session files | macOS Bitwarden desktop package |
| SSH keys/config | Replace dynamic public-key template with plaintext public key | Encrypted private keys and Chezmoi SSH config |
| Mise runtime age | Configure separate `~/.config/mise/age.txt` | Chezmoi passphrase remains independent |
| VS Code / Cursor settings | Slim `packages.yaml`; `run_onchange_after_vscode.sh` keeps Cursor symlinks only | Existing symlink behavior |
| zsh / sheldon / ZDOTDIR | Remove obsolete secret aliases | File layout and load order |
| CI (`test.yaml`) | Use existing `GITHUB_TOKEN` through Mise when needed | Workflow must keep passing `make init` |
| Docker | Dockerfile owns OS packages; encrypted targets ignored | No display manager; xrdp + XFCE X11 |
| Windows | Document in matrix | Full parity out of scope |

### Stakeholder / environment matrix

| Environment | Phase 0–1 impact | Validation required |
|-------------|------------------|---------------------|
| Personal macOS (`hotmilk`) | brew/mas bootstrap path changes | `mise bootstrap packages status`, `chezmoi apply` |
| Personal Linux GUI (`budybye`) | apt CLI vs GUI split | GUI task opt-in; `run_once_after_setup.sh` still runs |
| GitHub Actions (`ubuntu`) | Must stay CLI-only | `make init` in `test.yaml` |
| Docker devcontainer | `DOCKER=true` guards unchanged | Image build + `chezmoi apply` dry-run |
| Windows native | Minimal code change | Doc matrix only phase 4 |
| Fresh clone (`make init`) | Highest risk — full bootstrap | Disposable VM test before merging §5 |

---

## Documentation organization

### Taxonomy (target `docs/` layout)

| Tier | Audience | Files | Update trigger |
|------|----------|-------|----------------|
| **Entry** | Humans + agents | `README.md`, `AGENTS.md`, `docs/README.md` (new index) | Any phase completion |
| **Operations** | Setup / rebuild | `docs/bootstrap.md`, `docs/platform-matrix.md` | Phase 1, 4 |
| **Reference** | Day-to-day lookup | `docs/context.md`, `docs/references.md`, `docs/tech.md` | Phase 4, ongoing |
| **Migration** | One-time transitions | `docs/git-to-jj.md`, OpenSpec `changes/*` | Phase 4–5 |
| **Assurance** | Audit / security | `docs/audit-checklist.md`, `docs/security.md` (new) | Phase 5 |
| **Troubleshooting** | Debugging | `docs/problems.md`, `docs/go-template.md` | When branching changes |
| **Structure** | Contributors | `docs/directory.md`, `docs/design.md` | When tree or ownership shifts |

### Doc ownership rules (hybrid model)

1. **Single source of truth per fact** — e.g. OS packages → `mise.toml`, not `packages.yaml` + `tech.md` duplicate lists.
2. **`references.md`** = external URLs + pointer to internal canonical path (not duplicate prose).
3. **`tech.md`** = what we use; **`design.md`** = why; **`bootstrap.md`** = how to run.
4. **OpenSpec `changes/`** = active migration plan; **`docs/`** = steady-state after merge.
5. **Deprecate in place** — when slimming `packages.yaml`, add one-line redirect in `tech.md` / `references.md` until phase 1 ships.

### Documentation deliverables by phase

| Phase | New / updated docs |
|-------|-------------------|
| 0 | `bootstrap.md` § "Prerequisites" (chezmoi + mise curl) |
| 1 | `bootstrap.md` full flow; `tech.md` ownership table; `references.md` mise bootstrap links |
| 4 | `platform-matrix.md`, `context.md`; `problems.md` feature-flag section |
| 5 | `audit-checklist.md`, `security.md`; `docs/README.md` index |
| ongoing | `git-to-jj.md` (exists); align `AGENTS.md` |

---

## Dotfiles audit (phase 5)

**Goal:** Periodic, repeatable inventory of what chezmoi manages, what mise owns, and what is orphaned — not a one-time grep.

Coordinate with `openspec/changes/maximize-chezmoi-features` task **1.1** (managed file inventory); extend with mise hybrid scope.

### Audit scope checklist

| Area | Commands / artifacts | Pass criteria |
|------|---------------------|---------------|
| Managed files | `chezmoi managed`, `chezmoi unmanaged`, `chezmoi ignored` | No unexpected secrets in managed set |
| Templates | `chezmoi execute-template` per `docs/fixtures/` context | Renders without host secrets on CI profiles |
| Lifecycle scripts | List `.chezmoiscripts/**`; map phase `run_once`/`onchange`/`before`/`after` | Each script has owner (mise vs chezmoi) in matrix |
| Encrypted files | `find home -name 'encrypted_*'` | All listed in `security.md`; none plaintext |
| External resources | `.chezmoiexternal.toml.tmpl` | URLs pinned; refresh policy documented |
| Package duplication | Parity table (`tasks.md` §1.1) | Zero duplicate authoritative rows |
| Bootstrap idempotency | Run `chezmoi apply` + `mise bootstrap * apply` twice | Second run is no-op or status-only |
| Permissions | `chezmoi verify` | Passes on representative host |
| Dead code | Scripts guarded but never hit; commented `packages.yaml` blocks | Tracked in audit report |

### Audit cadence

| When | Type |
|------|------|
| **Before §5 script retirement** | Baseline audit (task 10.1) — required |
| **After phase 1 merge** | Post-migration audit (task 10.2) |
| **After phase 4 context refactor** | Template/ignore audit (task 10.3) |
| **Quarterly / major dep bump** | Light re-run of checklist |

Output: `docs/audit-report-YYYY-MM.md` (gitignored or committed summary without secrets).

---

## Security review (phase 5)

| Asset | Threat | Current control | Review focus |
|-------|--------|-----------------|--------------|
| Chezmoi passphrase | Leak via shell history or logs | Interactive prompt only; never stored in source/env | Verify encrypted files decrypt |
| Mise age identity | Leak into source, CI, or image | Separate `~/.config/mise/age.txt`, mode 600 | Verify ignore boundaries |
| SSH private keys | World-readable or accidental regeneration | `encrypted_*`, `chezmoi verify`, explicit `ssh_setup` | Key preservation and permissions |
| GitHub token | Shell/image-layer leakage | Actions `GITHUB_TOKEN`, local `gh` fallback | No committed token files or exports |
| `curl \| sh` installers | Supply-chain compromise | `install.sh`, Mise bootstrap URLs | Pin/check installer sources |
| Privileged scripts | Unintended system changes | Chezmoi `run_once` / Mise tasks | Review sudo boundaries |
| Multi-account GitHub SSH | Host alias misconfiguration | Managed `config.tmpl`; static public key | No cross-account key bleed |
| Devcontainer | Secrets enabled during build | `DOCKER=true` and encrypted target ignores | Re-verify Docker build |
| Third-party externals | Unpinned archive/tag drift | `.chezmoiexternal.toml.tmpl` | Pin and verify external URLs |

### Security review checklist

| # | Check | Method |
|---|-------|--------|
| S1 | No plaintext secrets in git history | Secret scan on `home/` |
| S2 | Chezmoi encrypted files decrypt with passphrase | `chezmoi decrypt` |
| S3 | CI/Docker ignore encrypted targets | `chezmoi ignored` and template render |
| S4 | Docker image contains no private key/token | Dockerfile and build logs |
| S5 | GitHub tokens remain external | Actions `GITHUB_TOKEN`; local `gh` fallback |
| S6 | Mise age identity has mode 600 | `stat ~/.config/mise/age.txt` |
| S7 | Mise age strict mode is enabled | Mise config review |
| S8 | External URLs remain within supply-chain policy | `.chezmoiexternal.toml.tmpl` review |

### Review timing

| Gate | Required reviews |
|------|------------------|
| Before removing legacy secret hooks | S1–S4 baseline |
| Before enabling Mise runtime secrets | S5–S7 |
| After external/bootstrap changes | S8 |

Findings → `docs/security.md` § "Open findings" with severity (critical/high/medium/low) and owner phase.

---

## Context

See `proposal.md` for motivation. The repository today splits bootstrap concerns across three layers:

| Layer | Location | Role today |
|-------|----------|------------|
| Data | `home/.chezmoidata/packages.yaml` | Declares darwin/linux package lists, curl installers, VS Code extensions, agent skills |
| Chezmoi scripts | `home/.chezmoiscripts/**` | Imperative install loops, macOS defaults, SSH setup, VS Code, skills |
| Mise bootstrap | `home/private_dot_config/mise.toml` | Already mirrors most brew/apt/mas packages and macOS defaults |

`home/private_dot_config/mise/config.toml` already owns `[tools]` and is symlinked by Chezmoi. Official `mise bootstrap` order is packages → (repos/)dotfiles → macOS defaults → `mise install` (tools); see [comparison section](#mise-vs-chezmoi-comparison-verified-2026-08-28). This repo does not yet invoke `mise bootstrap` as the primary machine-setup entrypoint, and `install.sh` does not yet install mise.

## Goals / Non-Goals

**Goals:**

- Establish Mise as the single authority for OS package installation and declarative macOS defaults.
- Migrate installer-script responsibilities that are already duplicated or trivially expressible as Mise tasks.
- Keep Chezmoi as the authority for templated configs, secrets, SSH multi-account, VS Code extensions, externals, and platform scripts without Mise equivalents.
- Deliver a phased, reversible migration with inventory parity checks before deleting Chezmoi scripts.

**Non-Goals:**

- Full `[dotfiles]` migration (Mise dotfiles API is deprecated in favor of `mise bootstrap dotfiles`; defer to a future change).
- Replacing Go-template host branching in `.chezmoi.toml.tmpl`.
- Moving Chezmoi encrypted files to Mise. Chezmoi remains passphrase/symmetric file encryption authority.
- Snap package management until Mise gains a supported manager or a package plugin exists.
- Windows package migration beyond documenting current Chezmoi PS1 script ownership.

## Decisions

### Phase model (incremental, not big-bang)

| Phase | Moves to Mise | Stays in Chezmoi |
|-------|---------------|------------------|
| **1 — Install parity** | `[bootstrap.packages]` authoritative; curl installers → `[tasks]`; disable overlapping package scripts after parity | Passphrase/symmetric encrypted files, SSH, Cursor symlinks, VS Code extensions, skills, snap, Windows, and templates |
| **2 — macOS defaults dedup** | `[bootstrap.macos.*]` and explicit macOS tasks own supported settings | Privileged `systemsetup`/`scutil` operations |
| **3 — Runtime secrets** | Mise direct-age values with separate `~/.config/mise/age.txt` | Chezmoi encrypted files and passphrase |
### macOS defaults parity map

| Legacy function | Current ownership | Notes |
|-----------------|-------------------|-------|
| `user_setup` | Deferred | `scutil` computer/host/user names are not user defaults |
| `system_setup` | Deferred | Privileged `systemsetup` operations remain explicit and inactive |
| `app_setup` | Mise raw defaults | SoftwareUpdate, commerce, and App Store keys |
| `interface_setup` | Mise friendly/raw defaults | Keyboard and trackpad values |
| `window_setup` | Mise raw defaults + explicit task | User defaults migrated; `chflags`, `/Library` writes, and notificationcenter unload remain deferred |
| `dock_setup` | Mise friendly/raw defaults + `macos-defaults-extra` | `persistent-apps` requires an array |
| `finder_setup` | Mise friendly/raw defaults + `macos-defaults-extra` | `NewWindowTargetPath` needs `$HOME`; keyboard shortcuts require a dictionary |
| `search_setup` | Omitted | Legacy calls are commented out and not active |
| `network_setup` | Omitted | Legacy call is commented out and not active |
| `restart` | Manual Mise task | `mise run macos-restart`; legacy call was commented out |

**Rationale:** Phase 1 has the highest duplication and lowest risk. Phases 2–3 touch identity and templating where mistakes are costly.

**Alternative considered:** Migrate everything to Mise dotfiles now. **Rejected** because Chezmoi templates, encryption, and per-host `data` blocks have no Mise equivalent; Mise dotfiles top-level command is also on a deprecation path.

### Single package inventory in `mise.toml`

Keep `packages.yaml` temporarily as a read-only reference during migration, then slim it to only Chezmoi-owned sections (`extensions`, `agents.skills`, snap lists) once parity is verified.

**Alternative considered:** Generate `mise.toml` from `packages.yaml` via template. **Rejected** for phase 1 — adds a third source of truth; direct edit of `mise.toml` matches current partial migration state.

### Bootstrap entrypoint: `install.sh` owns mise (curl fixed)

**Decision:** Install mise via `curl -fsSL https://mise.run | sh` in root `install.sh`, immediately after chezmoi and **before** `chezmoi init --apply`. This is the single canonical mise bootstrap path on macOS and Linux.

**Rationale:**
- Fresh Mac has no Homebrew yet; `install.sh` remains canonical for Mise.
- Chezmoi passphrase encryption still requires an age binary; `before_age` only ensures that binary is available.
- Bitwarden CLI and unlock are removed; no token or session file is created.

**`install.sh` target flow:**

```text
1. install chezmoi → ~/.local/bin/chezmoi
2. install mise    → ~/.local/bin/mise
3. export PATH=~/.local/bin:$PATH
4. chezmoi init --apply --source=<source>
     ├ run_once_before_age → ensure age binary
     └ run_onchange_*      → remaining platform tasks
5. mise bootstrap packages apply
6. mise bootstrap macos defaults apply (macOS only)
7. mise install
```

**Fallback only:** `before_*` scripts may keep a mise installer safety net when users skip `install.sh`. Primary path: `make init` → `./install.sh`.

## Migration Plan

| Phase | Focus | Gate |
|-------|-------|------|
| **0** | `install.sh` adds mise; dedupe installers | — |
| **1** | Package parity, CLI/GUI split, mise tasks, Makefile delegate | **§10.1 audit + §11.1 security S1–S6 before §5** |
| **2** | macOS defaults dedup | After P1 |
| **3** | Docker task, optional runtime secrets | After P1 stable |
| **4** | `host_profiles` + docs (`bootstrap`, `platform-matrix`, `context`) | After P1 + maximize-chezmoi 1.2 |
| **5** | Audit + security passes; `audit-checklist.md`, `security.md`, `docs/README.md` | Baseline before §5; repeat after P1/P4 |

**Rollback:** restore `install.sh`, `packages.yaml`, script guards, Makefile from git.

## Open Questions (resolved / deferred)

| Question | Decision |
|----------|----------|
| mise bootstrap entry | `install.sh` (resolved) |
| chezmoi secrets | chezmoi keeps encryption + BW |
| `packages.yaml` final | extensions + agents.skills |
| Audit / security when | baseline before §5; after P1 and P4 |
| Doc canonical for packages | `mise.toml` after P1 |
| git vs jj | hybrid — `docs/git-to-jj.md` |

See also: **Execution priority**, **Impact scope**, **Documentation organization**, **Dotfiles audit**, **Security review** at top of this document.
[Showing lines 1-300 of 305. Use :301 to continue]