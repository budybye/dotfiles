# ubuntu用のスクリプト
INSTALL_SCRIPT := ${HOME}/.local/bin/install.sh
SETUP_SCRIPT := ${HOME}/.local/bin/setup.sh
# macOS用のスクリプト
BOOTSTRAP_SCRIPT := ${HOME}/.local/bin/bootstrap.sh
DEFAULTS_SCRIPT := ${HOME}/.local/bin/defaults.sh
# 共通スクリプト
INIT_SCRIPT := ${HOME}/.local/bin/init.sh
LINK_SCRIPT := ${HOME}/.local/bin/link.sh
KEYGEN_SCRIPT := ${HOME}/.local/bin/keygen.sh
CODE_SCRIPT := ${HOME}/.local/bin/codex.sh

# OSによって設定を変更する make sense で実行
ifeq ($(shell uname), Darwin)
    # macOS用の設定
    CONFIG_DIR := macos
    sense: defaults bootstrap
else
    # Linux用の設定
    CONFIG_DIR := linux
    sense: setup install
endif

# 共用スクリプト実行 make it
it: init codex keygen link

# 環境セットアップスクリプトの実行
setup:
	@echo "Running setup script..."
	sh $(SETUP_SCRIPT)

# アプリケーションインストールスクリプトの実行
install:
	@echo "Running install script..."
	sh $(INSTALL_SCRIPT)

# Homebrewインストールスクリプトの実行
bootstrap:
	@echo "Running bootstrap script..."
	sh $(BOOTSTRAP_SCRIPT)

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

# Dotfilesの初期化スクリプトの実行
init:
	@echo "chezmoi init..."
	if [ -f "$(INIT_SCRIPT)" ]; then \
		sh $(INIT_SCRIPT); \
	else \
		echo "init.sh が存在しないため、chezmoi をインストールします。"; \
		wget -qO- chezmoi.io/get | sh -s -- init --apply budybye; \
	fi


