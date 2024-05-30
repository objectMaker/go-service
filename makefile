SHELL_PATH = /bin/ash
SHELL = $(if $(wildcard $(SHELL_PATH)),/bin/ash,/bin/bash)
ARG_ENV ?= dev

build:
	docker build \
	-f zarf/docker/Dockerfile.hello \
	-t go-hello \
	--build-arg ARG_ENV=${ARG_ENV} \
	.