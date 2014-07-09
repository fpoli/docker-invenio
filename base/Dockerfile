FROM ubuntu:14.04
MAINTAINER Federico Poli "federico.poli@cern.ch"


################
# Requirements #
################

RUN apt-get update

RUN apt-get install -y python-pip
RUN apt-get install -y mariadb-server libmariadbclient-dev redis-server 
RUN apt-get install -y libssl-dev libxml2-dev libxslt-dev
RUN apt-get install -y gnuplot clisp automake pstotext gettext
RUN apt-get install -y postfix
RUN apt-get install -y git unzip wget
RUN pip install nose git+https://bitbucket.org/osso/invenio-devserver.git


###############
# Create user #
###############

RUN useradd --create-home --password docker docker
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ENV HOME /home/docker
USER docker


###################
# Install Invenio #
###################

# Preparing Invenio build folder
RUN git clone -b new-prod https://github.com/inspirehep/ops.git /home/docker/invenio
WORKDIR /home/docker/invenio

# Installing Invenio requirements
RUN sudo pip install -r requirements.txt
#RUN sudo pip install -r requirements-extras.txt

# Building Invenio
RUN aclocal
RUN automake -a
RUN autoconf
RUN ./configure 
RUN make

# Preparing Invenio destination folders
RUN sudo mkdir -p /opt/invenio
RUN sudo chown docker:docker /opt/invenio
RUN sudo ln -s /opt/invenio/lib/python/invenio /usr/local/lib/python2.7/dist-packages/invenio

# Installing Invenio and plugins
RUN make install
RUN make install-jquery-plugins
RUN make install-mathjax-plugin
#RUN make install-jsmath-plugin
#RUN make install-fckeditor-plugin


###########
# Scripts #
###########

ADD services /home/docker/services
RUN sudo chmod +x /home/docker/services

ADD run /home/docker/run
RUN sudo chmod +x /home/docker/run


###########
# Startup #
###########

WORKDIR /home/docker
EXPOSE 4000
CMD ["/home/docker/run", "serve", "-b", "0.0.0.0"]
