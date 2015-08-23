##################################################################################
## 
## VERSION		:0.0.9
## DATE			:24Aug2015
##
## DESCRIPTION	:"This image installs ssh, updates centos6.6 and basic hadoop components daemon on base centos:6.6 image" Vendor="Miztiik Corp" Version="1.0"
##
## Ref [1]	:	https://docs.docker.com/examples/running_ssh_service/
## Ref [2]	:	https://registry.hub.docker.com/u/sequenceiq/hadoop-docker/dockerfile/
##
##################################################################################
FROM centos:6.6
MAINTAINER mystique <miztiik@gmail.com>

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

# Set sshd to start by default & Disable ip tables
RUN chkconfig sshd on && chkconfig iptables off

# Generates keys on the first run
RUN mkdir /var/run/sshd && /etc/init.d/sshd start

# Create an user and set it to sudo to root without password
RUN useradd hadoopadmin -G wheel -d /home/hadoopadmin -s /bin/bash
RUN echo 'hadoopadmin:tcuser' | chpasswd
RUN echo '%wheel ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

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
