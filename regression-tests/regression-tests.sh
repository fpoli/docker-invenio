#!/bin/bash

RET=1
while [[ RET -ne 0 ]]; do
    echo "Waiting for MySQL..."
    sleep 2
    mysql -h "$MYSQL_PORT_3306_TCP_ADDR" \
          -u root -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" \
          -e "status" > /dev/null 2>&1
    RET=$?
done

serve -b 0.0.0.0 2>&1 > /dev/null & 

/opt/invenio/bin/inveniocfg --regression-tests
