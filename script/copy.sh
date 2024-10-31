#!/bin/sh

# dotfilesリポジトリのパスを設定
DOTFILES="${HOME}/dotfiles"
# DOTFILES="${HOME}/.files"

mkdir -p "${XDG_CONFIG_HOME}/git"
cp -r "${DOTFILES}/.config/git/config" "${XDG_CONFIG_HOME}/git/config"
cp -r "${DOTFILES}/.config/git/ignore" "${XDG_CONFIG_HOME}/git/ignore"
cp -r "${DOTFILES}/.config/git/user.conf" "${XDG_CONFIG_HOME}/git/user.conf"
cp -r "${DOTFILES}/.config/git/commit_template" "${XDG_CONFIG_HOME}/git/commit_template"

cp -r "${DOTFILES}/.config/vim/vimrc" "${XDG_CONFIG_HOME}/vim/vimrc"

cp -r "${DOTFILES}/.config/mise/config.toml" "${XDG_CONFIG_HOME}/mise/config.toml"
cp -r "${DOTFILES}/.config/mise.toml" "${XDG_CONFIG_HOME}/mise.toml"

cp -r "${DOTFILES}/.config/starship.toml" "${XDG_CONFIG_HOME}/starship.toml"
mkdir -p "${XDG_CONFIG_HOME}/sheldon"
cp -r "${DOTFILES}/.config/sheldon/plugins.toml" "${XDG_CONFIG_HOME}/sheldon/plugins.toml"

cp -r "${DOTFILES}/.config/byobu/.tmux.conf" "${XDG_CONFIG_HOME}/byobu/.tmux.conf"

mkdir -p "${XDG_CONFIG_HOME}/fusuma"
cp -r "${DOTFILES}/.config/fusuma/config.yaml" "${XDG_CONFIG_HOME}/fusuma/config.yaml"

mkdir -p "${XDG_CONFIG_HOME}/mpd" "${XDG_CONFIG_HOME}/ncmpcpp"
cp -r "${DOTFILES}/.config/mpd/mpd.conf" "${XDG_CONFIG_HOME}/mpd/mpd.conf"
cp -r "${DOTFILES}/.config/ncmpcpp/config" "${XDG_CONFIG_HOME}/ncmpcpp/config"

mkdir -p "${XDG_CONFIG_HOME}/neofetch"
cp -r "${DOTFILES}/.config/neofetch/config.conf" "${XDG_CONFIG_HOME}/neofetch/config.conf"

mkdir -p "${XDG_CONFIG_HOME}/tabby"
cp -r "${DOTFILES}/.config/tabby/config.yaml" "${HOME}/Library/Application Support/tabby/config.yaml"
cp -r "${DOTFILES}/.config/tabby/config.yaml" "${XDG_CONFIG_HOME}/tabby/config.yaml"

mkdir -p "${XDG_CONFIG_HOME}/VSCodium/User" "${XDG_CONFIG_HOME}/vscode/User"
cp -r "${DOTFILES}/.config/vscode/extensions.json" "${XDG_CONFIG_HOME}/vscode/extensions.json"
cp -r "${DOTFILES}/.config/vscode/settings.json" "${XDG_CONFIG_HOME}/vscode/User/settings.json"

cp -r "${DOTFILES}/.config/vscode/settings.json" "${XDG_CONFIG_HOME}/VSCodium/User/settings.json"
cp -r "${DOTFILES}/.config/vscode/settings.json" "${HOME}/Library/Application Support/Cursor/User/settings.json"

cp -r "${DOTFILES}/shell/.profile" "${HOME}/.profile"
ln -sf "${DOTFILES}/shell/.bashrc" "${HOME}/.bashrc"
cp -r "${DOTFILES}/shell/.bash_profile" "${HOME}/.bash_profile"
cp -r "${DOTFILES}/shell/.zshrc" "${HOME}/.zshrc"
cp -r "${DOTFILES}/shell/.zshenv" "${HOME}/.zshenv"
cp -r "${DOTFILES}/shell/.aliases" "${HOME}/.aliases"

mkdir -p "${XDG_CONFIG_HOME}/wireshark"
cp -r "${DOTFILES}/.config/wireshark/language" "${XDG_CONFIG_HOME}/wireshark/language"

# cp -r "${DOTFILES}/fonts" "${XDG_DATA_HOME}/fonts"
