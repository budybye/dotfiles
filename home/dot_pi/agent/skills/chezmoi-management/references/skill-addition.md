# Skill Addition Process

## Adding New Skills (Personal Process)

1. `~/.pi/agent/skills/<name>/` で開発・動作確認
2. `chezmoi add ~/.pi/agent/skills/<name>` で source に反映
   - `+x` 属性のスクリプトは自動で `executable_` prefix が付く
3. `cd ~/.local/share/chezmoi && git status` で追加ファイルを確認
4. `git add dot_pi/agent/skills/<name>/` + commit + `git push origin main`

## Editing Existing Skills

`chezmoi add` でも `chezmoi re-add` でも上書きされる。普段は `re-add` の方が余計な差分が出にくい:

```bash
chezmoi re-add ~/.pi/agent/skills/nix-setup/SKILL.md
```

## APM vs Chezmoi Boundary

`~/.pi/agent/skills/` は **2 系統が混在**:

| 種別                    | 入り方                                   | 管理場所                                           |
| ----------------------- | ---------------------------------------- | -------------------------------------------------- |
| APM-managed (外部 repo) | `apm install --global` が apply 後に取得 | `~/.local/share/chezmoi/dot_apm/apm.yml`           |
| chezmoi-managed (自作)  | `chezmoi add` で source にコピー         | `~/.local/share/chezmoi/dot_pi/agent/skills/<name>/` |

**Current APM-managed items** (`dot_apm/apm.yml` 抜粋):

- `moonbitlang/moonbit-agent-guide/*` (moonbit-agent-guide, moonbit-refactoring, moonbit-c-binding)
- `ast-grep/agent-skill/ast-grep`
- その他の必要なスキル (適宜追加)

**Decision Criteria**:

- 外部公開・他リポジトリから使われる可能性あり → upstream repo に置いて APM 登録
- 自分環境でしか使わない運用メモ・実験中のスキル → chezmoi 管理

Both locations can have directories with the same name, but **APM side will overwrite during install** if there's a name conflict, so be careful.

**Check for name conflicts before adding a new skill to chezmoi**:

```bash
# APM 側に同名がないか確認
grep "<skill-name>" ~/.local/share/chezmoi/dot_apm/apm.yml
# or
chezmoi cd && grep -r "<skill-name>" dot_apm/
```