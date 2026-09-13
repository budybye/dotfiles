## Catalog split

**MANDATORY — READ ENTIRE FILE when** the SKILL.md load-table row matches exactly (user asks *why* this catalog split). Read from the top.
**Do NOT Load** for routing, source-of-truth, Bootstrap / ordinary Sync / Add-topic / Verify, DESIGN/ROADMAP structure, split, unless that parent row matches exactly. This file is not a procedure.

This catalog is not Diátaxis (tutorial / how-to / reference / explanation). It splits by who decides the fact, because agents treat any written file as the next session's source.

- **Entry vs intent vs runtime.** README is a human door. Install/commands/flags/deps/samples are runtime quotes of code/CI/manifest (mismatch → Gaps). Goals and architecture belong in `docs/`. If README owns them, agents skip `docs/` and humans stop at the agent prose (mismatch with `docs/` → drift).
- **Same-axis Gaps vs cross-axis drift.** Two CIs disagree → Gaps (write neither). Code says `--dry-run` default false and `docs/` says true → drift (`docs/` quotes runtime). Do not freeze both as two truths.
- **One file, one decision.** Mixing "what ships" with "how it runs" or "how it looks" makes the next edit overwrite the wrong axis. `architecture.md` vs `directory.md` vs `tech.md` is that split (duties/flow vs names vs rejected options).
- **Omit empty catalog rows.** A filename with no owner/source looks like coverage; later sessions treat the stub as truth.
- **Changelogs and OpenSpec stay out.** History is mutable; intent docs are not a log. Change proposals live beside `docs/` until merge so a plan cannot silently replace intent.
