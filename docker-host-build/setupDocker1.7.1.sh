#!/bin/bash
set -x
##################################################################################
## 
## VERSION		:0.0.2
## DATE			:12Aug2015
##
## USAGE		: This script enable docker 1.7.1 to use etc/sysconfig/ for additional options as they are not given by default
##################################################################################

systemctl stop docker

mkdir /etc/systemd/system/docker.service.d

rm -rf /etc/systemd/system/docker.service.d/docker-options.conf

cat > /etc/systemd/system/docker.service.d/docker-options.conf << "EOF"

[Service]
EnvironmentFile=-/etc/sysconfig/docker
EnvironmentFile=-/etc/sysconfig/docker-storage
EnvironmentFile=-/etc/sysconfig/docker-network
ExecStart=
ExecStart=/usr/bin/docker -d -H fd:// $OPTIONS \
      $DOCKER_STORAGE_OPTIONS \
      $DOCKER_NETWORK_OPTIONS \
      $BLOCK_REGISTRY \
      $INSECURE_REGISTRY
	  
EOF

# Set the temp directory
printf "DOCKER_TMPDIR=/media/sf_dockerRepos/dockerTmp\n" >> /etc/sysconfig/docker

# Set the ip tables on host for weave to work with ICMP
iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited

# Reload configs and start docker
systemctl daemon-reload
systemctl start docker && \
{ printf "\n\t ***************************************************\n"; \
printf "\n\t Successfully started docker\n\n"; \
printf "\n\t ***************************************************\n";} \
|| printf "\n\t FAILED to start docker, check out 'systemctl status docker -l'\n\n"

