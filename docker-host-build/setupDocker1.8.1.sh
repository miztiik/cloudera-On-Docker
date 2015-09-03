#!/bin/bash
# set -x
##################################################################################
## 
## VERSION		:0.0.3
## DATE			:24Aug2015
##
## USAGE		:This script enable docker 1.8.1 to use etc/sysconfig/ for additional options as they are not given by default
## Ref[1]		:https://docs.docker.com/articles/configuring/
## Ref[2]		:https://docs.docker.com/articles/systemd/
## Ref[2]		:https://docs.docker.com/reference/commandline/daemon/
##################################################################################

# Install the latest version of docker
curl -sSL https://get.docker.com/ | sh

# Stop docker to setup temporary folder
systemctl stop docker

mkdir /etc/systemd/system/docker.service.d

rm -rf /etc/systemd/system/docker.service.d/docker-options.conf

cat > /etc/systemd/system/docker.service.d/docker-options.conf << "EOF"

[Service]
Type=notify
EnvironmentFile=-/etc/sysconfig/docker
EnvironmentFile=-/etc/sysconfig/docker-storage
EnvironmentFile=-/etc/sysconfig/docker-network
ExecStart=
ExecStart=/usr/bin/docker -d -H fd:// \
	  $OPTIONS \
      $DOCKER_STORAGE_OPTIONS \
      $DOCKER_NETWORK_OPTIONS \
      $BLOCK_REGISTRY \
      $INSECURE_REGISTRY
	  
EOF

# Setup docker selinux to allow it to setup bridge
# https://github.com/docker/docker/issues/15498
yum -y install docker-selinux

# Set the temp directory & different location for images
printf "DOCKER_TMPDIR=/media/sf_dockerRepos/dockerTmp\n" >> /etc/sysconfig/docker

# Set the ip tables on host for weave to work with ICMP
iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2> /dev/null
iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited 2> /dev/null

# Reload configs and start docker
systemctl daemon-reload
systemctl start docker && \
	{ 	
		printf "\n\n\t ***************************************************"; \
		printf "\n\n\t\t Successfully started docker"; \
		printf "\n\n\t ***************************************************\n";
	} \
	|| printf "\n\n\t FAILED to start docker, check out 'systemctl status docker -l'\n\n"

