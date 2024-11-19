.PHONY: dev init up ubuntu git bw ssh

.ONESHELL:
SHELL = bash
.SHELLFLAGS = -ceuo pipefail

dev: bw init

init:
	chmod +x ./install.sh
	./install.sh | tee ${HOME}/make.log && rm -f ${HOME}/make.log

up:
	docker compose up -f .devcontainer/docker-compose.yml -d

ubuntu:
	multipass launch -n ubuntu -c 4 -m 8G -d 42G  --timeout 3600 --mount ${HOME}/dotfiles:/home/ubuntu/dotfiles --cloud-init $(pwd)/cloud-init/multipass.yaml && multipass info ubuntu

bw:
	export BW_SESSION=$(bw unlock --raw)

ssh:
	ssh ubuntu@$(multipass info ubuntu --format json | jq -r '.[0].ipv4[0]')

git:
	git add -A && git commit --allow-empty-message -m "" && git push origin main
