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

		exit 1

		docker stop $MYSQL_CONTAINER $REDIS_CONTAINER

		docker commit $INVENIO_CONTAINER $INVENIO_IMAGE
		docker commit $MYSQL_CONTAINER $MYSQL_IMAGE
		docker commit $REDIS_CONTAINER $REDIS_IMAGE
		;;

	unit-tests)
		docker run --rm $INVENIO_IMAGE /opt/invenio/bin/inveniocfg --run-unit-tests
		;;

	install-demo)
		MYSQL_CONTAINER=$( docker run -d -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" $MYSQL_IMAGE )
		REDIS_CONTAINER=$( docker run -d $REDIS_IMAGE )
		INVENIO_CONTAINER=$(docker run \
			--link $MYSQL_CONTAINER:mysql \
			--link $REDIS_CONTAINER:redis \
			$INVENIO_IMAGE \
			./install-demo.sh
		)

		docker stop $MYSQL_CONTAINER $REDIS_CONTAINER
		
		docker commit $MYSQL_CONTAINER $MYSQL_IMAGE
		docker commit $REDIS_CONTAINER $REDIS_IMAGE
		;;

	regression-tests)
		MYSQL_CONTAINER=$(docker run -d -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" $MYSQL_IMAGE)
		REDIS_CONTAINER=$(docker run -d $REDIS_IMAGE)
		INVENIO_CONTAINER=$(docker run \
			--link $MYSQL_CONTAINER:mysql \
			--link $REDIS_CONTAINER:redis \
			$INVENIO_IMAGE \
			/bin/bash -c "serve -b 0.0.0.0 &; /opt/invenio/bin/inveniocfg --run-regression-tests")

		docker stop $MYSQL_CONTAINER $REDIS_CONTAINER
		;;

	start)
		MYSQL_CONTAINER=$(docker run -d -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" $MYSQL_IMAGE)
		REDIS_CONTAINER=$(docker run -d $REDIS_IMAGE)
		INVENIO_CONTAINER=$(
			docker run -d \
			--link $MYSQL_CONTAINER:mysql \
			--link $REDIS_CONTAINER:redis \
			$INVENIO_IMAGE
		)
		echo Mysql container: $MYSQL_CONTAINER
		echo Redis container: $REDIS_CONTAINER
		echo Invenio container: $INVENIO_CONTAINER
		echo To stop the containers execute:
		echo docker stop $INVENIO_CONTAINER $REDIS_CONTAINER $MYSQL_CONTAINER
		;;

	clear)
		docker rmi $INVENIO_IMAGE $MYSQL_IMAGE $REDIS_IMAGE
		;;

	*)
		echo $"Usage: $0 {build|configure|...}"
		exit 1
esac
