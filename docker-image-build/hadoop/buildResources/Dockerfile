## hadoop base  setup docker file
##
## VERSION		:0.0.7
## DATE			:17Aug2015
## "This image installs ssh daemon on base centos:6.6 image" Vendor="Miztiik Corp" Version="1.0"
FROM centos:6.6
MAINTAINER mystique <miztiik@gmail.com>

# Ref [1]	:	https://docs.docker.com/examples/running_ssh_service/
# Ref [2]	:	https://registry.hub.docker.com/u/sequenceiq/hadoop-docker/dockerfile/

# Setup yum to use caching in the shared folder to allow it to be reused by multiple systems, number of copies to 3
RUN sed -ri 's/keepcache=0/keepcache=1/g' /etc/yum.conf
RUN sed -ri 's/installonly_limit=5/installonly_limit=3/g' /etc/yum.conf

# Enable the fastest mirror
RUN sed -ri 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf

# Have to really escape the special chracters will back slashes, probably should find a neater way of doing this, (laterz..)
RUN sed -ri 's/cachedir=\/var\/cache\/yum\/\$basearch\/\$releasever/cachedir=\/media\/sf_dockerRepos\/dockerTmp\/yum\/\$basearch\/\$releasever/g' /etc/yum.conf

# Lets install the necessary binaries
RUN yum -y install epel-release \
yum-presto \
passwd \
openssh openssh-server \
openssh-clients \
which \
tar \
wget \
rsync \
sudo

RUN yum -y update && yum clean all

# Lets install java in the base
# This is bloating the docker image, until i find a elegant way to do this, will do this manually.
# RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie' && yum -y install jdk-8u45-linux-x64.rpm && yum clean all

# Set sshd to start by default & Disable ip tables
RUN chkconfig sshd on && chkconfig iptables off

# Need to setup /etc/hosts files for local resolving - Need to figure how to connect docker ips internally without using static ips

RUN mkdir /var/run/sshd

# Generates keys on the first run
RUN  /etc/init.d/sshd start

RUN useradd hadoopadmin -G wheel -d /home/hadoopadmin -s /bin/bash
RUN echo 'hadoopadmin:tcuser' | chpasswd
RUN echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

# Set up SSH passwordless ssh ( First time start up of sshd will create these keys)
RUN mkdir /home/hadoopadmin/.ssh
RUN ssh-keygen -q -N "" -t rsa -f /home/hadoopadmin/.ssh/id_rsa
RUN cp /home/hadoopadmin/.ssh/id_rsa.pub /home/hadoopadmin/.ssh/authorized_keys
RUN chmod 600 /home/hadoopadmin/.ssh/authorized_keys; chmod 700 /home/hadoopadmin/.ssh
RUN chown -R hadoopadmin:hadoopadmin /home/hadoopadmin/.ssh && exit


# Set up SSHD config
RUN sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Setting up password less authentication
RUN sed -ri "s/#   PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

# Change the value to no; this will prevent the question when connecting with SSH to the host.
RUN sed -ri "s/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/" /etc/ssh/ssh_config
# echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# the nameserver priority & might not be required when using weave
RUN sed -i s/"files dns"/"dns files"/ /etc/nsswitch.conf

# Expose the private port for mapping
EXPOSE 22

# Start the SSH daemon
CMD [ "/usr/sbin/sshd", "-D" ]
