# シェルの設定 異なる環境でも差をなくすために bash を使用
SHELL := bash
# 一つのシェルセッションで実行して環境変数を引き継げる
.ONESHELL:
# シェルオプションの設定
.SHELLFLAGS := -euo pipefail -c
# エラーハンドリングの設定
.DELETE_ON_ERROR:
# Makeの警告とデフォルトルールの無効化
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Gitユーザーの設定
GIT_USER := $(if $(GIT_AUTHOR_NAME),$(GIT_AUTHOR_NAME),-S .)
# Linux
INSTALL_SCRIPT := ${HOME}/.local/bin/install.sh
SETUP_SCRIPT := ${HOME}/.local/bin/setup.sh
# MacOS
BOOTSTRAP_SCRIPT := ${HOME}/.local/bin/bootstrap.sh
DEFAULTS_SCRIPT := ${HOME}/.local/bin/defaults.sh
# 共通
INIT_SCRIPT := ${HOME}/.local/bin/init.sh
LINK_SCRIPT := ${HOME}/.local/bin/link.sh
KEYGEN_SCRIPT := ${HOME}/.local/bin/keygen.sh
CODE_SCRIPT := ${HOME}/.local/bin/codex.sh

# OSによるターゲットの設定
ifeq ($(shell uname), Darwin)
	CONFIG_DIR := macos
	TARGETS := init bootstrap defaults code keygen link
else
	CONFIG_DIR := linux
	TARGETS := init install setup code keygen link
endif

# ログファイルの設定
LOGFILE := ${HOME}/make.log
# ログファイルへの出力
define tee_log
	tee -a $(LOGFILE)
endef

# 共通のスクリプト実行関数
define run_script
	@echo "### Running $(1) script..." | $(tee_log)
	@sh $(2) | $(tee_log) || { echo "### $(1) script failed!" | $(tee_log); exit 1; }
endef

# ターゲットの実行
sense: $(TARGETS)
	@echo "### OSに応じたスクリプトの実行が完了しました。" | tee -a $(LOGFILE)

# chezmoi init
init:
	@echo "### Running init script..." | $(tee_log)
	@if [ -f "$(INIT_SCRIPT)" ]; then \
		sh $(INIT_SCRIPT) | $(tee_log); \
	else \
		echo "### init.sh が存在しないため、chezmoi をインストールします。" | $(tee_log); \
		curl -fsLS get.chezmoi.io | sh -s -- init --apply --verbose ${GIT_USER} | $(tee_log); \
	fi
# Ubuntu
# cli tools install
install:
	$(call run_script,Install,$(INSTALL_SCRIPT))
# desktop setup
setup:
	$(call run_script,Setup,$(SETUP_SCRIPT))

# MacOS
# cli tools install
bootstrap:
	$(call run_script,Bootstrap,$(BOOTSTRAP_SCRIPT))
# desktop setup
defaults:
	$(call run_script,Defaults,$(DEFAULTS_SCRIPT))

# 共通
# vscode setup
code:
	$(call run_script,Code,$(CODE_SCRIPT))
# ssh keygen
keygen:
	$(call run_script,Keygen,$(KEYGEN_SCRIPT))
# symlink
link:
	$(call run_script,Link,$(LINK_SCRIPT))
