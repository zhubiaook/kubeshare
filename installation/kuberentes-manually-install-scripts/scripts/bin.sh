#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source ${SCRIPT_ROOT}/environment.sh

PKGS=(cfssl etcd containerd runc kube cri-tools)

START_MARK='# KUBE-START-MARK'
END_MARK='# KUBE-END-MARK'

source "${SCRIPT_ROOT}/lib/init.sh"

install() {
  [ -d "${PKG_ROOT}" ] || { info "package not exist"; return; }
  [ -d "${BIN_DST}" ] ||  { mkdir -p ${BIN_DST}; } 

  for pkg in ${PKGS[@]}; do
    bin_dir=${PKG_ROOT}/${pkg}/bin/${OS}/${ARCH}
    if [ -n "ls -A ${bin_dir}" ]; then
      # info "copy ${pkg} binaries to ${BIN_DST}"
      cp ${bin_dir}/* ${BIN_DST}
    else
      error "${pkg} binary file not exist"
    fi
  done

  cni_plugins_install

  if grep "$END_MARK" ${HOME}/.bashrc &> /dev/null; then
    sed -ri "/${END_MARK}/ iexport PATH=${SCRIPT_ROOT}:${BIN_DST}:\$PATH" ${HOME}/.bashrc
  else
    echo -e "${START_MARK}\nexport PATH=${SCRIPT_ROOT}:${BIN_DST}:\$PATH\n${END_MARK}" >> ${HOME}/.bashrc
  fi
}

uninstall() {
  rm -rf ${BIN_DST} &> /dev/null
  cni_plugins_uninstall
  sed -ri "/${START_MARK}/,/${END_MARK}/d" ${HOME}/.bashrc
}

cni_plugins_install() {
  local BIN_DST=/opt/cni/bin 

  [ -d "${PKG_ROOT}" ] || { info "package not exist"; return; }
  [ -d "${BIN_DST}" ] ||  { mkdir -p ${BIN_DST}; } 

  pkg="cni-plugins"
  bin_dir=${PKG_ROOT}/${pkg}/bin/${OS}/${ARCH}
  if [ -n "ls -A ${bin_dir}" ]; then
    # info "copy ${pkg} binaries to ${BIN_DST}"
    cp ${bin_dir}/* ${BIN_DST}
  else
    error "${pkg} binary file not exist"
  fi
}

cni_plugins_uninstall() {
  local BIN_DST=/opt/cni/bin 
  rm -rf ${BIN_DST} &> /dev/null
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
