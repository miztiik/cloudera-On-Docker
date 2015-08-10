#!/bin/bash
# set -x
##################################################################################
## 
## VERSION		:0.0.1
## DATE			:09Aug2015
##
## USAGE		: This script enable docker 1.7.1 to use etc/sysconfig/ for additional options as they are not given by default
##################################################################################
mkdir /etc/systemd/system/docker.service.d

cat > /etc/systemd/system/docker.service.d/docker-options.conf << EOF

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
