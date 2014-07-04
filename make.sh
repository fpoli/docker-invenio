#!/bin/bash -x

BASE_PATH=$(pwd)

INVENIO_BASE_IMAGE="fedux/invenio-web-base"
MYSQL_BASE_IMAGE="mysql"
REDIS_BASE_IMAGE="redis"

INVENIO_IMAGE="fedux/invenio-web"
MYSQL_IMAGE="fedux/invenio-mysql"
REDIS_IMAGE="fedux/invenio-redis"

SUFFIX="$RANDOM"

INVENIO_CONTAINER="invenio-web-$SUFFIX"
MYSQL_CONTAINER="invenio-mysql-$SUFFIX"
REDIS_CONTAINER="invenio-redis-$SUFFIX"

MYSQL_ROOT_PASSWORD="$RANDOM"

case "$1" in
	build)
		docker build -t $INVENIO_BASE_IMAGE base
		docker pull $MYSQL_BASE_IMAGE
		docker pull $REDIS_BASE_IMAGE
		;;

	configure)
		docker run -d \
			--name $MYSQL_CONTAINER \
			-e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
			$MYSQL_BASE_IMAGE
		docker run -d \
			--name $REDIS_CONTAINER \
			$REDIS_BASE_IMAGE
		docker run \
			--name $INVENIO_CONTAINER \
			--link $MYSQL_CONTAINER:mysql \
			--link $REDIS_CONTAINER:redis \
			--volume $BASE_PATH/configure:/home/docker/configure \
			$INVENIO_BASE_IMAGE \
			./configure/configure.sh

		docker stop $MYSQL_CONTAINER $REDIS_CONTAINER

		docker commit $INVENIO_CONTAINER $INVENIO_IMAGE
		docker commit $MYSQL_CONTAINER $MYSQL_IMAGE
		docker commit $REDIS_CONTAINER $REDIS_IMAGE
		;;

	unit-tests)
		docker run -d \
			--name $MYSQL_CONTAINER \
			$MYSQL_IMAGE
		docker run --rm \
			--link $MYSQL_CONTAINER:mysql \
			--volume $BASE_PATH/unit-tests:/home/docker/unit-tests \
			$INVENIO_IMAGE \
			./unit-tests/unit-tests.sh
		
		docker stop $MYSQL_CONTAINER
		;;

	install-demo)
		docker run -d \
			--name $MYSQL_CONTAINER \
			$MYSQL_IMAGE
		docker run -d \
			--name $REDIS_CONTAINER \
			$REDIS_IMAGE
		docker run \
			--link $MYSQL_CONTAINER:mysql \
			--link $REDIS_CONTAINER:redis \
			--volume $BASE_PATH/demo:/home/docker/demo \
			$INVENIO_IMAGE \
			./demo/install-demo.sh

		docker stop $MYSQL_CONTAINER $REDIS_CONTAINER
		
		docker commit $INVENIO_CONTAINER $INVENIO_IMAGE
		docker commit $MYSQL_CONTAINER $MYSQL_IMAGE
		docker commit $REDIS_CONTAINER $REDIS_IMAGE
		;;

	regression-tests)
		docker run -d \
			--name $MYSQL_CONTAINER \
			$MYSQL_IMAGE
		docker run -d \
			--name $REDIS_CONTAINER \
			$REDIS_IMAGE
		docker run \
			--link $MYSQL_CONTAINER:mysql \
			--link $REDIS_CONTAINER:redis \
			--volume $BASE_PATH/regression-tests:/home/docker/regression-tests \
			$INVENIO_IMAGE \
			./regression-tests/regression-tests.sh

		docker stop $MYSQL_CONTAINER $REDIS_CONTAINER
		;;

	start)
		docker run -d \
			--name $MYSQL_CONTAINER \
			$MYSQL_IMAGE
		docker run -d \
			--name $REDIS_CONTAINER \
			$REDIS_IMAGE
		docker run -d \
			--link $MYSQL_CONTAINER:mysql \
			--link $REDIS_CONTAINER:redis \
			$INVENIO_IMAGE

		echo Mysql container: $MYSQL_CONTAINER
		echo Redis container: $REDIS_CONTAINER
		echo Invenio container: $INVENIO_CONTAINER
		echo To stop the containers execute:
		echo docker stop $INVENIO_CONTAINER $REDIS_CONTAINER $MYSQL_CONTAINER
		;;

	clear)
		docker rmi \
			$INVENIO_BASE_IMAGE $MYSQL_BASE_IMAGE $REDIS_BASE_IMAGE \
			$INVENIO_IMAGE $MYSQL_IMAGE $REDIS_IMAGE
		;;

	*)
		echo $"Usage: $0 {build|configure|...}"
		exit 1
esac
