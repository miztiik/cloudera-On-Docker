<!--[metadata]>
+++
draft = false
+++
<![end-metadata]-->

# Setting up GUI Apps in Docker

This docker files show how to build a application that needs GUI within docker. Inspired by this [article](http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/).

## Setup up the container
* Centos 6.6 - will be used as the based
* Install the necessary packages like wget,libssl, unzip etc
* Install and setup uTorrent
* Configure the ports required

### Build your image
Build your image using the dockerfile `docker build --tag="local/rotnode:v1" .`

### Run as container
`docker run -dti --name rotnode -p 28920:2891 -p 28921:8080 -v /media/sf_dockerRepos:/media/sf_dockerRepos local/rotnode:v1 /bin/bash`


