#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source ${SCRIPT_ROOT}/environment.sh

gen_kubeconfig() {
  kubectl config set-cluster kubernetes \
    --certificate-authority=${K8S_CERT_DIR}/ca.pem \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=${KUBECONFIG} &> /dev/null
  
  kubectl config set-credentials admin \
    --client-certificate=${K8S_CERT_DIR}/kubectl.pem \
    --client-key=${K8S_CERT_DIR}/kubectl-key.pem \
    --kubeconfig=${KUBECONFIG} &> /dev/null
  
  kubectl config set-context kubernetes \
    --cluster=kubernetes \
    --user=admin \
    --kubeconfig=${KUBECONFIG} &> /dev/null
  
  kubectl config use-context kubernetes --kubeconfig=${KUBECONFIG} &> /dev/null
}

remove_kubeconfig() {
  rm -rf ${KUBECONFIG}
}


USAGE="$0 gen_kubeconfig|remove_kubeconfig"
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

