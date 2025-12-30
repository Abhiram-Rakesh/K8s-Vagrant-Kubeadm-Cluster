#!/bin/bash
set -e

echo "🐳 [CONTAINERD] Installing dependencies"
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

echo "🐳 [CONTAINERD] Installing containerd"
apt-get install -y containerd

echo "🐳 [CONTAINERD] Configuring containerd"
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Enable systemd cgroup driver (REQUIRED for kubeadm)
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

echo "✅ [CONTAINERD] containerd ready"
