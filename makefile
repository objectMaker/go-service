SHELL_PATH = /bin/ash
SHELL = $(if $(wildcard $(SHELL_PATH)),/bin/ash,/bin/bash)
ARG_ENV ?= dev

# kindVar
KIND            := kindest/node:v1.30.0
KIND_CLUSTER    := ardan-starter-cluster

build:
	docker build \
	-f zarf/docker/Dockerfile.hello \
	-t go-hello \
	--build-arg ARG_ENV=${ARG_ENV} \
	.

kind-up:
	kind create cluster \
		--image $(KIND) \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml
	kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)
			

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
#	kubectl get pods -o wide --watch --all-namespaces
	kubectl get pods -o wide --all-namespaces