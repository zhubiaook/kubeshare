#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/lib/init.sh"
source ${SCRIPT_ROOT}/environment.sh

KUBELET_DIR=${K8S_ROOT}/kubelet
KUBELET_CONFIG_FILE=${KUBELET_DIR}/config.yaml

KUBELET_CONFIG="
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
staticPodPath: ${STATIC_POD_PATH}
syncFrequency: 0s
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /data/k8s/pki/ca.pem
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
cgroupDriver: systemd
clusterDNS:
- 10.250.0.3
clusterDomain: cluster.local
address: 0.0.0.0
port: 10250
readOnlyPort: 10255
healthzBindAddress: 127.0.0.1
healthzPort: 10248
rotateCertificates: true
kubeletCgroups: systemd
maxPods: 110
podPidsLimit: 1000
systemReserved:
  cpu: 200m
  memory: 250Mi
kubeReserved:
  cpu: 200m
  memory: 250Mi
containerLogMaxFiles: 3
containerLogMaxSize: 5Mi
cpuManagerReconcilePeriod: 0s
evictionHard:
  memory.available: 5%
  pid.available: 10%
evictionMaxPodGracePeriod: 120
evictionPressureTransitionPeriod: 30s
evictionSoft:
  memory.available: 10%
evictionSoftGracePeriod:
  memory.available: 2m
fileCheckFrequency: 0s
httpCheckFrequency: 0s
imageMinimumGCAge: 0s
logging: {}
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
shutdownGracePeriodCriticalPods: 0s
streamingConnectionIdleTimeout: 0s
volumeStatsAggPeriod: 0s
"

verify_hostname() {
  if echo ${HOSTNAME} | egrep '^kube[[:digit:]]+-(master|worker)'; then
    return 0
  else
    error "Please modify the hostname to the format of kube01-master, kube01-worker, and kube02-worker"
    return 1
  fi
}

start() {
  verify_hostname

  export CPUAccounting=true 
  export MemoryAccounting=true
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir -p ${LOG_DIR}
  fi

  if [ ! -d "${KUBELET_DIR}" ]; then
    mkdir -p ${KUBELET_DIR}
  fi

  if [ ! -d "${STATIC_POD_PATH}" ]; then
    mkdir -p ${STATIC_POD_PATH}
  fi

  echo "${KUBELET_CONFIG}" > "${KUBELET_CONFIG_FILE}"

  nohup \
  kubelet \
    --kubeconfig ${KUBECONFIG} \
    --config ${KUBELET_CONFIG_FILE} \
    --container-runtime-endpoint=unix:///run/containerd/containerd.sock \
    --root-dir ${KUBELET_DIR} \
    --node-ip ${IP} \
    --hostname-override=${HOSTNAME} \
    --cert-dir=/data/k8s/kubelet/pki \
    --kubelet-cgroups=/system.slice \
    --runtime-cgroups=/system.slice \
  &> ${LOG_DIR}/kubelet.log &
}

stop() {
  set +o errexit
  set +o nounset
  set +o pipefail

  pids=$(pgrep -x kubelet)
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
