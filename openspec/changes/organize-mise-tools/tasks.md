## 1. Baseline and classification

- [ ] 1.1 Snapshot normalized active declarations from `home/private_dot_config/mise/conf.d/tools.toml` with the documented `awk | sort` command and verify the baseline file is created.
- [ ] 1.2 Map every active declaration and intentionally commented candidate to exactly one of the ten purpose sections, using primary user-facing purpose and section 10 as the fallback; verify no row is unclassified or duplicated.

## 2. Reorganize the Mise inventory

- [ ] 2.1 Insert the exact inventory legend immediately below `[tools]` and arrange the existing rows under the ten numbered purpose-first headings in the specified order; verify the file still contains exactly one `[tools]` table.
- [ ] 2.2 Preserve every declaration key, backend prefix, version, inline note, and active/commented state while moving rows; verify the full diff contains only the legend, section/comment changes, and row movement.
- [ ] 2.3 Remove language-only separators that are false after the move while retaining comments that document backend behavior or installation exceptions; verify commented candidates remain commented beside their assigned section.

## 3. Validate the preserved loading contract

- [ ] 3.1 Generate the normalized post-edit declaration snapshot and run `cmp /tmp/mise-tools.before /tmp/mise-tools.after`; verify it exits successfully with no output.
- [ ] 3.2 Run `MISE_CONFIG_DIR="$PWD/home/private_dot_config/mise" mise config ls` and `MISE_CONFIG_DIR="$PWD/home/private_dot_config/mise" mise ls`; verify both commands exit successfully without a TOML parse error.
- [ ] 3.3 Run `git diff --check -- home/private_dot_config/mise/conf.d/tools.toml` and inspect the scoped diff; verify there are no whitespace errors and no files outside `tools.toml` are changed by implementation.
