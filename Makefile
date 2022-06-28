# Project details
PROJECT_NAME = sigstore_local

SHELL = /bin/bash
TOPDIR = $(shell git rev-parse --show-toplevel)

help: ##help
	@echo "Targets:"
	@fgrep -h "##" $(MAKEFILE_LIST) |grep -v grep | sed -e 's/##//' | sed -e 's/^.PHONY: //'|grep -v help
	@echo "---------------------------------------------------------"
	@echo "Ensure ${HOME}/go/bin is in your search path"
	@echo "Install targets only required if package missing"
	@echo "Note quickstart target does not install packages"
	@echo "Note install-packages target is for RHEL/Fedora only"

.PHONY: ##quickstart
quickstart:
	registry clone-rekor rekor-cli-test-image create-cosign-sig start-mariadb secure-mariadb trillian-log-server trillian-log-signer createtree start-rekor-server

,PHONY: ##install-packages
install-packages:
	sudo dnf install mariadb-server git go softhsm opensc

.PHONY: ##install-registry
install-registry:
	go install github.com/google/go-containerregistry/cmd/registry@latest

.PHONY: ##install-cosign
install-cosign:
	go install github.com/sigstore/cosign/cmd/cosign@latest

.PHONY: ##install-trillian
install-trillian:
	go install github.com/google/trillian/cmd/trillian_log_server@latest
	go install github.com/google/trillian/cmd/trillian_log_signer@latest
	go install github.com/google/trillian/cmd/createtree@latest

.PHONY: ##install-ko
install-ko:
	go install github.com/google/ko@latest

.PHONY: ##clone-rekor
clone-rekor:
	@mkdir -p ${HOME}/sigstore-local/src
	git clone https://github.com/sigstore/rekor.git ${HOME}/sigstore-local/src

.PHONY: ##registry
registry:
	bash scripts/start_registry

.PHONY: ##rekor-cli-test-image
rekor-cli-test-image:
	bash scripts/rekor-image

.PHONY: ##create-cosign-sig
create-cosign-sig:
	cosign generate-key-pair

.PHONY: ##start-mariadb
start-mariadb:
	sudo systemctl start mariadb

.PHONY: ##secure-mariadb
secure-mariadb:
	echo "Skip password change, YES for everything else"
	sudo mysql_secure_installation

.PHONY: ##create-db-tables
create-db-tables:
	bash scripts/mariadb-create-tables

.PHONY: ##trillian-log-server
trillian-log-server:
	bash scripts/start_trillian_log_server

.PHONY: ##trillian-log-signer
trillian-log-signer:
	bash scripts/start_trillian_signer

.PHONY: ##createtree
createtree:
	bash scripts/start_createtree

.PHONY: ##start-rekor-server
start-rekor-server:
	bash scripts/start_rekor_server


