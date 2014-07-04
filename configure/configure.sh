#!/bin/bash

cd /home/docker/configure

#####################
# Configure Invenio #
#####################

cp invenio-local.conf /opt/invenio/etc/invenio-local.conf
/opt/invenio/bin/inveniocfg --update-all
/opt/invenio/bin/inveniocfg --load-bibfield-conf


###################
# Configure MySQL #
###################

MYSQL_DB="invenio"
MYSQL_USER="invenio"
MYSQL_PASSWORD="my123p\$ss"

RET=1
while [[ RET -ne 0 ]]; do
    echo "Waiting for MySQL..."
    sleep 2
    mysql -h "$MYSQL_PORT_3306_TCP_ADDR" \
          -u root -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" \
          -e "status" > /dev/null 2>&1
    RET=$?
done

mysql -h "$MYSQL_PORT_3306_TCP_ADDR" \
      -u root -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" \
      -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DB DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci"
mysql -h "$MYSQL_PORT_3306_TCP_ADDR" \
      -u root -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" \
      -e "GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'"
/opt/invenio/bin/inveniocfg --create-tables
