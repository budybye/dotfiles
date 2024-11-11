#!/usr/bin/env bash
set -ex

# dotfilesリポジトリのパスを設定
DOTFILES="${HOME}/.local/share/chezmoi"
HOME_DOTFILES="${HOME}/dotfiles"

ln -sf "${DOTFILES}" "${HOME_DOTFILES}" || echo "### ${DOTFILES} のシンボリックリンクの作成に失敗しました。"
echo "### link.sh が完了しました。" && ls -la "${HOME_DOTFILES}"

# mkdir -p "${HOME}/.config/git"
# ln -sf "${DOTFILES}/.config/git/config" "${HOME}/.config/git/config"
# ln -sf "${DOTFILES}/.config/git/ignore" "${HOME}/.config}/git/ignore"
# ln -sf "${DOTFILES}/.config/git/user.conf" "${HOME}/.config/git/user.conf"
# ln -sf "${DOTFILES}/.config/git/commit_template" "${HOME}/.config/git/commit_template"

# ln -sf "${DOTFILES}/.config/vim/vimrc" "${HOME}/.config/vim/vimrc"

# ln -sf "${DOTFILES}/.config/mise/config.toml" "${HOME}/.config/mise/config.toml"
# ln -sf "${DOTFILES}/.config/mise.toml" "${HOME}/.config/mise.toml"

# ln -sf "${DOTFILES}/.config/starship.toml" "${HOME}/.config/starship.toml"
# mkdir -p "${HOME}/.config/sheldon"
# ln -sf "${DOTFILES}/.config/sheldon/plugins.toml" "${HOME}/.config/sheldon/plugins.toml"

# mkdir -p "${HOME}/.config/byobu"
# ln -sf "${DOTFILES}/.config/byobu/.tmux.conf" "${HOME}/.config/byobu/.tmux.conf"

# mkdir -p "${HOME}/.config/fusuma"
# ln -sf "${DOTFILES}/.config/fusuma/config.yaml" "${HOME}/.config/fusuma/config.yaml"

# mkdir -p "${HOME}/.config/mpd" "${HOME}/.config/ncmpcpp"
# ln -sf "${DOTFILES}/.config/mpd/mpd.conf" "${HOME}/.config/mpd/mpd.conf"
# ln -sf "${DOTFILES}/.config/ncmpcpp/config" "${HOME}/.config/ncmpcpp/config"

# mkdir -p "${HOME}/.config/neofetch"
# ln -sf "${DOTFILES}/.config/neofetch/config.conf" "${HOME}/.config/neofetch/config.conf"

# mkdir -p "${HOME}/.config/tabby"
# ln -sf "${DOTFILES}/.config/tabby/config.yaml" "${HOME}/.config/tabby/config.yaml"

# mkdir -p "${HOME}/.config/VSCodium/User" "${HOME}/.config/vscode/User" "${HOME}/.local/share/vscode/user-data/User"
# ln -sf "${DOTFILES}/.config/vscode/extensions.json" "${HOME}/.config/vscode/extensions.json"
# ln -sf "${DOTFILES}/.config/vscode/settings.json" "${HOME}/.config/vscode/User/settings.json"
# ln -sf "${DOTFILES}/.config/vscode/settings.json" "${HOME}/.local/share/vscode/user-data/User/settings.json"

# ln -sf "${DOTFILES}/.config/vsocde/extensions.json" "${HOME}/.config/VSCodium/extensions.json"
# ln -sf "${DOTFILES}/.config/vscode/settings.json" "${HOME}/.config/VSCodium/User/settings.json"
# # ln -sf "${DOTFILES}/.config/vscode/settings.json" "${HOME}/Library/Application Support/Cursor/User/settings.json"

# ln -sf "${DOTFILES}/.profile" "${HOME}/.profile"
# ln -sf "${DOTFILES}/.bashrc" "${HOME}/.bashrc"
# ln -sf "${DOTFILES}/.bash_profile" "${HOME}/.bash_profile"
# ln -sf "${DOTFILES}/.zshrc" "${HOME}/.zshrc"
# ln -sf "${DOTFILES}/.zshenv" "${HOME}/.zshenv"
# ln -sf "${DOTFILES}/.aliases" "${HOME}/.aliases"

# mkdir -p "${HOME}/.config/wireshark"
# ln -sf "${DOTFILES}/.config/wireshark/language" "${HOME}/.config/wireshark/language"

# # ln -sf "${DOTFILES}/themes" "${HOME}/.local/share/themes"
# # ln -sf "${DOTFILES}/icons" "${HOME}/.local/share/icons"
# # ln -sf "${DOTFILES}/fonts" "${HOME}/.local/share/fonts"
