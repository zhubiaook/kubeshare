#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/lib/init.sh"
source ${SCRIPT_ROOT}/environment.sh

start() {
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir -p ${LOG_DIR}
  fi

  local cert_dir=${K8S_ROOT}/kube-controller/pki
  [ ! -d "${LOG_DIR}" ] || mkdir -p ${LOG_DIR}
  [ ! -d "${cert_dir}" ] || mkdir -p ${cert_dir}

  nohup \
  kube-controller-manager \
    --kubeconfig ${KUBECONFIG} \
    --authentication-kubeconfig ${KUBECONFIG} \
    --authorization-kubeconfig ${KUBECONFIG} \
    --leader-elect=true \
    --client-ca-file ${K8S_CERT_DIR}/ca.pem \
    --root-ca-file ${K8S_CERT_DIR}/ca.pem \
    --requestheader-client-ca-file ${K8S_CERT_DIR}/ca.pem \
    --cluster-signing-cert-file ${K8S_CERT_DIR}/ca.pem \
    --cluster-signing-key-file ${K8S_CERT_DIR}/ca-key.pem \
    --cert-dir=${cert_dir} \
    --allocate-node-cidrs=true \
    --cluster-cidr=${POD_SUBNET} \
    --service-cluster-ip-range=${SERVICE_SUBNET} \
  &> ${LOG_DIR}/kube-controller.log &
}

stop() {
  pids=$(pgrep kube-controller)
  killprocess "${pids}"
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
