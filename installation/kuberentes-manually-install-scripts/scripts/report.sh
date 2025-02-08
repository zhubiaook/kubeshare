#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source ${SCRIPT_ROOT}/environment.sh

text() {
  printf "\nPlease execute:\n
  source ${HOME}/.bashrc

  # Get all pods
  kubectl get pod -A

  # Get nodes
  kubectl get node\n"
}



USAGE="$0 text"
{
  if [ "$#" -ne 1 ]; then
    echo Usage: ${USAGE}
    exit 1
  fi

  $1
}

