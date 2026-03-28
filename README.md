# Kubernetes Cluster using Vagrant & kubeadm

---

## Overview

This project provisions a **fully functional, multi-node Kubernetes cluster** locally using **Vagrant**, **VirtualBox**, and **kubeadm**.

The goal of this project is to simulate a **production-style Kubernetes environment** on local infrastructure, focusing on:

- Infrastructure reproducibility
- Proper Kubernetes bootstrapping
- Real-world debugging and failure handling
- DevOps best practices using Infrastructure as Code (IaC)

This project is also well-suited for **CKA (Certified Kubernetes Administrator)** and **CKAD (Certified Kubernetes Application Developer)** exam preparation, providing a hands-on environment that closely mirrors the exam cluster topology.

The cluster is designed to be **portable**, meaning it can be spun up on any compatible Windows or Linux machine using a single command:

```
vagrant up
```

---

## Architecture

<img width="1101" height="1051" alt="K8s-Vagrant-Kubeadm-Cluster" src="https://github.com/user-attachments/assets/9fb21acd-bc4b-4767-bb41-493e056355be" />


### Cluster Topology

- **1 Control Plane Node**
- **2 Worker Nodes**

### Node Details

| Node Name        | Role            | IP Address        |
|------------------|-----------------|-------------------|
| k8s-master       | Control Plane   | 192.168.56.10     |
| k8s-worker-1     | Worker Node     | 192.168.56.11     |
| k8s-worker-2     | Worker Node     | 192.168.56.12     |

### Technology Stack

- **Host Provisioning**: Vagrant
- **Hypervisor**: VirtualBox
- **Guest OS**: Ubuntu 22.04 LTS
- **Container Runtime**: containerd
- **Kubernetes Bootstrap**: kubeadm
- **Networking (CNI)**: Calico
- **Kubernetes Version**: v1.32
- **Calico Version**: v3.29.0

---

## Configuration

All version and network settings are centralised in `config/settings.yaml`:

```yaml
kubernetes_version: "v1.32"
calico_version: "v3.29.0"
pod_cidr: "192.168.0.0/16"
master_ip: "192.168.56.10"
```

To upgrade Kubernetes or Calico, change the version here — no need to touch any scripts or the Vagrantfile.

---

## Key Design Decisions

### 1. kubeadm-based Cluster

- Mirrors real-world Kubernetes bootstrapping.
- Avoids managed abstractions (EKS/AKS/GKE) to gain deeper understanding.

### 2. containerd as Runtime

- Industry standard container runtime.
- Required explicit systemd cgroup alignment for kubelet compatibility.

### 3. Calico CNI

- Production-grade networking solution.
- Supports network policies and scalable pod networking.

### 4. Host-Only Networking

- Ensures deterministic node-to-node communication.
- Avoids dependency on external networks.

### 5. Script-Based Provisioning

- Modular shell scripts for:
  - OS preparation
  - container runtime installation
  - Kubernetes component installation
- Improves maintainability and debugging.

---

## Prerequisites

### Host Machine Requirements

- **Installed Software**
  - VirtualBox
  - Vagrant
  - Git

- **Hardware**
  - Minimum 8 GB RAM (16 GB recommended)
  - CPU virtualization enabled (VT-x / AMD-V)

### Notes

- On Windows, Hyper-V, VBS, and host-only network adapters may interfere with VirtualBox.
- Linux hosts generally provide a smoother experience.

---

## Installation Instructions

### 1. Clone the Repository

```
git clone https://github.com/Abhiram-Rakesh/K8s-Vagrant-Kubeadm-Cluster.git
cd K8s-Vagrant-Kubeadm-Cluster
```

### 2. Bring Up the Cluster

```
vagrant up
```

This command will:
  - Create 3 Ubuntu VMs
  - Configure networking
  - Install containerd
  - Install Kubernetes components
  - Initialize the control plane
  - Deploy Calico
  - Join worker nodes to the cluster

### 3. Access the Cluster

```
vagrant ssh k8s-master
```

### 4. Validate the Setup

```
kubectl get nodes
kubectl get pods -n kube-system
```

Expected output:

```
k8s-master     Ready   control-plane
k8s-worker-1   Ready
k8s-worker-2   Ready
```

---

## Teardown

To stop the VMs without destroying them:

```
vagrant halt
```

To destroy the cluster and free all resources:

```
vagrant destroy -f
```

---

## Troubleshooting Guide

This project intentionally documents real-world issues encountered during setup.

### Common Issues & Resolutions

#### 1. VM Name Already Exists (Windows)

- **Cause:** A previous `vagrant up` failed mid-way, leaving stale VM registrations in VirtualBox
- **Fix:**
  1. Open VirtualBox GUI → right-click each stale VM → **Remove → Delete all files**
  2. If VMs don't appear in GUI, unregister manually:
     ```
     VBoxManage list vms
     VBoxManage unregistervm <uuid> --delete
     ```
  3. Delete Vagrant's local state: `rm -r .vagrant`
  4. Run `vagrant up`

#### 2. SSH Timeout on Boot (Windows)

- **Cause:** Hyper-V or Windows Hypervisor Platform is enabled and competing with VirtualBox for hardware virtualisation
- **Fix:**
  1. Open PowerShell as Administrator and check:
     ```
     bcdedit /enum | findstr hypervisorlaunchtype
     ```
  2. If it shows `Auto`, disable it:
     ```
     bcdedit /set hypervisorlaunchtype off
     ```
  3. Also disable in **Windows Features**: Hyper-V, Virtual Machine Platform, Windows Hypervisor Platform
  4. Reboot, then run `vagrant up`

#### 3. SSH Timeout — Port 2222 Already in Use (Windows)

- **Cause:** A leftover `VBoxHeadless.exe` process from a previous run is holding port 2222
- **Fix:**
  1. Find the process:
     ```
     netstat -ano | findstr :2222
     ```
  2. Kill it using the PID from the output:
     ```
     taskkill /F /PID <pid>
     ```
  3. Run `vagrant destroy -f` then `vagrant up`

#### 4. containerd CRI Errors

- **Cause:** Misaligned cgroup driver or corrupted runtime state
- **Fix:** Fully reset containerd and regenerate configuration with **SystemdCgroup=true**

#### 5. kubelet TLS Bootstrap Failures

- **Cause:** Transient API server unavailability during worker node join (cluster still stabilising post-Calico deployment)
- **Fix:** The worker script automatically retries the join up to 3 times. If it still fails, re-provision manually:
  ```
  vagrant provision k8s-worker-1
  vagrant provision k8s-worker-2
  ```

These issues and fixes closely resemble problems seen in on-prem and bare-metal Kubernetes environments.

---

## Recap

This project demonstrates:
  - End-to-end Kubernetes cluster provisioning using kubeadm
  - Practical experience with container runtimes and kubelet behavior
  - Debugging Kubernetes networking, certificates, and node bootstrap
  - Infrastructure automation using Vagrant
