## Kubernetes Component Versions

> 版本选择参考K3S: https://github.com/k3s-io/k3s/releases/tag/v1.28.11%2Bk3s2

0. Linux Kernel v5.4

1. Kubernetes v1.28.11
   [kube-apiserver](https://cdn.dl.k8s.io/release/v1.28.11/bin/linux/amd64/kube-apiserver)
   [kubelet](https://cdn.dl.k8s.io/release/v1.28.11/bin/linux/amd64/kubelet)
   [kubeadm](https://cdn.dl.k8s.io/release/v1.28.11/bin/linux/amd64/kubeadm)
   [kubectl](https://cdn.dl.k8s.io/release/v1.28.11/bin/linux/amd64/kubectl)
   [kube-controller-manager](https://cdn.dl.k8s.io/release/v1.28.11/bin/linux/amd64/kube-controller-manager)
   [kube-scheduler](https://cdn.dl.k8s.io/release/v1.28.11/bin/linux/amd64/kube-scheduler)
   [kube-proxy](https://cdn.dl.k8s.io/release/v1.28.11/bin/linux/amd64/kube-proxy)

2. Etcd v3.5.13
   [etcd](https://github.com/etcd-io/etcd/releases/download/v3.5.13/etcd-v3.5.13-linux-amd64.tar.gz)

3. Containerd v1.7.17

4. Runc v1.1.12

5. CNI Plugins v1.3.0
   [doc](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)
   [containerd](https://github.com/containerd/containerd/releases/download/v1.7.17/containerd-1.7.17-linux-amd64.tar.gz)
   [runc](https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64)
   [cin-plugins](https://github.com/containernetworking/plugins/releases/download/v1.5.0/cni-plugins-linux-amd64-v1.5.0.tgz)

6. Cilium v1.15.7

7. CoreDNS v1.9.3
   
   > install by kubeadm, you can manual install
   
   [coredns](https://github.com/coredns/deployment/tree/master/kubernetes)

8 Nginx-ingress v3.6.1(Nginx 1.27.0) 
      [nginx](https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/)
      [nginx-version](https://docs.nginx.com/nginx-ingress-controller/technical-specifications)

9. MetalLB v0.14.7
   [metallb](https://raw.githubusercontent.com/metallb/metallb/v0.14.7/config/manifests/metallb-native.yaml)
   [install-doc](https://metallb.universe.tf/installation/)
   [config-doc](https://metallb.universe.tf/configuration/)
   [L2-config-doc](https://metallb.universe.tf/configuration/_advanced_l2_configuration/)

10. Rancher v2.7.6
* Metrics-server v0.6.3
* Traefik v2.9.10
* Helm-controller v0.15.2
* helm v3.9.0
* Local-path-provisioner v0.0.24
* haproxy 2.3

## 镜像

registry.cn-beijing.aliyuncs.com/kubesphereio/kube-proxy:v1.26.7
registry.cn-beijing.aliyuncs.com/kubesphereio/pause:3.8
registry.cn-beijing.aliyuncs.com/kubesphereio/kube-apiserver:v1.26.7
registry.cn-beijing.aliyuncs.com/kubesphereio/kube-proxy:v1.26.7
registry.cn-beijing.aliyuncs.com/kubesphereio/kube-apiserver:v1.26.7
registry.cn-beijing.aliyuncs.com/kubesphereio/coredns:1.9.3
registry.cn-beijing.aliyuncs.com/kubesphereio/k8s-dns-node-cache:1.22.20
registry.cn-beijing.aliyuncs.com/kubesphereio/kube-controller-manager:v1.26.7
registry.cn-beijing.aliyuncs.com/kubesphereio/kube-controllers:v3.26.1
registry.cn-beijing.aliyuncs.com/kubesphereio/kube-scheduler:v1.26.7
registry.cn-beijing.aliyuncs.com/kubesphereio/kube-proxy:v1.26.7
registry.cn-beijing.aliyuncs.com/kubesphereio/cni:v3.26.1
registry.cn-beijing.aliyuncs.com/kubesphereio/coredns:1.9.3
registry.cn-beijing.aliyuncs.com/kubesphereio/k8s-dns-node-cache:1.22.20
registry.cn-beijing.aliyuncs.com/kubesphereio/kube-controllers:v3.26.1
registry.cn-beijing.aliyuncs.com/kubesphereio/cni:v3.26.1
registry.cn-beijing.aliyuncs.com/kubesphereio/node:v3.26.1
registry.cn-beijing.aliyuncs.com/kubesphereio/pod2daemon-flexvol:v3.26.1
registry.cn-beijing.aliyuncs.com/kubesphereio/haproxy:2.3

## Installer Version

* SQLite 3.39.2

## Environment

systemctl disable firewalld --now
conntrack ipvsadm ipset iptables sysstat libseccomp wget socat

## Etcd

```bash
#!/bin/bash

etcd_root=/data/k8s/etcd
nohup etcd --name etcd-01 --advertise-client-urls http://10.20.141.40:2379 --listen-client-urls http://10.20.141.40:2379 --listen-peer-urls http://10.20.141.40:2380 --initial-advertise-peer-urls http://10.20.141.40:2380 --data-dir ${etcd_root}/data &> ${etcd_root}/log/etcd.log &
```

## kube-apiserver

kube-apiserver --etcd-servers http://10.20.141.40:2379

## kubectl

curl -kL --cacert /data/k8s/tls/ca.pem --cert /data/k8s/tls/kubectl.pem --key /data/k8s/tls/kubectl-key.pem https://127.0.0.1:6443/api/v1/namespaces/default/pods

## kubelet

1. 运行条件:
   a. disable swap
   b. 10.20.141.40 kube01-master-demo

密钥认证：

1. 可通过配置文件指定私钥，不指定自动生成存放于数据库中
2. 通过密码将私钥传输到远程服务器中，但不能存储密码

https://github.com/etcd-io/etcd/releases/download/v3.5.7/etcd-v3.5.7-linux-amd64.tar.gz
https://github.com/containerd/containerd/releases/download/v1.7.1/containerd-1.7.1-linux-amd64.tar.gz
https://github.com/containerd/containerd/releases/download/v1.7.1/cri-containerd-cni-1.7.1-linux-amd64.tar.gz
https://github.com/opencontainers/runc/releases/download/v1.1.7/runc.amd64
