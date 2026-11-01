---
name: roadmap
description: プロジェクトの目標・進捗・バージョン計画
---

# Roadmap - Chezmoi Dotfiles

## GOAL

**最上位ゴール**: いつ・どの環境でも、自分用に最適化された設定を使える状態を半永続的に維持する (動的)。

完了条件を持たない上位目標であり、優先順位表の外に置く。短期〜長期の全マイルストーン (M5-M7、継続監査 M4) はこのゴールへの手段であり、環境が増える・変わるたびに本ファイルの目標に分解して維持する。

このファイルは、プロジェクトの中長期目標、到達点、進行中の作業、リリース方針を管理します。

README.md と docs/ が運用・設計の正本です。

実装手順と完了条件は本ファイルのマイルストーンに直接記録します。

## 現在地

- Chezmoi がテンプレート、設定、暗号化ファイル、OS・host 分岐を管理する
- Mise がツール、Linux (apt) の package bootstrap、macOS defaults の正本へ移行中。macOS の Homebrew (formula / cask / tap / mas) は Brewfile が単独の正本で、darwin の bootstrap script が `brew bundle --no-upgrade --file ~/.config/Brewfile` で適用する
- Makefile は既存利用者と CI の互換入口として維持する
- GitHub Actions は複数 OS で `make init` を実行し、Docker image を build し、LXD で cloud-init を起動する (`powershell` / `windows-11-arm64` / `wsl2` は package 導入または checkout のみ。`lxd` / `rpi` は cloud-init の終了コードを無視する)
- SemVer git tag がリリースバージョンの単一ソースである
- dayjobdoor/dotfiles (Ubuntu 26.04 専用・mise 管理) との比較で取り込み項目を洗い出した (2026-10-31、M8)。事実は 2026-11-01 に本 working copy で再確認した

## 目標の優先順位

実施順は 短期 → 中期 → 長期。番号は各期間内の優先順位。

| 期間 | 順 | 目標 | 依存・補足 |
|---|---|---|---|
| 完了 | - | M1 ドキュメントと正本の整理 | 残タスクは短期6へ移行 |
| 短期 | 1 | Ubuntu 26.04 環境の安定化 | CI / VM / LXD の土台 |
| 短期 | 2 | Ubuntu profile 境界の整理 | 1 と並行可 |
| 短期 | 3 | cloud-init 最適化 | 1 と並行可 |
| 短期 | 4 | Obsidian vault の git 管理 | 独立 |
| 短期 | 5 | クロスプラットフォーム設計の前提整理 | 長期 M5 の入力 |
| 短期 | 6 | ドキュメント参照リンクの自動チェック | M1 残タスク。実装は M8-5 |
| 短期 | 7 | 公開 repo の secret 露出の是正 | M8-1。他に依存しない。最優先 |
| 短期 | 8 | hostname → profile 対応表と GUI の desktop 限定 | 短期 2 の入力。M8-6 の `MISE_ENV` 分割はこの対応表を使う |
| 短期 | 9 | GitHub 既定アカウントの `budybye` 統一 | 独立。gh `hosts.yml` の `user:` が `boborder` のまま |
| 中期 | 1 | M2 Mise / Chezmoi 移行 | 進行中 |
| 中期 | 2 | M3 Chezmoi 機能の標準化 | M2 完了後 |
| 中期 | 3 | M4 品質・セキュリティ監査 | 継続 / M3 と並行可 |
| 中期 | 4 | M6 Mise 最適化と軽量化 | M2 完了後 |
| 中期 | 5 | M7 Kali Linux 対応 (Docker / VM RDP) | M6 と並行可。短期 1 / 2 が前提 |
| 中期 | 6 | M8 dayjobdoor/dotfiles との比較に基づく取り込み | M8-1 は短期 7。他は M3 / M4 / M6 と並行可 |
| 長期 | 1 | M5 Windows / WSL と汎用化 | 短期5 の設計を踏襲 |

## 短期目標

