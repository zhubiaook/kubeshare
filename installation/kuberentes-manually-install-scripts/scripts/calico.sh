#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source ${SCRIPT_ROOT}/environment.sh

create() {
  kubectl apply -f ${SCRIPT_ROOT}/manifests/calico.yaml &> /dev/null
}

remove() {
  kubectl delete -f ${SCRIPT_ROOT}/manifests/calico.yaml &> /dev/null
}



USAGE="$0 create|remove"
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
