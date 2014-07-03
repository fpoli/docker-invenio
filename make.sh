#!/bin/bash -x

INVENIO_IMAGE="fedux/invenio"
MYSQL_IMAGE="mysql"
REDIS_IMAGE="redis"

MYSQL_ROOT_PASSWORD="$RANDOM"

case "$1" in
	build)
		docker build -t $INVENIO_IMAGE invenio
		docker pull $MYSQL_IMAGE
		docker pull $REDIS_IMAGE
		;;

	configure)
		MYSQL_CONTAINER=$(docker run -d -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" $MYSQL_IMAGE)
		REDIS_CONTAINER=$(docker run -d $REDIS_IMAGE)
		INVENIO_CONTAINER=$(docker run \
			--link $MYSQL_CONTAINER:mysql \
			--link $REDIS_CONTAINER:redis \
			$INVENIO_IMAGE \
			./configure.sh)

		exit 1

		docker stop $MYSQL_CONTAINER $REDIS_CONTAINER

		docker commit $MYSQL_CONTAINER $MYSQL_IMAGE
		docker commit $REDIS_CONTAINER $REDIS_IMAGE
		;;

	unit-tests)
		docker run --rm $INVENIO_IMAGE:latest /opt/invenio/bin/inveniocfg --run-unit-tests
		;;

	install-demo)
		MYSQL_CONTAINER=$(docker run -d -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" $MYSQL_IMAGE)
		REDIS_CONTAINER=$(docker run -d $REDIS_IMAGE)
		INVENIO_CONTAINER=$(docker run \
			--link $MYSQL_CONTAINER:mysql \
			--link $REDIS_CONTAINER:redis \
			$INVENIO_IMAGE \
			./install-demo.sh)

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
			"serve -b 0.0.0.0 &; /opt/invenio/bin/inveniocfg --run-regression-tests")

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
