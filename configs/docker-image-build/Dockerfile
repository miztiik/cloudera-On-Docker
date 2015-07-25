## hadoop base  setup docker file
##
## VERSION		:0.0.4
## DATE			:22Jul2015

# FROM centos:6.6
FROM local/hadoopbase:v1
MAINTAINER mystique <b4wt@quantumfoam.uni.me>


# LABEL Description="This image installs ssh daemon on base centos:6.6 image" Vendor="Miztiik Corp" Version="1.0"


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
RUN yum install -y epel-release \
yum-presto \
passwd \
openssh openssh-server \
openssh-clients \
which \
tar \
rsync \
sudo

RUN yum clean all

# Disable ip tables & selinux
# RUN chkconfig iptables off; setenforce 0
RUN chkconfig iptables off

# Need to setup /etc/hosts files for local resolving - Need to figure how to connect docker ips internally without using static ips

RUN mkdir /var/run/sshd

# Generates keys on the first run
RUN  /etc/init.d/sshd start

RUN useradd hadoopadmin -G wheel
RUN echo 'hadoopadmin:tcuser' | chpasswd
RUN echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

# Set up SSH passwordless ssh ( First time start up of sshd will create these keys)
# RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
# RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
# RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
# RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

RUN mkdir -p /home/hadoopadmin/.ssh
ADD authorized_keys /home/hadoopadmin/.ssh/
RUN chmod 600 /home/hadoopadmin/.ssh/authorized_keys; chmod 700 /home/hadoopadmin/.ssh
RUN chown -R hadoopadmin:hadoopadmin /home/hadoopadmin/.ssh

# Set up SSHD config
RUN sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Setting up password less authentication
RUN sed -ri "s/#   PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

# Change the value to no; this will prevent the question when connecting with SSH to the host.
RUN sed -ri "s/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/" /etc/ssh/ssh_config
# echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# private and public mapping
# Usage of EXPOSE is deprecated and recommended to use -p during run
# EXPOSE 22:32768

# Start the SSH daemon
CMD ["/usr/sbin/sshd", "-D"]

