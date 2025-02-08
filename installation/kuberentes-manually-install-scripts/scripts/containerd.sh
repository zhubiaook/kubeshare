#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/lib/init.sh"
source ${SCRIPT_ROOT}/environment.sh

CONTAINERD_CONFIG_DIR=/etc/containerd
CONTAINERD_CONFIG_FILE=${CONTAINERD_CONFIG_DIR}/config.toml

CONTAINERD_FILES=(
  "/etc/containerd/config.toml"
  "/etc/crictl.yaml"
  "/etc/cni/net.d/10-containerd-net.conflist"
  )

install() {
  [ -d "${CONTAINERD_CONFIG_DIR}" ] || mkdir -p ${CONTAINERD_CONFIG_DIR}
  [ -d "${LOG_DIR}" ] || mkdir -p ${LOG_DIR}

  modprobe overlay
  containerd config default > ${CONTAINERD_CONFIG_FILE}
  sed -ri 's#sandbox_image.*$#sandbox_image = "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.8"#' ${CONTAINERD_CONFIG_FILE}

  nohup \
    containerd --config /etc/containerd/config.toml \
  &> ${LOG_DIR}/containerd.log &

  crictl::gen_config
}

crictl::gen_config() {
  cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 2
debug: true
pull-image-on-create: false
EOF
}

crictl::remove_config() {
  rm -rf /etc/crictl.yam &> /dev/null
}

uninstall() {
  crictl::remove_config

  pids=$(pidof containerd)
  killprocess ${pids}
  for f in ${CONTAINERD_FILES[@]}; do
    if [ -e "${f}" ]; then
      rm -rf ${f}
    else
      info "${f} does not exist"
    fi
  done
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
  else
    echo "$0 $*" executed failed
  fi
}
