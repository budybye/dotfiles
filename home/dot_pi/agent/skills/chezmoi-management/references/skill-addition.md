# Skill Management Process

## Adding New Skills

1. Develop and test in `~/.pi/agent/skills/<name>/`
2. Use `chezmoi add ~/.pi/agent/skills/<name>` to add to source
   - Scripts with `+x` attribute automatically get `executable_` prefix
3. Verify additions with `cd ~/.local/share/chezmoi && git status`
4. Commit with `git add dot_pi/agent/skills/<name>/` then commit and push

## Updating Existing Skills

Both `chezmoi add` and `chezmoi re-add` will overwrite. `re-add` typically produces fewer unwanted diffs:

```bash
chezmoi re-add ~/.pi/agent/skills/nix-setup/SKILL.md
```

## APM vs Chezmoi Management

The `~/.pi/agent/skills/` directory contains **two different systems**:

| Type                  | Installation Method                        | Managed Location                                      |
| --------------------- | ------------------------------------------ | ----------------------------------------------------- |
| APM-managed (external)| Installed via `apm install --global`       | `~/.local/share/chezmoi/dot_apm/apm.yml`              |
| Chezmoi-managed (custom)| Copied to source via `chezmoi add`      | `~/.local/share/chezmoi/dot_pi/agent/skills/<name>/`  |

**Currently APM-managed skills** (from `dot_apm/apm.yml`):
- `moonbitlang/moonbit-agent-guide/*` (multiple skills)
- `ast-grep/agent-skill/ast-grep`
- Other required skills (as needed)

**Decision Criteria**:
- May be used externally or by others → Host in separate repository and register with APM
- Personal operational notes or experimental skills → Manage with chezmoi

**Name Conflicts Warning**: Both locations can have directories with identical names, but **APM will overwrite during installation**, so check carefully.

**Check for conflicts before adding skills to chezmoi**:

```bash
# Check if name exists in APM configuration
grep "<skill-name>" ~/.local/share/chezmoi/dot_apm/apm.yml
# or
chezmoi cd && grep -r "<skill-name>" dot_apm/
```