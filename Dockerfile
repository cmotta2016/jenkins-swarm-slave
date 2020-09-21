## Fonte https://github.com/jtilander/docker-jenkins-swarm-slave
FROM jtilander/alpine
MAINTAINER Jim Tilander

RUN apk add --no-cache \
              openjdk8 \
                  curl \
                   git \
                  make \
                 docker
ENV SWARM_VERSION=3.4 \
    GOSU_VERSION=1.10
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-${SWARM_VERSION}.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.jar \
  && chmod 755 /usr/share/jenkins

RUN curl -SsL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 > /sbin/gosu && chmod a+x /sbin/gosu

ENV MYHOME=/home/jenkins \
        UID=1000
RUN adduser -S -s /bin/sh -D -u $UID -G root jenkins && \
        mkdir -p $MYHOME && chmod g+rwx $MYHOME

ENV JENKINS_MEMORY=200M

# O nome do server dessa variável corresponde ao nome do service dentro do compose da stack master
ENV SWARM_MASTER=<jenkins_master_url>
ENV SWARM_EXECUTORS=3
ENV SWARM_USERNAME=<user>
ENV SWARM_PASSWORD=<password>
ENV SWARM_LABELS="docker linux swarm amd64"
ENV MYTIMEZONE="America/Sao_Paulo"
ENV JAVA_OPTS="-Xms$JENKINS_MEMORY -Xmx$JENKINS_MEMORY -Djava.awt.headless=true -Duser.timezone=$MYTIMEZONE -Dorg.apache.commons.jelly.tags.fmt.timeZone=$MYTIMEZONE"

WORKDIR $MYHOME
VOLUME ["$MYHOME"]

COPY docker-entrypoint.sh /
RUN chmod 777 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["swarm"]
