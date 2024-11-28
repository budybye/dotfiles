.PHONY: dev init up down ipfs exec ubuntu git bw ssh age

.ONESHELL:
SHELL = bash
.SHELLFLAGS = -ceuo pipefail

dev: bw init

init:
	chmod +x ./install && \
	./install
up:
	cd .devcontainer && \
	docker compose up -d && \
	cd ..
down:
	cd .devcontainer && \
	docker compose down && \
	cd ..
ipfs:
	cd .devcontainer && \
	docker compose exec ipfs ipfs add -r $(HOME)/data && \
	cd ..
exec:
	cd .devcontainer && \
	docker compose exec ubuntu /bin/bash
ubuntu:
	multipass launch \
		-n ubuntu \
		-c 4 \
		-m 8G \
		-d 42G \
		--timeout 3600 \
		--cloud-init cloud-init/multipass.yaml && \
	multipass exec ubuntu -- tail -2 /var/log/cloud-init.log
ssh:
	ssh ubuntu@$(multipass info ubuntu --format json | jq -r '.[0].ipv4[0]')
git:
	git add -A && \
	git commit --allow-empty-message -m "" && \
	git push origin main
bw:
	@eval $$(bw unlock --raw | awk '{print "export BW_SESSION="$$1}')
age:
	age-keygen | age --armor --passphrase > key.txt.age
