# Download base image ubuntu 18.04 LTS
FROM ubuntu:18.04
LABEL MAINTAINER Dinesh Shetty <dinezh.shetty@gmail.com>

# Setup variables
ENV VNCPASSWORD "Dinesh@123!"
ENV SSHPASS "Dinesh@123!"


# Update Ubuntu Software repository
RUN apt-get update

# Install network tools for ipconfig
RUN apt-get install -y net-tools

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


# Setup workdirectory
RUN mkdir -p /workdirectory
WORKDIR /workdirectory


CMD [ "/usr/bin/supervisord", "-c",  "/etc/supervisor/conf.d/supervisord.conf" ]