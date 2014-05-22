#!/bin/bash

NAMESPACE="${NAMESPACE:-fpoli}"
DOCKER="${DOCKER:-docker}"
DATE="${DOCKER:-$(date +%Y%m%d%H%M%S)}"

die() {
    echo "/!\\ $1"
    exit 1
}

msg() {
    echo "[*] $@"
}

INSTALLED_NAME="$NAMESPACE/inspire-installed-$DATE"

INVENIO_REPOSITORY="https://github.com/inspirehep/ops.git"
INVENIO_BRANCH="prod"
INVENIO_FOLDER="invenio"

INSPIRE_REPOSITORY="https://github.com/inspirehep/inspire.git"
INSPIRE_BRANCH="master"
INSPIRE_FOLDER="inspire"

INVENIO_LOCAL_FILE="invenio-local.conf"
ISPIRE_CONFIG_LOCAL_FILE="inspire-config-local.mk"

msg "Checking Invenio"
if [ ! -d "$INVENIO_FOLDER" ]; then
    git clone -b "$INVENIO_BRANCH" "$INVENIO_REPOSITORY" "$INVENIO_FOLDER" || die "git clone Invenio failed"
fi

msg "Checking Inspire"
if [ ! -d "$INSPIRE_FOLDER" ]; then
    git clone -b "$INSPIRE_BRANCH" "$inspire_repository" "$INSPIRE_FOLDER" || die "git clone Inspire failed"
fi

msg "Checking $INVENIO_LOCAL_FILE"
if [ ! -e "$INVENIO_LOCAL_FILE" ]; then
    touch "$INVENIO_LOCAL_FILE"
fi

msg "Checking $ISPIRE_CONFIG_LOCAL_FILE"
if [ ! -e "$ISPIRE_CONFIG_LOCAL_FILE" ]; then
    touch "$ISPIRE_CONFIG_LOCAL_FILE"
fi

msg "Building Docker $INSTALLED_NAME"
$DOCKER build -t "$INSTALLED_NAME" . || die "docker build failed"

msg "Starting $INSTALLED_NAME"
$DOCKER run \
    -v "$(readlink -f $INVENIO_FOLDER):/home/docker/src/invenio:rw" \
    -v "$(readlink -f $INSPIRE_FOLDER):/home/docker/src/inspire:rw" \
    -p 4000:4000 \
    "$INSTALLED_NAME" \
    || die "docker run failed"
