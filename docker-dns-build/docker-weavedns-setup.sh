#!/bin/bash
# set -x
##################################################################################
## DNS setup in docker using Weave, Deciced to use weave as it have built in other funcationalities that can be levarage for monitoring.
##
## VERSION		:0.0.3
## DATE			:22Aug2015
##				:Weave uses PORT - 6783 , Use WEAVE_PORT to override
## Ref[1]		:https://github.com/weaveworks/weave#installation
## Ref[2]		:http://docs.weave.works/weave/latest_release/weavedns.html
## Ref[3]		:http://docs.weave.works/weave/latest_release/troubleshooting.html
##################################################################################

# Set Environment variables here
WEAVE_FILE=/usr/local/bin/weave

# Set the Weave DNS Server subnets & nay private subdomain
# WEAVE_DNSHOST_IP=10.2.254.1/24
# WEAVE_DOMAINS="navcluster.org"

function startWeave() {
	# Lets check if weave environment variable is set if not set it
	if [[ -z "$DOCKER_HOST" ]] 2>&1 > /dev/null; then
		{ weave launch &> /dev/null && weave launch-dns &> /dev/null && weave launch-proxy &> /dev/null && eval $(weave proxy-env) &> /dev/null && printf "\n\n\t Successfully started weave\n\n"; return 0; } \
		|| { printf "\n\n\t Not able to start weave!!"; return 1; }
	fi		 
	}

# check if docker is running, 'pgrep' returns 0, the process is running
# DOCKER_SERVICE=docker

docker info > /dev/null 2>&1 || { printf "\n\tDocker is not running! Ensure Docker is running before running this script\n\n"; exit; }
if [ -f $WEAVE_FILE ]; then
   printf "\n\n\t FILE : $WEAVE_FILE Exists!!, \tProceeding to launch weave"
   startWeave
else
   printf "\n\n\t The file '$WEAVE_FILE' Does Not Exist. Downloading the images and booting them"
   curl -L git.io/weave -o /usr/local/bin/weave
   sudo chmod +x /usr/local/bin/weave
   startWeave
fi
