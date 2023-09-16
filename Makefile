.PHONY: all clean install uninstall
all: kubectl

kubectl:
	curl -LO "https://dl.k8s.io/release/$$(curl -LS https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	chmod +x $@

clean:
	rm -f kubectl

install: kubectl
	cp $^ ~/.local/bin/

uninstall:
	rm ~/.local/bin/kubectl
