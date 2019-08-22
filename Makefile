SHELL = /bin/bash

.PHONY: help build go

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
	@docker run -it --rm -e TOOL="${TOOL}" -e VERSION="${VERSION}" -v ${PWD}/output:/output mcrmonkey/hashi-pkg

