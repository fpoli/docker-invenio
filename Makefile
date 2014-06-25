VOLUME_OPTIONS =
PORT_OPTIONS = -p 4000:4000
NAME = fedux/invenio
VERSION = 0.0.1

.PHONY: all build test start bash

all: build

build:
	docker build -t $(NAME) .

test:
	docker run $(VOLUME_OPTIONS) -t -i $(NAME):latest "\
		/opt/invenio/bin/inveniocfg --run-unit-tests && \
		/opt/invenio/bin/inveniocfg --run-regression-tests --yes-i-know "

start:
	docker run $(PORT_OPTIONS) -t -i $(VOLUME_OPTIONS) $(NAME):latest

bash:
	docker run $(VOLUME_OPTIONS) -t -i $(NAME):latest /bin/bash
