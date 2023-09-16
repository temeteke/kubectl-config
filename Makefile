BIN_DIR := ~/.local/bin

.PHONY: all clean install uninstall
all: kubectl

kubectl:
	curl -LO "https://dl.k8s.io/release/$$(curl -LS https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	chmod +x $@

clean:
	rm -f kubectl

install: kubectl
	mkdir -p $(BIN_DIR)
	cp $^ $(BIN_DIR)
	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | HELM_INSTALL_DIR=$(BIN_DIR) USE_SUDO=false bash

uninstall:
	rm $(BIN_DIR)/kubectl
	rm $(BIN_DIR)/helm
