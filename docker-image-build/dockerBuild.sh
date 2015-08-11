#!/bin/bash
# set -x
##################################################################################
## 
## VERSION		:0.0.1
## DATE			:11Aug2015
##
## USAGE		:This script will help to build images from docker file
##################################################################################

CURR_DIR="/media/sf_dockerRepos/cloudera-On-Docker/docker-image-build"
BUILD_CONTEXT="/media/sf_dockerRepos/cloudera-On-Docker/docker-image-build/hadoop/buildResources"
APP_DIR="/media/sf_dockerRepos/cloudera-On-Docker/docker-image-build/hadoop/"

cd "$APP_DIR"

shopt -s nullglob
dockerFiles=(*-Dockerfile)

# Check if docker is running and then continue if not exit
docker info > /dev/null 2>&1 && printf "\n\t Preparing to build your containers...\n\n" || { printf "\n\t Docker is not running! Ensure Docker is running before running this script\n\n"; exit; }

# Function to build images from DOCKERFILE

function imageBuilder() {
	
	[[ -f "Dockerfile" ]] && rm -f "Dockerfile"
	cd "$APP_DIR"
	cp "$1" "$BUILD_CONTEXT/Dockerfile"
	cd "$BUILD_CONTEXT"
	TAG=$(echo "$1" | cut -d "-" -f1)
	docker build --tag="local/$TAG" . && { printf "\n\t ***************************************************\n";printf "\n\t Successfully built container : $TAG\n\n";printf "\n\t ***************************************************\n";} || printf "\n\t FAILED to build container : $TAG\n\n"
	exit
	}

# Let start building containers
PS3=$'\n\t Choose container management task [Enter] : '
select opt in "${dockerFiles[@]}" "Exit";
do
    if [[ "$opt" != "Exit" ]] ; then
	imageBuilder "${opt}"
    else
		echo -e "\n\t You chose to exit! \n"
        break
    fi
done
