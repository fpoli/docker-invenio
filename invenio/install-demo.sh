#!/bin/bash

cp invenio-local.conf /opt/invenio/etc/invenio-local.conf
/opt/invenio/bin/inveniocfg --update-all
/opt/invenio/bin/inveniocfg --load-bibfield-conf
