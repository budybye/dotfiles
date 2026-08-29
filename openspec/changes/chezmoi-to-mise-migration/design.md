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
| **mise** | Tool versions, OS packages, macOS UI defaults, curl app installers, (future) runtime API keys via `[env]` + age |
| **chezmoi** | Templated dotfiles, encrypted files, Bitwarden unlock, SSH multi-account, VS Code extensions, agent skills, snap/Windows, complex scripts |

**Steady-state `packages.yaml`:** `extensions` + `agents.skills` (+ `snap` / `windows` as sibling keys or split data files until dedicated owners exist).

**New machine (target):** `make init` (= `mise run setup`) → chezmoi apply → `mise bootstrap packages apply` (CLI profile) → `mise bootstrap macos defaults apply` (macOS) → `mise install` → `mise run bootstrap:gui-packages` (GUI hosts only) → chezmoi apply (vscode/skills/ssh).

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

| Concern | Touch during migration | Leave untouched (phase 1–3) |
|---------|------------------------|----------------------------|
| Encrypted dotfiles (`encrypted_*`) | Audit + security review only | Encryption config, `before_age` |
| Bitwarden (`before_bw`) | Audit + security review only | Unlock flow, template branches |
| SSH multi-account | Audit | `run_once_after_ssh.sh.tmpl` behavior |
| VS Code extensions | Slim `packages.yaml` only | `run_onchange_after_vscode.sh.tmpl` |
| zsh / sheldon / ZDOTDIR | Document only | File layout and load order |
| CI (`test.yaml`) | Makefile delegation | Workflow must keep passing `make init` |
| Windows | Document in matrix | Full parity out of scope phase 1 |

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

**Goal:** Verify secret handling, trust boundaries, and script supply-chain risk before and after migration. Not a substitute for professional pentest — focused dotfiles threat model.

### Threat model (this repo)

| Asset | Threat | Current control | Review focus |
|-------|--------|-----------------|--------------|
| age private key | Leak via plaintext dotfile or wrong CI render | `encrypted_*`, `before_age`, env disables in CI/Docker | Template branches after phase 4 refactor |
| Bitwarden session | Token in shell env or logs | `before_bw`, feature flags | Script logging; non-interactive CI |
| SSH private keys | World-readable or wrong host deploy | `encrypted_private_*`, `run_once_after_ssh` | Permissions post-apply |
| `curl \| sh` installers | Supply-chain compromise | `install.sh`, mise.run, app curl tasks | Pin URLs; checksum where available |
| mise `[env]` age (future) | Second key confusion with chezmoi age | Separate `~/.config/mise/age.txt` | Document in `security.md` |
| Privileged scripts | sudo in bootstrap/defaults/docker | Chezmoi `run_once` / mise tasks | Minimize; document in audit |
| Multi-account GitHub SSH | Host alias misconfiguration | `run_once_after_ssh.sh.tmpl` | No cross-account key bleed |
| Devcontainer | Secrets enabled in image build | `DOCKER=true` → age/BW off | Re-verify after Dockerfile changes |
| Third-party externals | Unpinned archive/tag drift | `.chezmoiexternal.toml.tmpl` | Pin + verify task (maximize 4.2) |

### Security review checklist

| # | Check | Method |
|---|-------|--------|
| S1 | No plaintext secrets in git history (recent) | `git log -p` / secret scan on `home/` |
| S2 | `encrypted_*` files decrypt only with intended key | `chezmoi apply --dry-run` on CI profile without key |
| S3 | CI/Actions never sets `age=true` / `bitwarden=true` | `chezmoi data` with `GITHUB_ACTIONS=true` |
| S4 | Docker build does not embed BW token or age key | Inspect Dockerfile ENV and apply logs |
| S5 | Scripts avoid `curl \| sh` except documented bootstrap URLs | Grep `.chezmoiscripts`, `install.sh`, `[tasks]` |
| S6 | File modes: private keys `600`, config dirs not world-writable | `chezmoi verify` + spot check |
| S7 | `.chezmoiignore` excludes secret-derived paths on sandboxes | `chezmoi ignored` diff per profile |
| S8 | mise bootstrap tasks do not log secrets | Review task scripts before merge |
| S9 | Agent skills / npm curl installs — supply chain | Audit `packages.yaml` `agents.skills` |
| S10 | Post phase 4: `features.*` cannot be overridden by host profile typo | Fixture tests |

