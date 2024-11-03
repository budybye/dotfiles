#!/usr/bin/env/ bash -ex

# dotfilesリポジトリのパスを設定
DOTFILES="${HOME}/dotfiles"

mkdir -p "${XDG_CONFIG_HOME}/git"
ln -sf "${DOTFILES}/.config/git/config" "${XDG_CONFIG_HOME}/git/config"
ln -sf "${DOTFILES}/.config/git/ignore" "${XDG_CONFIG_HOME}/git/ignore"
ln -sf "${DOTFILES}/.config/git/user.conf" "${XDG_CONFIG_HOME}/git/user.conf"
ln -sf "${DOTFILES}/.config/git/commit_template" "${XDG_CONFIG_HOME}/git/commit_template"

ln -sf "${DOTFILES}/.config/vim/vimrc" "${XDG_CONFIG_HOME}/vim/vimrc"

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

ln -sf "${DOTFILES}/.profile" "${HOME}/.profile"
ln -sf "${DOTFILES}/.bashrc" "${HOME}/.bashrc"
ln -sf "${DOTFILES}/.bash_profile" "${HOME}/.bash_profile"
ln -sf "${DOTFILES}/.zshrc" "${HOME}/.zshrc"
ln -sf "${DOTFILES}/.zshenv" "${HOME}/.zshenv"
ln -sf "${DOTFILES}/.aliases" "${HOME}/.aliases"

mkdir -p "${XDG_CONFIG_HOME}/wireshark"
ln -sf "${DOTFILES}/.config/wireshark/language" "${XDG_CONFIG_HOME}/wireshark/language"

# ln -sf "${DOTFILES}/fonts" "${XDG_DATA_HOME}/fonts"
