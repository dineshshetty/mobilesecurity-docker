# Download base image ubuntu 18.04 LTS
FROM ubuntu:18.04
LABEL MAINTAINER Dinesh Shetty <dinezh.shetty@gmail.com>

# Setup variables
ENV VNCPASSWORD "Dinesh@123!"
ENV SSHPASS "Dinesh@123!"

# Software Versions
ENV ANDROID_SDK_VERSION "4333796"
ENV ANDROID_BUILD_TOOLS_VERSION "28.0.3"


# Update Ubuntu Software repository
RUN apt-get update

# Install Java
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:webupd8team/java -y
#RUN apt-get install -y debconf-utils
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
RUN apt-get install -y oracle-java8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


# Install network tools for ipconfig
RUN apt-get install -y net-tools

# Installing some required softwares
RUN apt-get install -y unzip wget tar

# Install and configure supervisor
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

RUN echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf
RUN echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "" >> /etc/supervisor/conf.d/supervisord.conf

#setup SSH for supervisor
EXPOSE 22
RUN apt-get install -y openssh-server
RUN apt-get install -y ssh
RUN mkdir /var/run/sshd

RUN echo "root:$SSHPASS" | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "X11UseLocalhost no" >> /etc/ssh/sshd_config
RUN echo "X11Forwarding yes" >> /etc/ssh/sshd_config

RUN echo "[program:sshd]" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "command=/usr/sbin/sshd -D" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "" >> /etc/supervisor/conf.d/supervisord.conf

# Setup VNC for supervisor
EXPOSE 5901
RUN mkdir -p /root/.vnc
RUN apt-get install -y x11vnc
RUN apt-get install -y xfce4 
RUN apt-get install -y xvfb 
RUN apt-get install -y xfce4-terminal
RUN apt-get install -y vnc4server
RUN x11vnc -storepasswd $VNCPASSWORD /root/.vnc/passwd
RUN chmod 600 /root/.vnc/passwd

RUN echo '#!/bin/bash' >> /root/.vnc/newvnclauncher.sh
RUN echo "/usr/bin/vncserver :1 -name vnc -geometry 800x640" >> /root/.vnc/newvnclauncher.sh
RUN chmod +x /root/.vnc/newvnclauncher.sh

RUN echo "[program:vncserver]" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "command=/bin/bash /root/.vnc/newvnclauncher.sh" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "" >> /etc/supervisor/conf.d/supervisord.conf

# Create a folder to store all the tools in
RUN mkdir -p /tools


# Install and Setup Android SDK
#Downloading SDK https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip

RUN wget -qO /tools/sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_SDK_VERSION.zip
RUN unzip -q /tools/sdk-tools.zip -d /tools/android-sdk-linux
RUN mv /tools/android-sdk-linux /tools/android-sdk
RUN chown -R root:root /tools/android-sdk/
RUN rm -f /tools/sdk-tools.zip

# Setup Android Environment variables
ENV ANDROID_HOME /tools/android-sdk
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools


# Handle "Warning: File /root/.android/repositories.cfg could not be loaded" error
RUN mkdir -p /root/.android && \
    touch /root/.android/repositories.cfg


# Update the Android SDK
RUN /tools/android-sdk/tools/bin/sdkmanager --update


# Install required Android tools (you can choose more from sdkmanager --list)
# Include echo 'y' | to accept license
RUN yes | /tools/android-sdk/tools/bin/sdkmanager --licenses
RUN echo 'y' | /tools/android-sdk/tools/bin/sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION"
RUN echo 'y' | /tools/android-sdk/tools/bin/sdkmanager "emulator" "platform-tools" "tools"  

# Enable only if required
# RUN /tools/android-sdk/tools/bin/sdkmanager "ndk-bundle" "extras;google;google_play_services" \
# "extras;android;m2repository" "extras;google;m2repository"

# Setup SDK for running Android API 28
RUN echo 'y' | /tools/android-sdk/tools/bin/sdkmanager "sources;android-28" \
	"system-images;android-28;google_apis;x86"

# Enable only if required
# RUN echo 'y' | /tools/android-sdk/tools/bin/sdkmanager "system-images;android-28;google_apis;x86_64"

# Setup workdirectory
RUN mkdir -p /workdirectory
WORKDIR /workdirectory

CMD [ "/usr/bin/supervisord", "-c",  "/etc/supervisor/conf.d/supervisord.conf" ]

# Additional Clean-up
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean
RUN apt-get autoremove
RUN apt-get autoclean