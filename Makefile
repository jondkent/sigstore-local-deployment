# Project details
PROJECT_NAME = sigstore_local

SHELL := /bin/bash
TOPDIR := $(shell git rev-parse --show-toplevel)

help: ##help
	@echo "Targets:"
	@fgrep -h "##" $(MAKEFILE_LIST) |grep -v grep | sed -e 's/##//' | sed -e 's/^.PHONY: //'|grep -v help
	@echo "---------------------------------------------------------"
	@echo "Ensure ${HOME}/go/bin is in your search path"
	@echo "*Note* quickstart target does not install packages, run install targets before using quickstart target"
	@echo "*Note* install-packages-linux target is for RHEL/Fedora only"
	@echo "Once deployed run make post-deploy-tests to validate state"
	@echo "Refer to journalctl for log output from targets"
	@echo "To stop all processes and, optionally clear Mariadb, run make cleanup"

.PHONY: ##quickstart
quickstart: registry clone-rekor test-registry create-cosign-sig test-cosign start-mariadb create-db-tables trillian-log-server trillian-log-signer createtree start-rekor-server test-rekor-server

.PHONY: ##post-deploy-tests
post-deploy-tests: test-cosign test-rekor

.PHONY: ##cleanup
cleanup:
	bash scripts/stop-cleanup

.PHONY: ##install-packages-linux
install-packages-linux:
	sudo dnf install mariadb-server git go softhsm opensc

.PHONY: ##install-packages-mac
install-packages-mac:
	brew install mariadb git go softhsm opensc

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
	bash scripts/clone-rekor

.PHONY: ##registry
registry:
	bash scripts/start_registry

.PHONY: ##create-cosign-sig
create-cosign-sig:
	cosign generate-key-pair

.PHONY: ##start-mariadb
start-mariadb:
	sudo systemctl start mariadb

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

.PHONY: ##test-registry
test-registry:
	bash tests/test-registry

.PHONY: ##test-rekor-server
test-rekor-server:
	bash tests/test_rekor_server

.PHONY: ##test-cosign
test-cosign:
	bash tests/simple-image-sign

.PHONY: ##test-rekor
test-rekor:
	bash tests/test-rekor

