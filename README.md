<link href="./style.css" rel="stylesheet"></link>

# dotfiles
v.0.1.1

## chezmoi

```
chezmoi init --apply budybye

chezmoi cd # cd ~/.local/share/chezmoi

chezmoi apply < option Filename >

chezmoi add --follow < Filename >

chezmoi chattr < Filename >
```

## mise
```
mise use <tool@version>

mise ls

mise trust
```
```
./.mise.toml
~/.config/mise.toml
~/.config/mise/config.toml
```

## shell
```
~/.zshrc

~/.zshenv

~/.profile

~/.bashrc

~/.bash_profile
```

## aliases
```
### zsh && bash
~/.aliases
```

## starship
```
~/.config/starship.toml
```

## sheldon
```
~/.config/sheldon/plugins.toml
```
## aqua
```
~/.config/aquaproj-aqua/aqua.yaml
```
## byobu
```
~/.config/byobu/.tmux.conf
```
## VSCodium
```
~/.config/vscode/user-date/User/setting.json
~/.config/vscode/extntions.json
```
## Git
```
~/.config/git/config
~/.config/git/user.conf
~/.config/git/ignore
~/.config/git/commit.template
```
## tabby
```
~/.config/tabby/config.yaml
```
## statship
```
~/.config/starship.toml
```
## editorconfig
```
~/.config/.editorconfig
```
## vim
```
~/.config/vim/vimrc
```
## fcitx5
```
~/.config/fcitx5/config
```
## fusuma
```
~/.config/fusuma/config.yaml
```
## neofetch
```
~/.config/neofetch/config.conf
```
## Hackgen NF
```
~/.local/share/fonts/Hackgen NF
```

## Brewfile
```
~/.config/Brewfile
```
## Multipass cloud-init
```
multipass launch \
-n ubuntu \
-c 4 \
-m 4G \
-d 40G \
--timeout 3600 \
--mount ${HOME}/.dotfiles:/home/ubuntu/dotfiles \
--cloud-init ${HOME}/multipass.yaml
```

## xrdp docker xfce utubun 
```
docker run --rm --privileged --name xdxu -it 5432:5432
```
