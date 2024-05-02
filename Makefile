BIN_DIR ?= ~/.local/bin
KUBECTL_VERSION ?= $(subst v,,$(shell curl -LS https://dl.k8s.io/release/stable.txt))
HELMFILE_VERSION ?= $(subst https://github.com/helmfile/helmfile/releases/tag/v,,$(shell curl -s -w '%{redirect_url}' https://github.com/helmfile/helmfile/releases/latest))

HOST_ARCH := $(shell uname -m)
ifeq ($(HOST_ARCH), aarch64)
	KUBECTL_TARGET := arm64
	HELMFILE_TARGET := linux_arm64
else
	KUBECTL_TARGET := amd64
	HELMFILE_TARGET := linux_amd64
endif

HELMFILE_TAR_NAME := helmfile_$(HELMFILE_VERSION)_$(HELMFILE_TARGET)
HELMFILE_TAR_FILE := $(HELMFILE_TAR_NAME).tar.gz
HELMFILE_TAR_URL := https://github.com/helmfile/helmfile/releases/download/v$(HELMFILE_VERSION)/$(HELMFILE_TAR_FILE)

.PHONY: all clean install uninstall
all: kubectl kustomize helmfile

kubectl:
	curl -LOR "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/$(KUBECTL_TARGET)/kubectl"
	chmod +x $@

kustomize:
	curl -s https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash

helmfile: | $(HELMFILE_TAR_FILE)
	tar -xf $(HELMFILE_TAR_FILE) helmfile

$(HELMFILE_TAR_FILE):
	curl -LR -o $@ $(HELMFILE_TAR_URL)

clean:
	rm -f kubectl
	rm -f kustomize
	rm -f helmfile $(HELMFILE_TAR_FILE)

install: install-kubectl install-kustomize install-helm install-helmfile install-carvel

install-kubectl: kubectl $(BIN_DIR)
	cp -a kubectl $(BIN_DIR)

install-kustomize: kustomize $(BIN_DIR)
	cp -a kustomize $(BIN_DIR)

install-helm: $(BIN_DIR)
	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | HELM_INSTALL_DIR=$(BIN_DIR) USE_SUDO=false bash

install-helmfile: helmfile $(BIN_DIR)
	cp -a helmfile $(BIN_DIR)
	helmfile init --force

install-carvel: $(BIN_DIR)
	curl -L https://carvel.dev/install.sh | K14SIO_INSTALL_BIN_DIR=$(BIN_DIR) bash

uninstall:
	rm -f $(BIN_DIR)/kubectl
	rm -f $(BIN_DIR)/kustomize
	rm -f $(BIN_DIR)/helm
	rm -f $(BIN_DIR)/helmfile
	rm -f $(BIN_DIR)/ytt $(BIN_DIR)/imgpkg $(BIN_DIR)/kbld $(BIN_DIR)/kapp $(BIN_DIR)/kwt $(BIN_DIR)/vendir $(BIN_DIR)/kctrl

$(BIN_DIR):
	mkdir -p $(BIN_DIR)
