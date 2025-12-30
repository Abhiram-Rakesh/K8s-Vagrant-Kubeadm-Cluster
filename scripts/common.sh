#!/bin/bash
set -e

echo "🔧 [COMMON] Disabling swap"
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "🔧 [COMMON] Loading kernel modules"
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

echo "🔧 [COMMON] Applying sysctl params"
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

echo "✅ [COMMON] OS bootstrap complete"
