SHELL = /bin/bash

.PHONY: get build-rpm build-deb build-repo-yum build-repo-deb

.DEFAULT_GOAL = help

TOOL := "terraform"

help:
	@echo "You'll need to specify a thing to do:"
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

build: ## - Build Docker image
	@echo "[i] Building docker image"
	@docker build -t mcrmonkey/hashi-pkg .

output:
	@echo "[i] Creating output directory"
	@mkdir output

go: ## - Go get the tool. Specify "TOOL=" and/or "VERSION=" to override defaults
	@echo "[i] Getting ${TOOL}"
	@${MAKE} output
	@docker run -it --rm -e H_TOOL="${TOOL}" -e H_VERSION="${VERSION}" -v ${PWD}/output:/output mcrmonkey/hashi-pkg

