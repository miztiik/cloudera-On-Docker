## Docker container for Cloudera Manager Server

This docker file shows how to build your own CMS in Centos6.6

### Docker instructions
* Centos 6.6 - will be used as the base
* Install the necessary packages like wget,sudo, ssh etc
* Configure sudo for password key based login & create hadoop admin uid with keys
* Disable IP Tables, Selinux ( by default selinux is disabled in centos6.6 & *Cloudera doesn't like Selinux as of now* )
* Setup the Cloudera yum repo, import GPG Key
	* Install Java
	* Install CMS Server, Agents, Daemons
	* Clean up the repos,
	* Set the VM.Swapiness to cloudera recommendation - _Moved to start up script - Design/Security Issue - [Refer here](https://github.com/docker/docker/issues/5703)_ 
	* Start the CMS Database - It configures itself using `initialize_embedded_db.sh` and populates `/etc/cloudera-scm-server/db.properties`
		* The default postgres DB should be configurable if you pass on the necessary conf file and then start the DB
	* Expose the necessary ports ( there is a whole lot of them )
	* Start SSHD
* Build the image

The cloudera manager gui is configured with the default uid `admin` and password `admin`.

Known Issues:

> Cloudera does not like hyphen "-" in hostnames, some times it breaks during managed installations.

### Build your image

Build your image using the dockerfile `docker build --tag="local/clouderaMgrNode:v1" .`

### Run as container
* _I recommend running weave before starting this node, as Weave DNS takes care of the Hostname/IP Constraints required by Cloudera & It likes the container to run in privileged mode_
* Below syntax only opens the cms server port, you might want add more ports as you need.

```
docker run -dti --name clouderaMgrNode \
				-p 7180:7180 \
				--privileged=true \
				mystique:clouderamgrnode:latest

```
##### Connect to the Cloudera Manager gui

You can access the gui here - `http://<your-clouderaMgrNode-container-ip>:7180/`

##### To Do
* Check if the services can be started during build itself or make them start from chkconfig is a better idea?
	* Usually CMS server takes a while to start.
* It is possible to seperate the docker cms layer seperately and ship them leave the OS bits and attach volume containers for logs?


