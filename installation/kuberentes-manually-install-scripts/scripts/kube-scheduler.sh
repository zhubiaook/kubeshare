#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/lib/init.sh"
source ${SCRIPT_ROOT}/environment.sh

start() {
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir -p ${LOG_DIR}
  fi

  nohup \
  kube-scheduler \
    --kubeconfig ${KUBECONFIG} \
    --bind-address=0.0.0.0 \
    --leader-elect=true \
    --authentication-kubeconfig ${KUBECONFIG} \
    --authorization-kubeconfig ${KUBECONFIG} \
    --client-ca-file ${K8S_CERT_DIR}/ca.pem \
    --requestheader-client-ca-file ${K8S_CERT_DIR}/ca.pem \
  &> ${LOG_DIR}/kube-scheduler.log &
}

stop() {
  pids=$(pgrep -x kube-scheduler)
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
