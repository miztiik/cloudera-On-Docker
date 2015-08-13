#!/bin/bash
# set -x
##################################################################################
## 
## VERSION		:0.1.0
## DATE			:11Aug2015
##
## USAGE		:This script will help to start, stop and remove containers. Poor mans version of kitematic
##################################################################################

# Ref	:	http://wiki.bash-hackers.org/syntax/arrays
# declare -A, introduced with Bash 4 to declare an associative array
declare -A sentence

sentence[Begin]='Be liberal in what'
sentence[Middle]='you accept, and conservative'
sentence[End]='in what you send'

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
declare -a quickStartContainers=("hadoopmgrnode" "namenode1" "datanode1" "datanode2" "reponode" "mysql" "httpd" "busybox")
declare -a loadedImages=($(docker images | awk -F ' ' '{print $1":"$2}'| cut -d "/" -f2 | grep -v "REPOSITORY")) 
declare -a runningContainers=($(docker inspect --format '{{.Name}}' $(docker ps -q) | cut -d\/ -f2))
declare -a exitedContaiers=($(docker inspect --format '{{.Name}}' $(docker ps -q -f status=exited) | cut -d\/ -f2 >/dev/null))

declare -a imageList=( "$DOCKER_IMAGES_DIR"/*.tar )
# Trims the prefixes and give only file names
imageList=( "${imageList[@]##*/}" )
# Removes the extensions from the file names
imageList=( "${imageList[@]%.*}" )
	

# Functions to manage the containers
function flushStatus() {	
	# pass assocociative array in string form to function
	e="$( declare -p $1 )"
	eval "declare -A myArr=${e#*=}"
	
	if [[ -n "${myArr[*]}" ]] &> /dev/null; then
		printf "\n\n\t\t Finished processing request for,"
		printf "\n\t\t ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
		for index in "${!myArr[@]}"
		do
			printf "%20d : %s\n" "${index}" "${myArr["${index}"]}"
		done
		printf "\t\t ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
		exit		
	else
	{ printf "\n\t\t Nothing was processed!!\n\n"; exit; }
	fi
	}

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
	[[ -n "${imageList[*]}" ]] || { printf "\n\t There are no images to load!\n\n";exit; }
	cd "$DOCKER_IMAGES_DIR"
	printf "\n\t Choose the images to load :"
	printf "\n\t --------------------------\n"
	for index in ${!imageList[*]}
	do
		printf "%12d : %s\n" $index ${imageList[$index]}
	done
	printf "\t --------------------------\n"
	
	declare -a cIndexes
	
	read -p "	 Choose the images to be loaded (by indexes seperated by spaces) : " -a cIndexes
		
	for index in ${cIndexes[*]}
	do
		printf "\n\n\t\t Starting to load image\t\t: %s" "${imageList[$index]}"
		docker load < "${imageList[$index]}".tar && printf "\n\t\t COMPLETED loading image\t: %s" "${imageList[$index]}" || printf "\n\t\t FAILED to load image\t\t: %s" "${imageList[$index]}"
	done
		
	if [[ -n "${cIndexes[*]}" ]] &> /dev/null; then
		printf "\n\n\t\t Finished processing request for,"
		printf "\n\t\t ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
		for index in ${cIndexes[*]}
		do
			printf "%20d : %s\n" "${index}" "${imageList[$index]}"
		done
		printf "\t\t ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
		exit		
	else
	{ printf "\n\t\t NO images were loaded!!\n\n"; exit; }
	fi
	
	}

function startContainers () {
	printf "\n\t Choose images to start :"
	printf "\n\t --------------------------\n"
	for index in "${!loadedImages[@]}"
	do
		printf "%12d - %s\n" "$index" "${loadedImages[$index]}"
	done
	printf "\t --------------------------\n"
	
	read -p "	Choose the containers to be started (by indexes seperated by spaces) : " -a cIndexes
	
	# Lets check if weave environment variable is set if not set it
	if [[ -z "$DOCKER_HOST" ]] 2>&1 > /dev/null; then
	eval $(weave proxy-env) || { printf "\n\t Not able to set weave proxy, Aborting\n\n"; exit; }
	fi
	
	for index in ${cIndexes[*]}
	do
		echo -e "\n\n Starting container		: ${quickStartContainers[$index]}"
		#${!quickStartContainers[$index]} && echo -e " Successfully started container	: ${quickStartContainers[$index]}" || echo -e " FAILED to start container	: ${quickStartContainers[$index]}"
		true && echo -e " Successfully started container	: ${quickStartContainers[$index]}" || echo -e " FAILED to start container	: ${quickStartContainers[$index]}"
	done
	
	exit 0
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
	[[ -n "${runningContainers[*]}" ]] || { printf "\n\t No containers are in running state!\n\n";exit; }
	printf "\n\t Choose containers to stop :"
	printf "\n\t --------------------------\n"
	for index in "${!runningContainers[@]}"
	do
		printf "%12d : %s\n" "$index" "${runningContainers[$index]}"
	done
	printf "\t --------------------------\n"
	
	read -p "	 Choose the containers to be stopped (by indexes seperated by spaces) : " -a cIndexes
	
	# Create associative array with format <index> <image/container Name>
	# MAINARRAY["$key"]="${TEMPARRAY["$key"]}"
	# or: MAINARRAY+=( ["$key"]="${TEMPARRAY["$key"]}" )
	declare -A cStatus
		
	for index in "${cIndexes[@]}"
	do
		printf "\n\n\t\t Stopping container\t\t: %s" "${runningContainers["$index"]}"
		cStatus["$index"]="${runningContainers["$index"]}"
		docker stop "${runningContainers["$index"]}" &> /dev/null && printf "\n\t\t Successfully stopped container\t: %s\n" "${runningContainers["$index"]}" || printf "\n\t\t FAILED to stop container\t\t: %s" "${runningContainers["$index"]}"
	done

	flushStatus "cStatus" 
}
	
function removeContainers() {
	[[ -n "${exitedContaiers[*]}" ]] || { printf "\n\t There are no containers in exited state!\n\n";exit; }
	#Check if any containers are running(-n for not null) if not exit with a message saying no containers are running
	if [[ -n $(docker ps -a -q -f status=exited) ]] &> /dev/null; then
	docker rm -v $(docker ps -a -q -f status=exited) &> /dev/null && { printf "\n\t REMOVED all exited containers\n\n"; exit; } || { printf "\n\t Not able to remove containers\n\n"; exit; }
	fi
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
