#!/bin/bash
set -e

MASTER_IP="192.168.56.10"
POD_CIDR="192.168.0.0/16"

echo "[MASTER] Initializing Kubernetes control plane"

kubeadm init \
    --apiserver-advertise-address=${MASTER_IP} \
    --pod-network-cidr=${POD_CIDR}

echo "[MASTER] Configuring kubectl access"

mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

echo "[MASTER] Installing Calico CNI"
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

echo "[MASTER] Waiting for API server to stabilize"
sleep 30

echo "[MASTER] Generating worker join command"
kubeadm token create --print-join-command >/vagrant/join.sh
chmod +x /vagrant/join.sh

echo "[MASTER] Control plane setup complete"
