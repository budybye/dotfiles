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

init:
	@curl -fsLS get.chezmoi.io | sh -s -- -b ${HOME}/.local/bin && \
		chezmoi init --apply -S . | tee ${HOME}/make.log

docker:
	@docker compose up -f .devcontainer/docker-compose.yml -d
