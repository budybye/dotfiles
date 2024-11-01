<!-- <link href="./style.css" rel="stylesheet"></link> -->

# dotfiles

v.0.1.1

## XDG DIR

```:path
XDG_CONFIG_HOME=${HOME}/.config

XDG_DATA_HOME=${HOME}/.local/share

XDG_CACHE_HOME=${HOME}/.cache

XDG_STATE_HOME=${HOME}/.local/state
XDG_DATA_DIRS=/usr/local/share:/usr/share:${HOME}/data
XDG_CONFIG_DIRS=/etc/xdg

...
```

## Environment

```sh
touch ./.env
```

## chezmoi

```sh
chezmoi init --apply budybye

chezmoi cd
# cd ~/.local/share/chezmoi

chezmoi apply < option Filename >

chezmoi add --follow < Filename >

chezmoi chattr < Filename >
```

## mise

```sh
mise use < tool@version >

mise ls

mise trust
```

```:path
./.mise.toml

~/.config/mise.toml

~/.config/mise/config.toml
```

## shell

```:path
~/.zshrc

~/.zshenv

~/.profile

~/.bashrc

~/.bash_profile
```

## aliases

```:path
# zsh && bash
~/.aliases
```

## starship

```:path
~/.config/starship.toml
```

## sheldon

```:path
~/.config/sheldon/plugins.toml
```

## aqua

```:path
~/.config/aquaproj-aqua/aqua.yaml
```

## byobu

```:path
~/.config/byobu/.tmux.conf
```

## VSCodium

```:path
~/.config/vscode/user-date/User/setting.json

~/.config/vscode/extntions.json
```

## Git

```:path
~/.config/git/config

~/.config/git/user.conf

~/.config/git/ignore

~/.config/git/commit.template
```

## tabby

```:path
~/.config/tabby/config.yaml
```

## statship

```:path
~/.config/starship.toml
```

## editorconfig

```:path
~/.config/.editorconfig
```

## vim

```:path
~/.config/vim/vimrc
```

## fcitx5

```:path
~/.config/fcitx5/config
```

## fusuma

```:path
~/.config/fusuma/config.yaml
```

## neofetch

```:path
~/.config/neofetch/config.conf
```

## Hackgen NF

```:path
~/.local/share/fonts/Hackgen NF
```

## Brewfile

```:path
~/.config/Brewfile
```

## Multipass cloud-init

```sh
multipass launch \
-n ubuntu \
-c 4 \
-m 4G \
-d 40G \
--timeout 3600 \
--mount ${HOME}/data:/home/ubuntu/mount \
--cloud-init ${HOME}/multipass.yaml
```

## xrdp docker xfce utubun

```sh
docker run \
--rm \
--privileged \
--name xdxu \
-it \
5432:5432
```