- [ ] Ubuntu 26.04 の hosted runner / VM / LXD 環境を安定化し、`make init`、Chezmoi apply、Mise bootstrap の再現性を確認する
- [ ] Ubuntu slim / minimal profile の責務を整理し、CLI-only image と GUI profile の package・service 境界を明確化する
- [ ] hostname → profile (`desktop` / `minimal` / `darwin`) の対応表を `.chezmoidata` に置き、`linux.gui` package と Linux GUI script を desktop のみに限定する。`101` は本 Mac、未登録 hostname は fail-closed (または minimal)。Ubuntu の hostname 行は運用者が埋めるまで空欄。CI と Docker Full image は GUI まで検証するため desktop として扱う (意図的)
- [ ] GitHub 既定アカウントを `budybye` にし (source 管理の gh `hosts.yml` の `user:` を含む)、`boborder` は `gh auth switch` で切り替える。既定にするのは `budybye` だけで、`boborder` / `dayjobdoor` は下記の org 別 identity としてだけ repo に載せる。既定アカウントの決定に path-based `includeIf` は使わない。symlink mode のため `gh auth switch` は source の `hosts.yml` を直接書き換える (現在の値は `user: boborder`)。済: git / jj の既定 identity は budybye (`user.conf.tmpl`、`.chezmoi.toml.tmpl`)、`~/Developer/{dayjobdoor,boborder}` 配下だけは git の `includeIf "gitdir:"` と jj の `[[--scope]]`、ssh Host (`github-dayjobdoor` / `github-boborder`) で org 別 identity に固定している
- [ ] cloud-init の共通処理、待機条件、ログ出力、冪等性を最適化し、Ubuntu / LXD / ARM64 の初期化時間と失敗率を下げる
- [ ] Obsidian vault を git 管理に組み込み、chezmoi / dotfiles リポジトリとの同期境界と運用方針を定義する
- [ ] macOS / Ubuntu / Windows / WSL / Docker を通したクロスプラットフォーム設計の前提と profile 境界を整理する
- [ ] 参照リンクと実ファイル構成の定期チェックを自動化(M1 残タスク。実装は M8-5)
- [ ] 公開 repo に残る平文 passwd と GitHub PAT、secret scan の不在を是正する (M8-1。秘密鍵の暗号文は passphrase を防壁として公開 repo に置き続ける)

## 中期目標

### M1: ドキュメントと正本の整理(完了)

- [x] README にドキュメント索引と正本パスを統合
- [x] 設計書を `docs/architecture.md` に統一
- [x] `docs/test.md` を追加（現 `docs/testing.md`）
- [x] `docs/tasks.md` の運用を `ROADMAP.md` に移行
- [x] Superpowers の2つの計画を README、docs、ROADMAP に統合

### M2: Mise / Chezmoi 移行

- [ ] Linux (apt) の package bootstrap の正本を Mise に集約 (macOS の Homebrew は Brewfile が単独の正本。`mise.toml` の `[bootstrap]` は macOS defaults と `apt:` のみ。済)
  - [ ] `install.sh` が `chezmoi init --apply` の前に Mise を導入する唯一の入口になる (他 script の Mise install、`packages.yaml` の mise curl 行は削除)
  - [ ] `packages.yaml` と `mise.toml` `[bootstrap.packages]` の apt entry の package parity 表を作り (Homebrew は Brewfile のみで parity の対象外)、必要 package が正本ちょうど1行に存在することを確認する
  - [ ] Linux bootstrap を CLI と GUI (xfce4, xrdp, pipewire 等) に分離し、CLI-only (slim image / minimal profile) には desktop stack を入れない。CI と Docker Full image は GUI まで検証するので `gui.sh` を実行する (意図的。Full image は Dockerfile が xfce4 / xrdp を先に入れ、`gui.sh` の追加 package は `light-locker` / `xscreensaver` を要求しないので RDP に影響しない)
  - [ ] zed の curl installer を冪等な Mise task へ移し、`packages.yaml` の未使用の `curl:` を削除する（coderabbit は `http:coderabbit`、cursor は `http:cursor-cli` として `tools.toml` へ移行済み）
  - [ ] Docker CE apt repo 導入を Mise task 化する（`act` は `tools.toml` で導入済みで、curl 経路は存在しない）
