DOCKER=docker
VOLUME_OPTIONS=
PORT_OPTIONS=-p 4000:4000
NAME=fpoli/invenio

all: build

build:
    ${DOCKER} build -t ${NAME} .

init: clean data-dir
    ${DOCKER} run ${VOLUME_OPTIONS} ${NAME}:latest init

start:
    sudo docker run ${PORT_OPTIONS} ${VOLUME_OPTIONS} ${NAME}:latest

bash:
    sudo docker run ${VOLUME_OPTIONS} -t -i ${NAME}:latest /bin/bash
