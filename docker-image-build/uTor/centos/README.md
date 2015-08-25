# Setting up GUI Apps in Docker

This docker files show how to build a application that needs GUI within docker. Inspired by this [article](http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/).

## Docker instructions
* Centos 6.6 - will be used as the based
* Install the necessary packages like wget,libssl, unzip etc
* Install and setup uTorrent
* Setup the file with additional configuration
	* All custom configuration goes into this file
		* Download directory
		* Torrent directory
		* Download, Upload Speeds & limits
		* WebGUI Port
		* uTorrent Client port
		* Max connections, DHT, Peer Exchange etc.,
* Build the image

### Build your image
Build your image using the dockerfile `docker build --tag="local/rotnode:v1" .`

### Run as container
You can run the container with default settings or with your own custom configuration file. In default mode the downloads will be stored in virtualbox shared folders under `/media/sf_dockerRepos/dockerTmp/utorrent/`.
If you have a custom configuration, say `utserver.conf`, you can add it as a data volume during docker run.

#### Default settings 
```
	docker run -dti --name rotnode \
	-p 28920:2891 \
	-p 28921:8085 \
	-v /media/sf_dockerRepos:/media/sf_dockerRepos \
	local/rotnode:v1 /bin/bash
```
#### Custom settings

```
	docker run -dti --name rotnode \
	-p 28920:2891 \
	-p 28921:8085 \
	-v utserver.conf:/opt/utorrent/utserver.conf \
	-v /media/sf_dockerRepos:/media/sf_dockerRepos \ 
	local/rotnode:v1 /bin/bash
```


