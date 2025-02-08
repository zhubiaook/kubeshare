#!/bin/bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${ROOT_DIR}/lib/init.sh"

ETCD_DIR=/data/k8s/etcd
ETCD_LOG_DIR=${ETCD_DIR}/log
HOSTNAME=$(hostname)

start() {
  if [ ! -d "${ETCD_LOG_DIR}" ]; then
    mkdir -p ${ETCD_LOG_DIR}
  fi

  nohup \
    etcd \
    --name ${HOSTNAME} \
    --listen-client-urls http://0.0.0.0:2379 \
    --advertise-client-urls http://10.20.141.40:2379 \
    --listen-peer-urls http://0.0.0.0:2380 \
    --initial-advertise-peer-urls http://10.20.141.40:2380 \
    --data-dir ${ETCD_DIR}/data \
  &> ${ETCD_LOG_DIR}/etcd.log &
}

stop() {
  pids=$(pidof etcd)
  killprocess ${pids}
}

USAGE="$0 start|stop"
{
  if [ "$#" -ne 1 ]; then
    echo Usage: ${USAGE}
    exit 1
  fi

  $1

  if [ $? -eq 0 ]; then
    echo "$0 $*" executed successfully
  else
    echo "$0 $*" executed failed
  fi
}
