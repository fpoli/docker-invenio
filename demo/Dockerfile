FROM fedux/invenio-base
MAINTAINER Federico Poli "federico.poli@cern.ch"


#################
# Configuration #
#################

ADD invenio-local.conf /opt/invenio/etc/invenio-local.conf
RUN /opt/invenio/bin/inveniocfg --update-all
RUN /opt/invenio/bin/inveniocfg --load-bibfield-conf


####################
# Create Demo Site #
####################

ENV CFG_INSPIRE_BIBTASK_USER admin

RUN sudo /home/docker/services start && \
        mysql -u root -e "CREATE DATABASE IF NOT EXISTS invenio DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci" && \
        mysql -u root -e "GRANT ALL PRIVILEGES ON invenio.* TO invenio@localhost IDENTIFIED BY 'my123p\$ss'" && \
        /opt/invenio/bin/inveniocfg --create-tables && \

        /opt/invenio/bin/inveniocfg --create-demo-site && \
        /opt/invenio/bin/inveniocfg --load-demo-records && \
    sudo /home/docker/services stop
