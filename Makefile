.PHONY: dev init up down ipfs exec ubuntu git bw ssh age

.ONESHELL:
SHELL = bash
.SHELLFLAGS = -ceuo pipefail

dev: bw init

init:
	chmod +x ./install.sh && ./install.sh
up:
	docker compose up -f .devcontainer/docker-compose.yaml -d
down:
	docker compose down -f .devcontainer/docker-compose.yaml
ipfs:
	docker compose -f .devcontainer/docker-compose.yaml exec ipfs ipfs add -r /data
exec:
	docker compose -f .devcontainer/docker-compose.yaml exec ubuntu /bin/bash
ubuntu:
	multipass launch -n ubuntu -c 4 -m 8G -d 42G  --timeout 3600 --mount ${HOME}/dotfiles:/home/ubuntu/dotfiles --cloud-init ./cloud-init/multipass.yaml && multipass exec ubuntu -- tail -2 /var/log/cloud-init.log
ssh:
	ssh ubuntu@$(multipass info ubuntu --format json | jq -r '.[0].ipv4[0]')
git:
	git add -A && git commit --allow-empty-message -m "" && git push origin main
bw:
	export BW_SESSION=$(bw unlock --raw)
age:
	age-keygen | age --armor --passphrase > key.txt.age
