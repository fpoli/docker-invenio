PORT_OPTIONS = -p 4000:4000
BASE_IMAGE = fedux/invenio-newprod-base
DEMO_IMAGE = fedux/invenio-newprod-demo
VERSION = 0.0.1

.PHONY: all build test start bash

all: build

build:
	docker build -t $(BASE_IMAGE) base
	docker build -t $(DEMO_IMAGE) demo

test:
	docker run -t -i $(DEMO_IMAGE):latest /bin/sh -c "\
		sudo /home/docker/services start && \
		/opt/invenio/bin/inveniocfg --run-unit-tests && \
		/opt/invenio/bin/inveniocfg --run-regression-tests --yes-i-know "

push:
	docker push $(BASE_IMAGE):latest
	docker push $(DEMO_IMAGE):latest

start-demo:
	docker run $(PORT_OPTIONS) -t -i $(DEMO_IMAGE):latest

bash-demo:
	docker run -t -i $(DEMO_IMAGE):latest /bin/bash
