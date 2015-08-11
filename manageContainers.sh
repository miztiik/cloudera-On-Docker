#!/bin/bash
# set -x
##################################################################################
## 
## VERSION		:0.1.0
## DATE			:11Aug2015
##
## USAGE		:This script will help to start, stop and remove containers. Poor mans version of kitematic
##################################################################################

hadoopmgrnode="docker run -dti \
--name hadoopmgrnode \
-p 32768:22 \
-p 7180:7180 \
--privileged=true \
-v /media/sf_dockerRepos:/media/sf_dockerRepos \
local/clouderamgrnode:v1 /usr/sbin/sshd -D"

namenode1="docker run -dti \
--name namenode1 \
-p 32769:22 \
--privileged=true \
-v /media/sf_dockerRepos:/media/sf_dockerRepos \
local/hadoopbase:v3 /usr/sbin/sshd -D"

datanode1="docker run -dti \
--name datanode1 \
-p 32770:22 \
--privileged=true \
-v /media/sf_dockerRepos:/media/sf_dockerRepos \
local/hadoopbase:v3 /usr/sbin/sshd -D"

datanode2="docker run -dti \
--name datanode2 \
-p 32771:22 \
--privileged=true \
-v /media/sf_dockerRepos:/media/sf_dockerRepos \
local/hadoopbase:v3 /usr/sbin/sshd -D"

reponode="docker run -dti \
--name reponode \
-p 2891:80 \
-v /media/sf_dockerRepos:/media/sf_dockerRepos \
centos:6.6 /bin/bash"

# Function Manipulation
#	${arr[*]}         # All of the items in the array
#	${!arr[*]}        # All of the indexes in the array
#	${#arr[*]}        # Number of items in the array
#	${#arr[0]}        # Length of item zero

docker info > /dev/null 2>&1 && printf "\n\t Preparing the menu...\n\n" || { printf "\n\tDocker is not running! Ensure Docker is running before running this script\n\n"; exit; }

# Global variables
DOCKER_IMAGES_DIR=/media/sf_dockerRepos/dockerBckUps

shopt -s nullglob
declare -a puppetOptions=("Load Containers" "Start Containers" "Restart Exited Containers" "Stop Containers" "Remove Containers" "Stop And Remove Containers" "Exit")
#declare -a imageList=("hadoopmgrnode" "namenode1" "datanode1" "datanode2" "reponode" "mysql" "httpd" "busybox" "Exit")
declare -a runningContainers=("$(docker inspect --format '{{.Name}}' $(docker ps -q) | cut -d\/ -f2)")
declare -a exitedContaiers=("$(docker inspect --format '{{.Name}}' $(docker ps -q -f status=exited) | cut -d\/ -f2)")

declare -a imageList=( "$DOCKER_IMAGES_DIR"/*.tar )
# Trims the prefixes and give only file names
imageList=( "${imageList[@]##*/}" )
# Removes the extensions from the file names
imageList=( "${imageList[@]%.*}" )
	

# Functions to manage the containers
function manageContainers () {
	#Check if any arguments are passed
	if [ "$#" -eq 0 ]; then
		echo "You didn't choose any options"		
		return 1
	fi
	if [ "$1" == "Load Containers" ]; then
		loadContainers
		elif [ "$1" == "Start Containers" ]; then
		startContainers
		elif [ "$1" == "Restart Exited Containers" ]; then
		startExitedContainers
		elif [ "$1" == "Stop Containers" ]; then
		stopContainers
		elif [ "$1" == "Remove Containers" ]; then
		removeContainers
		elif [ "$1" == "Stop And Remove Containers" ]; then
		stop_removeContainers
		elif [ "$1" == "Exit" ]; then
		return 0
	fi
	}

	function loadContainers () {
	cd "$DOCKER_IMAGES_DIR"
	printf "\n\t Choose the images to load :"
	printf "\n\t --------------------------\n"
	for index in ${!imageList[*]}
	do
		printf "%12d : %s\n" $index ${imageList[$index]}
	done
	printf "\t --------------------------\n"
	
	read -p "	Choose the images to be loaded (by indexes seperated by spaces) : " -a cIndexes
	
	for index in ${cIndexes[*]}
	do
		printf "\n\n\t Starting to load image	: %s" ${imageList[$index]}
		docker load < "${imageList[$index]}".tar && printf "\n\t COMPLETED loading image	: %s" ${imageList[$index]} || printf "\n\t FAILED to load image	: %s" ${imageList[$index]}
	done
	
	printf "\n\n\t Starting to load image	: %s" ${imageList[cIndexes[*]}
	
	exit 0
	
	}
	
function startContainers () {
	printf "\n\t Choose containers to start :"
	printf "\n\t --------------------------\n"
	for index in ${!imageList[*]}
	do
		printf "%12d : %s\n" $index ${imageList[$index]}
	done
	printf "\t --------------------------\n"
	
	read -p "	Choose the containers to be started (by indexes seperated by spaces) : " -a cIndexes
	
	# Lets check if weave environment variable is set if not set it
	if [[ -z "$DOCKER_HOST" ]] 2>&1 > /dev/null; then
	eval $(weave proxy-env) || return 1
	fi
	
	for index in ${cIndexes[*]}
	do
		echo -e "\n\n Starting container		: ${imageList[$index]}"
		${!imageList[$index]} && echo -e " Successfully started container	: ${imageList[$index]}" || echo -e " FAILED to start container	: ${imageList[$index]}"
	done
	
	return 0
}

function startExitedContainers() {
	printf "\n\t Choose containers to start :"
	printf "\n\t --------------------------\n"
	for index in ${!exitedContaiers[*]}
	do
		printf "%12d : %s\n" $index ${exitedContaiers[$index]}
	done
	printf "\t --------------------------\n"
	
	read -p "	Choose the containers to be started (by indexes seperated by spaces) : " -a cIndexes
	
	# Lets check if weave environment variable is set if not set it
	if [[ -z "$DOCKER_HOST" ]] 2>&1 > /dev/null; then
	eval $(weave proxy-env) || return 1
	fi
	
	for index in ${cIndexes[*]}
	do
		echo -e "\n\n Starting container		: ${exitedContaiers[$index]}"
		${!exitedContaiers[$index]} && echo -e " Successfully started container	: ${exitedContaiers[$index]}" || echo -e " FAILED to start container	: ${exitedContaiers[$index]}"
	done
	
	return 0
	}

function stopContainers () {
	printf "\n\t Choose containers to stop :"
	printf "\n\t --------------------------\n"
	for index in ${!runningContainers[*]}
	do
		printf "%12d : %s\n" $index ${runningContainers[$index]}
	done
	printf "\t --------------------------\n"
	
	read -p "	Choose the containers to be stopped (by indexes seperated by spaces) : " -a cIndexes
	
	for index in ${cIndexes[*]}
	do
		echo -e "\n\n Stopping container		: ${runningContainers[$index]}"
		docker stop ${runningContainers[$index]} && echo -e " Successfully stopped container	: ${runningContainers[$index]}" || echo -e " FAILED to stop container	: ${runningContainers[$index]}"
	done

	return 0
	}
	

	
function removeContainers() {
	docker rm -v $(docker ps -a -q -f status=exited)
	}


PS3=$'\n\t Choose container management task [Enter] : '
select opt in "${puppetOptions[@]}";
do
    if [[ "$opt" != "Exit" ]] ; then
	manageContainers "$opt"
    else
		echo -e "\n\t You chose to exit! \n"
        break
    fi
done
