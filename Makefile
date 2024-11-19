.PHONY: dev init up down exec ubuntu git bw ssh
.ONESHELL:
SHELL = /usr/bin/env bash
.SHELLFLAGS = -ceuo pipefail

dev: bw init

init:
	chmod +x ./install.sh
	./install.sh | tee ${HOME}/make.log
	rm -f ${HOME}/make.log
up:
	docker compose up -f .devcontainer/docker-compose.yml -d
down:
	docker compose down -f .devcontainer/docker-compose.yml
ipfs:
	docker compose exec -it ipfs ipfs add -r /data

ubuntu:
	multipass launch -n ubuntu -c 4 -m 8G -d 42G  --timeout 3600 --mount ${HOME}/dotfiles:/home/ubuntu/dotfiles --cloud-init $(pwd)/cloud-init/multipass.yaml && multipass info ubuntu
ssh:
	ssh ubuntu@$(multipass info ubuntu --format json | jq -r '.[0].ipv4[0]')
git:
	git add -A && git commit --allow-empty-message -m "" && git push origin main
bw:
	export BW_SESSION=$(bw unlock --raw)
