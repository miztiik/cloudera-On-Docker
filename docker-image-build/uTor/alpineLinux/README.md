# Container to run uTorrent in Alpine Linux

This docker files show how to build a super lightweight docker container to run uTorrent in Alipine Linux with mounted volumes for data storage.

## Docker instructions
* Use the latest [Alpine Linux](https://hub.docker.com/_/alpine/) image
* Install the necessary packages like curl wget tar libgcc openssl etc
* Install glibc (_Alpine Linux uses musl_) needed to run utServer
* Install and setup utServer (optional, you can have the utServer mounted as external volume)
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

Build your image using the dockerfile `docker build --tag="mystique/alpine-rot:latest" .`
> Note the dot in the end, to represent the current directory holds the dockerfile


### Run as container

You can run the container with default settings or with your own custom configuration file. In default mode the downloads will be stored in virtualbox shared folders under `/media/sf_dockerRepos/dockerTmp/utorrent/`.
If you have a custom configuration, say `utserver.conf`, you can add it as a data volume during docker run.

##### Default settings 
```
docker run -dti --name rotnode \
	            -p 28920:2891 \
	            -p 28921:8085 \
	            -v <Remote-torrent-directory>:<torrent-directory-inContainer> \ 
	            mystique/alpine-rot:latest
```

##### Custom settings
The relevant custom configurations for directory location are in `utserver.conf`, The full config template can be found [here](https://gist.github.com/miztiik/004d75d07e64e2b16edd), 
```
dir_active: 
dir_completed: 
dir_torrent_files: 
dir_temp_files: 
dir_autoload: 
```

or You can use mine [here](https://github.com/miztiik/cloudera-On-Docker/blob/master/docker-image-build/uTor/centos/utserver.conf) and just the edit the bits for directories, If you are happy with your settings you can start your container as shown below,
```
docker run -dti --name rotnode \
	            -p 28920:2891 \
	            -p 28921:8085 \
	            -v utserver.conf:/opt/utorrent/utserver.conf \
	            -v <Remote-torrent-directory>:<torrent-directory-inContainer> \ 
	            mystique/alpine-rot:latest
```

##### Accessing the GUI
Connect to gui `http://<docker-host-ip>:28921/gui `, user name: `admin` and pass: `''`

