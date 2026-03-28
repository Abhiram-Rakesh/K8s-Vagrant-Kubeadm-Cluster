#!/bin/bash
set -e

echo "[K8S] Adding Kubernetes apt repository"
curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list

apt-get update -y

echo "[K8S] Installing kubeadm, kubelet, kubectl"
apt-get install -y kubelet kubeadm kubectl

apt-mark hold kubelet kubeadm kubectl

systemctl enable kubelet

echo "[K8S] Kubernetes binaries installed"
