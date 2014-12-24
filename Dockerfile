FROM phusion/baseimage:0.9.13
MAINTAINER Wayne Leroux <WayneLeroux@gmail.com>

# Set up base image
RUN apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade
ENV HOME /root
RUN echo 'LANG="en_EN.UTF-8"' > /etc/default/locale
CMD ["/sbin/my_init"]

# Install Java 7
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer
RUN update-java-alternatives -s java-7-oracle
RUN echo 'export JAVA_HOME="/usr/lib/jvm/java-7-oracle"' >> ~/.bashrc
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle
ENV PATH $PATH:$JAVA_HOME/bin
RUN export PATH=$PATH

# Install Administration Utilities
RUN apt-get -y install wget unzip git sudo zip bzip2 fontconfig curl vim

# Install Crowd
ENV CROWD_VERSION 2.8.0
RUN wget -P /tmp http://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-${CROWD_VERSION}.tar.gz \
    && tar xzf /tmp/atlassian-crowd-${CROWD_VERSION}.tar.gz -C /opt
RUN mkdir /etc/service/atlassian-crowd-${CROWD_VERSION} \
    && echo "#!/bin/bash\n/opt/atlassian-crowd-${CROWD_VERSION}/apache-tomcat/bin/catalina.sh run" > /etc/service/atlassian-crowd-${CROWD_VERSION}/run \
    && chmod +x /etc/service/atlassian-crowd-${CROWD_VERSION}/run
RUN echo 'export CROWD_HOME="/var/crowd-home"' >> ~/.bashrc
ADD conf/crowd-init.properties /opt/atlassian-crowd-${CROWD_VERSION}/crowd-webapp/WEB-INF/classes/crowd-init.properties
ENV CROWD_HOME /var/crowd-home
RUN mkdir -p /var/crowd-home && chmod 777 /var/crowd-home
VOLUME /var/crowd-home
EXPOSE 8095

# Install MySQL Support for Crowd
RUN wget -P /tmp http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.32.tar.gz \
    && tar xzf /tmp/mysql-connector-java-5.1.32.tar.gz -C /tmp \
    && cp /tmp/mysql-connector-java-5.1.32/mysql-connector-java-5.1.32-bin.jar /opt/atlassian-crowd-${CROWD_VERSION}/apache-tomcat/lib/mysql-connector-java-5.1.32-bin.jar \
    && rm -rf /tmp

# Clean up when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*

