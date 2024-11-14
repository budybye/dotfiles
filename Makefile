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

# スクリプト実行関数
define run_script
	@echo "Running $(1) script..." | $(tee_log)
	@sh $(2) | $(tee_log) || { echo "$(1) script failed!" | $(tee_log); exit 1; }
endef

# ターゲットの実行
sense: $(TARGETS)
	@echo "OSに応じたスクリプトの実行が完了しました。" | tee -a $(LOGFILE)

# Gitユーザーの設定
GIT_USER := $(if $(GIT_AUTHOR_NAME),$(GIT_AUTHOR_NAME),-S .)
# chezmoi init
init:
	@echo "Running init script..." | $(tee_log)
	@if [ -f "$(SCRIPT_DIR)/init.sh" ]; then \
		sh $(SCRIPT_DIR)/init.sh | $(tee_log); \
	else \
		echo "init.sh が存在しないため、chezmoi をインストールします。" | $(tee_log); \
		curl -fsLS get.chezmoi.io | sh -s -- init --apply ${GIT_USER} | $(tee_log); \
		$(pwd)/bin/chezmoi data | $(tee_log); \
	fi

# スクリプトディレクトリの設定
SCRIPT_DIR := ${HOME}/.local/bin
# Ubuntu
install:
	$(call run_script,Install,${SCRIPT_DIR}/install.sh)
setup:
	$(call run_script,Setup,${SCRIPT_DIR}/setup.sh)

# MacOS
bootstrap:
	$(call run_script,Bootstrap,${SCRIPT_DIR}/bootstrap.sh)
defaults:
	$(call run_script,Defaults,${SCRIPT_DIR}/defaults.sh)

# 共通
code:
	$(call run_script,Code,${SCRIPT_DIR}/codex.sh)
keygen:
	$(call run_script,Keygen,${SCRIPT_DIR}/keygen.sh)
link:
	$(call run_script,Link,${SCRIPT_DIR}/link.sh)
