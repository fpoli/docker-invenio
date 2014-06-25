FROM debian:wheezy
MAINTAINER Federico Poli "federico.poli@cern.ch"


RUN apt-get update
RUN apt-get install -y sudo git wget


###############
# Create user #
###############

RUN useradd --create-home --password docker docker
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /home/docker
ENV HOME /home/docker
USER docker


#############
# Kickstart #
#############

RUN git clone https://github.com/tiborsimko/invenio-devscripts /home/docker/invenio-devscripts

RUN /home/docker/invenio-devscripts/invenio-kickstart --yes-i-know --yes-i-really-know

###########
# Startup #
###########

ADD run /usr/local/bin/run

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/run"]
CMD ["wait"]
