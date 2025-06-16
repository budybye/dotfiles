# Makefile for dotfiles management
# Author: budybye
# Version: 0.7

.ONESHELL:
SHELL := bash
.SHELLFLAGS := -ceuo pipefail
.DEFAULT_GOAL := help

# Variables
DOCKER_IMAGE := ubuntu-dev
DOCKER_CONTAINER := ubuntu-dev
MULTIPASS_VM := ubuntu
ARCH := $(shell uname -m)
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')

# Colors for output
RED := \033[31m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
RESET := \033[0m

# Docker settings
DOCKER_PORTS := -p 33389:3389 -p 2222:22
DOCKER_WORKDIR := /home/dev
DOCKER_USER := dev

# Multipass settings
MP_CPUS := 4
MP_MEMORY := 8G
MP_DISK := 42G
MP_TIMEOUT := 43210

##@ General

.PHONY: help
help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\n$(BLUE)Usage:$(RESET)\n  make $(GREEN)<target>$(RESET)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(GREEN)%-15s$(RESET) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(RESET)\n", substr($$0, 5) }' $(MAKEFILE_LIST)

.PHONY: version
version: ## Show version information
	@echo "$(GREEN)dotfiles version: 0.7$(RESET)"
	@echo "$(GREEN)OS: $(OS)$(RESET)"
	@echo "$(GREEN)Architecture: $(ARCH)$(RESET)"

##@ Setup & Installation

.PHONY: init
init: ## Initialize dotfiles with chezmoi
	@echo "$(GREEN)Initializing dotfiles...$(RESET)"
	./install.sh
	@echo "$(GREEN)✓ Dotfiles initialized successfully$(RESET)"

.PHONY: update
update: ## Update dotfiles from remote repository
	@echo "$(GREEN)Updating dotfiles...$(RESET)"
	chezmoi update
	@echo "$(GREEN)✓ Dotfiles updated successfully$(RESET)"

.PHONY: apply
apply: ## Apply dotfiles changes
	@echo "$(GREEN)Applying dotfiles changes...$(RESET)"
	chezmoi apply
	@echo "$(GREEN)✓ Changes applied successfully$(RESET)"

##@ Development

.PHONY: check
check: ## Check dotfiles configuration
	@echo "$(GREEN)Checking dotfiles configuration...$(RESET)"
	chezmoi diff || true
	@echo "$(GREEN)✓ Configuration check completed$(RESET)"

.PHONY: test
test: ## Run tests (placeholder for future implementation)
	@echo "$(YELLOW)Running tests...$(RESET)"
	@echo "$(YELLOW)TODO: Implement test suite$(RESET)"

##@ Docker

.PHONY: docker-build
docker-build: ## Build Docker image
	@echo "$(GREEN)Building Docker image: $(DOCKER_IMAGE)...$(RESET)"
	cd .devcontainer && docker build -t $(DOCKER_IMAGE) .
	@echo "$(GREEN)✓ Docker image built successfully$(RESET)"

.PHONY: docker-run
docker-run: docker-build ## Build and run Docker container
	@echo "$(GREEN)Running Docker container: $(DOCKER_CONTAINER)...$(RESET)"
	docker run \
		--rm \
		--interactive \
		--detach \
		--tty \
		--privileged \
		--name $(DOCKER_CONTAINER) \
		--hostname docker \
		--user $(DOCKER_USER) \
		--workdir $(DOCKER_WORKDIR) \
		--env DOCKER=true \
		--platform linux/$(ARCH) \
		$(DOCKER_PORTS) \
		$(DOCKER_IMAGE) || true
	@echo "$(GREEN)✓ Docker container started$(RESET)"

.PHONY: docker
docker: docker-run ## Alias for docker-run

.PHONY: up
up: ## Start Docker Compose services
	@echo "$(GREEN)Starting Docker Compose services...$(RESET)"
	cd .devcontainer && docker compose up -d
	@echo "$(GREEN)✓ Services started$(RESET)"

.PHONY: down
down: ## Stop Docker Compose services
	@echo "$(GREEN)Stopping Docker Compose services...$(RESET)"
	cd .devcontainer && docker compose down
	@echo "$(GREEN)✓ Services stopped$(RESET)"

.PHONY: exec
exec: ## Execute bash in Docker container
	@echo "$(GREEN)Executing bash in $(DOCKER_CONTAINER)...$(RESET)"
	docker exec -it $(DOCKER_CONTAINER) /bin/bash

.PHONY: logs
logs: ## Show Docker container logs
	@echo "$(GREEN)Showing logs for $(DOCKER_CONTAINER)...$(RESET)"
	docker logs -f $(DOCKER_CONTAINER)

##@ Virtual Machine (Multipass)

.PHONY: vm-create
vm-create: ## Create Multipass VM
	@echo "$(GREEN)Creating Multipass VM: $(MULTIPASS_VM)...$(RESET)"
	multipass launch \
		-n $(MULTIPASS_VM) \
		-c $(MP_CPUS) \
		-m $(MP_MEMORY) \
		-d $(MP_DISK) \
		--timeout $(MP_TIMEOUT) \
		--cloud-init cloud-init/multipass.yaml
	@echo "$(GREEN)✓ VM created successfully$(RESET)"
	@multipass exec $(MULTIPASS_VM) -- tail -5 /var/log/cloud-init.log

.PHONY: ubuntu
ubuntu: vm-create ## Alias for vm-create

.PHONY: vm-info
vm-info: ## Show VM information
	@echo "$(GREEN)VM Information:$(RESET)"
	multipass info $(MULTIPASS_VM)

.PHONY: vm-stop
vm-stop: ## Stop Multipass VM
	@echo "$(GREEN)Stopping VM: $(MULTIPASS_VM)...$(RESET)"
	multipass stop $(MULTIPASS_VM)
	@echo "$(GREEN)✓ VM stopped$(RESET)"

.PHONY: vm-start
vm-start: ## Start Multipass VM
	@echo "$(GREEN)Starting VM: $(MULTIPASS_VM)...$(RESET)"
	multipass start $(MULTIPASS_VM)
	@echo "$(GREEN)✓ VM started$(RESET)"

.PHONY: ssh
ssh: ## SSH into Multipass VM
	@echo "$(GREEN)Connecting to $(MULTIPASS_VM) via SSH...$(RESET)"
	ssh $(MULTIPASS_VM)

##@ Git Operations

.PHONY: git-commit
git-commit: ## Add, commit, and push changes
	@echo "$(GREEN)Committing and pushing changes...$(RESET)"
	git add -A
	git status
	@read -p "Enter commit message (or press Enter for auto-commit): " msg; \
	if [ -n "$$msg" ]; then \
		git commit -m "$$msg"; \
	else \
		git commit --allow-empty-message -m "Auto-commit: $(shell date)"; \
	fi
	git push origin main
	@echo "$(GREEN)✓ Changes pushed successfully$(RESET)"

.PHONY: git
git: git-commit ## Alias for git-commit

.PHONY: git-status
git-status: ## Show git status
	@echo "$(GREEN)Git Status:$(RESET)"
	git status

##@ Security & Encryption

.PHONY: age-keygen
age-keygen: ## Generate new age encryption key
	@echo "$(GREEN)Generating new age key...$(RESET)"
	age-keygen | age --armor --passphrase > ./home/key.txt.age
	@echo "$(GREEN)✓ Age key generated$(RESET)"

.PHONY: age
age: age-keygen ## Alias for age-keygen

.PHONY: bw-unlock
bw-unlock: ## Unlock Bitwarden vault
	@echo "$(GREEN)Unlocking Bitwarden vault...$(RESET)"
	@eval $$(bw unlock --raw | awk '{print "export BW_SESSION="$$1}')
	@echo "$(GREEN)✓ Bitwarden vault unlocked$(RESET)"

##@ Cleanup

.PHONY: clean-docker
clean-docker: ## Clean Docker resources
	@echo "$(GREEN)Cleaning Docker resources...$(RESET)"
	docker container prune -f || true
	docker image prune -f || true
	docker volume prune -f || true
	@echo "$(GREEN)✓ Docker resources cleaned$(RESET)"

.PHONY: clean-vm
clean-vm: ## Delete Multipass VM
	@echo "$(GREEN)Deleting VM: $(MULTIPASS_VM)...$(RESET)"
	multipass delete $(MULTIPASS_VM) || true
	multipass purge || true
	@echo "$(GREEN)✓ VM deleted$(RESET)"

.PHONY: clean
clean: clean-docker ## Clean all temporary resources
	@echo "$(GREEN)Cleaning temporary files...$(RESET)"
	find . -name "*.tmp" -delete || true
	find . -name "*.log" -delete || true
	@echo "$(GREEN)✓ Cleanup completed$(RESET)"

##@ Information

.PHONY: list-vms
list-vms: ## List all Multipass VMs
	@echo "$(GREEN)Multipass VMs:$(RESET)"
	multipass list

.PHONY: list-containers
list-containers: ## List all Docker containers
	@echo "$(GREEN)Docker Containers:$(RESET)"
	docker ps -a

.PHONY: system-info
system-info: ## Display system information
	@echo "$(GREEN)System Information:$(RESET)"
	@echo "OS: $(OS)"
	@echo "Architecture: $(ARCH)"
	@echo "Shell: $(SHELL)"
	@command -v chezmoi >/dev/null && echo "Chezmoi: $$(chezmoi --version)" || echo "Chezmoi: Not installed"
	@command -v docker >/dev/null && echo "Docker: $$(docker --version)" || echo "Docker: Not installed"
	@command -v multipass >/dev/null && echo "Multipass: $$(multipass version)" || echo "Multipass: Not installed"
