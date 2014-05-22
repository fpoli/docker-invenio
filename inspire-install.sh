#!/bin/bash

currentdir=$(pwd)

echo "* Building Inspire"

cp "src/inspire-config-local.mk" "src/inspire/config-local.mk"
mkdir -p "/opt/invenio/lib/webdoc/invenio/help"
mkdir -p "/opt/invenio/lib/python/invenio/websubmit_functions"

cd "src/inspire"
make 
make install
cd "$currentdir"

make install-dbchanges

sudo -u www-data /opt/invenio/bin/inveniocfg --update-all
sudo -u www-data /opt/invenio/bin/inveniocfg --load-bibfield-conf
sudo service apache2 restart

echo "* Preparing Apache2 configuration"
sudo -u www-data /opt/invenio/bin/inveniocfg --create-apache-conf
sudo ln -s /opt/invenio/etc/apache/invenio-apache-vhost.conf /etc/apache2/sites-available/invenio.conf
sudo ln -s /opt/invenio/etc/apache/invenio-apache-vhost-ssl.conf /etc/apache2/sites-available/invenio-ssl.conf
sudo a2dissite *default*
sudo a2ensite invenio
sudo a2ensite invenio-ssl
sudo service apache2 restart

sudo service apache2 restart

echo "* Installation finished:" $(date)
