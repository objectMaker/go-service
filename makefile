SHELL_PATH = /bin/ash
SHELL = $(if $(wildcard $(SHELL_PATH)),/bin/ash,/bin/bash)
ARG_ENV ?= dev

# kindVar
KIND            := kindest/node:v1.30.0
KIND_CLUSTER    := ardan-starter-cluster
VERSION := 1.0

IMG_NAME := sales-amd64

build:
	docker build \
	-f zarf/docker/Dockerfile.sales \
	-t ${IMG_NAME}:${VERSION} \
	--build-arg ARG_ENV=${ARG_ENV} \
	.

kind-up:
	kind create cluster \
		--image $(KIND) \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml
	kubectl config set-context --current --namespace=sales-system

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
#	kubectl get pods -o wide --watch --all-namespaces
	kubectl get pods -o wide --all-namespaces

kind-status-ss:
	kubectl get pods -o wide --namespace=sales-system

kind-load:
	kind load docker-image ${IMG_NAME}:${VERSION} --name $(KIND_CLUSTER)

kind-apply:
	kustomize build zarf/k8s/kind/sales-pod | kubectl apply -f -

kind-logs:
	kubectl logs -l app=sales --all-containers=true -f --tail=100

kind-restart:
	kubectl rollout restart deployment sales-pod

kind-update: build  kind-load kind-restart

kind-update-apply: build  kind-load kind-apply

kind-describe:
	kubectl describe pod -l app=sales

tidy:
	go mod tidy
	go mod vendor	