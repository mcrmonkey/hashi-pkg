SHELL = /bin/bash

.PHONY: help container package

.DEFAULT_GOAL = help

TOOL := "terraform"

help:
	@echo -e "\nYou'll need to specify a thing to do:\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-\/]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo -e "\nSpecify "TOOL=" and/or "VERSION=" to override defaults\n"

container: ## - Build Docker image to fetch and create packages
	@echo "[i] Building docker image"
	@docker build -t mcrmonkey/hashi-pkg .

output:
	@echo "[i] Creating output directory"
	@mkdir output

package: ## - Download the tool and create a package
	@echo "[i] Getting ${TOOL}"
	@${MAKE} output
	@docker run -it --rm -e TOOL="${TOOL}" -e VERSION="${VERSION}" -v ${PWD}/output:/output mcrmonkey/hashi-pkg

