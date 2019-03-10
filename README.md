# mobilesecurity-docker
WIP Docker Image for Mobile Security Training and Assessments. 


All of the steps were performed on a mac device, but should work fine on linux too.

## Completed Features

* SSH
* VNC
* JAVA
* Android SDK


## Current WIP Feature

* Android Emulator


## Sample Build Instructions:

Use the following command to build the docker image with the provided Dockerfile
```
docker-compose build
```

Use the following command to launch the created `mobilesecurity-docker` container with the required port-forwarding
```
docker run --privileged -d -p 2222:22 -p 5901:5901 mobilesecurity-docker:0.1 
```

You can use the following command to make sure that the docker container is in-fact running as expected
```
docker ps
```


## Usage Instructions:

### SSH Access:
Use the following command to SSH into the running container
```
ssh -X -p 2222 root@127.0.0.1
```
The default SSH password is ```Dinesh@123!```

### VNC Access:
On a mac device, I use REALVNC to connect to this container over port 5901. The default VNC password is ```Dinesh@123!```
