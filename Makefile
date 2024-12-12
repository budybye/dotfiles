.ONESHELL:
SHELL = bash
.SHELLFLAGS = -ceuo pipefail

.PHONY: dev
dev: bw init

.PHONY: init
init:
	sh -c "./install.sh"

.PHONY: docker
docker:
	cd .devcontainer && \
	docker build -t ubuntu-dev . && \
	docker run \
	--rm \
	--detach \
	--tty \
	--privileged \
	--name ubuntu-dev \
	--hostname docker \
	--user dev \
	--workdir /home/dev \
	--env DOCKER=true \
	--platform linux/${ARCH} \
	-p 33389:3389 \
	-p 2222:22 \
	-v $(HOME)/data:/data \
	ubuntu-dev \
	ubuntu ubuntu yes && \
	cd ..

.PHONY: exec
exec:
	docker exec ubuntu-dev /bin/bash

.PHONY: up
up:
	cd .devcontainer && \
	docker compose up -d

.PHONY: down
down:
	cd .devcontainer && \
	docker compose down

.PHONY: ipfs
ipfs:
	cd .devcontainer && \
	docker compose up -d ipfs && \
	cd .. && \
	docker compose exec ipfs ipfs add -r $(HOME)/data

.PHONY: ubuntu
ubuntu:
	multipass \
	launch \
	-n ubuntu \
	-c 4 \
	-m 8G \
	-d 42G \
	--timeout 7200 \
	--cloud-init cloud-init/multipass.yaml && \
	multipass exec ubuntu -- tail -5 /var/log/cloud-init.log

.PHONY: ssh
ssh:
	ssh ubuntu

.PHONY: git
git:
	git add -A && \
	git commit --allow-empty-message -m "" && \
	git push origin main

.PHONY: bw
bw:
	@eval $$(bw unlock --raw | awk '{print "export BW_SESSION="$$1}')

.PHONY: age
age:
	age-keygen | age --armor --passphrase > ./home/key.txt.age
