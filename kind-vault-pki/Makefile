IMAGE_NAME = aws-rolesanywhere
IMAGE_TAG = latest
REGISTRY = quay.io/ckyal
FULL_IMAGE_NAME = $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)

build:
	@echo "Building Docker image..."
	podman build -t $(FULL_IMAGE_NAME) .

push:
	@echo "Pushing Docker image to registry..."
	podman push $(FULL_IMAGE_NAME)

.PHONY: build  push