- [ ] 重複する Chezmoi install script を段階的に縮退
  - [ ] 縮退は parity 表と CLI/GUI 分離の完了後、baseline 監査 (M4) と security review の後に行う (darwin bootstrap / linux cli・gui script は早期 exit guard から)
  - [ ] テンプレートが参照しなくなったので `packages.yaml` は Windows の winget / scoop のみ有効 (`extensions` / `agents.skills` は `extensions.yaml` / `agents.yaml` に分離済み)。コメントアウトの linux / snap と未使用の `curl:` を整理する。snap は Chezmoi に残す
- [ ] macOS defaults と platform profile の責務を整理 (Mise `[bootstrap.macos.*]` への移行は完了、残りは platform profile)
- [ ] `make` 互換入口を維持したまま Mise task を追加
  - [ ] root `mise.toml` に `setup` / `install` / `apply` / `bootstrap:*` / `post-apply` / docker / vm task を置き、Makefile は Mise へ委譲する薄い wrapper にする (CI の `make init` を維持。現状の root `mise.toml` は `help` task の stub のみで、`.env` を読む `[env] _.file` はコメントアウト中)
- [x] ssh_setup を明示実行のみ・非破壊に保つ (`chezmoi apply` で SSH 鍵を生成・置換しない。新規生成は `ssh_setup --generate`。`.chezmoiscripts` からは呼ばれず、既存の鍵は上書きしない)
- [x] age 暗号化した `~/.ssh/id_ed25519_dayjobdoor` を source に加えた (`home/private_dot_ssh/encrypted_private_id_ed25519_dayjobdoor.age`。公開鍵 `id_ed25519_dayjobdoor.pub.tmpl` と `github-dayjobdoor` Host も追加済み)
- [ ] Mise runtime age と Chezmoi passphrase の鍵を分離したまま、Mise `[env]` による runtime secret を有効化する (有効化前に security.md へ鍵の分離を記録)

### M3: Chezmoi 機能の標準化

- [ ] template、`.chezmoiignore`、`.chezmoidata` の利用規則を統一
  - [ ] OS / distro / host / CI / container / sandbox の正規化 context と feature boolean を `.chezmoi.toml.tmpl` と `.chezmoidata/` に集約する。OS 判定は `.chezmoi.os` / `.chezmoi.osRelease`、hostname は意図的な差分のみ、username は主判定に使わない
  - [ ] 複数 target で共有する内容は `.chezmoitemplates` に置く
  - [ ] generated / cache / host-local / secret 由来のファイルを `.chezmoiignore` で通常管理から分離する
- [ ] lifecycle script の順序、冪等性、fail-closed 条件を検証
  - [ ] file attribute (`private_` / `executable_` / `once_` / `onchange_` / `before_` / `after_` 等) を `chattr` で監査・正規化する
  - [ ] script は prerequisite を確認し、反復実行しても安全で、実失敗時は非 0 で終了する。1 script group ずつ移行する
- [ ] secrets、external resource、generated file の境界を明文化
  - [ ] age / Bitwarden branch は CI・container・sandbox では無効化し、実ホストで secret 不足なら placeholder を書かずに明示エラーにする
  - [ ] `.chezmoiexternal.toml` は version / exact ref を固定し、refresh 失敗時は既存 resource を保持する
