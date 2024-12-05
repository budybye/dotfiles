.PHONY: dev init up down ipfs exec ubuntu git bw ssh age

.ONESHELL:
SHELL = bash
.SHELLFLAGS = -ceuo pipefail

dev: bw init

init:
	chmod +x ./install.sh && \
	./install.sh
docker:
	docker \
	run \
	--rm \
	--interactive \
	--tty \
	--privileged \
	--name ubuntu \
	--hostname docker \
	-p 33389:3389 \
	-p 2222:22 \
	-v $(HOME)/data:/data \
	ghcr.io/budybye/ubuntu-dev \
	ubuntu ubuntu yes
up:
	docker compose up -d -f .devcontainer/docker-compose.yaml
down:
	docker compose down -f .devcontainer/docker-compose.yaml
ipfs:
	docker compose up -d ipfs -f .devcontainer/docker-compose.yaml && \
	docker compose exec ipfs ipfs add -r $(HOME)/data
exec:
	docker compose exec ubuntu /bin/bash
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
ssh:
	ssh ubuntu
git:
	git add -A && \
	git commit --allow-empty-message -m "" && \
	git push origin main
bw:
	@eval $$(bw unlock --raw | awk '{print "export BW_SESSION="$$1}')
age:
	age-keygen | age --armor --passphrase > ./home/key.txt.age
