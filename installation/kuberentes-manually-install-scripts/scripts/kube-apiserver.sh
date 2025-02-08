#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/lib/init.sh"
source ${SCRIPT_ROOT}/environment.sh

start() {
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir -p ${LOG_DIR}
  fi

  nohup \
  kube-apiserver \
    --etcd-servers "${ETCD_SERVERS}" \
    --service-account-issuer https://kubernetes.default.svc.cluster.local \
    --service-account-key-file ${K8S_CERT_DIR}/kubeapiserver.pem \
    --service-account-signing-key-file ${K8S_CERT_DIR}/kubeapiserver-key.pem \
    --client-ca-file ${K8S_CERT_DIR}/ca.pem \
    --tls-cert-file ${K8S_CERT_DIR}/kubeapiserver.pem \
    --tls-private-key-file ${K8S_CERT_DIR}/kubeapiserver-key.pem \
    --kubelet-client-certificate ${K8S_CERT_DIR}/kubeapiserver.pem \
    --kubelet-client-key ${K8S_CERT_DIR}/kubeapiserver-key.pem \
    --allow-privileged \
    --service-cluster-ip-range=${SERVICE_SUBNET} \
  &> ${LOG_DIR}/kube-apiserver.log &
}

staticpod() {
  [ -d ${STATIC_POD_PATH} ] || mkdir -p ${STATIC_POD_PATH}
  true > ${STATIC_POD_PATH}/kube-apiserver.yaml
  while IFS= read -r line; do
    eval "echo \"${line}\"" >> ${STATIC_POD_PATH}/kube-apiserver.yaml
  done < "${SCRIPT_ROOT}/manifests/kube-apiserver.yaml.tmpl"
}

stop() {
  pids=$(pgrep -x kube-apiserver)
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
