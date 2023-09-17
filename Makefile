BIN_DIR := ~/.local/bin

HELMFILE_VERSION := $(subst https://github.com/helmfile/helmfile/releases/tag/v,,$(shell curl -s -w '%{redirect_url}' https://github.com/helmfile/helmfile/releases/latest))
HELMFILE_TARGET := linux_amd64
HELMFILE_TAR_NAME := helmfile_$(HELMFILE_VERSION)_$(HELMFILE_TARGET)
HELMFILE_TAR_FILE := $(HELMFILE_TAR_NAME).tar.gz
HELMFILE_TAR_URL := https://github.com/helmfile/helmfile/releases/download/v$(HELMFILE_VERSION)/$(HELMFILE_TAR_FILE)

.PHONY: all clean install uninstall
all: kubectl helmfile

kubectl:
	curl -LOR "https://dl.k8s.io/release/$$(curl -LS https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	chmod +x $@

helmfile: | $(HELMFILE_TAR_FILE)
	tar -xf $(HELMFILE_TAR_FILE) helmfile

$(HELMFILE_TAR_FILE):
	curl -LR -o $@ $(HELMFILE_TAR_URL)

clean:
	rm -f kubectl
	rm -f helmfile $(HELMFILE_TAR_FILE)

install: install-kubectl install-helm install-helmfile

install-kubectl: kubectl $(BIN_DIR)
	cp -a kubectl $(BIN_DIR)

install-helm: $(BIN_DIR)
	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | HELM_INSTALL_DIR=$(BIN_DIR) USE_SUDO=false bash

install-helmfile: helmfile $(BIN_DIR)
	cp -a helmfile $(BIN_DIR)
	helmfile init --force

uninstall:
	rm -f $(BIN_DIR)/kubectl
	rm -f $(BIN_DIR)/helm
	rm -f $(BIN_DIR)/helmfile

$(BIN_DIR):
	mkdir -p $(BIN_DIR)
