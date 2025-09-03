# Makefile for dotfiles management
# Author: budybye

.ONESHELL:
SHELL := bash
.SHELLFLAGS := -ceuo pipefail
.DEFAULT_GOAL := help

# Variables
ARCH := $(shell uname -m)
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
DOTFILES_VERSION := 0.8.0

# Docker settings
DOCKER_IMAGE := ubuntu-dev
DOCKER_CONTAINER := ubuntu-dev
DOCKER_HOST := docker
DOCKER_PORTS := -p 33389:3389 -p 2222:22
DOCKER_WORKDIR := /home/dev
DOCKER_USER := dev

# Multipass settings
MP_VM := ubuntu
MP_CPUS := 4
MP_MEMORY := 8G
MP_DISK := 42G
MP_TIMEOUT := 43210

##@ General

.PHONY: help
help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  %-15s %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) }' $(MAKEFILE_LIST)

.PHONY: version
version: ## Show version information
	@echo "dotfiles version: $(DOTFILES_VERSION)"
	@echo "OS: $(OS)"
	@echo "Architecture: $(ARCH)"

##@ Setup & Installation

.PHONY: init
init: ## Initialize dotfiles with chezmoi
	@echo "Initializing dotfiles..."
	./install.sh
	@echo "✓ Dotfiles initialized successfully"

.PHONY: update
update: ## Update dotfiles from remote repository
	@echo "Updating dotfiles..."
	chezmoi update
	@echo "✓ Dotfiles updated successfully"

.PHONY: apply
apply: ## Apply dotfiles changes
	@echo "Applying dotfiles changes..."
	chezmoi apply
	@echo "✓ Changes applied successfully"

##@ Development

.PHONY: check
check: ## Check dotfiles configuration
	@echo "Checking dotfiles configuration..."
	chezmoi diff
	@echo "✓ Configuration check completed"

.PHONY: test
test: ## Run tests (placeholder for future implementation)
	@echo "Running tests..."
	@echo "TODO: Implement test suite"

##@ Docker

.PHONY: docker-build
docker-build: ## Build Docker image
	@echo "Building Docker image: $(DOCKER_IMAGE)..."
	cd .devcontainer && docker build -t $(DOCKER_IMAGE) .
	@echo "✓ Docker image built successfully"

.PHONY: docker-run
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
		--platform linux/$(ARCH) \
		$(DOCKER_PORTS) \
		$(DOCKER_IMAGE)
	@echo "✓ Docker container started"

.PHONY: docker
docker: docker-run ## Alias for docker-run

.PHONY: up
up: ## Start Docker Compose services
	@echo "Starting Docker Compose services..."
	cd .devcontainer && docker compose up -d
	@echo "✓ Services started"

.PHONY: down
down: ## Stop Docker Compose services
	@echo "Stopping Docker Compose services..."
	cd .devcontainer && docker compose down
	@echo "✓ Services stopped"

.PHONY: exec
exec: ## Execute bash in Docker container
	@echo "Executing bash in $(DOCKER_CONTAINER)..."
	docker exec -it $(DOCKER_CONTAINER) /bin/bash

.PHONY: logs
logs: ## Show Docker container logs
	@echo "Showing logs for $(DOCKER_CONTAINER)..."
	docker logs -f $(DOCKER_CONTAINER)

##@ Virtual Machine (Multipass)

.PHONY: vm-create
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

.PHONY: ubuntu
ubuntu: vm-create ## Alias for vm-create

.PHONY: vm-info
vm-info: ## Show VM information
	@echo "VM Information:"
	multipass info $(MP_VM)

.PHONY: vm-stop
vm-stop: ## Stop Multipass VM
	@echo "Stopping VM: $(MP_VM)..."
	multipass stop $(MP_VM)
	@echo "✓ VM stopped"

.PHONY: vm-start
vm-start: ## Start Multipass VM
	@echo "Starting VM: $(MP_VM)..."
	multipass start $(MP_VM)
	@echo "✓ VM started"

.PHONY: ssh
ssh: ## SSH into Multipass VM
	@echo "Connecting to $(MP_VM) via SSH..."
	ssh $(MP_VM)

##@ Git Operations

.PHONY: git-commit
git-commit: ## Add, commit, and push changes
	@echo "Committing and pushing changes..."
	git add -A
	git status
	@read -p "Enter commit message (or press Enter for auto-commit): " msg; \
	if [ -n "$$msg" ]; then \
		git commit -m "$$msg"; \
	else \
		git commit --allow-empty-message -m "Auto-commit: $(shell date)"; \
	fi
	git push origin main
	@echo "✓ Changes pushed successfully"

.PHONY: git
git: git-commit ## Alias for git-commit

.PHONY: git-status
git-status: ## Show git status
	@echo "Git Status:"
	git status

##@ Security & Encryption

.PHONY: age-keygen
age-keygen: ## Generate new age encryption key
	@echo "Generating new age key..."
	age-keygen | age --armor --passphrase > ./home/key.txt.age
	@echo "✓ Age key generated"

.PHONY: age
age: age-keygen ## Alias for age-keygen

.PHONY: bw-unlock
bw-unlock: ## Unlock Bitwarden vault
	@echo "Unlocking Bitwarden vault..."
	@eval $$(bw unlock --raw | awk '{print "export BW_SESSION="$$1}')
	@echo "✓ Bitwarden vault unlocked"

##@ Cleanup

.PHONY: clean-docker
clean-docker: ## Clean Docker resources
	@echo "Cleaning Docker resources..."
	docker container prune -f || true
	docker image prune -f || true
	docker volume prune -f || true
	@echo "✓ Docker resources cleaned"

.PHONY: clean-vm
clean-vm: ## Delete Multipass VM
	@echo "Deleting VM: $(MP_VM)..."
	multipass delete $(MP_VM) || true
	multipass purge || true
	@echo "✓ VM deleted"

.PHONY: clean
clean: clean-docker ## Clean all temporary resources
	@echo "Cleaning temporary files..."
	find . -name "*.tmp" -delete || true
	find . -name "*.log" -delete || true
	@echo "✓ Cleanup completed"

##@ Information

.PHONY: list-vms
list-vms: ## List all Multipass VMs
	@echo "Multipass VMs:"
	multipass list

.PHONY: list-containers
list-containers: ## List all Docker containers
	@echo "Docker Containers:"
	docker ps -a

.PHONY: system-info
system-info: ## Display system information
	@echo "System Information:"
	@echo "OS: $(OS)"
	@echo "Architecture: $(ARCH)"
	@echo "Shell: $(SHELL)"
	@echo "Dotfiles Version: $(DOTFILES_VERSION)"
	@command -v chezmoi >/dev/null && echo "Chezmoi: $$(chezmoi --version)" || echo "Chezmoi: Not installed"
	@command -v docker >/dev/null && echo "Docker: $$(docker --version)" || echo "Docker: Not installed"
	@command -v multipass >/dev/null && echo "Multipass: $$(multipass version)" || echo "Multipass: Not installed"
