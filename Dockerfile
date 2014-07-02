FROM ubuntu:14.04
MAINTAINER Federico Poli "federico.poli@cern.ch"

RUN apt-get update

# Database
RUN apt-get install -y mariadb-server libmariadbclient-dev

# Webserver
RUN apt-get install -y \
    python-pip redis-server python-dev libssl-dev libxml2-dev libxslt-dev \
    gnuplot clisp automake pstotext gettext
RUN apt-get install -y git
RUN pip install git+https://bitbucket.org/osso/invenio-devserver.git

# System
RUN apt-get install -y unzip wget

RUN apt-get install -y openssh-server

RUN mkdir /var/run/sshd

RUN echo 'root:docker' | chpasswd