- [ ] macOS、Ubuntu、container の代表環境で apply / rollback を確認 (rollback は source revision の revert → 直前の正常 revision で再 apply。target の削除は diff を確認してから)
- [ ] `chezmoi apply` を 1 回実行し、移動・改名した source (`git/user.conf.tmpl`、omp の `herdr-omp-agent-state.ts`、`.chezmoiscripts` の `.sh.tmpl`) を target に反映する。apply するまで `~/.config/git/user.conf` は削除済みの source を指すため、git の既定 identity が未設定になる (jj は影響なし)。chezmoi は削除した source の target を消さないため、残骸 `~/.config/vim/autoload/plug.vim` と `~/.config/ipfs/config` (秘密鍵を含む) は手で削除する
- [ ] `make check` / `make test` / `make verify` で template・script・attribute・platform の失敗を skip せず可視化する (`chezmoi data` / `diff` / `managed` / `ignored` / `execute-template` / `apply --dry-run` / `verify`)。ネットワーク依存の external 検証は高速な構文・template 検査から分離する (済: `make test` は一時 destination への dry-run apply、`make verify` は `chezmoi verify` で、どちらも失敗を返し encrypted と external を除外する。残り: 他 OS・profile の描画、attribute、`ignored` / `managed` の検査)

### M4: 継続的な品質・セキュリティ監査

- [ ] template、script、attribute、platform branch の CI 検証を強化
- [ ] secrets と supply chain の baseline / post-change review を実施
- [ ] package parity と duplicate authority を定期監査
- [ ] 大規模な script 縮退 (M2) の前に baseline 監査 (inventory・secret posture・script risk) を実施し、縮退後に security review を再実施する
- [ ] CI failure policy と recovery 手順を更新
- [x] mise の `lockfile = true` (`lockfile_platforms = ["macos-arm64"]`、グローバル tool は `mise lock --global`) を有効化
- [x] グローバルの mise `env_file` / `yes` を削除し `activate_aggressive = false` にした。root `mise.toml` の `[env] _.file = '.env'` (repo 内だけで `.env` を読む設定) もコメントアウトしてあり、mise は `.env` を自動では読まない
- [x] claude `settings.json` の `permissions.allow` を read-only・開発ループのコマンドに絞り、`ask` (git push、`chezmoi execute-template`) と `deny` (secret・破壊的操作) を追加
- [x] `home/private_dot_config/ipfs/` を tree から削除した (PrivKey は公開 git 履歴と `ipfs.yaml` の pin に残る。M8-1)

### M6: Mise 最適化と軽量化

- [ ] Mise を tool version、package bootstrap、defaults、task orchestration の正本として整理する
- [ ] Chezmoi lifecycle script と Mise task の重複を削減し、初期化時間と実行回数を減らす
- [ ] CLI-only / GUI / Docker の最小構成を分離し、不要な GUI package と外部依存を入れない
- [ ] CI、Docker、WSL のキャッシュと並列実行を最適化し、再現性を維持したまま実行時間を短縮する
- [ ] package parity、生成物、キャッシュ容量を定期測定し、軽量化の効果を検証する
- [ ] sheldon `plugins.toml` の `[plugins.git-open]` に `apply = ["PATH"]` を設定するか検討する。`activate_aggressive = false` にした結果、defer された git-open が PATH の先頭に残る (中身は `git-open` のみで実害は無い)

### M7: Kali Linux 対応 (Docker / VM RDP)

- [ ] Docker: Kali GUI image を追加し、xrdp + XFCE セッションを Ubuntu Full image と共通化する
- [ ] VM: Kali cloud-init を LXD 経路で追加する (multipass は Ubuntu 専用、OrbStack machine は Ubuntu / Debian 専用のため Kali は LXD のみ。image は `images:kali/current/cloud` — `current` エイリアスは cloud-init 無しの `default` variant を解決するため `cloud-init status --wait` が破綻する)
- [ ] chezmoi template の OS 分岐に kali (`os_release.id`) を追加し、未知環境は fail-closed を維持する
- [ ] CI: test.yaml に Kali LXD ジョブ、Docker build 検証に Kali image を追加する
- [ ] docs (tech.md, requirements.md, testing.md) に Kali の位置づけを記録する

### M8: dayjobdoor/dotfiles との比較に基づく取り込み

