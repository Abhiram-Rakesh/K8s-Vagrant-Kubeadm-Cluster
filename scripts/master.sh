#!/bin/bash
set -e

echo "[MASTER] Initializing Kubernetes control plane"

kubeadm init \
    --apiserver-advertise-address=${MASTER_IP} \
    --pod-network-cidr=${POD_CIDR}

echo "[MASTER] Configuring kubectl access"

mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

echo "[MASTER] Waiting for API server to be ready"
until kubectl get nodes &>/dev/null; do
    echo "  API server not ready yet, retrying in 5s..."
    sleep 5
done

echo "[MASTER] Installing Calico CNI"
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/calico.yaml

echo "[MASTER] Setting up kubectl completion and alias"
apt-get install -y bash-completion
echo 'source <(kubectl completion bash)' >> /home/vagrant/.bashrc
echo 'alias k=kubectl' >> /home/vagrant/.bashrc
echo 'complete -F __start_kubectl k' >> /home/vagrant/.bashrc

echo "[MASTER] Generating worker join command"
kubeadm token create --print-join-command > /vagrant/join.sh
chmod +x /vagrant/join.sh

echo "[MASTER] Control plane setup complete"
