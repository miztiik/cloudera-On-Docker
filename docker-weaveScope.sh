#!/bin/bash
set -x
##################################################################################
## 
##
## VERSION		:	0.0.1
## DATE			:	31Aug2015
## DESCRIPTION	:	Weave Scope installation script
## Ref[1]		:	https://github.com/weaveworks/scope
##################################################################################

# Set Environment variables here
SCOPE_FILE=/usr/local/bin/scope

function startScope() {
	scope launch && \
	{ printf "\n\n\t\t Started Weave Successfully!!!\n\n"; printf "\n\n\t\t Open your web browser to http://localhost:4040 to use weave scope\n\n"; } || \
	{ printf "\n\n\t Not able to start weave!!"; return 1; }	 
	}

# check if docker is running
docker info > /dev/null 2>&1 || { printf "\n\tDocker is not running! Ensure Docker is running before running this script\n\n"; exit; }

if [ -f $SCOPE_FILE ]; then
   printf "\n\n\t FILE : $SCOPE_FILE Exists!!, \tProceeding to launch Weave Scope"
   startScope
else
   printf "\n\n\t The file '$SCOPE_FILE' Does Not Exist. Downloading the images and starting them\n\n"
   curl -L https://github.com/weaveworks/scope/releases/download/latest_release/scope -o /usr/local/bin/scope && \
   chmod a+x /usr/local/bin/scope && \
   startScope
fi
