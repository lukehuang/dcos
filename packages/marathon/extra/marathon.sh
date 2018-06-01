#!/bin/bash
set -euo pipefail

export LIBPROCESS_IP=$($MESOS_IP_DISCOVERY_COMMAND)

: ${MARATHON_HOSTNAME="$LIBPROCESS_IP"}
: ${MARATHON_DEFAULT_ACCEPTED_RESOURCE_ROLES="*"}
: ${MARATHON_MESOS_ROLE="slave_public"}
: ${MARATHON_MAX_INSTANCES_PER_OFFER=100}
: ${MARATHON_TASK_LAUNCH_TIMEOUT=86400000}
: ${MARATHON_DECLINE_OFFER_DURATION=300000}
: ${MARATHON_ENABLE_FEATURES="vips,task_killing,external_volumes,gpu_resources"}
: ${MARATHON_MESOS_AUTHENTICATION_PRINCIPAL="dcos_marathon"}
: ${MARATHON_MESOS_USER="root"}

if [ -z "${MARATHON_DISABLE_ZK_COMPRESSION+x}" ]; then
  MARATHON_ZK_COMPRESSION=""
fi

if [ -z "${MARATHON_DISABLE_REVIVE_OFFERS_FOR_NEW_APPS+x}" ]; then
  MARATHON_REVIVE_OFFERS_FOR_NEW_APPS=""
fi


export JAVA_OPTS="${MARATHON_JAVA_ARGS-}"
export -n MARATHON_JAVA_ARGS
export MARATHON_HOSTNAME MARATHON_MESOS_ROLE MARATHON_MAX_INSTANCES_PER_OFFER \
       MARATHON_TASK_LAUNCH_TIMEOUT MARATHON_DECLINE_OFFER_DURATION MARATHON_ENABLE_FEATURES \
       MARATHON_MESOS_AUTHENTICATION_PRINCIPAL MARATHON_MESOS_USER MARATHON_ZK_COMPRESSION \
       MARATHON_REVIVE_OFFERS_FOR_NEW_APPS

# TODO (DCOS_OSS-3592) - move this variable to the exported list after MARATHON-8254 is fixed
export -n MARATHON_DEFAULT_ACCEPTED_RESOURCE_ROLES

exec $PKG_PATH/marathon/bin/marathon \
    -Duser.dir=/var/lib/dcos/marathon \
    -J-server \
    -J-verbose:gc \
    -J-XX:+PrintGCDetails \
    -J-XX:+PrintGCTimeStamps \
    --master zk://zk-1.zk:2181,zk-2.zk:2181,zk-3.zk:2181,zk-4.zk:2181,zk-5.zk:2181/mesos \
    --mesos_leader_ui_url "/mesos" \
    # TODO (DCOS_OSS-3592) - remove this line after MARATHON-8254 is fixed
    --default_accepted_resource_roles "${MARATHON_DEFAULT_ACCEPTED_RESOURCE_ROLES}"
