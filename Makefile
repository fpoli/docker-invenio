VOLUME_OPTIONS =
PORT_OPTIONS = -p 4000:4000
NAME = fedux/invenio

.PHONY: all build test start bash

all: build

build:
	docker build -t $(NAME) invenio
	echo Pull MySQL image
	echo Pull Redis image

configure:
	echo Create database
	echo Configure Invenio

install-demo:
	echo TODO

test:
	echo TODO

test-demo:
	docker run $(VOLUME_OPTIONS) -t -i $(NAME):latest "\
		/opt/invenio/bin/inveniocfg --run-unit-tests && \
		/opt/invenio/bin/inveniocfg --run-regression-tests --yes-i-know "

start:
	docker run $(PORT_OPTIONS) -t -i $(VOLUME_OPTIONS) $(NAME):latest

start-dev:
	echo TODO

bash:
	docker run $(VOLUME_OPTIONS) -t -i $(NAME):latest /bin/bash

