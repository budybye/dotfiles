# ubuntu用のスクリプト
INSTALL_SCRIPT := bin/install.sh
SETUP_SCRIPT := bin/setup.sh
# macOS用のスクリプト
BREW_SCRIPT := bin/bootstrap.sh
DEFAULTS_SCRIPT := bin/defaults.sh
# 共通スクリプト
LINK_SCRIPT := bin/link.sh
KEYGEN_SCRIPT := bin/keygen.sh
CODE_SCRIPT := bin/codex.sh

# OSによって設定を変更する make sense で実行
ifeq ($(shell uname), Darwin)
    # macOS用の設定
    CONFIG_DIR := macos
    sense: defaults brew
else
    # Linux用の設定
    CONFIG_DIR := linux
    sense: setup install
endif

# 共用スクリプト実行 make it
it: codex keygen link init

# 環境セットアップスクリプトの実行
setup:
	@echo "Running setup script..."
	sh $(SETUP_SCRIPT)

# アプリケーションインストールスクリプトの実行
install:
	@echo "Running install script..."
	sh $(INSTALL_SCRIPT)

# Homebrewインストールスクリプトの実行
brew:
	@echo "Running brew script..."
	sh $(BREW_SCRIPT)

# デフォルト設定スクリプトの実行
defaults:
	@echo "Running defaults script..."
	sh $(DEFAULTS_SCRIPT)

# SSH鍵生成スクリプトの実行
keygen:
	@echo "Running keygen script..."
	sh $(KEYGEN_SCRIPT)

# VSCode拡張機能インストールスクリプトの実行
code:
	@echo "Running code script..."
	sh $(CODE_SCRIPT)

# シンボリックリンク作成スクリプトの実行
link:
	@echo "Running link script..."
	sh $(LINK_SCRIPT)

init:
	@echo "chezmoi init..."
	sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply -S .
