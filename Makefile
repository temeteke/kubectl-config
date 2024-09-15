BIN_DIR ?= ~/.local/bin
KUBECTL_VERSION ?= $(subst v,,$(shell curl -fsSL https://dl.k8s.io/release/stable.txt))
HELMFILE_VERSION ?= $(subst https://github.com/helmfile/helmfile/releases/tag/v,,$(shell curl -fsS -w '%{redirect_url}' https://github.com/helmfile/helmfile/releases/latest))
YTT_VERSION ?= $(subst https://github.com/carvel-dev/ytt/releases/tag/v,,$(shell curl -fsS -w '%{redirect_url}' https://github.com/carvel-dev/ytt/releases/latest))

HOST_ARCH := $(shell uname -m)
ifeq ($(HOST_ARCH), aarch64)
	KUBECTL_TARGET := arm64
	HELMFILE_TARGET := linux_arm64
	YTT_TARGET := linux-arm64
	KREW_TARGET := linux_arm64
else
	KUBECTL_TARGET := amd64
	HELMFILE_TARGET := linux_amd64
	YTT_TARGET := linux-amd64
	KREW_TARGET := linux_amd64
endif

HELMFILE_TAR_NAME := helmfile_$(HELMFILE_VERSION)_$(HELMFILE_TARGET)
HELMFILE_TAR_FILE := $(HELMFILE_TAR_NAME).tar.gz
HELMFILE_TAR_URL := https://github.com/helmfile/helmfile/releases/download/v$(HELMFILE_VERSION)/$(HELMFILE_TAR_FILE)

KREW := krew-$(KREW_TARGET)
KREW_TAR_FILE := $(KREW).tar.gz
KREW_TAR_URL := https://github.com/kubernetes-sigs/krew/releases/latest/download/$(KREW_TAR_FILE)

.PHONY: all clean install uninstall
all: kubectl kustomize helmfile ytt $(KREW)

kubectl:
	curl -fsSLRO "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/$(KUBECTL_TARGET)/kubectl"
	chmod +x $@

kustomize:
	curl -fsSL https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash

helmfile: | $(HELMFILE_TAR_FILE)
	tar -xf $(HELMFILE_TAR_FILE) helmfile

$(HELMFILE_TAR_FILE):
	curl -fsSLR -o $@ $(HELMFILE_TAR_URL)

ytt:
	curl -fsSLR -o $@ "https://github.com/carvel-dev/ytt/releases/download/v$(YTT_VERSION)/ytt-$(YTT_TARGET)"
	chmod +x $@

$(KREW): $(KREW_TAR_FILE)
	tar -xf $(KREW_TAR_FILE) ./$(KREW)

$(KREW_TAR_FILE):
	curl -fsSLR -o $@ $(KREW_TAR_URL)

clean:
	rm -f kubectl
	rm -f kustomize
	rm -f helmfile helmfile_*
	rm -f ytt
	rm -f $(KREW) $(KREW_TAR_FILE)

install: install-kubectl install-kustomize install-helm install-helmfile install-ytt install-krew

install-kubectl: kubectl $(BIN_DIR)
	cp -a kubectl $(BIN_DIR)

install-kustomize: kustomize $(BIN_DIR)
	cp -a kustomize $(BIN_DIR)

install-helm: $(BIN_DIR)
	curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | HELM_INSTALL_DIR=$(BIN_DIR) USE_SUDO=false bash

install-helmfile: helmfile $(BIN_DIR)
	cp -a helmfile $(BIN_DIR)
	helmfile init --force

install-ytt: ytt $(BIN_DIR)
	cp -a ytt $(BIN_DIR)

install-krew: $(KREW)
	./$(KREW) install krew

uninstall:
	rm -f $(BIN_DIR)/kubectl
	rm -f $(BIN_DIR)/kustomize
	rm -f $(BIN_DIR)/helm
	rm -f $(BIN_DIR)/helmfile
	rm -f $(BIN_DIR)/ytt
	rm -rf ~/.krew

$(BIN_DIR):
	mkdir -p $(BIN_DIR)
