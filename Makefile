# シェルの設定 異なる環境でも差をなくすために bash を使用
SHELL := /usr/bin/env bash
# 一つのシェルセッションで実行して環境変数を引き継げる
.ONESHELL:
# シェルオプションの設定
.SHELLFLAGS := -eu -o pipefail -c
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
# ログファイルの設定
LOGFILE := ${HOME}/make.log

# OSによるターゲットの設定
ifeq ($(shell uname), Darwin)
	CONFIG_DIR := macos
	SENSE_TARGETS := init bootstrap defaults code keygen
else
	CONFIG_DIR := linux
	SENSE_TARGETS := init install setup code keygen
endif

# ターゲットの実行
sense: $(SENSE_TARGETS)
	@echo "### OSに応じたスクリプトの実行が完了しました。" | tee -a $(LOGFILE)

# 共通のスクリプト実行関数
define run_script
	@echo "### Running $(1) script..." | tee -a $(LOGFILE)
	@sh $(2) | tee -a $(LOGFILE) || { echo "### $(1) script failed!" | tee -a $(LOGFILE); exit 1; }
endef

# Ubuntu
install:
	$(call run_script,Install,$(INSTALL_SCRIPT))
setup:
	$(call run_script,Setup,$(SETUP_SCRIPT))
# MacOS
bootstrap:
	$(call run_script,Bootstrap,$(BOOTSTRAP_SCRIPT))
defaults:
	$(call run_script,Defaults,$(DEFAULTS_SCRIPT))
# 共通
keygen:
	$(call run_script,Keygen,$(KEYGEN_SCRIPT))
code:
	$(call run_script,Code,$(CODE_SCRIPT))
# 非推奨 chezmoi に変更
link:
	$(call run_script,Link,$(LINK_SCRIPT))
init:
	@echo "### Running init script..." | tee -a $(LOGFILE)
	@if [ -f "$(INIT_SCRIPT)" ]; then \
		sh $(INIT_SCRIPT) | tee -a $(LOGFILE); \
	else \
		echo "### init.sh が存在しないため、chezmoi をインストールします。" | tee -a $(LOGFILE); \
		curl -fsLS chezmoi.io/get | sh -s -- init --apply ${GIT_USER} | tee -a $(LOGFILE); \
	fi
