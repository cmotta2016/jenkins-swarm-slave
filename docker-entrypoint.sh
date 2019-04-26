#!/bin/bash
set -e

case "$1" in
        swarm)
                shift

                JAR=`ls -1 /usr/share/jenkins/swarm-client-*.jar | tail -n 1`

                PARAMS="-deleteExistingClients -disableSslVerification -mode exclusive"

                [ ! -z "$SWARM_USERNAME" ] && AUTH="-username $SWARM_USERNAME -password $SWARM_PASSWORD"

                if [ -z "$MYNAME" ]; then
                        MYNAME=`hostname`
                fi

                [ "$DEBUG" == "1" ] && echo "exec /sbin/gosu jenkins java $JAVA_OPTS -jar $JAR -executors $SWARM_EXECUTORS -name ${MYNAME} -master $SWARM_MASTER -labels \"$SWARM_LABELS\" $AUTH -fsroot $MYHOME $PARAMS"
                exec /sbin/gosu jenkins java $JAVA_OPTS -jar $JAR -executors $SWARM_EXECUTORS -name ${MYNAME} -master $SWARM_MASTER -labels "$SWARM_LABELS" $AUTH -fsroot $MYHOME $PARAMS
                ;;
esac

exec "$@"
