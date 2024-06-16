SHELL_PATH = /bin/ash
SHELL = $(if $(wildcard $(SHELL_PATH)),/bin/ash,/bin/bash)
ARG_ENV ?= dev

# kindVar
KIND            := kindest/node:v1.30.0
KIND_CLUSTER    := ardan-starter-cluster
VERSION := 1.0

IMG_NAME := service-amd64

build:
	docker build \
	-f zarf/docker/Dockerfile.hello \
	-t ${IMG_NAME}:${VERSION} \
	--build-arg ARG_ENV=${ARG_ENV} \
	.

kind-up:
	kind create cluster \
		--image $(KIND) \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml
	kubectl config set-context --current --namespace=service-system

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
#	kubectl get pods -o wide --watch --all-namespaces
	kubectl get pods -o wide --all-namespaces

kind-status-ss:
	kubectl get pods -o wide --namespace=service-system

kind-load:
	kind load docker-image ${IMG_NAME}:${VERSION} --name $(KIND_CLUSTER)

kind-apply:
	cat zarf/k8s/base/service-pod/base-service.yaml | kubectl apply -f -

kind-logs:
	kubectl logs -l app=service --all-containers=true -f --tail=100

kind-restart:
	kubectl rollout restart deployment service-pod

kind-update: build  kind-load kind-restart

kind-describe:
	kubectl describe pod -l app=service