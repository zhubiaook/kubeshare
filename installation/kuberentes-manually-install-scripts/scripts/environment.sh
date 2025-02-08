#!/bin/bash
###################################
# environment
###################################

OS=$(uname -s)
OS=$(echo ${OS} | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
[ "${ARCH}" = "x86_64" ] && ARCH=amd64

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# node
HOSTNAME=kube01-master-test
IP=10.20.140.25
ROLE=master

# k8s
readonly K8S_ROOT=/data/k8s
BIN_DST=${K8S_ROOT}/bin
LOG_DIR=${K8S_ROOT}/log
readonly K8S_CERT_DIR=/data/k8s/pki
readonly KUBECONFIG=${HOME}/.kube/config
readonly STATIC_POD_PATH=/data/k8s/manifests
readonly POD_SUBNET=10.2.0.0/16
readonly SERVICE_SUBNET=10.250.0.0/16

# etcd
readonly ETCD_CERT_DIR=${K8S_CERT_DIR}/etcd
readonly ETCD_SERVERS=http://${IP}:2379

# pkg
readonly PKG_ROOT=${SCRIPT_ROOT}/../pkg


