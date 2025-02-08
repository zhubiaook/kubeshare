#!/bin/bash

set +o errexit
set +o nounset
set +o pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source ${SCRIPT_ROOT}/environment.sh

os::configure() {
  echo "${IP} ${HOSTNAME}" >> /etc/hosts

  # stop firewalld
  systemctl stop firewalld &> /dev/null
  systemctl disable firewalld &> /dev/null

  # stop SELinux
  setenforce 0
  sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

  # close swap
  swapoff -a
  sed -ri '/[[:blank:]]swap[[:blank:]]/s/^/#/' /etc/fstab

  # modify hostname
  hostnamectl set-hostname ${HOSTNAME}

  # configure kernel parameters
  modprobe overlay
  modprobe br_netfilter

  cat > /etc/modules-load.d/k8s.conf <<EOF 
br_netfilter
overlay
EOF

  cat > /etc/sysctl.d/k8s.conf <<EOF 
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
fs.file-max = 999999
EOF
  sysctl --system -p &> /dev/null

  localectl set-locale LANG=en_US.UTF-8 && export LANG=en_US.UTF-8
  systemctl stop postfix && systemctl disable postfix &> /dev/null

  yum -y install socat conntrack ebtables ipset ipvsadm &> /dev/null
}

USAGE="$0 configure"
{
  if [ "$#" -ne 1 ]; then
    echo Usage: ${USAGE}
    exit 1
  fi

  os::$1

  if [ $? -eq 0 ]; then
    echo "$0 $*" executed successfully
  else
    echo "$0 $*" executed failed
  fi
}