比較元は [dayjobdoor/dotfiles](https://github.com/dayjobdoor/dotfiles) (Ubuntu 26.04 専用・mise 管理。本 repo から派生し、起動速度・CI・公開前提の secret 運用を作り直したもの)。chezmoi / mise の選択は変えない。M8-1 以外は M3 / M4 / M6 と重複する項目を、根拠と完了条件つきで具体化したもの。

#### M8-1: 公開 repo の secret 露出 (短期 7)

- [ ] cloud-init の平文 `passwd:` を削除する (`cloud-init/lxd.yaml:14`、`multipass.yaml:16,28`、`template.cfg:16`、`user-data:35`)。`lock_passwd: true` と `ssh_import_id: gh:` に寄せ、RDP 用 password は起動後に `passwd` で設定する。使い回している値は変更する (履歴に残るため、削除だけでは足りない)。公開 GHCR image の既定 `ubuntu:ubuntu` と NOPASSWD sudo は仕様として維持する (この項目の対象外)
- [x] 秘密鍵と `key.txt` の age 暗号文 (`home/private_dot_ssh/encrypted_private_id_{ed25519,ed25519_boborder,ed25519_dayjobdoor,rsa}.age`、`home/key.txt.age`) は公開 repo に置き続ける (現状維持)。防壁は passphrase の強度だけで、後から取り消せない。記録は `docs/security.md` の脅威表。外す場合は各マシンで `ssh_setup --generate` し、公開鍵だけを template で配る
- [ ] `.gitignore` に `age.txt`、`*.pem`、`*.key`、`rclone.conf`、`*.local` を足す (現状は `.env`、`.env.*` (`!.env.example`)、`.devcontainer/.env`、`config.yml.lock`、`tmp` のみ)
- [ ] gitleaks を `.githooks/pre-commit` (staged) と CI (履歴全体) に入れる (現状はどちらも無い)
- [ ] repo ルートの `.env` と `.devcontainer/.env` に平文で残る GitHub PAT を revoke・再発行する。root `mise.toml` の `[env]` は既にコメントアウト済みで、`GITHUB_TOKEN="$(gh auth token)"` に寄せれば `.env` 自体が不要になる
- 完了条件: `git grep -nE '^[[:space:]]*(passwd|plain_text_passwd)[[:space:]]*:' -- cloud-init` が 0 件。`gitleaks git --redact` が通る。PAT を再発行済み

#### M8-2: CI が収束を検証する (M3 / M4)

- 済: `make test` と `make verify` はドリフトで失敗を返す (4f0080e)
- [ ] `.chezmoiscripts` の `|| echo` / `|| true` (41 箇所) を、必須処理は失敗させ、任意処理だけ理由コメントつきで残す (M3 の「実失敗時は非 0」と同じ作業)
- [ ] `test.yaml` の `make init` の後に収束の検査を足す: `chezmoi verify --exclude=encrypted,externals`、`mise bootstrap status --missing`、`mise doctor`。`make doctor` はこれらを含め、失敗で exit 1 にする (現状は `chezmoi doctor` のみ)
- [ ] `lxd` / `rpi` ジョブの `|| true` を外し、`cloud-init status --wait` の終了コードと `systemctl is-active xrdp` を検査する (現状は出力するだけ)
- 完了条件: 必須 package を 1 つ壊した branch で `test.yaml` が赤になる。結果を `docs/testing.md` に記録する

#### M8-3: shell 起動コスト (M6)

- 根拠: `docs/problems.md` によれば AI agent は bash を login shell で起動し、毎回 `.profile` を読む。`.profile` だけを `env -i HOME=<tmp> sh -c '. ~/.profile'` で 5 回測ると、`home/dot_profile` は 0.06〜0.14 秒 (2026-11-01、初回のみ 0.14 秒。毎回の `chmod -R 755 ~/.local/share/mise/installs` を削除して、以前の 0.17〜0.26 秒から短縮した)、djd の `.profile` は 0.06〜0.09 秒 (macOS)。`home/dot_profile` は `command -v` を 68 回、`mkdir -p` を 61 回実行し、毎回 mpd の起動 (477 行) と `mkcert -CAROOT` (276 行) も行う
- [ ] `.profile` を export のみにし、`mkdir` / `touch` / mpd 起動を `.chezmoiscripts` の `run_onchange` へ移す (`chmod -R` は削除済み)
- [ ] `LC_ALL` (86 行) と `TERM` (88 行) の強制をやめる (`LANG` のみ)。mise は `bootstrap` の出力を英語前提で解析する箇所があり、djd は日本語ロケールで ufw の判定が壊れた (mise 2026.10.23)。外せない場合は bootstrap 実行時に `LC_ALL=C.UTF-8` を付ける
- [x] `.zprofile` から `.zshrc` を再読み込みしない (済: 対話 shell では読まず、非対話 login (`zsh -lc`) だけ読む。mux の自動起動は `.zlogin`)
- [ ] `compinit` を 1 回にする。現状は `.zshrc` (60, 62 行)、`sheldon/plugins.toml` (16-17 行)、Ubuntu の `/etc/zsh/zshrc` の最大 3 回。`.zshenv` に `skip_global_compinit=1` を足し、残りのどれか 1 つに絞る
- [ ] `eval "$(tool init)"` を `$XDG_CACHE_HOME/zsh/init/` にキャッシュする。`mise activate` は PATH を、`sheldon source` は plugins.toml の編集を出力に含むので除外する。`chezmoi apply` の後にキャッシュを消す
- 完了条件: `hyperfine 'zsh -i -c exit'` の前後の値を `docs/testing.md` に記録する。`zsh -ic true` が何も出力しない

#### M8-4: supply chain とコンテナ (M4)

- [ ] `sheldon/plugins.toml` の 20 plugin に `rev` を付ける (現状 0 件)。更新手順をファイル先頭に書く
- [ ] Actions の `uses:` 33 件を commit SHA に固定する (現状 0 件)。dependabot (`github-actions`、cooldown 7 日) を足す。`permissions: contents: read` を全 workflow の既定にし (現状は `test.yaml` のみ。`push.yaml` / `ipfs.yaml` は job 単位、`tag.yaml` の job は `contents: write`)、`MISE_GITHUB_TOKEN` は job 全体ではなく必要な step にだけ渡す。checkout に `persist-credentials: false` を付ける
- [ ] `privileged: true` (`.devcontainer/compose.yaml:11`、`devcontainer.json:23`、`Makefile:114,131`) が必要か確認して外す。djd の desktop image は privileged なしで xrdp のログインが通る
- [ ] `make git-commit` (`git add -A` から `push origin main` まで、`Makefile:193-201`) を廃止する (jj 運用と矛盾する)
- [ ] jactionlint と hadolint を lint に入れる
- 完了条件: `git grep -nE 'uses: .*@v[0-9]'` が 0 件。`jactionlint .github/workflows/*.yaml` が通る

#### M8-5: docs の整合 lint (短期 6)

- [ ] djd の `mise-tasks/lint/docs` (bash 94 行、chezmoi 非依存) を移植する。Markdown のリンクとアンカー、コードスパン内のパス、`make` / `mise run` のコマンド名の実在を検査する。`mise.toml` に `lint:docs` を置く
- [ ] 現在の不一致を直す: `mise.toml` の `[tasks.help]` が `echo dotfile` のまま (README の正本表は開発タスクの正本を Makefile としている。M2 の task 追加で解消する)。済: `docs/architecture.md` の Ubuntu 26.04、`.tool-versions` への言及の削除 (`docs/directory.md`、`docs/requirements.md`)
- 完了条件: `mise run lint:docs` が CI で通る。短期 6 を完了にする

#### M8-6: server の堅牢化と profile (短期 2 / M2)

- [ ] `ufw allow 3389` (全開放。`cloud-init/lxd.yaml:62`、`template.cfg:154`、`.chezmoiscripts/linux/run_once_after_setup.sh:50`) を private network (10.0.0.0/8、172.16.0.0/12、192.168.0.0/16、fc00::/7、fe80::/10) に限定し、`mise.toml` の `[bootstrap.linux.firewall]` へ移す
- [ ] sshd を key のみにする drop-in (`/etc/ssh/sshd_config.d/10-*.conf`) と docker の `daemon.json` (published port を 127.0.0.1 に束縛する。docker は ufw を迂回する) を `[bootstrap.files]` で置く。どちらも現在は未設定
- [ ] 短期 2 の hostname → profile 対応表を、profile (workstation / ci / docker) ごとの `MISE_ENV` 設定ファイルに分けて実現する (djd の `config.<module>.toml` が実例)
- 完了条件: Ubuntu VM (LXD) で `ufw status` に 3389 の any 許可が無く、`sshd -T` が `passwordauthentication no` を返す

#### M8-7: xrdp 音声 (M2 の「pipewire 等」の具体化)

- 根拠: Ubuntu 26.04 の apt に `pipewire-module-xrdp` 0.2-2build1 がある (xrdp 0.10.1)。djd はこれと `pulseaudio-utils` (`pactl`) を desktop module に入れ、`~/.xsession` で `pipewire` / `wireplumber` / `pipewire-pulse` を起動する。xfreerdp でログインする `test:desktop` が、`pactl get-default-sink` が `xrdp-sink` を返すまで待つ形で通り、autostart エントリを消した image では `auto_null` で赤になる (arm64 の Docker。systemd の VM 経路は未確認)
- [ ] `.chezmoiscripts/linux/run_once_after_setup.sh` の `pipewire_setup` (73-160 行。deb-src の有効化、`pulseaudio` の削除、pulseaudio-module-xrdp の source build) を、apt の `pipewire-module-xrdp` と `pulseaudio-utils` に置き換える
- [ ] `.devcontainer/entrypoint.sh:52-55` は pipewire を無条件に起動する。`$XDG_RUNTIME_DIR/pipewire-0` が無いときだけ起動し、systemd のある VM では socket activation と二重にしない
- 完了条件: Full image で RDP ログイン後に `pactl get-default-sink` が `xrdp-sink` を返す。Ubuntu VM でも同様

見送り: djd の「Ubuntu 26.04 専用」というスコープ、`symlink-each`、alias の最小化 (本 repo は mac / Windows / WSL を持つ)。

## 長期目標

### M5: Windows / WSL と汎用化

- [ ] Windows native の Chezmoi apply と package bootstrap を安定化する
- [ ] WSL2 を Linux CLI profile として検証し、Windows native との差分を文書化する
- [ ] macOS、Ubuntu、Windows、WSL、Docker で共有できる profile / feature 境界を整理する
- [ ] ユーザー名・ホスト名・OS 固有分岐を減らし、未知の環境でも安全に fail-closed する

## リリース方針

- バージョンの正本は SemVer の git tag
- `tag.yaml` は test 成功後に release と tag を作成する
- `push.yaml` は tag を対象に GHCR image を公開する
- `latest` はリリース済み image の alias として扱う
- main push は test 成功後に `tag.yaml` が tag と release を作り、`push.yaml` を起動して release image を公開する (docs のみの push は test が走らないので公開しない)。`push.yaml` 自体は main push では起動しない

## 更新ルール

1. 目標やマイルストーンを変更したら、このファイルを更新する
2. 実装手順やチェック項目はこのファイルに記録する
3. 完了条件は `docs/testing.md` と対応する workflow / command にリンクする
4. 技術の採用可否は `docs/tech.md` と実設定ファイルを更新してから記録する

## 関連ドキュメント

- [README](README.md)
- [要件定義](docs/requirements.md)
- [アーキテクチャ](docs/architecture.md)
- [検証ガイド](docs/testing.md)
- [技術スタック](docs/tech.md)
- [セキュリティ](docs/security.md)
- [ドキュメント](docs/)
