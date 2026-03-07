---
name: reference
description: ツール・ライブラリの公式ドキュメント・リポジトリ一覧
---

# 参考文献 - Chezmoi Dotfiles

このプロジェクトで使用しているツールの公式ドキュメント・リポジトリです。`~/.config/` に設定を持つツールを中心に掲載。ランタイム・CLI の多くは [mise](https://mise.jdx.dev/) で管理（[config.toml](../home/private_dot_config/mise/config.toml)）。詳細は [技術スタック](tech.md) および [ディレクトリ構成](directory.md) を参照。

---

## コア・インフラ

- [Chezmoi](https://chezmoi.io/) · [twpayne/dotfiles](https://github.com/twpayne/dotfiles)
- [Make](https://www.gnu.org/software/make/manual/make.html) · [Git](https://git-scm.com/)
- [Docker](https://docs.docker.com/) · [Docker Compose](https://docs.docker.com/compose/) · [Podman](https://podman.io/)
- [Kubernetes](https://kubernetes.io/docs/) · [kubectl](https://kubernetes.io/docs/reference/kubectl/) · [kubectx/kubens](https://github.com/ahmetb/kubectx) · [Minikube](https://minikube.sigs.k8s.io/)
- [Multipass](https://multipass.run/) · [Orbstack](https://orbstack.dev/) · [QEMU](https://www.qemu.org/)
- [GitHub Actions](https://docs.github.com/en/actions) · [act](https://github.com/nektos/act)（ローカル実行）
- [Dev Container](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/creating-a-dev-container-configuration) · [ghcr](https://github.com/features/packages)
- [Nix](https://nixos.org/) · [Flatpak](https://flatpak.org/) · [Cloud-init](https://cloud-init.io/) · [Proxmox](https://www.proxmox.com/)
- [Rclone](https://rclone.org/) · [Nextcloud](https://nextcloud.com/)
- [Terraform](https://developer.hashicorp.com/terraform) · [Vagrant](https://developer.hashicorp.com/vagrant/docs) · [Packer](https://developer.hashicorp.com/packer/docs) · [Ansible](https://docs.ansible.com/)
- [Portainer](https://www.portainer.io/) · [Cloud-init-linter](https://github.com/anderssonPeter/cloud-init-linter) · [Rhino Linux](https://github.com/rhinolinux)

## エディタ・IDE

- [Cursor](https://cursor.com) · [VSCode](https://code.visualstudio.com/) · [VSCodium](https://vscodium.com/)
- [Neovim](https://neovim.io/) · [Vim](https://vim.org/) · [Spacemacs](https://www.spacemacs.org/)
- [Xcode](https://developer.apple.com/xcode/) · [Android Studio](https://developer.android.com/studio)
- [Ghostty](https://ghostty.org/) · [Zed](https://zed.dev/) · [Tabby](https://tabby.sh/) · [Alacritty](https://alacritty.org/)
- [Claude](https://claude.ai/)（Anthropic）· [Crossnote](https://github.com/0xGG/crossnote) · [Codex](https://github.com/github/codex)（AI CLI）

## AI・LLM・MCP

- [OpenAI Platform](https://platform.openai.com/docs) · [Anthropic Claude](https://docs.anthropic.com/) · [Open Router](https://openrouter.ai/docs)
- [Vercel AI SDK](https://sdk.vercel.ai/) · [LangGraph](https://github.com/langchain-ai/langgraph) · [Trigger Dev](https://trigger.dev/docs)
- [Model Context Protocol](https://modelcontextprotocol.io/) · [n8n](https://docs.n8n.io/) · [Pipedream](https://pipedream.com/docs/)
- [Context7](https://github.com/upstash/context7) · [CodeRabbit](https://docs.coderabbit.ai/)

## シェル・ターミナル

- [Zsh](https://zsh.org/) · [Fish](https://fishshell.com/) · [Bash](https://www.gnu.org/software/bash/)
- [Starship](https://starship.rs/) · [Sheldon](https://sheldon.cli.rs/) · [Fisher](https://github.com/jorgebucaran/fisher)
- [Byobu](https://byobu.co/) · [Tmux](https://github.com/tmux/tmux) · [Zellij](https://zellij.dev/)

## パッケージ・ランタイム

- [Homebrew](https://brew.sh/) · [Mise](https://mise.jdx.dev/) · [Aqua](https://aquaproj.github.io/)
- [UV](https://docs.astral.sh/uv/) · [Cargo](https://cargo.rust-lang.org/) · [Bun](https://bun.sh/) · [Go](https://go.dev/)
- [npm](https://www.npmjs.com/) · [pnpm](https://pnpm.io/) · [PM2](https://pm2.keymetrics.io/)
- [pipx](https://pipx.px.dev/) · [Poetry](https://python-poetry.org/) · [Jupyter](https://jupyter.org/)
- [Java](https://openjdk.org/) · [Maven](https://maven.apache.org/)
- [PostgreSQL](https://www.postgresql.org/) · [Redis](https://redis.io/)
- [asdf](https://asdf-vm.com/) · [direnv](https://direnv.net/)

## Mise 管理ツール（抜粋）

`~/.config/mise/config.toml` で管理。公式ドキュメント・GitHub へのリンク。

- **ランタイム**: [Deno](https://deno.land/) · [Bun](https://bun.sh/) · [Node](https://nodejs.org/) · [pnpm](https://pnpm.io/) · [Python](https://www.python.org/) · [UV](https://docs.astral.sh/uv/) · [Go](https://go.dev/) · [Rust](https://www.rust-lang.org/) · [Java](https://openjdk.org/) · [Maven](https://maven.apache.org/)
- **CLI・開発**: [act](https://github.com/nektos/act) · [ghq](https://github.com/x-motemen/ghq) · [gh](https://cli.github.com/) · [devcontainer-cli](https://github.com/devcontainers/cli) · [Task](https://taskfile.dev/) · [lazygit](https://github.com/jesseduffield/lazygit) · [lazydocker](https://github.com/jesseduffield/lazydocker)
- **検索・表示**: [ripgrep](https://github.com/BurntSushi/ripgrep) · [fd](https://github.com/sharkdp/fd) · [bat](https://github.com/sharkdp/bat) · [lsd](https://github.com/lsd-rs/lsd) · [dua](https://github.com/Byron/dua-cli) · [xh](https://github.com/ducaale/xh) · [fx](https://github.com/antonmedv/fx)
- **フォーマット・Lint**: [Prettier](https://prettier.io/) · [Ruff](https://docs.astral.sh/ruff/) · [shellcheck](https://www.shellcheck.net/) · [hadolint](https://github.com/hadolint/hadolint) · [yamlfmt](https://github.com/google/yamlfmt) · [checkmake](https://github.com/mrtazz/checkmake)
- **セキュリティ・シークレット**: [Age](https://age-encryption.org/) · [Bitwarden CLI](https://github.com/bitwarden/cli) · [mkcert](https://github.com/FiloSottile/mkcert) · [Trivy](https://github.com/aquasecurity/trivy) · [Doppler](https://docs.doppler.com/) · [dotenvx](https://github.com/dotenvx/dotenvx)
- **クラウド・インフラ**: [Wrangler](https://developers.cloudflare.com/workers/wrangler/) · [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) · [Caddy](https://caddyserver.com/) · [cfssl](https://github.com/cloudflare/cfssl) · [gcloud](https://cloud.google.com/sdk) · [rclone](https://rclone.org/) · [infracost](https://www.infracost.io/)
- **AI・API**: [Claude CLI](https://docs.anthropic.com/) · [Stripe CLI](https://stripe.com/docs/stripe-cli) · [Sentry CLI](https://docs.sentry.io/) · [OpenCode](https://github.com/sst/opencode)
- **DB・データ**: [DuckDB](https://duckdb.org/) · [SQLite](https://www.sqlite.org/) · [Redis](https://redis.io/) · [yq](https://github.com/mikefarah/yq) · [jq](https://github.com/jqlang/jq)
- **その他**: [Jujutsu (jj)](https://github.com/martinvonz/jj) · [Zellij](https://zellij.dev/) · [zoxide](https://github.com/ajeetdsouza/zoxide) · [glow](https://github.com/charmbracelet/glow) · [atuin](https://github.com/atuinsh/atuin) · [lychee](https://lychee.cli.rs/) · [hurl](https://hurl.dev/) · [cheat](https://github.com/cheat/cheat) · [Conan](https://conan.io/) · [Ninja](https://ninja-build.org/) · [pre-commit](https://pre-commit.com/) · [Solidity](https://docs.soliditylang.org/) · [CocoaPods](https://cocoapods.org/)

## セキュリティ

- [Age](https://age-encryption.org/) · [Bitwarden](https://bitwarden.com) · [Vaultwarden](https://github.com/dani-garcia/vaultwarden)
- [SSH](https://www.openssh.com/) · [OpenSSL](https://www.openssl.org/) · [GnuPG](https://gnupg.org/) · [mkcert](https://github.com/FiloSottile/mkcert)
- [Better Auth](https://www.better-auth.com/) · [Sentry](https://docs.sentry.io/) · [Trivy](https://github.com/aquasecurity/trivy)
- [BoringTun](https://github.com/cloudflare/boringtun) · [Cloudflare Warp](https://developers.cloudflare.com/warp-client) · [WireGuard](https://www.wireguard.com/)

## 開発・CLI

- [GitHub CLI](https://cli.github.com/) · [ghq](https://github.com/x-motemen/ghq) · [jq](https://github.com/jqlang/jq) · [fzf](https://github.com/junegunn/fzf) · [zoxide](https://github.com/ajeetdsouza/zoxide)
- [ripgrep](https://github.com/BurntSushi/ripgrep) · [fd-find](https://github.com/sharkdp/fd) · [bat](https://github.com/sharkdp/bat) · [lsd](https://github.com/lsd-rs/lsd)
- [Wrangler](https://developers.cloudflare.com/workers/wrangler/) · [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) · [websocat](https://github.com/vi/websocat)
- [Conan](https://conan.io/)（C/C++ パッケージマネージャ）
- [tldr](https://tldr.sh/) · [navi](https://github.com/denisidoro/navi) · [glow](https://github.com/charmbracelet/glow)
- [thefuck](https://github.com/nvbn/thefuck) · [shellcheck](https://www.shellcheck.net/) · [tree](https://mama.indstate.edu/users/ice/tree/)
- [translate-shell](https://github.com/soimort/translate-shell) · [nmap](https://nmap.org/) · [whois](https://www.gnu.org/software/inetutils/)
- [xdg-ninja](https://github.com/b3nj5m1n/xdg-ninja) · [sd](https://github.com/chmln/sd) · [moreutils](https://joeyh.name/code/moreutils/)
- [multitail](https://www.vanheusden.com/multitail/) · [socat](https://www.dest-unreach.org/socat/)
- [AWS CLI](https://docs.aws.amazon.com/cli/) · [Google Cloud CLI](https://cloud.google.com/sdk/docs/install-sdk) · [pgcli](https://www.pgcli.com/) · [Keploy](https://keploy.io/) · [Hono](https://hono.dev/)
- [DBeaver](https://dbeaver.io/) · [Postman](https://www.postman.com/) · [Insomnia](https://insomnia.rest/)
- [PowerShell](https://docs.microsoft.com/powershell/) · [mac-defaults](https://github.com/kevinSuttle/macOS-Defaults)
- [rj](https://github.com/yusukebe/rj)（JSON クエリ）· [GitHub Desktop](https://desktop.github.com/) · [curl](https://curl.se/)

## フロントエンド・フレームワーク

- [React](https://react.dev/) · [Next.js](https://nextjs.org/docs) · [Astro](https://docs.astro.build/) · [Vite](https://vitejs.dev/)
- [Tailwind CSS](https://tailwindcss.com/) · [DaisyUI](https://daisyui.com/) · [shadcn/ui](https://ui.shadcn.com/)
- [TanStack Query](https://tanstack.com/query) · [tRPC](https://trpc.io/) · [RivetKit](https://rivet.dev/)

## データベース・ORM

- [Drizzle ORM](https://orm.drizzle.team/) · [Prisma](https://www.prisma.io/docs) · [Supabase](https://supabase.com/docs)
- [SQLite](https://www.sqlite.org/docs.html) · [MongoDB](https://www.mongodb.com/docs/) · [Upstash](https://upstash.com/docs)

## テスト・品質

- [Vitest](https://vitest.dev/) · [Playwright](https://playwright.dev/) · [Testing Library](https://testing-library.com/) · [MSW](https://mswjs.io/)

## 音楽・メディア

- [MPD](https://www.musicpd.org/) · [mpc](https://www.musicpd.org/clients/mpc/) · [Ncmpcpp](https://github.com/ncmpcpp/ncmpcpp)
- [ffmpeg](https://ffmpeg.org/) · [yt-dlp](https://github.com/yt-dlp/yt-dlp) · [yt-x](https://github.com/nicholaschiasson/yt-x)
- [Mixxx](https://mixxx.org/) · [MusicBrainz Picard](https://picard.musicbrainz.org/)
- [VLC](https://www.videolan.org/) · [Mp3tag](https://www.mp3tag.de/en/) · [Audacity](https://www.audacityteam.org/) · [audacity-plugins-awesome](https://awesomeaudacityplugins.com/)
- [mp3gain-express](https://mp3gain.sourceforge.net/) · [Mackup](https://github.com/lra/mackup)

## デスクトップ・GUI

- [Brave](https://brave.com/) · [Chrome](https://www.google.com/chrome/) · [Discord](https://discord.com/)
- [Xfce](https://xfce.org/) · [Xfce-look](https://xfce-look.org/) · [xrdp](https://xrdp.org/) · [Remmina](https://remmina.org/)
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/) · [Raycast](https://raycast.com/) · [Rectangle](https://rectangleapp.com/)
- [Clipy](https://clipy-app.com/) · [PopClip](https://pilotmoon.com/popclip/) · [BetterDisplay](https://github.com/waydabber/BetterDisplay)
- [Obsidian](https://obsidian.md/) · [Notion](https://notion.so/) · [TradingView](https://tradingview.com/) · [AionUI](https://aionui.app/)
- [awesome bookmarklets](https://awesomebookmarklets.com/) · [Microsoft Remote Desktop](https://docs.microsoft.com/windows-server/remote/remote-desktop-services/clients/remote-desktop-mac)
- [Wireshark](https://wireshark.org/) · [AppCleaner](https://freemacsoft.net/appcleaner/)
- [Keyclu](https://github.com/nickshanks/keyclu) · [Onyx](https://www.titanium-software.fr/onyx.html)
- [Blender](https://www.blender.org/) · [The Unarchiver](https://theunarchiver.com/) · [Windows App](https://github.com/microsoft/WSA)（WSA）

## モニタリング・ネットワーク

- [Fastfetch](https://github.com/fastfetch-cli/fastfetch) · [Neofetch](https://github.com/dylanaraps/neofetch) · [Sampler](https://github.com/sqshq/sampler)
- [htop](https://htop.dev/) · [Sniffnet](https://github.com/GyulyVGC/sniffnet) · [kmon](https://github.com/orhun/kmon)

## ジョーク・ユーティリティ

- [cmatrix](https://github.com/abishekvashok/cmatrix) · [fortune](https://github.com/shlomif/fortune-mod) · [figlet](https://github.com/cmatsuoka/figlet)
- [cowsay](https://github.com/tnalpgge/rank-amateur-cowsay) · [lolcat](https://github.com/busyloop/lolcat) · [oneko](https://github.com/nicohaku/oneko)

## フォント・テーマ

- [HackGen Nerd Font](https://github.com/yuru7/HackGenNerdFont) · [Roboto Mono Nerd Font JP](https://github.com/yuru7/RobotoMonoNerdFontJP)
- [WhiteSur-GTK-Theme](https://github.com/vinceliuice/WhiteSur-gtk-theme) · [Reggae One](https://fonts.google.com/specimen/Reggae+One)
- [Monokai Pro](https://monokai.pro/) · [Monokai Pro](https://github.com/monokai/monokai-pro) · [Kanagawa](https://github.com/rebelot/kanagawa.nvim)（Neovim/VSCode/Ghostty/Zellij）

## バージョン管理・その他

- [Jujutsu (jj)](https://github.com/martinvonz/jj) · [jjui](https://github.com/nickshanks/jjui)
- [IPFS](https://ipfs.io/) · [Element](https://element.io/)（Matrix）
- [Fcitx5](https://github.com/fcitx/fcitx5) · [Fusuma](https://github.com/iberianpig/fusuma)
- [Meilisearch](https://www.meilisearch.com/) · [Biome](https://biomejs.dev/)
- [EditorConfig](https://editorconfig.org/) · [WSL2](https://docs.microsoft.com/en-us/windows/wsl/) · [Wine](https://www.winehq.org/)
- [XRPL](https://xrpl.org/) · [XRPL.js](https://github.com/XRPLF/xrpl.js) · [Xaman](https://docs.xaman.dev/)
- [Caddy](https://caddyserver.com/) · [nginx](https://nginx.org/) · [Resend](https://resend.com/docs) · [Elysia](https://elysiajs.com/)
- [Mermaid](https://mermaid.js.org/) · [Marp](https://marp.app/) · [MDN](https://developer.mozilla.org/)
- [awesome](https://github.com/sindresorhus/awesome) · [awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins)
- [Raspberry Pi](https://www.raspberrypi.org/)
- [CodeRabbit](https://coderabbit.ai/) · [Vicinae](https://vicinae.com/)

## Mac App Store

- [Plash](https://plash.app/) · [Shazam](https://www.shazam.com/) · [RunCat](https://github.com/Kyome22/RunCat_for_Mac)
- [Speedtest](https://www.speedtest.net/) · [speedtest-cli](https://github.com/sivel/speedtest-cli) · [Hidden Bar](https://github.com/dwarvesf/hidden) · [Hyper Cursor](https://hypercursor.com/)
