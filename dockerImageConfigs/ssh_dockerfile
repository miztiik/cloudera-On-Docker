# ssh
#
# VERSION               0.0.1

# FROM centos:6.6
FROM centos/centos:6.6
MAINTAINER mystique <b4wt@quantumfoam.uni.me>

# LABEL Description="This image installs ssh daemon on base centos:6.6 image" Vendor="Miztiik Corp" Version="1.0"

# Source from : https://docs.docker.com/examples/running_ssh_service/

# Lets install the necessary binaries
RUN yum install -y epel-release \
yum-presto \
passwd \
openssh openssh-server \
openssh-clients \
sudo

RUN yum clean all

RUN mkdir /var/run/sshd

# Generates keys on the first run
RUN  /etc/init.d/sshd start

RUN useradd hadoopadmin -G wheel
RUN echo 'hadoopadmin:tcuser' | chpasswd
RUN echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

# Set up SSH
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

