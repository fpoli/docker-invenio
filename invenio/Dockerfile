FROM ubuntu:14.04
MAINTAINER Federico Poli "federico.poli@cern.ch"


################
# Requirements #
################

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
    python-pip python-dev libssl-dev libxml2-dev libxslt-dev gnuplot clisp \
    automake pstotext gettext git unzip wget
RUN pip install git+https://bitbucket.org/osso/invenio-devserver.git


###############
# Create user #
###############

RUN useradd --create-home docker
USER docker
ENV HOME /home/docker


###########
# Invenio #
###########

# Preparing Invenio build folder
RUN git clone -b new-prod https://github.com/inspirehep/ops.git /home/docker/invenio
WORKDIR /home/docker/invenio

# Installing Invenio requirements
RUN pip install -r requirements.txt
#RUN pip install -r requirements-extras.txt

# Building Invenio
RUN aclocal
RUN automake -a
RUN autoconf
RUN ./configure 
RUN make

# Preparing Invenio destination folders
USER root
RUN mkdir -p /opt/invenio
RUN chown docker:docker -R /opt/invenio
RUN ln -s /opt/invenio/lib/python/invenio /usr/local/lib/python2.7/dist-packages/invenio
USER docker

# Installing Invenio and plugins
RUN make install
RUN make install-jquery-plugins
RUN make install-mathjax-plugin
#RUN make install-jsmath-plugin
#RUN make install-fckeditor-plugin


###########
# Startup #
###########

WORKDIR /home/docker
EXPOSE 4000
CMD ["serve", "-b", "0.0.0.0"]
