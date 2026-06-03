.DEFAULT_GOAL := help

help: ## Show this help
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_-]+:.*## / {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

test: ## Run tests
	./gradlew test

start: run ## Alias for 'run'

run: ## Run the app locally (bootRun)
	./gradlew bootRun

update-gradle: ## Update the Gradle wrapper
	./gradlew wrapper --gradle-version 9.2.1

update-deps: ## Refresh dependency versions
	./gradlew refreshVersions

install: ## Resolve/download dependencies
	./gradlew dependencies

build: ## Build the app (gradle build)
	./gradlew build

lint: ## Check code formatting
	./gradlew spotlessCheck

lint-fix: ## Auto-fix code formatting
	./gradlew spotlessApply

.PHONY: help build

DOCKER_REGISTRY ?= docker.io
DOCKER_USER     ?= abdujabbar
IMAGE_NAME      ?= bulletins
IMAGE           ?= $(DOCKER_REGISTRY)/$(DOCKER_USER)/$(IMAGE_NAME)
TAG             ?= $(shell git rev-parse --short HEAD)

docker-build: ## Build image, tag :<git-sha> and :latest
	docker build --provenance=false -t $(IMAGE):$(TAG) -t $(IMAGE):latest .

docker-login: ## Log in to Docker Hub
	docker login $(DOCKER_REGISTRY)

docker-push: ## Push both tags to Docker Hub
	docker push $(IMAGE):$(TAG)
	docker push $(IMAGE):latest

docker-release: docker-build docker-push ## Build + push to Docker Hub

docker-buildx: ## Multi-arch build + push (amd64, arm64)
	docker buildx build --platform linux/amd64,linux/arm64 \
		--provenance=false \
		-t $(IMAGE):$(TAG) -t $(IMAGE):latest --push .

.PHONY: docker-build docker-login docker-push docker-release docker-buildx
