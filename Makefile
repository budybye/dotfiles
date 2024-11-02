# OSによって設定を変更する
ifeq ($(shell uname), Darwin)
    # macOS用の設定
    CONFIG_DIR := macos
else
    # Linux用の設定
    CONFIG_DIR := linux
endif

install:
    @echo "Installing dotfiles from $(CONFIG_DIR) config"
    stow -v -t $(HOME) -d $(CONFIG_DIR) *

all: init link defaults brew install setup

