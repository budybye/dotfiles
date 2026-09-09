# Makefile for dotfiles management
# Author: budybye

.ONESHELL:
SHELL := bash
.SHELLFLAGS := -ceuo pipefail
.DEFAULT_GOAL := help

# Variables
ARCH := $(shell uname -m)
# Docker は amd64/arm64 を期待。uname は x86_64/aarch64 を返す
DOCKER_ARCH := $(if $(filter x86_64,$(ARCH)),amd64,$(if $(filter aarch64 arm64,$(ARCH)),arm64,$(ARCH)))
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
# 真のバージョンは git の semver タグ（CI の tag.yaml と一致）
DOTFILES_VERSION := $(shell git describe --tags --match '[0-9]*.[0-9]*.[0-9]*' --abbrev=0 2>/dev/null || echo dev)

# Docker settings
DOCKER_IMAGE := ubuntu-dev
DOCKER_SLIM_IMAGE := ubuntu-dev-slim
DOCKER_CONTAINER := ubuntu-dev
DOCKER_HOST := docker
DOCKER_PORTS := -p 127.0.0.1:33389:3389
DOCKER_WORKDIR := /home/dev
DOCKER_USER := dev

# Multipass settings
MP_VM := ubuntu
MP_CPUS := 4
MP_MEMORY := 8G
MP_DISK := 42G
MP_TIMEOUT := 43210

.PHONY: help version init update apply check test completion doctor verify
.PHONY: docker-build docker-slim-build docker-run up down exec logs
.PHONY: vm-create vm-info vm-stop vm-start ssh
.PHONY: git-commit git-status age-keygen
.PHONY: clean-docker clean-vm clean list-vms list-containers system-info

##@ General

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  %-20s %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) }' $(MAKEFILE_LIST)

version: ## Show version information
	@echo "dotfiles version: $(DOTFILES_VERSION)"
	@echo "OS: $(OS)"
	@echo "Architecture: $(ARCH)"

##@ Setup & Installation

init: ## Initialize dotfiles with chezmoi
	@echo "Initializing dotfiles..."
	./install.sh
	@echo "✓ Dotfiles initialized successfully"

update: ## Update dotfiles from remote repository
	@echo "Updating dotfiles..."
	chezmoi update
	@echo "✓ Dotfiles updated successfully"

apply: ## Apply dotfiles changes
	@echo "Applying dotfiles changes..."
	chezmoi apply
	@echo "✓ Changes applied successfully"

##@ Development

check: ## Check dotfiles configuration
	@echo "Checking dotfiles configuration..."
	chezmoi diff
	@echo "✓ Configuration check completed"

test: ## Run tests (template syntax, dry-run)
	@echo "Verifying template syntax..."
	@chezmoi execute-template '{{ .chezmoi.sourceDir }}' >/dev/null && echo "  sourceDir: OK" || true
	@echo "Dry-run apply..."
	@chezmoi apply --dry-run 2>/dev/null && echo "  dry-run: OK" || echo "  dry-run: skipped (age passphrase may be required)"
	@echo "✓ Tests completed"

completion: ## Generate chezmoi shell completion (zsh)
	@chezmoi completion zsh

doctor: ## Run chezmoi doctor (health check)
	@echo "Running chezmoi doctor..."
	chezmoi doctor
	@echo "✓ Doctor completed"

verify: ## Verify chezmoi scripts
	@echo "Verifying chezmoi scripts..."
	@chezmoi verify 2>/dev/null && echo "  verify: OK" || echo "  verify: skipped (age passphrase may be required)"
	@echo "✓ Verify completed"

##@ Docker

docker-build: ## Build Docker image
	@test -n "$${GITHUB_TOKEN:-}" || { echo "GITHUB_TOKEN is required for Docker builds." >&2; exit 1; }
	@echo "Building Docker image: $(DOCKER_IMAGE)..."
	cd .devcontainer && DOCKER_BUILDKIT=1 docker build --secret id=github_token,env=GITHUB_TOKEN -t $(DOCKER_IMAGE) .
	@echo "✓ Docker image built successfully"

docker-slim-build: ## Build Slim CLI Docker image
	@test -n "$${GITHUB_TOKEN:-}" || { echo "GITHUB_TOKEN is required for Docker builds." >&2; exit 1; }
	@echo "Building Slim Docker image: $(DOCKER_SLIM_IMAGE)..."
	cd .devcontainer && DOCKER_BUILDKIT=1 docker build --secret id=github_token,env=GITHUB_TOKEN -f slim.Dockerfile -t $(DOCKER_SLIM_IMAGE) .
	@echo "✓ Slim Docker image built successfully"

