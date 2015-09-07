# Docker container for Hadoop Base Nodes

This docker files shows how to build your own base image for various cloudera components running on Centos6.6

## Docker instructions
* Centos 6.6 - will be used as the base
* Install the necessary packages like wget,sudo, ssh etc
* Configure sudo for password key based login & create hadoop admin uid with keys
* Disable IP Tables, Selinux ( by default selinux is disabled in centos6.6 & *Cloudera doesn't like Selinux as of now* )
* Setup the Cloudera yum repo, import GPG Key
	* Install Java
	* Install core hadoop components
	* Clean up the repos,
	* Start SSHD
* Build the image


### Build your image

Build your image using the dockerfile `docker build --tag="local/hadoopbasenode:latest" .`

### Run as container
* _I recommend running [Weave](https://github.com/weaveworks/weave) before starting this node, as Weave DNS takes care of the Hostname/IP Constraints required by Cloudera & It likes the container to run in privileged mode_
* Below syntax only opens the cms server port, you might want add more ports as you need.

```
docker run -dti --name hadoopbasenode \
				--privileged=true \
				mystique:hadoopbasenode:latest

```
### ROLE ASSIGNMENTS
                       |     namenode1        |     datanode1	     |        datanode2     |        datanode3     |
 ----------------------|----------------------|----------------------|----------------------|----------------------|
         HDFS          |     Namenode         |                      |                      |					   |
         HDFS          |                      |  Secondary Namenode  |                      |                      |
         HDFS          |                      |     Datanode         |      Datanode        |       Datanode       |					  
         HDFS          |                      |  Yarn Node Manager   |  Yarn Node Manager   |  Yarn Node Manager   |
         HDFS          |     History Server   |                      |                      |                      |
                       |     ZooKeeper        |                      |                      |                      |
                       |                      |        Hue           |                      |                      |
                       |                      |                      |        Hive          |                      |
					   
#### Accessing the cluster through GUI
Name Node: `http://<Namenode-hostname>:50070/`
YARN Services: `http://<Yarn-Node-Manager-hostname>:8088/`
Secondary Name Node: `http://<Secondary-Namenode-hostname>:50090/`
Data Node 1: `http://<Datanode[*]-hostname>:50075/`

### Testing your hadoop cluster
```
su - hdfs
hadoop jar /usr/lib/hadoop-0.20-mapreduce/hadoop-examples.jar randomwriter out
```

#### Exposed Ports
The following ports are exposed, [the list is huge](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_ports_cdh5.html). Trying to sort them into my 4 node cluster.
> 22 2181 7180 7182 50010 50075 50020 8020 50070 50090 8032 8030 8031 8033 8088 8888 8040 8042 8041 10020 19888 41370 38319 10000 21050 25000 25010 25020 18080 18081 7077 7078 9000 9001

###### Ports for namenode1
     namenode1        |     External	     |        Internal     |
----------------------|----------------------|---------------------|
Namenode              |      8020            |                     |
Namenode              |      50070           |                     |
JobHistory Server     |      19888           |                     |
JobHistory Server     |                      |          10020      |
JobHistory Server     |                      |          10033      |
ZooKeeper             |      2181            |                     |

###### Ports for datanode1
    datanode1         |     External         |        Internal     |
----------------------|----------------------|---------------------|
Datanode              |      50010           |                     |
Datanode              |      50020           |                     |
Datanode              |      50090           |                     |
Datanode              |      50075           |                     |
Hue                   |      8888            |                     |

###### Ports for datanode2
     datanode2        |     External	     |        Internal     |
----------------------|----------------------|---------------------|
Datanode              |      50010           |                     |
Datanode              |      50020           |                     |
Datanode              |      50090           |                     |
Datanode              |      50075           |                     |
ResourceManager       |      8030            |                     |
ResourceManager       |      8031            |                     |
ResourceManager       |      8032            |                     |
ResourceManager       |      8033            |                     |
ResourceManager       |      8888            |                     |

###### Ports for datanode3
     datanode2        |     External	     |        Internal     |
----------------------|----------------------|---------------------|
Datanode              |      50010           |                     |
Datanode              |      50020           |                     |
Datanode              |      50090           |                     |
Datanode              |      50075           |                     |

##### To Do
- [x] Expose the necessary ports ( there is a whole lot of them ).
- [ ] Probably can add zookeeper client also.
- [ ] Add the basic cluster configuration so all nodes will have the settings and same key
- [ ] Find a way to add vm.swapiness during build, probably echo it into the file?


