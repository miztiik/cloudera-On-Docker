#!/bin/bash
set -x
##################################################################################
## Hadoop Manager Node Start Script
##
## VERSION		:0.0.1
## DATE			:23Jul2015
##################################################################################


# Probably will use them in the future
# docker & network settings
DOCKER_IMAGE_NAME="local/hadoop_cloudera_mgr_base:v1"                 	# build of nginx-php - for example
DOCKER_CONTAINERS_NAME="hadoopmgrnode"                  				# our container's name
DOCKER_CONTAINERS_HOSTNAME="hadoopmgrnode"
 # DOCKER_NETWORK_INTERFACE_NAME="eth0:1"                  				# default we have eth0 (or p2p1), so interface will eth0:1 or p2p1:1
# DOCKER_NETWORK_INTERFACE_IP="192.168.56.86"                  			# network interface address
DOCKER_NETWORK_INTERFACE_IP="0.0.0.0"                  			# network interface address

# try to find created this network interface
# found_iface=$(ifconfig | grep "$DOCKER_NETWORK_INTERFACE_NAME")
# if [ -z "$found_iface" ]; then
#   # create & start some another network interface for docker container
#   sudo ifconfig $DOCKER_NETWORK_INTERFACE_NAME $DOCKER_NETWORK_INTERFACE_IP netmask 255.255.255.0 up
# else
#   echo "$DOCKER_NETWORK_INTERFACE_NAME with ip $DOCKER_NETWORK_INTERFACE_IP alredy exists";
# fi

# start conteiner if "docker some_image run" earlier
found_container=$(docker ps -a | grep "$DOCKER_CONTAINERS_NAME")
if [ ! -z "$found_container" ]; then
  sudo docker start "$DOCKER_CONTAINERS_NAME"
else
  # start docker container to created network interface
  sudo docker run -ti -h $DOCKER_CONTAINERS_HOSTNAME \
--name "$DOCKER_CONTAINERS_NAME" \
-p $DOCKER_NETWORK_INTERFACE_IP:32768:22 \
-p $DOCKER_NETWORK_INTERFACE_IP:7180:7180 \
--privileged=true \
-v /media/sf_dockerRepos:/media/sf_dockerRepos \
$DOCKER_IMAGE_NAME /bin/bash
fi

# also you can manually remove created virtual network interface
# ifconfig $DOCKER_NETWORK_INTERFACE_NAME down