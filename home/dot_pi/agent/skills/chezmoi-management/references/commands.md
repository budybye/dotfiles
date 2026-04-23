# Chezmoi Commands Reference

## Daily Workflow Commands

### Check Differences
```bash
chezmoi diff                   # source と dest の差分
chezmoi status                 # 大雑把な状態（MM/M /?? など）
```

### Direction Sense in `chezmoi diff`
- `-` 行 = dest (現在の実ファイル) にある内容 — apply で **削除される**
- `+` 行 = target (source.tmpl 展開後の期待状態) にある内容 — apply で **追加される**
- `chezmoi apply` は dest を target に合わせる方向（source → dest）

### Import Changes from dest to source
```bash
chezmoi add ~/.zshrc                    # 新規ファイル追加
chezmoi re-add                          # managed な dest の変更を一括で source に反映
chezmoi re-add ~/.pi/CLAUDE.md          # 個別
```

### Apply Changes from source to dest
```bash
chezmoi diff                            # 先に見る
chezmoi apply                           # 全体
chezmoi apply ~/.pi/CLAUDE.md           # 個別
chezmoi apply --verbose                 # 何をやってるか表示
```

### Edit source files
```bash
chezmoi edit ~/.zshrc                   # source 側を開く (エディタ閉じた後に apply する？は -a フラグ)
chezmoi edit -a ~/.zshrc                # 編集後 apply も実行
chezmoi edit ~/.pi/CLAUDE.md            # pi 設定ファイルを開く
chezmoi cd                              # source dir に cd
```

## Initialization on New Machine

```bash
# chezmoi 本体: brew install chezmoi など

chezmoi init https://github.com/hotmilk/chezmoi-dotfiles.git --apply
# ↑ clone + apply までやる。run_after_apm-install.sh が走って
#   apm install --global --target claude で外部スキルが入る

# pre-commit 有効化（新マシンで一度だけ）
cd $(chezmoi source-path)
prek install
```