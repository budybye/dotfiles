#!/bin/sh

# dotfilesリポジトリのパスを設定
DOTFILES="${HOME}/dotfiles"
# DOTFILES="${HOME}/.files"

mkdir -p "${XDG_CONFIG_HOME}/git"
sudo ln -sf "${DOTFILES}/.config/git/config" "${XDG_CONFIG_HOME}/git/config"
sudo ln -sf "${DOTFILES}/.config/git/ignore" "${XDG_CONFIG_HOME}/git/ignore"
sudo ln -sf "${DOTFILES}/.config/git/user.conf" "${XDG_CONFIG_HOME}/git/user.conf"
sudo ln -sf "${DOTFILES}/.config/git/commit_template" "${XDG_CONFIG_HOME}/git/commit_template"

sudo ln -sf "${DOTFILES}/.config/vim/vimrc" "${XDG_CONFIG_HOME}/vim/vimrc"


ln -sf "${DOTFILES}/.config/mise/config.toml" "${XDG_CONFIG_HOME}/mise/config.toml"
ln -sf "${DOTFILES}/.config/mise.toml" "${XDG_CONFIG_HOME}/mise.toml"

ln -sf "${DOTFILES}/.config/starship.toml" "${XDG_CONFIG_HOME}/starship.toml"
mkdir -p "${XDG_CONFIG_HOME}/sheldon"
ln -sf "${DOTFILES}/.config/sheldon/plugins.toml" "${XDG_CONFIG_HOME}/sheldon/plugins.toml"

mkdir -p "${XDG_CONFIG_HOME}/byobu"
ln -sf "${DOTFILES}/.config/byobu/.tmux.conf" "${XDG_CONFIG_HOME}/byobu/.tmux.conf"

mkdir -p "${XDG_CONFIG_HOME}/fusuma"
ln -sf "${DOTFILES}/.config/fusuma/config.yaml" "${XDG_CONFIG_HOME}/fusuma/config.yaml"

mkdir -p "${XDG_CONFIG_HOME}/mpd" "${XDG_CONFIG_HOME}/ncmpcpp"
ln -sf "${DOTFILES}/.config/mpd/mpd.conf" "${XDG_CONFIG_HOME}/mpd/mpd.conf"
ln -sf "${DOTFILES}/.config/ncmpcpp/config" "${XDG_CONFIG_HOME}/ncmpcpp/config"

mkdir -p "${XDG_CONFIG_HOME}/neofetch"
ln -sf "${DOTFILES}/.config/neofetch/config.conf" "${XDG_CONFIG_HOME}/neofetch/config.conf"

mkdir -p "${XDG_CONFIG_HOME}/tabby"
ln -sf "${DOTFILES}/.config/tabby/config.yaml" "${HOME}/Library/Application Support/tabby/config.yaml"
ln -sf "${DOTFILES}/.config/tabby/config.yaml" "${XDG_CONFIG_HOME}/tabby/config.yaml"

mkdir -p "${XDG_CONFIG_HOME}/VSCodium/User" "${XDG_CONFIG_HOME}/vscode/User" "${XDG_DATA_HOME}/vscode/user-data/User"
ln -sf "${DOTFILES}/.config/vscode/extensions.json" "${XDG_CONFIG_HOME}/vscode/extensions.json"
ln -sf "${DOTFILES}/.config/vscode/settings.json" "${XDG_CONFIG_HOME}/vscode/User/settings.json"
ln -sf "${DOTFILES}/.config/vscode/settings.json" "${XDG_DATA_HOME}/vscode/user-data/User/settings.json"

ln -sf "${DOTFILES}/.config/vsocde/extensions.json" "${XDG_CONFIG_HOME}/VSCodium/extensions.json"
ln -sf "${DOTFILES}/.config/vscode/settings.json" "${XDG_CONFIG_HOME}/VSCodium/User/settings.json"
# ln -sf "${DOTFILES}/.config/vscode/settings.json" "${HOME}/Library/Application Support/Cursor/User/settings.json"

ln -sf "${DOTFILES}/shell/.profile" "${HOME}/.profile"
ln -sf "${DOTFILES}/shell/.bashrc" "${HOME}/.bashrc"
ln -sf "${DOTFILES}/shell/.bash_profile" "${HOME}/.bash_profile"
ln -sf "${DOTFILES}/shell/.zshrc" "${HOME}/.zshrc"
ln -sf "${DOTFILES}/shell/.zshenv" "${HOME}/.zshenv"
ln -sf "${DOTFILES}/shell/.aliases" "${HOME}/.aliases"

mkdir -p "${XDG_CONFIG_HOME}/wireshark"
ln -sf "${DOTFILES}/.config/wireshark/language" "${XDG_CONFIG_HOME}/wireshark/language"

# ln -sf "${DOTFILES}/fonts" "${XDG_DATA_HOME}/fonts"
