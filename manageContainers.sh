#!/bin/bash
# set -x
##################################################################################
## 
## VERSION		:0.0.2
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

# Functions to manage the containers
declare -a puppetOptions=("Start Containers" "Stop Containers" "Remove Containers" "Stop And Remove Containers" "Exit")
declare -a imageList=("hadoopmgrnode" "namenode1" "datanode1" "datanode2" "reponode" "mysql" "httpd" "busybox" "Exit")

function manageContainers () {
	#Check if any arguments are passed
	if [ "$#" -eq 0 ]; then
		echo "You didn't choose any options"		
		return 1
	fi
	if [ "$1" == "Start Containers" ]; then
		startContainers
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

function stopContainers () {
	declare -a runningContainers=($(docker inspect --format '{{.Name}}' $(docker ps -q) | cut -d\/ -f2))
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


PS3=$'\n\t Choose container management task [Enter] : '
select opt in "${puppetOptions[@]}";
do
    if [[ $opt != "Exit" ]] ; then
	manageContainers "$opt"
    else
		echo -e "\n\t You chose to exit! \n"
        break
    fi
done
