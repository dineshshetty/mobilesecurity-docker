# mobilesecurity-docker
WIP Docker Image for Mobile Security Training and Assessments. 


All of the steps were performed on a mac device, but should work fine on linux too.

## Completed Features

* SSH
* VNC
* JAVA
* Android SDK + Platform + other Android tools
* Android Emulator and AVD - ARM
* ADB
* Ability to ADB into Emulator running on base Mac OS
* Drozer v2.4.4
* Apktool v2.4.0
* Simplify
* APKiD
* Kwetza


## Current WIP Feature

* Adding multiple Android Tools


## Sample Build Instructions:

Use the following command to build the docker image with the provided Dockerfile
```
docker-compose build
```

Use the following command to launch the created `mobilesecurity-docker` container with the required port-forwarding
```
docker run --privileged -d -p 2222:22 -p 5901:5901  -p 5555:5555 -p 5554:5554 mobilesecurity-docker:0.1
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

### ADB to Emulator running on host machine OS

- Start Emulator on host machine OS
- Run ``adb devices`` on host machine to find the port on which our Emulator is running
- Run ``adb tcpip 5554``  on host OS
- VNC into the Docker image
- Run ``adb connect docker.for.mac.host.internal`` in the Docker terminal to connect the Emulator running on host OS
- Run ``adb shell`` to gain shell access