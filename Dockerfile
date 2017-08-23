FROM phusion/baseimage:0.9.19

RUN echo "nameserver 192.168.22.2" > /etc/resolv.conf \
&&  apt-get update \
&&  apt-get upgrade -y \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "nameserver 192.168.22.2" > /etc/resolv.conf \
&&  apt-get update \
&&  apt-get install -y \
      openjdk-8-jre \
      rsync \
      ssh \
      git \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Spigot (Minecraft server)
ADD https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar /opt/minecraft/BuildTools.jar

WORKDIR /opt/minecraft/

RUN echo "nameserver 192.168.22.2" > /etc/resolv.conf \
&&  java -jar BuildTools.jar --rev 1.12.1 . \
&&  mkdir -p /etc/service/scriptcraft

ADD http://scriptcraftjs.org/download/extras/mqtt/sc-mqtt.jar /opt/minecraft/sc-mqtt.jar
ADD http://scriptcraftjs.org/download/latest/scriptcraft-3.2.1/scriptcraft.jar /opt/minecraft/plugins/scriptcraft.jar

ADD server.properties /opt/minecraft/server.properties
#ADD config.yml /opt/minecraft/plugins/scriptcraft/config.yml

# add the scriptcraft service
ADD start /etc/service/scriptcraft/run

# a default ssh access to upload js
ADD sshd_config /etc/ssh/sshd_config

RUN mkdir -p /opt/minecraft/scriptcraft/players/ \
&&  echo "root:minecraft" | chpasswd \
&&  echo "eula=true" > /opt/minecraft/eula.txt \
&&  rm -f /etc/service/sshd/down \
&&  chmod +x /etc/service/scriptcraft/run

EXPOSE 25565 22
VOLUME ["/minecraft/"]

