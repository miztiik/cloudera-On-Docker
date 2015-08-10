#!/bin/bash
# set -x

PS3='Choose container to start : '

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

# Function to start the containers.
function startContainer () {
	echo -e "\n\n Starting container		:  $1"
	${!1} && echo -e "\nSuccessfully started container	: $opt" || echo -e "\n FAILED to start container	: $opt"
	return 0
	}

declare -a imageList=("hadoopmgrnode" "namenode1" "datanode1" "datanode2" "reponode")

select opt in "${imageList[@]}" "Quit" ;
do
    if [[ $opt != "Quit" ]] ; then
		startContainer $opt		
    else
		echo -e "\n You chose to exit! \n"
        break
    fi
done
