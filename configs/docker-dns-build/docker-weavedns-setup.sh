#!/bin/bash
# set -x
##################################################################################
## DNS setup in docker using Weave, Deciced to use weave as it have built in other funcationalities that can be levarage for monitoring.
##
## VERSION		:0.0.1
## DATE			:26Jul2015
##				:Weave uses PORT - 6783 , Use WEAVE_PORT to override
## Ref[1]		:https://github.com/weaveworks/weave#installation
## Ref[2]		:http://docs.weave.works/weave/latest_release/weavedns.html
## Ref[3]		:http://docs.weave.works/weave/latest_release/troubleshooting.html
##################################################################################

function launch_weave () {
	weave launch && weave launch-dns && weave launch-proxy
	eval $(weave proxy-env)
	# weave launch-dns --domain='stellaverse.srv.'
	}

WEAVE_FILE=/usr/local/bin/weave

#check if docker is running, 'pgrep' returns 0, the process is running
DOCKER_SERVICE=docker
if  (pgrep ${DOCKER_SERVICE} )
  then

	if [ -f $WEAVE_FILE ]; then
	   echo "FILE : $WEAVE_FILE Exists, Proceeding to launch weave"
	   launch_weave
	   
	else
	   echo "The file '$WEAVE_FILE' Does Not Exist. Downloading the images and booting them"
	   curl -L git.io/weave -o /usr/local/bin/weave
	   sudo chmod +x /usr/local/bin/weave
	   launch_weave
	fi

  else
	echo "${DOCKER_SERVICE} service is not running!"
fi


