#!/bin/bash
# set -x
##################################################################################
## 
## VERSION		:0.0.2
## DATE			:6Aug2015
##
## USAGE		: This script will load images into docker.
##################################################################################


IMAGE_LOCATION=/media/sf_dockerRepos/dockerBckUps
echo -e "\n The current working directory is $IMAGE_LOCATION"

cd $IMAGE_LOCATION
## declare the list of images to load here, use double quote to avoid breaking with whitespace characters
# declare -a imageList=("hadoopBasev2.tar" "hadoop_cloudera_mgr_base_v1.tar" "httpdBase.tar" "weavedns_1.0.1.tar" "weaveexec_1.0.1.tar" "weave_1.0.1.tar" "testing")

declare -a imageList=("clouderamgrnode.tar" "hadoopbasev3.tar" "weavedns.tar" "weaveexec.tar" "weave.tar" "httpdbase.tar" "mysqlbase.tar" "centos66Base.tar")

# Function to load the images, planning to re-use it.
function loadImages () {
	echo -e "\nStarting to load image  : $1"
	docker load < $1 &&	echo "COMPLETED loading image : $1"	|| echo "FAILED loading image : $1. Check the logs"
	}

## now loop through the above array
  
for i in "${imageList[@]}" 
do
	if [ -f $i ]; then
	  loadImages $i
	  else
	  echo "The image '$i' does not exist in $IMAGE_LOCATION"
	fi
done



