#!/bin/bash
set -o errexit # set -e
set -o nounset # set -u
set -o pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source ${SCRIPT_ROOT}/environment.sh

install() {
  ${SCRIPT_ROOT}/os.sh configure
  ${SCRIPT_ROOT}/bin.sh install && {
    set +o errexit
    set +o nounset
    set +o pipefail
    source ${HOME}/.bashrc &> /dev/null
    set -o errexit
    set -o nounset
    set -o pipefail
  }
  ${SCRIPT_ROOT}/etcd.sh start
  ${SCRIPT_ROOT}/containerd.sh install
  ${SCRIPT_ROOT}/gencert.sh gen_kube_all_certs
  ${SCRIPT_ROOT}/kubectl.sh gen_kubeconfig
  ${SCRIPT_ROOT}/kube-apiserver.sh start
  ${SCRIPT_ROOT}/kube-controller.sh start
  ${SCRIPT_ROOT}/kube-scheduler.sh start
  ${SCRIPT_ROOT}/kube-proxy.sh start
  ${SCRIPT_ROOT}/kubelet.sh start
  ${SCRIPT_ROOT}/calico.sh create
}

uninstall() {
  set +o errexit
  set +o nounset
  set +o pipefail
  ${SCRIPT_ROOT}/calico.sh remove
  ${SCRIPT_ROOT}/containerd.sh uninstall
  ${SCRIPT_ROOT}/etcd.sh stop
  ${SCRIPT_ROOT}/bin.sh uninstall
  ${SCRIPT_ROOT}/gencert.sh remove_all_certs
  ${SCRIPT_ROOT}/kubelet.sh stop
  ${SCRIPT_ROOT}/kubectl.sh remove_kubeconfig
  ${SCRIPT_ROOT}/kube-apiserver.sh stop
  ${SCRIPT_ROOT}/kube-scheduler.sh stop
  ${SCRIPT_ROOT}/kube-controller.sh stop
  ${SCRIPT_ROOT}/kube-proxy.sh stop
  rm -rf ${K8S_ROOT}
}

USAGE="$0 install|uninstall"
{
  if [ "$#" -ne 1 ]; then
    echo Usage: ${USAGE}
    exit 1
  fi

  $1

  if [ $? -eq 0 ]; then
    echo "$0 $*" executed successfully
    ${SCRIPT_ROOT}/report.sh text
  else
    echo "$0 $*" executed failed
  fi
}
