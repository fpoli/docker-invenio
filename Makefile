BASE_IMAGE = fpoli/invenio-base
READY_IMAGE = fpoli/invenio-ready

.PHONY: all build test start bash

all: prepare

build:
	docker build -t $(BASE_IMAGE) .

start:
	docker run -d $(BASE_IMAGE):latest /usr/sbin/sshd -D

bash:
	docker run -t -i $(BASE_IMAGE):latest /bin/bash

clean:
	docker rmi $(BASE_IMAGE):latest
