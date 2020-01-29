FROM centos:centos7

ENV JAVA_UPDATE 181

USER root
############################### Instalação Java JDK

COPY files/jdk-8u${JAVA_UPDATE}-linux-x64.rpm /tmp
RUN rpm -ivh /tmp/jdk-8u${JAVA_UPDATE}-linux-x64.rpm && rm -f /tmp/jdk-8u${JAVA_UPDATE}-linux-x64.rpm

USER app

ENV JAVA_HOME "/usr/java/jdk1.8.0_${JAVA_UPDATE}-amd64/"
ENV JAVA_VERSION 8u${JAVA_UPDATE}

############################### Remoção do usuário app

USER root
ENV DOCKER_VERSION 17.03.0-ce
ENV JENKINS_SWARM_VERSION  3.14 

# Install Essentials + Ansible
RUN yum update -y && yum install -y git sudo openssh-server which ansible && yum clean all

############################### Instalaçao do DOCKER

ADD files/docker-${DOCKER_VERSION}.tgz /
RUN cp /docker/* /usr/bin/ && rm -rf docker/

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python get-pip.py && pip install docker

############################### Permissão sudo para grupo jenkins e requiretty desabilitado

COPY files/sudoers /etc/sudoers
RUN echo "StrictHostKeyChecking=no" >> /etc/ssh/ssh_config

# gen dummy keys, centos doesn't autogen them like ubuntu does
RUN /usr/bin/ssh-keygen -A

# Set SSH Configuration to allow remote logins without /proc write access
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd

#Environment

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV JENKINS_HOME /var/lib/jenkins

# Create Jenkins User
RUN groupadd -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

RUN chown -R jenkins:jenkins ${JENKINS_HOME}

######################## Seting locale for Jenkins User

RUN echo 'export LANG=en_US.UTF-8' >> ${JENKINS_HOME}/.bash_profile \
    && echo 'LANG=en_US.UTF-8' >> /etc/environment
RUN echo 'export LANGUAGE=en_US:en' >> ${JENKINS_HOME}/.bash_profile \
    && echo 'LANGUAGE=en_US:en' >> /etc/environment
RUN echo 'export LC_ALL=en_US.UTF-8' >> ${JENKINS_HOME}/.bash_profile \
    && echo 'LC_ALL=en_US.UTF-8' >> /etc/environment

RUN echo "export JENKINS_HOME_OUT=${JENKINS_HOME}" >> ${JENKINS_HOME}/.bash_profile 
RUN echo "export JENKINS_HOME_OUT=${JENKINS_HOME}" >> /etc/environment
RUN echo "export JENKINS_HOME_OUT=${JENKINS_HOME}" >> /etc/profile 

COPY files/swarm-client-${JENKINS_SWARM_VERSION}.jar /usr/share/jenkins/swarm-client-${JENKINS_SWARM_VERSION}.jar 
COPY files/jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

RUN chmod  755 /usr/share/jenkins/swarm-client-${JENKINS_SWARM_VERSION}.jar  /usr/local/bin/jenkins-slave.sh
# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

USER ${user}
WORKDIR ${JENKINS_HOME}
ENV JENKINS_HOME_OUT ${JENKINS_HOME}

#ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]
ENTRYPOINT ["/tini", "--"]
CMD ["/usr/local/bin/jenkins-slave.sh"]