docker-run: docker-build ## Build and run Docker container
	@echo "Running Docker container: $(DOCKER_CONTAINER)..."
	docker run \
		--rm \
		--interactive \
		--detach \
		--tty \
		--privileged \
		--name $(DOCKER_CONTAINER) \
		--hostname $(DOCKER_HOST) \
		--user $(DOCKER_USER) \
		--workdir $(DOCKER_WORKDIR) \
		--env DOCKER=true \
		--platform linux/$(DOCKER_ARCH) \
		$(DOCKER_PORTS) \
		$(DOCKER_IMAGE)
	@echo "✓ Docker container started"

up: ## Start Docker Compose services
	@echo "Starting Docker Compose services..."
	cd .devcontainer && docker compose up -d --build
	@echo "✓ Services started"

.PHONY: down
down: ## Stop Docker Compose services
	@echo "Stopping Docker Compose services..."
	cd .devcontainer && docker compose down
	@echo "✓ Services stopped"

exec: ## Execute bash in Docker container
	@echo "Executing bash in $(DOCKER_CONTAINER)..."
	docker exec -it $(DOCKER_CONTAINER) /bin/bash

logs: ## Show Docker container logs
	@echo "Showing logs for $(DOCKER_CONTAINER)..."
	docker logs -f $(DOCKER_CONTAINER)

##@ Virtual Machine (Multipass)

vm-create: ## Create Multipass VM
	@echo "Creating Multipass VM: $(MP_VM)..."
	multipass launch \
		-n $(MP_VM) \
		-c $(MP_CPUS) \
		-m $(MP_MEMORY) \
		-d $(MP_DISK) \
		--timeout $(MP_TIMEOUT) \
		--cloud-init cloud-init/multipass.yaml
	@echo "✓ VM created successfully"
	@multipass exec $(MP_VM) -- tail -5 /var/log/cloud-init.log

vm-info: ## Show VM information
	@echo "VM Information:"
	multipass info $(MP_VM)

vm-stop: ## Stop Multipass VM
	@echo "Stopping VM: $(MP_VM)..."
	multipass stop $(MP_VM)
	@echo "✓ VM stopped"

vm-start: ## Start Multipass VM
	@echo "Starting VM: $(MP_VM)..."
	multipass start $(MP_VM)
	@echo "✓ VM started"

ssh: ## SSH into Multipass VM
	@echo "Connecting to $(MP_VM) via SSH..."
	ssh $(MP_VM)

##@ Git Operations

git-commit: ## Add, commit, and push changes
	@echo "Committing and pushing changes..."
	git add -A
	git status
	@read -p "Enter commit message: " msg; \
	if [ -z "$$msg" ]; then \
		echo "Aborted: commit message is required"; exit 1; \
	fi; \
	git commit -m "$$msg" && git push origin main
	@echo "✓ Changes pushed successfully"

git-status: ## Show git status
	@echo "Git Status:"
	git status

##@ Security & Encryption

age-keygen: ## Generate local Mise age identity
	@mkdir -p "$(HOME)/.config/mise"
	@chezmoi age-keygen --output="$(HOME)/.config/mise/age.txt"
	@chmod 600 "$(HOME)/.config/mise/age.txt"
	@echo "Age identity written to $(HOME)/.config/mise/age.txt"

##@ Cleanup

clean-docker: ## Clean Docker resources
	@echo "Cleaning Docker resources..."
	docker container prune -f || true
	docker image prune -f || true
	docker volume prune -f || true
	@echo "✓ Docker resources cleaned"

clean-vm: ## Delete Multipass VM
	@echo "Deleting VM: $(MP_VM)..."
	multipass delete $(MP_VM) || true
	multipass purge || true
	@echo "✓ VM deleted"

clean: clean-docker ## Clean all temporary resources
	@echo "Cleaning temporary files..."
	find . -name "*.tmp" -delete || true
	find . -name "*.log" -delete || true
	@echo "✓ Cleanup completed"

##@ Information

list-vms: ## List all Multipass VMs
	@echo "Multipass VMs:"
	multipass list

list-containers: ## List all Docker containers
	@echo "Docker Containers:"
	docker ps -a

system-info: ## Display system information
	@echo "System Information:"
	@echo "OS: $(OS)"
	@echo "Architecture: $(ARCH)"
	@echo "Shell: $(SHELL)"
	@echo "Dotfiles Version: $(DOTFILES_VERSION)"
	@command -v chezmoi >/dev/null && echo "Chezmoi: $$(chezmoi --version)" || echo "Chezmoi: Not installed"
	@command -v docker >/dev/null && echo "Docker: $$(docker --version)" || echo "Docker: Not installed"
	@command -v multipass >/dev/null && echo "Multipass: $$(multipass version)" || echo "Multipass: Not installed"
