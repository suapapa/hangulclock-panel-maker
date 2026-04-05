IMAGE := icn.vultrcr.com/homincr1/hangulclock-panel-maker:latest
PLATFORM := linux/amd64

.PHONY: all build push push-only

all: build

build:
	docker build --platform $(PLATFORM) -t $(IMAGE) -f svelte-app/Dockerfile svelte-app/

push: build
	docker push $(IMAGE)

push-only:
	docker push $(IMAGE)
