#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source ${SCRIPT_ROOT}/environment.sh

arch=arm64
os=linux

download() {
  url="$1"
  wget ${url}
}

download::k8s() {
  local version=v1.26.7
  urls=(
    https://cdn.dl.k8s.io/release/${version}/bin/${os}/${arch}/kube-apiserver
    https://cdn.dl.k8s.io/release/${version}/bin/${os}/${arch}/kubelet
    https://cdn.dl.k8s.io/release/${version}/bin/${os}/${arch}/kubeadm
    https://cdn.dl.k8s.io/release/${version}/bin/${os}/${arch}/kubectl
    https://cdn.dl.k8s.io/release/${version}/bin/${os}/${arch}/kube-controller-manager
    https://cdn.dl.k8s.io/release/${version}/bin/${os}/${arch}/kube-scheduler
    https://cdn.dl.k8s.io/release/${version}/bin/${os}/${arch}/kube-proxy
  )

  for url in ${urls[@]}; do
    echo "Download ${url}"
    download ${url}
  done
}

download::etcd() {
  local version=v3.5.7

  urls=(
    https://github.com/etcd-io/etcd/releases/download/${version}/etcd-${version}-${os}-${arch}.tar.gz
  )

  for url in ${urls[@]}; do
    echo "Download ${url}"
    download ${url}
  done
}

download::containerd() {
  local version=1.7.1

  urls=(
    https://github.com/containerd/containerd/releases/download/v${version}/containerd-${version}-${os}-${arch}.tar.gz
  )

  for url in ${urls[@]}; do
    echo "Download ${url}"
    download ${url}
  done
}

download::runc() {
  local version=v1.1.7

  urls=(
    https://github.com/opencontainers/runc/releases/download/${version}/runc.${arch}
  )

  for url in ${urls[@]}; do
    echo "Download ${url}"
    download ${url}
  done
}

download::cni-plugins() {
  local version=v1.3.0

  urls=(
    https://github.com/containernetworking/plugins/releases/download/${version}/cni-plugins-${os}-${arch}-${version}.tgz
  )

  for url in ${urls[@]}; do
    echo "Download ${url}"
    download ${url}
  done
}

download::crictl() {
  local version=v1.26.1

  urls=(
    https://github.com/kubernetes-sigs/cri-tools/releases/download/${version}/crictl-${version}-${os}-${arch}.tar.gz
  )

  for url in ${urls[@]}; do
    echo "Download ${url}"
    download ${url}
  done
}






{
  download::k8s
  download::etcd
  download::containerd
  download::runc
  download::cni-plugins
  download::crictl
}
