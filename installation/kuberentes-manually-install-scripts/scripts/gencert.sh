#!/bin/bash

SCRIPT_ROOT=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd -P)
source "${SCRIPT_ROOT}/lib/init.sh"
source ${SCRIPT_ROOT}/environment.sh

HOSTNAME=$(hostname)
IPS=$(hostname -I)
KUBEAPISERVER_URL="kubeapiserver.example.io"

STAET_MARK='# KUBE-START-MARK'

CA_CSR='{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "ca": {
    "expiry": "876000h"
  }
}'

CA_CONFIG='{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "server": {
        "expiry": "876000h",
        "usages": [
          "signing",
          "key encipherment",
          "server auth"
        ]
      },
      "client": {
        "expiry": "876000h",
        "usages": [
          "signing",
          "key encipherment",
          "client auth"
        ]
      },
      "peer": {
        "expiry": "876000h",
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ]
      }
    }
  }
}'

KUBEAPISERVER_CSR='{
  "CN": "kube-apiserver",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "hosts": [
    %s
    "127.0.0.1",
    "localhost"
  ]
}'

KUBECTL_CSR='{
  "CN": "kubectl",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "O": "system:masters"
    }
  ]
}'


ETCD_CA_CSR='{
  "CN": "etcd-ca",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "ca": {
    "expiry": "876000h"
  }
}'


ETCD_SERVER_CSR='{
  "CN": "etcd-server",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "hosts": [
    %s
    "127.0.0.1",
    "localhost"
  ]
}'

# generate self signed certificates
gen_ca_cert() {
  [ -d ${K8S_CERT_DIR} ] || mkdir -p ${K8S_CERT_DIR}
  echo -e "${CA_CSR}" > ${K8S_CERT_DIR}/ca-csr.json
  cfssl gencert -initca ${K8S_CERT_DIR}/ca-csr.json 2> /dev/null | cfssljson -bare ${K8S_CERT_DIR}/ca
}

create_cert_config() {
  echo -e "$CA_CONFIG" > ${K8S_CERT_DIR}/ca-config.json
}

gen_kubeapiserver_cert() {
  hosts=(${IPS} ${HOSTNAME} 10.250.0.1 kubernetes kubernetes.kube-system kubernetes.kube-system.svc kubernetes.kube-system.svc.cluster.local) 
  str=$(strings::join '    "%s",\n' ${hosts[@]})

  printf "${KUBEAPISERVER_CSR}" "${str}" > ${K8S_CERT_DIR}/kubeapiserver-csr.json
  cfssl gencert -ca ${K8S_CERT_DIR}/ca.pem -ca-key ${K8S_CERT_DIR}/ca-key.pem -config ${K8S_CERT_DIR}/ca-config.json -profile peer ${K8S_CERT_DIR}/kubeapiserver-csr.json 2> /dev/null | cfssljson -bare ${K8S_CERT_DIR}/kubeapiserver
}

gen_kubectl_cert() {
  printf "${KUBECTL_CSR}" > ${K8S_CERT_DIR}/kubectl-csr.json
  cfssl gencert -ca ${K8S_CERT_DIR}/ca.pem -ca-key ${K8S_CERT_DIR}/ca-key.pem -config ${K8S_CERT_DIR}/ca-config.json -profile peer ${K8S_CERT_DIR}/kubectl-csr.json 2> /dev/null | cfssljson -bare ${K8S_CERT_DIR}/kubectl
}

create_etcd_cert_config() {
  echo -e "$CA_CONFIG" > ${ETCD_CERT_DIR}/ca-config.json
}

gen_etcd_ca_cert() {
  [ -d ${ETCD_CERT_DIR} ] || mkdir -p ${ETCD_CERT_DIR}
  echo -e "${ETCD_CA_CSR}" > ${ETCD_CERT_DIR}/ca-csr.json
  cfssl gencert -initca ${ETCD_CERT_DIR}/ca-csr.json 2> /dev/null | cfssljson -bare ${ETCD_CERT_DIR}/ca
}

gen_etcd_server_cert() {
  hosts=(${IPS} ${HOSTNAME} etcd etcd.kube-system etcd.kube-system.svc etcd.kube-system.svc.cluster.local) 
  str=$(strings::join '    "%s",\n' ${hosts[@]})

  printf "${ETCD_SERVER_CSR}" "${str}" > ${ETCD_CERT_DIR}/etcd-server-csr.json
  cfssl gencert -ca ${ETCD_CERT_DIR}/ca.pem -ca-key ${ETCD_CERT_DIR}/ca-key.pem -config ${ETCD_CERT_DIR}/ca-config.json -profile server ${ETCD_CERT_DIR}/etcd-server-csr.json 2> /dev/null | cfssljson -bare ${ETCD_CERT_DIR}/etcd-server
}

gen_etcd_all_certs() {
  gen_etcd_ca_cert
  create_etcd_cert_config
  gen_etcd_server_cert
}

gen_kube_all_certs() {
  gen_ca_cert
  create_cert_config
  gen_kubeapiserver_cert
  gen_kubectl_cert
}

remove_all_certs() {
  rm -rf ${K8S_CERT_DIR}
}

USAGE="$0 gen_kube_all_certs|gen_etcd_all_certs|remove_all_certs"
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