### Review timing

| Gate | Required reviews |
|------|------------------|
| Before merging §5 (script retire) | S1–S6 baseline |
| After phase 1 | S5, S8 (new mise tasks) |
| After phase 4 context refactor | S3, S7, S10 |
| Before enabling mise runtime secrets (phase 3) | S2 split + mise age doc |

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
- Migrating **encrypted dotfile lifecycle** (`encrypted_*`, `key.txt.age`, `chezmoi edit --encrypt`) or **Bitwarden unlock** (`before_bw`) to Mise in phase 1. Runtime API keys via mise `[env]` + age are a phase 3+ option only.
- Snap package management until Mise gains a supported manager or a package plugin exists.
- Windows package migration beyond documenting current Chezmoi PS1 script ownership.

## Decisions

### Phase model (incremental, not big-bang)

| Phase | Moves to Mise | Stays in Chezmoi |
|-------|---------------|------------------|
| **1 — Install parity** | `[bootstrap.packages]` authoritative; curl installers → `[tasks]`; disable overlapping `run_onchange_after_{bootstrap,cli,gui}.sh.tmpl` after parity | SSH (`run_once_after_ssh.sh.tmpl`), VS Code (`run_onchange_after_vscode.sh.tmpl`), skills, snap, Linux `run_once_after_setup.sh`, Windows PS1, externals |
| **2 — macOS defaults dedup** | Retire `run_onchange_after_defaults.sh` after gap analysis vs `[bootstrap.macos.*]` | Privileged `systemsetup`/`scutil` steps until expressed as Mise tasks |
| **3 — Future** | Evaluate `[dotfiles]` for simple static files; `[bootstrap.repos]` for git clones | Templates with `.chezmoi.toml.tmpl` data, encryption, multi-account SSH |

**Rationale:** Phase 1 has the highest duplication and lowest risk. Phases 2–3 touch identity and templating where mistakes are costly.

**Alternative considered:** Migrate everything to Mise dotfiles now. **Rejected** because Chezmoi templates, encryption, and per-host `data` blocks have no Mise equivalent; Mise dotfiles top-level command is also on a deprecation path.

### Single package inventory in `mise.toml`

Keep `packages.yaml` temporarily as a read-only reference during migration, then slim it to only Chezmoi-owned sections (`extensions`, `agents.skills`, snap lists) once parity is verified.

**Alternative considered:** Generate `mise.toml` from `packages.yaml` via template. **Rejected** for phase 1 — adds a third source of truth; direct edit of `mise.toml` matches current partial migration state.

### Bootstrap entrypoint: `install.sh` owns mise (curl fixed)

**Decision:** Install mise via `curl -fsSL https://mise.run | sh` in root `install.sh`, immediately after chezmoi and **before** `chezmoi init --apply`. This is the single canonical mise bootstrap path on macOS and Linux.

**Rationale:**
- Fresh Mac has no Homebrew yet; `darwin/bootstrap` cannot rely on `brew install mise`.
- Today mise is installed in four places (`install.sh` absent, `before_bw`, `linux/cli`, `packages.yaml` curl) — inconsistent.
- `before_age` / `before_bw` need mise on PATH during first apply; installing in `install.sh` satisfies that without duplicating curl logic in every `before_*` script.

**`install.sh` target flow:**

```text
1. curl chezmoi  → ~/.local/bin/chezmoi
2. curl mise.run → ~/.local/bin/mise      # canonical; optional MISE_VERSION= pin
3. export PATH=~/.local/bin:$PATH
4. chezmoi init --apply --source=...
     ├ run_once_before_age  → mise use age (mise already present)
     ├ run_once_before_bw    → mise use node + bw (no mise_install)
     └ run_onchange_*        → package scripts retired/guarded in phase 1
5. mise bootstrap packages apply          # after config.toml symlink exists
6. mise bootstrap macos defaults apply    # macOS only
7. chezmoi apply                          # vscode, skills, ssh once (if needed)
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