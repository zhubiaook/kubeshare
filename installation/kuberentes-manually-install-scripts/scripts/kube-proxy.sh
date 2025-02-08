#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/lib/init.sh"
source ${SCRIPT_ROOT}/environment.sh

start() {
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir -p ${LOG_DIR}
  fi

  local config_dir=${K8S_ROOT}/kube-proxy
  [ -d "${config_dir}" ] || mkdir -p ${config_dir}
  config=${config_dir}/config.yaml

  cat > ${config} <<EOF
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
bindAddressHardFail: false
clientConnection:
  acceptContentTypes: ""
  burst: 0
  contentType: ""
  kubeconfig: ${KUBECONFIG}
  qps: 0
clusterCIDR: ${POD_SUBNET}
configSyncPeriod: 0s
conntrack:
  maxPerCore: null
  min: null
  tcpCloseWaitTimeout: null
  tcpEstablishedTimeout: null
detectLocalMode: ""
enableProfiling: false
healthzBindAddress: ""
hostnameOverride: ${HOSTNAME}
iptables:
  masqueradeAll: false
  masqueradeBit: 14
  minSyncPeriod: 0s
  syncPeriod: 30s
ipvs:
  excludeCIDRs: null
  minSyncPeriod: 0s
  scheduler: ""
  strictARP: false
  syncPeriod: 0s
  tcpFinTimeout: 0s
  tcpTimeout: 0s
  udpTimeout: 0s
kind: KubeProxyConfiguration
metricsBindAddress: ""
mode: iptables
nodePortAddresses: null
oomScoreAdj: null
portRange: ""
showHiddenMetricsForVersion: ""
udpIdleTimeout: 0s
winkernel:
  enableDSR: false
  networkName: ""
  sourceVip: ""
EOF

  nohup \
  kube-proxy \
    --config ${config} \
  &> ${LOG_DIR}/kube-proxy.log &
}

stop() {
  pids=$(pgrep -x kube-proxy)
  killprocess ${pids}
}

USAGE="$0 start|stop"
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
