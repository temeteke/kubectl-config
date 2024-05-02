BIN_DIR ?= ~/.local/bin
KUBECTL_VERSION ?= $(subst v,,$(shell curl -LS https://dl.k8s.io/release/stable.txt))
HELMFILE_VERSION ?= $(subst https://github.com/helmfile/helmfile/releases/tag/v,,$(shell curl -s -w '%{redirect_url}' https://github.com/helmfile/helmfile/releases/latest))
YTT_VERSION ?= $(subst https://github.com/carvel-dev/ytt/releases/tag/v,,$(shell curl -s -w '%{redirect_url}' https://github.com/carvel-dev/ytt/releases/latest))

HOST_ARCH := $(shell uname -m)
ifeq ($(HOST_ARCH), aarch64)
	KUBECTL_TARGET := arm64
	HELMFILE_TARGET := linux_arm64
	YTT_TARGET := linux-arm64
else
	KUBECTL_TARGET := amd64
	HELMFILE_TARGET := linux_amd64
	YTT_TARGET := linux-amd64
endif

HELMFILE_TAR_NAME := helmfile_$(HELMFILE_VERSION)_$(HELMFILE_TARGET)
HELMFILE_TAR_FILE := $(HELMFILE_TAR_NAME).tar.gz
HELMFILE_TAR_URL := https://github.com/helmfile/helmfile/releases/download/v$(HELMFILE_VERSION)/$(HELMFILE_TAR_FILE)

.PHONY: all clean install uninstall
all: kubectl kustomize helmfile ytt

kubectl:
	curl -LOR "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/$(KUBECTL_TARGET)/kubectl"
	chmod +x $@

kustomize:
	curl -s https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash

helmfile: | $(HELMFILE_TAR_FILE)
	tar -xf $(HELMFILE_TAR_FILE) helmfile

$(HELMFILE_TAR_FILE):
	curl -LR -o $@ $(HELMFILE_TAR_URL)

ytt:
	curl -LR -o $@ "https://github.com/carvel-dev/ytt/releases/download/v$(YTT_VERSION)/ytt-$(YTT_TARGET)"
	chmod +x $@

clean:
	rm -f kubectl
	rm -f kustomize
	rm -f helmfile $(HELMFILE_TAR_FILE)
	rm -f ytt

install: install-kubectl install-kustomize install-helm install-helmfile install-ytt

install-kubectl: kubectl $(BIN_DIR)
	cp -a kubectl $(BIN_DIR)

install-kustomize: kustomize $(BIN_DIR)
	cp -a kustomize $(BIN_DIR)

install-helm: $(BIN_DIR)
	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | HELM_INSTALL_DIR=$(BIN_DIR) USE_SUDO=false bash

install-helmfile: helmfile $(BIN_DIR)
	cp -a helmfile $(BIN_DIR)
	helmfile init --force

install-ytt: ytt $(BIN_DIR)
	cp -a ytt $(BIN_DIR)

uninstall:
	rm -f $(BIN_DIR)/kubectl
	rm -f $(BIN_DIR)/kustomize
	rm -f $(BIN_DIR)/helm
	rm -f $(BIN_DIR)/helmfile
	rm -f $(BIN_DIR)/ytt

$(BIN_DIR):
	mkdir -p $(BIN_DIR)
